from pathlib import Path
import urllib.request
import pandas as pd
import pyarrow.parquet as pq
from sqlalchemy import create_engine

def main():
    year = "2025"
    month = "11"
    output_dir = Path("data")
    output_dir.mkdir(parents=True, exist_ok=True)

    #Get green taxi data set.
    green_url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_{year}-{month}.parquet"
    green_path = output_dir / f"green_tripdata_{year}-{month}.parquet"
    urllib.request.urlretrieve(green_url, green_path)

    #Get zones data set.
    zone_url = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv"
    zone_path = output_dir / "taxi_zone_lookup.csv"
    urllib.request.urlretrieve(zone_url, zone_path)

    # Read the zone lookup CSV
    df_zones = pd.read_csv(zone_path)

    # Create the database engine (using the service name 'db' from your docker-compose)
    engine = create_engine('postgresql://root:root@db:5432/ny_taxi')

    # Write the zone data to postgres
    df_zones.to_sql(name='zones', con=engine, if_exists='replace', index=False)
    print("Zones data inserted successfully!")

    # Define the data types for the green taxi data
    dtype = {
        "VendorID": "Int64",
        "passenger_count": "Int64",
        "trip_distance": "float64",
        "RatecodeID": "Int64",
        "store_and_fwd_flag": "string",
        "PULocationID": "Int64",
        "DOLocationID": "Int64",
        "payment_type": "Int64",
        "fare_amount": "float64",
        "extra": "float64",
        "mta_tax": "float64",
        "tip_amount": "float64",
        "tolls_amount": "float64",
        "improvement_surcharge": "float64",
        "total_amount": "float64",
        "congestion_surcharge": "float64"
    }
    # Read and insert the green taxi parquet file in chunks
    parquet_file = pq.ParquetFile(green_path)
    first_chunk = True

    for batch in parquet_file.iter_batches(batch_size=100000):
        df_chunk = batch.to_pandas()

        # Apply explicit data types, ignoring columns not present in the chunk
        existing_dtypes = {col: dt for col, dt in dtype.items() if col in df_chunk.columns}
        df_chunk = df_chunk.astype(existing_dtypes)

        # If it's the first chunk, replace the table; otherwise, append to it
        mode = 'replace' if first_chunk else 'append'
        df_chunk.to_sql(name='green_taxi_data', con=engine, if_exists=mode, index=False)
        
        first_chunk = False
        print(f"Inserted chunk of {len(df_chunk)} rows...")

    print("Green taxi data inserted successfully!")


if __name__ == "__main__":
    main()