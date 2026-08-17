{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('staging', 'fhv_tripdata') }}

),

renamed as (

    select

        {{ dbt_utils.generate_surrogate_key([
            'dispatching_base_num',
            'pickup_datetime',
            'dropOff_datetime',
            'PUlocationID',
            'DOlocationID',
            'Affiliated_base_number'
        ]) }} as trip_id,

        unique_row_id,
        filename,

        -- identifiers
        cast(dispatching_base_num as string) as dispatching_base_num,

        -- timestamps
        cast(pickup_datetime as timestamp) as pickup_datetime,
        cast(dropoff_datetime as timestamp) as dropoff_datetime,

        -- trip info
        cast(pulocationid as integer) as pickup_location_id,
        cast(dolocationid as integer) as dropoff_location_id,
        {{ safe_cast('SR_Flag', 'integer') }} as sr_flag,
        {{ safe_cast('Affiliated_base_number', 'string') }} as affiliated_base_number

    from source
    where dispatching_base_num is not null

)

select * from renamed

{{ limit_data_if_test() }}