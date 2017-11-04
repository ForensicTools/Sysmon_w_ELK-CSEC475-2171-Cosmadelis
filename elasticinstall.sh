# Install and configure the ELK Stack
# By: Michael Cosmadelis
#
# Resources: https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-centos-7
#

# get kibanaadmin password
echo "Please enter a password for kibanaadmin: "

read pass

# Install Java
yum install -y java

# Install elasticsearch

rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
echo "[elastic-5.x]" > /etc/yum.repos.d/elastic.repo
echo "name=Elastic repository for 5.x packages" >> /etc/yum.repos.d/elastic.repo
echo "baseurl=https://artifacts.elastic.co/packages/5.x/yum" >> /etc/yum.repos.d/elastic.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/elastic.repo
echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch" >> /etc/yum.repos.d/elastic.repo
echo "enabled=1" >> /etc/yum.repos.d/elastic.repo
echo "autorefresh=1" >> /etc/yum.repos.d/elastic.repo
echo "type=rpm-md" >> /etc/yum.repos.d/elastic.repo

yum install -y elasticsearch
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

# Install Kibana
echo "Installing kibana..."

echo "[kibana-4.4]" > /etc/yum.repos.d/kibana.repo
echo "name=Kibana repository for 4.4.x packages" >> /etc/yum.repos.d/kibana.repo
echo "baseurl=http://packages.elastic.co/kibana/4.4/centos" >> /etc/yum.repos.d/kibana.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/kibana.repo
echo "gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch" >> /etc/yum.repos.d/kibana.repo
echo "enabled=1" >> /etc/yum.repos.d/kibana.repo

yum install -y kibana

# nginx install
yum install -y epel-release
yum install -y nginx httpd-tools

htpasswd -c /etc/nginx/htpasswd.users $pass

systemctl start nginx
systemctl enable nginx

# have to then remove the server block, not being done yet

echo "server {" > /etc/nginx/conf.d/kibana.conf
echo -e "\tlisten 80;" >> /etc/nginx/conf.d/kibana.conf
echo -e "\tserver_name domain.com" >> /etc/nginx/conf.d/kibana.conf 
echo -e "\tauth_basic 'Restricted Access'" >> /etc/nginx/conf.d/kibana.conf
echo -e "\tlocation / {" >> /etc/nginx/conf.d/kibana.conf
echo -e "\t\tproxy_pass http://localhost:5601 " >> /etc/nginx/conf.d/kibana.conf
echo -e "\t\tproxy_http_version 1.1" >> /etc/nginx/conf.d/kibana.conf
echo -e "\t\tproxy_set_header Upgrade $http_upgrade" >> /etc/nginx/conf.d/kibana.conf
echo -e "\t\tproxy_set_header Connection 'upgrade'" >> /etc/nginx/conf.d/kibana.conf
echo -e "\t\tproxy_set_header Host $host" >> /etc/nginx/conf.d/kibana.conf
echo -e "\t\tproxy_cache_bypass $http_upgrade" >> /etc/nginx/conf.d/kibana.conf
echo -e "\t}" >> /etc/nginx/conf.d/kibana.conf
echo -e "}" >> /etc/nginx/conf.d/kibana.conf

# Install Logstash
# need to set configurations
yum -y install logstash
