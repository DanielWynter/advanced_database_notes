#Lesson 6
- SELECT Title, Domestic_sales, International_sales
FROM Boxoffice
JOIN Movies
ON Boxoffice.Movie_id = Movies.id

- SELECT Title, Domestic_sales, International_sales
FROM Boxoffice
JOIN Movies
ON Boxoffice.Movie_id = Movies.id
WHERE Boxoffice.International_sales > Boxoffice.Domestic_sales;

- SELECT Title
FROM Movies
JOIN Boxoffice
ON Movies.id = Boxoffice.Movie_id
ORDER BY Rating
desc

#Lesson 7
- SELECT DISTINCT Building_name
FROM Buildings
JOIN Employees
ON Buildings.Building_name = Employees.Building

- SELECT DISTINCT Building_name, Capacity
FROM Buildings

- SELECT DISTINCT Building_name, Role
FROM Buildings
LEFT JOIN Employees
ON Buildings.Building_name = Employees.Building


#Interview question
SELECT DISTINCT p.page_id
FROM pages AS p
LEFT JOIN page_likes
ON p.page_id = page_likes.page_id
WHERE liked_date IS NULL
ORDER BY page_id ASC

