-- 1. Find different payment method,number of transactions, number of quantity sold

select payment_method,
count(*) as Transaction_Count,
sum(quantity) as No_of_quantity_sold
from walmart
group by payment_method;

-- 2. Highest-rated category in each branch, displaying the branch, category & avg rating 

select *
from(
SELECT 
    branch,
    category,
    round(AVG(rating),2) as avg_rating,
    rank() over(partition by branch order by round(AVG(rating),2) desc) as `rank`
FROM
    walmart
GROUP BY branch , category) as t
where `rank` = 1;

-- 3. Busiest day based on no. of transactions

	select *
    from(    
    select branch,
	dayname(date) as Day_name,
	count(*) as no_of_transaction,
    rank() over(partition by branch order by count(*) desc) as `rank`
	from walmart
	group by branch,day_name) as t
    where `rank`=1;
	
-- 4. total quantity of item sold per payment method. List payment method and total quantity

select payment_method,
sum(quantity) as total_quantity
from walmart 
group by payment_method;

-- 5. determine average,minimum,max rating of product for each city.List city,average,min,max rating.
select City,
category,
min(rating) as min_rating,
max(rating) as max_rating,
round(avg(rating),2) as avg_rating
from walmart
group by City,category;

-- 6. total profit by each category by considering total_profit as unit_price*quantity*profit_margin.
-- list the category and total_profit,ordered from highest to lowest profit. 

select category,
sum(total) as total_revenue,
sum(total * profit_margin) as profit
from walmart
group by category;

-- 7. Most cpmmon payment method for each branch.display branch and preferred payment method.
select *
from(
select payment_method,
Branch,
count(payment_method) as common_method,
rank() over(partition by Branch order by count(payment_method) desc) as `rank`
 from walmart
 group by payment_method,Branch) as t
 where `rank`= 1;

-- 8. categorize sales in morning,afternoon and evening.find out no of invoices for each shift 
select * FROM walmart;

SELECT Branch,
    CASE
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) >= 12 and HOUR(time) < 17 THEN 'Afternoon'
        ELSE 'Evening'
    END day_time,
    COUNT(*) as Total_orders
FROM
    walmart
group by Branch,day_time
order by Branch,Total_orders;

-- 9. 5 branch with highest decrease ration in revenue compare to last year(current 2023,last 2022)

with revenue_2022
as
(
select
Branch,
sum(total) as Revenue
from walmart 
where year(date) = 2022
group by Branch
),

revenue_2023
as
(
select
Branch,
sum(total) as Revenue
from walmart 
where year(date) = 2023
group by Branch
)

select ls.Branch,
ls.revenue as last_year_revenue,
cs.revenue as current_year_revenue,
round((ls.revenue - cs.revenue)/ls.revenue * 100,2) as  decrease_ratio
from revenue_2022 ls
join
revenue_2023 cs
on 
ls.Branch = cs.Branch
where ls.revenue >cs.revenue
order by decrease_ratio desc
limit 5;
