select * from {{ ref('stg__green_tripdata') }}
union all
select * from {{ ref('stg__yellow_tripdata') }}