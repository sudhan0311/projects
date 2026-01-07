CREATE DATABASE layoffs ;
USE layoffs;

-- EDA

-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!


SELECT * FROM lay ;

-- EASIER QUERIES

SELECT MAX(total_laid_off)
FROM lay ;



-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM lay 
WHERE Percentage_laid_off IS NOT NULL ;


-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT * FROM lay 
WHERE percentage_laid_off  = 1 ;
-- these are mostly startups it looks like who all went out of business during this time


-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT * FROM lay 
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- BritishVolt looks like an EV company, Quibi! I recognize that company - wow raised like 2 billion dollars and went under - ouch






-- SOMEWHAT TOUGHER AND MOSTLY USING GROUP BY--------------------------------------------------------------------------------------------------

-- Companies with the biggest single Layoff

SELECT company, total_laid_off
FROM lay 
ORDER BY 2 DESC 
LIMIT 5 ;
-- now that's just on a single day

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM lay 
GROUP BY company 
ORDER BY 2 DESC
LIMIT 10 ;




-- by location
SELECT location ,SUM(total_laid_off)
FROM lay
GROUP BY location 
ORDER BY 2 DESC 
LIMIT 10;


-- this it total in the past 3 years or in the dataset

SELECT country, SUM(total_laid_off)
FROM lay
GROUP BY country
ORDER BY 2 DESC ;


SELECT YEAR(date), SUM(total_laid_ofF)
FROM lay
GROUP BY YEAR(date)
ORDER BY 1 ASC ;


SELECT industry , SUM(total_Laid_off)
FROM layoffs.lay
GROUP BY industry 
ORDER BY 2 DESC ;


SELECT stage, SUM(total_laid_off)
FROM lay 
GROUP BY stage
ORDER BY 2 DESC ;





-- TOUGHER QUERIES------------------------------------------------------------------------------------------------------------------------------------
-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.
-- I want to look at 

WITH Company_Year AS 
(
  SELECT company, YEAR(STR_TO_DATE(date, '%m/%d/%Y')) AS years, SUM(total_laid_off) AS total_laid_off
  FROM lay
  GROUP BY company, years
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;


-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date,1,7) AS Dates, SUM(total_laid_off) AS total_laid_off
FROM lay
GROUP BY Dates
ORDER BY Dates ASC ;

-- now use it in a CTE so we can query off of it
	WITH DATE_CTE AS 
    (
    SELECT SUBSTRING(date,1,7) AS Dates , SUM(total_laid_off) AS total_laid_off
    FROM lay
    GROUP BY Dates 
    ORDER BY Dates ASC 
    )
    SELECT Dates, SUM(total_laid_off) OVER (ORDER BY Dates ASC) AS rolling_total_layoffs
    FROM DATE_CTE
    ORDER BY Dates ASC ;


