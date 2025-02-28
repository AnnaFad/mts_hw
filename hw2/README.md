Фадеева Анна ДЗ2
Скачиваем файлы script1.sh и script2.sh и в командной строке заходим в папку, где они хранятся.
Перекидываем эти файлы на jn (вместо  team@176.109.91.10 указать свои парамеры точки входа в систему)
```
scp script1 team@176.109.91.10:
scp script2 team@176.109.91.10:
```
Заходим в сиситему и запускаем hadoop если он ещё не запущен (см дз1)

На jn настариваем nginx для namenoode 
Если есть файл /etc/nginx/sites-available/nn, то проверяем, что в нём прописан порт 9870.
Если его нет, то создаем его.
```
cd /etc/nginx/sites-available/
sudo touch nn
```
Содержание файла должно быть таким:
```
server {
        listen 9870; 

        root /var/www/html;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                auth_basic "Administrator's Area"; 
                auth_basic_user_file /etc/.htpasswd; 
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                # try_files $uri $uri/ =404;
                proxy_pass http://<название NameNode, в моём случае tmpl-nn>:9870;  
        }
}
```

При помощи exit выходим в коммандную строку компьютера и запускаем следующую команду:
```
ssh -L 9870:<название NameNode, в моём случае tmpl-nn>:9870 team@176.109.91.10 
```
Вместо team@176.109.91.10 указать свои параметры точки входа.

При переходе на localhost:9870 в браузере будет отображаться веб-интерфейс Namenode.

Равернём Yarn
Переходим пользователя hadoop
```
sudo -i -u hadoop
```
На JNode переходим в папку в конфигами
```
cd hadoop-3.4.0/etc/hadoop
```
Открываем yarn-site.xml
```
vim yarn-site.xml
```
И вставляем следующее
```
<configuration>
	<property>
		<name>yarn.nodemanager.aux-services</name>
		<value>mapreduce_shuffle</value>
	</property>
	<property>
		<name>yarn.nodemanager.env-whitelist</name>
		<value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME,PATH,LANG,TZ,HADOOP_MAPRED_HOME</value>
	</property>
	<property>
		<name>yarn.resourcemanager.hostname</name>
		<value><название NameNode, в моём случае tmpl-nn></value>
	</property>
	<property>
		<name>yarn.resourcemanager.address</name>
		<value><название NameNode, в моём случае tmpl-nn>:8032</value>
	</property>
	<property>
		<name>yarn.resourcemanager.resource-tracker.address</name>
		<value><название NameNode, в моём случае tmpl-nn>:8031</value>
	</property>
</configuration>
```
Открываем mapred-site.xml
```
vim mapred-site.xml
```
Встевляем туда следующее
```
<configuration>
	<property>
		<name>mapreduce.framework.name</name>
		<value>yarn</value>
	</property>
	<property>
		<name>mapreduce.application.classpath</name>
		<value>$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*</value>
	</property>
</configuration>
```
Копируем файлы mapred-site.xml и yarn-site.xml на все ноды:
```
scp mapred-site.xml tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp mapred-site.xml tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp mapred-site.xml tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop

scp yarn-site.xml tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp yarn-site.xml tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp yarn-site.xml tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop
```
Переходим на namenode.
Запускаем Yarn командой:
```
hadoop-3.4.0/sbin/start-yarn.sh
```
Запускаем Historyserver
```
mapred --daemon start historyserver
```

Для работы MapReduce нужно создать map.py и reduce.py в зависимости от файла с данными и целей, с которыми файл обрабатывается.

Выходим из пользователя hadoop  и возвращаемся jn
Правим конфиги nginx для веб интерфейса(для этого скопируем файл для nn и поменяем порты):
```
sudo cp /etc/nginx/sites-available/nn /etc/nginx/sites-available/ya
sudo cp /etc/nginx/sites-available/nn /etc/nginx/sites-available/dh
```
Открываем /etc/nginx/sites-available/ya и /etc/nginx/sites-available/dh при помощи vim и заменяем порт 9870 на 8088 и 19888 соответственно.

Настраиваем
```
sudo ln -s /etc/nginx/sites-available/ya /etc/nginx/sites-enabled/ya
sudo ln -s /etc/nginx/sites-available/dh /etc/nginx/sites-enabled/dh
```

перезапускаем nginx
```
sudo systemctl reload nginx
sudo systemctl status nginx
```
выходим из системы в комадную строку компьютера.
Из командной строки запускаем следующую команду:
```
ssh -L 9870:<название NameNode, в моём случае tmpl-nn>:9870 -L 8088:<название NameNode, в моём случае tmpl-nn>:8088 -L 19888:<название NameNode, в моём случае tmpl-nn>:19888 team@176.109.91.10 
```
team@176.109.91.10 - точка входа

При переходе на localhost:9870 в браузере будет отображаться веб-интерфейс Namenode.

При переходе на localhost:8088 в браузере будет отображаться веб-интерфейс hadoop и yarn.

При переходе на localhost:19888 в браузере будет отображаться веб-интерфейс JobHistory.

