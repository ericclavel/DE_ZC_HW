# Data Engineering Zoomcamp Homework

# Week 1:
    # Question 1: Run the following:
        docker run -it --entrypoint=bash python:3.13-slim
        pip --version
            *Returns pip 26.1.2

    # Question 2:
        postgres:5432

    # Question 3:
        SELECT COUNT(*)
        FROM public.green_taxi_data
        WHERE lpep_pickup_datetime >= '2025-11-01'
            AND lpep_pickup_datetime < '2025-12-01'
            AND trip_distance <= 1;

        (answer = 8007)

    # Question 4:
        SELECT CAST(lpep_pickup_datetime AS DATE) AS pickup_day, trip_distance
        FROM public.green_taxi_data
        WHERE trip_distance < 100
        ORDER BY trip_distance DESC
        LIMIT 1;

        (answer = 2025-11-14)

    # Question 5:
        SELECT z."Zone", COUNT(*) AS trip_count
        FROM public.green_taxi_data t
        JOIN public.zones z ON t."PULocationID" = z."LocationID"
        WHERE CAST(t."lpep_pickup_datetime" AS DATE) = '2025-11-18'
        GROUP BY z."Zone"
        ORDER BY trip_count DESC
        LIMIT 1;

        (answer = East Harlem North)

    # Question 6:
        SELECT do_z."Zone", t."tip_amount"
        FROM public.green_taxi_data t
        JOIN public.zones pu_z ON t."PULocationID" = pu_z."LocationID"
        JOIN public.zones do_z ON t."DOLocationID" = do_z."LocationID"
        WHERE pu_z."Zone" = 'East Harlem North'
            AND t."lpep_pickup_datetime" >= '2025-11-01'
            AND t."lpep_pickup_datetime" < '2025-12-01'

        ORDER BY "tip_amount" DESC
        LIMIT 1;
        
        (answer = Yorkville West)

    # Question 7:
        terraform init, terraform apply -auto-approve, terraform destroy


# Week 2:
    # Question 1:
        128.3 MiB

    # Question 2:
        green_tripdata_2020-04.csv

    # Question 3:
        SELECT COUNT(*) AS row_count
        FROM `YOUR_PROJECT.YOUR_DATASET.yellow_tripdata_2020_*`
        WHERE _TABLE_SUFFIX IN (
        '01', '02', '03', '04', '05', '06',
        '07', '08', '09', '10', '11', '12'
        );

        (answer = 24,648,499)

    # Question 4:
        CREATE OR REPLACE EXTERNAL TABLE `arctic-operand-398220.zoomcamp.green_2020_all_ext`
        OPTIONS (
        format = 'CSV',
        uris = ['gs://arctic-operand-398220-eclavel-hw/green_tripdata_2020-*.csv'],
        skip_leading_rows = 1
        );

        SELECT COUNT(*) AS row_count
        FROM `arctic-operand-398220.zoomcamp.green_2020_all_ext`;

        (answer = 1,734,051)


    # Question 5:
        SELECT COUNT(*) AS row_count
        FROM `arctic-operand-398220.zoomcamp.yellow_tripdata_2021_03`;

        (answer = 1,925,152)


    # Question 6:
        Add a timezone property set to America/New_York in the Schedule trigger configuration
