{{
    config(
        materialized='table'
    )
}}

with green_tripdata as (

    select
        trip_id,
        vendor_id,
        rate_code_id,
        pickup_location_id,
        dropoff_location_id,
        pickup_datetime,
        dropoff_datetime,
        store_and_fwd_flag,
        passenger_count,
        trip_distance,
        trip_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        ehail_fee,
        improvement_surcharge,
        total_amount,
        payment_type,
        payment_type_description,
        'Green' as service_type

    from {{ ref('stg__green_tripdata') }}

),

yellow_tripdata as (

    select
        trip_id,
        vendor_id,
        rate_code_id,
        pickup_location_id,
        dropoff_location_id,
        pickup_datetime,
        dropoff_datetime,
        store_and_fwd_flag,
        passenger_count,
        trip_distance,

        -- Green-specific field; preserve common schema
        cast(null as integer) as trip_type,

        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,

        -- Green-specific field; preserve common schema
        cast(null as numeric) as ehail_fee,

        improvement_surcharge,
        total_amount,
        payment_type,
        payment_type_description,
        'Yellow' as service_type

    from {{ ref('stg__yellow_tripdata') }}

),

trips_unioned as (

    select * from green_tripdata

    union all

    select * from yellow_tripdata

),

dim_zones as (

    select *
    from {{ ref('dim_zones') }}
    where borough != 'Unknown'

)

select

    -- trip identifiers
    trips.trip_id,
    trips.vendor_id,
    trips.service_type,
    trips.rate_code_id,

    -- pickup location
    trips.pickup_location_id,
    pz.borough as pickup_borough,
    pz.zone as pickup_zone,

    -- dropoff location
    trips.dropoff_location_id,
    dz.borough as dropoff_borough,
    dz.zone as dropoff_zone,

    -- trip timing
    trips.pickup_datetime,
    trips.dropoff_datetime,
    trips.store_and_fwd_flag,
    {{ get_trip_duration_minutes(
        'trips.pickup_datetime',
        'trips.dropoff_datetime'
    ) }} as trip_duration_minutes,

    -- trip metrics
    trips.passenger_count,
    trips.trip_distance,
    trips.trip_type,

    -- payment breakdown
    trips.fare_amount,
    trips.extra,
    trips.mta_tax,
    trips.tip_amount,
    trips.tolls_amount,
    trips.ehail_fee,
    trips.improvement_surcharge,
    trips.total_amount,
    trips.payment_type,
    trips.payment_type_description

from trips_unioned as trips

inner join dim_zones as pz
    on trips.pickup_location_id = pz.location_id

inner join dim_zones as dz
    on trips.dropoff_location_id = dz.location_id