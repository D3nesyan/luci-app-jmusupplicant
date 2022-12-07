local fs = require "nixio.fs"

local f = SimpleForm("jmusupplicant",
	translate("运行日志"),
	translate("日志文件路径: /tmp/jmusupplicant.log"))

local o = f:field(Value, "jmusupplicant_log")

o.template = "cbi/tvalue"
o.rows = 32

function o.cfgvalue(self, section)
	return fs.readfile("/tmp/jmusupplicant.log")
end

function o.write(self, section, value)
	require("luci.sys").call('cat /dev/null > /tmp/jmusupplicant.log 2>/dev/null')
end

f.submit = translate("清除日志")
f.reset = false

return f
