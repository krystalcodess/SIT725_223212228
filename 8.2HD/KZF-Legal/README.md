# KZF-Legal

AI-powered legal guidance platform helping immigrants navigate the Australian immigration system.

**Tech stack:** Node.js, Express, MongoDB, vanilla HTML/CSS/JS frontend

## Docker — HD Task Run Guide

This is the primary guide for running the containerised submission.

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (includes Docker Compose)

### 1. Clone and configure

```bash
git clone https://github.com/kryscodeless/SIT725_223212228.git
cd SIT725_223212228/8.2HD/KZF-Legal
cp .env.example .env
```

Edit `.env` before starting:

| Variable | Required | Notes |
|----------|----------|-------|
| `JWT_SECRET` | Yes | Must be at least 32 characters |
| `OPENAI_API_KEY` | Yes | Required for document upload and chat ingestion |
| `ANTHROPIC_API_KEY` | Yes | Required for chat responses |

**Sensitive values:** API keys are not stored in this public repository. Use the working `OPENAI_API_KEY` and `ANTHROPIC_API_KEY` values supplied in my **OnTrack submission** for this HD task.

Docker Compose automatically sets the database URLs for the containers:

- `MONGODB_URI=mongodb://mongo:27017/kfz-legal`
- `RAG_MONGODB_URI=mongodb://mongo:27017/kfz-legal-rag`

No local MongoDB installation is required.

### 2. Build and start

```bash
docker compose up --build
```

Wait until the app logs show the server running on port 3000.

### 3. Access the application

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

1. **Register** a new account, or log in with a seeded test user (see below).
2. **Upload** a PDF, DOC, or DOCX file.
3. **Chat** by asking a question in the chat interface.

Optional seed data:

```bash
docker compose exec app npm run seed -- --force
```

| Email | Password | Role |
|-------|----------|------|
| `alice@example.com` | `UserPassword123!` | user |
| `bob@example.com` | `UserPassword123!` | user |
| `admin@legalplatform.dev` | `AdminPassword123!` | admin |

### 6. Stop the application

```bash
docker compose down
```

To remove persisted database and upload data:

```bash
docker compose down -v
```

### Troubleshooting

- **App exits on startup:** ensure `JWT_SECRET` in `.env` is at least 32 characters.
- **Chat or upload fails:** confirm API keys from OnTrack are in `.env`, then run `docker compose up --build` again.
- **Port already in use:** stop any process on port 3000, or change the host mapping in `docker-compose.yml` (e.g. `"3001:3000"`).
