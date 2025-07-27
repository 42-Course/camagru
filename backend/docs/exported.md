# 📘 API Documentation

> **Note:** All authenticated endpoints require a valid token via `Authorization: Bearer <token>`.

## `POST` /login
**Description**: Authenticate a user using either username or email. Returns a session token on success.
**Auth required**: No
**Tags**: auth, sessions

### Parameters
- `identity` (String) **(required)** - Username or email address
- `password` (String) **(required)** - User's password

### Responses
- `200`: Login successful
```json
{
  "token": "<jwt_token_here>"
}
```
- `400`: Missing identity or password
```json
{
  "error": "Missing identity or password"
}
```
- `401`: Invalid credentials
```json
{
  "error": "Invalid credentials"
}
```

---
## `POST` /logout
**Description**: Invalidate current session token. For JWT-based apps, the client must delete the token locally.
**Auth required**: Yes
**Tags**: auth, sessions

### Responses
- `200`: Logout successful
```json
{
  "message": "Logged out successfully"
}
```

---
## `GET` /stickers
**Description**: Get the list of available sticker overlays. Public route used by the editor.
**Auth required**: No
**Tags**: stickers

### Responses
- `200`: List of stickers
```json
[
  {
    "id": 1,
    "name": "Hat",
    "file_path": "/stickers/hat.png"
  },
  {
    "id": 2,
    "name": "Laser Eyes",
    "file_path": "/stickers/lasereyes.png"
  }
]
```

---
## `POST` /password/forgot
**Description**: Request a password reset link.If the email exists, a reset token is sent.The response is always generic to prevent user enumeration.
**Auth required**: No
**Tags**: password, reset

### Parameters
- `email` (String) **(required)** - The email address of the user requesting a password reset.

### Responses
- `200`: Reset link sent (if account exists)
```json
{
  "message": "If your email exists, a reset link has been sent"
}
```
- `400`: Missing email
```json
{
  "error": "Missing email"
}
```

---
## `POST` /password/reset
**Description**: Request a password reset link. If the email exists, a reset token is sent.The response is always generic to prevent user enumeration.
**Auth required**: No
**Tags**: password, reset

### Parameters
- `token` (String) **(required)** - Reset token received by email
- `password` (String) **(required)** - New password (minimum 8 characters)

### Responses
- `200`: Password reset successfully
```json
{
  "message": "Password reset successfully"
}
```
- `400`: Missing token or password
```json
{
  "error": "Missing token or password"
}
```
- `400`: Password too short
```json
{
  "error": "Password too short (min 8 chars)"
}
```
- `400`: Invalid or expired token
```json
{
  "error": "Invalid or expired token"
}
```

---
## `POST` /signup
**Description**: Register a new user. Sends a confirmation email with a validation token.
**Auth required**: No
**Tags**: auth, users

### Parameters
- `username` (String) **(required)** - Unique username
- `email` (String) **(required)** - Valid email address
- `password` (String) **(required)** - Minimum 8 characters

### Responses
- `201`: User created
```json
{
  "message": "Confirmation email sent"
}
```
- `400`: Validation failed
```json
{
  "error": "All fields are required"
}
```
- `400`: Validation failed
```json
{
  "error": "Invalid email format"
}
```
- `400`: Validation failed
```json
{
  "error": "Password too short (min 8 chars)"
}
```
- `400`: Validation failed
```json
{
  "error": "Username already registered"
}
```
- `400`: Validation failed
```json
{
  "error": "Email already registered"
}
```

---
## `GET` /confirm
**Description**: Confirm user email using the token sent during registration.
**Auth required**: No
**Tags**: auth, email

### Parameters
- `token` (String) **(required)** - Confirmation token sent via email

### Responses
- `200`: Email confirmed
```json
{
  "message": "Email confirmed successfully!"
}
```
- `400`: Invalid or missing token
```json
{
  "error": "Invalid or expired token"
}
```

---
