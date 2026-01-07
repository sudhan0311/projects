
USE zomato_analysis ;


                                  -- DATA EXPLORATION --
          
-- 1. Checked all the details of table such column name, data types and constraints --
        
        SELECT 
		COLUMN_NAME ,
		DATA_TYPE 
		FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'zomato' ;
        
        
       SELECT DISTINCT TABLE_CATALOG, TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS ;
       SELECT * FROM INFORMATION_SCHEMA.COLUMNS ;
       
       SELECT * FROM zomato;
       
        
        
-- 2. Checked for duplicate values in [RestaurantId] column --
        
        -- CHECKING FOR DUPLICATE--
        
        SELECT RestaurantID, count(RestaurantID)
        FROM zomato
        GROUP BY RestaurantID
        ORDER BY 2 DESC ;
        
        SELECT * FROM zomato ;
        
        
        
        
                
-- 3. Removed unwanted columns from table --
        
        DELETE FROM zomato_analysis.zomato
        WHERE RestaurantName IN ( 'Bar' , 'Grill' , 'Bakers & More' ,'Chowringhee Lane' , 'Grill & Bar' ,'Chinese') ;
        
        DELETE FROM zomato
        WHERE RestaurantID = '18306543' ;
        
        SELECT * FROM zomato ;
        
        
        
        
        
-- 4. Identitfied and corrected the mis-spelled city names
        
                -- IDENTIFYING  IF THERE ANY MISS-SPELLED WORD

        SELECT DISTINCT City FROM zomato
        WHERE City LIKE '%?%' ;
        
                -- REPLACING MISS_SPELLED WORD --

        SELECT REPLACE(City, '?', 'i')
        FROM zomato 
        WHERE City LIKE '%?%' ;
        
        -- UPDATING WITH REPLACE STRING FUNCTION
        
        UPDATE zomato SET City = REPLACE(City, '?' , 'i')  
        WHERE City LIKE '%?%' ;
        
        -- COUNTING TOTAL REST. IN EACH CITY OF PARTICULAR COUNTRY
        
        SELECT COUNTRYCODE, CITY, COUNT(City) AS TOTAL_REST
        FROM zomato 
        GROUP BY COUNTRYCODE,City
        ORDER BY 1,2,3 DESC ;
        
       



-- 5. Counted the no.of restaurants by rolling count/moving count using windows functions
       
        -- LOCALITY COLUMN
        -- ROLL COUNT 
        
        SELECT 
              City, 
              Locality, 
              COUNT(Locality) AS COUNT_LOCALITY,
              SUM(COUNT(Locality)) OVER(PARTITION BY City ORDER BY City, Locality) AS ROLL_COUNT
        FROM zomato
        WHERE COUNTRY_NAME = 'INDIA'
        GROUP BY Locality, City
		ORDER BY 1, 2, 3 DESC;
        
        -- DROP COLUMNS
        
        ALTER TABLE zomato
        DROP COLUMN Address,
        DROP COLUMN LocalityVerbose ;
        
        -- CUISINES COLUMN 
        
        SELECT Cuisines, COUNT(Cuisines)
        FROM zomato
        WHERE Cuisines IS NULL OR Cuisines = '  '
        GROUP BY Cuisines 
        ORDER BY 2 DESC ;
        
        SELECT Cuisines, COUNT(Cuisines)
        FROM zomato
        GROUP BY Cuisines 
        ORDER BY  2 DESC ;
        
        -- CURRENCY COLUMN
        
        SELECT Currency, COUNT(Currency) AS Total_Currency
        FROM zomato 
        GROUP BY Currency
        ORDER BY 2 DESC ;
        
        -- YES/NO COLUMNS
        
        SELECT DISTINCT Has_Table_booking FROM zomato ;
        SELECT DISTINCT Has_Online_delivery FROM zomato ;
        SELECT DISTINCT Is_delivering_now FROM zomato ;
        SELECT DISTINCT Switch_to_order_menu FROM zomato ;
        
        -- DROP COLUMN
        ALTER TABLE zomato DROP COLUMN Switch_to_order_menu ;
        
        -- PRICE  RANGE COLUMN
        SELECT DISTINCT Price_range FROM zomato ;
    
    
       
       
-- 6. Checked min,max,avg data for votes, rating & currency column.

        -- VOTES COLUMN  ( CHECKING MIN,MAX,AVG)
        SELECT 
             MIN(cast(Votes AS SIGNED )) AS MIN_VT,
             MAX(CAST(Votes AS SIGNED)) AS MAX_VT,
             avg(cast(Votes AS SIGNED)) AS AVG_VT
		FROM zomato ;
        
        -- COST COLUMN
        -- CHANGING COLUMN TYPE 
        ALTER TABLE zomato MODIFY COLUMN Average_Cost_for_two FLOAT;
        
        SELECT
             Currency,
             MIN(cast(Average_Cost_for_two AS SIGNED )) AS MIN_CST,
             MAX(CAST(Average_Cost_for_two AS SIGNED )) AS MAX_CST,
             AVG(CAST(Average_Cost_for_two AS SIGNED )) AS AVG_CST
		FROM zomato
        GROUP BY Currency ;
        
        -- RATING COLUMN --
        SELECT 
            MIN(Rating),
            ROUND(AVG(CAST(Rating AS DECIMAL(10,1))), 1),
            MAX(Rating)
		FROM zomato;
        
        SELECT CAST(rating AS DECIMAL(10,1)) AS NUM
        FROM zomato
        WHERE CAST(Rating AS DECIMAL(10,1)) >= 4;
        
        ALTER TABLE zomato MODIFY COLUMN Rating DECIMAL(10,1);
        
        SELECT Rating FROM zomato WHERE Rating >= 4 ;
        
        SELECT Rating,
             CASE 
                 WHEN Rating >= 1 AND Rating < 2.5 THEN 'POOR'
                 WHEN Rating >=2.5 AND Rating < 3.5 THEN 'GOOD'
                 WHEN Rating >=3.5 AND Rating < 4.5 THEN 'GREAT'
                 WHEN Rating >= 4.5  THEN 'EXCELLENT'
			END AS RATE_CATEGORY
		FROM zomato ;
        
         ALTER TABLE zomato ADD RATE_CATEGORY varchar(20) ;
         
         SELECT * FROM zomato ;
         
 
        
        -- 8. Created new category column for rating
        
        UPDATE zomato SET RATE_CATEGORY  = (CASE
             WHEN Rating >= 1 AND Rating < 2.5 THEN 'POOR'
             WHEN Rating >= 2.5 AND Rating < 3.5 THEN 'GOOD'
             WHEN Rating >= 3.5 AND Rating < 4.5 THEN  'GREAT'
             WHEN Rating >= 4.5 THEN 'EXCELLENT'
		END);
 
             