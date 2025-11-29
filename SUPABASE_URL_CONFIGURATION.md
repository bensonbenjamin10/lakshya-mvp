# Supabase URL Configuration for Production

## Issue
Supabase confirmation emails are using `http://localhost:3000` as the redirect URL instead of the production URL.

## Solution

You need to configure the redirect URLs in Supabase Dashboard. The code has been updated to use production URLs, but Supabase Dashboard settings also need to be updated.

### Step 1: Update Supabase Dashboard Settings

1. Go to your Supabase Dashboard: https://supabase.com/dashboard/project/spzcjpvtikyoykbgnlgr
2. Navigate to **Authentication** > **URL Configuration**
3. Update the following settings:

#### Site URL
Set to your production URL:
```
https://paperlms-001.web.app
```

#### Redirect URLs
Add these URLs (one per line):
```
https://paperlms-001.web.app
https://paperlms-001.web.app/**
http://localhost:3000
http://localhost:3000/**
```

The `**` wildcard allows all sub-paths to work (e.g., `/login`, `/admin`, etc.)

### Step 2: Email Templates (Optional)

You can also customize email templates:
1. Go to **Authentication** > **Email Templates**
2. Update the **Confirm signup** template if needed
3. The redirect URL will automatically use the configured Site URL

### Step 3: Verify Configuration

After updating:
1. Try registering a new user
2. Check the confirmation email - it should now use `https://paperlms-001.web.app` instead of `localhost:3000`
3. Password reset emails will also use the production URL

## Code Changes Made

- Updated `lib/config/app_config.dart` to include production redirect URL
- Updated `lib/services/auth_service.dart` to use production URL for:
  - Email confirmations (`signUpWithEmail`)
  - Password resets (`resetPassword`)

## Environment Variables (Optional)

For different environments, you can override the redirect URL:
```bash
flutter build web --release --dart-define=AUTH_REDIRECT_URL=https://your-custom-domain.com
```

## Notes

- The Site URL in Supabase Dashboard is the primary setting
- Redirect URLs must be explicitly allowed in the Redirect URLs list
- Both `localhost` and production URLs are included for development flexibility
- After updating Supabase settings, new emails will use the production URL

