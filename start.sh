#!/bin/bash

cd `dirname $0`
rm -f nginx*
cp -f tpl/nginx.conf ./
mkdir -p server
rm -f server/*.conf

sed_tag=""
sed_flag="$sed_flag"
if [ `uname` = 'Darwin' ];then
    sed_tag=".bak"
    sed_flag="g"
fi

replace()
{
    v=$3
    if [[ $v =~ ";" && ! $v =~ $2 ]]; then
        v=`echo "$v" | sed -E "s#;#;$2 #$sed_flag"`
    fi
    if [[ `grep -c -E "^\s*$2\s+.*;$" $1` = "0" ]]; then
        echo "$2 $v;" >> ${1%%.*}_ext.conf
    fi
    sed -i $sed_tag -E "s#^([[:blank:]]*)$2([[:blank:]]+).*;\$#\\1$2\\2$v;#$sed_flag" $1
}

echo `date '+%Y-%m-%d %H:%M:%S'`"	config /etc/nginx/nginx.conf"
env | grep -i ^NGINX_ | while read -r a
do
    a=${a:6}
    k=${a%%=*}
    v=${a#*=}
    if [[ $k = "VERSION" ]]; then
        continue
    fi
	echo `date '+%Y-%m-%d %H:%M:%S'`"	  - replace $k to [$v]"
    replace nginx.conf "$k" "$v"
done
if [[ -f "nginx_ext.conf" ]]; then
    sed -i $sed_tag -E "s!# extra configs!include nginx_ext.conf;!$sed_flag" nginx.conf
fi

env | grep -i ^SERVER_ | while read -r a
do
    a=${a:7}
    name=${a%%=*}
    type=${a#*=}

    echo `date '+%Y-%m-%d %H:%M:%S'`"	config /etc/nginx/server/$name.conf by $type"

    listen_var="${name}_listen"
    if [[ ${!listen_var} =~ "ssl" ]]; then
    echo `date '+%Y-%m-%d %H:%M:%S'`"	  - add ssl confi$sed_flag"
    	IFSbak=$IFS
		IFS="\n"
    	cat tpl/${type}_server.conf | while read -r line
		do
		    echo "$line" >> server/${name}.conf
			if [[ $line =~ "listen" ]]; then
				cat tpl/ssl.conf >> server/${name}.conf
				echo >> server/${name}.conf
			fi
		done
		IFS=$IFSbak
    else
	    cp tpl/${type}_server.conf server/${name}.conf
    fi

    if [[ $type = "php" || $type = "up" ]]; then
        sed -i $sed_tag -E "s#upname#upname_$name#$sed_flag" server/${name}.conf
    fi

    env | grep -i ^${name}_ | while read -r a
    do
        a=${a:${#name}+1}
        k=${a%%=*}
        v=${a#*=}
		echo `date '+%Y-%m-%d %H:%M:%S'`"	  - replace $k to [$v]"
        replace server/${name}.conf "$k" "$v"
    done

    if [[ -f "server/${name}_ext.conf" ]]; then
        sed -i $sed_tag -E "s!# extra configs!include server/${name}_ext.conf;!$sed_flag" server/${name}.conf
    fi
done
