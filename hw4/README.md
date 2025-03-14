Данная настойка выполняется после успешного выполнения предудущих

Копируем файлы со скриптами на сервер (Из папки куда они скачаны):

```
scp spark_dowload_jn.sh team@176.109.91.10:
scp pyspark.sh team@176.109.91.10:
```

Заходим на Jump Node 
```
ssh USER@PORT
```
В моём случае это team@176.109.91.10

и вводим пароль.

Перекидываем скрипты на nn
```
scp postgres.sh tmpl-nn:
scp pyspark.sh tmpl-nn:
```
Заходим в пользователя hadoop и переключаемся на nn:
```
sudo -i -u hadoop
ssh tmpl-nn
```
Нужно перекинуть файл:

Перекидваем скрипт в пользователя hadoop и запускаем скрипт:
```
sudo cp /home/USER/spark_dowload_jn.sh /home/hadoop/spark_dowload_jn.sh
sh spark_dowload_jn.sh
```

Открываем конфиг:
```
vim ~/.profile
```
Добавляем в конфиг переменные окружения:
```
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export SPARK_HOME=/home/hadoop1/spark-3.5.3-bin-hadoop3
export PATH=$PATH:$SPARK_HOME/bin
```
Ативируем:
```
source ~/.profile
```

Данные уже скачаны и положены в файлоую систему в ДЗ3.


В другом окне запускаем
```
 hive
 --hiveconf hive.server2.enable.doAs=false
 --hiveconf hive.security.authorization.enabled=false
 --service metastore
 1>> /tmp/metastore.log
 2>> /tmp/metastore.log
```
Запускаем metastore:
```
hive --service metastore -p 5433 & 
```

Переходим на nn в пользователя team
```
exit
```
Запускаем скрипт:
```
sh pyspark.sh
```
переходим в пользователя hadoop
```
sudo -i -u hadoop
```
Запустим
```
jupyter notebook --no-browser --port=9999 --ip=0.0.0.0
```

В другом терминале на локальном устройстве
```
ssh -L 9999:127.0.0.1:9999 team@176.109.91.10 -t ssh -L 9999:127.0.0.1:9999 192.168.1.131
```
далее в браузере открываем Jupyter notebook:
```
http://localhost:9999/tree?token=<сгенерированный токен>
```
в  Jupyter создаём файл .ipynb туда запишем и запустим:
```
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import IntegerType, StringType, DoubleType
from onetl.file import FileDFReader
from onetl.connection import SparkHDFS
from onetl.file.format import CSV


spark = SparkSession.builder \
    .master("yarn") \
    .appName("spark-with-yarn") \
    .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
    .config("spark.hadoop.hive.metastore.uris", "thrift://192.168.1.131:9083") \
    .enableHiveSupport() \
    .getOrCreate()

hdfs = SparkHDFS(host="192.168.1.99", port=9000, spark=spark, cluster="test")
#Проверка соедирения
print(hdfs.check())

reader = FileDFReader(connection=hdfs, format=CSV(delimiter=",", header=True), source_path="/test")
df = reader.run(["gameandgrade.csv"])
df.printSchema()
print(f"Число партиций: {df.rdd.getNumPartitions()}")

#Все значеня в датасете заполены

df = df.withColumn("Sex", df["Sex"].cast(BooleanType()))
df = df.withColumn("School Code", df["School Code"].cast(IntegerType()))
df = df.withColumn("Playing Years", df["Playing Years"].cast(IntegerType()))
df = df.withColumn("Playing Often", df["Playing Often"].cast(IntegerType()))
df = df.withColumn("Playing Hours", df["Playing Hours"].cast(IntegerType()))
df = df.withColumn("Playing Games", df["Playing Games"].cast(IntegerType()))
df = df.withColumn("Parent Revenue", df["Parent Revenue"].cast(IntegerType()))
df = df.withColumn("Father Education", df["Father Education"].cast(IntegerType()))
df = df.withColumn("Mother Education", df["Mother Education"].cast(IntegerType()))
df = df.withColumn("Grade", df["Grade"].cast(DoubleType())) 


df = df.withColumn("Grade_classes", 
                   F.when(df["Grade"] < 50, "Low")
                    .when((df["Grade"] >= 50) & (df["Grade"] < 80), "Medium")
                    .otherwise("High"))

df = df.repartition(11, "School Code")
print(f"Число партиций: {df.rdd.getNumPartitions()}")

df.write.parquet("/test/parquet")
df.write.saveAsTable("table", partitionBy="Pclass")

spark.stop()
```
