# Phone OTP Authentication Setup Guide

This guide covers setting up Phone OTP authentication for the Lakshya app using Supabase and Twilio.

## Step 1: Create Twilio Account

1. Go to [Twilio Console](https://console.twilio.com/)
2. Sign up for a free account (includes trial credits)
3. Verify your email and phone number

## Step 2: Get Twilio Credentials

From Twilio Console, note down:
- **Account SID**: Found on dashboard (starts with `AC...`)
- **Auth Token**: Found on dashboard (click to reveal)
- **Phone Number**: Get a Twilio phone number from Console → Phone Numbers → Buy a Number

## Step 3: Configure Supabase Phone Auth

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Navigate to **Authentication** → **Providers**
4. Find **Phone** and enable it
5. Configure SMS Provider:

### Twilio Configuration in Supabase

```
SMS Provider: Twilio
Account SID: AC... (your Account SID)
Auth Token: (your Auth Token)
Message Service SID: (leave empty) OR your Messaging Service SID
Twilio Phone Number: +1234567890 (your Twilio number)
```

## Step 4: SMS Template (Optional)

Customize the OTP message in Supabase:
- Go to **Authentication** → **Email Templates** → **SMS Message**
- Default: `Your verification code is: {{ .Code }}`

## Step 5: Test Configuration

Test in Supabase SQL Editor:
```sql
-- This will be triggered when signInWithOtp is called
SELECT * FROM auth.users WHERE phone = '+919876543210';
```

## Twilio Pricing (India)

| Type | Cost |
|------|------|
| SMS to India | ~$0.0075/message |
| Trial credits | $15.50 free |
| ~2000 OTPs | Free with trial |

## Alternative: Twilio Verify Service

For production, consider Twilio Verify (handles rate limiting, fraud prevention):
1. Create Verify Service in Twilio Console
2. Use Verify API instead of direct SMS

## Troubleshooting

### "Invalid phone number format"
- Ensure E.164 format: `+[country code][number]`
- India: `+919876543210` (10 digits after +91)

### "SMS not received"
- Check Twilio logs for delivery status
- Verify phone number is not on DND (India)
- Trial accounts can only send to verified numbers

### "Rate limit exceeded"
- Supabase limits: 30 OTPs per hour per phone
- Implement cooldown timer in UI

## Environment Variables (Optional)

For additional security, use environment variables:
```env
TWILIO_ACCOUNT_SID=AC...
TWILIO_AUTH_TOKEN=...
TWILIO_PHONE_NUMBER=+1...
```

## Next Steps

After setup:
1. Test OTP flow in the app
2. Monitor Twilio usage in console
3. Set up usage alerts to avoid unexpected charges

