# Устанавливаем дитсрибутив
FROM debian:buster

# Делаем update и upgrade
RUN apt-get update && apt-get upgrade -y

# Устанавливаем утилиты
RUN apt-get install -y nginx default-mysql-server php php-mysql php-fpm php-mbstring wget

# git curl zsh

# ZSH
# RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -y

# Создаем временные директории для распаковки сервисов
# RUN mkdir /temp/phpmyadmin /temp/wordpress /etc/nginx/ssl_certs

# Запускаем заготовку
# FROM runner

# WordPress
# dwnls
RUN wget https://wordpress.org/latest.tar.gz
# unzip & del
RUN tar -xvf latest.tar.gz && rm latest.tar.gz
# Перемещаем wordpress в директорию с моим сайтом
RUN mv wordpress /var/www/xz_site
# копируем туда же конфиг
COPY ./srcs/wp-config.php /var/www/xz_site

# phpMyAdmin
# dwnld
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-english.tar.gz
# unzip
RUN tar -xvf phpMyAdmin-5.0.4-english.tar.gz
# удаляем файл с архивом phpMyAdmin
RUN rm -rf phpMyAdmin-5.0.4-english.tar.gz
# переименовываем директорию для удобства и переместил в директорию с сайтом
RUN mv phpMyAdmin-5.0.4-english /var/www/xz_site/phpmyadmin
# копируем конфиг
COPY ./srcs/config.inc.php /var/www/xz_site/phpmyadmin/

# Nginx
# копируем конфиги в файл который называется так же как мой сайт
COPY ./srcs/nginx-conf /etc/nginx/sites-available/xz_site.conf
# создём симфолическую ссылку
RUN ln -s /etc/nginx/sites-available/xz_site.conf /etc/nginx/sites-enabled/xz_site.conf
# удаляем дефолтный сайт
RUN rm -Rf /etc/nginx/sites-enabled/default

# SSL
# создаём директории для сертификатов SSL
RUN mkdir /etc/nginx/ssl/
# создаем сертификаты
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /etc/nginx/ssl/private.pem -keyout /etc/nginx/ssl/public.key -subj "/C=RU/L=KAZAN/OU=21school/"
RUN openssl rsa -noout -text -in /etc/nginx/ssl/public.key

# меняем владельца и права файлов и директорий в каталоге с сайтом
RUN chown -R www-data /var/www/*
RUN chmod -R 755 /var/www/*

# MySQL
# копируем скрипт для создание базы данных
COPY ./srcs/wp_database.sql /
# копируем скрипы для запуска сервисов
COPY ./srcs/*.sh /

# Делаем видимыми порты 80 и 443 в контейнере для внешней машины
EXPOSE 80 443

ENTRYPOINT sh /init.sh && cat /var/log/nginx/error.log && /bin/bash
