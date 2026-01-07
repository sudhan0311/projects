create database amazon_users ;
use amazon_users ;


     -- 01. Retrieve the names and email addresses of all users.
     -- 02. Find the number of users by gender.
	 -- 03. Get the usernames and membership start dates of users who joined before a certain date (2024-03-13).
     -- 04. Count the number of users from a specific location (let's say, locations that contains Port).
     -- 05. List the subscription plans along with the count of users subscribed to each plan.
     -- 06. Find the usernames and their corresponding payment information.
     -- 07. Identify the renewal status of each user's subscription.
     -- 08. Calculate the average usage frequency of all users.
     -- 09. Determine the number of users with a specific purchase history.
     -- 10. List the favorite genres of users along with the count of users for each genre.
     -- 11. Retrieve the distinct devices used by users.
     -- 12. Get the engagement metrics for users who gave feedback or ratings.
     -- 13. Find the usernames of users who had customer support interactions.
     -- 14. Identify the users who have memberships ending within a certain date range (in February 2025).
     -- 15. List the users who have used a specific device (Tablet).
     -- 16. Calculate the total feedback or ratings given by users.
     -- 17. Get the usernames of users who have renewed their subscription.
     -- 18. Find the usernames of users who have not made any purchases.
     -- 19. Identify the most frequently used device among users.
     -- 20. List the usernames and their corresponding locations for users who are highly engaged.




   -- 01. Retrieve the names and email addresses of all users.--
   
         SELECT name, email_address FROM am_data ORDER BY name LIMIT 10;
         
         
	-- 02. Find the number of users by gender. --
    
         SELECT gender, count(*) AS total_users FROM am_data group by gender ;
         
         
		
	-- 03. Get the usernames and membership start dates of users who joined before a certain date (2024-03-13).--
    
         SELECT username, membership_start_date FROM am_data WHERE membership_start_date < '2024-03-13' order by membership_start_date ;
         
         
         
	-- 04. Count the number of users from a specific location (let's say, locations that contains Port). 
         
         SELECT 
             location, COUNT(*) AS total_users 
		 FROM am_data
		 GROUP BY location 
         HAVING location LIKE '%Port%' 
         ORDER BY total_users DESC LIMIT 10;


     -- 05. List the subscription plans along with the count of users subscribed to each plan. --
     
         SELECT
             subscription_plan, COUNT(*) AS total_users
         FROM am_data
         GROUP BY subscription_plan 
		 ORDER BY total_users DESC ;
         
         
	-- 06. Find the usernames and their corresponding payment information. --
	
    delimiter //
         SELECT username,
			CASE 
			    WHEN COUNT(DISTINCT payment_information) > 1
			    THEN GROUP_CONCAT(DISTINCT payment_information)
				ELSE MAX(payment_information) END
			AS aggregated_payment_information 
		 FROM am_data
		 GROUP BY username 
		 HAVING COUNT(DISTINCT payment_information) > 1
		 ORDER BY username LIMIT 10 ;
	delimiter ;
 
	
    -- 07. Identify the renewal status of each user's subscription. --
    
    SELECT username, renewal_status FROM am_data ORDER BY renewal_status LIMIT 10 ;
    
    
    -- 08. Calculate the average usage frequency of all users. --
    
    -- Define a mapping for usage frequency categories to numerical values
      WITH usage_frequency_mapping AS(
           SELECT 'Frequent' AS category, 3 AS numeric_value
           UNION ALL 
           SELECT 'Regular' AS category, 2 AS numeric_value
           UNION ALL
           SELECT 'Occasional' AS category, 1 AS numeric_value
)

   -- Create a new column with numerical  values based on the mapping 
	,mapped_data AS (
          SELECT df.*, um.numeric_value AS usage_frequency_numeric
          FROM am_data df
          JOIN usage_frequency_mapping um ON df.usage_frequency = um.category
)

   -- Calculate the average usage frequency 
          SELECT ROUND(AVG(usage_frequency_numeric),2) AS average_usage_frequency 
          FROM mapped_data ;
          
          
   -- 09. Determine the number of users with a specific purchase history. --
   
           SELECT COUNT(*) AS clothing_users FROM am_data
           WHERE purchase_history = 'Clothing' ;
           
           
	-- 10. List the favorite genres of users along with the count of users for each genre. --
          
           SELECT favorite_genres AS genre, COUNT(*) AS total_users
           FROM am_data
           GROUP BY favorite_genres
           ORDER BY total_users DESC ;
           
	
    -- 11. Retrieve the distinct devices used by users. --
    
           SELECT DISTINCT devices_used FROM am_data ;
    
    
	-- 12. Get the engagement metrics for users who gave feedback or ratings. --
    
           SELECT user_id, engagement_metrics, feedback_ratings
           FROM am_data 
           WHERE feedback_ratings IS NOT NULL LIMIT 10 ;
           
                 -- Average Ratings --
                 
           WITH engagement_records AS (SELECT user_id, engagement_metrics as engagement, feedback_ratings as ratings
		   FROM am_data
           WHERE feedback_ratings IS NOT NULL)
           SELECT engagement, ROUND(SUM(ratings), 2) AS sum_ratings, ROUND(AVG(ratings),2) AS avg_ratings FROM engagement_records GROUP BY engagement;
           
           
	-- 13. Find the usernames of users who had customer support interactions. --
    
            SELECT username, customer_support_interactions
            FROM am_data
            WHERE customer_support_interactions !=0 LIMIT 10;
            
            -- Total users customer support interactions --
            
            WITH csi_records AS (SELECT username, customer_support_interactions
			FROM am_data
            WHERE customer_support_interactions !=0)
            SELECT customer_support_interactions, COUNT(username) AS total_users
            FROM csi_records
            GROUP BY customer_support_interactions
            ORDER BY customer_support_interactions;
    
    
    -- 14. Identify the users who have memberships ending within a certain date range (in February 2025). --
    
            SELECT
                 user_id, name, username, email_address,
                 renewal_status, devices_used, membership_start_date, membership_end_date
            FROM am_data
            WHERE membership_end_date >= '2025-02-01' AND membership_end_date < '2025-03-01'
            LIMIT 10;
            
            
            WITH february_ending_records AS (
                  SELECT
                  user_id, name, username, email_address,
                  renewal_status, devices_used, membership_start_date, membership_end_date
            FROM am_data
            WHERE membership_end_date >= '2025-02-01' AND membership_end_date < '2025-03-01'
            )
            SELECT renewal_status, COUNT(user_id) AS total_users FROM february_ending_records 
            GROUP BY renewal_status;
            
            
            WITH february_ending_records AS (
				 SELECT
                 user_id, name, username, email_address,
                 renewal_status, devices_used, membership_start_date, membership_end_date
		   FROM am_data
           WHERE membership_end_date >= '2025-02-01' AND membership_end_date < '2025-03-01'
		   )
           SELECT devices_used, COUNT(user_id) AS total_users FROM february_ending_records 
           GROUP BY devices_used;
           
            
	-- 15. List the users who have used a specific device (Tablet). --
    
           SELECT
                user_id, name, username, email_address, renewal_status
           FROM am_data
           WHERE devices_used = 'Tablet'
           LIMIT 10 ;
    
    
    -- 16. Calculate the total feedback or ratings given by users. --
         
          SELECT username, ROUND(SUM(feedback_ratings), 2) AS total_ratings
          FROM am_data
          GROUP BY username
          ORDER BY total_ratings DESC LIMIT 10 ; 
          
          
	-- 17. Get the usernames of users who have renewed their subscription. --
    
		 SELECT user_id, username, devices_used FROM am_data WHERE renewal_status = 'Auto-Renew'  LIMIT 10;
             
     
	-- 18. Find the usernames of users who have not made any purchases. --
    
         SELECT username FROM am_data WHERE purchase_history IS null ;
         
         
    -- 19. Identify the most frequently used device among users. --
         
         WITH devices AS (
			    SELECT devices_used AS device, COUNT(user_id) AS total_users FROM am_data
                GROUP BY devices_used
		 )
         SELECT device FROM devices WHERE total_users = (SELECT MAX(total_users) FROM devices);
         
	
    -- 20. List the usernames and their corresponding locations for users who are highly engaged. --
    
         SELECT name, username, location, devices_used AS device, favorite_genres AS genre
		 FROM am_data
         WHERE engagement_metrics = 'High'
         ORDER BY location
         LIMIT 10 ;
         
         
         WITH high_engagement AS (
               SELECT name, username, location, devices_used AS device, favorite_genres AS genre
			   FROM am_data
               WHERE engagement_metrics = 'High'
		)
        SELECT genre, COUNT(name) AS total_users FROM high_engagement GROUP BY genre ;
        
        
        WITH high_engagement AS (
				SELECT name, username, location, devices_used AS device, favorite_genres AS genre
                FROM am_data
                WHERE engagement_metrics = 'High'
        )
        SELECT device, COUNT(name) AS total_users FROM high_engagement GROUP BY device;
   

    
           
   