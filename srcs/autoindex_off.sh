sed -i {'s/autoindex on/autoindex off/'} /etc/nginx/sites-available/xz_site.conf
service nginx reload
