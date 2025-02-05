import pyodbc

server = "southernscale.database.windows.net"
database = "ScaleRite Backend"
driver = "{ODBC Driver 18 for SQL Server}"

conn_str = (
    f"DRIVER={driver};"
    f"SERVER={server};"
    f"DATABASE={database};"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
)

try:
    conn = pyodbc.connect(conn_str)
    print("✅ ODBC Connection Successful!")
except Exception as e:
    print("❌ ODBC Connection Failed:", e)
