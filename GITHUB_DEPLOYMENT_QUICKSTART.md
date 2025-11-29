# GitHub Deployment Quick Start Guide

## ✅ Setup Status

All files are ready! Follow these steps to enable automatic deployment.

## Step 1: Create Google Cloud Service Account

1. **Go to**: https://console.cloud.google.com/iam-admin/serviceaccounts?project=paperlms-001
2. Click **"Create Service Account"**
3. Fill in:
   - **Name**: `github-actions-deploy`
   - **Description**: `Service account for GitHub Actions Cloud Run deployment`
4. Click **"Create and Continue"**
5. **Grant these roles**:
   - ✅ Cloud Run Admin (`roles/run.admin`)
   - ✅ Service Account User (`roles/iam.serviceAccountUser`)
   - ✅ Storage Admin (`roles/storage.admin`)
6. Click **"Continue"** then **"Done"**
7. Click on the service account → **"Keys"** tab → **"Add Key"** → **"Create new key"** → **JSON**
8. **Download the JSON file** (keep it secure!)

## Step 2: Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"** and add these:

### Secret 1: GCP_SA_KEY
- **Name**: `GCP_SA_KEY`
- **Value**: Paste the **entire contents** of the JSON key file you downloaded

### Secret 2: NEXT_PUBLIC_SUPABASE_URL
- **Name**: `NEXT_PUBLIC_SUPABASE_URL`
- **Value**: `https://spzcjpvtikyoykbgnlgr.supabase.co`

### Secret 3: NEXT_PUBLIC_SUPABASE_ANON_KEY
- **Name**: `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- **Value**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwemNqcHZ0aWt5b3lrYmdubGdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNTY2NzgsImV4cCI6MjA3OTkzMjY3OH0.m06J6IujRB6dX0Cqw00Y6NnGgGUCo6yU7CdnqSIWVzc`

## Step 3: Enable Required APIs

1. Go to: https://console.cloud.google.com/apis/library?project=paperlms-001
2. Enable these APIs (if not already enabled):
   - ✅ **Cloud Run API** (already enabled)
   - ✅ **Cloud Build API** - Click "Enable"
   - ✅ **Artifact Registry API** - Click "Enable"

## Step 4: Commit and Push

```bash
git add .
git commit -m "Add GitHub Actions for Cloud Run deployment"
git push origin main
```

## Step 5: Monitor Deployment

1. Go to your GitHub repository
2. Click on **"Actions"** tab
3. You should see **"Deploy Admin Panel to Cloud Run"** workflow running
4. Click on it to see build logs
5. Wait for it to complete (usually 3-5 minutes)

## ✅ Success!

Once deployment completes:
- **Admin Panel URL**: https://admin-lakshya.web.app
- **Cloud Run Service**: https://console.cloud.google.com/run/detail/us-central1/admin?project=paperlms-001

## 🔄 Future Deployments

Every time you push changes to the `main` branch that affect files in `admin/`, the workflow will automatically:
1. Build your Next.js app
2. Deploy to Cloud Run
3. Update the live site

You can also trigger deployments manually:
- Go to **Actions** tab → **Deploy Admin Panel to Cloud Run** → **Run workflow**

## 🐛 Troubleshooting

**Workflow fails at "Authenticate to Google Cloud":**
- Check that `GCP_SA_KEY` secret contains valid JSON
- Verify service account has correct roles

**Build fails:**
- Check that Supabase secrets are set correctly
- Verify environment variables in workflow logs

**Deployment fails:**
- Check Cloud Build API is enabled
- Verify service account has Storage Admin role
- Check Cloud Run logs: https://console.cloud.google.com/run/detail/us-central1/admin/logs?project=paperlms-001

## 📚 More Info

- Full setup guide: `.github/SETUP.md`
- Deployment options: `admin/DEPLOYMENT.md`

