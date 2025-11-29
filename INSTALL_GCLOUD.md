# Installing Google Cloud CLI (gcloud) on Windows

## Quick Installation Steps

### Method 1: Download Installer (Recommended) ⭐

1. **Download the Installer**
   - Visit: https://cloud.google.com/sdk/docs/install
   - Click "Download Google Cloud SDK"
   - Choose "Windows x86_64" (or appropriate for your system)
   - Save the installer file

2. **Run the Installer**
   - Double-click the downloaded `.exe` file
   - Follow the installation wizard
   - **Important**: Check "Run gcloud init" at the end (or run it manually)

3. **Initialize gcloud**
   ```powershell
   gcloud init
   ```
   - Login with your Google account
   - Select project: `paperlms-001`
   - Choose default region: `us-central1`

4. **Verify Installation**
   ```powershell
   gcloud --version
   ```

### Method 2: Using PowerShell (Alternative)

If you prefer command-line installation:

```powershell
# Download installer
Invoke-WebRequest -Uri "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe" -OutFile "$env:TEMP\GoogleCloudSDKInstaller.exe"

# Run installer
Start-Process -FilePath "$env:TEMP\GoogleCloudSDKInstaller.exe" -Wait

# After installation, restart PowerShell and run:
gcloud init
```

## After Installation

### 1. Authenticate
```powershell
gcloud auth login
```

### 2. Set Your Project
```powershell
gcloud config set project paperlms-001
```

### 3. Verify Setup
```powershell
gcloud config list
```

You should see:
- `project = paperlms-001`
- `region = us-central1` (or your chosen region)

## Enable Required APIs

```powershell
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
```

## Test Installation

```powershell
# Check version
gcloud --version

# List projects
gcloud projects list

# Check current config
gcloud config list
```

## Troubleshooting

### "gcloud is not recognized"
- **Restart PowerShell/Command Prompt** after installation
- Check if gcloud is in PATH: `$env:PATH -split ';' | Select-String "google"`
- If not found, add manually:
  - Usually installed at: `C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin`
  - Add to PATH: `[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin", "User")`

### Authentication Issues
```powershell
# Re-authenticate
gcloud auth login

# Set application default credentials
gcloud auth application-default login
```

### Project Not Found
```powershell
# List available projects
gcloud projects list

# Set the correct project
gcloud config set project paperlms-001
```

## Next Steps

Once gcloud is installed and configured:

1. **Deploy Cloud Run Service**
   ```powershell
   cd admin
   gcloud run deploy admin --source . --region us-central1 --project paperlms-001 --allow-unauthenticated
   ```

2. **Or use the helper script**
   ```powershell
   .\scripts\deploy-cloud-run-manual.ps1
   ```

## Resources

- Official Docs: https://cloud.google.com/sdk/docs/install
- Quick Start: https://cloud.google.com/sdk/docs/quickstart
- Video Tutorial: https://www.youtube.com/watch?v=7mE-9E4D4Os


