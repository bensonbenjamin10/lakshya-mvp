# Admin Panel Deployment Guide

## Deployment Options

### Option 1: GitHub Actions (Recommended) ✅

**Automatic deployment via GitHub Actions** - Set up once, deploy automatically on every push!

See `.github/SETUP.md` for complete setup instructions.

**Quick Setup:**
1. Create Google Cloud Service Account with Cloud Run Admin role
2. Add GitHub Secrets:
   - `GCP_SA_KEY` - Service account JSON key
   - `NEXT_PUBLIC_SUPABASE_URL` - Your Supabase URL
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Your Supabase anon key
3. Push to GitHub - deployment happens automatically!

**Benefits:**
- ✅ Automatic deployments on push
- ✅ No manual steps required
- ✅ Build logs in GitHub
- ✅ Easy rollback via Git

### Option 2: Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/run)
2. Select project: `paperlms-001`
3. Click "Create Service"
4. Configure:
   - **Service name**: `admin`
   - **Region**: `us-central1`
   - **Deploy**: "Continuously deploy new revisions from a source repository"
   - **Source**: Upload from local filesystem
   - **Source location**: `admin/` directory
   - **Runtime**: Node.js 20
   - **Port**: 3000
   - **Allow unauthenticated invocations**: Yes

5. Set environment variables:
   - `NEXT_PUBLIC_SUPABASE_URL`: https://spzcjpvtikyoykbgnlgr.supabase.co
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`: (Your Supabase anon key)

6. Click "Create" and wait for deployment

### Option 3: gcloud CLI

If you have gcloud CLI installed:

```bash
cd admin
gcloud run deploy admin \
  --source . \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --project paperlms-001 \
  --set-env-vars NEXT_PUBLIC_SUPABASE_URL=https://spzcjpvtikyoykbgnlgr.supabase.co,NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key_here
```

## Current Status

✅ **Firebase Hosting**: Deployed successfully
- URL: https://admin-lakshya.web.app
- Static files are live

⚠️ **Cloud Run**: Needs to be deployed (use one of the options above)

## After Cloud Run Deployment

Once Cloud Run is deployed, Firebase Hosting will automatically route requests to it. The admin panel will be fully functional at:

**https://admin-lakshya.web.app**

## Testing

1. Visit https://admin-lakshya.web.app
2. Login with admin/faculty credentials
3. Test all features:
   - Dashboard
   - Leads management
   - Courses management
   - Videos management
   - Analytics

## Troubleshooting

- **404 errors**: Cloud Run service might not be deployed yet
- **Authentication errors**: Check Supabase environment variables
- **Build errors**: Ensure environment variables are set correctly
- **GitHub Actions failures**: Check secrets are configured correctly
