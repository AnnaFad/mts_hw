#Скачать postgres
sudo apt install postgresql
sudo -i -u postgres

psql

CREATE DATABASE metastore;
CREATE USER hive WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE "metastore" TO hive;
ALTER DATABASE metastore OWNER TO hive;


