use sql_python;
CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);
     select * from df_orders;
     
     -- find top 10 higest revenue generating products
	
    SELECT 
    product_id, SUM(sale_price) AS sales
FROM
    df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;
     
-- find the top 5 highest seling product in region 

     select region , product_id, sell, rn  from
     (  select region, product_id, sum(sale_price) as sell,
       row_number()over(partition by region order by sum(sale_price) desc) as rn from df_orders group by region, product_id) t
        where rn<=5;
	
-- find month over month growth comparision for 2022 and 2023 sales eg; jan 2022  vs jan 2023

with cte as (
select year(order_date) as order_year, month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by order_year, order_month
)

select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

-- For each category which month had hieghest sales

with cte as(
select category , format(order_date, 'yyyyMM') as order_year_month,
sum(sale_price) as sales from df_orders
group by category, order_year_month
)

select * from 
( select *, row_number() over (partition by category order by sales desc) as rn from cte
) a
where rn=1;



-- Which sun category  had highest growth by profit in 2023 compare to 2022

with cte as (

select sub_category, year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category, order_year
),
cte2  as (
 select sub_category,
 sum(case when order_year=2022 then sales else 0 end ) as sales_2022,
 sum(case when order_year=2023 then sales else 0 end) as sales_2023
 from cte
 group by sub_category 
 )
 select sub_category, (sales_2023 - sales_2022)*100/sales_2022
 from cte2
 limit 1;
