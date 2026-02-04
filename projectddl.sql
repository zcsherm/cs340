
CREATE OR REPLACE TABLE Products  (
    productID int NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL UNIQUE,
    currentPrice decimal(12,2) NOT NULL CHECK (price > 0),
    PRIMARY KEY (productID),
);

CREATE OR REPLACE TABLE Inventories (
    inventoryID int NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    atStore boolean NOT NULL,
    PRIMARY KEY (inventoryID)
);

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

CREATE OR REPLACE TABLE Customers (
    customerID int NOT NULL AUTO_INCREMENT,
    fName varchar(255) NOT NULL,
    lName varchar(255) NOT NULL,
    email varchar(255) NOT NULL UNIQUE,
    phone varchar(15),
    points int, NOT NULL DEFAULT 0 CHECK (points >= 0),
    lastPurchase DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customerID)
);

CREATE OR REPLACE TABLE Orders (
    orderID int NOT NULL AUTO_INCREMENT,
    customerID int DEFAULT NULL,
    orderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pointsUsed int default 0,
    FOREIGN KEY (customerID) REFERENCES Customers(customerID)
    ON DELETE RESTRICT,
    PRIMARY KEY (orderID)
);

CREATE OR REPLACE TABLE OrderItems (
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
