# ------------------------------------------------------------
#
# PowerShell - Get-NetFirewallRule, New-NetFirewallRule (Set Inbound-Outbound rules to open tcp-udp ports, etc. via PowerShell)
#
# ------------------------------------------------------------


Get-NetFirewallRule -All;


<# TCP 21 (FTP) Firewall Inbound Whitelisting #> 
New-NetFirewallRule `
-DisplayName "FTP (TCP 21)" `
-Description "FTP - Allow Inbound TCP Traffic on Port(s) 21" `
-Direction Inbound `
-Action Allow `
-EdgeTraversalPolicy Allow `
-Protocol TCP `
-LocalPort 21 `
;


<# TCP 80 & 443 (HTTP, HTTPS) Firewall Inbound Whitelisting #> 
New-NetFirewallRule `
-DisplayName "HTTP,HTTPS (TCP 80,443)" `
-Description "HTTP,HTTPS - Allow Inbound TCP Traffic on Port(s) 80,443" `
-Direction Inbound `
-Action Allow `
-EdgeTraversalPolicy Allow `
-Protocol TCP `
-LocalPort 80,443 `
;


<# TCP 9000 (Minio) Firewall Inbound Whitelisting #>
New-NetFirewallRule `
-DisplayName "Minio (TCP 9000)" `
-Description "MinIO - Allow Inbound TCP Traffic on Port(s) 9000" `
-Direction Inbound `
-Action Allow `
-EdgeTraversalPolicy Allow `
-Protocol TCP `
-LocalPort 9000 `
;


<# TCP 27017 (MongoDB) Firewall Inbound Whitelisting #>
New-NetFirewallRule `
-DisplayName "MongoDB (TCP 27017)" `
-Description "MongoDB - Allow Inbound TCP Traffic on Port(s) 27017" `
-Direction Inbound `
-Action Allow `
-EdgeTraversalPolicy Allow `
-Protocol TCP `
-LocalPort 27017 `
;


<# TCP 3389 (Microsoft SQL) Firewall Inbound Whitelisting #>
New-NetFirewallRule `
-DisplayName "GVS Microsoft SQL (TCP 3389)" `
-Description "Microsoft SQL - Allow Inbound TCP Traffic on Port(s) 3389" `
-Direction Inbound `
-Action Allow `
-EdgeTraversalPolicy Allow `
-Protocol TCP `
-LocalPort 3389;


<# ICMPv4 Type 8 (Echo Request / Ping) Firewall Inbound Whitelisting #>
New-NetFirewallRule `
-DisplayName "PRTG_Network_Monitor_Server (ICMPv4)" `
-Description "PRTG Server - Allow/Respond to Inbound Network 'Pings' (ICMP Echo Requests)" `
-Direction Inbound `
-Action Allow `
-Profile Private `
-EdgeTraversalPolicy Allow `
-Protocol ICMPv4 `
-IcmpType 8 `
;


# ------------------------------------------------------------
#
# Citation(s)
#
#   docs.microsoft.com  |  "New-NetFirewallRule `
- Creates a new inbound or outbound firewall rule and adds the rule to the target computer"  |  https://docs.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule?view=win10-ps
#
#   docs.microsoft.com  |  "Get-NetFirewallRule - Retrieves firewall rules from the target computer"  |  https://docs.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule?view=win10-ps
#
# ------------------------------------------------------------