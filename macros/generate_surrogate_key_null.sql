{%- macro generate_surrogate_key_null(column_name) -%}
    case 
        when {{ column_name }} is not null and trim({{ column_name }}) <> '' then
            {{ dbt_utils.generate_surrogate_key([column_name]) }}
        else
            null
    end as id_{{ column_name }}
{%- endmacro -%}
