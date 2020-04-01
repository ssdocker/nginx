# use env to config nginx

```shell script
docker run --name nginx -d --restart=always -e nginx_gzip=off -e server_s1=php -e s1_server_name=abc.com -e s1_server=php:9000 --link php ssdockers/nginx:0.2
```

### -e nginx_OPTION=VALUE for set nginx.conf

for example

```
-e nginx_worker_processes=2
```

if option not exist in tpl/nginx.conf, will add into nginx_ext.conf and add "include nginx_ext.conf;" into nginx.conf under http section.


### -e server_SERVERNAME=TYPE for set a new server based tpl/TYPE_server.conf

for example

```
-e server_s1=php
-e server_s2=simple
-e server_s3=rproxy
-e server_s4=up
```


### -e SERVERNAME_OPTION=VALUE for set server/SERVERNAME.conf

for example

```
-e s1_server_name=abc.com
```

if option not exist in server/SERVERNAME.conf, will add into server/SERVERNAME_ext.conf and add "include server/SERVERNAME_ext.conf;" into server/SERVERNAME.conf under server section.
