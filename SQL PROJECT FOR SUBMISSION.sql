
-- Question 1: What are the total number of countries involved in deforestation? --

WITH table_1 AS 
(
SELECT * FROM 
(SELECT COUNTRY_NAME, YEAR, forest_area_sqkm,
RANK() OVER(PARTITION BY COUNTRY_NAME ORDER BY forest_area_sqkm DESC) AS COL_rank
FROM Forest_Area) table_1
WHERE COL_RANK > 1),

table_2 AS 
(
SELECT COUNTRY_NAME, YEAR, FOREST_AREA_SQKM,
LAG(forest_area_sqkm) OVER(PARTITION BY COUNTRY_NAME ORDER BY YEAR ASC) AS PREVIOUS_FA
FROM table_1),

table_3 AS 
(SELECT * FROM table_2 WHERE PREVIOUS_FA IS NOT NULL),

table_4 AS 
(SELECT *, 
CASE WHEN FOREST_AREA_SQKM >= PREVIOUS_FA THEN 'AFFORESTATION' ELSE 'DEFORESTATION' END AS FOREST_STATE
FROM table_3)

SELECT COUNT(DISTINCT COUNTRY_NAME) AS NO_COUNTRIES_INVOLVED_IN_DEFORESTATION FROM table_4
WHERE FOREST_STATE = 'DEFORESTATION';


-- Question 2: Show the income groups of countries having total area ranging from 75,000 to 150,000 square meter?--

SELECT REG.COUNTRY_ID, 
REG.country_name,
REG.COUNTRY_CODE,
REGION,
LAN.total_area_sq_mi,
INCOME_GROUP
FROM REGION AS REG
INNER JOIN LAND_AREA AS LAN
ON REG.COUNTRY_ID = LAN.COUNTRY_ID
WHERE total_area_sq_mi BETWEEN 75000 AND 150000
ORDER BY total_area_sq_mi ASC;


--Question 3: Calculate average area in square miles for countries in the 'upper middle income region'. Compare the result with the rest of the income categories.--
-- USING JOINS ONLY--

SELECT income_group, AVG(total_area_sq_mi) FROM Land_Area
JOIN REGION
ON Land_Area.country_code = Region.country_code
GROUP BY income_group
HAVING income_group != 'NULL';


--Question 4: Determine the total forest area in square km for countries in the 'high income' group. Compare result with the rest of the income categories.--

SELECT * FROM REGION;
SELECT * FROM FOREST_AREA;

SELECT REG.COUNTRY_NAME,
INCOME_GROUP ,
SUM(forest_area_sqkm) AS FOREST_AREA_SQKM FROM REGION AS REG
INNER JOIN FOREST_AREA AS FAS
ON REG.COUNTRY_ID = FAS.COUNTRY_ID
WHERE income_group = 'HIGH INCOME'
GROUP BY REG.COUNTRY_NAME,income_group; 

(SELECT REG.COUNTRY_NAME,
INCOME_GROUP ,
SUM(forest_area_sqkm) AS FOREST_AREA_SQKM FROM REGION AS REG
INNER JOIN FOREST_AREA AS FAS
ON REG.COUNTRY_ID = FAS.COUNTRY_ID
WHERE income_group != 'HIGH INCOME'
GROUP BY REG.COUNTRY_NAME,income_group);

--Using cte (common Table Expression) --

WITH FORESTAREA AS ( SELECT INCOME_GROUP, SUM(forest_area_sqkm) AS FAS 
FROM REGION AS REG
INNER JOIN FOREST_AREA AS FAS 
ON REG.COUNTRY_ID = FAS.COUNTRY_ID
GROUP BY INCOME_GROUP)
SELECT INCOME_GROUP,FAS FROM FORESTAREA
WHERE income_group = 'HIGH INCOME'

UNION ALL

SELECT INCOME_GROUP, FAS FROM FORESTAREA
WHERE income_group != 'HIGH INCOME';

--Question 5: Show countries from each region(continent) having the highest total forest areas.-- 

WITH table_1 AS
(SELECT COUNTRY_NAME, SUM(FOREST_AREA_SQKM) AS TOTAL_FOREST_AREA
FROM Forest_Area 
GROUP BY country_name),

table_2 AS
(SELECT REGION, a.country_name, TOTAL_FOREST_AREA,
RANK() OVER(PARTITION BY REGION ORDER BY TOTAL_FOREST_AREA DESC) RANK
FROM table_1 a 
JOIN REGION b 
ON a.country_name = b.country_name)

SELECT * FROM table_2 WHERE RANK = 1 AND REGION != 'WORLD'





