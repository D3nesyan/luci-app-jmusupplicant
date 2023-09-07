include $(TOPDIR)/rules.mk

LUCI_TITLE:=Ruijie Authentication in JMU campus Client for LuCI
LUCI_DEPENDS:=+jmusupplicant
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-jmusupplicant
PKG_VERSION:=2.1
PKG_RELEASE:=7

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
