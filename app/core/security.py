import hashlib
import os
from dotenv import load_dotenv
from passlib.context import CryptContext

load_dotenv()

SECRET_KEY=os.getenv("SECRET_KEY","supersecret")
ALGORITHM=os.getenv("ALGORITHM","HS256")

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    prehashed = hashlib.sha256(password.encode("utf-8")).digest()
    return pwd_context.hash(prehashed)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    prehashed = hashlib.sha256(plain_password.encode("utf-8")).digest()
    return pwd_context.verify(prehashed, hashed_password)