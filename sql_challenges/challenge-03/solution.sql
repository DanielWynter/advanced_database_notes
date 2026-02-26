--Lesson 10

1. SELECT MAX(years_employed) as Max_years_employed
FROM employees;

2. SELECT role, AVG(years_employed) as Average_years_employed
FROM employees
GROUP BY role;

3. SELECT building, SUM(years_employed) as Total_years_employed
FROM employees
GROUP BY building;

--Lesson 11

1. SELECT COUNT(role), role FROM employees
WHERE Role = "Artist"
GROUP BY Role

2. SELECT Count(name), Role FROM employees
GROUP BY Role

3. SELECT Sum(years_employed) FROM employees
WHERE Role = "Engineer"


--Try it 1
select count(unique shape) number_of_shapes,
       stddev(unique Weight) distinct_weight_stddev
from   bricks;

--Try it 2
select shape, sum ( weight )
from   bricks
group  by shape;

--Try it 3
select shape, sum ( weight )
from   bricks
group  by shape;
having sum(weight) < 4;