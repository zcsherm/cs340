CREATE OR REPLACE TABLE Products  (
    productID int NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL UNIQUE,
    currentPrice decimal(12,2) NOT NULL CHECK (currentPrice > 0),
    PRIMARY KEY (productID)
);

CREATE OR REPLACE TABLE Inventories (
    inventoryID int NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    atStore boolean NOT NULL,
    PRIMARY KEY (inventoryID)
);
-- changed quantity name, added restraints for deletes
CREATE OR REPLACE TABLE ProductInventories (
    productInventoryID int NOT NULL AUTO_INCREMENT,
    productID int NOT NULL,
    inventoryID int NOT NULL,
    quantity int NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    PRIMARY KEY (productInventoryID),
    FOREIGN KEY (productID) REFERENCES Products(productID)
    ON DELETE RESTRICT,
    FOREIGN KEY (inventoryID) REFERENCES Inventories(inventoryID)
    ON DELETE RESTRICT
);
-- shortened name fields names, changed points name, added check for positive 
CREATE OR REPLACE TABLE Customers (
    customerID int NOT NULL AUTO_INCREMENT,
    fName varchar(255) NOT NULL,
    lName varchar(255) NOT NULL,
    email varchar(255) NOT NULL UNIQUE,
    phone varchar(15),
    points int NOT NULL DEFAULT 0 CHECK (points >= 0),
    lastPurchase DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customerID)
);
-- Removed orderTotal (calculated value), changed points name
CREATE OR REPLACE TABLE Orders (
    orderID int NOT NULL AUTO_INCREMENT,
    customerID int DEFAULT NULL,
    orderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pointsUsed int NOT NULL default 0,
    FOREIGN KEY (customerID) REFERENCES Customers(customerID)
    ON DELETE RESTRICT,
    PRIMARY KEY (orderID)
);
-- removed unitPrice (calculated value), added delete constraints
CREATE OR REPLACE TABLE OrderProducts (
    orderItemID int NOT NULL AUTO_INCREMENT,
    orderID int NOT NULL,
    productID int NOT NULL,
    quantity int NOT NULL,
    inventoryID int NOT NULL,
    FOREIGN KEY (orderID) REFERENCES Orders(orderID)
    ON DELETE CASCADE,
    FOREIGN KEY (productID) REFERENCES Products(productID)
    ON DELETE RESTRICT,
    FOREIGN KEY (inventoryID) REFERENCES Inventories(inventoryID)
    ON DELETE RESTRICT,
    PRIMARY KEY (orderItemID)
);

-- Insert Default Values for Products
INSERT INTO Products (name, currentPrice)
VALUES 
    ('Raging Goblin', 2.99),
    ('Fossil Booster Box', 49.99),
    ('Rhystic Study', 1.00),
    ('Fog', .23),
    ('WOTC branded playmat', 17.40)
;

-- Insert Default Values for Inventories
INSERT INTO Inventories (name, atStore)
VALUES 
    ('Display', TRUE),
    ('Store Room', TRUE),
    ('On Order', FALSE)
;

-- Insert Default Values for ProductInventories
INSERT INTO ProductInventories (productID, inventoryID, quantity)
VALUES 
    ((SELECT productID FROM Products WHERE name = 'Raging Goblin'), (SELECT inventoryID FROM Inventories WHERE name = 'Display'), 16),
    ((SELECT productID FROM Products WHERE name = 'Fossil Booster Box'), (SELECT inventoryID FROM Inventories WHERE name = 'Store Room'), 3),
    ((SELECT productID FROM Products WHERE name = 'Fog'), (SELECT inventoryID FROM Inventories WHERE name = 'Store Room'), 362),
    ((SELECT productID FROM Products WHERE name = 'Rhystic Study'), (SELECT inventoryID FROM Inventories WHERE name = 'On Order'), 5)    
;
-- Insert Default values for Customers
INSERT INTO Customers (fname, lname, email, phone, points)
VALUES 
    ('Henry', 'Paul', 'hpaul@email.com', NULL, 2000),
    ('Jason', 'Isaacs', 'hizzy@me.net', '555-343-5288', 200),
    ('Monica', 'Isfran', 'spamfolder@yahoo.com', '5554876952', 0),
    ('Mokoto', 'Nagano', 'ninjawarrior@super.gove', NULL, 3000)
;
-- Insert Default values for Orders
INSERT INTO Orders (customerID, pointsUsed)
VALUES 
 ((SELECT customerID FROM Customers WHERE email = 'hpaul@email.com'), 1600),
 ((SELECT customerID FROM Customers WHERE fname = 'Makoto' AND lname = 'Nagano'),0),
 ((SELECT customerID FROM Customers WHERE email = 'hizzy@me.net'), 200),
 ((SELECT customerID FROM Customers WHERE email = 'ninjawarrior@super.gove'), 3000)
;
-- Insert Default values for orderproducts
INSERT INTO OrderProducts (orderID, productID, quantity, inventoryID)
VALUES
    (
    (SELECT Orders.orderID FROM Orders JOIN Customers ON Orders.customerID = Customers.customerID WHERE Customers.email = 'hizzy@me.net'),
    (SELECT productID FROM Products WHERE name = 'Fog'),
    13,
    (SELECT inventoryID FROM Inventories WHERE NAME = 'Store Room')  
    ),
    (
    (SELECT Orders.orderID FROM Orders JOIN Customers ON Orders.customerID = Customers.customerID WHERE Customers.email = 'hpaul@email.com'),
    (SELECT productID FROM Products WHERE name = 'Raging Goblin'),
    1,
    (SELECT inventoryID FROM Inventories WHERE NAME = 'Display')  
    ),
    (
    (SELECT orderID FROM Orders JOIN Customers ON Orders.customerID = Customers.customerID WHERE Customers.email = 'ninjawarrior@super.gove'),
    (SELECT productID FROM Products WHERE name = 'Fossil Booster Box'),
    2,
    (SELECT inventoryID FROM Inventories WHERE NAME = 'Store Room')  
    )
;

SELECT * FROM Products;
SELECT * FROM Inventories;
SELECT * FROM ProductInventories;
SELECT * FROM Orders;
SELECT * FROM Customers;
SELECT * FROM OrderProducts;
