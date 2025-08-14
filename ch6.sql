-- POSTGRESQL ДЛЯ ПРИЛОЖЕНИЙ


-- ОТДЕЛЬНЫЙ ПОЛЬЗОВАТЕЛЬ


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
