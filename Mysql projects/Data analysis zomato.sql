
use zomato_analysis ;
   
                                     -- ZOMATO ANALYSIS --
                                     
                                     
		-- 1. According to this Zomato Dataset, 90.67% of data is related to restaurants listed in India followed by USA(4.45%).
        
        -- ROLLING/MOVING COUNT OF RESTAURANTS IN INDIAN CITIES
        
	    SELECT 
            Country_Name,
            City,
            Locality,
            COUNT(Locality) AS TOTAL_REST,
            SUM(COUNT(Locality)) OVER(PARTITION BY City ORDER BY  Locality DESC) AS ROLL_COUNT
		FROM zomato
        WHERE Country_Name = 'India'
        GROUP BY Country_Name, City, Locality;
        
        
        -- SEARCHING FOR PERCENTAGE OF RESTAURANTS IN ALL THE COUNTRIE
        
        CREATE OR REPLACE VIEW TOTAL_COUNT AS 
        SELECT
             DISTINCT Country_Name,
             count(CAST(RestaurantID AS UNSIGNED)) OVER() AS TOTAL_REST
		FROM zomato ;
        
        SELECT * FROM TOTAL_COUNT ;
        
        
        -- -- FINAL QUERY AFTER CREATING VIEW 
        
        WITH CT1 AS (
             SELECT 
                  Country_Name,
                  COUNT(CAST(RestaurantID AS UNSIGNED)) AS REST_COUNT
		     FROM zomato
             GROUP BY Country_Name
		)
        SELECT 
            A.Country_Name,
            A.REST_COUNT,
            ROUND(CAST(A.REST_COUNT AS DECIMAL(10,2)) / CAST(B.TOTAL_REST AS DECIMAL(10,2)) * 100, 2) AS PERCENTAGE
		FROM CT1 A
        JOIN TOTAL_COUNT B ON A.Country_Name = B.Country_Name
        ORDER  BY 3 DESC ;
        


-- 2. Out of 15 Countries only 2 countries provides Online delivery options to their customers, to be precised only 28.01% of restaurants in India and 46.67% of restaurants in UAE provides online delivery options.

        -- WHICH COUNTRIES AND HOW MANY RESTAURANTS WITH PERCENTAGE PROVIDES ONLINE DELIVERY OPTION
        
        CREATE OR REPLACE VIEW COUNTRY_REST AS
        SELECT
             Country_Name,
             COUNT(CAST(RestaurantID AS UNSIGNED)) AS REST_COUNT
		FROM zomato
		GROUP BY Country_name ;
        
        SELECT * FROM COUNTRY_REST ORDER BY 2 DESC ;    
        
        
        SELECT 
             A.Country_Name,
             COUNT(A.RestaurantID) AS TOTAL_REST,
             ROUND(COUNT(CAST(A.RestaurantID AS DECIMAL (10,2))) /CAST(B.REST_COUNT AS DECIMAL (10,2)) *100,2) AS PERCENTAGE
		FROM zomato A 
        JOIN COUNTRY_REST B ON A.Country_Name = B.Country_Name
        WHERE A.Has_Online_delivery = 'YES'
        GROUP BY A.Country_Name, B.REST_COUNT
        ORDER BY 2 DESC ;
        

-- 3. As this dataset contains data most related to India so i worked on gaining insights on Indian Restaurants.

        -- FINDING FROM WHICH CITY AND LOCALITY IN INDIA WHERE THE MAX RESTAURANTS ARE LISTED IN ZOMATO
        WITH CT1 AS (
              SELECT 
                    City,
                    Locality,
                    Count(RestaurantID) AS REST_COUNT 
			   FROM zomato 
               WHERE Country_Name = 'India'
               GROUP BY City,Locality
		)
        SELECT Locality, REST_COUNT
        FROM CT1
        WHERE REST_COUNT = (SELECT max(REST_COUNT) FROM CT1) ;
        
        
	-- 4. Connaught Place in New Delhi has the most listed restaurants (122) follwed by Rajouri Garden (99) and Shahdara (87)
 
        
        -- TYPES OF FOODS ARE AVAILABLE IN INDIA WHERE THE MAX RESTAURANTS ARE LISTED IN ZOMATO\
        WITH CT1 AS (
               SELECT 
                    City,
                    Locality,
                    COUNT(RestaurantID) AS REST_COUNT
				FROM zomato 
                WHERE Country_Name = 'India'
                GROUP BY City,Locality
		),
        CT2 AS (
             SELECT Locality,REST_COUNT
             FROM CT1
             WHERE REST_COUNT = (SELECT MAX(REST_COUNT) FROM CT1)
		),
        CT3 AS (
             SELECT Locality,Cuisines FROM zomato 
		)
        SELECT A.Locality, B.Cuisines
        FROM CT2 A
        JOIN CT3 B ON A.Locality =b.Locality ;	
        
  
  
  -- 5. Most popular cuisines in Connaught Place is North Indian Food.
     
        -- MOST POPULAR FOOD IN INDIA WHERE THE MAX RESTAURANTS ARE LISTED IN ZOMATO
        
        CREATE OR REPLACE VIEW VF AS 
        SELECT 
             Country_Name,
             City,
             Locality,
             j.Cuisines
		FROM zomato 
        JOIN JSON_TABLE (
             CONCAT('[" ',REPLACE(Cuisines,  '|', ' "," '), ' "]'),
             '$[*]'  COLUMNS (Cuisines VARCHAR(255) PATH '$')
		) AS j ;
        
        WITH CT1 AS (
               SELECT 
                    City,
                    Locality,
                    COUNT(RestaurantID) AS REST_COUNT
				FROM zomato 
                WHERE Country_Name = 'India'
                GROUP BY City, Locality
		),
        CT2 AS (
             SELECT Locality, REST_COUNT
             FROM CT1
             WHERE REST_COUNT = (SELECT MAX(REST_COUNT) FROM CT1)
		)
        SELECT 
            A.Cuisines,
            COUNT(A.Cuisines) AS Cuisine_COUNT
		FROM VF A
        JOIN CT2 B ON A.Locality = B.Locality
        GROUP BY B.Locality , A.Cuisines
        ORDER BY 2 DESC ;


-- 6. Out of 122 restaurants in Connaught Place only 54 restaurants provide table booking facility to their customers.

  -- WHICH LOCALITIES IN INDIA HAS THE LOWEST RESTAURANTS LISTED IN ZOMATO
  WITH CT1 AS (
        SELECT 
             City,
             Locality,
             COUNT(RestaurantID) AS REST_COUNT
		FROM zomato 
        WHERE Country_Name = 'India'
        GROUP BY City,Locality
  )
  SELECT * FROM CT1
  WHERE REST_COUNT =(SELECT MIN(REST_COUNT) FROM CT1)
  ORDER BY City ;
  
  
-- 7. Average Ratings for restaurants with table booking facility is 3.9/5 compared to  restaurants without table booking facility is 3.7/5 in Connaught Place,New Delhi.

  -- HOW MANY RESTAURANTS OFFER TABLE BOOKING OPTION IN INDIA WHERE THE MAX RESTAURANTS ARE LISTED IN ZOMATO
   WITH CT1 AS ( 
          SELECT 
               City,
               Locality,
               COUNT(RestaurantID) AS REST_COUNT
		  FROM zomato
          WHERE Country_Name = 'India'
          GROUP BY City,Locality
	),
    CT2 AS  (
        SELECT Locality, REST_COUNT
        FROM CT1 
        WHERE REST_COUNT = (SELECT MAX(REST_COUNT) FROM CT1)
	),
    CT3 AS (
        SELECT Locality, Has_Table_booking AS TABLE_BOOKING
        FROM zomato
	)
    SELECT 
        A.Locality,
        COUNT(A.TABLE_BOOKING) AS TABLE_BOOKING_OPTION
	FROM CT3 A 
    JOIN CT2 B ON A.Locality = B.Locality
    WHERE A.TABLE_BOOKING = 'YES'
    GROUP BY A.Locality ;
    


  -- 8. Best modrately priced restaurants with average cost for two < 1000, rating > 4, votes > 4 and provides both table booking and online delivery options to their customer with indian cuisines is located in Kolkata,India named as 'India Restaurant',(RestaurantID - 20747).
  
    -- HOW RATING AFFECTS IN MAX LISTED RESTAURANTS WITH AND WITHOUT TABLE BOOKING OPTION (Connaught Place)
     SELECT 
         'WITH_TABLE' AS TABLE_BOOKING_OPT,
         COUNT(Has_Table_booking) AS TOTAL_REST,
         ROUND(AVG(Rating), 2) AS AVG_RATING
	FROM zomato
    WHERE Has_Table_booking = 'YES'
       AND Locality = 'Connaught Place'
       
    UNION
    
    SELECT 
        'WITHOUT_TABLE' AS TABLE_BOOKING_OPT,
        COUNT(Has_Table_booking) AS TOTAL_REST,
        ROUND(AVG(Rating), 2) AS AVG_RATING
	FROM zomato 
    WHERE Has_Table_booking = 'NO'
       AND Locality = 'Connaught Place' ;
       
       
       -- AVG RATING OF RESTS LOCATION WISE
       SELECT 
            Country_Name,
            City,
            Locality,
            COUNT(RestaurantID) AS TOTAL_REST,
            ROUND(AVG(CAST(Rating AS DECIMAL(10,2))), 2) AS AVG_RATING 
	   FROM zomato 
       GROUP BY Country_name, City, Locality
       ORDER BY 4 DESC ;
       
       
       -- FINDING THE BEST RESTAURANTS WITH MODERATE COST FOR TWO IN INDIA HAVING INDIAN CUISINES
       SELECT * FROM zomato 
       WHERE Country_Name = 'India'
            AND Has_Table_booking = 'YES'
            AND Has_Online_delivery = 'YES'
            AND Price_range <= 3
            AND Votes > 1000
            AND Average_Cost_for_two < 1000
            AND Rating > 4
            AND Cuisines LIKE '%India%' ;
            
       -- FIND ALL THE RESTAURANTS THOSE WHO ARE OFFERING TABLE BOOKING OPTIONS WITH PRICE RANGE AND HAS HIGH RATING
       SELECT
           Price_range,
           COUNT(Has_Table_booking) AS NO_OF_REST
		FROM zomato 
        WHERE Rating >= 4.5
           AND Has_Table_booking = 'YES'
		GROUP BY Price_range ;
     

		