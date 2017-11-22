# Install and configure the ELK Stack
# By: Michael Cosmadelis
#
# Resources: https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-centos-7
#


if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# get kibanaadmin password
echo "Please enter a password for kibanaadmin: "

read pass
# Install Java
yum install -y java

# Install elasticsearch

rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

echo '[elastic-5.x]
name=Elastic repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
' | tee /etc/yum.repos.d/elastic.repo

yum install -y elasticsearch
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

# Install Kibana
echo "Installing kibana..."

echo '[kibana-4.4]
name=Kibana repository for 4.4.x packages
baseurl=http://packages.elastic.co/kibana/4.4/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
' | tee /etc/yum.repos.d/kibana.repo

yum install -y kibana

# nginx install
yum install -y epel-release
yum install -y nginx httpd-tools

htpasswd -c /etc/nginx/htpasswd.users $pass

cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
mv /conf/nginx/nginx.conf /etc/nginx/nginx.conf

exho 'server {
    listen 80;

    server_name example.com;

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;        
    }
}
' | tee /etc/nginx/conf.d/kibana.conf



systemctl start nginx
systemctl enable nginx


# Install Logstash
# need to set configurations
echo '[logstash-2.2]
name=logstash repository for 2.2 packages
baseurl=http://packages.elasticsearch.org/logstash/2.2/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
' | tee /etc/yum.repos.d/logstash.repo

yum -y install logstash



