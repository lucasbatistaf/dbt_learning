select
    *
from
    --{{ source('dbt_learn_jinja', 'orders__shopify') }}
    {{ source('dbt_learn_jinja', 'orders__amazon') }}