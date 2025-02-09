-- Создаём таблицы для таблиц и импортируем в них данные средствами импорта DBeaver
create table transaction_hw2 (transaction_id int
							, product_id int
							, customer_id int
							, transaction_date date
							, online_order boolean
							, order_status varchar(16)
							, brand varchar(128)
							, product_line varchar(16)
							, product_class	varchar(16)
							, product_size varchar(16)
							, list_price numeric(16, 2)
							, standard_cost numeric(16, 2)
)

create table customer_hw2 (customer_id int
						, first_name varchar(64)
						, last_name	varchar(64)
						, gender varchar(64)
						, DOB date
						, job_title	varchar(128)
						, job_industry_category	varchar(128)
						, wealth_segment varchar(64)
						, deceased_indicator varchar(4)
						, owns_car varchar(4)
						, address varchar(512)
						, postcode varchar(32) -- хотя по данным кажется, что это число, но, вообще говоря, почтовый индекс может быть буквами и первый ноль тоже значим
						, state	varchar(64)
						, country varchar(128)
						, hw2 int

)


-- Проверим, что таблицы заполнены и количсество записей совпадает с количеством в первоначальном файле:
select * from transaction_hw2
select * from customer_hw2
select count(*) from transaction_hw2 -- 20000
select count(*) from customer_hw2 -- 4000


-- Вывести все уникальные бренды, у которых стандартная стоимость выше 1500 долларов.
select distinct brand 
from transaction_hw2 
where standard_cost > 1500

-- Вывести все подтвержденные транзакции за период '2017-04-01' по '2017-04-09' включительно.
-- Смотрим какие статусы заказов бывают: select distinct order_status from transaction_hw2 - Результат: Approved, Cancelled
select * 
from transaction_hw2 
where transaction_date between '2017-04-01' and '2017-04-09' and order_status = 'Approved'

-- Вывести все профессии у клиентов из сферы IT или Financial Services, которые начинаются с фразы 'Senior'.
select distinct job_title
from customer_hw2
where lower(job_industry_category) in ('it', 'financial services') -- хотя в этитх данных такого нет, но на практике лучше делать регистро независимые запросы, если на зависимость от регистра нет специальных требований.
and lower(job_title) like 'senior%' 

-- Вывести все бренды, которые закупают клиенты, работающие в сфере Financial Services
select distinct t.brand
from transaction_hw2 t
inner join customer_hw2 c on t.customer_id = c.customer_id
where lower(c.job_industry_category) = 'financial services'

-- Вывести 10 клиентов, которые оформили онлайн-заказ продукции из брендов 'Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles'.
select distinct c.*
from customer_hw2 c
inner join transaction_hw2 t on c.customer_id = t.customer_id
where t.online_order 
and lower(t.brand) in ('giant bicycles', 'norco bicycles', 'trek bicycles')
limit 10

-- Вывести всех клиентов, у которых нет транзакций.
select *
from customer_hw2 c
where not exists (select 1
				  from transaction_hw2 t
				  where t.customer_id = c.customer_id
   				 )

-- Вывести всех клиентов из IT, у которых транзакции с максимальной стандартной стоимостью.
-- Вариант 1
select distinct c.*
from customer_hw2 c
inner join transaction_hw2 t on c.customer_id = t.customer_id
where lower(c.job_industry_category) = 'it'
and t.standard_cost = (select max(tt.standard_cost)
					   from transaction_hw2 tt
					  )
-- Вариант 2
select * 
from customer_hw2 c
where lower(c.job_industry_category) = 'it'
and exists (select 1
			from transaction_hw2 t
			where t.standard_cost = (select max(tt.standard_cost) from transaction_hw2 tt)
			and t.customer_id = c.customer_id
		   )
			

-- Вывести всех клиентов из сферы IT и Health, у которых есть подтвержденные транзакции за период '2017-07-07' по '2017-07-17'.
-- Вариант 1
select distinct c.*
from customer_hw2 c
join transaction_hw2 t on c.customer_id = t.customer_id
where lower(c.job_industry_category) in ('it', 'health')
and t.transaction_date between '2017-07-07' and '2017-07-17'
and t.order_status = 'Approved'

-- Вариант 2
select *
from customer_hw2 c
where lower(c.job_industry_category) in ('it', 'health')
and exists (select 1
			from transaction_hw2 t
			where t.customer_id = c.customer_id
			and t.transaction_date between '2017-07-07' and '2017-07-17'
			and t.order_status = 'Approved'
		   )







