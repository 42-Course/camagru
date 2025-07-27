# Camagru

### Controllers

| Controller                 | Purpose                                                               |
| -------------------------- | --------------------------------------------------------------------- |
| `BaseController`           | Shared logic (e.g., JSON response helpers, current user, auth checks) |
| `UsersController`          | Signup, login, logout, email confirmation, profile update             |
| `SessionsController`       | Login + logout routes (optional separation)                           |
| `PasswordResetsController` | Request and handle password reset via token                           |
| `ImagesController`         | Upload (webcam or file), delete, list **own** images (auth required)  |
| `GalleryController`        | **Public** listing of all images, with pagination                     |
| `LikesController`          | Like/unlike image (auth required)                                     |
| `CommentsController`       | Post/read comments (some public, some restricted), notify authors     |
| `StickersController`       | List available stickers (probably public)                             |

---

### API

| Method | Route | Controller's call | STATUS |
| ---- | ----------------------------- | ------------------------ | ---- |
| POST |     /signup                   | → UsersController#create | OK |
| POST |     /login                    | → SessionsController#create | OK |
| POST |     /logout                   | → SessionsController#destroy | OK |
| POST |     /password/forgot          | → PasswordResetsController#create | OK |
| POST |     /password/reset           | → PasswordResetsController#update | OK |
| GET |      /confirm?token=...        | → UsersController#confirm_email | OK |
| GET |      /stickers                 | → StickersController#index | OK |
| GET |      /gallery?page=1           | → GalleryController#index | TODO |
| POST |     /images                   | → ImagesController#create | TODO |
| DELETE |   /images/:id               | → ImagesController#destroy | TODO |
| GET |      /images/mine              | → ImagesController#my_images | TODO |
| POST |     /images/:id/like          | → LikesController#like | TODO |
| DELETE |   /images/:id/unlike        | → LikesController#unlike | TODO |
| POST |     /images/:id/comments      | → CommentsController#create | TODO |
| GET |      /images/:id/comments      | → CommentsController#index | TODO |