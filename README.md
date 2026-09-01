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


# Week 3:
    # Question 1:
        SELECT COUNT(*) AS record_count  
        FROM `arctic-operand-398220.zoomcamp.yellow_taxi_2024_external` 

        (answer = 20,332,093)


    # Question 2:
        SELECT COUNT(DISTINCT PULocationID) AS distinct_pickup_locations
        FROM `arctic-operand-398220.zoomcamp.yellow_taxi_2024_external`;

        SELECT COUNT(DISTINCT PULocationID) AS distinct_pickup_locations
        FROM `arctic-operand-398220.zoomcamp.yellow_taxi_2024` ;

        (answer = 0 MB for external and 155.12 MB for materialized)


    # Question 3:
        BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.


    # Question 4:
        SELECT COUNT(*) AS zero_fare_trips
        FROM `arctic-operand-398220.zoomcamp.yellow_taxi_2024_external`
        WHERE fare_amount = 0;

        (answer = 8,333)


    # Question 5:
        CREATE OR REPLACE TABLE
        `arctic-operand-398220.zoomcamp.yellow_taxi_2024_optimized`

        PARTITION BY DATE(tpep_dropoff_datetime)

        CLUSTER BY VendorID

        AS
        SELECT *
        FROM `arctic-operand-398220.zoomcamp.yellow_taxi_2024`;

        (answer = Partition by tpep_dropoff_datetime and Cluster on VendorID)


    # Question 6:
        310.24 MB for non-partitioned table and 26.84 MB for the partitioned table


    # Question 7:
        GCP Bucket


    # Question 8:
        True


    # Question 9:
        0 B.  There is no filters so BigQuery doesn't need to scan any columns.  Row count is available in the tables metadata which BigQuery can see.



    # ML Learning:
        Question: Can we predict trip distance from pickup location, drop-off location, time of day, and passenger count?

        Target to predict:  
            -trip_distance

        Input data features:
            -PULocationID
            -DOLocationID
            -passenger_count
            -pickup_hour
            -pickup_day_of_week

        Training Data:
            CREATE OR REPLACE MODEL
            `arctic-operand-398220.zoomcamp.trip_distance_model`
            OPTIONS (
            model_type = 'linear_reg',
            input_label_cols = ['trip_distance']
            ) AS

            SELECT
            trip_distance,
            CAST(PULocationID AS STRING) AS PULocationID,
            CAST(DOLocationID AS STRING) AS DOLocationID,
            passenger_count,
            EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
            EXTRACT(DAYOFWEEK FROM tpep_pickup_datetime) AS pickup_day_of_week
            FROM `arctic-operand-398220.zoomcamp.yellow_taxi_2024`
            WHERE MOD(
            ABS(FARM_FINGERPRINT(
                CONCAT(
                CAST(tpep_pickup_datetime AS STRING),
                CAST(PULocationID AS STRING),
                CAST(DOLocationID AS STRING)
                )
            )),
            100
            ) < 5
            AND trip_distance > 0
            AND trip_distance <= 100;


                Mean absolute error = 1.4078
                Mean squared error = 6.5934
                Mean squared log error = 0.193
                Median absolute error = 0.8877
                R squared = 0.6778


        Evaluate using data not used during training:

            SELECT *
            FROM ML.EVALUATE(
            MODEL `arctic-operand-398220.zoomcamp.trip_distance_model`,
            (
                SELECT
                trip_distance,
                CAST(PULocationID AS STRING) AS PULocationID,
                CAST(DOLocationID AS STRING) AS DOLocationID,
                passenger_count,
                EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
                EXTRACT(DAYOFWEEK FROM tpep_pickup_datetime) AS pickup_day_of_week
                FROM `arctic-operand-398220.zoomcamp.yellow_taxi_2024`
                WHERE MOD(
                ABS(FARM_FINGERPRINT(
                    CONCAT(
                    CAST(tpep_pickup_datetime AS STRING),
                    CAST(PULocationID AS STRING),
                    CAST(DOLocationID AS STRING)
                    )
                )),
                100
                ) BETWEEN 5 AND 9
                AND trip_distance > 0
                AND trip_distance <= 100
            )
            );
                "mean_absolute_error": "1.6033971988730935",
                "mean_squared_error": "4840.4992122161129",
                "mean_squared_log_error": "0.18773686681994203",
                "median_absolute_error": "0.88041263354680277",
                "r2_score": "-254.97024531311405",
                "explained_variance": "-254.96741852614554"


        Internal evaluation produced an R² of 0.6778, but a separate holdout sample revealed extreme negative predictions and a strongly negative R². This suggests the baseline linear model was unstable for sparse categorical location features and would require a different model or preprocessing strategy for production use.


        
# Week 4:

    # Question 1:
        answer: int_trips_unioned only.  This command dbt run --select +int_trips_unioned would include ancestors. 

    # Question 2: 
        answer: dbt will fail the test, returning a non-zero exit code.

    # Question 3:
        answer: 11,702

    # Question 4:
        SELECT
        pickup_zone, SUM(revenue_monthly_total_amount) AS total_revenue

        FROM `arctic-operand-398220.analytics_prod.fct_monthly_zone_revenues`
        WHERE service_type = 'Green'
        AND revenue_month >= DATE('2020-01-01')
        AND revenue_month <= DATE('2021-01-01')
        GROUP BY pickup_zone
        ORDER BY total_revenue desc
        LIMIT 1;

        answer: East Harlem North

    # Question 5:
        SELECT
        SUM(total_monthly_trips) AS total_trips

        FROM `arctic-operand-398220.analytics_prod.fct_monthly_zone_revenues`
        WHERE service_type = 'Green'
        AND revenue_month = DATE('2019-10-01')

        answer: 383,852

    # Question 6:
        answer: 43,244,693


# Week 5:

    # Question 1:
        answer: .bruin.yml and pipeline/ with pipeline.yml and assets/

    # Question 2:
        answer: time_interval

    # Question 3:
        answer: bruin run --var 'taxi_types=["yellow"]'

    # Question 4:
        answer: bruin run ingestion/trips.py --downstream

    # Question 5:
        answer: name: not_null

    # Question 6:
        answer: bruin lineage

    # Question 7:
        answer: --full-refresh


# Week 6:

    # Question 1: 
        answer: 4.2.0

    # Question 2:
        answer: 25MB

    # Question 3:
        df_yellow.createOrReplaceTempView("yellow")
        spark.sql("""
        SELECT COUNT(*) AS total_trips

        FROM yellow
        WHERE tpep_pickup_datetime >= '2025-11-15' AND tpep_pickup_datetime < '2025-11-16'

        """).show()
        answer: 162,604

    # Question 4:
        spark.sql("""
            SELECT
                tpep_pickup_datetime,
                tpep_dropoff_datetime,
                total_amount,
                trip_distance,
                fare_amount,
                timestampdiff(MINUTE, tpep_pickup_datetime, tpep_dropoff_datetime) AS trip_minutes,
                trip_minutes / 60 AS trip_hours
            FROM yellow
            ORDER BY trip_hours DESC
            LIMIT 10

        """).show()


        answer: 90.6 hours


    # Question 5:
        answer: 4040

    # Question 6:
        spark.sql("""
            SELECT
                Zone,
                COUNT(PULocationID) AS zone_frequency
            FROM joined
            GROUP BY Zone
            ORDER BY zone_frequency ASC
            LIMIT 1
    
        """).show()


        answer:  Governor's Island/Ellis Island/Liberty Island



# Week 7:

    # Question 1:



