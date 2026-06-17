SELECT DISTINCT*
FROM
	Online_Retail_New..[2009-2010];

  SELECT*
FROM
	Online_Retail_New..2009-2010]
WHERE
	StockCode like '%[a-zA-Z]%' --check if it has alphabet
ORDER BY StockCode ASC;

SELECT DISTINCT*
FROM
	Online_Retail_New..[2010-2011];

SELECT*
FROM
	Online_Retail_New..[2010-2011]
WHERE
	StockCode like '%[a-zA-Z]%' --check if it has alphabet
ORDER BY StockCode ASC;

BEGIN TRANSACTION --Verify cleaning before commit
UPDATE 
	Online_Retail_New..[2009-2010]
SET 
	Invoice = Trim(UPPER(REPLACE(Invoice, 'A', ''))),
	StockCode = NULLIF(TRY_CAST(TRIM(UPPER(StockCode)) AS INT), ''),
	Description = NULLIF(TRIM(UPPER(Description)), ''), --this says trim it, and if result is empty or '', make it null
	Quantity = ABS(TRY_CAST(REPLACE(Quantity, '-','') AS INT)),
	InvoiceDate = TRY_CAST(InvoiceDate AS DATE),
	Price = TRY_CAST(REPLACE(Price, '-', '') AS DECIMAL),
	CustomerID = NULLIF(TRY_CAST(CustomerID AS INT), ''),
	Country = UPPER(Country)
COMMIT;

BEGIN TRANSACTION --Verify cleaning before commit
UPDATE 
	Online_Retail_New..[2010-2011]
SET 
	Invoice = Trim(UPPER(REPLACE(Invoice, 'A', ''))),
	StockCode = NULLIF(TRY_CAST(TRIM(UPPER(StockCode)) AS INT), ''),
	Description = NULLIF(TRIM(UPPER(Description)), ''), --this says trim it, and if result is empty or '', make it null
	Quantity = ABS(TRY_CAST(REPLACE(Quantity, '-','') AS INT)),
	InvoiceDate = TRY_CAST(InvoiceDate AS DATE),
	Price = TRY_CAST(REPLACE(Price, '-', '') AS DECIMAL),
	CustomerID = NULLIF(TRY_CAST(CustomerID AS INT), ''),
	Country = UPPER(Country)
COMMIT;

BEGIN TRANSACTION;
WITH New_Table AS(
	SELECT*, 
	ROW_NUMBER() OVER(PARTITION BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID,
		Country ORDER BY Invoice, StockCode) AS RowNum
	FROM 
		Online_Retail_New..[2009-2010]
		)
DELETE FROM New_Table WHERE RowNum > 1 --REMOVING DUPLICATES
COMMIT;

BEGIN TRANSACTION;
WITH New_Table AS(
	SELECT*, 
	ROW_NUMBER() OVER(PARTITION BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID,
		Country ORDER BY Invoice, StockCode) AS RowNum
	FROM 
		Online_Retail_New..[2010-2011]
		)
DELETE FROM New_Table WHERE RowNum > 1 --REMOVING DUPLICATES
COMMIT;

BEGIN TRANSACTION -- Code to make sure only digits exist in a column
WHILE 1 = 1
BEGIN
	UPDATE Online_Retail_New..[2009-2010]
	SET StockCode = STUFF(StockCode, PATINDEX('%[^0-9]%', StockCode), 1, '')
	WHERE PATINDEX('%[^0-9]%', StockCode) > 0; --Finds any char NOT 0-9

	-- stop the loop when no more non-digits are found
	IF @@ROWCOUNT = 0 BREAK;
END

BEGIN TRANSACTION -- Code to make sure only digits exist in a column
WHILE 1 = 1
BEGIN
	UPDATE Online_Retail_New..[2010-2011]
	SET StockCode = STUFF(StockCode, PATINDEX('%[^0-9]%', StockCode), 1, '')
	WHERE PATINDEX('%[^0-9]%', StockCode) > 0; --Finds any char NOT 0-9

	-- stop the loop when no more non-digits are found
	IF @@ROWCOUNT = 0 BREAK;
END

--troubleshooting the datatset
SELECT
	SUM(case when Price is not null then 1 else 0 end) TotalNotNulls,
	SUM(case when Price = '' then 1 else 0 end) Totalempty,
	SUM(case when Price is null then 1 else 0 end) TotalNull,
	SUM(case when Price = 0 then 1 else 0 end) TotalZeroPrice,
	SUM(case when Price != 0 then 1 else 0 end) TotalNonZeroPrice,
	SUM(case when Invoice like '%[a-zA-Z]%' then 1 else 0 end),
	SUM(case when Invoice like '%[a-zA-Z]%' and Price = 0 then 1 else 0 end),
	SUM(case when Invoice like '%[a-zA-Z]%' and Price = 0 and CustomerID is null then 1 else 0 end)
FROM
	Online_Retail_New..[2009-2010];

--troubleshooting the datatset
SELECT
	SUM(case when Price is not null then 1 else 0 end) TotalNotNulls,
	SUM(case when Price = '' then 1 else 0 end) Totalempty,
	SUM(case when Price is null then 1 else 0 end) TotalNull,
	SUM(case when Price = 0 then 1 else 0 end) TotalZeroPrice,
	SUM(case when Price != 0 then 1 else 0 end) TotalNonZeroPrice,
	SUM(case when Invoice like '%[a-zA-Z]%' then 1 else 0 end),
	SUM(case when Invoice like '%[a-zA-Z]%' and Price = 0 then 1 else 0 end),
	SUM(case when Invoice like '%[a-zA-Z]%' and Price = 0 and CustomerID is null then 1 else 0 end)
FROM
	Online_Retail_New..[2010-2011];


BEGIN TRANSACTION
SELECT* INTO Online_All_Tables
FROM
(
  SELECT*
	FROM
		Online_Retail_New..[2009-2010]
	UNION ALL
	SELECT*
	FROM
		Online_Retail_New..[2010-2011]
	) AS All_Tables
COMMIT;

-- to know products that where returned and check if its price is zero
-- in order to remove it from the dataset
SELECT*
FROM
	Online_All_Tables
WHERE
	Invoice LIKE '%C%' AND Price = 0:

-- getting to understand the dataset
SELECT*
FROM
	Online_All_Tables
WHERE
	Price = 0
--GROUP BY
--	CustomerID
--ORDER BY 
--	COUNT(*) DESC
--WHERE 
--CustomerID IS NULL
--ORDER BY Invoice ASC


BEGIN TRANSACTION
UPDATE Online_All_Tables
SET Invoice = 
	CASE 
		WHEN CustomerID IS NULL AND Invoice NOT LIKE '%[a-zA-Z]%' 
		THEN CONCAT('C', Invoice) ELSE Invoice 
	END
WHERE
	CustomerID IS NULL --THIS HELPS THE QUERY RUN FASTER. IT WILL JUMP TO NULLS
COMMIT;


SELECT
	StockCode, Description
FROM
	Online_All_Tables
GROUP BY
	Description, StockCode  -- TRYING TO OBTAIN INFO ON SOME MISSING CODES

SELECT DISTINCT	
	Quantity
FROM	
	Online_All_Tables 
ORDER BY Quantity ASC


SELECT*
FROM
	Online_All_Tables
WHERE
	CustomerID IS NULL AND StockCode IS NULL
	 --Description LIKE '%CHERRY LIGHT%'
ORDER BY CustomerID ASC

SELECT*
FROM
	Online_All_Tables
WHERE
	 Invoice LIKE '%C%'

SELECT*
FROM
	Online_All_Tables
WHERE
	CustomerID IS NULL AND Invoice LIKE '%C%'

BEGIN 
UPDATE Online_All_Tables
SET
	Quantity = TRY_CAST(NULLIF(TRIM(Quantity), '') AS INT) 
END

BEGIN TRANSACTION
ALTER TABLE Online_All_Tables
ALTER COLUMN StockCode BIGINT;

SELECT*
FROM
	Online_All_Tables
WHERE
	StockCode IS NULL AND CustomerID IS NULL AND Description IS NOT NULL
ORDER BY Invoice DESC

BEGIN TRANSACTION
DELETE FROM Online_All_Tables
WHERE CustomerID IS NULL AND StockCode IS NULL

ROLLBACK
COMMIT

SELECT*
FROM
	Online_All_Tables
--WHERE Quantity = 0
ORDER BY Price ASC--StockCode, Invoice

SELECT*	
FROM	Online_All_Tables

BEGIN TRANSACTION
DELETE FROM Online_All_Tables
WHERE Price = 0

BEGIN TRANSACTION
ALTER TABLE 
	Online_All_Tables
ADD 
	Year INT

BEGIN TRANSACTION
ALTER TABLE Online_All_Tables
DROP COLUMN Year 

UPDATE Online_All_Tables
SET Year = YEAR(InvoiceDate)

BEGIN TRANSACTION
ALTER TABLE 
	Online_All_Tables
ADD 
	TotalSpend INT

UPDATE Online_All_Tables
SET TotalSpend = CEILING(Quantity * Price)
COMMIT

SELECT CustomerID, Year, MaxSpend
FROM(
	SELECT
		CustomerID, Year, SUM(TotalSpend) MaxSpend
	FROM
		Online_All_Tables
	WHERE 
		CustomerID IS NOT NULL
	GROUP BY
		CustomerID, Year
	) Sub

WHERE 
	MaxSpend = 
		(SELECT MAX(Total)
		FROM(
			SELECT
				CustomerID, Year, SUM(TotalSpend) Total
			FROM
				Online_All_Tables
			WHERE 
				CustomerID IS NOT NULL
			GROUP BY
				CustomerID, Year) InnerSub
		)


SELECT CustomerID, Year, MaxSpend
FROM(
	SELECT
		CustomerID, Year, SUM(TotalSpend) MaxSpend
	FROM
		Online_All_Tables
	WHERE 
		CustomerID IS NOT NULL
	GROUP BY
		CustomerID, Year
	) Sub
GROUP BY
		CustomerID, Year


SELECT 
	CustomerID, Year, SUM(TotalSpend) MaxSpend
FROM
	Online_All_Tables
WHERE 
	CustomerID = 18102 
GROUP BY
	CustomerID, Year
ORDER BY 
	CustomerID 


SELECT
	CustomerID, Year, SUM(TotalSpend) Total
FROM
	Online_All_Tables
WHERE
	CustomerID IS NOT NULL
GROUP BY
	CustomerID, Year
ORDER BY 
	Total DESC


SELECT
	CustomerID, Year, SUM(TotalSpend) Total
FROM
	Online_All_Tables
WHERE
	CustomerID IS NOT NULL
GROUP BY
	CustomerID, Year
ORDER BY 
	Total DESC

BEGIN TRANSACTION;

WITH YearlyCustomerSpend AS 
(
    SELECT 
        CustomerID, 
        Year, 
        SUM(TotalSpend) AS Total
    FROM Online_All_Tables 
    WHERE CustomerID IS NOT NULL AND Invoice NOT LIKE '%C%'
    GROUP BY CustomerID, [Year]
),

CustomerRank AS
(
    SELECT 
        CustomerID,
        Year,
        Total,
        DENSE_RANK() OVER (
            PARTITION BY Year
            ORDER BY Total DESC
        ) AS Yearly_Rank
    FROM YearlyCustomerSpend
)

SELECT 
    CustomerID,
    Year,
    Total, Yearly_Rank
FROM CustomerRank
WHERE Yearly_Rank <= 3
ORDER BY Year ASC;

COMMIT;
