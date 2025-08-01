# 📘 API Documentation

> **Note:** All authenticated endpoints require a valid token via `Authorization: Bearer <token>`.

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
## `GET` /me
**Description**: Get the current authenticated user information.
**Auth required**: Yes
**Tags**: user, email

### Responses
- `200`: User
```json
{
  "id": 42,
  "username": "newhandle",
  "email": "new@example.com",
  "created_at": "2025-07-28T14:22:01Z",
  "updated_at": "2025-07-28T14:22:01Z",
  "confirmed_at": "2025-07-28T14:22:01Z",
  "notifications_enabled": "true"
}
```
- `401`: Unauthorized
```json
{
  "error": "Unauthorized"
}
```
- `404`: Invalid user
```json
{
  "error": "Invalid user"
}
```

---
## `POST` /me/update
**Description**: Update the current user's profile. Supports changing username, email, and/or password.
**Auth required**: Yes
**Tags**: users, profile

### Parameters
- `username` (String)  - New unique username
- `email` (String)  - New valid email address
- `notifications_enabled` (Boolean)  - Activate or deactivate notifications
- `password` (String)  - New password (minimum 8 characters)

### Responses
- `200`: Profile updated
```json
{
  "id": 3,
  "username": "newhandle",
  "email": "new@example.com",
  "created_at": "2025-07-28T14:22:01Z",
  "updated_at": "2025-07-29T10:11:45Z",
  "notifications_enabled": "false"
}
```
- `400`: Validation failed
```json
{
  "error": "Password too short (min 8 chars)"
}
```
- `400`: Failed to update profile
```json
{
  "error": "Failed to update profile"
}
```

---
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
## `POST` /images/:id/comments
**Description**: Add a comment to a specific image. Authenticated users only.
**Auth required**: Yes
**Tags**: comments, images

### Parameters
- `content` (String) **(required)** - The body of the comment

### Responses
- `201`: Comment created
```json
{
  "id": 13,
  "user_id": 4,
  "image_id": 7,
  "content": "Amazing overlay!",
  "created_at": "2024-07-25T12:00:00Z"
}
```
- `400`: Missing or empty comment
```json
{
  "error": "Missing or empty comment"
}
```
- `404`: Image not found
```json
{
  "error": "Image not found"
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
## `POST` /images/:id/like
**Description**: Like a specific image. Only authenticated users may like images.
**Auth required**: Yes
**Tags**: likes, images

### Responses
- `200`: Image liked
```json
{
  "message": "Image liked"
}
```
- `404`: Image not found
```json
{
  "error": "Image not found"
}
```
- `400`: Image already liked
```json
{
  "error": "Image already liked"
}
```

---
## `DELETE` /images/:id/unlike
**Description**: Unlike a previously liked image. Only authenticated users may unlike.
**Auth required**: Yes
**Tags**: likes, images

### Responses
- `200`: Image unliked
```json
{
  "message": "Image unliked"
}
```
- `404`: Image not found
```json
{
  "error": "Image not found"
}
```
- `400`: Image not liked
```json
{
  "error": "Image not liked"
}
```

---
## `GET` /gallery
**Description**: List all public images in the gallery with support for pagination, sorting, and custom per-page limits.
**Auth required**: No
**Tags**: gallery, images

### Parameters
- `page` (Integer)  - Page number (default: 1)
- `per_page` (Integer)  - Items per page (default: 10, max: 100)
- `sort_by` (String)  - Sort field: created_at, likes, or comments
- `order` (String)  - `asc` or `desc` (default: desc)

### Responses
- `200`: Paginated images
```json
{
  "page": 1,
  "per_page": 5,
  "total": 32,
  "total_pages": 7,
  "images": [
    {
      "id": 3,
      "file_path": "/images/abc.png",
      "user_id": 1,
      "created_at": "...",
      "user": {
        "id": 4,
        "username": "alice",
        "created_at": "2025-07-27T12:00:00Z"
      },
      "comments": [
        {
          "id": 42,
          "image_id": 3,
          "user_id": 7,
          "content": "awesome!",
          "created_at": "",
          "username": "alice",
          "user_created_at": ""
        }
      ],
      "likes": []
    }
  ]
}
```

---
## `GET` /images/mine
**Description**: Retrieve the current user's active (non-archived) images.
**Auth required**: Yes
**Tags**: images

### Responses
- `200`: List of active images
```json
[
  {
    "id": 1,
    "file_path": "/images/abc.png",
    "user_id": 4,
    "deleted_at": "null",
    "user": {
      "id": 4,
      "username": "alice",
      "created_at": "2025-07-27T12:00:00Z"
    },
    "comments": [],
    "likes": []
  }
]
```

---
## `GET` /images/archived
**Description**: Retrieve the current user's archived (soft-deleted) images.
**Auth required**: Yes
**Tags**: images

### Responses
- `200`: List of archived images
```json
[
  {
    "id": 2,
    "file_path": "/images/old.png",
    "user_id": 4,
    "deleted_at": "2024-01-01T10:00:00Z",
    "user": {
      "id": 4,
      "username": "alice",
      "created_at": "2025-07-27T12:00:00Z"
    },
    "comments": [],
    "likes": []
  }
]
```

---
## `POST` /images/:id/archive
**Description**: Soft-delete (archive) an image owned by the current user.
**Auth required**: Yes
**Tags**: images

### Responses
- `200`: Image archived
```json
{
  "message": "Image archived successfully"
}
```
- `403`: Unauthorized (not owner)
```json
{
  "error": "Unauthorized"
}
```
- `404`: Image not found
```json
{
  "error": "Image not found"
}
```

---
## `DELETE` /images/:id
**Description**: Permanently delete an image owned by the current user.
**Auth required**: Yes
**Tags**: images

### Responses
- `200`: Image deleted
```json
{
  "message": "Image deleted successfully"
}
```
- `403`: Unauthorized (not owner)
```json
{
  "error": "Unauthorized"
}
```
- `404`: Image not found
```json
{
  "error": "Image not found"
}
```

---
## `POST` /images
**Description**: Upload a new image with sticker overlays. Accepts base64, file upload, remote URL, or local path. Composites stickers server-side and returns enriched image metadata.
**Auth required**: Yes
**Tags**: images, stickers

### Parameters
- `image` (String) **(required)** - Base image to be used (can be data URL, remote URL, local path, or uploaded file)
- `preview_width` (Integer) **(required)** - Preview width relative to the x, y and scale
- `preview_height` (Integer) **(required)** - Preview height relative to the x, y and scale
- `stickers` (Array) **(required)** - Array of sticker overlays with position and scale (layered first-to-last)

### Responses
- `201`: Image created
```json
{
  "id": 42,
  "user_id": 4,
  "file_path": "/uploads/user_04/2025/07/28/image_a1b2c3d4.png",
  "created_at": "2025-07-28T15:42:00Z",
  "deleted_at": null,
  "user": {
    "id": 4,
    "username": "alice",
    "created_at": "2025-07-27T12:00:00Z"
  },
  "comments": [],
  "likes": []
}
```
- `400`: Invalid or missing input
```json
{
  "error": "Invalid image data"
}
```
- `401`: Unauthorized
```json
{
  "error": "Unauthorized"
}
```
- `500`: Server-side failure
```json
{
  "error": "Failed to save image"
}
```

---
