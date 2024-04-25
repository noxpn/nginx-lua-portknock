#### Portknock on lua for nginx
```
(c)noxp 2023
```


#### /etc/nginx/lua/
```
-rwxr-xr-- 1 www-data root  645 Dec  1 15:52 add_nft_rule.sh
-rwxr-xr-- 1 www-data root  348 Dec  1 15:52 del_nft_rule.sh
-rwxr-xr-- 1 www-data root 2972 Dec  1 15:59 knock.lua
-rwxr-x--x 1 www-data root  454 Dec  1 15:54 tg_send.sh
```

#### /etc/sudoers.d/www-data
```
www-data ALL=(ALL) NOPASSWD: /usr/sbin/nft
```
#### nginx.conf
```
    location ~ ^/test {
        error_log /var/log/nginx/test_error.log;
        access_by_lua_file /etc/nginx/lua/knock.lua;
    }
```

