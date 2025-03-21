
Данная настойка выполняется после успешного выполнения предудущих(в том числе уже присутствуем фийл gameandgrade.csv)

Копируем файлы на сервер (Из папки куда они скачаны):

```
scp flow1.py team@176.109.91.10:
scp flow_schedualed.py team@176.109.91.10:
```
Вместо team@176.109.91.10 указываем USER@PORT

Заходим на Jump Node
```
ssh USER@PORT
```
В моём случае это team@176.109.91.10

и вводим пароль.
Копируем файлы в пользователя hadoop
```
sudo cp /home/USER/flow1.py /home/hadoop/flow1.py
sudo cp /home/USER/flow_schedualed.py /home/hadoop/flow_schedualed.py
```
Заходим в пользователя hadoop
```
sudo -i -u hadoop
```

Активируем окружение и уcтанавливаем prefect
```
source .venv/bin/activate
pip install prefect
```
Запускаем файл
```
python3 flow1.py
```

Далее сделаем выполнение по расписанию.
Устанавливаем путь:
```
export PREFECT_URL="http://tmpl-nn:port/api"
```
Запуск prefect
```
prefect server start --host tmpl-nn --port port -b
```
Настраиваем выполнение
```
prefect flow serve flow_scheduled:spark_flow --cron "0 0 * * *" --name "daily" --no-pause-on-shutdown
```
