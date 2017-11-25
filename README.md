# Sysmon_w_ELK-CSEC475-2171-Cosmadelis

This tool automatically deploys and configures the ELK stack to analyze and visualize Sysmon logs. Using an Ansible script, Sysmon and Winlogbeat will be installed on the windows hosts specified by the user in windows_hosts.txt. This will be based on the tool ossecKibanaElkonWindows-475-2161_bornholm from the ForensicTools Github.

## Installing/Deploying ELK Stack
1) git clone https://github.com/forensictools/Sysmon_w_ELK-CSEC475-2171-Cosmadelis
2) cd Sysmon_w_ELK-CSEC475-2171-Cosmadelis
3) ./elasticinstall.sh
    NOTE: This script sets SELinux to permissive mode

## Configure Windows for Ansible 
1) Download the repository to a Windows host
2) cd Sysmon_w_ELK-CSEC475-2171-Cosmadelis
3) Edit the windows_hosts.txt
4) Set ansible_user and ansible_password in group_vars/windows
5) .\winrm_init.ps1

