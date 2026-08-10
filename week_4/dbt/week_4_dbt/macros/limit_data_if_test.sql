{% macro limit_data_if_test(row_limit=100)%}

    {% if var('is_test_run', default=true) %}
        limit {{ row_limit}}
    {% endif %}

{% endmacro %}