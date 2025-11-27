# Lakshya Institute MVP - Design Document

## Overview

This document outlines the design and architecture of the Lakshya Institute MVP - a Progressive Web App (PWA) built with Flutter for lead generation and course enrollment.

## Business Goals

1. **Lead Generation**: Capture leads from multiple channels (website, social media, referrals, ads)
2. **Course Discovery**: Showcase ACCA, CA, CMA (US), and Integrated B.Com & MBA programs
3. **Conversion Optimization**: Drive enrollments through strategic CTAs and forms
4. **Global Scalability**: Design for international reach with responsive, accessible UI
5. **Future-Proof**: Built on Flutter for easy migration to native mobile apps

## Architecture

### Technology Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Navigation**: GoRouter
- **Local Storage**: SharedPreferences
- **PWA Support**: Service Worker + Web Manifest

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (Course, Lead)
├── providers/                # State management (CourseProvider, LeadProvider)
├── routes/                   # Navigation configuration
├── screens/                  # Main UI screens
│   ├── home_screen.dart      # Landing page
│   ├── courses_screen.dart   # Course catalog
│   ├── course_detail_screen.dart  # Individual course details
│   ├── contact_screen.dart  # Contact/inquiry page
│   └── about_screen.dart     # About Lakshya
├── widgets/                  # Reusable UI components
│   ├── hero_section.dart     # Hero banner
│   ├── course_card.dart      # Course display card
│   ├── features_section.dart # Why choose Lakshya
│   ├── testimonials_section.dart  # Student testimonials
│   ├── cta_section.dart      # Call-to-action section
│   └── lead_form_dialog.dart # Lead capture form
└── theme/                    # App theming
    └── app_theme.dart        # Material Design 3 theme
```

## Key Features

### 1. Landing Page (Home Screen)

**Components:**
- Hero Section: Compelling headline with primary CTAs
- Popular Courses: Horizontal scroll of featured courses
- Features Section: 6 key differentiators (Global Recognition, Expert Faculty, etc.)
- Testimonials: Social proof from students
- CTA Section: Final conversion push
- Footer: Navigation and contact info

**Conversion Goals:**
- Drive course exploration
- Capture initial interest
- Build trust through testimonials

### 2. Course Catalog

**Features:**
- Grid/list view of all courses
- Category filters (ACCA, CA, CMA, B.Com & MBA)
- Course cards with key information
- Quick access to course details

**Course Information:**
- Title and description
- Duration and level
- Key highlights
- Popular badge
- Enrollment CTA

### 3. Course Detail Pages

**Content:**
- Full course description
- Detailed highlights
- Duration and level information
- Multiple CTAs:
  - "Enroll Now" (direct enrollment)
  - "Request Info" (inquiry form)

**Lead Capture:**
- Context-aware forms
- Pre-filled course information
- Multiple inquiry types

### 4. Lead Capture System

**Form Types:**
1. **Enrollment**: Direct course enrollment interest
2. **Course Inquiry**: General course questions
3. **Brochure Request**: Download course materials
4. **General Contact**: General inquiries

**Data Collected:**
- Name, Email, Phone (required)
- Country (optional)
- Message (optional)
- Lead Source (website, social media, referral, ad, other)
- Course Interest (if applicable)
- Inquiry Type

**Storage:**
- Currently: Local storage (SharedPreferences)
- Production: Backend API integration needed

### 5. Contact Page

**Features:**
- Contact information cards
- Quick action buttons
- Multiple inquiry options
- Professional presentation

## Design System

### Color Palette

- **Primary**: Deep Blue (#1E3A8A) - Trust, professionalism
- **Secondary**: Bright Blue (#3B82F6) - Energy, innovation
- **Accent**: Amber/Gold (#F59E0B) - Premium, achievement
- **Success**: Green (#10B981) - Positive actions
- **Error**: Red (#EF4444) - Alerts
- **Background**: Light Gray (#F9FAFB) - Clean, modern
- **Surface**: White (#FFFFFF) - Content areas

### Typography

- **Display**: Bold, large headings (32px, 28px, 24px)
- **Headline**: Medium weight, section titles (20px)
- **Body**: Regular weight, readable text (16px, 14px)

### Components

- **Cards**: Elevated, rounded corners (12px radius)
- **Buttons**: Rounded (8px radius), clear hierarchy
- **Forms**: Outlined inputs, clear validation
- **Spacing**: Consistent 8px grid system

## User Flows

### Lead Generation Flow

1. **Discovery**: User lands on homepage
2. **Exploration**: Browse courses or read about institute
3. **Interest**: Click on course or CTA
4. **Engagement**: View course details
5. **Conversion**: Fill lead form
6. **Confirmation**: Success message

### Enrollment Flow

1. **Course Selection**: Choose specific course
2. **Information Review**: Read course details
3. **Form Submission**: Complete enrollment form
4. **Confirmation**: Receive confirmation message
5. **Follow-up**: (Backend) Send welcome email

## PWA Features

### Manifest Configuration

- **Name**: Lakshya Institute - Commerce Professional Courses
- **Short Name**: Lakshya
- **Display**: Standalone (app-like experience)
- **Theme Color**: Primary blue
- **Icons**: Multiple sizes for different devices

### Service Worker

- **Caching**: App shell and assets
- **Offline**: Basic offline support
- **Updates**: Cache versioning

## Analytics & Tracking (To Be Implemented)

### Recommended Integrations

1. **Google Analytics**: Track page views, user behavior
2. **Facebook Pixel**: Track conversions from ads
3. **Google Tag Manager**: Centralized tag management
4. **Heatmaps**: User interaction analysis (Hotjar, Crazy Egg)

### Key Metrics

- Lead form submissions
- Course page views
- CTA click-through rates
- Form abandonment rates
- Source attribution

## Backend Integration (Future)

### API Endpoints Needed

```
POST /api/leads
  - Submit lead form data
  - Return confirmation

GET /api/courses
  - Fetch course catalog
  - Return course details

POST /api/enrollments
  - Process enrollment
  - Return enrollment confirmation
```

### CRM Integration

- **HubSpot**: Lead management
- **Salesforce**: Enterprise CRM
- **Custom**: API-based integration

## Mobile App Migration Path

### Flutter Benefits

- **Single Codebase**: Same code for web, iOS, Android
- **Native Performance**: Compiled to native code
- **Consistent UI**: Same design across platforms
- **Easy Migration**: Minimal changes needed

### Migration Steps

1. Add platform-specific configurations
2. Implement native features (push notifications, biometrics)
3. Optimize for mobile UX
4. Test on physical devices
5. Submit to app stores

## Performance Optimization

### Current Optimizations

- Lazy loading of course lists
- Efficient state management
- Optimized images (to be added)
- Code splitting (Flutter web)

### Future Optimizations

- Image optimization and lazy loading
- CDN integration
- Caching strategies
- Bundle size optimization

## Security Considerations

### Data Protection

- Form validation (client-side)
- HTTPS enforcement
- Secure API communication (future)
- GDPR compliance (future)

### Lead Data

- Secure storage
- Encryption at rest (backend)
- Access controls
- Data retention policies

## Testing Strategy

### Unit Tests

- Provider logic
- Form validation
- Data models

### Widget Tests

- UI components
- User interactions
- Form submissions

### Integration Tests

- User flows
- Navigation
- Lead submission

## Deployment

### Web Deployment

1. Build: `flutter build web --release`
2. Host: Firebase Hosting, Netlify, or AWS
3. CDN: CloudFlare or AWS CloudFront
4. SSL: Automatic HTTPS

### Mobile Deployment

1. iOS: App Store submission
2. Android: Google Play Store submission
3. Beta Testing: TestFlight, Firebase App Distribution

## Next Steps

1. **Immediate**:
   - Install dependencies (`flutter pub get`)
   - Test locally
   - Add placeholder images
   - Configure backend API endpoints

2. **Short-term**:
   - Backend API integration
   - Analytics implementation
   - SEO optimization
   - Performance testing

3. **Long-term**:
   - Mobile app release
   - Advanced features (student portal, payments)
   - Content management system
   - Multi-language support

## Success Metrics

- **Lead Volume**: Number of leads generated
- **Conversion Rate**: Leads to enrollments
- **Engagement**: Time on site, pages per session
- **Source Attribution**: Which channels drive most leads
- **Form Completion**: Form abandonment rates

---

**Version**: 1.0  
**Last Updated**: 2024  
**Status**: MVP Prototype

