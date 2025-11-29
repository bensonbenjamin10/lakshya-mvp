# Manual Cloud Run Deployment Guide

This guide walks you through manually deploying the admin panel to Cloud Run.

## Prerequisites

- Google Cloud Project: `paperlms-001`
- Cloud Run API enabled ✅
- Cloud Build API enabled (for source deployments)
- Firebase CLI installed (`npm install -g firebase-tools`)

## Option 1: Deploy from Source (Easiest) ⭐ Recommended

This method builds and deploys directly from your local `admin/` directory.

### Step 1: Authenticate with Google Cloud

```powershell
# Install gcloud CLI if you haven't already
# Download from: https://cloud.google.com/sdk/docs/install

# Authenticate
gcloud auth login

# Set your project
gcloud config set project paperlms-001
```

### Step 2: Enable Required APIs

```powershell
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
```

### Step 3: Deploy to Cloud Run

From the project root directory:

```powershell
cd admin

# Deploy with source build
gcloud run deploy admin `
  --source . `
  --region us-central1 `
  --platform managed `
  --allow-unauthenticated `
  --project paperlms-001 `
  --set-env-vars "NEXT_PUBLIC_SUPABASE_URL=https://spzcjpvtikyoykbgnlgr.supabase.co,NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwemNqcHZ0aWt5b3lrYmdubGdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNTY2NzgsImV4cCI6MjA3OTkzMjY3OH0.m06J6IujRB6dX0Cqw00Y6NnGgGUCo6yU7CdnqSIWVzc"
```

**What this does:**
- Builds your Next.js app using Cloud Build
- Creates a Docker container
- Deploys to Cloud Run
- Sets environment variables
- Makes it publicly accessible

**Wait time:** 5-10 minutes for first deployment

### Step 4: Verify Deployment

After deployment completes, you'll see:
```
Service [admin] revision [admin-xxxxx] has been deployed and is serving 100 percent of traffic.
Service URL: https://admin-xxxxx-uc.a.run.app
```

### Step 5: Update Firebase Hosting

The Cloud Run service is now live! Firebase Hosting will automatically route to it since we configured the rewrite in `firebase.json`.

Visit: **https://admin-lakshya.web.app**

---

## Option 2: Build Docker Image Locally

If you prefer to build locally first:

### Step 1: Build Docker Image

```powershell
cd admin

# Build the image
docker build -t gcr.io/paperlms-001/admin:latest .

# Tag for Cloud Run
docker tag gcr.io/paperlms-001/admin:latest gcr.io/paperlms-001/admin:latest
```

### Step 2: Push to Google Container Registry

```powershell
# Configure Docker to use gcloud credentials
gcloud auth configure-docker

# Push the image
docker push gcr.io/paperlms-001/admin:latest
```

### Step 3: Deploy to Cloud Run

```powershell
gcloud run deploy admin `
  --image gcr.io/paperlms-001/admin:latest `
  --region us-central1 `
  --platform managed `
  --allow-unauthenticated `
  --project paperlms-001 `
  --set-env-vars "NEXT_PUBLIC_SUPABASE_URL=https://spzcjpvtikyoykbgnlgr.supabase.co,NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwemNqcHZ0aWt5b3lrYmdubGdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNTY2NzgsImV4cCI6MjA3OTkzMjY3OH0.m06J6IujRB6dX0Cqw00Y6NnGgGUCo6yU7CdnqSIWVzc"
```

---

## Option 3: Using Google Cloud Console (No CLI)

### Step 1: Go to Cloud Run Console

Visit: https://console.cloud.google.com/run?project=paperlms-001

### Step 2: Create Service

1. Click **"Create Service"**
2. Choose **"Deploy one revision from an existing container image"** or **"Continuously deploy new revisions from a source repository"**

### Step 3: Configure Service

**Basic Settings:**
- **Service name**: `admin`
- **Region**: `us-central1`
- **Deploy**: Choose one:
  - **From source**: Upload `admin/` directory
  - **From container**: Use `gcr.io/paperlms-001/admin:latest`

**Container Settings:**
- **Port**: `3000`
- **Container port**: `3000`
- **CPU**: 1 (or 2 for better performance)
- **Memory**: 512 MiB (or 1 GiB)

**Environment Variables:**
Click **"Variables & Secrets"** → **"Add Variable"**:
- `NEXT_PUBLIC_SUPABASE_URL` = `https://spzcjpvtikyoykbgnlgr.supabase.co`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` = `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwemNqcHZ0aWt5b3lrYmdubGdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNTY2NzgsImV4cCI6MjA3OTkzMjY3OH0.m06J6IujRB6dX0Cqw00Y6NnGgGUCo6yU7CdnqSIWVzc`

**Security:**
- **Allow unauthenticated invocations**: ✅ Yes

### Step 4: Deploy

Click **"Create"** and wait for deployment (5-10 minutes)

---

## Updating/Re-deploying

### Quick Update (Option 1 - Source Deploy)

```powershell
cd admin
gcloud run deploy admin --source . --region us-central1 --project paperlms-001
```

### Update Environment Variables

```powershell
gcloud run services update admin `
  --region us-central1 `
  --project paperlms-001 `
  --update-env-vars "NEXT_PUBLIC_SUPABASE_URL=new_value"
```

### View Logs

```powershell
gcloud run logs read admin --region us-central1 --project paperlms-001
```

Or visit: https://console.cloud.google.com/run/detail/us-central1/admin/logs?project=paperlms-001

---

## Troubleshooting

### "Permission denied" errors
```powershell
# Make sure you're authenticated
gcloud auth login
gcloud config set project paperlms-001
```

### "API not enabled" errors
```powershell
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### Build fails
- Check that `admin/.env.local` exists (for local builds)
- Verify all dependencies are in `package.json`
- Check build logs in Cloud Console

### Service not accessible
- Verify service is deployed: https://console.cloud.google.com/run?project=paperlms-001
- Check service URL is correct
- Verify Firebase Hosting rewrite is configured

### Environment variables not working
- Check variables are set: `gcloud run services describe admin --region us-central1`
- Restart service after updating variables
- Verify variable names start with `NEXT_PUBLIC_` for client-side access

---

## Quick Reference Commands

```powershell
# Deploy (from admin directory)
gcloud run deploy admin --source . --region us-central1 --project paperlms-001 --allow-unauthenticated

# View service details
gcloud run services describe admin --region us-central1 --project paperlms-001

# View logs
gcloud run logs read admin --region us-central1 --project paperlms-001 --limit 50

# Delete service (if needed)
gcloud run services delete admin --region us-central1 --project paperlms-001

# List all services
gcloud run services list --project paperlms-001
```

---

## After Deployment

Once Cloud Run is deployed:

1. ✅ Service will be available at: `https://admin-xxxxx-uc.a.run.app`
2. ✅ Firebase Hosting will route to it: `https://admin-lakshya.web.app`
3. ✅ Test the admin panel and verify all features work

**Next:** Test login, dashboard, leads, courses, and videos management!


