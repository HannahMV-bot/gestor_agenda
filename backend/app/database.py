import os

from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI")

if not MONGODB_URI:
    raise ValueError("No se encontró MONGODB_URI en el archivo .env")

client = MongoClient(MONGODB_URI)

database = client["gestor_agenda"]

users_collection = database["users"]
tasks_collection = database["tasks"]