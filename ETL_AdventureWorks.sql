



-- TABLA DE HECHOS / FACT TABLE
-- Datos de Venta

CREATE VIEW VWVentas
AS
SELECT CONCAT(SOH.SalesOrderID, SOD.SalesOrderDetailID) AS ID
      ,CONVERT(DATE,SOH.OrderDate) AS OrderDate
	  ,CAST(SOH.ShipDate AS DATE) AS ShipDate
	  ,DATEDIFF(DAY, SOH.OrderDate, SOH.ShipDate) AS DaysToShip
	  ,CASE
			WHEN SOH.Status = 1 THEN 'In Process'
			WHEN SOH.Status = 2 THEN 'Approved'
			WHEN SOH.Status = 3 THEN 'Backordered'
			WHEN SOH.Status = 4 THEN 'Rejected'
			WHEN SOH.Status = 5 THEN 'Shipped'
			WHEN SOH.Status = 6 THEN 'Cancelled'
			ELSE 'Check'
		END AS StatusLabel
	  ,IIF(SOH.OnlineOrderFlag = 1, 'Order placed online by customer', 'Order placed by sales person') AS OnlineOrderFlag
	  ,SOH.SalesOrderNumber
	  ,SOH.AccountNumber
	  ,SOH.CustomerID
	  ,ISNULL(SOH.SalesPersonID, 0) AS SalesPersonID
	  ,SOH.TerritoryID
	  ,SOH.BillToAddressID
	  ,SOH.ShipToAddressID
	  ,SOH.ShipMethodID
	  ,SOH.CurrencyRateID
	  ,SOH.SubTotal
	  ,SOH.TaxAmt
	  ,SOH.Freight
	  ,SOH.SubTotal + SOH.TaxAmt + SOH.Freight AS Total
	  ,SOH.TaxAmt / (SOH.SubTotal + SOH.TaxAmt + SOH.Freight) AS PercentageTax
	  ,SOH.Freight / (SOH.SubTotal + SOH.TaxAmt + SOH.Freight) AS PercentageFreight
	  ,SOD.OrderQty
	  ,SOD.ProductID
	  ,SOD.UnitPrice
	  ,SOD.LineTotal
	  ,SOD.LineTotal / SOH.SubTotal AS PercentageOfOrder
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN Sales.SalesOrderDetail AS SOD
	ON SOH.SalesOrderID = SOD.SalesOrderID


SELECT * 
FROM VWVentas



CREATE TABLE [AWDataWarehouse].dbo.FactVentas(
	ID BIGINT PRIMARY KEY
	,OrderDate DATE 
	,ShipDate DATE
	,DaysToShip INT
	,StatusLabel VARCHAR(10)
	,OnlineOrderFlag VARCHAR(255)
	,SalesOrderNumber VARCHAR(255)
	,AccountNumber VARCHAR(100)
	,CustomerID INT
	,SalesPersonID INT
	,TerritoryID INT
	,BillToAdressID INT
	,ShipToAdressID INT
	,ShipMethodID INT
	,CurrencyRateID INT
	,SubTotal NUMERIC(38,4)
	,TaxAmt NUMERIC(38,4)
	,Freight NUMERIC(38,4)
	,Total NUMERIC(38,4)
	,PercentageTax NUMERIC(38,4)
	,PercentageOfFreight NUMERIC(38,4)
	,OrderQty INT
	,ProductID INT
	,UnitPrice NUMERIC(38,4)
	,LineTotal NUMERIC(38,4)
	,PercentageOfOrder NUMERIC(38,4)
)


INSERT INTO [AWDataWarehouse].dbo.FactVentas
SELECT * 
FROM VWVentas


-- DIM_DATES / CALENDARIO

CREATE VIEW VWDimDates
AS
SELECT DISTINCT CAST(OrderDate as DATE) AS OrderDate
	   ,CONCAT(YEAR(OrderDate), 
			IIF(LEN(MONTH(OrderDate))=1, CAST(CONCAT(0,MONTH(OrderDate)) AS VARCHAR), CAST(MONTH(OrderDate) AS VARCHAR)),
			IIF(LEN(DAY(OrderDate))=1, CAST( CONCAT(0,DAY(OrderDate)) AS VARCHAR), CAST(DAY(OrderDate) AS VARCHAR))) AS DATEKEY
	   ,YEAR(OrderDate) AS [YEAR]
	   ,MONTH(OrderDate) AS [MONTH]
	   ,DAY(OrderDate) AS [DAY]
	   ,DATENAME(MONTH, OrderDate) AS [MONTHNAME]
	   ,DATENAME(WEEKDAY, OrderDate) AS [WEEKNAME]
	   ,DATEPART(DAYOFYEAR, OrderDate) AS [DAYOFYEAR]
	   ,DATEPART(WEEK, OrderDate) AS [WEEKOFYEAR]
	   ,DATEPART(QUARTER, OrderDate) AS [QUARTER]
	   ,CASE	
			WHEN DATEPART(QUARTER, OrderDate) BETWEEN 1 AND 2 THEN 1
			WHEN DATEPART(QUARTER, OrderDate) BETWEEN 3 AND 4 THEN 2
			ELSE NULL
			END AS SEMESTER
	   ,CAST(DATEADD(YEAR, -1, OrderDate) AS DATE)    AS OrderDatePY 
FROM Sales.SalesOrderHeader

CREATE TABLE [AWDataWarehouse].dbo.DimFecha (
	OrderDate DATE,
	DATEKEY INT,
	[YEAR] INT,
	[MONTH] INT,
	[DAY] INT,
	[MONTHNAME] VARCHAR(15),
	[WEEKNAME] VARCHAR(15),
	[DAYOFYEAR] INT,
	[WEEKOFYEAR] INT,
	[QUARTER] INT,
	[SEMESTER] INT,
	[OrderDatePY] DATE
)

INSERT INTO [AWDataWarehouse].dbo.DimFecha
SELECT * FROM VWDimDates


SELECT * FROM [AWDataWarehouse].dbo.DimFecha order by 1 desc


-- Dim método de envío

CREATE VIEW VWShipMethod
AS
SELECT ShipMethodID
	  ,Name AS ShipMethod
	  ,ShipBase
	  ,ShipRate
FROM Purchasing.ShipMethod

SELECT * FROM VWShipMethod

CREATE TABLE [AWDataWarehouse].dbo.DimShipMethod (
	ShipMethodID INT,
	ShipMethod VARCHAR(100),
	ShipBase NUMERIC(4,2),
	ShipRate NUMERIC(3,2)
)

INSERT INTO [AWDataWarehouse].dbo.DimShipMethod
SELECT * FROM VWShipMethod

SELECT * FROM [AWDataWarehouse].dbo.DimShipMethod


-- DIM Producto
CREATE VIEW VWDimProducto
AS
SELECT PP.ProductID
	  ,PP.Name AS ProductName
	  ,PP.ProductNumber
	  ,ISNULL(PP.Color, 'No Color') AS Color
	  ,pp.StandardCost
	  ,pp.ListPrice
	  ,ISNULL(pp.Size, 'No Size') AS Size
	  ,ISNULL(pp.SizeUnitMeasureCode, 'No Size Code') AS SizeUnitMeasureCode
	  ,ISNULL(pp.WeightUnitMeasureCode, 'No Weight Code') AS WeightUnitMeasureCode
	  ,ISNULL(pp.Weight, 0) AS [Weight]
	  ,CASE	
			WHEN pp.ProductLine = 'R' THEN 'Road'
			WHEN PP.ProductLine = 'M' THEN 'Mountain'
			WHEN PP.ProductLine = 'T' THEN 'Toouring'
			WHEN pp.ProductLine = 'S' THEN 'Standart'
			WHEN pp.ProductLine IS NULL THEN 'No Product Line'
			ELSE 'Check'
		END AS ProductLine
	  ,CASE		
			WHEN PP.Class = 'H' THEN 'High'
			WHEN PP.Class = 'M' THEN 'Medium'
			WHEN PP.Class = 'L' THEN 'Low'
			WHEN pp.Class IS NULL THEN 'No Class'
		    ELSE 'Check'
		END AS Class
	  ,CASE
			WHEN pp.Style = 'W' THEN 'Women'
			WHEN PP.Style = 'M' THEN 'Men'
			WHEN PP.Style = 'U' THEN 'Universal'
			WHEN pp.Style IS NULL THEN 'No Style'
			ELSE 'Check'
		END AS Style
	   ,PP.SellStartDate
	   ,PP.SellEndDate
	   ,IIF(pp.SellEndDate IS NOT NULL, 'Not Active', 'Active') AS ProductStatus
	   ,ISNULL(PM.Name, 'No Model') AS Model
	   ,ISNULL(PSC.Name, 'No') AS ProductSubCategory
	   ,ISNULL(PC.Name, 'No') AS ProductCategory
FROM Production.Product AS PP
LEFT JOIN  Production.ProductSubcategory AS PSC
	ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID 
LEFT JOIN production.ProductCategory AS PC
	ON PC.ProductCategoryID = PSC.ProductCategoryID
LEFT JOIN Production.ProductModel AS PM
	ON PM.ProductModelID = PP.ProductModelID


SELECT * FROM VWDimProducto

CREATE TABLE [AWDataWarehouse].dbo.DimProducto (
	ProductID INT,
	ProductName VARCHAR(255),
	ProductNumber VARCHAR(100),
	Color VARCHAR(50),
	StandardCost NUMERIC(38,4),
	ListPrice NUMERIC(38,4),
	Size VARCHAR(5),
	SizeUnitMeasureCode VARCHAR(5),
	WeightUnitMeasureCode VARCHAR(5),
	[Weight] NUMERIC(38,4),
	ProductLine VARCHAR(100),
	Class VARCHAR(100),
	Style VARCHAR(100),
	SellStartDate DATETIME,
	SellEndDate DATETIME,
	ProductStatus VARCHAR(50),
	Model VARCHAR(100),
	ProductSubcategory VARCHAR(100),
	ProductCategory VARCHAR(100)
)

INSERT INTO [AWDataWarehouse].dbo.DimProducto
SELECT * FROM VWDimProducto ORDER BY 1 DESC

-- DIM Territorio
CREATE VIEW  VWDimTerritorio
AS
SELECT TerritoryID
      ,Name AS TerritoryName
	  ,CountryRegionCode
	  ,[Group]
	  ,CASE
			WHEN CountryRegionCode = 'US' THEN 37.09024
			WHEN CountryRegionCode = 'CA' THEN 37.2502200
			WHEN CountryRegionCode = 'FR' THEN 46.227638
			WHEN CountryRegionCode = 'DE' THEN 51.165691
			WHEN CountryRegionCode = 'AU' THEN -25.274398
			WHEN CountryRegionCode = 'GB' THEN 55.378051
		ELSE NULL END Latitud
	  ,CASE
			WHEN CountryRegionCode = 'US' THEN -95.712891
			WHEN CountryRegionCode = 'CA' THEN  -119.7512600
			WHEN CountryRegionCode = 'FR' THEN 2.213749
			WHEN CountryRegionCode = 'DE' THEN  10.451526
			WHEN CountryRegionCode = 'AU' THEN 133.775136
			WHEN CountryRegionCode = 'GB' THEN -3.435973
		ELSE NULL END Longitud
FROM Sales.SalesTerritory


CREATE TABLE [AWDataWarehouse].dbo.DimTerritorio (
	TerritoryID INT,
	TerritoryName VARCHAR(15),
	CountryRegionCode VARCHAR(2),
	[Group] VARCHAR(15),
	Latitud VARCHAR(255),
	Longitud VARCHAR(255)
	)


INSERT INTO [AWDataWarehouse].dbo.DimTerritorio
SELECT * FROM VWDimTerritorio

-- DIM clientes individuos

CREATE VIEW  VWDimClientesIN
AS
SELECT CUS.CustomerID
	   ,CUS.TerritoryID
	   ,CUS.AccountNumber
	   ,PP.FirstName + ' ' + PP.LastNamE AS FullName
	   ,CAST(VPD.DateFirstPurchase AS DATE) AS DateFirstPurchase
	   ,CAST(VPD.BirthDate AS DATE) AS BirthDate
	   ,VPD.MaritalStatus
	   ,VPD.YearlyIncome
	   ,VPD.Gender
	   ,VPD.TotalChildren
	   ,VPD.NumberChildrenAtHome
	   ,VPD.Education
	   ,VPD.Occupation
	   ,VPD.HomeOwnerFlag
	   ,VPD.NumberCarsOwned
FROM Sales.Customer AS CUS
INNER JOIN Person.Person AS PP
	ON PP.BusinessEntityID = CUS.PersonID
INNER JOIN Sales.vPersonDemographics AS VPD
	--ON VPD.BusinessEntityID = PP.BusinessEntityID
	ON VPD.BusinessEntityID = CUS.PersonID
WHERE CUS.StoreID IS NULL AND PP.PersonType = 'IN'


SELECT * FROM VWDimClientesIN

CREATE TABLE [AWDataWarehouse].dbo.DimClientesIN (
	CustomerID INT,
	TerritoryID INT,
	AccountNumber VARCHAR(100),
	FullName VARCHAR(100),
	DateFirstPurchase DATE,
	BirthDate DATE,
	MaritalStatus VARCHAR(5),
	YearlyIncome VARCHAR(100),
	Gender VARCHAR(5),
	TotalChildres INT,
	NumberChildrenAtHome INT,
	Education VARCHAR(100),
	Occupation VARCHAR(100),
	HomeOwnerFlag INT,
	NumberCarsOwned INT
)

INSERT INTO [AWDataWarehouse].dbo.DimClientesIN 
SELECT * FROM VWDimClientesIN

-- DIM Clientes Tiendas

CREATE VIEW VWDimClientesT
AS
SELECT CUS.CustomerID,
	  CUS.AccountNumber,
	  St.[Name] AS StoreName,
	  PP.FirstName,
	  PP.LastName,
	  STE.[Name] AS Territory,
	  STE.[Group]
FROM Sales.Customer AS CUS
INNER JOIN Sales.Store AS ST
	ON ST.BusinessEntityID = CUS.StoreID
LEFT JOIN Person.Person AS PP
	ON PP.BusinessEntityID = ST.SalesPersonID
INNER JOIN Sales.SalesTerritory AS STE
	ON STE.TerritoryID = CUS.TerritoryID
WHERE CUS.StoreID IS NOT NULL


CREATE TABLE [AWDataWarehouse].dbo.DimClientesT (
	CustomerID INT,
	AccountNumber VARCHAR(100),
	StoreName VARCHAR(255),
	FirstName VARCHAR(50),
	LastName VARCHAR(50),
	Territory VARCHAR(100),
	[Group] VARCHAR(100)
)

INSERT INTO [AWDataWarehouse].dbo.DimClientesT
SELECT * FROM VWDimClientesT

--DIM Currency

CREATE VIEW VWCurrencyRate
AS
SELECT 
	CR.CurrencyRateID,
	CAST(CR.CurrencyRateDate AS DATE) AS CurrencyRateDate,
	C.Name AS FromDollarToCurrencyCode,
	ROUND(CR.AverageRate, 2) AS AverageRate,
	ROUND(CR.EndOfDayRate,2) AS EndOfDayRate,
	CAST(CR.ModifiedDate AS DATE) AS ModifiedDate
FROM Sales.CurrencyRate AS CR
INNER JOIN Sales.Currency AS C
on CR.ToCurrencyCode = C.CurrencyCode

CREATE TABLE [AWDataWareHouse].dbo.DimCurrencyRate (
	CurrencyRateID INT,
	CurrencyRateDate DATE,
	FromDollarToCurrencyCode VARCHAR(50),
	AverageRate NUMERIC(6,2),
	EndOfDayRate NUMERIC(6,2),
	ModifiedDate DATE
)

INSERT INTO [AWDataWarehouse].dbo.DimCurrencyRate
SELECT * FROM VWCurrencyRate

