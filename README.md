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

## Next Steps for Production

1. **Backend Integration**: Connect lead forms to your CRM/backend API
2. **Analytics**: Add analytics tracking (Google Analytics, Firebase Analytics)
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
- **SharedPreferences**: Local storage
- **Material Design 3**: UI components

## License

Copyright © 2024 Lakshya Institute. All rights reserved.

