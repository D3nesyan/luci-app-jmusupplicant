module("luci.controller.jmusupplicant", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/jmusupplicant") then
		return
	end

	if luci.sys.call("command -v jmusupplicant >/dev/null") ~= 0 then
		return
	end

	local page = entry({"admin", "services", "jmusupplicant"}, alias("admin", "services", "jmusupplicant", "general"), _("JMUSupplicant"))
	page.order = 10
	page.dependent = true
	page.acl_depends = { "luci-app-jmusupplicant" }

	entry({"admin", "services", "jmusupplicant", "general"}, cbi("jmusupplicant/general"), _("JMUSupplicant Settings"), 10).leaf = true
	entry({"admin", "services", "jmusupplicant", "log"}, cbi("jmusupplicant/log"), _("JMUSupplicant LOG"), 20).leaf = true
end
