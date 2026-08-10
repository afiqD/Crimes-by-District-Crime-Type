with source as (
    select * from {{ source('bronze', 'crime_district_raw') }}
),

renamed as (
    select
        cast(date as date)        as crime_date,
        state,
        district,
        category                  as crime_category,
        type                      as crime_type,
        cast(crimes as integer)   as crime_count
    from source
    where crimes is not null
)

select * from renamed
