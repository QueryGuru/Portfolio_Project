import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus
import os

# --- 🔧 Configurations ---
csv_files = {
    "coviddeaths": r"C:\Users\v-jakapo\Desktop\Dataset\Covid\CovidDeaths.csv",
    "covidvaccinations": r"C:\Users\v-jakapo\Desktop\Dataset\Covid\CovidVaccinations.csv"
}
mysql_user = "root"
raw_password = "pass@123"
mysql_password = quote_plus(raw_password)  # Encode special characters
mysql_host = "localhost"
mysql_port = 3306
mysql_database = "portfolio_project"

# --- 🚀 Create SQLAlchemy engine ---
engine = create_engine(f"mysql+pymysql://{mysql_user}:{mysql_password}@{mysql_host}:{mysql_port}/{mysql_database}")

# --- 📥 Loop through CSV files and import ---
for table_name, file_path in csv_files.items():
    if os.path.exists(file_path):
        df = pd.read_csv(file_path)
        df.to_sql(name=table_name, con=engine, index=False, if_exists='replace')
        print(f"✅ Successfully imported '{file_path}' into table '{table_name}'.")
    else:
        print(f"❌ File not found: {file_path}")

