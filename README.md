# Lakshya Institute MVP - Flutter PWA

A Progressive Web App (PWA) built with Flutter for Lakshya Institute, a leading educational institution offering commerce professional courses globally.

## Features

- 🎓 **Course Catalog**: Browse ACCA, CA, CMA (US), and Integrated B.Com & MBA programs
- 📝 **Lead Capture**: Multiple lead capture forms for inquiries, enrollments, and brochure requests
- 📱 **PWA Support**: Installable Progressive Web App with offline capabilities
- 🌐 **Global Ready**: Designed to scale globally with responsive design
- 🎨 **Modern UI**: Clean, professional design optimized for conversions

## Courses Offered

- **ACCA** (Association of Chartered Certified Accountants)
- **CA** (Chartered Accountancy)
- **CMA (US)** (Certified Management Accountant)
- **Integrated B.Com & MBA**

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Chrome browser (for web development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd lakshya-mvp
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For web
flutter run -d chrome

# For mobile (iOS/Android)
flutter run
```

### Building for Production

#### Web (PWA)
```bash
flutter build web --release
```

The built files will be in the `build/web` directory.

#### Mobile Apps
```bash
# Android
flutter build apk --release
# or
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── course.dart
│   └── lead.dart
├── providers/                # State management
│   ├── course_provider.dart
│   └── lead_provider.dart
├── routes/                   # Navigation
│   └── app_router.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── courses_screen.dart
│   ├── course_detail_screen.dart
│   ├── contact_screen.dart
│   └── about_screen.dart
├── widgets/                  # Reusable widgets
│   ├── hero_section.dart
│   ├── course_card.dart
│   ├── features_section.dart
│   ├── testimonials_section.dart
│   ├── cta_section.dart
│   └── lead_form_dialog.dart
└── theme/                    # App theming
    └── app_theme.dart
```

## Key Features Implementation

### Lead Management
- Leads are captured through various forms (enrollment, inquiry, contact, brochure request)
- Lead data is stored locally (can be integrated with backend API)
- Tracks lead source, inquiry type, and course interest

### Course Management
- Course catalog with detailed information
- Course highlights and features
- Popular courses showcase
- Course detail pages with enrollment CTAs

### PWA Configuration
- Service worker for offline support
- Web manifest for installability
- Responsive design for all devices

## Firebase Setup and Deployment

### Prerequisites

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Firebase Hosting in the Firebase Console
3. Enable Firebase Analytics in the Firebase Console
4. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```
5. Login to Firebase:
   ```bash
   firebase login
   ```

### Configuration

1. **Get Firebase Web App Configuration**:
   - Go to Firebase Console > Project Settings > General
   - Scroll to "Your apps" section and click on the Web app icon (`</>`)
   - Copy the Firebase configuration values

2. **Update Firebase Configuration**:
   - Update `.firebaserc` with your Firebase project ID:
     ```json
     {
       "projects": {
         "default": "your-actual-firebase-project-id"
       }
     }
     ```
   - For production builds, set Firebase environment variables or update `lib/config/firebase_config.dart` with your Firebase config values

3. **Build and Deploy**:
   
   **Windows (PowerShell)**:
   ```powershell
   .\scripts\deploy.ps1
   ```
   
   **Linux/Mac (Bash)**:
   ```bash
   chmod +x scripts/deploy.sh
   ./scripts/deploy.sh
   ```
   
   **Manual Deployment**:
   ```bash
   # Build Flutter web app
   flutter build web --release
   
   # Deploy to Firebase Hosting
   firebase deploy --only hosting
   ```

### Firebase Analytics Events

The app tracks the following analytics events:

- **Page Views**: Automatic tracking via route changes
- **lead_submission**: When a lead form is submitted
  - Parameters: `course_id`, `source`, `inquiry_type`, `country`
- **course_view**: When a course detail page is viewed
  - Parameters: `course_id`, `course_name`
- **cta_click**: When a CTA button is clicked
  - Parameters: `cta_location`, `course_id` (if applicable)
- **video_play**: When a promo video is played
  - Parameters: `video_id`, `video_title`
- **whatsapp_click**: When WhatsApp link is clicked
  - Parameters: `source_location`

### Custom Domain

After deployment, you can configure a custom domain in Firebase Console:
1. Go to Firebase Console > Hosting
2. Click "Add custom domain"
3. Follow the instructions to verify domain ownership
4. Firebase will automatically provision SSL certificates

## Next Steps for Production

1. ✅ **Analytics**: Firebase Analytics integrated
2. **Backend Integration**: Connect lead forms to your CRM/backend API (Supabase already integrated)
3. **Payment Integration**: Add payment gateway for enrollment
4. **User Authentication**: Add student portal/login functionality
5. **Content Management**: Integrate CMS for dynamic content
6. **Push Notifications**: Add PWA push notifications
7. **SEO Optimization**: Enhance meta tags and structured data
8. **Performance**: Optimize images and implement lazy loading

## Technologies Used

- **Flutter**: Cross-platform framework
- **GoRouter**: Navigation and routing
- **Provider**: State management
- **Supabase**: Backend and database
- **Firebase**: Hosting and Analytics
- **Material Design 3**: UI components

## License

Copyright © 2024 Lakshya Institute. All rights reserved.

