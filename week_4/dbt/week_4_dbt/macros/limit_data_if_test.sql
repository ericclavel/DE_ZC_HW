{% macro limit_data_if_test(row_limit=100)%}

    {% if var('is_test_run', default=true) %}
        limit {{ row_limit}}
    {% endif %}

{% endmacro %}

-- docker compose run --rm dbt build --target dev --vars '{is_test_run: false}' --