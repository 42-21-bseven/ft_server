sed -i {'s/autoindex off/autoindex on/'} /etc/nginx/sites-available/xz_site.conf
service nginx reload
