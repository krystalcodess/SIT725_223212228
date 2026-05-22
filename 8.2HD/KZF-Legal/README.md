# KFZ-Legal
KZF Legal — an AI powered legal guidance platform
helping immigrants navigate the Australian immigration system.

## Expected Folder Structure

This is the current baseline structure and will evolve over time as features are added.

```text
public/
    index.html
  css/
    styles.css
  js/
    app.js
    chat.js
    upload.js
    socket.js

server/
  app.js
  server.js
  config/
    env.js
    database.js
    passport.js
  models/
    User.js
    Chat.js
    Message.js
    Document.js
  controllers/
    authController.js
    chatController.js
    documentController.js
  services/
    authService.js
    chatService.js
    documentService.js
  routes/
    index.js
    adminRoutes.js
    authRoutes.js
    chatRoutes.js
    documentRoutes.js
    healthRoutes.js
  middleware/
    authenticateSocket.js
    validateRequest.js
    errorHandler.js
    notFound.js
    requireAuth.js
    requireAdmin.js
    upload.js
  validators/
    authValidator.js
    chatValidator.js
    docValidator.js
  utils/
    logger.js
    seed.js

rag/
  chunker.js
  embedder.js
  vectorStore.js
  webRetriever.js
  contextBuilder.js
  pipeline.js

tests/
  public/
  rag/
  server/
    auth.test.js
    health.test.js
    middleware.test.js
    notFound.test.js
    helpers/
      mockAuth.js
```

## Tech Stack

- **Runtime:** Node.js
- **Framework:** Express.js
- **Authentication:** Passport
- **Database:** MongoDB (Mongoose)

## Docker (HD Task)

This section is the primary run guide for marking the containerised submission.

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (includes Docker Compose)
- A copy of this repository

### 1. Clone and configure

```bash
git clone https://github.com/kryscodeless/KZF-Legal.git
cd KZF-Legal
cp .env.example .env
```

Edit `.env` before starting:

| Variable | Required | Notes |
|----------|----------|-------|
| `JWT_SECRET` | Yes | Must be at least 32 characters |
| `OPENAI_API_KEY` | Yes (chat + upload ingestion) | Not stored in this public repo |
| `ANTHROPIC_API_KEY` | Yes (chat responses) | Not stored in this public repo |

**Sensitive values:** Real API keys are intentionally excluded from GitHub. Use the working `OPENAI_API_KEY` and `ANTHROPIC_API_KEY` values supplied in my **OnTrack submission** for this HD task.

Docker Compose automatically sets these database URLs for the containers:

- `MONGODB_URI=mongodb://mongo:27017/kfz-legal`
- `RAG_MONGODB_URI=mongodb://mongo:27017/kfz-legal-rag`

You do not need a local MongoDB installation when using Docker.

### 2. Build and start

```bash
docker compose up --build
```

Wait until the app logs show the server running on port 3000.

### 3. Access the application

Open in a browser:

```text
http://localhost:3000
```

### 4. Verify the student endpoint

```bash
curl http://localhost:3000/api/student
```

Expected response:

```json
{
  "name": "Phuc Anh Thu Nguyen",
  "studentId": "223212228"
}
```

### 5. Verify database-backed features

With the containers running and valid API keys in `.env`:

1. **Register** a new account from the login/register screen, or use seeded test users (see below).
2. **Log in** with that account.
3. **Upload** a PDF, DOC, or DOCX file from the upload page (requires valid `OPENAI_API_KEY` for ingestion).
4. **Chat** by asking a question in the chat interface (requires valid `OPENAI_API_KEY` and `ANTHROPIC_API_KEY`).

Optional seed data for quick testing:

```bash
docker compose exec app npm run seed -- --force
```

Seeded accounts from `server/utils/seed.js`:

| Email | Password | Role |
|-------|----------|------|
| `alice@example.com` | `UserPassword123!` | user |
| `bob@example.com` | `UserPassword123!` | user |
| `admin@legalplatform.dev` | `AdminPassword123!` | admin |

### 6. Stop the application

```bash
docker compose down
```

To remove persisted database and upload data as well:

```bash
docker compose down -v
```

### Troubleshooting

- **App exits on startup:** check that `JWT_SECRET` in `.env` is at least 32 characters.
- **Chat or upload fails:** confirm the API keys from OnTrack are present in `.env`, then restart with `docker compose up --build`.
- **Port already in use:** stop any local process on port 3000 or change the host mapping in `docker-compose.yml` (e.g. `"3001:3000"`).

## Getting Started (Local Development)

### Prerequisites

- Node.js v20 or higher
- npm v10 or higher
- MongoDB instance

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/kryscodeless/KZF-Legal.git
   cd KZF-Legal
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Copy the .env.example to .env

4. Start the development server:
   ```bash
   npm run dev
   ```

5. Verify the server is running:
   ```bash
   curl http://localhost:3000/api/health
   ```

## Frontend

The frontend is a vanilla HTML/CSS/JavaScript application served from the `public/` folder.

### Pages

| Page | File | Description |
|------|------|-------------|
| Login / Register | `index.html` | Authentication screens for signing in or creating an account. Connects to `/api/login-page` and `/api/register-page`. |
| Home | `index.html` | Dashboard shown after login. Displays a greeting, quick ask box, recent conversations, and shortcuts to other pages. |
| Chat | `index.html` | Main AI conversation interface. Messages are sent to the backend via Socket.io and responses are rendered with citation badges. |
| Upload | `index.html` | Drag and drop document upload page. Accepts PDF, DOC, and DOCX files up to 10MB. Connects to `/api/upload-page`. |
| History | `index.html` | Lists all past conversation sessions with search and date filtering. Supports resume and delete actions. |

### Frontend Files 

| File | Description |
|------|-------------|
| `public/css/styles.css` | All styling design tokens, layout, components. |
| `public/js/chat.js` | Handles message rendering, typing indicator, suggestion chips, and session title updates. |
| `public/js/socket.js` | Manages the Socket.io connection. Authenticates with the session token from login and listens for `chat:response` events. |
| `public/js/upload.js` | Handles drag and drop, client-side file validation (type, size, duplicates), and upload progress UI. |
| `public/js/app.js` | Handles main functionality of the app flow states. |

### Socket Events

| Direction | Event | Payload |
|-----------|-------|---------|
| Server → Client | `chat:response` | `{ messageId, answer, citations?, sessionId? }` |
| Server → Client | `chat:error` | `{ messageId, message, sessionId? }` |
| Server → Client | `document:updated` | `{ documentId, status, filename?, chatId? }` |

### API Endpoints (Frontend → Backend)

| Method | Endpoint | Used by |
|--------|----------|---------|
| `POST` | `/api/auth/login` | Login form (`app.js`) |
| `POST` | `/api/auth/register` | Register form (`app.js`) |
| `POST` | `/api/auth/logout` | Logout (`app.js`) |

| `POST` | `/api/chat` | Send message (`chat.js`) |

| `POST` | `/api/documents/upload` | Upload file (`upload.js`) |
| `GET` | `/api/documents` | Load documents page (`app.js`) |
| `DELETE` | `/api/documents/:id` | Delete document (`app.js` + upload chip removal) |

| `GET` | `/api/history` | Load chat history (`app.js`) |
| `GET` | `/api/history/:chatId` | Load single conversation (`resumeSession`) |
| `DELETE` | `/api/history/:chatId` | Delete conversation (`app.js`) |