#Запускается с hadoop nn
#Скачиваем дистрибутив spark
wget -q "https://dlcdn.apache.org/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz"
#Разархивируем
tar -xzf "spark-3.5.3-bin-hadoop3.tgz"
#Скачиваем и разархивируем Hive 4.0.0, в случае, если в прошлый раз была не та версия
#wget https://archive.apache.org/dist/hive/hive-4.0.0-alpha-2/apache-hive-4.0.0-alpha-2-bin.tar.gz
#tar -xzf apache-hive-4.0.0-alpha-2-bin.tar.gz