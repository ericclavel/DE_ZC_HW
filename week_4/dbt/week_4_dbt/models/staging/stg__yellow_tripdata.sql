{{ config(materialized='view') }}

with source as (
    select * 
    from {{ source('staging', 'yellow_tripdata') }}
),

renamed as (
    select
        
        {{ dbt_utils.generate_surrogate_key([
            'vendorid',
            'tpep_pickup_datetime'
        ]) }} as trip_id,

        unique_row_id,
        filename,
        
        -- identifiers (standardized naming for consistency across yellow/green)
        cast(vendorid as integer) as vendor_id,
        {{ safe_cast('ratecodeid', 'integer') }} as rate_code_id,
        cast(pulocationid as integer) as pickup_location_id,
        cast(dolocationid as integer) as dropoff_location_id,

        -- timestamps (standardized naming)
        cast(tpep_pickup_datetime as timestamp) as pickup_datetime,  -- tpep = Taxicab Passenger Enhancement Program (yellow taxis)
        cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,

        -- trip info
        cast(store_and_fwd_flag as string) as store_and_fwd_flag,
        cast(passenger_count as integer) as passenger_count,
        cast(trip_distance as numeric) as trip_distance,
        cast(null as integer) as trip_type,

        -- payment info
        cast(fare_amount as numeric) as fare_amount,
        cast(extra as numeric) as extra,
        cast(mta_tax as numeric) as mta_tax,
        cast(tip_amount as numeric) as tip_amount,
        cast(tolls_amount as numeric) as tolls_amount,
        cast(null as numeric) as ehail_fee,
        cast(total_amount as numeric) as total_amount,
        cast(improvement_surcharge as numeric) as improvement_surcharge,
        {{ safe_cast('payment_type', 'integer') }} as payment_type,
        cast(congestion_surcharge as numeric) as congestion_surcharge

    from source
    -- Filter out records with null vendor_id (data quality requirement)
    where vendorid is not null
        and tpep_pickup_datetime >= timestamp('2019-01-01')
        and tpep_pickup_datetime < timestamp('2021-01-01')
),

enriched as (

    select
        *,
        {{ get_payment_type_description('payment_type') }} as payment_type_description

    from renamed

)

select *
from enriched


{{ limit_data_if_test() }}