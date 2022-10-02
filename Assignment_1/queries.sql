SELECT * FROM authors

SELECT COUNT(*) FROM authors

SELECT  authors.id, COUNT(authors.id) FROM authors
GROUP BY authors.id
HAVING COUNT(authors.id) > 1

