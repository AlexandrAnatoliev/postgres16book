-- ДЕМОНСТРАЦИОННАЯ БАЗА ДАННЫХ


-- УСТАНОВКА С САЙТА


-- Переключаемся на пользователя postgres

-- sudo su - postgres

-- Скачиваем базу данных

-- wget https://edu.postgrespro.ru/demo-small.zip
-- zcat demo-small.zip | psql


-- ПРИМЕРЫ ЗАПРОСОВ

-- Запускаю psql

-- sudo -u postgres psql

-- Подключаюсь к демонстрационной базе

-- postgres=# \c demo 
-- You are now connected to database "demo" as user "postgres".
-- demo=# 

-- Таблица с самолетами

SELECT * FROM aircrafts;

-- aircraft_code |        model        | range 
-----------------+---------------------+-------
-- 773           | Боинг 777-300       | 11100
-- 763           | Боинг 767-300       |  7900
-- SU9           | Сухой Суперджет-100 |  3000
-- 320           | Аэробус A320-200    |  5700
-- 321           | Аэробус A321-200    |  5600
-- 319           | Аэробус A319-100    |  6700
-- 733           | Боинг 737-300       |  4200
-- CN1           | Сессна 208 Караван  |  1200
-- CR2           | Бомбардье CRJ-200   |  2700
--(9 rows)

-- Версия демонстрационной базы данных

SELECT bookings.now();

--          now           
--------------------------
-- 2017-08-15 18:00:00+03
--(1 row)

-- Названия моделей самолетов и городов выводятся по-русски

SELECT airport_code, city
FROM airports LIMIT 5;

-- airport_code |           city           
----------------+--------------------------
-- YKS          | Якутск
-- MJZ          | Мирный
-- KHV          | Хабаровск
-- PKC          | Петропавловск-Камчатский
-- UUS          | Южно-Сахалинск
--(5 rows)

-- Меняем язык на уровне базы данных

ALTER DATABASE demo SET bookings.lang = en;

-- Подключаемся к базе данных заново

-- demo=# \c
-- You are now connected to database "demo" as user "postgres".

-- Названия моделей самолетов и городов выводятся по-английски

SELECT airport_code, city
FROM airports LIMIT 5;

-- airport_code |       city        
----------------+-------------------
-- YKS          | Yakutsk
-- MJZ          | Mirnyj
-- KHV          | Khabarovsk
-- PKC          | Petropavlovsk
-- UUS          | Yuzhno-Sakhalinsk
--(5 rows)


-- ПРОСТЫЕ ЗАПРОСЫ


-- ЗАДАЧА: Кто летел позавчера рейсом Москва (SVO) - Новосибирск (OVB) на месте 1A и когда он забронировал себе билет?

SELECT  t.passenger_name,
        b.book_date
FROM    bookings b
        JOIN tickets t
          ON t.book_ref = b.book_ref
        JOIN boarding_passes bp
          ON bp.ticket_no = t.ticket_no
        JOIN flights f
          ON f.flight_id = bp.flight_id
WHERE   f.departure_airport = 'SVO'
AND     f.arrival_airport = 'OVB'
AND     f.scheduled_departure::date = bookings.now() - INTERVAL '2 day'
AND     bp.seat_no = '1A';

-- passenger_name | book_date 
------------------+-----------
--(0 rows)

-- Все пассажиры этого рейса, сидевшие на этом месте

SELECT  t.passenger_name,
        b.book_date
FROM    bookings b
        JOIN tickets t
          ON t.book_ref = b.book_ref
        JOIN boarding_passes bp
          ON bp.ticket_no = t.ticket_no
        JOIN flights f
          ON f.flight_id = bp.flight_id
WHERE   f.departure_airport = 'SVO'
AND     f.arrival_airport = 'OVB'
AND     bp.seat_no = '1A';

-- FLYURA ORLOVA       | 2017-07-31 09:31:00+03
-- VALENTINA KOROLEVA  | 2017-07-10 16:17:00+03
-- ELIZAVETA SEMENOVA  | 2017-07-17 21:41:00+03
-- SVETLANA KUZNECOVA  | 2017-07-19 18:14:00+03
-- YURIY VOROBEV       | 2017-07-04 00:40:00+03
-- SERGEY TARASOV      | 2017-07-09 11:24:00+03
-- NINA NAZAROVA       | 2017-07-26 19:41:00+03
-- SERGEY SCHERBAKOV   | 2017-07-28 20:39:00+03
-- EVGENIY SAVELEV     | 2017-07-09 06:28:00+03
-- IVAN BORISOV        | 2017-07-12 18:57:00+03
-- VARVARA ARKHIPOVA   | 2017-07-10 19:56:00+03
-- NIKOLAY MIRONOV     | 2017-07-19 20:45:00+03
-- ANASTASIYA BORISOVA | 2017-07-06 10:35:00+03
-- EKATERINA BORISOVA  | 2017-07-16 01:25:00+03
-- VLADIMIR ANTONOV    | 2017-07-13 17:45:00+03
--(19 rows)


-- ЗАДАЧА: Сколько мест осталось незанятыми вчера на рейсе PG0404?

-- С помощью NOT EXISTS найдем места без посадочных талонов

SELECT  count(*)
FROM    flights f
        JOIN seats s
          ON s.aircraft_code = f.aircraft_code
WHERE   f.flight_no = 'PG0404'
AND     f.scheduled_departure::date = bookings.now()::date - INTERVAL '1 day'
AND     NOT EXISTS (
          SELECT NULL
          FROM boarding_passes bp
          WHERE bp.flight_id = f.flight_id
          AND bp.seat_no = s.seat_no
        );

-- count 
---------
--    63
--(1 row)

-- Сколько всего было мест вчера на рейс PG0404

SELECT  count(*)
FROM    flights f
        JOIN seats s
          ON s.aircraft_code = f.aircraft_code
WHERE   f.flight_no = 'PG0404'
AND     f.scheduled_departure::date = bookings.now()::date - INTERVAL '1 day';

-- count 
---------
--   170
--(1 row)

-- Решение с помощью вычитания множеств ("все билеты на рейс" - "Все пассажиры, севшие на рейс")

SELECT count(*)
FROM (
  SELECT s.seat_no
  FROM seats s
  WHERE s.aircraft_code = (
    SELECT aircraft_code
    FROM flights
    WHERE flight_no = 'PG0404'
    AND scheduled_departure::date = bookings.now()::date - INTERVAL '1 day'
  )
  EXCEPT
  SELECT bp.seat_no
  FROM boarding_passes bp
  WHERE bp.flight_id = (
    SELECT flight_id
    FROM flights
    WHERE flight_no = 'PG0404'
    AND scheduled_departure::date = bookings.now()::date - INTERVAL '1 day'
  )
) t;

-- count 
---------
--    63
--(1 row)

-- все билеты на рейс:

SELECT count(*)
FROM (
  SELECT s.seat_no
  FROM seats s
  WHERE s.aircraft_code = (
    SELECT aircraft_code
    FROM flights
    WHERE flight_no = 'PG0404'
    AND scheduled_departure::date = bookings.now()::date - INTERVAL '1 day'
  ) 
);

-- count 
---------
--   170
--(1 row)

-- Все пассажиры, севшие на рейс

SELECT count(*)
FROM (
  SELECT bp.seat_no
  FROM boarding_passes bp
  WHERE bp.flight_id = (  
    SELECT flight_id
    FROM flights
    WHERE flight_no = 'PG0404'
    AND scheduled_departure::date = bookings.now()::date - INTERVAL '1 day'
  )                                                                        
);                                                                        

-- count 
---------
--   107
--(1 row)


-- ЗАДАЧА: на каких рейсах происходили самые длительные задержки? Выведите список из 10 рейсов, задержанных на самые длительные сроки.

SELECT    f.flight_no,
          f.scheduled_departure,
          f.actual_departure,
          f.actual_departure - f.scheduled_departure
          AS delay
FROM      flights f
WHERE     f.actual_departure IS NOT NULL
ORDER BY  f.actual_departure - f.scheduled_departure
          DESC
LIMIT 10;

-- flight_no |  scheduled_departure   |    actual_departure    |  delay   
-------------+------------------------+------------------------+----------
-- PG0589    | 2017-07-29 15:30:00+03 | 2017-07-29 20:07:00+03 | 04:37:00
-- PG0164    | 2017-07-29 15:25:00+03 | 2017-07-29 19:53:00+03 | 04:28:00
-- PG0364    | 2017-07-19 11:45:00+03 | 2017-07-19 16:12:00+03 | 04:27:00
-- PG0568    | 2017-08-13 16:15:00+03 | 2017-08-13 20:35:00+03 | 04:20:00
-- PG0454    | 2017-08-02 10:05:00+03 | 2017-08-02 14:23:00+03 | 04:18:00
-- PG0096    | 2017-08-03 16:35:00+03 | 2017-08-03 20:53:00+03 | 04:18:00
-- PG0166    | 2017-08-12 14:35:00+03 | 2017-08-12 18:51:00+03 | 04:16:00
-- PG0278    | 2017-07-16 14:20:00+03 | 2017-07-16 18:36:00+03 | 04:16:00
-- PG0564    | 2017-08-10 09:30:00+03 | 2017-08-10 13:44:00+03 | 04:14:00
-- PG0669    | 2017-07-19 16:15:00+03 | 2017-07-19 20:23:00+03 | 04:08:00
--(10 rows)

-- 10 рейсов с минимальной задержкой

demo=# SELECT    f.flight_no,
          f.scheduled_departure,
          f.actual_departure,
          f.actual_departure - f.scheduled_departure
          AS delay
FROM      flights f
WHERE     f.actual_departure IS NOT NULL
ORDER BY  f.actual_departure - f.scheduled_departure
LIMIT 10;     

-- flight_no |  scheduled_departure   |    actual_departure    |  delay   
-------------+------------------------+------------------------+----------
-- PG0405    | 2017-07-30 09:35:00+03 | 2017-07-30 09:35:00+03 | 00:00:00
-- PG0404    | 2017-07-31 19:05:00+03 | 2017-07-31 19:05:00+03 | 00:00:00
-- PG0404    | 2017-08-14 19:05:00+03 | 2017-08-14 19:05:00+03 | 00:00:00
-- PG0404    | 2017-07-24 19:05:00+03 | 2017-07-24 19:05:00+03 | 00:00:00
-- PG0405    | 2017-08-08 09:35:00+03 | 2017-08-08 09:35:00+03 | 00:00:00
-- PG0404    | 2017-08-06 19:05:00+03 | 2017-08-06 19:05:00+03 | 00:00:00
-- PG0403    | 2017-08-08 11:25:00+03 | 2017-08-08 11:25:00+03 | 00:00:00
-- PG0402    | 2017-07-17 12:25:00+03 | 2017-07-17 12:25:00+03 | 00:00:00
-- PG0403    | 2017-07-29 11:25:00+03 | 2017-07-29 11:25:00+03 | 00:00:00
-- PG0405    | 2017-07-26 09:35:00+03 | 2017-07-26 09:35:00+03 | 00:00:00
--(10 rows)


-- АГРЕГАТНЫЕ ФУНКЦИИ


-- ЗАДАЧА: Какова минимальная и максимальная продолжительность полета для каждого из возможных рейсов из Москвы в Санкт-Петербург,
-- и сколько раз вылет рейса был задержан больше, чем на час?

SELECT    f.flight_no,
          f.scheduled_duration,
          min(f.actual_duration),
          max(f.actual_duration),
          sum(CASE  WHEN  f.actual_departure >
                          f.scheduled_departure + 
                          INTERVAL '1 hour'
                    THEN 1 ELSE 0
              END) delays
FROM      flights_v f
WHERE     f.departure_city = 'Москва'
AND       f.arrival_city = 'Санкт-Петербург'
AND       f.status = 'Arrived'
GROUP BY  f.flight_no,
          f.scheduled_duration;

-- flight_no | scheduled_duration | min | max | delays 
-------------+--------------------+-----+-----+--------
--(0 rows)

-- Города пишем по-английски, т.к. база данных переключена на английский

SELECT    f.flight_no,
          f.scheduled_duration,
          min(f.actual_duration),
          max(f.actual_duration),
          sum(CASE  WHEN  f.actual_departure >
                          f.scheduled_departure + 
                          INTERVAL '1 hour'
                    THEN 1 ELSE 0
              END) delays
FROM      flights_v f
WHERE     f.departure_city = 'Moscow'
AND       f.arrival_city = 'St. Petersburg'
AND       f.status = 'Arrived'
GROUP BY  f.flight_no,
          f.scheduled_duration;

-- flight_no | scheduled_duration |   min    |   max    | delays 
-------------+--------------------+----------+----------+--------
-- PG0227    | 00:50:00           | 00:49:00 | 00:51:00 |      1
-- PG0228    | 00:50:00           | 00:49:00 | 00:51:00 |      3
-- PG0229    | 00:50:00           | 00:49:00 | 00:51:00 |      2
-- PG0402    | 00:55:00           | 00:54:00 | 00:57:00 |      2
-- PG0403    | 00:55:00           | 00:54:00 | 00:57:00 |      2
-- PG0404    | 00:55:00           | 00:54:00 | 00:56:00 |      3
-- PG0405    | 00:55:00           | 00:54:00 | 00:56:00 |      1
-- PG0468    | 00:50:00           | 00:49:00 | 00:51:00 |      0
-- PG0469    | 00:50:00           | 00:49:00 | 00:51:00 |      5
-- PG0470    | 00:50:00           | 00:49:00 | 00:51:00 |      1
-- PG0471    | 00:50:00           | 00:49:00 | 00:51:00 |      1
-- PG0472    | 00:50:00           | 00:49:00 | 00:51:00 |      3
--(12 rows)


-- ЗАДАЧА: Найти самых дисциплинированных пассажиров, которые зарегистрировались на все рейсы первыми.
-- Учитывайте только тех пассажиров, которые совершали минимум два рейса.

-- Учитываем тот файкт, что номера посадочных талонов выдаются в порядке регистрации.

SELECT    t.passenger_name,
          t.ticket_no
FROM      tickets t
          JOIN boarding_passes bp
            ON bp.ticket_no = t.ticket_no
GROUP BY  t.passenger_name,
          t.ticket_no
HAVING    max(bp.boarding_no) = 1
AND       count(*) > 1;

--    passenger_name    |   ticket_no   
------------------------+---------------
-- VIKTOR BELOV         | 0005432054255
-- YULIYA SOROKINA      | 0005432146218
-- NIKOLAY SCHERBAKOV   | 0005432195667
-- ANDREY FROLOV        | 0005432293170
-- ANNA ANDREEVA        | 0005432295838
-- ALEKSANDR MARTYNOV   | 0005432359667
-- ANNA MATVEEVA        | 0005432398234
-- KONSTANTIN KAZAKOV   | 0005432427125
-- SERGEY VOROBEV       | 0005432566574
-- ALEKSANDR FILIPPOV   | 0005432675028
-- NINA LOGINOVA        | 0005432784253
-- ALEKSANDR MAKAROV    | 0005432862259
-- ANASTASIYA MELNIKOVA | 0005432984664
-- MARIYA EGOROVA       | 0005433057209
-- NADEZHDA ROMANOVA    | 0005433060382

-- то же самое, но с ограничением 10 человек

SELECT    t.passenger_name,
          t.ticket_no
FROM      tickets t
          JOIN boarding_passes bp
            ON bp.ticket_no = t.ticket_no
GROUP BY  t.passenger_name,
          t.ticket_no
HAVING    max(bp.boarding_no) = 1
AND       count(*) > 1
LIMIT     10;

--   passenger_name   |   ticket_no   
----------------------+---------------
-- VIKTOR BELOV       | 0005432054255
-- YULIYA SOROKINA    | 0005432146218
-- NIKOLAY SCHERBAKOV | 0005432195667
-- ANDREY FROLOV      | 0005432293170
-- ANNA ANDREEVA      | 0005432295838
-- ALEKSANDR MARTYNOV | 0005432359667
-- ANNA MATVEEVA      | 0005432398234
-- KONSTANTIN KAZAKOV | 0005432427125
-- SERGEY VOROBEV     | 0005432566574
-- ALEKSANDR FILIPPOV | 0005432675028
--(10 rows)

-- ЗАДАЧА: Сколько пассажиров приходится на одно бронирование?

SELECT    tt.cnt,     -- количество пассажиров в каждом бронировании
          count(*)    -- количество бронирований с каждым вариантом количества пассажиров
FROM      (
            SELECT    t.book_ref,
                      count(*) cnt
            FROM      tickets t
            GROUP BY  t.book_ref
          ) tt
GROUP BY  tt.cnt
ORDER BY  tt.cnt;

-- cnt | count  
-------+--------
--   1 | 173390
--   2 |  75793
--   3 |  12686
--   4 |    896
--   5 |     23
--(5 rows)

-- количество пассажиров в каждом бронировании

SELECT    t.book_ref,
          count(*) cnt
FROM      tickets t
GROUP BY  t.book_ref;

-- book_ref | cnt 
------------+-----
-- C92964   |   1
-- 98B6E6   |   1
-- 2A4792   |   2
-- DC7310   |   2
-- 609970   |   1
-- 453C9F   |   2
-- 017036   |   2
-- 3EFFB3   |   1
-- 059EF0   |   1
-- 03072F   |   1
-- 3BD3FD   |   2
-- A49B68   |   2
-- E07800   |   1
-- 5E5A4F   |   1
-- 44E52C   |   2


-- ОКОННЫЕ ФУНКЦИИ


-- ЗАДАЧА: для каждого билета выведите входящие в него перелеты вместе с запасом времени на пересадку на следующий рейс.
-- Ограничьте выборку теми билетами, которые были забронированы 7 днями ранее.

SELECT  tf.ticket_no,
        f.departure_airport,
        f.arrival_airport,
        f.scheduled_arrival,
        lead(f.scheduled_departure) OVER w
        AS next_departure,
        lead(f.scheduled_departure) OVER w - f.scheduled_arrival
        AS gap
FROM    bookings b
        JOIN tickets t
          ON t.book_ref = b.book_ref
        JOIN ticket_flights tf
          ON tf.ticket_no = t.ticket_no
        JOIN flights f
          ON tf.flight_id = f.flight_id
WHERE   b.book_date = bookings.now()::date - INTERVAL '7 day'
WINDOW w AS (
          PARTITION BY tf.ticket_no
          ORDER BY f.scheduled_departure);

--   ticket_no   | departure_airport | arrival_airport |   scheduled_arrival    |     next_departure     |       gap       
-----------------+-------------------+-----------------+------------------------+------------------------+-----------------
-- 0005432748291 | DME               | CEK             | 2017-08-21 11:50:00+03 | 2017-08-29 15:50:00+03 | 8 days 04:00:00
-- 0005432748291 | CEK               | DME             | 2017-08-29 17:50:00+03 |                        | 
-- 0005433570172 | DME               | KZN             | 2017-08-20 11:35:00+03 | 2017-08-21 10:15:00+03 | 22:40:00
-- 0005433570172 | KZN               | IKT             | 2017-08-21 14:55:00+03 | 2017-08-30 13:10:00+03 | 8 days 22:15:00
-- 0005433570172 | IKT               | KZN             | 2017-08-30 17:50:00+03 | 2017-08-31 17:45:00+03 | 23:55:00
-- 0005433570172 | KZN               | DME             | 2017-08-31 18:40:00+03 |                        | 
-- 0005434351952 | VKO               | MQF             | 2017-08-22 16:00:00+03 | 2017-08-30 08:55:00+03 | 7 days 16:55:00
-- 0005434351952 | MQF               | VKO             | 2017-08-30 10:55:00+03 |                        | 
-- 0005434351953 | VKO               | MQF             | 2017-08-22 16:00:00+03 | 2017-08-30 08:55:00+03 | 7 days 16:55:00
-- 0005434351953 | MQF               | VKO             | 2017-08-30 10:55:00+03 |                        | 
-- 0005434505082 | SVO               | OVS             | 2017-08-25 18:50:00+03 | 2017-08-26 14:45:00+03 | 19:55:00
-- 0005434505082 | OVS               | NJC             | 2017-08-26 15:45:00+03 | 2017-09-04 11:15:00+03 | 8 days 19:30:00
-- 0005434505082 | NJC               | OVS             | 2017-09-04 12:15:00+03 | 2017-09-05 13:40:00+03 | 1 day 01:25:00
-- 0005434505082 | OVS               | SVO             | 2017-09-05 15:50:00+03 |                        | 
-- 0005434926468 | SVO               | GOJ             | 2017-08-22 15:15:00+03 | 2017-08-23 16:35:00+03 | 1 day 01:20:00

-- ЗАДАЧА: Какие сочетания имен и фамилий встречаются чаще всего и какую долю от числа всех пассажиров они составляют?

SELECT    passenger_name,
          round( 100.0 * cnt / sum(cnt) OVER (), 2)
          AS percent
FROM      (
            SELECT    passenger_name,
                      count(*) cnt
            FROM      tickets
            GROUP BY  passenger_name
          ) t 
ORDER BY  percent DESC;

--     passenger_name      | percent 
---------------------------+---------
-- ALEKSANDR IVANOV        |    0.23
-- ALEKSANDR KUZNECOV      |    0.21
-- SERGEY IVANOV           |    0.17
-- SERGEY KUZNECOV         |    0.16
-- VLADIMIR IVANOV         |    0.15
-- ALEKSANDR POPOV         |    0.13
-- VLADIMIR KUZNECOV       |    0.13
-- ALEKSANDR PETROV        |    0.12
-- ELENA KUZNECOVA         |    0.12
-- TATYANA IVANOVA         |    0.12
-- ALEKSANDR VASILEV       |    0.11
-- ALEKSEY KUZNECOV        |    0.11
-- TATYANA KUZNECOVA       |    0.11
-- OLGA IVANOVA            |    0.10
-- SERGEY POPOV            |    0.10

-- ЗАДАЧА: решите предыдущую задачу отдельно для имен и отдельно для фамилий

-- Подсчет имен

WITH p AS (
  SELECT  left(passenger_name,
              position(' ' IN passenger_name))
          AS passenger_name
  FROM    tickets
)
SELECT    passenger_name,
          round( 100.0 * cnt / sum(cnt) OVER (), 2)
          AS percent
FROM      (
            SELECT    passenger_name,
                      count(*) cnt
            FROM      p
            GROUP BY  passenger_name
          ) t
ORDER BY  percent DESC;

-- passenger_name | percent 
------------------+---------
-- ALEKSANDR      |    5.54
-- SERGEY         |    4.13
-- VLADIMIR       |    3.49
-- TATYANA        |    3.29
-- ELENA          |    3.08
-- OLGA           |    2.73
-- NATALYA        |    2.65
-- ALEKSEY        |    2.61
-- VALENTINA      |    2.19

-- Подсчет фамилий

WITH p AS (
  SELECT  right(passenger_name,
              position(' ' IN passenger_name))
          AS passenger_name
  FROM    tickets
)
SELECT    passenger_name,
          round( 100.0 * cnt / sum(cnt) OVER (), 2)
          AS percent
FROM      (
            SELECT    passenger_name,
                      count(*) cnt
            FROM      p
            GROUP BY  passenger_name
          ) t
ORDER BY  percent DESC;

-- passenger_name | percent 
------------------+---------
-- ANOVA          |    0.61
-- KUZNECOV       |    0.50
--  IVANOV        |    0.49
-- Y IVANOV       |    0.44
-- UZNECOV        |    0.44
-- IVANOVA        |    0.44
-- ZNECOVA        |    0.39
-- AROVA          |    0.34
-- IKOVA          |    0.31


-- МАССИВЫ


-- ЗАДАЧА: В билете не указывается явно, в один он конец или туда и обратно. Но это можно определить, 
-- сравнив первый пункт отправления с последним пунктом назначения.
-- Для каждого билета выведите аэропорты отправления и назначения без учета пересадок и с указанием того,
-- взят ли он в один конец или туда и обратно.

-- С помощью array_agg сворачиваем список аэропортов поти следования в пассажиров
-- В качестве аэропорта назначения примем средний элемент массива (путь туда = путь обратно)

WITH t AS (
  SELECT  ticket_no,
          a,
          a[1]                  departure,
          a[cardinality(a)]     last_arrival,
          a[cardinality(a)/2+1] middle
  FROM (
    SELECT  t.ticket_no,
            array_agg(  f.departure_airport
              ORDER BY  f.scheduled_departure) ||
            (array_agg( f.arrival_airport
              ORDER BY  f.scheduled_departure DESC)
            )[1] AS a
    FROM    tickets t 
            JOIN ticket_flights tf 
              ON tf.ticket_no = t.ticket_no
            JOIN flights f 
              ON f.flight_id = tf.flight_id
    GROUP BY t.ticket_no
  ) t
)
SELECT  t.ticket_no,
        t.a,
        t.departure,
        CASE
          WHEN t.departure = t.last_arrival
            THEN t.middle
          ELSE t.last_arrival
        END arrival,
        (t.departure = t.last_arrival) return_ticket
FROM t;

--   ticket_no   |               a               | departure | arrival | return_ticket 
-----------------+-------------------------------+-----------+---------+---------------
-- 0005432000987 | {CSY,SVO}                     | CSY       | SVO     | f
-- 0005432000988 | {CSY,SVO}                     | CSY       | SVO     | f
-- 0005432000989 | {CSY,SVO}                     | CSY       | SVO     | f
-- 0005432000990 | {CSY,SVO}                     | CSY       | SVO     | f
-- 0005432000991 | {CSY,SVO}                     | CSY       | SVO     | f
-- 0005432000992 | {CSY,SVO}                     | CSY       | SVO     | f
-- 0005432000993 | {CSY,SVO}                     | CSY       | SVO     | f
-- 0005432000994 | {CSY,SVO}                     | CSY       | SVO     | f
-- 0005432000995 | {CSY,SVO}                     | CSY       | SVO     | f
-- 0005432000996 | {CSY,SVO}                     | CSY       | SVO     | f

-- ЗАДАЧА: Найдите билеты, взятые туда и обратно, в которых путь "туда" не совадает с путем "обратно".

WITH ticket_routes AS (
  SELECT  t.ticket_no,
          array_agg(  f.departure_airport 
            ORDER BY  f.scheduled_departure
          ) AS departure_airports,
          array_agg(  f.arrival_airport 
            ORDER BY  f.scheduled_departure
          ) AS arrival_airports,
          array_agg(  f.departure_airport 
            ORDER BY  f.scheduled_departure) || 
          (array_agg( f.arrival_airport 
            ORDER BY  f.scheduled_departure DESC)
          )[1] AS full_route
  FROM    tickets t 
          JOIN ticket_flights tf 
            ON tf.ticket_no = t.ticket_no
          JOIN flights f 
            ON f.flight_id = tf.flight_id
  GROUP BY t.ticket_no
),
route_analysis AS (
  SELECT  ticket_no,
          full_route[1] AS departure,
          full_route[array_length(full_route, 1)] AS last_arrival,
          (full_route[1] = full_route[array_length(full_route, 1)]) AS is_return_ticket,
          departure_airports,
          arrival_airports,
          array(
            SELECT arrival_airports[i] 
            FROM generate_subscripts(arrival_airports, 1) AS i 
            ORDER BY i DESC
          ) AS reversed_arrival_airports
  FROM    ticket_routes
)
SELECT    ticket_no,
          departure AS initial_departure,
          last_arrival AS final_arrival,
          departure_airports,
          arrival_airports
FROM      route_analysis
WHERE     is_return_ticket = true
AND       departure_airports <> reversed_arrival_airports;

--   ticket_no   | initial_departure | final_arrival |    departure_airports     |     arrival_airports      
-----------------+-------------------+---------------+---------------------------+---------------------------
-- 0005432394032 | SVO               | SVO           | {SVO,OVB,ABA,TOF}         | {OVB,ABA,TOF,SVO}
-- 0005432394033 | SVO               | SVO           | {SVO,OVB,ABA,TOF}         | {OVB,ABA,TOF,SVO}
-- 0005432394034 | SVO               | SVO           | {SVO,OVB,ABA,TOF}         | {OVB,ABA,TOF,SVO}
-- 0005432394035 | SVO               | SVO           | {SVO,OVB,ABA,TOF}         | {OVB,ABA,TOF,SVO}
-- 0005432394036 | SVO               | SVO           | {SVO,OVB,ABA,TOF}         | {OVB,ABA,TOF,SVO}
-- 0005432394037 | SVO               | SVO           | {SVO,OVB,ABA,TOF}         | {OVB,ABA,TOF,SVO}
-- 0005432394038 | SVO               | SVO           | {SVO,OVB,ABA,TOF}         | {OVB,ABA,TOF,SVO}
-- 0005432394039 | SVO               | SVO           | {SVO,OVB,ABA,TOF}         | {OVB,ABA,TOF,SVO}
-- 0005432394040 | SVO               | SVO           | {SVO,OVB,ABA,TOF}         | {OVB,ABA,TOF,SVO}
-- 0005432394041 | SVO               | SVO           | {SVO,OVB,ABA,TOF}         | {OVB,ABA,TOF,SVO}

-- Создает таблицу, в которой указывается маршрут по которому летит самолет для данного билета

SELECT  t.ticket_no,
        array_agg(  f.departure_airport 
          ORDER BY  f.scheduled_departure
        ) AS departure_airports,
        array_agg(  f.arrival_airport 
          ORDER BY  f.scheduled_departure
        ) AS arrival_airports,
        array_agg(  f.departure_airport 
          ORDER BY  f.scheduled_departure) || 
        (array_agg( f.arrival_airport 
          ORDER BY  f.scheduled_departure DESC)
        )[1] AS full_route
FROM    tickets t 
        JOIN ticket_flights tf 
          ON tf.ticket_no = t.ticket_no
        JOIN flights f 
          ON f.flight_id = tf.flight_id
GROUP BY t.ticket_no;

--   ticket_no   |    departure_airports     |     arrival_airports      |          full_route           
-----------------+---------------------------+---------------------------+-------------------------------
-- 0005432000987 | {CSY}                     | {SVO}                     | {CSY,SVO}
-- 0005432000988 | {CSY}                     | {SVO}                     | {CSY,SVO}
-- 0005432000989 | {CSY}                     | {SVO}                     | {CSY,SVO}
-- 0005432000990 | {CSY}                     | {SVO}                     | {CSY,SVO}
-- 0005432000991 | {CSY}                     | {SVO}                     | {CSY,SVO}
-- 0005432000992 | {CSY}                     | {SVO}                     | {CSY,SVO}
-- 0005432000993 | {CSY}                     | {SVO}                     | {CSY,SVO}
-- 0005432000994 | {CSY}                     | {SVO}                     | {CSY,SVO}
-- 0005432000995 | {CSY}                     | {SVO}                     | {CSY,SVO}

-- ЗАДАЧА: Найдите такие пары аэропортов, рейсы между которыми в одну и другую стороны отправляются по разным дням недели.

WITH flight_days AS (
  SELECT    departure_airport,
            arrival_airport,
            array_agg(
              DISTINCT EXTRACT(DOW FROM scheduled_departure) 
              ORDER BY EXTRACT(DOW FROM scheduled_departure)
            ) AS departure_days,
            array_agg(
              DISTINCT EXTRACT(DOW FROM scheduled_arrival) 
              ORDER BY EXTRACT(DOW FROM scheduled_arrival)
            ) AS arrival_days
  FROM      flights
  GROUP BY  departure_airport, 
            arrival_airport
),
airport_pairs AS (  -- соединяем направления A->B и B->A
  SELECT    f1.departure_airport AS airport1,
            f1.arrival_airport AS airport2,
            f1.departure_days AS days_1_to_2,
            f2.departure_days AS days_2_to_1
  FROM      flight_days f1
            JOIN flight_days f2 
              ON f1.departure_airport = f2.arrival_airport 
            AND f1.arrival_airport = f2.departure_airport
  WHERE     f1.departure_airport < f1.arrival_airport  -- избегаем дублирования пар
)
SELECT      airport1,
            airport2,
            days_1_to_2,
            days_2_to_1
FROM        airport_pairs
WHERE       days_1_to_2 <> days_2_to_1    -- выбираем только те пары, где дни недели отличаются
ORDER BY    airport1, 
            airport2;

-- airport1 | airport2 | days_1_to_2 | days_2_to_1 
------------+----------+-------------+-------------
-- AAQ      | NOZ      | {2}         | {1}
-- ABA      | DME      | {0,3}       | {2,6}
-- ABA      | GRV      | {3}         | {2}
-- ABA      | KYZ      | {2,6}       | {1,4}
-- AER      | GOJ      | {1,4,6}     | {1,3,6}
-- AER      | IAR      | {0}         | {3}
-- AER      | IWA      | {0,3}       | {2,6}
-- AER      | KGP      | {6}         | {1}
-- AER      | KJA      | {0,3}       | {0,4}
-- AER      | NOZ      | {3,6}       | {2,6}
-- ARH      | TJM      | {0,2,4}     | {1,3,6}
-- ARH      | TOF      | {0,3}       | {0,4}

-- Для каждого направления (пары аэропортов) собираем дни недели, в которые выполняются рейсы

SELECT    departure_airport,
          arrival_airport,
          array_agg(
            DISTINCT EXTRACT(DOW FROM scheduled_departure) 
            ORDER BY EXTRACT(DOW FROM scheduled_departure)
          ) AS departure_days,
          array_agg(
            DISTINCT EXTRACT(DOW FROM scheduled_arrival) 
            ORDER BY EXTRACT(DOW FROM scheduled_arrival)
          ) AS arrival_days
FROM      flights
GROUP BY  departure_airport, 
          arrival_airport;

-- departure_airport | arrival_airport | departure_days  |  arrival_days   
---------------------+-----------------+-----------------+-----------------
-- AAQ               | EGO             | {0,1,2,3,4,5,6} | {0,1,2,3,4,5,6}
-- AAQ               | NOZ             | {2}             | {2}
-- AAQ               | SVO             | {0,1,2,3,4,5,6} | {0,1,2,3,4,5,6}
-- ABA               | ARH             | {6}             | {6}
-- ABA               | DME             | {0,3}           | {0,3}
-- ABA               | GRV             | {3}             | {3}
-- ABA               | KYZ             | {2,6}           | {2,6}
-- ABA               | OVB             | {0,1,2,3,4,5,6} | {0,1,2,3,4,5,6}
-- ABA               | TOF             | {0,1,2,3,4,5,6} | {0,1,2,3,4,5,6}
-- AER               | EGO             | {0,1,2,3,4,5,6} | {0,1,2,3,4,5,6}

-- Вариант из учебника

SELECT  r1.departure_airport,
        r1.arrival_airport,
        r1.days_of_week dow,
        r2.days_of_week dow_back
FROM    routes r1
        JOIN routes r2 
          ON r1.arrival_airport = r2.departure_airport
        AND r1.departure_airport = r2.arrival_airport
WHERE   NOT (r1.days_of_week && r2.days_of_week);

-- departure_airport | arrival_airport |   dow   | dow_back 
---------------------+-----------------+---------+----------
-- UIK               | SGC             | {6}     | {7}
-- SGC               | UIK             | {7}     | {6}
-- IWA               | AER             | {2,6}   | {3,7}
-- AER               | IWA             | {3,7}   | {2,6}
-- DME               | PKV             | {2,5,7} | {1,4,6}
-- PKV               | DME             | {1,4,6} | {2,5,7}
-- IAR               | TOF             | {7}     | {1}
-- SVO               | VKT             | {3,6}   | {4,7}


-- РЕКУРСИВНЫЕ ЗАПРОСЫ


-- ЗАДАЧА: Как добраться из Усть-Кута (UKX) в Нерюнги (CNN) с минимальным числом пересадок
-- и сколько времени придется провести в воздухе?

-- т.о. необходимо найти кратчайший путь в графе, что делается рекурсивным запросом

WITH RECURSIVE p( -- инициализация начальных значений
  last_arrival,   -- последний достигнутый аэропорт
  destination,    -- аэропорт назначения
  hops,           -- массив посещенных аэропортов
  flights,        -- массив номеров рейсов
  flight_time,    -- общее время в пути
  found           -- флаг достижения пути назначения
) AS (
  SELECT  a_from.airport_code,
          a_to.airport_code,
          array[a_from.airport_code],             -- инициализируем массив hops начальным аэропортом
          array[]::char(6)[],
          interval '0',                           -- время поляета = 0
          a_from.airport_code = a_to.airport_code -- флаг = true, когда начальный и конечный аэропорт совпадают
  FROM    airports a_from,
          airports a_to
  WHERE   a_from.airport_code = 'UKX'
  AND     a_to.airport_code = 'CNN'
  UNION ALL        -- рекурсивный поиск маршрута 
  SELECT  r.arrival_airport,
          p.destination,
          (p.hops || r.arrival_airport)::char(3)[],
          (p.flights || r.flight_no)::char(6)[],
          p.flight_time + r.duration,
          bool_or(r.arrival_airport = p.destination)
            OVER ()
  FROM    p 
          JOIN routes r
            ON r.departure_airport = p.last_arrival
  WHERE   NOT r.arrival_airport = ANY(p.hops)
  AND     NOT p.found
)
SELECT    hops,
          flights,
          flight_time
FROM      p 
WHERE     p.last_arrival = p.destination;

--         hops          |            flights            | flight_time 
-------------------------+-------------------------------+-------------
-- {UKX,KJA,OVB,MJZ,CNN} | {PG0022,PG0206,PG0390,PG0035} | 10:25:00
-- {UKX,KJA,OVB,MJZ,CNN} | {PG0022,PG0207,PG0390,PG0035} | 10:25:00
-- {UKX,KJA,SVO,MJZ,CNN} | {PG0022,PG0548,PG0120,PG0035} | 15:40:00
-- {UKX,KJA,OVB,MJZ,CNN} | {PG0022,PG0206,PG0390,PG0036} | 10:25:00
-- {UKX,KJA,OVB,MJZ,CNN} | {PG0022,PG0207,PG0390,PG0036} | 10:25:00
-- {UKX,KJA,SVO,MJZ,CNN} | {PG0022,PG0548,PG0120,PG0036} | 15:40:00
-- {UKX,KJA,OVS,LED,CNN} | {PG0022,PG0689,PG0686,PG0245} | 14:15:00
-- {UKX,KJA,SVO,LED,CNN} | {PG0022,PG0548,PG0472,PG0245} | 14:35:00
-- {UKX,KJA,SVO,LED,CNN} | {PG0022,PG0548,PG0471,PG0245} | 14:35:00
-- {UKX,KJA,SVO,LED,CNN} | {PG0022,PG0548,PG0470,PG0245} | 14:35:00
-- {UKX,KJA,SVO,LED,CNN} | {PG0022,PG0548,PG0469,PG0245} | 14:35:00
-- {UKX,KJA,SVO,LED,CNN} | {PG0022,PG0548,PG0468,PG0245} | 14:35:00

-- ЗАДАЧА: Какое максимальное количество пересадок может потребоваться,
-- чтобы добраться из одного любого аэропорта в любой другой?

WITH RECURSIVE p(
  departure,
  last_arrival,
  destination,
  hops,
  found
) AS (
  SELECT  a_from.airport_code,
          a_from.airport_code,
          a_to.airport_code,
          array[a_from.airport_code],
          a_from.airport_code = a_to.airport_code
  FROM    airports a_from,
          airports a_to
  UNION ALL
  SELECT  p.departure,
          r.arrival_airport,
          p.destination,
          (p.hops || r.arrival_airport)::char(3)[],
          bool_or(r.arrival_airport = p.destination)
            OVER (PARTITION BY  p.departure,
                                p.destination)
  FROM    p 
          JOIN routes r 
            ON r.departure_airport = p.last_arrival
  WHERE   NOT r.arrival_airport = ANY(p.hops)
  AND     NOT p.found
)
SELECT  max(cardinality(hops)-1)
FROM    p
WHERE   p.last_arrival = p.destination;

--         hops          |            flights            | flight_time 
-------------------------+-------------------------------+-------------
-- {UKX,KJA,OVB,MJZ,CNN} | {PG0022,PG0206,PG0390,PG0035} | 10:25:00
-- {UKX,KJA,OVB,MJZ,CNN} | {PG0022,PG0207,PG0390,PG0035} | 10:25:00
-- {UKX,KJA,SVO,MJZ,CNN} | {PG0022,PG0548,PG0120,PG0035} | 15:40:00
-- {UKX,KJA,OVB,MJZ,CNN} | {PG0022,PG0206,PG0390,PG0036} | 10:25:00
-- {UKX,KJA,OVB,MJZ,CNN} | {PG0022,PG0207,PG0390,PG0036} | 10:25:00
-- {UKX,KJA,SVO,MJZ,CNN} | {PG0022,PG0548,PG0120,PG0036} | 15:40:00

-- ЗАДАЧА: Найдите кратчайший путь, ведущий из Усть-Кута (UKX) в Нерюнги (CNN),
-- с точки зрения чистого времени перелетов (игнорируя время пересадок)

WITH RECURSIVE p(
  last_arrival,
  destination,
  flights,
  flight_time,
  min_time 
) AS (
  SELECT  a_from.airport_code,
          a_to.airport_code,
          array[]::char(6)[],
          interval '0',
          NULL::interval
  FROM    airports a_from,
          airports a_to
  WHERE   a_from.airport_code = 'UKX'
  AND     a_to.airport_code = 'CNN'
  UNION ALL
  SELECT  r.arrival_airport,
          p.destination,
          (p.flights || r.flight_no)::char(6)[],
          p.flight_time + r.duration,
          least(
            p.min_time,
            min(p.flight_time + r.duration)
            FILTER (
              WHERE r.arrival_airport = p.destination
            ) OVER ()
          )
  FROM    p 
          JOIN routes r 
            ON r.departure_airport = p.last_arrival
  WHERE   p.flight_time + r.duration
          < coalesce(
              p.min_time,
              INTERVAL '1 year'
            )
)
CYCLE last_arrival SET is_cycle USING hops
SELECT  hops,
        flights,
        flight_time
FROM    (
          SELECT  hops,
                  flights,
                  flight_time,
                  min(min_time) OVER () min_time
          FROM    p 
          WHERE   p.last_arrival = p.destination
        ) t
WHERE   flight_time = min_time;

--                 hops                  |               flights                | flight_time 
-----------------------------------------+--------------------------------------+-------------
-- {(UKX),(KJA),(NOZ),(OVB),(MJZ),(CNN)} | {PG0022,PG0352,PG0297,PG0390,PG0035} | 10:10:00
-- {(UKX),(KJA),(NOZ),(OVB),(MJZ),(CNN)} | {PG0022,PG0351,PG0297,PG0390,PG0035} | 10:10:00
-- {(UKX),(KJA),(NOZ),(OVB),(MJZ),(CNN)} | {PG0022,PG0352,PG0298,PG0390,PG0035} | 10:10:00
-- {(UKX),(KJA),(NOZ),(OVB),(MJZ),(CNN)} | {PG0022,PG0351,PG0298,PG0390,PG0035} | 10:10:00
-- {(UKX),(KJA),(NOZ),(OVB),(MJZ),(CNN)} | {PG0022,PG0352,PG0297,PG0390,PG0036} | 10:10:00
-- {(UKX),(KJA),(NOZ),(OVB),(MJZ),(CNN)} | {PG0022,PG0351,PG0297,PG0390,PG0036} | 10:10:00
-- {(UKX),(KJA),(NOZ),(OVB),(MJZ),(CNN)} | {PG0022,PG0352,PG0298,PG0390,PG0036} | 10:10:00
-- {(UKX),(KJA),(NOZ),(OVB),(MJZ),(CNN)} | {PG0022,PG0351,PG0298,PG0390,PG0036} | 10:10:00
--(8 rows)


-- ФУНКЦИИ И РАСШИРЕНИЯ


-- ЗАДАЧА: Найдите расстояние между Калининградом (KGD) и Петропавловском-Камчатским (PKC)

-- необходимо учесть сферическую форму Земли

CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;
SELECT  round(
          (a_from.coordinates <@> a_to.coordinates) * 
          1.609344
          )
FROM    airports a_from,
        airports a_to
WHERE   a_from.airport_code = 'KGD'
AND     a_to.airport_code = 'PKC';

-- round 
---------
--  7392
--(1 row)
