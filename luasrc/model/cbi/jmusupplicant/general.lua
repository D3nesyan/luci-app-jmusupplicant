local function is_running(name)
	if luci.sys.call("pidof %s >/dev/null" %{name}) == 0 then
		return translate("RUNNING")
	else
		return translate("NOT RUNNING")
	end
end

local function is_online(ipaddr)
	if ipaddr == "0.0.0.0" then 
		return translate("Pinghost not set")
	end
	if luci.sys.call("ping -c1 -w1 %s >/dev/null 2>&1" %{ipaddr}) == 0 then
		return translate("ONLINE")
	else
		return translate("NOT ONLINE")
	end
end

require("luci.sys")

m = Map("jmusupplicant", translate("JMUSupplicant"))
m.description = translate("Configure JMUSupplicant 802.11x.")

s = m:section(TypedSection, "jmusupplicant", translate("Status"))
s.anonymous = true

status = s:option(DummyValue,"_jmusupplicant_status", "JMUSupplicant")
status.value = "<span id=\"_jmusupplicant_status\">%s</span>" %{is_running("jmusupplicant")}
status.rawhtml = true
t = io.popen('uci get jmusupplicant.@jmusupplicant[0].pinghost')
netstat = is_online(tostring(t:read("*line")))
t:close()
if netstat ~= "" then
netstatus = s:option(DummyValue,"_network_status", translate("Network Status"))
netstatus.value = "<span id=\"_network_status\">%s</span>" %{netstat}
netstatus.rawhtml = true
end

o = m:section(TypedSection, "jmusupplicant", translate("Settings"))
o.addremove = false
o.anonymous = true

o:tab("base", translate("Normal Settings"))
o:tab("advanced", translate("Advanced Settings"))

enable = o:taboption("base", Flag, "enable", translate("Enable"))

name = o:taboption("base", Value, "username", translate("Username"))
name.description = translate("The username given to you by your network administrator")

pass = o:taboption("base", Value, "password", translate("Password"))
pass.description = translate("The password you set or given to you by your network administrator")
pass.password = true

ifname = o:taboption("base", ListValue, "ifname", translate("Interfaces"))
ifname.description = translate("Physical interface of WAN")
for k, v in ipairs(luci.sys.net.devices()) do
    if v ~= "lo" then
        ifname:value(v)
    end
end

pinghost = o:taboption("base", Value, "pinghost", translate("PingHost"))
pinghost.description = translate("Ping host for drop detection, 0.0.0.0 to turn off this feature")
pinghost.default = "0.0.0.0"

ipaddr = o:taboption("advanced", Value, "ipaddr", translate("IP Address"))
ipaddr.description = translate("Your IPv4 Address. (DHCP users can set to 0.0.0.0)")
ipaddr.default = "0.0.0.0"

mask = o:taboption("advanced", Value, "mask", translate("NetMask"))
mask.description = translate("NetMask, it doesn't matter")
mask.default = "0.0.0.0"

gateway = o:taboption("advanced", Value, "gateway", translate("Gateway"))
gateway.description = translate("Gateway, if specified, will monitor gateway ARP information")
gateway.default = "0.0.0.0"

dnsserver = o:taboption("advanced", Value, "dns", translate("DNS server"))
dnsserver.description = translate("DNS server, it doesn't matter")
dnsserver.default = "0.0.0.0"

echointerval = o:taboption("advanced", Value, "echointerval", translate("EchoInterval"))
echointerval.description = translate("Interval for sending Echo packets (seconds)")
echointerval.default = "30"

restartwait = o:taboption("advanced", Value, "restartwait", translate("RestartWait"))
restartwait.description = translate("Failed Wait (seconds) Wait for seconds after authentication failed or restart authentication after server request")
restartwait.default = "15"

netoperator = o:taboption("advanced", ListValue, "netoperator", translate("NetOperator"))
netoperator.description = translate("Network Operator")
netoperator:value(0, translate("Education Network"))
netoperator:value(1, translate("China Unicom"))
netoperator:value(2, translate("China Mobile"))
netoperator:value(3, translate("China Telecom"))
netoperator.default = "0"

local apply = luci.http.formvalue("cbi.apply")
if apply then
	io.popen("/etc/init.d/jmusupplicant restart")
end

return m
