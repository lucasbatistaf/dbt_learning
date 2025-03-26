{% macro grant_select(schema=target.dataset, name=target.name) %}

  {% set sql %}
    grant usage on schema {{ schema }} to name {{ name }};
    grant select on all tables in schema {{ schema }} to name {{ name }};
    grant select on all views in schema {{ schema }} to name {{ name }};
  {% endset %}

  {{ log('Granting select on all tables and views in schema ' ~ target.dataset ~ ' to name ' ~ name, info=True) }}
  {% do run_query(sql) %}
  {{ log('Privileges granted', info=True) }}

{% endmacro %}