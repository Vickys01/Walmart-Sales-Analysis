select * from walmart_data limit 5

select count(*) from walmart_data;

select payment_method,
count(*) from walmart_data
group by payment_method;

select count(distinct branch) from walmart_data

select max(quantity) from walmart_data

select min(quantity) from walmart_data

--------------Business Problems-----------------------
/*1.)What are the different payment methods, and how many transactions and
items were sold with each method? */

select payment_method, count(invoice_id) as number_of_transaction, 
sum(quantity) as Sold_Quantity
from walmart_data
group by payment_method;
--------------------------------------------------------------------------------------------------
-- 2.) Which category received the highest average rating in each branch?

select * from 
(select branch , category ,
avg(rating) as Avg_rating ,
Rank() over(partition by  branch order by avg(rating) desc) as Ranks
from walmart_data
group by 1 ,2) as alias
where ranks = 1

-----------------------------------------------------------------------------------------------------
/*3.) What is the busiest day of the week for each branch based on transaction
   volume?*/
select * from (   
select branch, 
DayName(date_format(date, '%d-%m-%y')) AS Formated_Date,
count(*) as no_transaction,
Rank() over(partition by branch order by count(*) Desc) as ranks
from walmart_data
group by 1 , 2
) as alias
where Ranks = 1 

----------------------------------------------------------------------------------------------------

-- 4.) How many items were sold through each payment method?


select payment_method,
sum(quantity) as Sold_Quantity
from walmart_data
group by payment_method;

-----------------------------------------------------------------------------------------------------
/*5.)What are the average, minimum, and maximum ratings for each category in
each city?*/

select category , city ,
min(rating) as min_rating,
max(rating) as max_rating,
avg(rating) as avg_rating
from walmart_data 
group by 1 , 2

-----------------------------------------------------------------------------------------------------

-- 6.)  What is the total profit for each category, ranked from highest to lowest?

select category ,
sum(profit_margin * Total_amount) as profit,
sum(Total_amount) as revenue
from walmart_data
group by 1
order by 3 desc

-----------------------------------------------------------------------------------------------------
-- 7.) What is the most frequently used payment method in each branch?
select * from 
(
select branch , payment_method, count(invoice_id) as number_of_transaction,
Rank () over(partition by branch order by count(*) desc) as ranks
from walmart_data
group by 1,2
) as alias
where ranks = 1

-----------------------------------------------------------------------------------------------------

/*8.)How many transactions occur in each shift (Morning, Afternoon, Evening)
across branches?*/

select  branch,
        case
             when hour(str_to_date(time, '%H:%i:%s')) < 12 then 'morning'
             when hour(str_to_date(time, '%H:%i:%s')) between 12 and 17 then 'afternoon'
             else 'evening'
             end day_time,
             count(*)
from walmart_data
group by 1 , 2
order by 1, 3 desc

-----------------------------------------------------------------------------------------------------
/*9.)Which branches experienced the largest decrease in revenue compared to
the previous year?*/
select * ,
year(date_format(date, '%d-%m-%y')) AS Formated_Date
from walmart_data

with revenue_2022 as (
select branch ,
sum(total_amount) as revenue
from walmart_data
where 
year(date_format(date, '%d-%m-%y'))  = 2022
group by 1
order by 1
),
revenue_2023 as 
 (
select branch ,
sum(total_amount) as revenue
from walmart_data
where 
year(date_format(date, '%d-%m-%y'))  = 2023
group by 1
order by 1
)
select lp.branch,
lp.revenue as last_year_revenue,
cp.revenue as cr_year_revenue ,
round((lp.revenue - cp.revenue)/lp.revenue * 100 ,2) as rev_dec_ratio
from revenue_2022 lp
join revenue_2023 cp
on lp.branch = cp.branch
where lp.revenue > cp.revenue
order by 4 desc
limit 5
