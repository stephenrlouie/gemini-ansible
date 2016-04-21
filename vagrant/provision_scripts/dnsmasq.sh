cat >> /etc/dnsmasq.conf << EOF

dhcp-option=3
dhcp-option=6

EOF

systemctl restart dnsmasq.service
