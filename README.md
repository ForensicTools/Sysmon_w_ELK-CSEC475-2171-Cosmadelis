# Sysmon_w_ELK-CSEC475-2171-Cosmadelis-Drozenski


This tool will automatically deploy and configure the ELK Stack to analyze and visualize Sysmon logs.  This will prompt the user to enter the hostnames or IP addresses to remote into one or more Windows machines, install Sysmon and configure the host to forward these logs to ELK. Documentation will be provided on any requirements and configurations that must be present in the environment. This will be based on the tool ossecKibanaElkonWindows-475-2161_bornholm from the ForensicTools Github.


# Configure Windows for Ansible 
1) Download the repository to a Windows host
2) cd Sysmon_w_ELK-CSEC475-2171-Cosmadelis-Drozenski
3) Edit the windows_hosts.txt
4) Set ansible_user and ansible_password in group_vars/windows
5) .\psexec_ansible_setup.ps1'

