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
m.description = translate("集美大学校园网认证 (JMUSupplicant) 设置")

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

ipaddr_midnight = o:taboption("base", Value, "ipaddr_midnight", translate("断网模式使用的 IP 地址"))
ipaddr_midnight.description = translate("指定 IPV4 地址，如打开断网模式或自动重连功能，请在此填入无断网办公区域的 IP 地址。在断网模式未开启时，本选项将没有任何作用")
ipaddr_midnight.default = "0.0.0.0"

cronset_midnight = o:taboption("base", Flag, "cronset_midnight", translate("自动重连"))
cronset_midnight.description = translate("注意: 本选项使用 Crontab 实现。本选项开启后, 将在每天 6:10, 周日到周四晚上 23:00, 周五到周六晚上 23:59 自动执行和断网模式有关的相关任务")

pinghost = o:taboption("base", Value, "pinghost", translate("Ping 主机"))
pinghost.description = translate("用于检测网络状态的 Ping 主机地址，可设置成 0.0.0.0 以关闭该功能")
pinghost.default = "223.5.5.5"

advanced = o:taboption("advanced", Flag, "advanced", translate("高级选项开关"))
advanced.description = translate("仅在本开关开启后，高级选项中的设置内容生效")

cronset_advanced = o:taboption("advanced", Flag, "cronset_advanced", translate("定时开启高级模式"))
cronset_advanced.description = translate("注意: 本选项使用 Crontab 实现。本选项开启后, 将在每天 6:10, 周日到周四晚上 23:00, 周五到周六晚上 23:59 自动开启高级模式并重启插件")

ipaddr = o:taboption("advanced", Value, "ipaddr", translate("IP 地址"))
ipaddr.description = translate("自定义 IP 地址，可设置成 0.0.0.0 以关闭该功能")
ipaddr.default = "0.0.0.0"

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
