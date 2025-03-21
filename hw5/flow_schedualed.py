from prefect import flow, task
from pyspark.sql import SparkSession, DataFrame
from pyspark.sql import functions as F
from pyspark.sql.types import IntegerType, StringType, DoubleType


@task(name="Spark Session creating")
def create_spark_session():
    spark = SparkSession.builder \
        .master("yarn") \
        .appName("spark-with-yarn") \
        .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
        .config("spark.hive.metastore.uris", "thrift://tmpl-jn:9083") \
        .enableHiveSupport() \
        .getOrCreate()
    return spark

@task(name="Read csv")
def read_csv(spark: SparkSession) -> DataFrame:
    return spark.read.csv("/test/gameandgrade.csv", header=True, inferSchema=True)  

@task(name="df transforming ")
def transform_df(df: DataFrame) -> DataFrame:
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
    return df

@task(name="Repartition")
def repartition_df(df: DataFrame) -> DataFrame:
    return df.repartition(11, "School Code")

@task(name="Save parquet to HDFS")
def save_parquet(df: DataFrame):
    df.write.parquet("/test/gameandgrade_parquet")

@task(name="Save table to Hive")
def save_table(df: DataFrame):
    df.write.saveAsTable("gameandgrade_table", partitionBy="School Code", mode="overwrite")

@flow()
def spark_flow():
    spark = create_spark_session()
    raw_df = read_csv(spark)
    transformed_df = transform_df(raw_df)
    repartitioned_df = repartition_df(transformed_df)
    save_parquet(repartitioned_df)
    save_table(repartitioned_df)

if __name__ == "__main__":
    spark_flow()