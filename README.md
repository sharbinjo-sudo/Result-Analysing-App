# 🏫 V V Result & Analysis Web App

A full-stack **college result and analysis system** for **V V College of Engineering**, inspired by *Stucor*, built with:

- 🌐 **Flutter Web** frontend  
- ⚙️ **FastAPI (Python)** backend  
- 🔐 **JWT authentication**  
- ☁️ **Netlify** + **Render/Railway** deployment

---

## 🚀 Overview

**V V Result & Analysis** simplifies result viewing, analysis, and management for students, staff, and administrators.

The system offers three dashboards with dedicated access and permissions:
- **Students** → View results, notices, and analysis
- **Staff** → Upload results, analyze performance
- **Admins** → Manage users, upload college-wide notices (PDF)

---

## 🧩 Project Modules

### 🖥️ Frontend — Flutter Web (`frontend/`)
- Built with **Flutter 3.x (Web build)**
- Hosted on **Netlify**
- Uses `flutter_secure_storage` for JWT storage
- Responsive design with college theme (`#B11116`)
- Navigation via `Navigator.pushNamed`

**Student Features:**
- My Results  
- Analysis  
- Profile  
- Notices  

**Staff Features:**
- Upload Results  
- Class Analysis  
- Student Insights  
- Reports  

**Admin Features:**
- User Approvals / Removals  
- Notice Upload (PDF)  

---

### ⚙️ Backend — FastAPI + JWT (`jwt_backend/`)
- Authentication via **JWT tokens**
- Role-based access control (Student / Staff / Admin)
- SQLAlchemy ORM + SQLite (Postgres ready)
- CORS enabled for Flutter Web
- File upload endpoints for PDFs
- Fully modular route-based structure

**Main API Routes:**
| Method | Endpoint | Description | Auth |
|--------|-----------|-------------|------|
| `POST` | `/auth/signup` | Register user | ❌ |
| `POST` | `/auth/login` | Login and get JWT | ❌ |
| `GET` | `/users/me` | Get user profile | ✅ |
| `POST` | `/results/upload` | Upload student results | ✅ (Staff) |
| `GET` | `/results/{reg_no}` | Fetch student result | ✅ |
| `POST` | `/notices/upload` | Upload PDF notice | ✅ (Admin) |
| `GET` | `/notices` | Fetch all notices | ✅ |

✅ — Requires `Authorization: Bearer <token>`

---

## 🎨 Design System (Frontend)

| Element | Style |
|----------|--------|
| Primary Color | `#B11116` (V V College Red) |
| Background | White |
| Cards | Rounded (radius 16), subtle shadows |
| Fonts | Material 3 defaults |
| Layout | Responsive grid & padding system |

---

## 🧠 Demo Credentials

| Role | Email | Password |
|------|--------|-----------|
| Student | `student@vvcoe.com` | `student123` |
| Staff | `staff@vvcoe.com` | `staff123` |
| Admin | `admin@vvcoe.com` | `admin123` |

*(Fake logins for testing frontend workflows)*

---

## ⚙️ Tech Stack

| Layer | Technology |
|--------|-------------|
| **Frontend** | Flutter 3.x (Web Build) |
| **Backend** | FastAPI (Python 3.10+) |
| **Auth** | JWT (python-jose) |
| **Database** | SQLite (dev), PostgreSQL (prod) |
| **HTTP Client** | Dio |
| **Storage** | flutter_secure_storage |
| **Hosting** | Netlify (frontend), Render / Railway (backend) |

---

## 🧩 Folder Structure

vv-result-analysis/
├── frontend/ # Flutter Web App
│ ├── lib/
│ │ ├── main.dart
│ │ ├── theme.dart
│ │ ├── pages/
│ │ ├── widgets/
│ │ └── services/
│ ├── web/
│ ├── pubspec.yaml
│ └── README.md
│
├── jwt_backend/ # FastAPI Backend
│ ├── main.py
│ ├── routes/
│ ├── auth/
│ ├── models/
│ ├── database.py
│ ├── requirements.txt
│ ├── .env
│ └── README.md
│
├── .gitignore
└── README.md # (this file)