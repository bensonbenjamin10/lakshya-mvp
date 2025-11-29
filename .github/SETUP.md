# GitHub Actions Setup for Cloud Run Deployment

This guide will help you set up automatic deployment of the admin panel to Cloud Run via GitHub Actions.

## Prerequisites

1. GitHub repository with your code
2. Google Cloud Project: `paperlms-001`
3. Cloud Run Admin API enabled (already done ✅)

## Step 1: Create Google Cloud Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com/iam-admin/serviceaccounts?project=paperlms-001)
2. Click "Create Service Account"
3. Name: `github-actions-deploy`
4. Description: `Service account for GitHub Actions Cloud Run deployment`
5. Click "Create and Continue"
6. Grant roles:
   - **Cloud Run Admin** (`roles/run.admin`)
   - **Service Account User** (`roles/iam.serviceAccountUser`)
   - **Storage Admin** (`roles/storage.admin`) - for source uploads
7. Click "Continue" then "Done"

## Step 2: Create Service Account Key

1. Click on the service account you just created
2. Go to "Keys" tab
3. Click "Add Key" → "Create new key"
4. Choose "JSON"
5. Download the key file (keep it secure!)

## Step 3: Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click "New repository secret"
4. Add these secrets:

   **GCP_SA_KEY**
   - Value: Paste the entire contents of the JSON key file you downloaded

   **NEXT_PUBLIC_SUPABASE_URL**
   - Value: `https://spzcjpvtikyoykbgnlgr.supabase.co`

   **NEXT_PUBLIC_SUPABASE_ANON_KEY**
   - Value: Your Supabase anonymous key (from `lib/config/supabase_config.dart`)

## Step 4: Enable Required APIs

Make sure these APIs are enabled in your Google Cloud project:

- Cloud Run API ✅ (already enabled)
- Cloud Build API (for source deployments)
- Artifact Registry API (for container images)

You can enable them at: https://console.cloud.google.com/apis/library?project=paperlms-001

## Step 5: Push to GitHub

Once secrets are configured:

```bash
git add .
git commit -m "Add GitHub Actions workflow for Cloud Run deployment"
git push origin main
```

## How It Works

- **Automatic deployment**: Every push to `main` branch that changes files in `admin/` will trigger deployment
- **Manual deployment**: You can also trigger it manually from GitHub Actions tab
- **Build**: Runs `npm ci` and `npm run build` in the `admin/` directory
- **Deploy**: Uses `gcloud run deploy` to deploy the built app to Cloud Run

## Monitoring

- View deployment logs in GitHub Actions tab
- Check Cloud Run service at: https://console.cloud.google.com/run?project=paperlms-001
- View logs: https://console.cloud.google.com/run/detail/us-central1/admin/logs?project=paperlms-001

## Troubleshooting

**Build fails:**
- Check that `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` secrets are set correctly

**Deployment fails:**
- Verify service account has correct permissions
- Check that Cloud Build API is enabled
- Ensure `GCP_SA_KEY` secret contains valid JSON

**Service not accessible:**
- Check Cloud Run service is deployed and running
- Verify Firebase Hosting rewrite is configured correctly

