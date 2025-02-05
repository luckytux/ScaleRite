import os
import pyodbc
import msal
import requests
from flask import Flask, jsonify
from dotenv import load_dotenv

# ✅ Load environment variables first
load_dotenv()

# ✅ Define variables after loading .env
SQL_SERVER = os.getenv("AZURE_SQL_SERVER", "southernscale.database.windows.net")
DATABASE = os.getenv("AZURE_DATABASE", "ScaleRite Backend")  # Ensure database name is correct
TENANT_ID = os.getenv("AZURE_TENANT_ID", "5adace38-704b-416e-979f-297e63c0483e")
CLIENT_ID = os.getenv("AZURE_CLIENT_ID")
CLIENT_SECRET = os.getenv("AZURE_CLIENT_SECRET")

# ✅ Debug: Print variables to check if they are loaded
print("\n--- ENVIRONMENT VARIABLES DEBUG ---")
print("SQL Server:", SQL_SERVER)
print("Database:", DATABASE)
print("Client ID:", CLIENT_ID)
print("Client Secret:", "Set" if CLIENT_SECRET else "Missing")
print("--- END DEBUG ---\n")

app = Flask(__name__)

# ✅ Entra ID Configuration
AUTHORITY = f"https://login.microsoftonline.com/{TENANT_ID}"
SCOPE = ["https://database.windows.net/.default"]

# ✅ Function to get access token
def get_sql_access_token():
    try:
        if "WEBSITE_SITE_NAME" in os.environ:  # Running on Azure
            identity_endpoint = "http://169.254.169.254/metadata/identity/oauth2/token"
            headers = {"Metadata": "true"}
            params = {"api-version": "2019-08-01", "resource": "https://database.windows.net/"}
            
            response = requests.get(identity_endpoint, headers=headers, params=params)
            response.raise_for_status()
            token = response.json().get("access_token")

        else:  # Running locally, use Service Principal
            if not CLIENT_ID or not CLIENT_SECRET:
                raise ValueError("AZURE_CLIENT_ID and AZURE_CLIENT_SECRET must be set for local authentication")

            app = msal.ConfidentialClientApplication(CLIENT_ID, authority=AUTHORITY, client_credential=CLIENT_SECRET)
            result = app.acquire_token_for_client(SCOPE)

            if "access_token" in result:
                token = result["access_token"]
            else:
                raise Exception(f"Failed to get token: {result.get('error_description')}")

        # ✅ Debug: Print token length
        print("\n--- ACCESS TOKEN DEBUG ---")
        print("Access Token Retrieved:", "Yes" if token else "No")
        print("Access Token Length:", len(token) if token else "None")
        print("--- END DEBUG ---\n")

        return token

    except Exception as e:
        raise Exception(f"Authentication failed: {e}")

# ✅ Function to connect to Azure SQL
def get_db_connection():
    try:
        conn_str = (
            "DRIVER={ODBC Driver 18 for SQL Server};"
            f"SERVER=tcp:{SQL_SERVER},1433;"
            f"DATABASE={DATABASE};"
            "Encrypt=yes;"
            "TrustServerCertificate=no;"
            "Connection Timeout=30;"
            "Authentication=ActiveDirectoryServicePrincipal;"  # ✅ FIXED
            f"UID={CLIENT_ID};"  # ✅ Use Service Principal Client ID
            f"PWD={CLIENT_SECRET};"  # ✅ Use Service Principal Client Secret
        )

        print("\n--- DATABASE CONNECTION DEBUG ---")
        print("SQL Server:", SQL_SERVER)
        print("Database:", DATABASE)
        print("Using Authentication: ActiveDirectoryServicePrincipal")
        print("Connection String:", conn_str)
        print("--- END DEBUG ---\n")

        conn = pyodbc.connect(conn_str)
        return conn

    except Exception as e:
        print("Database connection failed:", str(e))
        raise Exception(f"Database connection failed: {e}")

# ✅ Flask Routes
@app.route("/")
def home():
    return "Azure Flask API with Entra ID authentication is running!"

@app.route("/customers", methods=["GET"])
def get_customers():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT id, business_name, customer_name, address, city, province, postal_code, 
                   phone_number, invoice_email, report_email, notes, created_at 
            FROM Customers
        """)
        rows = cursor.fetchall()

        if not rows:
            return jsonify({"message": "No customers found"}), 200  # ✅ Handle empty response

        customers = [
            {
                "id": row[0],
                "business_name": row[1],
                "customer_name": row[2],
                "address": row[3],
                "city": row[4],
                "province": row[5],
                "postal_code": row[6],
                "phone_number": row[7],
                "invoice_email": row[8],
                "report_email": row[9],
                "notes": row[10],
                "created_at": row[11].strftime("%Y-%m-%d %H:%M:%S") if row[11] else None
            }
            for row in rows
        ]

        conn.close()
        return jsonify(customers)

    except Exception as e:
        print("\n--- SQL ERROR DEBUG ---")
        print("Error Message:", str(e))
        print("--- END DEBUG ---\n")
        return jsonify({"error": str(e)}), 500

# ✅ Run Flask
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
