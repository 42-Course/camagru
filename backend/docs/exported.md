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
