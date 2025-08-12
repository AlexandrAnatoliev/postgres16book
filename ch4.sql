-- ПРОБУЕМ SQL


--Подключение с помощью psql

-- sudo -u postqres psql


-- БАЗА ДАННЫХ


-- Создать новую базу данных с именем test:

-- postqres=# CREATE DATABASE test;

-- Переключиться на созданную базу:

-- postqres=# \c test

--Список команд **psql**:

-- test=# \?


--- ТАБЛИЦЫ


-- Основные типы данных:
-- integer
-- test
-- boolean
-- NULL 

-- Создать таблицу с 3 столбцами c_no, title, hours:

CREATE TABLE courses(
  c_no text PRIMARY KEY,
  title text,
  hours integer
);


-- PRIMARY KEY - ограничение, не допустит в поле c_no повторяющихся или неопределенных значений.

-- Посмотреть синтаксис команды **CREATE TABLE**:

-- test=# \help CREATE TABLE


-- НАПОЛНЕНИЕ ТАБЛИЦ


-- Добавить в таблицу 2 строки:

INSERT INTO courses(c_no, title, hours)
VALUES ('CS301', 'Базы данных', 30),
       ('CS305', 'Сети ЭВМ', 60);

-- Создать еще 2 таблицы students и exams:

CREATE TABLE students(
  s_id integer PRIMARY KEY,
  name text,
  start_year integer
);

-- Внести студентов:

INSERT INTO students(s_id, name, start_year)
VALUES (1451, 'Anna', 2014),
       (1432, 'Victor', 2014),
       (1556, 'Nina', 2015);

* Таблица **exams** содержит оценки студентов по дисциплинам

CREATE TABLE exams(
  s_id integer REFERENCES students(s_id),
  c_no text REFERENCES courses(c_no),
  score integer,
  CONSTRAINT pk PRIMARY KEY(s_id, c_no)
);

-- CONSTRAINT - ограничение целостности, относящееся сразу к двум таблицам 
-- (запись в таблице exams идентифицируется совокупностью номера студенческого билета **s_id** и номера курса **c_no**);
-- REFERENCES - ссылочной целостности (внешние ключи), 
-- значения в одной таблице (exams) ссылаются на строки в другой таблице (students). 
-- Т.о. при любых действиях СУБД нельзя будет поставить оценку несуществующему студенту или по несуществующему предмету. 

-- Поставить оценки студентам:

INSERT INTO exams(s_id, c_no, score)
VALUES (1451, 'CS301', 5),
       (1556, 'CS301', 5),
       (1451, 'CS305', 5),
       (1432, 'CS305', 4);


-- ВЫБОРКА ДАННЫХ


-- Вывести 2 столбца из таблицы courses:

SELECT title AS course_title, hours
FROM courses ;

-- course_title | hours 
----------------+-------
-- Базы данных  |    30
-- Сети ЭВМ     |    60
--(2 rows)

-- SELECT - опрератор для чтения данных из таблицы;
-- AS - переименовывает столбец (title -> course_title);

-- Вывести все столбцы ( * )

SELECT * FROM courses;

-- c_no  |    title    | hours 
---------+-------------+-------
-- CS301 | Базы данных |    30
-- CS305 | Сети ЭВМ    |    60
--(2 rows)

-- Вывести один столбец:

SELECT start_year FROM students;

-- start_year 
--------------
--       2014
--       2014
--       2015
--(3 rows)

-- Вывести все различные года поступления:

SELECT DISTINCT start_year FROM students;

-- start_year 
--------------
--       2014
--       2015
--(2 rows)


-- Без предложения **FROM** запрос вернет одну строку:

SELECT 2+2 AS result;

-- result 
----------
--      4
--(1 row)

-- Вернуть отфильтрованные по условию (WHERE) данные:

SELECT * FROM courses WHERE hours > 45;

-- c_no  |  title   | hours 
---------+----------+-------
-- CS305 | Сети ЭВМ |    60
--(1 row)

-- WHERE может стодержать операторы: =, <> (!=), >, >=, <, <=, 
-- а также объединять условия с помощью AND, OR, NOT и скобок.


-- СОЕДИНЕНИЯ


-- Прямое (декартово) соединение таблиц - к каждой строке одной таблицы добавляется каждая строка другой:

SELECT *FROM courses, exams;

-- c_no  |    title    | hours | s_id | c_no  | score 
---------+-------------+-------+------+-------+-------
-- CS301 | Базы данных |    30 | 1451 | CS301 |     5
-- CS305 | Сети ЭВМ    |    60 | 1451 | CS301 |     5
-- CS301 | Базы данных |    30 | 1556 | CS301 |     5
-- CS305 | Сети ЭВМ    |    60 | 1556 | CS301 |     5
-- CS301 | Базы данных |    30 | 1451 | CS305 |     5
-- CS305 | Сети ЭВМ    |    60 | 1451 | CS305 |     5
-- CS301 | Базы данных |    30 | 1432 | CS305 |     4
-- CS305 | Сети ЭВМ    |    60 | 1432 | CS305 |     4
--(8 rows)

-- Исходные таблицы:

SELECT *FROM courses;

-- c_no  |    title    | hours 
---------+-------------+-------
-- CS301 | Базы данных |    30
-- CS305 | Сети ЭВМ    |    60
--(2 rows)

SELECT *FROM exams;

-- s_id | c_no  | score 
--------+-------+-------
-- 1451 | CS301 |     5
-- 1556 | CS301 |     5
-- 1451 | CS305 |     5
-- 1432 | CS305 |     4
--(4 rows)

SELECT *FROM students;

-- s_id |  name  | start_year 
--------+--------+------------
-- 1451 | Anna   |       2014
-- 1432 | Victor |       2014
-- 1556 | Nina   |       2015
--(3 rows)

-- Оценки по всем дисциплинам, сопоставляя курсы с теми экзаменами, которые проводились именно по данному курсу:

SELECT courses.title, exams.s_id, exams.score  
FROM courses, exams
WHERE courses.c_no = exams.c_no;

--    title    | s_id | score 
---------------+------+-------
-- Базы данных | 1451 |     5
-- Базы данных | 1556 |     5
-- Сети ЭВМ    | 1451 |     5
-- Сети ЭВМ    | 1432 |     4
--(4 rows)

-- Запрос с соединениями с помощью JOIN (при этом исключаются студенты не сдававшие экзамен):

SELECT students.name, exams.score
FROM students 
JOIN exams 
  ON students.s_id = exams.s_id
  AND exams.c_no = 'CS305';

--  name  | score 
----------+-------
-- Anna   |     5
-- Victor |     4
--(2 rows)

-- Запрос с помощью JOIN LEFT (в выдаче есть студенты, не сдававшие экзамен)

SELECT students.name, exams.score
FROM students 
LEFT JOIN exams
  ON students.s_id = exams.s_id
  AND exams.c_no = 'CS305';

--  name  | score 
----------+-------
-- Anna   |     5
-- Victor |     4
-- Nina   |      
--(3 rows)

-- Условие WHERE применяется к уже соединенным строкам и убирает строку Nina:

SELECT students.name, exams.score
FROM students 
LEFT JOIN exams ON students.s_id = exams.s_id
WHERE exams.c_no = 'CS305';

--  name  | score 
----------+-------
-- Anna   |     5
-- Victor |     4
--(2 rows)


-- ПОДЗАПРОСЫ

-- Использование подзапроса (SELECT ...):

SELECT name,
  (SELECT score
   FROM exams                      
   WHERE exams.s_id = students.s_id
   AND exams.c_no = 'CS305')
FROM students;

--  name  | score 
----------+-------
-- Anna   |     5
-- Victor |     4
-- Nina   |      
--(3 rows)

-- Использование подзапроса в условиях фильтрации:

SELECT * 
FROM exams
WHERE (SELECT start_year
       FROM students
       WHERE students.s_id = exams.s_id) > 2014;

-- s_id | c_no  | score 
--------+-------+-------
-- 1556 | CS301 |     5
--(1 row)

-- Формулируем условия на подзапросы с произвольным количеством строкам
-- выводит данные студентов, сдававших экзамен по предмету CS305
-- IN - проверяет, содержится ли значение в таблице, возвращаемой запросом

SELECT name, start_year
FROM students 
WHERE s_id IN (SELECT s_id
               FROM exams
               WHERE c_no = 'CS305');

--  name  | start_year 
----------+------------
-- Anna   |       2014
-- Victor |       2014
--(2 rows)

-- Подзапрос "кто сдавал экзамен по предмету CS305"

SELECT s_id
FROM exams
WHERE c_no = 'CS305';

-- s_id 
--------
-- 1451
-- 1432
--(2 rows)

-- Исходная таблица с экзаменами

SELECT * FROM exams;

-- s_id | c_no  | score 
--------+-------+-------
-- 1451 | CS301 |     5
-- 1556 | CS301 |     5
-- 1451 | CS305 |     5
-- 1432 | CS305 |     4
--(4 rows)

-- Исходная таблица со студентами

SELECT * FROM students;

-- s_id |  name  | start_year 
--------+--------+------------
-- 1451 | Anna   |       2014
-- 1432 | Victor |       2014
-- 1556 | Nina   |       2015
--(3 rows)

-- Использование оператора NOT IN - вывести список студентов не получивших ни одной 5:

SELECT name, start_year
FROM students
WHERE s_id NOT IN
      (SELECT s_id 
       FROM exams 
       WHERE score = 5);

--  name  | start_year 
----------+------------
-- Victor |       2014
--(1 row)

-- EXIST - проверяет, возвратил ли подзапрос хотя бы одну строку

SELECT name, start_year
FROM students 
WHERE NOT EXISTS 
      (SELECT s_id 
       FROM exams 
       WHERE exams.s_id = students.s_id 
       AND score = 5);

--  name  | start_year 
----------+------------
-- Victor |       2014
--(1 row)

-- Используем алиасы: 
-- students s - псевдоним таблицы
-- ...) ce - псевдоним подзапроса

SELECT s.name, ce.score     -- Используем алиасы
FROM students s
JOIN (SELECT exams.*
      FROM courses, exams
      WHERE courses.c_no = exams.c_no
      AND courses.title = 'Базы данных') ce
  ON s.s_id = ce.s_id;      -- Используем алиасы

-- name | score 
--------+-------
-- Anna |     5
-- Nina |     5
--(2 rows)

-- То же самое без подзапросав

SELECT s.name, e.score
FROM students s, courses c, exams e
WHERE c.c_no = e.c_no
AND c.title = 'Базы данных'
AND s.s_id = e.s_id;

-- name | score 
--------+-------
-- Anna |     5
-- Nina |     5
--(2 rows)


-- СОРТИРОВКА


-- Упорядочить строки (ORDER BY):
-- по возрастанию оценки (score)
-- или по возрастанию студенческого билета (s_id)
-- если первые два ключа совпадают - по убыванию номера курса (c_no DESC)
-- направление сортировки:
-- по умолчанию - "по возрастанию" (ASC) 
-- "по убыванию" (DESC)

SELECT *
FROM exams 
ORDER BY score, s_id, c_no DESC;

-- s_id | c_no  | score 
--------+-------+-------
-- 1432 | CS305 |     4
-- 1451 | CS305 |     5
-- 1451 | CS301 |     5
-- 1556 | CS301 |     5
--(4 rows)


-- ГРУППИРОВКА


-- Вывести количество проведенных экзаменов, количество сдавших студентов и средний балл

SELECT count(*), count(DISTINCT s_id),
avg(score)
FROM exams;

-- count | count |        avg         
---------+-------+--------------------
--     4 |     3 | 4.7500000000000000
--(1 row)

-- То же самое, разбив по номерам курсов с помощью GROUP BY

SELECT c_no, count(*),
count(DISTINCT s_id), avg(score)
FROM exams 
GROUP BY c_no;

-- c_no  | count | count |        avg         
---------+-------+-------+--------------------
-- CS301 |     2 |     2 | 5.0000000000000000
-- CS305 |     2 |     2 | 4.5000000000000000
--(2 rows)

-- Вывести имена студентов, получивших более 1 пятерки по предмету
-- HAVING - работает так же как WHERE, но фильтровка осуществляется после группировки 
-- и можно использовать столбцы с вычисленными результатами, а не исходнве таблицы

SELECT students.name
FROM students, exams
WHERE students.s_id = exams.s_id AND exams.score = 5
GROUP BY students.name
HAVING count(*) > 1;

-- name 
--------
-- Anna
--(1 row)


-- ИЗМЕНЕНИЕ И УДАЛЕНИЕ ДАННЫХ


-- С помощью UPDATE увеличим количество часов для курса 'Базы данных'

UPDATE courses 
SET hours = hours * 2
WHERE c_no = 'CS301';

-- С помощью DELETE удалим из таблицы строку:

DELETE FROM exams WHERE score < 5;


-- ТРАНЗАКЦИИ


-- Усложним схему данных:
-- распределим студентов по группам 
-- у каждой группы должен быть староста

-- Создание таблицы групп:
-- NOT NULL - запрещает неопределенные значения

CREATE TABLE groups(
  g_no text PRIMARY KEY,
  monitor integer NOT NULL REFERENCES students(s_id)
);

-- Таблица students - исходный вид

-- test=# \d students
--                Table "public.students"
--   Column   |  Type   | Collation | Nullable | Default 
--------------+---------+-----------+----------+---------
-- s_id       | integer |           | not null | 
-- name       | text    |           |          | 
-- start_year | integer |           |          | 

-- Добавить новый столбец (номер группы) в таблицу

ALTER TABLE students 
ADD g_no text REFERENCES groups(g_no);

-- добавил столбец

--test=# \d students
--                Table "public.students"
--   Column   |  Type   | Collation | Nullable | Default 
--------------+---------+-----------+----------+---------
-- s_id       | integer |           | not null | 
-- name       | text    |           |          | 
-- start_year | integer |           |          | 
-- g_no       | text    |           |          | 

-- список таблиц в базе данных

-- test=# \d 
--          List of relations
-- Schema |   Name   | Type  |  Owner   
----------+----------+-------+----------
-- public | courses  | table | postgres
-- public | exams    | table | postgres
-- public | groups   | table | postgres
-- public | students | table | postgres

-- Создать группу A-101
-- поместим в нее всех студентов
-- старостой назначив Anna

BEGIN;
-- BEGIN
INSERT INTO groups(g_no, monitor)
SELECT 'A-101', s_id
FROM students 
WHERE name = 'Anna';

-- BEGIN - начало транзакции:
-- т.е. нескольких операций, которые можно сделать только одновременно

-- добавим студентов в группу
UPDATE students SET g_no = 'A-101';

-- Закончим транзакцию и зафиксируем сделанные изменения

COMMIT;
-- COMMIT

-- Посмотреть содержимое таблиц

SELECT * FROM groups;

-- g_no  | monitor 
---------+---------
-- A-101 |    1451
--(1 row)

SELECT * FROM students;

-- s_id |  name  | start_year | g_no  
--------+--------+------------+-------
-- 1451 | Anna   |       2014 | A-101
-- 1432 | Victor |       2014 | A-101
-- 1556 | Nina   |       2015 | A-101
--(3 rows)


-- ПОЛЕЗНЫЕ КОМАНДЫ PSQL


-- \? - справка по командам psql
-- \h - справка по sql (доступные команды и синтаксис конкретной команды)
-- \x - переключение с табличного вывода на расширенный
-- \l - список баз данных
-- \du - список пользователей
-- \dt - список таблиц
-- \di - список индексов
-- \dv - список представлений
-- \df - список функций
-- \dn - список схем
-- \dx - список установленных расширений
-- \dp - список привилегий
-- \d имя - подробная информация по конкретному объекту базы данных
-- \d+ имя - еще более подробная информация 
-- \timing on - вывод времени выполнения операторов
