# Фадеева Анна ДЗ6
Подключаемся через putty к удаленному серверу.
Через WinSCP создаем папку team32_fadeeva и переносим файлы gameandgrade.csv, external.sql, managed.sql на сервер.
В одном окне запускаем gpfdist:
```
gpfdist -d /home/user -p 8080 &
```
В другом окне выполняем скрипты в БД idp (в первом скрипте создаем external table, во втором копируем ее в другую):
```
psql -d idp -a -f team32_fadeeva/external.sql
psql -d idp -a -f team32_fadeeva/managed.sql
```
Далее подключаемся в БД

```
psql -d idp
```
Можем выполнить несколько запросов для проверки:
```
SELECT * FROM gameandgrade_external
LIMIT 5;
SELECT * FROM gameandgrade_managed
LIMIT 5;
SELECT AVG(Grade) FROM gameandgrade_external;
```
