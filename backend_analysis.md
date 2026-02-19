# Backend Analysis - `userservives`

This report provides a technical deep dive into the `userservives` backend, which powers the Abay eQub identity and user management systems.

## 🏗️ Architecture Overview
The backend is a **Modular Node.js Express** application following clean architecture principles.

- **Framework**: Express.js 5.x
- **ORM**: Sequelize (MySQL 8+)
- **Auth**: JWT (Short-lived Access + long-lived Refresh tokens) & HTTP-only Cookies
- **Validation**: Joi
- **Security**: Helmet, CORS, Bcrypt (10 salts), and rate-limiting (via OTP windows).

## 🗄️ Database Schema (Primary Models)
The schema is designed for multi-role access (Admin vs. User) and robust OTP management.

### `User` Model
- `phone`: Unique, normalized (supports multiple formats).
- `fullName`: Required for registration.
- `email`: Optional but unique.
- `password`: Hashed via Bcrypt hooks.
- `isActive`: Boolean flag for account suspension.
- `trustScore`: (Conceptualized, used in Flutter app).

### `OtpRegistration` & `Otp` Models
- Tracks ephemeral codes with expiration timestamps.
- Stores metadata about the registration request (phone, email, hashed password).

## 🔑 Authentication Flows

### 1. Registration (OTP-First)
- **Request**: `POST /api/auth/otp/register` (takes `phone`).
- **Verify**: `POST /api/auth/otp/verify` (takes `phone`, `otp`, `fullName`, `email`, `password`).
- **Result**: Creates a user and returns a JWT.

### 2. Login (Two Modes)
- **OTP Login**: 
    - `POST /api/auth/otp/login/request`
    - `POST /api/auth/otp/login/verify`
- **Password Login**:
    - `POST /api/auth/user/signin` (takes `phone` or `email` as identifier).

### 3. Session Management
- Tokens are issued as `accessToken` in the JSON body and `refreshToken` in a secure HTTP-only cookie.
- A dedicated `/api/auth/user/refresh` endpoint handles sliding sessions.

## 📡 Essential API Endpoints

| Category | Endpoint | Method | Description |
| :--- | :--- | :--- | :--- |
| **Identity** | `/api/auth/otp/register` | `POST` | Start verification flow |
| **Identity** | `/api/auth/otp/verify` | `POST` | Finalize user creation |
| **Auth** | `/api/auth/user/signin` | `POST` | Standard password login |
| **Admin** | `/api/admin/users` | `GET` | List/Search users (Admin only) |
| **System** | `/api/health` | `GET` | Uptime & heartbeat |

## 🛠️ Infrastructure & Config
- **CORS**: Configured for `localhost:5173` (likely a Vite frontend developer environment).
- **Environment**: Managed via `.env` files.
- **Logging**: Morgan unified with Winston for production-grade audit trails.

## 🚀 Mobile Integration Tips
1. **Host Configuration**: Use `10.0.2.2:3000` for Android Emulator access to this backend.
2. **Token Injection**: The Flutter `ApiClient` must inject the `Authorization: Bearer <token>` header for protected routes like `/admin` or `/user/profile`.
3. **Error Mapping**: The backend uses custom `AppError` types which return consistent JSON structures (`{ success: false, message: "..." }`).
