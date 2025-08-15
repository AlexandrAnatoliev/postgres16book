-- POSTGRESQL ДЛЯ ПРИЛОЖЕНИЙ


-- ОТДЕЛЬНЫЙ ПОЛЬЗОВАТЕЛЬ


--Подключение с помощью psql

-- sudo -u postqres psql

-- создать нового пользователя 

CREATE USER app PASSWORD 'p@ssw0rd'; 

-- сделать его владельцем отдельной базы данных

CREATE DATABASE appdb OWNER app;

-- подключиться

-- \c appdb app localhost 5432

-- создать таблицу

CREATE TABLE greeting(s text);
INSERT INTO greeting VALUES ('Привет, мир!');


-- ПРОВЕРКА СВЯЗИ

-- Установить java и jdbc

-- sudo apt install libpostgresql-jdbc-java

-- Пример тестовой программы ch6/Test.java
-- Компилируем ее и запускаем

-- javac Test.java 
-- java -cp .:/usr/share/java/postgresql-jdbc4.jar Test 
-- Привет, мир!


-- РЕЗЕРВНОЕ КОПИРОВАНИЕ 

-- сделать резервную копию базы
-- pg_dump appdb > appdb.dump

-- если не работает, то:
-- pg_dump -U app -h localhost -d appdb -f appdb.dump

-- либо заходим через sudo в пользователя postgres
-- sudo -u postgres pg_dump appdb > appdb.dump 

-- создать новую базу данных
-- createdb appdb2

-- Если не работает
-- sudo -u postgres createdb appdb2

-- Восстановить содержимое базы данных в новую базу
-- psql -d appdb2 -f appdb.dump

-- если не работает
-- psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  role "alexandr" does not exist
-- sudo -u postgres psql -d appdb2 -f appdb.dump
