# 🏫 V V College Result & Analysis Web App (Frontend)

A modern **Flutter Web** application for **V V College of Engineering**, designed to manage and analyze student results, staff uploads, and admin controls — all in one beautiful interface.

---

## 🎯 Overview

This is the **frontend** of the project, built using **Flutter 3.x (Web)**.  
It connects to a planned **FastAPI backend** for authentication and data handling.

The app provides dedicated dashboards for **Students**, **Staff**, and **Admins**, with consistent UI and smooth navigation.

---

## ✨ Features

### 👨‍🎓 Student Dashboard
- View personal results and performance analysis  
- Access college notices  
- Manage student profile  

### 👩‍🏫 Staff Dashboard
- Upload student results  
- View class analysis and insights  
- Generate performance reports  

### 🧑‍💻 Admin Dashboard
- Approve / remove users  
- Manage staff and student roles  
- Upload college-wide notices (PDF support)

---

## 🎨 Design System

- **Primary Color:** `#B11116` (V V College Red)  
- **UI Style:** Clean white backgrounds, rounded corners, subtle shadows  
- **Navigation:** `Navigator.pushNamed` routes  
- **Framework:** Flutter Material 3  
- **Responsive:** Works on desktop and mobile browsers  

---

## 🧩 Pages Implemented

| Page | Description |
|------|--------------|
| `LoginPage` | Fake login for testing (student, staff, admin) |
| `StudentDashboard` | Cards for My Results, Analysis, Profile, Notices |
| `StaffDashboard` | Upload Results, Class Analysis, Reports |
| `AdminDashboard` | Manage Users, Upload Notices |
| `main.dart` | Handles routing and navigation |
| `theme.dart` | Defines the color palette and consistent styles |

---

## 🧠 Test Credentials (Fake Login)

| Role | Email | Password |
|------|--------|-----------|
| Student | `student@vvcoe.com` | `student123` |
| Staff | `staff@vvcoe.com` | `staff123` |
| Admin | `admin@vvcoe.com` | `admin123` |

---

## ⚙️ Tech Stack

| Category | Technology |
|-----------|-------------|
| **Framework** | Flutter 3.x (Web Build) |
| **State / Storage** | flutter_secure_storage |
| **API Client** | Dio |
| **Hosting** | Netlify |
| **Build Tool** | `flutter build web --release` |

---

## 🛠️ Setup & Run Locally

### 1️⃣ Clone the repository
```bash
git clone https://github.com/your-username/vvcoe-result-frontend.git
cd vvcoe-result-frontend
