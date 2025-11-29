# Firebase Setup Instructions

## Step 1: Get Your Firebase Project ID

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your **paperLMS** project
3. Click the gear icon ⚙️ next to "Project Overview"
4. Select "Project settings"
5. Scroll down to "Your apps" section
6. The **Project ID** is shown at the top of the General tab (it's usually lowercase, e.g., `paperlms-xxxxx` or just `paperlms`)

## Step 2: Update .firebaserc

Once you have the exact project ID, update `.firebaserc`:

```json
{
  "projects": {
    "default": "your-actual-project-id-here"
  }
}
```

## Step 3: Get Web App Configuration

1. In Firebase Console > Project Settings > General
2. Scroll to "Your apps" section
3. If you don't have a web app yet, click the `</>` (Web) icon to add one
4. Register your app with a nickname (e.g., "Lakshya Web")
5. Copy the Firebase configuration object

You'll see something like:
```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "paperlms.firebaseapp.com",
  projectId: "paperlms",
  storageBucket: "paperlms.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef",
  measurementId: "G-XXXXXXXXXX"
};
```

## Step 4: Configure Firebase in Flutter

For Flutter web, Firebase can be initialized automatically if you have the Firebase SDK scripts in `web/index.html`. However, for better control, you can:

### Option A: Use Environment Variables (Recommended for CI/CD)

Build with environment variables:
```bash
flutter build web --release \
  --dart-define=FIREBASE_API_KEY=your-api-key \
  --dart-define=FIREBASE_PROJECT_ID=your-project-id \
  --dart-define=FIREBASE_APP_ID=your-app-id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your-sender-id \
  --dart-define=FIREBASE_MEASUREMENT_ID=your-measurement-id
```

### Option B: Update firebase_config.dart (For Development)

Update `lib/config/firebase_config.dart` with default values (not recommended for production, but fine for testing).

## Step 5: Enable Firebase Hosting

1. In Firebase Console, go to "Hosting" in the left sidebar
2. Click "Get started"
3. Follow the setup wizard (we already have `firebase.json` configured)

## Step 6: Deploy

Once configured, deploy using:
```powershell
.\scripts\deploy.ps1
```

Or manually:
```bash
flutter build web --release
firebase deploy --only hosting
```

## Troubleshooting

- **Project ID not found**: Make sure you're logged in with `firebase login`
- **Hosting not enabled**: Enable it in Firebase Console > Hosting
- **Analytics not working**: Make sure Analytics is enabled in Firebase Console and you have the measurement ID configured

