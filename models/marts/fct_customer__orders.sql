-- Import CTE

with


customers as 
(

    select * from {{ ref('stg_jaffle_shop__customers_refactor') }}

),

orders as 
(

    select * from {{ ref('stg_jaffle_shop__orders_refactor') }}

),

payments as 
(

    select * from {{ ref('stg_stripe__payments_refactor') }}

),

customer_order_history as 
(
    select  
        customers.customer_id,
        customers.full_name,
        customers.surname,
        customers.givenname,
        min(order_date) as first_order_date,
        min(case when orders.order_status NOT IN ('returned','return_pending') then order_date end) as first_non_returned_order_date,
        max(case when orders.order_status NOT IN ('returned','return_pending') then order_date end) as most_recent_non_returned_order_date,
        COALESCE(max(user_order_seq),0) as order_count,
        COALESCE(count(case when orders.order_status != 'returned' then 1 end),0) as non_returned_order_count,
        sum(case when orders.order_status NOT IN ('returned','return_pending') then payments.payment_amount else 0 end) as total_lifetime_value,
        sum(case when orders.order_status NOT IN ('returned','return_pending') then payments.payment_amount else 0 end)/NULLIF(count(case when orders.order_status NOT IN ('returned','return_pending') then 1 end),0) as avg_non_returned_order_value,
        array_agg(distinct orders.order_id) as order_ids

    from orders
    join customers
    on orders.customer_id = customers.customer_id

    left outer join payments
    on orders.order_id = payments.order_id

    where orders.order_status NOT IN ('pending') and payments.payment_status != 'fail'

    group by customers.customer_id, customers.full_name, customers.surname, customers.givenname

),

-- Final CTEs

final as 
(

    select
        orders.order_id as order_id,
        orders.customer_id as customer_id,    
        customers.surname,
        customers.givenname,
        first_order_date,
        total_lifetime_value,
        payments.payment_amount as order_value_dollars,
        orders.order_status as order_status,
        payments.payment_status as payment_status

    from orders
    join customers as customers
    on orders.customer_id = customers.customer_id

    join customer_order_history
    on orders.customer_id = customer_order_history.customer_id

    left outer join payments
    on orders.order_id = payments.order_id

    where payments.payment_status != 'fail'

)

-- Simples Select Statement

select * from final