# Lakshya Admin Panel

Next.js admin panel for managing Lakshya Institute courses, leads, and videos.

## Setup

1. Install dependencies:
```bash
npm install --legacy-peer-deps
```

2. Create `.env.local` file:
```bash
NEXT_PUBLIC_SUPABASE_URL=https://spzcjpvtikyoykbgnlgr.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_APP_URL=http://localhost:3001
```

3. Run development server:
```bash
npm run dev
```

The admin panel will be available at `http://localhost:3001`

## Deployment

### Deploy to Firebase Hosting + Cloud Run

```bash
# Build the app
npm run build

# Deploy (from project root)
firebase deploy --only hosting:admin,run:admin
```

Or use the deployment script:
```bash
.\scripts\deploy-admin.ps1
```

## Features

- **Dashboard**: Overview with stats and charts
- **Leads Management**: View, filter, and manage leads
- **Courses Management**: CRUD operations for courses
- **Videos Management**: Manage video promos
- **Analytics**: Detailed analytics and insights

## Tech Stack

- Next.js 16 (App Router)
- Refine.dev (Admin Framework)
- Supabase (Backend)
- Tailwind CSS (Styling)
- Recharts (Charts)
- TypeScript

## Authentication

Only users with `admin` or `faculty` role can access the admin panel. Authentication is handled via Supabase Auth.
