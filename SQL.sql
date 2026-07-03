create database customer_behavior;
use customer_behavior;
select * from customer_behavior;

-- Q1.#totle revenue of male and female
SELECT 
    gender, SUM(Purchase_Amount) AS revenue
FROM
    customer_behavior
GROUP BY gender;

-- Q2.#which customers used a discount but still spent more then the average purchase amount
SELECT 
    customer_id, purchase_amount
FROM
    customer_behavior
WHERE
    discount_applied = 'yes'
        AND purchase_amount >= (SELECT 
            AVG(purchase_amount)
        FROM
            customer_behavior);

-- Q3.#top 5 products with the highest average review rating??
SELECT 
    item_purchased,
    AVG(review_rating) AS 'Average product rating'
FROM
    customer_behavior
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC
LIMIT 5;

-- Q4.#compareing the average purchase amounts between standard and express shipping ??
SELECT 
    shipping_type, AVG(purchase_amount)
FROM
    customer_behavior
WHERE
    shipping_type IN ('standard' , 'express')
GROUP BY shipping_type;

-- Q5.#compare average spend and total revenue between subscribers and non-subscribers??
SELECT 
    subscription_status,
    COUNT(customer_id) AS total_customers,
    AVG(purchase_amount) AS avg_spend,
    SUM(purchase_amount) AS total_revenu
FROM
    customer_behavior
GROUP BY subscription_status;



# Q6.#which 5 products have the highest percentage of purchases with discounts??
SELECT 
    item_purchased,
    ROUND(100 * SUM(CASE
                WHEN discount_applied = 'yes' THEN 1
                ELSE 0
            END) / COUNT(*),
            2) AS discount_rate
FROM
    customer_behavior
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- Q7. segment customers into new, returning,and loyal based on their total number of previous purchases, and show the count of each segment. 
with customer_type as (
select Customer_ID, Previous_Purchases,
case
    when Previous_Purchases = 1 then 'new'
    when Previous_Purchases between 2 and 10 then 'returning'
    else'loyal'
    end as customer_segment 
from customer_behavior   
)

select customer_segment, count(*) as "number of customers"
from customer_type
group by customer_segment

-- Q8. What are the top 3 most purchased products within each category??
WITH item_counts AS (
    SELECT 
        category,
        item_purchased,
        COUNT(Customer_ID) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY COUNT(Customer_ID) DESC
        ) AS item_rank
    FROM customer_behavior 
    GROUP BY category, item_purchased
)

SELECT item_rank, category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <= 3;

-- Q9. Are customers who are repeat buyers (more than 5 previous) also likely to subscribe??
WITH repeat_buyers AS (
    SELECT 
        Customer_ID,
        CASE 
            WHEN Previous_Purchases > 5 THEN 'Repeat_Buyer'
            ELSE 'Non_Repeat'
        END AS buyer_type,
        Subscription_Status
    FROM customer_behavior
)
SELECT 
    buyer_type,
    Subscription_Status,
    COUNT(*) AS customer_count
FROM repeat_buyers
GROUP BY buyer_type, Subscription_Status
ORDER BY buyer_type, Subscription_Status;

-- Q10. what is the revenue contribution of each age group??
select age_group,
sum(Purchase_Amount) as total_revenue
from customer_behavior
group by Age_group
order by total_revenue desc;






