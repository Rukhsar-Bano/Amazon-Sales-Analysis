---#Connect the Database
use Amazon

---Display the Data
select * from amazon_Data

---check the Numbers of Rows And Columns
select COUNT(*) as Total_rows from amazon_Data

select COUNT(*) as Total_columns
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='amazon_Data';

---# Display Column Name

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'amazon_Data';

---#Check Datatypes

EXEC sp_columns amazon_Data;

---Check the Null values

---#1.How does the discount percentage affect the rating of a product?

select discount_percentage,round(avg(rating),1) as avg_rating from amazon_Data
group by discount_percentage order by avg_rating desc;

---#2.Which category has the highest average rating?

-- #Add a new column to store the first part of the category
ALTER TABLE amazon_Data ADD first_category NVARCHAR(255);

-- #Update the new column with the value before the first '|'
UPDATE amazon_Data
SET first_category = LEFT(category, CHARINDEX('|', category + '|') - 1);

-- #View the results
SELECT category, first_category
FROM amazon_Data;

select first_category , round(AVG(rating),2) as avg_rating_pro
from amazon_Data group by first_category order by avg_rating_pro desc;


---#3.Is there a correlation between the product's price and its rating?

SELECT 
    actual_price, 
    round(AVG(rating),2) AS avg_rating, 
    COUNT(rating) AS cnt_review
FROM 
    amazon_Data
where
actual_price IS NOT NULL AND actual_price <> ''  -- Exclude empty or NULL descriptions
    AND rating IS NOT NULL  -- Exclude rows where rating is NULL
GROUP BY 
    actual_price order by avg_rating desc;


---#4.What is the most common word in the positive and negative reviews?

WITH WordList AS (
    SELECT value AS word
    FROM amazon_Data
    CROSS APPLY STRING_SPLIT(review_title, ',')  -- Split the review text into words by space
    WHERE review_title IS NOT NULL
)
SELECT word, COUNT(*) AS word_count
FROM WordList
where word IS NOT NULL
GROUP BY word
ORDER BY word_count DESC;  -- Returns the most common word


---#5.What is the distribution of ratings across all products?

select rating,COUNT(rating) as Rating_count from amazon_Data
where rating is not null group by rating;

---#6.Which product has the highest number of reviews and what is its rating?

select product_name, COUNT(rating) as Total_rating from
amazon_Data group by product_name order by Total_rating Desc;

---#7.Identify the top 5 users who have given the most reviews?

select user_id, count(review_title) as Top_Review from
amazon_Data group by user_id order by Top_Review desc;

---#8.Is there a correlation between the length of a review and the rating given?

-- Step 1: Calculate Correlation
SELECT 
    LEN(review_title) AS len_review, 
    AVG(rating) AS avg_rating, 
    COUNT(rating) AS cnt_review
FROM 
    amazon_Data
where
review_title IS NOT NULL AND review_title <> ''  -- Exclude empty or NULL descriptions
    AND rating IS NOT NULL  -- Exclude rows where rating is NULL
GROUP BY 
    LEN(review_title) order by avg_rating Desc;

---#9.Does having an image link affect the product rating?

SELECT 
    CASE 
        WHEN img_link IS NOT NULL THEN 'Has Image' 
        ELSE 'No Image' 
    END AS image_status,  -- Categorizes products
    AVG(rating) AS avg_rating,       -- Calculates average rating for the group
    COUNT(*) AS product_count        -- Counts number of products in each group
FROM 
    amazon_Data
GROUP BY 
    CASE 
        WHEN img_link IS NOT NULL THEN 'Has Image' 
        ELSE 'No Image' 
    END;  -- The exact CASE logic from SELECT is repeated in GROUP BY



---#10.Can the length of the product description be correlated to the product's rating?

SELECT 
    LEN(about_product) AS len_desc, 
    AVG(rating) AS avg_rating, 
    COUNT(rating) AS cnt_review
FROM 
    amazon_Data
where
about_product IS NOT NULL AND about_product <> ''  -- Exclude empty or NULL descriptions
    AND rating IS NOT NULL  -- Exclude rows where rating is NULL
GROUP BY 
    LEN(about_product) order by avg_rating;



