-- {% macro grant_select(schema=target.dataset, role='roles/bigquery.dataViewer', user=target.profile_name) %}

--   {% set sql %}
--     grant usage on schema {{ schema }};
--     grant {{ role }} on all tables in schema {{ schema }} to {{ user }};
--     grant {{ role }} on all views in schema {{ schema }} to {{ user }};
--   {% endset %}

--   {{ log('Granting ' ~ role ~ ' on all tables and views in schema ' ~ target.dataset ~ ' to user ' ~ user, info=True) }}
--   {% do run_query(sql) %}
--   {{ log('Privileges granted', info=True) }}

-- {% endmacro %}