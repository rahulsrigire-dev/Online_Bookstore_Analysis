create database OnlineBookstore;

use onlinebookstore;

CREATE TABLE Books(
Book_ID INT AUTO_INCREMENT PRIMARY KEY,
Title VARCHAR(100) ,
Author VARCHAR(100) ,
Genre VARCHAR(50),
Published_Year INT,
Price DECIMAL(10,2),
Stock INT
);

CREATE TABLE Customers(
Customer_ID INT AUTO_INCREMENT PRIMARY KEY,
Name VARCHAR(50) ,
Email VARCHAR(100),
Phone VARCHAR(15),
City VARCHAR(100),
Country VARCHAR(100)
);

CREATE TABLE ORDERS(
Order_ID INT AUTO_INCREMENT PRIMARY KEY,
Customer_ID INT,
Book_ID INT,
Order_Date DATE,
Quantity INT,
Total_Amount DECIMAL(10,2),
FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
);

select * from books;
select * from customers;
select * from orders;

-- 1) Retrive all books in the "Fiction" Genre

SELECT * FROM books
where Genre = 'Fiction';

-- 2) Find the books published after the year 1950

SELECT * FROM books
WHERE Published_Year > 1950;

-- 3 List all customers from canada

SELECT * FROM customers
WHERE Country = 'Canada';

-- 4 Show orders placed in november 2023

SELECT * FROM orders
WHERE Order_Date BETWEEN '2023-11-01' and '2023-11-30';

-- 5) Retrieve the total stock of books available

SELECT SUM(Stock) as Total_Stock FROM books;

-- 6) Find the details of the most expensive book

SELECT * FROM books
WHERE Price = (SELECT MAX(Price) FROM books);

-- 7) Show all customers who ordered more than 1 quantity of a book

SELECT * FROM orders
WHERE Quantity >1;

-- 8) Retrieve all orders where the total amount exceeds $20

SELECT * FROM orders
WHERE Total_Amount > 20;

-- 9) List all genres available in the Books table

SELECT DISTINCT Genre FROM books;

-- 10) Find the books with the lowest stock

SELECT * FROM books
WHERE Stock= (SELECT MIN(Stock) FROM books);

-- 11) Calculate the total revenue generated from all orders

SELECT SUM(Total_Amount) AS Total_Revenue FROM orders;

-- 12) Retrieve the total number of books sold for each genre

SELECT b.Genre, SUM(o.Quantity) AS Total_Books_Sold FROM books b
INNER JOIN orders o
ON b.Book_ID=o.Book_ID
GROUP BY b.Genre;

-- 13) Find the average price of books in the "Fantasy" genre

SELECT Genre, AVG(Price) AS avg_price FROM books
WHERE Genre = 'Fantasy';

-- 14) List customers who have placed at least 2 orders

SELECT c.Customer_ID, c.Name , COUNT(o.Customer_ID) AS Order_Count FROM customers c
INNER JOIN orders o
ON c.Customer_ID=o.Customer_ID
GROUP BY c.Customer_ID
HAVING COUNT(o.Customer_ID)>=2;

-- 15) Find the most frequently ordered book

SELECT Book_ID, COUNT(Order_ID) AS Order_Count
FROM Orders
GROUP BY Book_ID
ORDER BY Order_Count DESC
LIMIT 1;

-- 16) Show the top 3 most expensive books of 'Fantasy' Genre 

SELECT Book_ID, Price FROM books
WHERE Genre='Fantasy'
ORDER BY Price DESC
LIMIT 3;

-- 17) Retrieve the total quantity of books sold by each author

SELECT b.Author, SUM(o.Quantity) AS Total_Books_Sold FROM books b
INNER JOIN orders o
ON b.Book_ID=o.Book_ID
GROUP BY b.Author
ORDER BY Total_Books_Sold DESC;

-- 18) List the cities where customers who spent over $30 are located

SELECT c.city,c.Customer_ID, SUM(Total_Amount) AS Amount_Spent FROM customers c
INNER JOIN orders o
ON c.Customer_ID=o.Customer_ID
GROUP BY  c.City,c.Customer_ID
HAVING SUM(Total_Amount) > 30
ORDER BY Amount_Spent DESC;

-- 19) Find the customer who spent the most on orders

SELECT c.Customer_ID, c.Name, SUM(o.Total_Amount)  AS Amount_Spent FROM customers c
INNER JOIN orders o
ON c.Customer_ID=o.Customer_ID
GROUP BY c.Customer_ID, c.Name
ORDER BY Amount_Spent DESC
LIMIT 1;

-- 20) Calculate the stock remaining after fulfilling all orders

SELECT b.Book_ID,b.Title,b.Stock,COALESCE(SUM(o.Quantity), 0) AS Order_Quantity, 
b.Stock - COALESCE(SUM(o.Quantity), 0) AS Remaining_Quantity
FROM books b
LEFT JOIN orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID
ORDER BY b.Book_ID;

-- 21) Rank customers by total spending and identify the top spender(s)

WITH Customer_Spending AS(
SELECT c.Customer_ID, c.Name , SUM(Total_Amount) AS Total_Spending FROM customers c
LEFT JOIN orders o
ON c.Customer_ID=o.Customer_ID
GROUP BY c.Customer_ID, c.Name
) 
SELECT *, DENSE_RANK() OVER(ORDER BY Total_Spending DESC) AS RNK FROM Customer_Spending;

-- 22) Analyze customer spending trend using previous orders

SELECT Customer_ID,Order_Date,Total_Amount AS Order_Spending,
LAG(Total_Amount) OVER(PARTITION BY Customer_ID ORDER BY Order_Date) AS Previous_Order_Amount 
FROM orders;
