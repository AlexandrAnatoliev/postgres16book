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
-- (2 rows)

-- SELECT - опрератор для чтения данных из таблицы;
-- AS - переименовывает столбец (title -> course_title);

-- Вывести все столбцы ( * )

SELECT * FROM courses;

-- c_no  |    title    | hours 
---------+-------------+-------
-- CS301 | Базы данных |    30
-- CS305 | Сети ЭВМ    |    60
-- (2 rows)

-- Вывести один столбец:

SELECT start_year FROM students;

-- start_year 
--------------
--       2014
--       2014
--       2015
-- (3 rows)

-- Вывести все различные года поступления:

SELECT DISTINCT start_year FROM students;

-- start_year 
--------------
--       2014
--       2015
-- (2 rows)


-- Без предложения **FROM** запрос вернет одну строку:

SELECT 2+2 AS result;

-- result 
----------
--      4
-- (1 row)

-- Вернуть отфильтрованные по условию (WHERE) данные:

SELECT * FROM courses WHERE hours > 45;

-- c_no  |  title   | hours 
---------+----------+-------
-- CS305 | Сети ЭВМ |    60
-- (1 row)

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
-- (8 rows)

-- Исходные таблицы:

SELECT *FROM courses;

-- c_no  |    title    | hours 
---------+-------------+-------
-- CS301 | Базы данных |    30
-- CS305 | Сети ЭВМ    |    60
-- (2 rows)

SELECT *FROM exams;

-- s_id | c_no  | score 
--------+-------+-------
-- 1451 | CS301 |     5
-- 1556 | CS301 |     5
-- 1451 | CS305 |     5
-- 1432 | CS305 |     4
-- (4 rows)

SELECT *FROM students;

-- s_id |  name  | start_year 
--------+--------+------------
-- 1451 | Anna   |       2014
-- 1432 | Victor |       2014
-- 1556 | Nina   |       2015
-- (3 rows)

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
-- (4 rows)

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
-- (2 rows)

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
-- (3 rows)

-- Условие WHERE применяется к уже соединенным строкам и убирает строку Nina:

SELECT students.name, exams.score
FROM students 
LEFT JOIN exams ON students.s_id = exams.s_id
WHERE exams.c_no = 'CS305';

--  name  | score 
----------+-------
-- Anna   |     5
-- Victor |     4
-- (2 rows)


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
-- (3 rows)


