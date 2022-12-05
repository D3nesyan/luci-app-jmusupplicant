include $(TOPDIR)/rules.mk

LUCI_TITLE:=JMUSupplicant 802.1X Client for LuCI
LUCI_DEPENDS:=+jmusupplicant
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-jmusupplicant
PKG_VERSION:=1.1.1
PKG_RELEASE:=4

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
