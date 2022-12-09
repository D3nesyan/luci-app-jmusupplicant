local function is_running(name)
	if luci.sys.call("pidof %s >/dev/null" %{name}) == 0 then
		return translate("运行中")
	else
		return translate("未运行")
	end
end

local function is_online(pinghost)
	if pinghost == "0.0.0.0" then 
		return translate("Ping 主机未设置")
	end
	if luci.sys.call("ping -c1 -w1 %s >/dev/null 2>&1" %{pinghost}) == 0 then
		return translate("已连接至互联网")
	else
		return translate("未连接至互联网")
	end
end

require("luci.sys")

m = Map("jmusupplicant", translate("集美大学校园网锐捷认证"))
m.description = translate("集美大学校园网认证（JMUSupplicant）设置")

s = m:section(TypedSection, "jmusupplicant", translate("状态"))
s.anonymous = true

status = s:option(DummyValue,"_jmusupplicant_status", "认证程序")
status.value = "<span id=\"_jmusupplicant_status\">%s</span>" %{is_running("jmusupplicant")}
status.rawhtml = true
t = io.popen('uci get jmusupplicant.@jmusupplicant[0].pinghost')
netstat = is_online(tostring(t:read("*line")))
t:close()
if netstat ~= "" then
netstatus = s:option(DummyValue,"_network_status", translate("网络状态"))
netstatus.value = "<span id=\"_network_status\">%s</span>" %{netstat}
netstatus.rawhtml = true
end

o = m:section(TypedSection, "jmusupplicant", translate("设置"))
o.addremove = false
o.anonymous = true

o:tab("base", translate("常规设置"))
o:tab("advanced", translate("高级设置"))

enable = o:taboption("base", Flag, "enable", translate("开启"))

name = o:taboption("base", Value, "username", translate("用户名"))
name.description = translate("校园网用户名（通常为学号）")

pass = o:taboption("base", Value, "password", translate("密码"))
pass.description = translate("校园网密码（通常为身份证前 15 位）")
pass.password = true

ifname = o:taboption("base", ListValue, "ifname", translate("接口"))
ifname.description = translate("WAN 口的物理接口")
for k, v in ipairs(luci.sys.net.devices()) do
    if v ~= "lo" then
        ifname:value(v)
    end
end

netoperator = o:taboption("base", ListValue, "netoperator", translate("运营商服务"))
netoperator.description = translate("选择/切换运营商宽带服务")
netoperator:value(0, translate("教育网接入"))
netoperator:value(1, translate("联通宽带接入"))
netoperator:value(2, translate("移动宽带接入"))
netoperator:value(3, translate("电信宽带接入"))
netoperator.default = "0"

midnight = o:taboption("base", Flag, "midnight", translate("断网模式"))

ipaddr = o:taboption("base", Value, "ipaddr", translate("IP 地址"))
ipaddr.description = translate("指定 IPV4 地址，可填入无断网办公区域的 IP 地址")
ipaddr.default = "0.0.0.0"

cronset = o:taboption("basic", Flag, "cronset", translate("清晨自动重连"), translate("每天 6:10 A.M 进行重连 "))

pinghost = o:taboption("base", Value, "pinghost", translate("Ping 主机"))
pinghost.description = translate("用于检测网络状态的 Ping 主机地址，可设置成 0.0.0.0 以关闭该功能")
pinghost.default = "0.0.0.0"

mask = o:taboption("advanced", Value, "mask", translate("子网遮罩"))
mask.description = translate("指定子网遮罩地址，可设置成 0.0.0.0 以关闭该功能")
mask.default = "0.0.0.0"

gateway = o:taboption("advanced", Value, "gateway", translate("网关"))
gateway.description = translate("指定网关地址，可设置成 0.0.0.0 以关闭该功能")
gateway.default = "0.0.0.0"

dnsserver = o:taboption("advanced", Value, "dns", translate("DNS 服务器"))
dnsserver.description = translate("指定 DNS 服务器地址，可设置成 0.0.0.0 以关闭该功能")
dnsserver.default = "0.0.0.0"

local apply = luci.http.formvalue("cbi.apply")
if apply then
	io.popen("/etc/init.d/jmusupplicant restart")
end

return m
