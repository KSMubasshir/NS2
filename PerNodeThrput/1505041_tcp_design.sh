ns 1505041_Wireless_802_11_static.tcl 1
awk -f 1505041_rule_tcp_wireless.awk 1505041_tcp_wireless.tr
xgraph -x "nodeX" -y "throughput" graph.txt
