# Пробуем SQL

### Подключение с помощью psql

`sudo -u postqres psql`

### База данных

* Создать новую базу данных с именем **test**:

`postqres=# CREATE DATABASE test;`

* Переключиться на созданную базу:

`postqres=# \c test`

* Список команд **psql**:

`test=# \?`

### Таблицы

Основные типы данных:
* integer
* test
* boolean
* NULL 

* Создать таблицу с 3 столбцами **c_no, title, hours**:

```
test=# CREATE TABLE courses(
test(# c_no text PRIMARY KEY,
test(# title text,
test(# hours integer
test(# );
```

**PRIMARY KEY** - ограничение, не допустит в поле **c_no** повторяющихся или неопределенных значений.

* Посмотреть синтаксис команды **CREATE TABLE**:

```
test=# \help CREATE TABLE
```

### Наполнение таблиц

* Добавить в таблицу 2 строки:

```
test=# INSERT INTO courses(c_no, title, hours)
test-# VALUES ('CS301', 'Базы данных', 30),
test-# ('CS305', 'Сети ЭВМ', 60);
```

* Создать еще 2 таблицы **students** и **exams**:

```
test=# CREATE TABLE students(
test(# s_id integer PRIMARY KEY,
test(# name text,
test(# start_year integer
test(# );
```

* Внести студентов:

```
test=# INSERT INTO students(s_id, name, start_year)
test-# VALUES (1451, 'Anna', 2014),
test-# (1432, 'Victor', 2014),
test-# (1556, 'Nina', 2015);
```

* Таблица **exams** содержит оценки студентов по дисциплинам

```
test=# CREATE TABLE exams(
test(# s_id integer REFERENCES students(s_id),
test(# c_no text REFERENCES courses(c_no),
test(# score integer,
test(# CONSTRAINT pk PRIMARY KEY(s_id, c_no)
test(# );
```

**CONSTRAINT** - ограничение целостности, относящееся сразу к двум таблицам (запись в таблице **exams** идентифицируется совокупностью номера
студенческого билета **s_id** и номера курса **c_no**);
**REFERENCES** - ссылочной целостности (**внешние ключи**), значения в одной таблице (**exams**) ссылаются на строки в другой таблице (**students**). Т.о. при любых действиях СУБД нельзя будет поставить оценку несуществующему студенту или по несуществующему предмету. 

* Поставить оценки студентам:

```
test=# INSERT INTO exams(s_id, c_no, score)
test-# VALUES (1451, 'CS301', 5),
test-# (1556, 'CS301', 5),
test-# (1451, 'CS305', 5),
test-# (1432, 'CS305', 4);
```


### Выборка данных

* Вывести 2 столбца из таблицы **courses**:

```
test=# SELECT title AS course_title, hours
test-# FROM courses ;
 course_title | hours 
--------------+-------
 Базы данных  |    30
 Сети ЭВМ     |    60
(2 rows)
```


**SELECT** - опрератор для чтения данных из таблицы;
**AS** - переименовывает столбец (**title** -> **course_title**);

* Вывести все столбцы ( \* )

```
test=# SELECT * FROM courses;
 c_no  |    title    | hours 
-------+-------------+-------
 CS301 | Базы данных |    30
 CS305 | Сети ЭВМ    |    60
(2 rows)
```


* Вывести один столбец:

```
test=# SELECT start_year FROM students;
 start_year 
------------
       2014
       2014
       2015
(3 rows)
```

* Вывести все **различные** года поступления:

```
test=# SELECT DISTINCT start_year FROM students;
 start_year 
------------
       2014
       2015
(2 rows)
```


* Без предложения **FROM** запрос вернет одну строку:

```
test=# SELECT 2+2 AS result;
 result 
--------
      4
(1 row)
```

* Вернуть отфильтрованные по условию (**WHERE**) данные:

```
test=# SELECT * FROM courses WHERE hours > 45;
 c_no  |  title   | hours 
-------+----------+-------
 CS305 | Сети ЭВМ |    60
(1 row)
```

**WHERE** может стодержать операторы: **=, <> (!=), >, >=, <, <=**, а также объединять условия с помощью **AND, OR, NOT** и скобок.

### Соединения

* Прямое (декартово) соединение таблиц - к каждой строке одной таблицы добавляется каждая строка другой:

```
test=# SELECT *FROM courses, exams;
 c_no  |    title    | hours | s_id | c_no  | score 
-------+-------------+-------+------+-------+-------
 CS301 | Базы данных |    30 | 1451 | CS301 |     5
 CS305 | Сети ЭВМ    |    60 | 1451 | CS301 |     5
 CS301 | Базы данных |    30 | 1556 | CS301 |     5
 CS305 | Сети ЭВМ    |    60 | 1556 | CS301 |     5
 CS301 | Базы данных |    30 | 1451 | CS305 |     5
 CS305 | Сети ЭВМ    |    60 | 1451 | CS305 |     5
 CS301 | Базы данных |    30 | 1432 | CS305 |     4
 CS305 | Сети ЭВМ    |    60 | 1432 | CS305 |     4
(8 rows)
```


* Исходные таблицы:

```
test=# SELECT *FROM courses;
 c_no  |    title    | hours 
-------+-------------+-------
 CS301 | Базы данных |    30
 CS305 | Сети ЭВМ    |    60
(2 rows)

test=# SELECT *FROM exams;
 s_id | c_no  | score 
------+-------+-------
 1451 | CS301 |     5
 1556 | CS301 |     5
 1451 | CS305 |     5
 1432 | CS305 |     4
(4 rows)

test=# SELECT *FROM students;
 s_id |  name  | start_year 
------+--------+------------
 1451 | Anna   |       2014
 1432 | Victor |       2014
 1556 | Nina   |       2015
(3 rows)
```

* Оценки по всем дисциплинам, сопоставляя курсы с теми экзаменами, которые проводились именно по данному курсу:

```
test=# SELECT courses.title, exams.s_id, exams.score  
test-# FROM courses, exams
test-# WHERE courses.c_no = exams.c_no;
    title    | s_id | score 
-------------+------+-------
 Базы данных | 1451 |     5
 Базы данных | 1556 |     5
 Сети ЭВМ    | 1451 |     5
 Сети ЭВМ    | 1432 |     4
(4 rows)
```

* Запрос с соединениями с помощью **JOIN** (при этом исключаются студенты не сдававшие экзамен):

```
test=# SELECT students.name, exams.score
test-# FROM students 
test-# JOIN exams 
test-# ON students.s_id = exams.s_id
test-# AND exams.c_no = 'CS305';
  name  | score 
--------+-------
 Anna   |     5
 Victor |     4
(2 rows)
```

* Запрос с помощью **JOIN LEFT** (в выдаче есть студенты, не сдававшие экзамен)

```
test=# SELECT students.name, exams.score
test-# FROM students 
test-# LEFT JOIN exams
test-# ON students.s_id = exams.s_id
test-# AND exams.c_no = 'CS305';
  name  | score 
--------+-------
 Anna   |     5
 Victor |     4
 Nina   |      
(3 rows)
```

* Условие **WHERE** применяется к уже соединенным строкам и убирает строку **Nina**:

```
test=# SELECT students.name, exams.score
FROM students 
LEFT JOIN exams
ON students.s_id = exams.s_id
WHERE exams.c_no = 'CS305';
  name  | score 
--------+-------
 Anna   |     5
 Victor |     4
(2 rows)
```
