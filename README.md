# Our Moment App

A full-featured event management mobile application for creating, managing, and sharing memorable moments together. Supports both iOS and Android.

---

## Table of Contents

- [Features](#features)
- [Tech Stack & Architecture](#tech-stack--architecture)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Running the App](#running-the-app)
- [Environment Variables](#environment-variables)
- [Database Schema](#database-schema)

---

## Features

| Feature | Description |
|---|---|
| **Authentication** | Register / Login with Email & Password or Google Sign-In, JWT (Access + Refresh Token) |
| **Event Management** | Create, edit, delete events with Theme Color, Cover Image, and Join Code |
| **QR Code** | Generate QR Codes for event joining + Scan QR to Join / Check-in |
| **Guest Management** | Invite / manage guests, view status (Joined, Checked-in), manage allergy information |
| **Live Gallery** | Real-time photo uploads via Socket.IO, Multi-select for bulk delete / download |
| **Face Search (Face++)** | Automatic face detection on upload, find your own photos with a selfie via Face++ Search API + FaceSet |
| **Agenda** | Create event schedules, per-user reminders, automatic scheduler |
| **Wish Wall** | Guests can write wishes (1 per event per user) |
| **Event Analytics** | Attendee, photo, and wish statistics |
| **Location & Map** | Pin event location on map, navigate to venue |
| **Notifications** | Real-time in-app notifications + Background notifications |

---

## Tech Stack & Architecture

### Mobile App (Flutter)

| Category | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart SDK ^3.11.0) |
| **Architecture** | Feature-first structure organized by feature modules (auth, event, home, profile, notification) |
| **State Management** | StatefulWidget (local state) |
| **HTTP Client** | `http` package + Custom `ApiClient` wrapper |
| **Real-time** | `socket_io_client` (Socket.IO) |
| **Authentication** | JWT Token stored in `flutter_secure_storage`, Google Sign-In |
| **Camera & Gallery** | `image_picker`, `image_cropper` (TOCropViewController) |
| **QR Code** | `qr_flutter` (generate), `mobile_scanner` (scan) |
| **Map** | `flutter_map` + `latlong2` + `geolocator` |
| **Save to Gallery** | `gal` + `path_provider` |
| **Background Service** | `flutter_background_service` + `flutter_local_notifications` |
| **Sharing** | `share_plus` |
| **UI** | Custom theme system (`AppColors`, `AppTheme`), Reusable widgets |

### Backend (Node.js)

| Category | Technology |
|---|---|
| **Runtime** | Node.js + TypeScript |
| **Framework** | Express.js |
| **ORM** | Prisma (MySQL) |
| **Authentication** | JWT (Access + Refresh Token), `bcryptjs` for password hashing |
| **Validation** | `zod` |
| **File Upload** | `multer` + `sharp` (image processing/compression) |
| **Real-time** | `socket.io` |
| **QR Code** | `qrcode` |
| **Face Recognition** | Face++ API (`axios` + `form-data`) — Detect, FaceSet, Search |
| **Scheduler** | `node-cron` (agenda reminders) |
| **Dev Tools** | `ts-node-dev` (hot reload), Prisma Studio |

### Database

- **MySQL** — Relational database
- **Prisma** — ORM & migration tool

---

## Project Structure

```
our_moment_app/
├── MobileApp/                    # Flutter Mobile Application
│   ├── lib/
│   │   ├── main.dart             # App entry point
│   │   ├── core/                 # Shared core modules
│   │   │   ├── routes/           # App routing
│   │   │   ├── services/         # API client, token storage, background service
│   │   │   ├── theme/            # App colors, typography, theme
│   │   │   ├── utils/            # Utility functions
│   │   │   └── widgets/          # Reusable widgets (scaffold, buttons, etc.)
│   │   └── features/             # Feature modules
│   │       ├── auth/             # Login, Register, Forgot Password, Google Sign-In
│   │       ├── event/            # Event CRUD, Dashboard, Gallery, Agenda, Wishes
│   │       │   ├── data/         # Repositories (API calls)
│   │       │   └── presentation/ # Pages & Widgets
│   │       ├── home/             # Home page, Event listing
│   │       ├── notification/     # Notification list
│   │       └── profile/          # User profile, Edit profile
│   ├── assets/                   # Fonts, Images
│   ├── ios/                      # iOS native config (Podfile, Runner)
│   └── android/                  # Android native config
│
├── backend/                      # Node.js Backend API
│   ├── src/
│   │   ├── index.ts              # Server entry point
│   │   ├── app.ts                # Express app setup
│   │   ├── config/               # Database, Environment config
│   │   ├── middleware/            # Auth, Error handler, Upload, Validation, Role
│   │   ├── modules/              # Feature modules (REST API)
│   │   │   ├── auth/             # Register, Login, Google OAuth, Token refresh
│   │   │   ├── event/            # Event CRUD
│   │   │   ├── guest/            # Guest management, Check-in
│   │   │   ├── photo/            # Photo upload, Delete, Face search
│   │   │   ├── agenda/           # Agenda CRUD, Reminders
│   │   │   ├── wish/             # Wish wall
│   │   │   ├── analytics/        # Event statistics
│   │   │   ├── notification/     # Notifications
│   │   │   ├── location/         # Event location
│   │   │   └── user/             # User profile
│   │   └── shared/               # Shared utilities
│   │       ├── facepp.ts         # Face++ API integration
│   │       ├── image.ts          # Image processing (sharp)
│   │       ├── socket.ts         # Socket.IO setup
│   │       ├── storage.ts        # File storage management
│   │       ├── qr-code.ts        # QR code generation
│   │       └── scheduler.ts      # Cron job scheduler
│   ├── prisma/
│   │   └── schema.prisma         # Database schema
│   └── uploads/                  # Uploaded files (avatars, event photos)
│
└── README.md
└── our_moment_db.sql             # Database file if can't use prisma generate
```

---

## Prerequisites

- **Flutter SDK** >= 3.x (Dart SDK ^3.11.0)
- **Node.js** >= 18.x
- **MySQL** >= 8.0
- **Xcode** >= 16.x (for iOS builds)
- **Android Studio** (for Android builds)
- **CocoaPods** (for iOS dependencies)

---

## Installation & Setup

### 1. Clone Repository

```bash
git clone https://github.com/Sompong6103/our_moment_app.git
cd our_moment_app
```

### 2. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Create .env file (see example below)
cp .env.example .env
# Edit DATABASE_URL, JWT secrets, etc.

# Generate Prisma Client
npx prisma generate

# Push schema to database (sync schema → MySQL)
npx prisma db push

# (Optional) Browse database via Prisma Studio
npm run db:studio

# Start backend (development mode, port 3000)
npm run dev
```

### 3. Mobile App Setup

```bash
cd MobileApp

# Install Flutter dependencies
flutter pub get

# (iOS) Install CocoaPods dependencies
cd ios && pod install && cd ..

# Run the app on Simulator / Device
flutter run
```

---

## Running the App

### Backend

```bash
cd backend

# Development (hot reload)
npm run dev

# Production build
npm run build
npm start
```

### Mobile App

```bash
cd MobileApp

# Run with development environment
flutter run --dart-define-from-file=env/dev.env

# Run with production environment
flutter run --dart-define-from-file=env/prod.env

# Build for iOS release
flutter build ios --dart-define-from-file=env/prod.env

# Build for Android release
flutter build apk --dart-define-from-file=env/prod.env

# Hot reload: press r in terminal
# Hot restart: press R in terminal
```

---

## Environment Variables

### Backend (`backend/.env`)

```env
# Server
NODE_ENV=development
PORT=3000

# Database (MySQL)
DATABASE_URL="mysql://user:password@localhost:3306/our_moment_db"

# JWT
JWT_ACCESS_SECRET=your-access-secret-key
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Upload
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760

# App URLs
APP_URL=http://localhost:3000
FRONTEND_URL=ourmoment://

# Face++ API (https://www.faceplusplus.com)
FACEPP_API_KEY=your-facepp-api-key
FACEPP_API_SECRET=your-facepp-api-secret
FACEPP_BASE_URL=https://api-us.faceplusplus.com
```

### Mobile App (`MobileApp/env/dev.env` / `prod.env`)

Values are injected at build time via `--dart-define-from-file`. See `AppEnv` class for usage.

```env
# API_HOST includes port when needed (e.g. 192.168.1.102:3000)
# For production domains, omit the port (e.g. api.example.com)
API_HOST=192.168.1.102:3000
API_SCHEME=http
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_SERVER_CLIENT_ID=your-google-server-client-id
```

| Variable | Description | Example |
|---|---|---|
| `API_HOST` | Server host with optional port | `192.168.1.102:3000` or `api.example.com` |
| `API_SCHEME` | `http` or `https` | `http` (dev), `https` (prod) |
| `GOOGLE_CLIENT_ID` | Google OAuth iOS Client ID | `xxxx.apps.googleusercontent.com` |
| `GOOGLE_SERVER_CLIENT_ID` | Google OAuth Server/Web Client ID | `xxxx.apps.googleusercontent.com` |

---

## Database Schema

| Model | Description |
|---|---|
| `User` | User accounts (email, password, Google ID, avatar) |
| `RefreshToken` | JWT Refresh Token storage |
| `Event` | Events (title, date, theme, join code, status) |
| `Location` | Event venue (latitude, longitude, address) |
| `EventGuest` | User ↔ Event join table (status: joined, checked_in) |
| `AgendaItem` | Event schedule items |
| `AgendaReminder` | Per-user agenda reminders |
| `Photo` | Event photos (soft delete) |
| `PhotoFace` | Face tokens from Face++ (used with FaceSet Search) |
| `Wish` | Guest wishes (1 per user per event) |
| `Notification` | Notifications (ceremony, reminder, update, offer) |

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/register` | Register new account |
| POST | `/api/auth/login` | Login |
| POST | `/api/auth/google` | Google Sign-In |
| POST | `/api/auth/refresh` | Refresh access token |
| GET | `/api/events` | List events |
| POST | `/api/events` | Create event |
| GET | `/api/events/:id` | Get event details |
| PATCH | `/api/events/:id` | Update event |
| GET | `/api/events/:id/photos` | List photos |
| POST | `/api/events/:id/photos` | Upload photo |
| POST | `/api/events/:id/photos/face-search` | Search photos by face |
| POST | `/api/events/:id/photos/bulk-delete` | Bulk delete photos (Host only) |
| GET | `/api/events/:id/guests` | List guests |
| POST | `/api/events/:id/guests/join` | Join event |
| POST | `/api/events/:id/guests/check-in` | Check-in |
| GET | `/api/events/:id/agenda` | Get agenda |
| GET | `/api/events/:id/wishes` | List wishes |
| POST | `/api/events/:id/wishes` | Create wish |
| GET | `/api/events/:id/analytics` | Event analytics |
| GET | `/api/notifications` | List notifications |
