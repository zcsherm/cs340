-- DML QUERIES
-- Group 39
-- Zachary Sherman
-- Justin Barreras

------------------------------------------------------------------------
-- VIEW QUERIES
-------------------------------------------------------------------------


-- GENERIC VIEWS (ALL VALUES)
DROP VIEW IF EXISTS v_all_products;
CREATE VIEW v_all_products AS 
SELECT * FROM Products;

DROP VIEW IF EXISTS v_all_inventories;
CREATE VIEW v_all_inventories AS
SELECT * FROM Inventories;

DROP VIEW IF EXISTS v_all_product_inventories;
CREATE VIEW v_all_product_inventories AS
SELECT * FROM ProductInventories;

DROP VIEW IF EXISTS v_all_customers;
CREATE VIEW v_all_customers AS
SELECT * FROM Customers;

DROP VIEW IF EXISTS v_all_orders;
CREATE VIEW v_all_orders AS
SELECT * FROM Orders;

DROP VIEW IF EXISTS v_all_order_products;
CREATE VIEW v_all_order_products AS
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
DROP FUNCTION IF EXISTS fn_get_customer_id_by_name;
DELIMITER //
CREATE FUNCTION fn_get_customer_id_by_name(
    IN _fName VARCHAR(255),
    IN _lName VARCHAR(255)
)
RETURNS INT
DETERMINISTIC
COMMENT 'Returns a customerID based on the customers first and last name. Assumes no duplicate NAMES'
BEGIN
    DECLARE _customerID INT;
    IF EXISTS (SELECT 2 FROM Customers WHERE fname = _fName AND lname = _lName) THEN
        RETURN NULL; -- Return NULL if there are multiple customers with the same name
    END IF;
    SELECT customerID INTO _customerID FROM Customers WHERE fname = _fName AND lname = _lName;
    RETURN _customerID;
END //
DELIMITER ;

-- Get inventoryID based on inventoryID -> Better as Function
DROP FUNCTION IF EXISTS fn_get_inventory_id_by_name;
DELIMITER //
CREATE FUNCTION fn_get_inventory_id_by_name(
    IN _inventoryName VARCHAR(255)
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE _inventoryID INT;
    SELECT inventoryID INTO _inventoryID FROM Inventories WHERE name = _inventoryName;
    RETURN _inventoryID;
END //
DELIMITER ;

-- Get all orders for a particular customer by name
DROP VIEW IF EXISTS v_orders_by_customer_name;
CREATE VIEW v_orders_by_customer_name AS
SELECT Orders.orderID FROM Orders INNER JOIN 
Customers ON Orders.customerID = Customers.customerID
WHERE (Customers.fname = @fname AND Customers.lname = @lname);

-- Get productID based on product name -> Better as a function
DROP FUNCTION IF EXISTS fn_get_product_id_by_name;
DELIMITER //
CREATE FUNCTION fn_get_product_id_by_name(
    IN _productName VARCHAR(255)
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE _productID INT;
    SELECT productID INTO _productID FROM Products WHERE name = _productName;
    RETURN _productID;
END //
DELIMITER ;

-- Get all products in a given order
DROP VIEW IF EXISTS v_products_by_order;
CREATE VIEW v_products_by_order AS
SELECT Products.name as Product, OrderProducts.quantity,(OrderProducts.quantity * Products.price) as Price FROM OrderProducts 
INNER JOIN Products on Products.productID = OrderProducts.productID
ORDER BY Product;

-- Get all products in a given order with inventory location
DROP PROCEDURE IF EXISTS sp_get_products_by_order_with_inventory;
DELIMITER //
CREATE PROCEDURE sp_get_products_by_order_with_inventory(
    IN _orderID INT
)
COMMENT 'Gets all products in a given order with inventory location'
BEGIN
        SELECT Products.name as Product, OrderProducts.quantity, Inventories.name as Inventory FROM OrderProducts 
        INNER JOIN Products on Products.productID = OrderProducts.productID
        INNER JOIN Inventories on Inventories.inventoryID = OrderProducts.inventoryID
        WHERE OrderProducts.orderID = _orderID;
END // 
DELIMITER ;
 

-- Get all orders in a given day
DROP PROCEDURE IF EXISTS sp_get_orders_by_date;
DELIMITER //
CREATE PROCEDURE sp_get_orders_by_date(
    IN _orderDate DATE
)
COMMENT 'Gets all orders in a given day'
BEGIN
    SELECT Orders.orderID, CONCAT(Customers.fName,' ',Customers.lName) AS Name, Orders.pointsUsed FROM Orders INNER JOIN Customers ON Orders.customerID = Customers.customerID
    WHERE Orders.orderDate = _orderDate;
END //
DELIMITER ;

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
-- Get total quantity of a product ordered by productID (sum of quantity for all order items with a given productID)

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
    IF EXISTS (SELECT 1 FROM ProductInventories WHERE productID = _productID AND inventoryID = _inventoryID) THEN
        SELECT 'Error: Product inventory entry already exists. Use update procedure to change quantity or inventory location.' AS Result;
    ELSE
        INSERT INTO ProductInventories (productID, inventoryID, quantity) VALUES
        (_productID, _inventoryID, _quantity);
    END IF;
END //
DELIMITER ;


------------------------------------------------------------------------
-- UPDATE QUERIES
-------------------------------------------------------------------------


-- CUSTOMER UPDATE QUERIES
-- Update a customer's information
DROP PROCEDURE IF EXISTS sp_update_customer_info;
DELIMITER //
CREATE PROCEDURE sp_update_customer_info(
    IN _customerID INT,
    IN _fName VARCHAR(255),
    IN _lName VARCHAR(255),
    IN _email VARCHAR(255),
    IN _phone VARCHAR(15)
)
COMMENT 'Updates a customers information'
BEGIN
    UPDATE Customers SET fName = _fName, lName = _lName, email = _email, phone = _phone WHERE customerID = _customerID;
END //
DELIMITER ;

-- Update a Customers points by adding
DROP PROCEDURE IF EXISTS sp_update_customer_points;
DELIMITER //
CREATE PROCEDURE sp_update_customer_points(
    IN _customerID INT,
    IN _points INT
)
COMMENT 'Updates a customers points by adding to the existing points'
BEGIN
    UPDATE Customers SET points = (points + _points) WHERE customerID = _customerID;
END //
DELIMITER ;

-- Update a customers last purchase date
DROP PROCEDURE IF EXISTS sp_update_customer_last_purchase;
DELIMITER //
CREATE PROCEDURE sp_update_customer_last_purchase(
    IN _customerID INT
)
COMMENT 'Updates a customers last purchase date to the current timestamp'
BEGIN
    UPDATE Customers SET lastPurchase = CURRENT_TIMESTAMP WHERE customerID = _customerID;
END //
DELIMITER ;

-- PRODUCT UPDATE QUERIES
-- Update a product's price
DROP PROCEDURE IF EXISTS sp_update_product_price;
DELIMITER //
CREATE PROCEDURE sp_update_product_price(
    IN _productID INT,
    IN _currentPrice DECIMAL(12,2)
)
COMMENT "Updates a product's price"
BEGIN
    UPDATE Products SET currentPrice = _currentPrice WHERE productID = _productID;
END //
DELIMITER ;

-- Update a product's name
DROP PROCEDURE IF EXISTS sp_update_product_name;
DELIMITER //
CREATE PROCEDURE sp_update_product_name(
    IN _productID INT,
    IN _name VARCHAR(255)
)
COMMENT "Updates a product's name"
BEGIN
    UPDATE Products SET name = _name WHERE productID = _productID;
END //
DELIMITER ;

-- INVENTORY UPDATE QUERIES
-- Update an inventory's name and atStore status
DROP PROCEDURE IF EXISTS sp_update_inventory;
DELIMITER //
CREATE PROCEDURE sp_update_inventory(
    IN _inventoryID INT,
    IN _name VARCHAR(255),
    IN _atStore BOOLEAN
)
COMMENT "Updates an inventory's name and atStore status"
BEGIN
    UPDATE Inventories SET name = _name, atStore = _atStore WHERE inventoryID = _inventoryID;
END //
DELIMITER ;

-- Update a product's quantity in an inventory
DROP PROCEDURE IF EXISTS sp_update_product_inventory_quantity;
DELIMITER //
CREATE PROCEDURE sp_update_product_inventory_quantity(
    IN _productID INT,
    IN _inventoryID INT,
    IN _quantity INT
)
COMMENT "Updates a product's quantity in an inventory"
BEGIN
    UPDATE ProductInventories SET quantity = _quantity WHERE productID = _productID AND inventoryID = _inventoryID;
END //
DELIMITER ;

-- Update a product's quantity in an inventory by adding to the existing quantity (eg feeding 3 to increase inventory by 3)
DROP PROCEDURE IF EXISTS sp_add_product_inventory_quantity;
DELIMITER //
CREATE PROCEDURE sp_add_product_inventory_quantity(
    IN _productID INT,
    IN _inventoryID INT,
    IN _quantity INT
)
COMMENT "Adds to a product's quantity in an inventory"
BEGIN
    UPDATE ProductInventories SET quantity = quantity + _quantity WHERE productID = _productID AND inventoryID = _inventoryID;
END //
DELIMITER ;


-- PRODUCT INVENTORY UPDATE QUERIES
-- Update a product's inventory location (by changing the inventoryID associated with that product)
DROP IF EXISTS sp_update_product_inventory_location;
DELIMITER //
CREATE PROCEDURE sp_update_product_inventory_location(
    IN _productID INT,
    IN _inventoryID INT,
    IN _inventoryIDNew INT
)
COMMENT "Updates a product's inventory location"
BEGIN
    UPDATE ProductInventories SET inventoryID = _inventoryIDNew WHERE productID = _productID AND inventoryID = _inventoryID;
END //
DELIMITER ;

-- ORDER UPDATE QUERIES
-- Update an order's points used
DROP IF EXISTS sp_update_order_points_used;
DELIMITER //
CREATE PROCEDURE sp_update_order_points_used(
    IN _orderID INT,
    IN _pointsUsed INT
)
COMMENT "Updates an order's points used"
BEGIN
     UPDATE Orders SET pointsUsed = _pointsUsed WHERE orderID = _orderID;
END //
DELIMITER ;

-- Update an order's customer
DROP IF EXISTS sp_update_order_customer;
DELIMITER //
CREATE PROCEDURE sp_update_order_customer(
    IN _orderID INT,
    IN _customerID INT
)
COMMENT "Updates an order's customer"
BEGIN
     UPDATE Orders SET customerID = _customerID WHERE orderID = _orderID;
END //
DELIMITER ;

-- Update an order's date
DROP IF EXISTS sp_update_order_date;
DELIMITER //
CREATE PROCEDURE sp_update_order_date(
    IN _orderID INT,
    IN _orderDate DATE
)
COMMENT "Updates an order's date"
BEGIN
     UPDATE Orders SET orderDate = _orderDate WHERE orderID = _orderID;
END //
DELIMITER ;

-- Update all of an orders attributes
DROP IF EXISTS sp_update_order;
DELIMITER //
CREATE PROCEDURE sp_update_order(
    IN _orderID INT,
    IN _customerID INT,
    IN _orderDate DATE,
    IN _pointsUsed INT
)
COMMENT "Updates all attributes of an order"
BEGIN
    UPDATE Orders SET customerID = _customerID, orderDate = _orderDate, pointsUsed = _pointsUsed WHERE orderID = _orderID;
END //
DELIMITER ;

-- ORDER PRODUCT UPDATE QUERIES
-- Update the quantity of a product in an order
DROP PROCEDURE IF EXISTS sp_update_order_product_quantity;
DELIMITER //
CREATE PROCEDURE sp_update_order_product_quantity(
    IN _orderItemID INT,
    IN _quantity INT
)
COMMENT "Updates the quantity of a product in an order"
BEGIN
    UPDATE OrderProducts SET quantity = _quantity WHERE orderItemID = _orderItemID;
END //
DELIMITER ;

-- Update the product associated with an order item
DROP PROCEDURE IF EXISTS sp_update_order_product;
DELIMITER //
CREATE PROCEDURE sp_update_order_product(
    IN _orderItemID INT,
    IN _productID INT
)
COMMENT "Updates the product associated with an order item"
BEGIN
    UPDATE OrderProducts SET productID = _productID WHERE orderItemID = _orderItemID;
END //
DELIMITER ;

-- Update the inventory associated with an order item
DROP PROCEDURE IF EXISTS sp_update_order_inventory;
DELIMITER //
CREATE PROCEDURE sp_update_order_inventory(
    IN _orderItemID INT,
    IN _inventoryID INT
)
COMMENT "Updates the inventory associated with an order item"
BEGIN
    UPDATE OrderProducts SET inventoryID = _inventoryID WHERE orderItemID = _orderItemID;
END //
DELIMITER ;

-- Update the order associated with an order item
DROP PROCEDURE IF EXISTS sp_update_order_product_order;
DELIMITER //
CREATE PROCEDURE sp_update_order_product_order(
    IN _orderItemID INT,
    IN _orderID INT
)
COMMENT "Updates the order associated with an order item"
BEGIN 
    UPDATE OrderProducts SET orderID = _orderID WHERE orderItemID = _orderItemID;
END //
DELIMITER ;

-- Update all attributes of an order item
DROP PROCEDURE IF EXISTS sp_update_order_item;
DELIMITER //
CREATE PROCEDURE sp_update_order_item(
    IN _orderItemID INT,
    IN _orderID INT,
    IN _productID INT,
    IN _quantity INT,
    IN _inventoryID INT
)
COMMENT "Updates all attributes of an order item"
BEGIN
    UPDATE OrderProducts SET orderID = _orderID, productID = _productID, quantity = _quantity, inventoryID = _inventoryID WHERE orderItemID = _orderItemID;
END //
DELIMITER ;


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
