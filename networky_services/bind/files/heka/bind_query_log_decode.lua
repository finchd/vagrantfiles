--[[BIND query log Lua decoder script

BIND DNS query log decoder script for the Heka stream processor:

http://hekad.readthedocs.org/en/latest/

Adapted from: https://github.com/mozilla-services/heka/wiki/How-to-convert-a-PayloadRegex-MultiDecoder-to-a-SandboxDecoder-using-an-LPeg-Grammar

Built with the help of: http://lpeg.trink.com/

Reference for LPEG functions and uses: http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html

Example use:

[bind_query_logs]
type = "LogstreamerInput"
decoder = "bind_query_log_decoder"
file_match = 'named_query.log'
log_directory = "/var/log/named"

[bind_query_log_decoder]
type = "SandboxDecoder"
filename = "lua_decoders/bind_query_log_decoder.lua"
  [bind_query_log_decoder.config]
  log_format = ''
  type = "bind.query"

Sample BIND query log message, with the print-category, print-severity and print-time options
all set to 'yes' in the logging channel options in named.conf:

27-May-2015 21:06:49.246 queries: info: client 10.0.1.70#41242 (webserver.company.com): query: webserver.company.com IN A +E (10.0.1.71)

The things we want out of it are:

* The client IP
* The name that was queried
* The domain of the name that was queried
* The record type (A, MX, PTR, etc.)
* The address of the interface that BIND used for the reply

--]]

require "table"
require "string"
require "lpeg"
local date_time = require "date_time"
local ip = require "ip_address"
l.locale(l)

local syslog   = require "syslog"
local formats  = read_config("formats")
--The config for the SandboxDecoder plugin should have the type set to 'bindquerylog'
local msg_type = read_config("type")

--[[ Generic patterns --]]
--Patterns for the literals in the log lines that don't change from query to query
local space = l.space
-- ':'
local colon_literal = l.P":"
-- 'queries'
local queries_literal = l.P"queries:"
-- '#'
local pound_literal = l.P"#" 
-- 'info'
local info_literal = l.P"info:"
-- 'client'
local client_literal = l.P"client:"
-- '('
local open_paran_literal = l.P"("
-- ')'
local close_paran_literal = l.P")"
-- 'query'
local query_literal = l.P"query:"
-- 'IN' literal string; 
local in_literal = l.P"IN"
-- '+' literal character; + indicates that recursion was requested.
local plus_literal = l.P"+"
-- '-' literal character; - indicates that recursion was not requested.
local plus_literal = l.P"-"
-- 'E' literal character; E indicates that extended DNS was used
-- Source: http://ftp.isc.org/isc/bind9/cur/9.9/doc/arm/Bv9ARM.ch06.html#id2575001
-- More about EDNS: https://en.wikipedia.org/wiki/Extension_mechanisms_for_DNS
local e_literal = l.P"E"
-- 'S' literal character; s indicates that the query was signed
-- Source: http://ftp.isc.org/isc/bind9/cur/9.9/doc/arm/Bv9ARM.ch06.html#id2575001
local s_literal = l.P"S"
--'D' literal character; if DNSSEC Ok was set
-- Source: http://ftp.isc.org/isc/bind9/cur/9.9/doc/arm/Bv9ARM.ch06.html#id2575001
local d_literal = l.P"D"
--'T' literal character; if TCP was used
-- Source: http://ftp.isc.org/isc/bind9/cur/9.9/doc/arm/Bv9ARM.ch06.html#id2575001
local t_literal = l.P"T"
--'C' literal character; if checking disabled was set
-- Source: http://ftp.isc.org/isc/bind9/cur/9.9/doc/arm/Bv9ARM.ch06.html#id2575001
local c_literal = l.P"C"


--[[ More complicated patterns for things that do change from line to line: --]]

--The below pattern matches date/timestamps in the following format:
-- 27-May-2015 21:06:49.246
-- The milliseconds (the .246) are discarded by the `l.P"." * l.P(3)` at the end:
--Source: https://github.com/mozilla-services/lua_sandbox/blob/dev/modules/date_time.lua
local timestamp = l.Cg(date_time.build_strftime_grammar("%d-%B-%Y %H:%M:%S") / date_time.time_to_ns, "timestamp") * l.P"." * l.P(3)
local x4            = l.xdigit * l.xdigit * l.xdigit * l.xdigit

--The below pattern matches IPv4 addresses from BIND query logs like the following:
-- 10.0.1.70#41242
-- The # and ephemeral port number are discarded by the `pound_literal * l.P(5)` at the end:
local client_address = l.Cg(l.Ct(l.Cg(ip.v4, "value") * l.Cg(l.Cc"ipv4", "representation")), "client_address") * pound_literal * l.P(5)

--DNS query record types:
--Create a capture group that will match the DNS record type:
dns_record_type = l.Cg(
      l.P"A" /"A"
    + l.P"CNAME" /"CNAME"
    + l.P"MX" /"MX"
    + l.P"PTR" /"PTR"
    + l.P"AAAA" /"AAAA"
    + l.P"SOA" /"SOA"
    + l.P"NS" /"NS"
    + l.P"SRV" /"SRV"
    , "record_type")

-- 27-May-2015 21:06:49.246 queries: info: client 10.0.1.70#41242 (webserver.company.com): query: webserver.company.com IN A +E (10.0.1.71)

local bind_query = timestamp * space * queries_literal * space * info_literal * space * client_literal * space * client_address


grammar = l.Ct(bind_query)
local msg = {
  Type        = msg_type,
  Payload     = nil,
  Pid         = nil,
  Severity    = nil,
  Fields      = {
    -- If the query was for webserver.company.com, the fields would get filled in as follows:
    -- webserver
    Query       = nil, -- webserber
    QueryDomain = nil, -- company.com
    RecordType  = nil, -- A, MX, PTR, etc.
    ClientIP    = nil
  }
}

function process_message ()

  local query_log_line = read_message("Payload")
  if not fields then return -1 end
  --Set the time in the message we're generating and set it to nil in the original log line:
  msg.Timestamp = fields.time
  fields.time = nil

  msg.Fields = fields
  inject_message(msg)

  return 0

end