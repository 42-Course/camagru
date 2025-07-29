# Camagru

Camagru is a containerized full-stack web application inspired by the 42 school project. It allows users to capture or upload images, overlay stickers, and publish them to a public gallery. Authenticated users can like and comment on images. All backend logic is written in Ruby using Sinatra, and image processing is handled server-side.

---

## 🧱 Tech Stack

* **Backend**: Ruby, Sinatra
* **Database**: PostgreSQL
* **Frontend**: HTML/CSS/JS (no frameworks)
* **Email**: MailHog (SMTP), `mail` gem
* **Image Processing**: Server-side overlay pipeline (TBD)
* **Authentication**: JWT-based session tokens
* **Tests**: RSpec
* **Linting**: RuboCop
* **Containerization**: Docker + Docker Compose

---

## 📁 Project Structure

```
camagru/
├── backend/
│   ├── app/                # Main application code
│   │   ├── controllers/    # Sinatra route definitions
│   │   ├── models/         # Database interaction logic
│   │   ├── lib/            # Shared utilities (e.g., auth, API doc)
│   │   ├── helpers/        # Support modules (e.g., token, hashing)
│   │   └── views/          # (if needed for templating)
│   ├── db/                 # Seeds and migrations
│   ├── docs/               # Exported API docs (Markdown + JSON)
│   ├── spec/               # RSpec tests
│   └── Dockerfile
├── docker-compose.yml
├── Makefile
└── frontend/               # Static frontend files
```

---

## 🧪 Test Coverage

* `make test`: Runs all RSpec tests
* Isolated tests per model/controller
* Many routes include exhaustive specs and edge-case handling

---

## 🚀 Features

* Secure user signup/login/logout with JWT
* Password reset flow via email
* Image upload (processing pipeline to come)
* Gallery of user-generated content
* Public and private image management
* Stickers system
* RESTful enriched image JSON including likes and comments

---

## 🧾 API Overview

### Authentication

| Method | Route                | Controller                        | Status |
| ------ | -------------------- | --------------------------------- | ------ |
| POST   | `/signup`            | `UsersController#create`          | ✅      |
| POST   | `/login`             | `SessionsController#create`       | ✅      |
| POST   | `/logout`            | `SessionsController#destroy`      | ✅      |
| GET    | `/confirm?token=...` | `UsersController#confirm_email`   | ✅      |
| POST   | `/password/forgot`   | `PasswordResetsController#create` | ✅      |
| POST   | `/password/reset`    | `PasswordResetsController#update` | ✅      |

### Stickers

| Method | Route       | Controller                 | Status |
| ------ | ----------- | -------------------------- | ------ |
| GET    | `/stickers` | `StickersController#index` | ✅      |

### Gallery (Public)

| Method | Route      | Controller                | Status                            |
| ------ | ---------- | ------------------------- | --------------------------------- |
| GET    | `/gallery` | `GalleryController#index` | ✅ (likes/comments sort supported) |

### Image Management (Authenticated)

| Method | Route                 | Controller                  | Status |
| ------ | --------------------- | --------------------------- | ------ |
| GET    | `/images/mine`        | `ImagesController#mine`     | ✅      |
| GET    | `/images/archived`    | `ImagesController#archived` | ✅      |
| POST   | `/images/:id/archive` | `ImagesController#archive`  | ✅      |
| DELETE | `/images/:id`         | `ImagesController#destroy`  | ✅      |

### Likes

| Method | Route                | Controller               | Status |
| ------ | -------------------- | ------------------------ | ------ |
| POST   | `/images/:id/like`   | `LikesController#like`   | ✅      |
| DELETE | `/images/:id/unlike` | `LikesController#unlike` | ✅      |

### Comments

| Method | Route                  | Controller                  | Status |
| ------ | ---------------------- | --------------------------- | ------ |
| POST   | `/images/:id/comments` | `CommentsController#create` | ✅      |

> ❌ `GET /images/:id/comments` has been intentionally removed.
> Instead, image responses now embed comments + likes (RESTful style).

---

## 📦 Running Locally

```bash
make up         # Start containers
make migrate    # Run DB migrations
make seed       # Seed DB with test data
make logs       # Tail backend logs
```

---

## 🧰 Utilities

* `make docs` — export Markdown + JSON API documentation
* `rake db:create|drop|migrate|seed` — DB tasks
* `rake doc:export` — custom task for `APIDoc` generator

---

## 📌 Notes

* All images returned from `/gallery`, `/images/mine`, and `/images/archived` include embedded `comments` and `likes`.
* Pagination supports `page`, `per_page`, `sort_by` (`created_at`, `likes`, `comments`), and `order` (`asc`, `desc`).
* Email delivery is mocked with MailHog by default.

---

## 🏁 Remaining Work

* [x] Implement server-side image processing pipeline (stickers overlay)
* [x] Add frontend integration
* [ ] Rate limiting for likes/comments/images
* [x] User profile editing

---

Camagru is proudly built with ❤️ and Sinatra by pulgamecanica

- [ ] Send notifications via email