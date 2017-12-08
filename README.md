# Sysmon_w_ELK-CSEC475-2171-Cosmadelis

This tool automatically deploys and configures the ELK stack to analyze and visualize Sysmon logs. Using an Ansible script, Sysmon and Winlogbeat will be installed on the windows hosts specified by the user in windows_hosts.txt. This will be based on the tool ossecKibanaElkonWindows-475-2161_bornholm from the ForensicTools Github.

## Requirements:
1) A CentOS 7 (server)
    a) With Ansible installed
2) At least one Windows 10 host (client)

## Installing/Deploying ELK Stack
1) git clone https://github.com/ForensicTools/Sysmon_w_ELK-CSEC475-2171-Cosmadelis
2) cd Sysmon_w_ELK-CSEC475-2171-Cosmadelis
3) ./elasticinstall.sh

## Configure Windows for Ansible
1) Download the repository to a Windows host
2) cd Sysmon_w_ELK-CSEC475-2171-Cosmadelis
3) Edit the windows_hosts.txt
4) Set ansible_user and ansible_password in group_vars/windows
5) .\winrm_init.ps1

## Set IP Addresses
1) Change “localhost” to the IP of the server win conf/winbeat/winlogbeat.yml
2) Set up windows_hosts.txt to IP/Hostnames of 
3) Run Ansible scripts
4) Configure windows_hosts.txt with a list of IP addresses or hostnames
5) Run “ansible-playbook -i windows_hosts.txt deploy_agents.yml -u root”
6) Go to https://localhost from the CentOS server to access kibana

For information on configuring visualizations and dashboards, see:
https://cyberwardog.blogspot.com/2017/03/building-sysmon-dashboard-with-elk-stack.html 

