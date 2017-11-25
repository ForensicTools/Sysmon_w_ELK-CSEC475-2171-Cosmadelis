# Install and configure the ELK Stack
# By: Michael Cosmadelis
#
# Resources: https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-centos-7
#	     https://github.com/ForensicTools/ossecKibanaElkonWindows-475-2161_bornholm/
#

#i SELinux muse be set to permissive

setenforce 0

set -x
set -e

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Install Java
yum install -y java
yum install -y java-devel

# Install elasticsearch
echo '[logstash-6.x]
name=Elastic repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
' | tee /etc/yum.repos.d/logstash.repo


rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch


yum install -y elasticsearch

curl -XGET localhost:9200
curl -XGET 'http://localhost:9200/_cluster/health?pretty=true'

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

systemctl daemon-reload
systemctl start kibana

# nginx install
yum install -y epel-release
yum install -y nginx httpd-tools
yum install certbot -y

htpasswd -c /etc/nginx/htpasswd.users kibanaadmin

cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
yes | cp -f conf/nginx/nginx.conf /etc/nginx/nginx.conf

echo 'server {
    listen 80;

    server_name example.com;

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;        
    }
}
' | tee /etc/nginx/conf.d/kibana.conf

echo 'server {
  listen 80;
  location ~ /.well-known {
      allow all;
  }
}
' | tee /etc/nginx/conf.d/letsencrypt.conf


systemctl start nginx

mkdir /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx-selfsigned.key -out /etc/nginx/ssl/nginx-selfsigned.crt
openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048

rm -rf /etc/nginx/conf.d/letsencrypt.conf

echo "server {
    listen 443 ssl;
    server_name _;
    ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;
    ssl_dhparam /etc/nginx/ssl/dhparam.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling on;
    ssl_stapling_verify on;
    add_header Strict-Transport-Security max-age=15768000;
    location ~ /.well-known {
        allow all;
    }
    auth_basic 'Restricted Access';
    auth_basic_user_file /etc/nginx/htpasswd.users;
    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
" | tee /etc/nginx/conf.d/kibana.conf
systemctl enable nginx
systemctl restart nginx
setsebool -P httpd_can_network_connect 1



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

/usr/share/logstash/bin/logstash-plugin install logstash-input-beats

cat > /etc/logstash/conf.d/02-beats-input.conf << EOF
input {
beats {
port => 5044
ssl => false
}
}
EOF

cat /etc/logstash/conf.d/30-elasticsearch.conf << EOF
output {
elasticsearch {
hosts = ["http://localhost:9200"]
index = "%{type}-%{[@metadata][beat]}-%{+YYYY.MM.dd}"
document_type = "%{[@metadata][type]}"
}
}
EOF

systemctl restart logstash
systemctl enable logstash

# Install/Configure firewall
sudo yum install firewalld -y
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd –zone=public –permanent –add-service=http
sudo firewall-cmd –zone=public –permanent –add-service=https
sudo firewall-cmd –zone=public –permanent –add-service=ssh
sudo firewall-cmd –zone=public –permanent –add-port=5044/tcp
sudo firewall-cmd –zone=public –permanent –add-port=9200/tcp
sudo firewall-cmd –reload




