# Dataset Description

##  Overview
This Online Retail II data set contains all the transactions occurring for a UK-based and registered, non-store online retail between 01/12/2009 and 09/12/2011. The company mainly sells unique all-occasion gift-ware. Many customers of the company are wholesalers. The dataset is then used to build the Power BI portfolio dashboard. The primary goal is to analyze revenue trends and customer retention, best selling products...

* **Source:** https://archive.ics.uci.edu/dataset/502/online+retail+ii
* **Size:** 2 tables, 1,067,371 rows
* **Time Range:** between 01/12/2009 and 09/12/2011.

InvoiceNo: Invoice number. Nominal. A 6-digit integral number uniquely assigned to each transaction. If this code starts with the letter 'c', it indicates a cancellation. 
StockCode: Product (item) code. Nominal. A 5-digit integral number uniquely assigned to each distinct product. 
Description: Product (item) name. Nominal. 
Quantity: The quantities of each product (item) per transaction. Numeric.	
InvoiceDate: Invice date and time. Numeric. The day and time when a transaction was generated. 
UnitPrice: Unit price. Numeric. Product price per unit in sterling (Â£). 
CustomerID: Customer number. Nominal. A 5-digit integral number uniquely assigned to each customer. 
Country: Country name. Nominal. The name of the country where a customer resides.

## Data Cleaning Steps
Before data was imported to power bi, the data was cleaned using sql queries 

## Key Queries
# YearOverYear
'''
WITH YearlySpend AS
(
	SELECT
		Year, SUM(TotalSpend) Revenue
	FROM
		Online_All_Tables
	WHERE
		Invoice NOT LIKE '%c%' 
	GROUP BY
		Year
)

SELECT
	Year, Revenue, 
	ROUND((Revenue - LAG(Revenue) OVER (ORDER BY Year)) * 100 /
	LAG(Revenue) OVER (ORDER BY Year), 2) YoY_Percent
FROM
	YearlySpend
ORDER BY
	Year
'''

# Repeat Customer Rate
'''
WITH CustomerOrderCount AS 
(
    SELECT 
        CustomerID, 
        COUNT(DISTINCT Invoice) AS TotalInvoices
    FROM Online_All_Tables
    WHERE CustomerID IS NOT NULL 
      AND Invoice NOT LIKE '%C%'
    GROUP BY CustomerID
)

SELECT 
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    SUM(CASE WHEN TotalInvoices > 1 THEN 1 ELSE 0 END) AS RepeatCustomerCount,
    CAST(SUM(CASE WHEN TotalInvoices > 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(DISTINCT CustomerID) AS RepeatCustomerRate
FROM CustomerOrderCount;
'''
