SELECT Customers.CustomerName, Invoices.InvoiceID, SUM(InvoiceDetails.LineTotal) AS LineSum
FROM Customers
INNER JOIN Invoices ON Invoices.CustomerID = Customers.CustomersID
INNER JOIN InvoiceDetails ON InvoiceDetails.InvoiceID = Invoices.InvoiceID
GROUP BY Invoices.InvoiceID
ORDER BY LineSum DESC;
