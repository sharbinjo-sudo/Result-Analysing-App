# 🏫 V V Result & Analysis Web App

A full-stack **college result and analysis system** for **V V College of Engineering**, inspired by *Stucor & MyCamu*, built with:

- 🌐 **Flutter Web** frontend  
- ⚙️ **Django + Django REST Framework (DRF)** backend  
- 🔐 **JWT authentication (SimpleJWT)**  
- ☁️ **Netlify** + **Render/Railway** deployment  

---

## 🚀 Overview

**V V Result & Analysis** simplifies result viewing, performance analysis, and academic management for students, staff, and administrators.

The system provides three role-based dashboards with strict access control:

- **Students** → View results, notices, and analysis  
- **Staff** → Upload results, analyze class performance  
- **Admins** → Manage users and upload college-wide notices (PDF)  

---

## 🧩 Project Modules

### 🖥️ Frontend — Flutter Web (`frontend/`)
- Built with **Flutter 3.x (Web build)**  
- Hosted on **Netlify**  
- JWT stored securely using `flutter_secure_storage`  
- Responsive UI with college branding (`#B11116`)  
- Route-based navigation using `Navigator.pushNamed`  

**Student Features:**
- My Results  
- Performance Analysis  
- Profile  
- Notices  

**Staff Features:**
- Upload Results  
- Class-wise Analysis  
- Student Insights  
- Reports  

**Admin Features:**
- User Approval / Removal  
- Notice Upload (PDF)  

---

### ⚙️ Backend — Django + DRF + JWT (`django_backend/`)
- Django REST Framework API backend  
- Authentication via JWT (SimpleJWT)  
- Role-based access control (Student / Staff / Admin)  
- ORM using Django Models  
- SQLite (development) → PostgreSQL (production-ready)  
- CORS enabled for Flutter Web  
- Secure PDF file uploads  
- Modular app-based architecture  

---

## 🔐 Authentication & Authorization
- JWT-based login using **Access + Refresh tokens**  
- Tokens passed via:  
  ```
  Authorization: Bearer <access_token>
  ```
- Permissions enforced using custom DRF permission classes  

---

## 🔌 API Endpoints

| Method | Endpoint | Description | Access |
|--------|-----------|-------------|--------|
| `POST` | `/api/auth/signup/` | Register user | ❌ |
| `POST` | `/api/auth/login/` | Login (JWT) | ❌ |
| `POST` | `/api/auth/token/refresh/` | Refresh JWT | ❌ |
| `GET`  | `/api/users/me/` | Get user profile | ✅ |
| `POST` | `/api/results/upload/` | Upload student results | ✅ (Staff) |
| `GET`  | `/api/results/<reg_no>/` | Fetch student result | ✅ |
| `POST` | `/api/notices/upload/` | Upload PDF notice | ✅ (Admin) |
| `GET`  | `/api/notices/` | Fetch all notices | ✅ |

✅ — Requires JWT Authentication  

---

## 🎨 Design System (Frontend)

| Element | Style |
|----------|--------|
| Primary Color | `#B11116` (V V College Red) |
| Background | White |
| Cards | Rounded corners (16px), soft shadows |
| Fonts | Material 3 defaults |
| Layout | Responsive grid & padding system |

---

## 🧠 Demo Credentials (Testing Only)

| Role | Email | Password |
|------|--------|-----------|
| Student | `student@vvcoe.com` | `student123` |
| Staff   | `staff@vvcoe.com`   | `staff123` |
| Admin   | `admin@vvcoe.com`   | `admin123` |

⚠️ These are **fake credentials** for frontend testing only.  

---

## ⚙️ Tech Stack

| Layer | Technology |
|--------|-------------|
| **Frontend** | Flutter 3.x (Web Build) |
| **Backend** | Django 4.x + DRF |
| **Auth** | JWT (SimpleJWT) |
| **Database** | SQLite (Dev), PostgreSQL (Prod) |
| **HTTP Client** | Dio |
| **Storage** | flutter_secure_storage |
| **Hosting** | Netlify (Frontend), Render / Railway (Backend) |

---

## 🧩 Folder Structure

```
vv-result-analysis/
├── frontend/                 # Flutter Web App
│   ├── lib/
│   │   ├── main.dart
│   │   ├── theme.dart
│   │   ├── pages/
│   │   ├── widgets/
│   │   └── services/
│   ├── web/
│   ├── pubspec.yaml
│   └── README.md
│
├── django_backend/           # Django + DRF Backend
│   ├── vv_backend/
│   ├── users/
│   ├── results/
│   ├── notices/
│   ├── manage.py
│   ├── requirements.txt
│   ├── .env
│   └── README.md
│
├── .gitignore
└── README.md                 # Project documentation
```
