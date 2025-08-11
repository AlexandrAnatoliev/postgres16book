# Как установить PostgreSQL на Linux

### Установка

* Подключение пакетного репозитория PGDG:

`sudo apt install lsb-release`

* Установка:

`sudo apt install postgresql`

* Проверка версии PostgreSQL:

`sudo -u postgres psql -c 'select  version()'`

### Управление службой и основные файлы

* Остановка службы сервера баз данных:

`sudo systemctl stop postgresql`

* Запуск:

`sudo systemctl start postgresql`

* Проверка текущего состояния:

`sudo systemctl status postgresql`

* Файл с логами:

`/var/log/postgresql/postgresql-16-main.log`

* Информация, содержащаяся в базе данных располагается:

`/var/lib/postgresql/16/main/`

* Основной конфигурационный файл:

`/etc/postgresql/16/main/postgresql.conf`

* Файл с настнойками доступа:

`/etc/postgresql/16/main/pg_hba.conf`
