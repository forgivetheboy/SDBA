"""Spark → Iceberg → PostgreSQL (Gold)

Run with:
  /opt/spark/bin/spark-submit \
    --packages org.postgresql:postgresql:42.7.1 \
    spark/04_spark_transform.py
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, to_date

spark = (
    SparkSession.builder
    .appName("iceberg_to_postgres")
    .config("spark.sql.catalog.local", "org.apache.iceberg.spark.SparkCatalog")
    .config("spark.sql.catalog.local.type", "hadoop")
    .config("spark.sql.catalog.local.warehouse", "hdfs://namenode:8020/warehouse/iceberg")
    .getOrCreate()
)

# Read Iceberg (Silver)
orders = spark.table("local.silver_orders")

# Transform (Gold)
gold = (
    orders
    .filter(col("amount") > 0)
    .withColumn("order_date", to_date(col("order_ts")))
)

# Write to PostgreSQL Staging
(
    gold.write
    .format("jdbc")
    .option("url", "jdbc:postgresql://postgres-staging:5432/staging")
    .option("dbtable", "public.gold_orders")
    .option("user", "staging_user")
    .option("password", "StrongPassword")
    .option("driver", "org.postgresql.Driver")
    .mode("append")
    .save()
)

spark.stop()
