-- dbt staging model (Gold layer)

{{ config(materialized='view') }}

SELECT
  order_id,
  customer_id,
  order_ts,
  order_date,
  amount
FROM public.gold_orders
WHERE amount > 0
