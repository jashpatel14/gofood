# Implementation Plan - Professional Forgot Password Feature

This plan outlines the steps to implement a modern, professional password reset flow similar to top food delivery apps (Zomato, Swiggy).

## Proposed Changes

### Backend (Node.js)

#### [.env](file:///C:/flutterproject/gofood/backend/.env)
- Add `EMAIL_USER` and `EMAIL_PASS` for SMTP configuration.

#### [NEW] [email_service.js](file:///C:/flutterproject/gofood/backend/services/email_service.js)
- Create a reusable email service using `nodemailer`.
- Implement a professional HTML template for the reset password email.

#### [auth.js](file:///C:/flutterproject/gofood/backend/routes/auth.js)
- Add `POST /forgot-password`:
    - Validates user email.
    - Generates a secure random token (`crypto`).
    - Saves token in a new `password_reset_tokens` table.
    - Sends reset email with a link.
- Add `POST /reset-password`:
    - Validates the token and expiration.
    - Updates the user's password.
    - Deletes the token.

#### [NEW] [password_reset.sql](file:///C:/flutterproject/gofood/backend/database/password_reset.sql)
- SQL script to create the `password_reset_tokens` table.

---

### Frontend (Flutter)

#### [NEW] [forgot_password_screen.dart](file:///C:/flutterproject/gofood/lib/screens/auth/forgot_password_screen.dart)
- Modern UI with a clean design.
- Input field for email.
- Success/Error handling with Lottie animations or professional snackbars.

#### [auth_api.dart](file:///C:/flutterproject/gofood/lib/api/auth_api.dart)
- Add `forgotPassword(email)` method.

#### [app_router.dart](file:///C:/flutterproject/gofood/lib/routes/app_router.dart)
- Add route for `ForgotPasswordScreen`.

---

## Verification Plan

### Automated Tests
- I will verify the backend endpoints using `curl` or a similar tool.
- I will check the email receipt (manually).

### Manual Verification
- Run the Flutter app and navigate through the forgot password flow.
- Verify that the email is received and contains the correct link.
- Verify that the password is successfully updated in the database.
