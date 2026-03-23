USE CustomerBehaviourAnalysis


-- Revenue generated based on Male vs Female
SELECT  gender, SUM(CAST(purchase_amount_usd AS FLOAT)) as revenue
from dbo.ConsumerShoppingBehaviourr
group by gender


--Customer used Discount but still spend more than average
SELECT customer_id, category
FROM (
    SELECT 
        customer_id,
        category,
        CAST(purchase_amount_usd AS FLOAT) AS purchase_amount,
        AVG(CAST(purchase_amount_usd AS FLOAT)) OVER () AS avg_purchase
    FROM dbo.ConsumerShoppingBehaviourr
    WHERE discount_applied = 'Yes'

) t
WHERE purchase_amount > avg_purchase;


--top 5 products with highest average review rating
SELECT TOP 5 
    item_purchased,
    AVG(TRY_CAST(review_rating AS FLOAT)) AS avg_rating
FROM dbo.ConsumerShoppingBehaviourr
GROUP BY item_purchased
ORDER BY avg_rating DESC;

--Compare the average Purchse Amounts between Standard and Express Shipping.
SELECT shipping_type, AVG(purchase_amount_usd) as Average
FROM dbo.ConsumerShoppingBehaviourr
WHERE shipping_type in ('Standard' , 'Express')
GROUP BY shipping_type

--Who spends more? Subscribed or Un subscribed
SELECT subscription_status , COUNT(customer_id ), 
ROUND(AVG(CAST(purchase_amount_usd AS FLOAT )),2) as average_spend, 
ROUND(SUM(CAST(purchase_amount_usd as FLOAT )),2) as total_spend
FROM dbo.ConsumerShoppingBehaviourr 
GROUP BY subscription_status
ORDER BY average_spend , total_spend desc;

--Which product have higher purchases with discounts applied Top 5
SELECT 
    item_purchased,
    CAST(
        AVG(CASE WHEN discount_applied = 'Yes' THEN 1.0 ELSE 0 END) * 100
    AS DECIMAL(5,2)) AS discount_rate
FROM dbo.ConsumerShoppingBehaviourr
GROUP BY item_purchased
ORDER BY discount_rate DESC;


--Segmenting customers into new,returning, Loyal based on number of previous purchases
;WITH item_counts AS (
    SELECT 
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM dbo.ConsumerShoppingBehaviourr
    GROUP BY category, item_purchased
)

SELECT 
    item_rank, 
    category,
    item_purchased, 
    total_orders
FROM item_counts
WHERE item_rank <= 3
ORDER BY category, item_rank;


--. Are customers who are repeat buyers (more than 5 previous purchases) also likely to scrier

Select subscription_status, 
count(customer_id) as repeat_buyers
from dbo.ConsumerShoppingBehaviourr
where previous_purchases > 5
group by subscription_status

--What is the revenue contribution of each age group?

SELECT age_group,
SUM(CAST(purchase_amount_usd AS FLOAT)) AS total_revenue
FROM dbo.ConsumerShoppingBehaviourr
GROUP BY age_group
ORDER BY total_revenue DESC;