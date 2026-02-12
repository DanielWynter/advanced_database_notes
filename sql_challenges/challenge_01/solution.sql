-- lesson 1
SELECT title FROM movies; 
SELECT director FROM movies;
SELECT director, title FROM movies;
SELECT title, year FROM movies;
SELECT * FROM movies;

-- lesson 2
SELECT title FROM movies WHERE id=6;
SELECT title FROM movies WHERE year BETWEEN 2000 and 2010;
SELECT title FROM movies WHERE year NOT BETWEEN 2000 and 2010;
SELECT title, Year FROM movies WHERE id BETWEEN 1 AND 5;

-- lesson 3
SELECT title FROM movies WHERE title LIKE "%Toy Story%";
SELECT title FROM movies WHERE director = "John Lasseter";
SELECT title, director FROM movies WHERE director != "John Lasseter";
SELECT title FROM movies WHERE title LIKE "%WALL-%";

-- lesson 4
SELECT DISTINCT director FROM movies ORDER BY director asc;
SELECT title FROM movies ORDER BY year desc LIMIT 4;
SELECT title FROM movies ORDER BY title asc LIMIT 5;
SELECT title FROM movies ORDER BY title asc LIMIT 5 OFFSET 5;

-- lesson 5
SELECT City, Population FROM north_american_cities WHERE country = "Canada";
SELECT City FROM north_american_cities WHERE country = "United States" Order By latitude desc;
SELECT City FROM north_american_cities WHERE longitude < (SELECT longitude FROM north_american_cities Where city = "Chicago") Order By longitude asc;
SELECT City FROM north_american_cities WHERE Country = "Mexico" ORDER BY Population desc LIMIT 2;
SELECT City FROM north_american_cities WHERE Country = "United States" ORDER BY population desc LIMIT 2 OFFSET 2;