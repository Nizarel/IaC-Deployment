FrontEnd
	- Set Resource Group Fe
	- Set a Public IP adress
	- Set FE Vnet
	- Set AzuraFirewallSubnet
	- Jbox-subnet
         - FW-01 (Firewall)

Backend
	- Set BE Resource Group
	- Set Web Vnet
		○ Web Subnet
	- Web-Interface
	- Web-NSG
	- Web-VM01

Peering
	- Configure vNet peering between the fw-vnet & web-vnet 
	- 2 NAT rules on the firewall
		○ NAT Rule to allow RDP to jbox from anywhere
		○ NAT rule to allow traffic to webserver from anywhere
        Allowing RDP to webserver from Jbox-vm01

![image](https://user-images.githubusercontent.com/46408023/111848629-c7859c80-890b-11eb-81a3-19db81954dfa.png)
