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
DROP VIEW IF EXISTS v_products_and_prices;
CREATE VIEW v_products_and_prices AS
SELECT name AS product, currentPrice AS price FROM Products;

--display all inventories available
DROP VIEW IF EXISTS v_inventories;
CREATE VIEW v_inventories AS
SELECT name, atStore FROM Inventories;

-- Display products with their respective locations and quantities
DROP VIEW IF EXISTS v_products_and_locations;
CREATE VIEW v_products_and_locations AS
SELECT Products.name as product, Inventories.name as location, ProductInventories.quantity
FROM Products INNER JOIN ProductInventories ON Products.productID = ProductInventories.productID
INNER JOIN Inventories ON ProductInventories.inventoryID = Inventories.inventoryID
ORDER BY product;

-- Display all customers
DROP VIEW IF EXISTS v_customers;
CREATE VIEW v_customers AS
SELECT fName as First, lname as Last, email
FROM Customers;

-- Display dollar value of an orderitem entry
DROP VIEW IF EXISTS v_order_item_totals;
CREATE VIEW v_order_item_totals AS
SELECT OrderProducts.orderID AS "Order Number", 
SUM(OrderProducts.quantity * Products.currentPrice) AS itemTotal FROM OrderProducts INNER JOIN Products 
WHERE OrderProducts.productID = Products.productID GROUP BY orderID;

-- Display each order and the sum of that order along with the customer who made the order
DROP VIEW IF EXISTS v_orders_and_totals;
CREATE VIEW v_orders_and_totals AS
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
DROP VIEW IF EXISTS v_order_products_details;
CREATE VIEW v_order_products_details AS
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
-- Get all orders in a given day
----------------------------------------------------------------------------
-- FETCH FUNCTIONS
----------------------------------------------------------------------------

-- Get a custoer's ID by their name(assuming no duplicates)
-- Get a customer's ID by their email)
-- Get a customer's points by customerID
-- Get a customers name by their ID
-- Get a customer's email by their ID
-- Get a customer's phone number by their ID
-- Get a customer's last purchase date by their ID

-- Get a product ID by its name
-- Get a product's price by productID

-- Get an inventory ID by its name
-- Get the quantity of a product in a given inventory

-- Get all orders by customerID
-- Get all products by orderID

-- Get the item cost for an order item by orderItemID
-- Get the total cost of an order by orderID
-- Get the total cost of an order by customerID (sum of all orders for a given customer)
----------------------------------------------------------------------------
-- INSERT QUERIES
----------------------------------------------------------------------------

-- Insert a new customer
DROP PROCEDURE IF EXISTS sp_insert_customer;
DELIMITER //
CREATE PROCEDURE sp_insert_customer(
    IN _fName VARCHAR(255),
    IN _lName VARCHAR(255),
    IN _email VARCHAR(255),
    IN _phone VARCHAR(15),
    OUT _customerID INT
)
COMMENT 'Inserts a new customer and gets the new id'
BEGIN
    INSERT INTO Customers (fName, lName, email, phone) VALUES
    (_fName, _lName, _email, _phone);
    SET _customerID = LAST_INSERT_ID();
END //
DELIMITER ;

-- Insert a new order for a customer
DROP PROCEDURE IF EXISTS sp_insert_order;
DELIMITER //
CREATE PROCEDURE sp_insert_order(
    IN _customerID INT,
    IN _pointsUsed INT,
    OUT _orderID INT
)
COMMENT 'Inserts a new order for a customer and gets the new id'
BEGIN
    INSERT INTO Orders (customerID, pointsUsed) VALUES
    (_customerID, _pointsUsed);
    SET _orderID = LAST_INSERT_ID();
END //
DELIMITER ;

-- Insert a new product into an order
DROP PROCEDURE IF EXISTS sp_insert_order_product;
DELIMITER //
CREATE PROCEDURE sp_insert_order_product(
    IN _orderID INT,
    IN _productID INT,
    IN _quantity INT,
    IN _inventoryID INT
)
COMMENT 'Inserts a new product into an order'
BEGIN
    INSERT INTO OrderProducts (orderID, productID, quantity, inventoryID) VALUES
    (_orderID, _productID, _quantity, _inventoryID);
END //
DELIMITER ;

-- Insert a  new inventory
DROP PROCEDURE IF EXISTS sp_insert_inventory;
DELIMITER //
CREATE PROCEDURE sp_insert_inventory(
    IN _name VARCHAR(255),
    IN _atStore BOOLEAN,
    OUT _inventoryID INT
)
COMMENT 'Inserts a new inventory and gets the new id'
BEGIN    
    INSERT INTO Inventories (name, atStore) VALUES
    (_name, _atStore);
    SET _inventoryID = LAST_INSERT_ID();
END //
DELIMITER ;

-- Insert a new product
DROP PROCEDURE IF EXISTS sp_insert_product;
DELIMITER //
CREATE PROCEDURE sp_insert_product(
    IN _name VARCHAR(255),
    IN _currentPrice DECIMAL(12,2),
    OUT _productID INT
)
COMMENT 'Inserts a new product and gets the new id'
BEGIN
    INSERT INTO Products (name, currentPrice) VALUES
    (_name, _currentPrice);
    SET _productID = LAST_INSERT_ID();
END //
DELIMITER ;

--Insert a new ProductInventory entry (associating a product with an inventory and quantity)
DROP PROCEDURE IF EXISTS sp_insert_product_inventory;
DELIMITER //
CREATE PROCEDURE sp_insert_product_inventory(
    IN _productID INT,
    IN _inventoryID INT,
    IN _quantity INT
)
COMMENT 'Inserts a new product inventory entry associating a product with an inventory and quantity'
BEGIN  
INSERT INTO ProductInventories (productID, inventoryID, quantity) VALUES
    (_productID, _inventoryID, _quantity);
END //
DELIMITER ;


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
DELIMITER //
DROP PROCEDURE IF EXISTS sp_delete_customer;
CREATE PROCEDURE sp_delete_customer(
    IN _customerID INT
)
COMMENT 'Deletes a customer if they have no orders'
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Handle the error (e.g., log it, return a message, etc.)
        ROLLBACK;
        SELECT 'Error: Cannot delete customer with existing orders.' AS Result;
    END;
    START TRANSACTION;
    IF EXISTS (SELECT 1 FROM Customers WHERE customerID = _customerID) THEN
        DELETE FROM Customers WHERE customerID = _customerID;
        SELECT 'Customer deleted successfully.' AS Result;
    ELSE
        SELECT 'Error: Customer not found.' AS Result;
    END IF;
    COMMIT;
END //
DELIMITER ;

-- Delete a customer and all of their orders (CASCADE will also delete all associated orders and order items)
DELIMITER //
DROP PROCEDURE IF EXISTS sp_delete_customer_and_orders;
CREATE PROCEDURE sp_delete_customer_and_orders(
    IN _customerID INT
)
COMMENT 'Deletes a customer and all associated orders and order items. BYPASSES RESTRICT CONSTRAINTS, USE WITH CAUTION '
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Handle the error (e.g., log it, return a message, etc.)
        ROLLBACK;
        SELECT 'Error: Cannot delete customer.' AS Result;
    END;
    START TRANSACTION;
    -- First delete all the order items if they exist
    IF EXISTS (SELECT 1 FROM Orders WHERE customerID = _customerID) THEN
        DELETE FROM Orders WHERE customerID = _customerID;
    END IF;
    -- Then delete the customer if they exist
    IF EXISTS (SELECT 1 FROM Customers WHERE customerID = _customerID) THEN
        DELETE FROM Customers WHERE customerID = _customerID;
        SELECT 'Customer deleted successfully.' AS Result;
    ELSE
        SELECT 'Error: Customer not found.' AS Result;
    END IF;
    COMMIT;
END //
DELIMITER ;

-- Delete an order (CASCADE will also delete all associated order item entries)
DELIMITER //
DROP PROCEDURE IF EXISTS sp_delete_order;
CREATE PROCEDURE sp_delete_order(
    IN _orderID INT
)
COMMENT 'Deletes an order and all associated order items'
BEGIN
    IF EXISTS (SELECT 1 FROM Orders WHERE orderID = _orderID) THEN
        DELETE FROM Orders WHERE orderID = _orderID;
        SELECT 'Order deleted successfully.' AS Result;
    ELSE
        SELECT 'Error: Order not found.' AS Result;
    END IF;
END //
DELIMITER ;

-- Delete an order item (no restrictions apply)
DELIMITER //
DROP PROCEDURE IF EXISTS sp_delete_order_item;
CREATE PROCEDURE sp_delete_order_item(
    IN _orderItemID INT
)
COMMENT 'Deletes an order item'
BEGIN
    IF EXISTS (SELECT 1 FROM OrderProducts WHERE orderItemID = _orderItemID) THEN
        DELETE FROM OrderProducts WHERE orderItemID = _orderItemID;
        SELECT 'Order item deleted successfully.' AS Result;
    ELSE
        SELECT 'Error: Order item not found.' AS Result;
    END IF; 
END //
DELIMITER ;

-- Delete a product (RESTRICT prevents deletion if this product is in inventory or is a part of any orders
DELIMITER //
DROP PROCEDURE IF EXISTS sp_delete_product;
CREATE PROCEDURE sp_delete_product(
    IN _productID INT
)
COMMENT 'Deletes a product if it is not in any inventory or orders'
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Handle the error (e.g., log it, return a message, etc.)
        ROLLBACK;
        SELECT 'Error: Cannot delete product with existing inventory or orders.' AS Result;
    END;
    BEGIN TRANSACTION;
    IF EXISTS (SELECT 1 FROM Products WHERE productID = _productID) THEN
        DELETE FROM Products WHERE productID = _productID;
        SELECT 'Product deleted successfully.' AS Result;
    ELSE
        SELECT 'Error: Product not found.' AS Result;
    END IF;
    COMMIT;
END //
DELIMITER ;

-- Delete a product and all all associated inventories and orders
DELIMITER //
DROP PROCEDURE IF EXISTS sp_delete_product_and_associations;
CREATE PROCEDURE sp_delete_product_and_associations(
    IN _productID INT
)
COMMENT 'Deletes a product and all associated inventory entries and order items. BYPASSES RESTRICT CONSTRAINTS, USE WITH CAUTION '
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Handle the error (e.g., log it, return a message, etc.)
        ROLLBACK;
        SELECT 'Error: Cannot delete product.' AS Result;
    END;
    START TRANSACTION;
    -- First delete all the order items if they exist
    IF EXISTS (SELECT 1 FROM OrderProducts WHERE productID = _productID) THEN
        DELETE FROM OrderProducts WHERE productID = _productID;
    END IF;
    -- Then delete all inventory entries if they exist
    IF EXISTS (SELECT 1 FROM ProductInventories WHERE productID = _productID) THEN
        DELETE FROM ProductInventories WHERE productID = _productID;
    END IF;
    -- Then delete the product if it exists
    IF EXISTS (SELECT 1 FROM Products WHERE productID = _productID) THEN
        DELETE FROM Products WHERE productID = _productID;
        SELECT 'Product and all associations deleted successfully.' AS Result;
    ELSE
        SELECT 'Error: Product not found.' AS Result;
    END IF;
    COMMIT;
END //
DELIMITER ;

-- Delete an inventory (RESTRICT prevents deletion if this inventory has any products/orders pulling from it)
DELIMITER //
DROP PROCEDURE IF EXISTS sp_delete_inventory;
CREATE PROCEDURE sp_delete_inventory(
    IN _inventoryID INT
)
COMMENT 'Deletes an inventory if it has no products or orders'
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Handle the error (e.g., log it, return a message, etc.) 
        ROLLBACK;
        SELECT 'Error: Cannot delete inventory with existing products or orders.' AS Result;
    END;
    START TRANSACTION;
    IF EXISTS (SELECT 1 FROM Inventories WHERE inventoryID = _inventoryID) THEN
        DELETE FROM Inventories WHERE inventoryID = _inventoryID;
        SELECT 'Inventory deleted successfully.' AS Result;
    ELSE
        SELECT 'Error: Inventory not found.' AS Result;
    END IF;
    COMMIT;
END //
DELIMITER ;

-- Delete a product inventory entry (No restrictions apply)
DELIMITER //
DROP PROCEDURE IF EXISTS sp_delete_product_inventory;
CREATE PROCEDURE sp_delete_product_inventory(
    IN _productID INT,  
    IN _inventoryID INT
)
COMMENT 'Deletes a product inventory entry'
BEGIN
    IF EXISTS (SELECT 1 FROM ProductInventories WHERE productID = _productID AND inventoryID = _inventoryID) THEN
        DELETE FROM ProductInventories WHERE productID = _productID AND inventoryID = _inventoryID;
        SELECT 'Product inventory entry deleted successfully.' AS Result;
    ELSE
        SELECT 'Error: Product inventory entry not found.' AS Result;
    END IF;    
END //
DELIMITER ;

-- DELETE an inventory and all associated product inventory entries (CASCADE will delete all associated product inventory entries but RESTRICT will prevent deletion if there are any orders pulling from this inventory)
DELIMITER //
DROP PROCEDURE IF EXISTS sp_delete_inventory_and_associations;
CREATE PROCEDURE sp_delete_inventory_and_associations(
    IN _inventoryID INT
)
COMMENT 'Deletes an inventory and all associated product inventory entries. BYPASSES RESTRICT CONSTRAINTS, USE WITH CAUTION '
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Handle the error (e.g., log it, return a message, etc.)
        ROLLBACK;
        SELECT 'Error: Cannot delete inventory.' AS Result;
    END;
    START TRANSACTION;
    -- First delete all the product inventory entries if they exist
    IF EXISTS (SELECT 1 FROM ProductInventories WHERE inventoryID = _inventoryID) THEN
        DELETE FROM ProductInventories WHERE inventoryID = _inventoryID;
    END IF;
    -- Then delete the inventory if it exists
    IF EXISTS (SELECT 1 FROM Inventories WHERE inventoryID = _inventoryID) THEN
        DELETE FROM Inventories WHERE inventoryID = _inventoryID;
        SELECT 'Inventory and all associations deleted successfully.' AS Result;
    ELSE
        SELECT 'Error: Inventory not found.' AS Result;
    END IF;
    COMMIT;
END //
DELIMITER ;
