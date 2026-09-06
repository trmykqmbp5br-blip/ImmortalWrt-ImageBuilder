#!/bin/sh
# nat-masq-ensure.sh — 确保 WAN MASQUERADE 规则存在（fw4 iptables-nft 缺陷补救）
# 被 rc.local / 99-multipath / ecmp-reload 统一调用，改一处即生效

for wan_if in pppoe-wan pppoe-wanb; do
  if ip link show "$wan_if" >/dev/null 2>&1; then
    nft add table ip nat 2>/dev/null
    nft "add chain ip nat POSTROUTING { type nat hook postrouting priority srcnat; policy accept; }" 2>/dev/null
    if ! nft list chain ip nat POSTROUTING 2>/dev/null | grep -q "oifname \"$wan_if\".*masquerade"; then
      nft add rule ip nat POSTROUTING oifname "$wan_if" counter masquerade && \
        echo "[nat-masq-ensure] added masquerade for $wan_if"
    fi
  fi
done
