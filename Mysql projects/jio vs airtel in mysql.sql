
CREATE DATABASE air_vs_jio ;
USE  air_vs_jio;



 -- 1. Which Jio plans offer high-speed data (> 2GB/day)?


SELECT Days, Price, Data_Per_day
FROM jio_plans
WHERE Data_Per_day > 2 ;
 
 
 -- 2. Which Airtel plans are designed for long-term use (84 days or more)?

SELECT Price, Days ,Data_per_Day
FROM airtel_plans
WHERE Days >= 84 ;


-- What are the "Budget-Friendly" options (under ₹300) available from both?

SELECT 'Jio' AS Provider, Price, Days FROM jio_plans WHERE Price < 300
UNION ALL
SELECT 'Airtel' AS Provider, Price,Days FROM airtel_plans WHERE Price < 300;


-- 4. Does Airtel offer any plans with no daily data limit (bulk data only)?

SELECT Price, Data, Days
FROM airtel_plans
WHERE Data_per_Day = 0 AND Data > 0;


-- 5. What are the standard "monthly" plans (exactly 28 days validity) for Jio?

SELECT Days, Price, Data_per_Day
FROM jio_plans
WHERE Days = 28


-- 6. Which Airtel plans include a free Disney+ Hotstar subscription?

SELECT Price, Days, Additional_Benefits
FROM airtel_plans
WHERE Additional_Benefits LIKE '%Disney%' ;


-- 7. Which Airtel plans include a free Amazon Prime membership?

SELECT Price, Days, Additional_Benefits
FROM airtel_plans
WHERE Additional_Benefits LIKE '%Amazon%' ;


-- 8. Which plans offer purely data/talktime with zero additional benefits?

SELECT Price, Days, Additional_Benefits
FROM airtel_plans
WHERE Additional_Benefits = '0' OR Additional_Benefits IS NULL ;


-- 9. What is the actual "Cost per 1 GB of Data" for each Jio plan?

SELECT 
     Price,
     Days,
     Data_per_day,
     ROUND(Price/ (Data_per_day * Days ), 2) AS Cost_Per_GB
FROM jio_plans
WHERE Data_per_day > 0
ORDER BY Cost_Per_GB ASC ;


-- 10. If we normalize to a 30-day cycle, what is the estimated monthly cost for Airtel?

SELECT
     Price,
     Days,
     ROUND((Price / Days) * 30, 2) Est_Monthly_Cost
FROM airtel_plans ;


-- 11. How can we categorize Jio plans into "Budget," "Standard," and "Premium"?

SELECT 
     Price,
     CASE
         WHEN Price < 200 THEN 'Budget'
         WHEN Price BETWEEN 200 AND 600 THEN 'Standard'
         ELSE 'Premium'
    END AS Plan_Category
FROM jio_plans 
ORDER BY Price desc ;


-- 12. If a user sticks to a single plan for a year, how much will they spend?

SELECT 
     Price,
     Days,
     ROUND((365 / Days) * Price ,  0) AS Yearly_Projection
FROM jio_plans
ORDER BY Price DESC ;


-- 13. How does the average price change as the validity period increases?

SELECT 
     Days,
     COUNT(*) AS Total_plans,
     ROUND (AVG(Price), 2) AS Avg_Price
FROM airtel_plans
GROUP BY Days 
ORDER BY Days ;


-- 14. What is the total data capacity promised by Jio if one buys every plan?

SELECT SUM(Data_per_Day * Days) AS Total_Network_Data_Capacity
FROM jio_plans


-- 15. What is the most common "Data per Day" offering?

SELECT
      Data_per_Day,
      COUNT(*) AS Numper_of_plans
FROM airtel_plans
GROUP BY Data_per_Day
ORDER BY Numper_of_plans DESC ;

-- 16. What are the minimum, maximum, and average prices in the market?

SELECT 
     MIN(Price) AS MIN_Price,
     MAX(Price) AS MAX_Price,
     AVG(Price) AS AVG_Price
FROM airtel_plans ;


-- 17. The Leaderboard: Which top 10 plans are cheapest per day (Across Both)?

SELECT 'Jio' AS Provider, Price, Days, Price_Day AS Daily_Cost FROM jio_plans
UNION ALL
SELECT 'Airtel' AS PROVIDER, Price, Days, (Price/Days) AS Daily_Cost FROM airtel_plans 
ORDER BY Daily_Cost ASC 
LIMIT 10;


-- 18. Head-to-Head: How much cheaper is Jio vs Airtel for 84-day plans?

SELECT 
     J.Price AS Jio_Price,
     A.Price AS Airtel_Price,
     (A.Price - J.Price) AS Price_Difference
FROM jio_plans J JOIN airtel_plans A ON J.Days = A.Days
WHERE J.Days = 84 ;


-- 19. Rank Airtel plans by how much data they offer (Highest to Lowest).

SELECT 
     Price,
     Data_per_Day,
     RANK() OVER (ORDER BY Data_per_Day DESC) AS Data_Rank
FROM airtel_plans ;
   

-- 20. Which Jio plans drive the highest profit margins relative to price?

SELECT
      Price,
      Profit_per_customer,
      ROUND((Profit_per_customer / Price) * 100 , 2) AS Margin_Percentage
FROM jio_plans 
ORDER BY Margin_Percentage DESC;


-- 21. The "Power User" Filter: High Data (>1.5GB) AND Streaming Benefits.

SELECT * FROM airtel_plans
WHERE Data_per_Day >= 1.5
AND (Additional_Benefits LIKE '%Disney%'  OR Additional_Benefits LIKE '%Prime%');
