#Фадеева Анна 
На момент выполнения уже выполнены дз1 и дз2

Копируем файлы со скриптами на сервер
```
scp install_hive.sh team@176.109.91.10:
scp postgres.sh team@176.109.91.10:
scp set_hive.sh team@176.109.91.10:
```
Вместо team@176.109.91.10 USER@PORT
1. Заходим на jn
   ```
   ssh USER@PORT
   ```
   Вводим пароль
2. Копируем файл со скриптом на nn
   ```
   scp postgres.sh tmpl-nn:
   ```
3. Заходим на nn и выполняем там файл
   ```
   ssh tmpl-nn
   sh postgres.sh
   ```

4. Выходим из терминала на jn
   ```
   exit
   exit
   ```

5.Исправляем конфиги
```
sudo vim /etc/postgresql/16/main/postgresql.conf
```

Указываем в конфиге (tmpl-nn заменить на название namenode):
```
listen_addresses = 'tmpl-nn'
```
Открываем следующий кофиг
```
sudo vim /etc/postgresql/16/main/pg_hba.conf
```
Добавить строку 
```
host    metastore       hive            <ip_jumpnode>/32         password
```
и удалить
```
host    all             all             127.0.0.1/32            scram-sha-256
```
6. перезапускаем постгрес
```
sudo systemctl restart postgresql
sudo systemctl status postgresql
```
7. Переходим на jn, Скачиваеваем пользователя, проверяем возможность подключения к таблице
```
exit
sudo apt install postgresql-client-16
psql -h tmpl-nn -p 5432 -U hive -W -d metastore
```

# Установка hive
Перекидываем скрипты на пользователя hadoop
```
sudo cp /home/USER/install_hive.sh /home/hadoop/install_hive.sh
sudo cp /home/USER/set_hive.sh /home/hadoop/set_hive.sh
```
Заходим в пользователя hadoop на jn
```
sudo -i -u hadoop
```
Запускаем скрипт:
```
sh install_hive.sh
```
Редактируем конфиги:
```
cd apache-hive-4.0.1-bin/
cd lib
vim hive-site.xml
```
Вставляем:
<configuration>
   <property>
       <name>hive.server2.authentication</name>
       <value>NONE</value>
   </property>
   <property>
       <name>hive.metastore.warehouse.dir</name>
       <value>/user/hive/warehouse</value>
   </property>
   <property>
       <name>hive.server2.thrift.port</name>
       <value>5433</value>
   </property>
   <property>
       <name>javax.jdo.option.ConnectionURL</name>
       <value>jdbc:postgresql://tmpl-nn:5432/metastore</value>
   </property>
   <property>
       <name>javax.jdo.option.ConnectionDriverName</name>
       <value>org.postgresql.Driver</value>
   </property>
   <property>
       <name>javax.jdo.option.ConnectionUserName</name>
       <value>hive</value>
   </property>
   <property>
       <name>javax.jdo.option.ConnectionPassword</name>
       <value><postgre password></value>
   </property>
</configuration>
```
```
vim ~/.profile
```
Добавить пути:
```
export HIVE_HOME=/home/hadoop/apache-hive-4.0.1-bin
export HIVE_CONF_DIR=$HIVE_HOME/conf
export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*
export PATH=$PATH:$HIVE_HOME/bin
```

```
source ~/.profile
hive --version
```
```
cp /home/hadoop/set_hive.sh /home/hadoop/apache-hive-4.0.1-bin/lib/set_hive.sh
sh set_hive.sh
```

Подключаемся через beeline:
```
beeline -u jdbc:hive2://tmpl-jn:5433 -n scott -p tiger
```
выходим обратно  и подкачиваем данные и unzip:
```
exit                             
sudo apt install unzip           
sudo -i -u hadoop
wget  https://www.kaggle.com/api/v1/datasets/download/deadier/play-games-and-success-in-students
unzip play-games-and-success-in-students
```

```
hdfs dfs -chmod g+w /test
hdfs dfs -put gameandgrade.csv /test
```
Подключаемся cнова через beeline:
```
beeline -u jdbc:hive2://tmpl-jn:5433 -n scott -p tiger
```
```
SHOW DATABASES;
CREATE DATABASE test;

use test;
Создать таблицу по формату данных и подгузить туда данные из файла
CREATE TABLE IF NOT EXISTS test.dataset_unpartitioned (
    Sex BOOLEAN,
    School_code INT,
    Playing_years INT,
    Playing_often INT,
    Playing_hours INT,
    Playing_games INT,
    Parent_revenue INT,
    Father_education INT,
    Mother_education INT,
    Grade DOUBLE)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
    TBLPROPERTIES ('skip.header.line.count'='1');
LOAD DATA INPATH 'gameandgrade.csv' INTO TABLE test.dataset_unpartitioned;

SET hive.exec.dynamic.partition=true;

CREATE TABLE IF NOT EXISTS test.dataset_partitioned (
    Sex BOOLEAN,
    Playing_years INT,
    Playing_often INT,
    Playing_hours INT,
    Playing_games INT,
    Parent_revenue INT,
    Father_education INT,
    Mother_education INT,
    Grade DOUBLE)
    PARTITIONED BY (School_code INT)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

INSERT INTO TABLE test.dataset_partitioned PARTITION (School_code)
SELECT Sex,
    School_code,
    Playing_years,
    Playing_often,
    Playing_hours,
    Playing_games,
    Parent_revenue,
    Father_education,
    Mother_education,
    Grade
FROM test.dataset_unpartitioned;
```
