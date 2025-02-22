{%- macro hash_columns(columns=none, multi_active_key=none, main_hashkey_column=none) -%}

    {{- adapter.dispatch('hash_columns', 'datavault4dbt')(columns=columns,
                                                          multi_active_key=multi_active_key,
                                                          main_hashkey_column=main_hashkey_column) -}}

{%- endmacro %}

{%- macro default__hash_columns(columns, multi_active_key, main_hashkey_column) -%}

{%- if columns is mapping and columns is not none -%}

    {%- for col in columns -%}

        {%- if datavault4dbt.is_something(multi_active_key) -%}
            {% if columns[col] is mapping and columns[col].is_hashdiff -%}
                {{- datavault4dbt.hash(columns=columns[col]['columns'], 
                                alias=col, 
                                is_hashdiff=columns[col]['is_hashdiff'],
                                multi_active_key=multi_active_key,
                                main_hashkey_column=main_hashkey_column) -}}

            {%- elif columns[col] is not mapping and (col|upper) == (main_hashkey_column | upper) -%}
                {{- datavault4dbt.hash(columns=columns[col],
                                alias=col,
                                is_hashdiff=false) -}}  

            {%- endif -%}

            {{- ", \n" if not loop.last -}}

        {%- else -%}          
            
            {% if columns[col] is mapping and columns[col].is_hashdiff -%}

                {{- datavault4dbt.hash(columns=columns[col]['columns'], 
                                alias=col, 
                                is_hashdiff=columns[col]['is_hashdiff']) -}}

            {%- elif columns[col] is not mapping -%}

                {{- datavault4dbt.hash(columns=columns[col],
                                alias=col,
                                is_hashdiff=false) -}}
            
            {%- elif columns[col] is mapping and not columns[col].is_hashdiff -%}

                {%- if execute -%}
                    {%- do exceptions.warn("[" ~ this ~ "] Warning: You provided a list of columns under a 'columns' key, but did not provide the 'is_hashdiff' flag. Use list syntax for PKs.") -%}
                {% endif %}

                {{- datavault4dbt.hash(columns=columns[col]['columns'], alias=col) -}}

            {%- endif -%}

        {{- ",\n" if not loop.last -}}

        {%- endif -%}
        
    {%- endfor -%}

{%- endif %}

{%- endmacro -%}
