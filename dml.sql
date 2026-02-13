-- DML QUERIES
-- Group 39
-- Zachary Sherman
-- Justin Barreras

------------------------------------------------------------------------
-- VIEW QUERIES
-------------------------------------------------------------------------


-- GENERIC VIEWS (ALL VALUES)
SELECT * FROM Products;
SELECT * FROM Inventories;
SELECT * FROM ProductInventories;
SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderProducts;

-- USER FRIENDLY VIEWS
-- Display products with their current price
SELECT name AS product, currentPrice AS price FROM Products;

--display all inventories available
SELECT name, atStore FROM Inventories;

-- Display products with their respective locations and quantities
SELECT Products.name as product, Inventories.name as location, ProductInventories.quantity
FROM Products INNER JOIN ProductInventories ON Products.productID = ProductInventories.productID
INNER JOIN Inventories ON ProductInventories.inventoryID = Inventories.inventoryID
ORDER BY product;

-- Display all customers
SELECT fName as First, lname as Last, email
FROM Customers;

-- Display dollar value of an orderitem entry
SELECT OrderProducts.orderID AS "Order Number", 
SUM(OrderProducts.quantity * Products.currentPrice) AS itemTotal FROM OrderProducts INNER JOIN Products 
WHERE OrderProducts.productID = Products.productID GROUP BY orderID;

-- Display each order and the sum of that order along with the customer who made the order
SELECT Orders.orderDate as Date, Customers.fname as First, Customers.lname as Last,
itemTotal as "Order Total" FROM Orders INNER JOIN Customers ON Orders.customerID = Customers.customerID 
INNER JOIN
(
SELECT OrderProducts.orderID, SUM(OrderProducts.quantity * Products.currentPrice) AS itemTotal 
FROM OrderProducts INNER JOIN Products 
ON OrderProducts.productID = Products.productID GROUP BY orderID
) 
AS t ON Orders.orderID=t.orderID;
-- Display each order product with the product name, quantity, inventory from, and who made the purchase
SELECT OrderProducts.orderID as "Order Number", Products.name as "Product", OrderProducts.quantity, 
Inventories.name AS 'Inventory', CONCAT(Customers.fName,' ',Customers.lName) AS Name FROM
OrderProducts INNER JOIN Products on Products.productID = OrderProducts.productID
INNER JOIN Inventories on Inventories.inventoryID = OrderProducts.inventoryID
INNER JOIN Orders on Orders.orderID = OrderProducts.orderID
INNER JOIN Customers on Orders.customerID = Customers.customerID 
ORDER BY OrderProducts.orderID ASC;


-------------------------------------------------------------------------------------
-- SELECTIVE VIEWS -> I Believe these are going to be better as procedures later on.
-------------------------------------------------------------------------------------


-- Get CustomerID based on customer name => Better as a function that returns a single value
SELECT Customers.customerID from Customers WHERE fname = @fname AND lname = @lname;
-- Get inventoryID based on inventoryID -> Better as Function
SELECT Inventories.inventoryID from Inventories WHERE name = @inventoryName;
-- Get all orders for a particular customer by name
SELECT Orders.orderID FROM Orders INNER JOIN 
Customers ON Orders.customerID = Customers.customerID
WHERE (Customers.fname = @fname AND Customers.lname = @lname);
-- Get productID based on product name -> Better as a function
SELECT Products.productID from Products WHERE name = @productName;
-- Get all products in a given order
SELECT Products.name as Product, OrderProducts.quantity FROM OrderProducts 
INNER JOIN Products on Products.productID = OrderProducts.productID
ORDER BY Product;    
-- Get all products in a given order with inventory location
SELECT Products.name as Product, ProductInventories.quantity FROM Products 
INNER JOIN ProductInventories on Products.productID = ProductInventories.productID
INNER JOIN Inventories on ProductInventories.inventoryID = Inventories.inventoryID
WHERE ProductInventories.inventoryID = @inventoryID;


----------------------------------------------------------------------------
-- INSERT QUERIES
----------------------------------------------------------------------------


-- Insert a new customer
INSERT INTO Customers (fName, lName, email, phone) VALUES
(@fName, @lName, @email, @phone);
-- Insert a new order for a customer
INSERT INTO Orders (customerID, pointsUsed) VALUES
(@customerID, @pointsUsed);
-- Insert a new product into an order
INSERT INTO OrderProducts (orderID, productID, quantity, inventoryID) VALUES
(@orderID, @productID, @quantity, @inventoryID);
-- Insert a  new inventory
INSERT INTO Inventories (name, atStore) VALUES
(@name, @atStore);
-- Insert a new product
INSERT INTO Products (name, currentPrice) VALUES
(@name, @currentPrice);
--Insert a new ProductInventory entry (associating a product with an inventory and quantity)
INSERT INTO ProductInventories (productID, inventoryID, quantity) VALUES
(@productID, @inventoryID, @quantity);


------------------------------------------------------------------------
-- UPDATE QUERIES
-------------------------------------------------------------------------


-- CUSTOMER UPDATE QUERIES
-- Update a customer's information
UPDATE Customers SET fName = @fName, lName = @lName, email = @email, phone = @phone WHERE customerID = @customerIDFromProcedure;
-- Update a Customers points by adding
UPDATE Customers SET points = (points + @points) WHERE customerID = @customerIDFromProcedure;
-- Update a customers last purchase date
UPDATE Customers SET lastPurchase = CURRENT_TIMESTAMP WHERE customerID = @customerIDFromProcedure;

-- PRODUCT UPDATE QUERIES
-- Update a product's price
UPDATE Products SET currentPrice = @currentPrice WHERE productID = @productIDFromProcedure;
-- Update a product's name
UPDATE Products SET name = @name WHERE productID = @productIDFromProcedure;

-- INVENTORY UPDATE QUERIES
-- Update an inventory's name and atStore status
UPDATE Inventories SET name = @name, atStore = @atStore WHERE inventoryID = @inventoryIDFromProcedure;
-- Update a product's quantity in an inventory
UPDATE ProductInventories SET quantity = @quantity WHERE productID = @productIDFromProcedure AND inventoryID = @inventoryIDFromProcedure;
-- Update a product's quantity in an inventory by adding to the existing quantity (eg feeding 3 to increase inventory by 3)
UPDATE ProductInventories SET quantity = quantity + @quantity WHERE productID = @productIDFromProcedure AND inventoryID = @inventoryIDFromProcedure;

-- PRODUCT INVENTORY UPDATE QUERIES
-- Update a product's quantity in an inventory
UPDATE ProductInventories SET quantity = @quantity WHERE productID = @productIDFromProcedure AND inventoryID = @inventoryIDFromProcedure;
-- Update a product's quantity in an inventory by adding 
UPDATE ProductInventories SET quantity = quantity + @quantity WHERE productID = @productIDFromProcedure AND inventoryID = @inventoryIDFromProcedure;
-- Update a product's inventory location (by changing the inventoryID associated with that product)
UPDATE ProductInventories SET inventoryID = @inventoryID WHERE productID = @productIDFromProcedure AND inventoryID = @inventoryIDFromProcedure;
-- Update a product's inventory location and quantity
UPDATE ProductInventories SET inventoryID = @inventoryID, quantity = @quantity WHERE productID = @productIDFromProcedure AND inventoryID = @inventoryIDFromProcedure;
-- Update the product associated with a given inventory entry (rare use)
UPDATE ProductInventories SET productID = @productID WHERE productID = @productIDFromProcedure AND inventoryID = @inventoryIDFromProcedure;

-- ORDER UPDATE QUERIES
-- Update an order's points used
UPDATE Orders SET pointsUsed = @pointsUsed WHERE orderID = @orderIDFromProcedure;
-- Update an order's customer
UPDATE Orders SET customerID = @customerID WHERE orderID = @orderIDFromProcedure;
-- Update an order's date
UPDATE Orders SET orderDate = @orderDate WHERE orderID = @orderIDFromProcedure;
-- Update all of an orders attributes
UPDATE Orders SET customerID = @customerID, orderDate = @orderDate, pointsUsed = @pointsUsed WHERE orderID = @orderIDFromProcedure;

-- ORDER PRODUCT UPDATE QUERIES
-- Update the quantity of a product in an order
UPDATE OrderProducts SET quantity = @quantity WHERE orderItemID = @orderItemIDFromProcedure;
-- Update the product associated with an order item
UPDATE OrderProducts SET productID = @productID WHERE orderItemID = @orderItemIDFromProcedure;
-- Update the inventory associated with an order item
UPDATE OrderProducts SET inventoryID = @inventoryID WHERE orderItemID = @orderItemIDFromProcedure;
-- Update the order associated with an order item
UPDATE OrderProducts SET orderID = @orderID WHERE orderItemID = @orderItemIDFromProcedure;
-- Update all attributes of an order item
UPDATE OrderProducts SET orderID = @orderID, productID = @productID, quantity = @quantity, inventoryID = @inventoryID WHERE orderItemID = @orderItemIDFromProcedure;


-------------------------------------------------------------------------------
-- DELETE QUERIES
-------------------------------------------------------------------------------


-- Delete a customer (RESTRICT prevents deletion if this person has orders)
DELETE FROM Customers WHERE customerID = @customerIDFromProcedure;
-- Delete an order (CASCADE will also delete all associated order item entries)
DELETE FROM Orders WHERE orderID = @orderIDFromProcedure;
-- Delete an order item (no restrictions apply)
DELETE FROM OrderProducts WHERE orderItemID = @orderItemIDFromProcedure;
-- Delete a product (RESTRICT prevents deletion if this product is in inventory or is a part of any orders
DELETE FROM Products WHERE productID = @productIDFromProcedure;
-- Delete an inventory (RESTRICT prevents deletion if this inventory has any products/orders pulling from it)
DELETE FROM Inventories WHERE inventoryID = @inventoryIDFromProcedure;
-- Delete a product inventory entry (No restrictions apply)
DELETE FROM ProductInventories WHERE productID = @productIDFromProcedure AND inventoryID = @inventoryIDFromProcedure;