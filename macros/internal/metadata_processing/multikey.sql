{%- macro multikey(columns, prefix=none, condition=none, operator='AND') -%}

    {{- adapter.dispatch('multikey', 'datavault4dbt')(columns=columns, prefix=prefix, condition=condition, operator=operator) -}}

{%- endmacro %}

{%- macro default__multikey(columns, prefix=none, condition=none, operator='AND') -%}

    {%- if prefix is string -%}
        {%- set prefix = [prefix] -%}
    {%- endif -%}

    {%- if columns is string -%}
        {%- set columns = [columns] -%}
    {%- endif -%}

    {%- if condition in ['<>', '!=', '='] -%}
        {%- for col in columns -%}
            {%- if prefix -%}
                {{- datavault4dbt.prefix([col], prefix[0], alias_target='target') }} {{ condition }} {{ datavault4dbt.prefix([col], prefix[1]) -}}
            {%- endif %}
            {%- if not loop.last %} {{ operator }} {% endif -%}
        {% endfor -%}
    {%- else -%}
        {%- if datavault4dbt.is_list(columns) -%}
            {%- for col in columns -%}
                {{ (prefix[0] ~ '.') if prefix }}{{ col }} {{ condition if condition else '' }}
                {%- if not loop.last -%} {{ "\n    " ~ operator }} {% endif -%}
            {%- endfor -%}
        {%- else -%}
            {{ prefix[0] ~ '.' if prefix }}{{ columns }} {{ condition if condition else '' }}
        {%- endif -%}
    {%- endif -%}

{%- endmacro -%}