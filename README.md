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

| Method | Route | Controller's call |
| ---- | ----------------------------- | ------------------------ |
| POST |     /signup                   | → UsersController#create |
| POST |     /login                    | → SessionsController#create |
| POST |     /logout                   | → SessionsController#destroy |
| POST |     /password/forgot          | → PasswordResetsController#create |
| POST |     /password/reset           | → PasswordResetsController#update |
| GET |      /confirm?token=...        | → UsersController#confirm_email |
| GET |      /stickers                 | → StickersController#index |
| GET |      /gallery?page=1           | → GalleryController#index |
| POST |     /images                   | → ImagesController#create |
| DELETE |   /images/:id               | → ImagesController#destroy |
| GET |      /images/mine              | → ImagesController#my_images |
| POST |     /images/:id/like          | → LikesController#like |
| DELETE |   /images/:id/unlike        | → LikesController#unlike |
| POST |     /images/:id/comments      | → CommentsController#create |
| GET |      /images/:id/comments      | → CommentsController#index |