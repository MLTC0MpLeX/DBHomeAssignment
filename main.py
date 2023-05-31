import time

import pyodbc
import json
import pandas as pd
import sys

# a) A global variable called conn where the database connection is stored.
conn = None

# a) A function called createConnection that accepts a server name, and a database name.
def createConnection(server, database):
    global conn
    try:
        conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+';Trusted_Connection=yes;')
    except pyodbc.Error as ex:
        print("An error occurred while connecting to the DBMS: ", ex)
        sys.exit(1)

# b) A function called closeConnection that accepts a database connection as a parameter
def closeConnection():
    global conn
    try:
        conn.close()
        sys.exit(0)
    except pyodbc.Error as ex:
        print("An error occurred while closing the connection: ", ex)
        sys.exit(1)

# d) A function called loadData that accepts a file path
def loadData(file_path):
    global conn
    try:
        with open(file_path) as f:
            data = json.load(f)

        # Access products list
        products = data['products']

        # Create a cursor object to execute SQL queries
        cursor = conn.cursor()

        # Iterate over products
        for product in products:
            # Convert the product dictionary to JSON format
            json_data = json.dumps(product)
            print(json_data)
            # Execute the SQL query with the JSON data as a parameter

            cursor.execute("INSERT INTO loading.json_data(JSONdata) VALUES (?)", json_data)

        # Commit the changes to the database
        conn.commit()
    except pyodbc.Error as ex:
        print("An error occurred in loadData: ", ex)
    except FileNotFoundError:
        print("The specified file does not exist: ", file_path)
    except Exception as e:
        print("A generic error occurred in loadData: ", e)

# e) A function called getRatings that accepts a decimal as a parameter.
def getRatings(rating):
    global conn
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT main.getProductsRating(?)", float(rating))
        data = cursor.fetchone()
        df = pd.read_json(data[0])
        print(df)
    except pyodbc.Error as ex:
        print("An error occurred in getRatings: ", ex)
    except Exception as e:
        print("A generic error occurred in getRatings: ", e)

# f) A function called showMenu
def showMenu():
    while True:
        print("1: Load Data")
        print("2: Get Products by Rating")
        print("3: Exit")
        option = input("Please choose an option: ")
        if option == "1":
            file_path = input("Please enter the file location: ")
            loadData(file_path)
        elif option == "2":
            rating = float(input("Please enter a rating from 1 to 5: "))
            getRatings(rating)
        elif option == "3":
            closeConnection()
        else:
            print("Invalid option, please choose again.")


createConnection('ARTEMIS\SQLEXPRESS', 'a3products')
showMenu()
