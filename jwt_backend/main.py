import os
import secrets
from datetime import datetime, timedelta
from typing import Optional

from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware
from jose import jwt, JWTError
from passlib.context import CryptContext
from pydantic import BaseModel
from dotenv import load_dotenv

# ==========================
# 🔐 Environment Setup
# ==========================
load_dotenv()  # Load .env if it exists

# Generate secret key if not found
if not os.getenv("SECRET_KEY"):
    generated_key = secrets.token_hex(32)
    with open(".env", "a") as f:
        f.write(f"\nSECRET_KEY={generated_key}\n")
    print(f"⚠️ No SECRET_KEY found. Generated one and saved to .env: {generated_key}")

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 1440))

# ==========================
# ⚙️ App Configuration
# ==========================
app = FastAPI()

# Allow all Flutter requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow Flutter frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================
# 🔧 Password & JWT Setup
# ==========================
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Temporary in-memory database (replace with MongoDB / PostgreSQL later)
users_db = {}  # {email: {"name":..., "email":..., "password_hash":..., "role":...}}

# ==========================
# 🧩 Data Models
# ==========================
class RegisterData(BaseModel):
    name: str
    email: str
    password: str
    role: str

class TokenData(BaseModel):
    access_token: str
    token_type: str = "bearer"

# ==========================
# 🛠 Helper Functions
# ==========================
def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": expire})
    encoded = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded

# ==========================
# 🚀 Routes
# ==========================

@app.get("/")
def home():
    return {"message": "✅ VVCOE JWT API running successfully!"}

# ----- Register -----
@app.post("/register")
async def register(data: RegisterData):
    if data.email in users_db:
        raise HTTPException(status_code=400, detail="Email already registered")

    users_db[data.email] = {
        "name": data.name,
        "email": data.email,
        "password_hash": hash_password(data.password),
        "role": data.role,
    }

    return {"message": "Registration successful"}

# ----- Login -----
@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    email = form_data.username
    password = form_data.password
    role = form_data.scopes[0] if form_data.scopes else None  # Flutter sends role here

    user = users_db.get(email)
    if not user or not verify_password(password, user["password_hash"]):
        raise HTTPException(status_code=400, detail="Invalid credentials")

    if role != user["role"]:
        raise HTTPException(status_code=403, detail="Role mismatch")

    token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token({"sub": email, "role": role}, token_expires)

    return {"access_token": access_token, "token_type": "bearer"}

# ----- Protected Route -----
@app.get("/protected")
async def protected(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user = payload.get("sub")
        role = payload.get("role")
        return {"message": f"Welcome {user}, your role is {role}"}
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

# ==========================
# ▶️ Run Command
# ==========================
# uvicorn main:app --host 0.0.0.0 --port 8000
