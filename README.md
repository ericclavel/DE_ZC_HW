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
        