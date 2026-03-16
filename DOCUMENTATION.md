# SkillTrack.AI --- Production Architecture & Infrastructure Documentation

## 1. System Overview

SkillTrack.AI consists of four deployable components.

### Landing Site

Domain: https://skilltrack.ai\
Purpose: Marketing, SEO, onboarding entry\
Stack: Flutter Web → Static export → Cloudflare Pages

### Web Application

Domain: https://app.skilltrack.ai\
Purpose: Main user application\
Stack: Flutter Web → Cloudflare Pages

### Backend API

Domain: https://api.skilltrack.ai\
Purpose: Application logic\
Stack: - Node.js - Express.js - TypeScript - PostgreSQL - Redis

Hosted on Railway.

### Background Worker

Purpose: - Skill scoring - AI processing - Email queue - Analytics
processing

Stack: Node.js + BullMQ (Hosted on Railway)

------------------------------------------------------------------------

# 2. DNS Configuration

Provider: Cloudflare

Records:

-   skilltrack.ai → Cloudflare Pages
-   app.skilltrack.ai → Cloudflare Pages
-   api.skilltrack.ai → Railway service

------------------------------------------------------------------------

# 3. Repository Structure

Recommended monorepo:

    skilltrack-ai/

    apps/
       api/
       worker/
       web-app/
       landing/

    packages/
       database/
       types/
       utils/

    infra/
       docker/
       scripts/

------------------------------------------------------------------------

# 4. Backend Dependencies

Core:

-   express
-   cors
-   helmet
-   dotenv
-   compression
-   zod
-   bcrypt
-   jsonwebtoken
-   uuid
-   dayjs

Database:

-   pg
-   drizzle-orm
-   drizzle-kit

Authentication:

-   passport
-   passport-github2
-   passport-google-oauth20
-   passport-linkedin-oauth2

Redis / Queue:

-   ioredis
-   bullmq

File Upload:

-   multer

Cloudflare R2:

-   @aws-sdk/client-s3

Email:

-   resend

Payments:

-   stripe

Error Monitoring:

-   @sentry/node

Analytics:

-   posthog-node

AI Calls:

-   axios

Resume generation:

-   puppeteer

Logging:

-   pino
-   pino-pretty

------------------------------------------------------------------------

# 5. Frontend Dependencies (Flutter)

Core:

-   go_router
-   riverpod
-   flutter_hooks
-   dio

UI:

-   glassmorphism
-   flutter_animate
-   hovering
-   smooth_page_indicator

Charts:

-   fl_chart

Auth:

-   flutter_appauth

File Upload:

-   file_picker

Images:

-   cached_network_image

Analytics:

-   posthog_flutter

Error Monitoring:

-   sentry_flutter

------------------------------------------------------------------------

# 6. PostgreSQL Setup (Neon)

Database: skilltrack_prod

Extensions:

-   uuid-ossp
-   pgcrypto

------------------------------------------------------------------------

# 7. Database Schema

## users

-   id (uuid primary key)
-   username
-   email
-   password_hash
-   avatar_url
-   primary_provider
-   public_profile
-   created_at
-   updated_at

## oauth_accounts

-   id
-   user_id
-   provider
-   provider_user_id
-   created_at

## skills

-   id
-   name
-   category

## user_skills

-   id
-   user_id
-   skill_id
-   score
-   level
-   updated_at

## activities

-   id
-   user_id
-   type
-   title
-   duration
-   difficulty
-   skill_tags\[\]
-   created_at

## projects

-   id
-   user_id
-   title
-   description
-   tech_stack\[\]
-   github_url
-   cover_image
-   created_at

## github_accounts

-   id
-   user_id
-   github_id
-   username
-   access_token

## subscriptions

-   id
-   user_id
-   stripe_customer_id
-   stripe_subscription_id
-   status
-   created_at

## streaks

-   id
-   user_id
-   current_streak
-   longest_streak
-   updated_at

------------------------------------------------------------------------

# 8. Authentication

Email login: - bcrypt password hashing - JWT issued

Access token expiration: 15 minutes\
Refresh token expiration: 30 days

OAuth Providers:

-   GitHub
-   Google
-   LinkedIn

Account merge rule:

If OAuth email matches existing account → merge accounts.

GitHub becomes primary identity.

------------------------------------------------------------------------

# 9. GitHub Integration

Required scopes:

-   read:user
-   repo

Used to collect:

-   commits
-   repositories
-   languages
-   contribution graph

------------------------------------------------------------------------

# 10. Skill Scoring Engine

Score range: 0--100

Inputs:

-   activity_logs
-   projects
-   github_activity
-   practice_platforms
-   consistency_streak

Weights:

-   activity_logs 30%
-   projects 30%
-   github_activity 20%
-   practice_platforms 10%
-   consistency_streak 10%

Formula:

score = (activity_score \* 0.30) + (project_score \* 0.30) +
(github_score \* 0.20) + (practice_score \* 0.10) + (streak_score \*
0.10)

Worker recomputes daily.

------------------------------------------------------------------------

# 11. AI Integration (InceptionAI)

Used for:

-   Skill extraction from activities
-   Roadmap generation
-   Resume generation
-   Project recommendation
-   Skill gap analysis

Example API:

POST https://api.inception.ai/v1/generate

Payload:

{ "model": "inception-1", "prompt": "...", "temperature": 0.2 }

------------------------------------------------------------------------

# 12. Resume Generator

Flow:

1.  User clicks export\
2.  Backend compiles HTML template\
3.  Puppeteer renders PDF\
4.  PDF stored in Cloudflare R2

------------------------------------------------------------------------

# 13. File Storage (Cloudflare R2)

Bucket: skilltrack-files

Max file size: 10MB

Folders:

-   avatars/
-   projects/
-   screenshots/
-   portfolio/
-   resumes/

------------------------------------------------------------------------

# 14. Email System (Resend)

Sender: noreply@skilltrack.ai

Templates:

-   Email verification
-   Password reset
-   Subscription invoice

------------------------------------------------------------------------

# 15. Stripe Configuration

Product: SkillTrack Pro\
Price: \$5/month

Webhook events:

-   checkout.session.completed
-   invoice.payment_succeeded
-   customer.subscription.deleted

------------------------------------------------------------------------

# 16. Analytics (PostHog)

Tracked events:

-   signup
-   login
-   project_created
-   activity_logged
-   resume_generated
-   subscription_started

------------------------------------------------------------------------

# 17. Error Monitoring

Tool: Sentry

Enabled for:

-   Frontend
-   Backend
-   Workers

------------------------------------------------------------------------

# 18. Rate Limiting

Auth routes: 10 requests/minute\
API routes: 100 requests/minute\
AI endpoints: 20 requests/minute

------------------------------------------------------------------------

# 19. Worker Queues (BullMQ)

Queues:

-   skill-score
-   github-sync
-   resume-generation
-   email-delivery
-   ai-analysis

------------------------------------------------------------------------

# 20. Free Tier Capacity

Railway free tier: \~2GB RAM

Neon free tier: 3GB storage

Cloudflare R2 free tier: 10GB storage

Cloudflare Pages: unlimited static hosting

Expected capacity: \~1000 users

------------------------------------------------------------------------

# 21. Security

Helmet security headers\
bcrypt cost factor: 12

JWT algorithm: HS256

Allowed CORS origins:

-   skilltrack.ai
-   app.skilltrack.ai

------------------------------------------------------------------------

# 22. Logging

Logger: pino

Log levels:

-   info
-   warn
-   error

------------------------------------------------------------------------

# 23. Deployment

Backend → Railway (GitHub auto deploy)

Frontend → Cloudflare Pages

Database → Neon

------------------------------------------------------------------------

# 24. CI/CD

GitHub Actions pipeline:

1.  install
2.  lint
3.  build
4.  test
5.  deploy

------------------------------------------------------------------------

# 25. API Folder Structure

    src/

    controllers/
    services/
    routes/
    middleware/
    models/
    jobs/
    workers/
    utils/
    config/

------------------------------------------------------------------------

# 26. Public Profile

Profile URL format:

https://skilltrack.ai/{username}

Profile shows:

-   Skill scores
-   Projects
-   Portfolio
-   GitHub stats

------------------------------------------------------------------------

# 27. .env.example

    NODE_ENV=production

    PORT=3000

    APP_URL=https://app.skilltrack.ai
    API_URL=https://api.skilltrack.ai
    DOMAIN=skilltrack.ai

    JWT_SECRET=
    JWT_REFRESH_SECRET=

    DATABASE_URL=

    REDIS_URL=

    GITHUB_CLIENT_ID=
    GITHUB_CLIENT_SECRET=

    GOOGLE_CLIENT_ID=
    GOOGLE_CLIENT_SECRET=

    LINKEDIN_CLIENT_ID=
    LINKEDIN_CLIENT_SECRET=

    STRIPE_SECRET_KEY=
    STRIPE_WEBHOOK_SECRET=
    STRIPE_PRICE_ID=

    RESEND_API_KEY=
    EMAIL_FROM=noreply@skilltrack.ai

    R2_ACCOUNT_ID=
    R2_ACCESS_KEY_ID=
    R2_SECRET_ACCESS_KEY=
    R2_BUCKET=skilltrack-files
    R2_PUBLIC_URL=

    POSTHOG_API_KEY=
    POSTHOG_HOST=https://app.posthog.com

    SENTRY_DSN=

    INCEPTION_AI_API_KEY=

    GITHUB_SYNC_CRON=0 */6 * * *

    MAX_FILE_SIZE=10485760
