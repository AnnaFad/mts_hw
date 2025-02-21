# mts_hw1
 Фадеева Анна Александровна

Заходим в профиль:
```
ssh team@176.109.91.10
(вводим пароль от профиля)
```
Устанавливаем tmux(в данной среде уже установлен)
```
sudo apt install tmux
```
Открываем новое окно
```
tmux
```
Устанавливаем автоматическую авторизацию
```
ssh-keygen
cat .ssh/id_ed25519.pub >> .ssh/authorized_keys
scp .ssh/authorized_keys 192.168.1.131:/home/team/.ssh/
(вводим пароль от профиля)
scp .ssh/authorized_keys 192.168.1.132:/home/team/.ssh/
(вводим пароль от профиля)
scp .ssh/authorized_keys 192.168.1.133:/home/team/.ssh/
(вводим пароль от профиля)
```
Меняем порты на jn
```
sudo vim /etc/hosts
```
Редактируем содержание открывшегося файла на такое и сохраняем:
```
127.0.0.1 tmpl-jn

#192.168.1.130 tmpl-jn
192.168.1.131 tmpl-nn
192.168.1.132 tmpl-dn-00
192.168.1.133 tmpl-dn-01
```
Проверим подключение к nn
```
ping tmpl-nn
```
Все работает.
Добавим пользователя hadoop:
```
sudo adduser hadoop
```
Перейдём на nn
```
ssh 192.168.1.131
```
Меняем порты на nn
```
sudo vim /etc/hosts
```
Редактируем содержание открывшегося файла на такое и сохраняем:
```
192.168.1.130 tmpl-jn
192.168.1.131 tmpl-nn
192.168.1.132 tmpl-dn-00
192.168.1.133 tmpl-dn-01
```
Добавим пользователя hadoop:
```
sudo adduser hadoop
```
Выйдем из nn:
```
exit
```
Перейдём на dn-00
```
ssh 192.168.1.132
```
Меняем порты на dn-00
```
sudo vim /etc/hosts
```
Редактируем содержание открывшегося файла на такое и сохраняем:
```
127.0.0.1 tmpl-dn-00

192.168.1.130 tmpl-jn
192.168.1.131 tmpl-nn
#192.168.1.132 tmpl-dn-00
192.168.1.133 tmpl-dn-01
```
Добавим пользователя hadoop:
```
sudo adduser hadoop
```
Выйдем из dn-00:
```
exit
```
Перейдём на dn-01
```
ssh 192.168.1.133
```
Меняем порты на dn-01
```
sudo vim /etc/hosts
```
Редактируем содержание открывшегося файла на такое и сохраняем:
```
127.0.0.1 tmpl-dn-01

192.168.1.130 tmpl-jn
192.168.1.131 tmpl-nn
192.168.1.132 tmpl-dn-00
#192.168.1.133 tmpl-dn-01
```
Добавим пользователя hadoop:
```
sudo adduser hadoop
```
Выйдем из dn-01:
```
exit
```
Возвращаемся в предыдущее окно tmux
Меняем пользователя на hadoop:
```
sudo -i -u hadoop
```
Открываем новое окно
```
tmux
```
Скачиваем hadoop
```
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
```
Переходим в предыдущее окно tmux
Настраиваем автоматическую авторизацию:
```
ssh-keygen
cat .ssh/id_ed25519.pub >> .ssh/authorized_keys
cat .ssh/authorized_keys

scp -r .ssh/ tmpl-nn:/home/hadoop
scp -r .ssh/ tmpl-dn-00:/home/hadoop
scp -r .ssh/ tmpl-dn-01:/home/hadoop
```
Вернулись к окну со скачкой:
```
tmux attach -t 0 
```
Скачанный архив копируем на все ноды:
```
scp hadoop-3.4.0.tar.gz tmpl-nn:/home/hadoop
scp hadoop-3.4.0.tar.gz tmpl-dn-00:/home/hadoop
scp hadoop-3.4.0.tar.gz tmpl-dn-01:/home/hadoop
```
Разворачиваем архив на каждой ноде:
```
tar -xzvf hadoop-3.4.0.tar.gz
ssh tmpl-nn
tar -xzvf hadoop-3.4.0.tar.gz
ssh tmpl-dn-00
tar -xzvf hadoop-3.4.0.tar.gz
ssh tmpl-dn-01
tar -xzvf hadoop-3.4.0.tar.gz
```
При помощи exit возвращаемся обратно на jn.


Проверим версию java:
```
java -version
```
Установлена java 11-й версии, всё хорошо.

Смотрим путь к java
```
which java # (покажет путь к файлу: /usr/bin/java)
readlink -f /usr/bin/java
```
Получим положение файла: /usr/lib/jvm/java-11-openjdk-amd64/bin/java

Изменяем файл .profile
```
vim .profile
```
Допишем в конец файла 3 строчки:
```
export HADOOP_HOME=/home/hadoop/hadoop-3.4.0
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```
Активируем .profile
```
source .profile
```
Копируем .profile на остальные ноды:
```
scp .profile tmpl-dn-01:/home/hadoop
scp .profile tmpl-dn-00:/home/hadoop
scp .profile tmpl-nn:/home/hadoop
```
Проверим, что работает hadoop на ноде:
```
hadoop version
```
Проверим, что работает на nn:
```
ssh tmpl-nn
hadoop version
exit
```
Подправим конфиги.
hadoop-env.sh
```
vim hadoop-env.sh
```
Добавить в файл путь к java:
```
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```
core-site.xml
```
vim core-site.xml
```
Добавим в файл конфиг:
```
<configuration>
        <property>
                <name>fs.defaultFS</name>
                <value>hdfs://tmpl-nn:9000</value>
        </property>
</configuration>
```
hdfs-site.xml
```
vim hdfs-site.xml
```
Добавим в файл конфиг:
```
<configuration>
        <property>
                <name>dfs.replication</name>
                <value>3</value>
        </property>
</configuration>
```
workers - список демонов
```
vim workers
```
Поменять содержимое файла на такое:
```
tmpl-nn
tmpl-dn-00
tmpl-dn-01
```
Копируем все изменённые файлы на все ноды:
```
scp hadoop-env.sh tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp hadoop-env.sh tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp hadoop-env.sh tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop

scp core-site.xml tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp core-site.xml tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp core-site.xml tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop

scp hdfs-site.xml tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp hdfs-site.xml tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp hdfs-site.xml tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop

scp workers tmpl-nn:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp workers tmpl-dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp workers tmpl-dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
```
Вернуться в пользователя team из hadoop при помощи exit
Меняем hostname на ноде:
```
sudo vim /etc/hostname
```
Поменять содержимое файла на 
```
tmpl-jn
```
Аналогичные действия проводим для каждой ноды:
```
ssh tmpl-nn
sudo vim /etc/hostname
ssh tmpl-dn-00
sudo vim /etc/hostname
ssh tmpl-dn-01
sudo vim /etc/hostname
exit
exit
exit
```
файлы меняем соответственно на tmpl-nn, tmpl-dn-00, tmpl-dn-01.
Вернёмся в пользователя hadoop и пойдем в nn:
```
sudo -i -u hadoop
ssh tmpl-nn
```
Форматируем файловую систему
```
cd hadoop-3.4.0/
bin/hdfs namenode -format 
```
Запускаем hadoop
```
sbin/start-dfs.sh 
```
При помощи jps смотрим логи на ноде:
```
jps 
```
Вывелось
```
48692 Jps
48185 NameNode
48569 SecondaryNameNode
48362 DataNode
```
Аналогично на dn-00 выводится:
```
47755 Jps
47613 DataNode
```
Аналогично на dn-01 выводится:
```
47904 Jps
47765 DataNode
```
Для проверки работоствобности смотрим логи:
На dn-01:
```
tail hadoop-3.4.0/logs/hadoop-hadoop-datanode-team-32-dn-01.log
```
На dn-00:
```
tail hadoop-3.4.0/logs/hadoop-hadoop-datanode-team-32-dn-00.log 
```
На nn:
```
tail  hadoop-3.4.0/logs/hadoop-hadoop-namenode-team-32-nn.log
tail  hadoop-3.4.0/logs/hadoop-hadoop-datanode-team-32-nn.log
```
