# Functional Features Roadmap - MVP to Next Level

**Date:** January 2025  
**Status:** Planning Phase  
**Focus:** User-facing features to grow from MVP to full platform

## Overview

This document outlines functional features to transform the Lakshya MVP from a lead generation tool into a complete educational platform. These features focus on student engagement, enrollment management, and post-enrollment experience.

---

## Current MVP Features ✅

- ✅ Course catalog browsing
- ✅ Lead capture forms (enrollment, inquiry, brochure request)
- ✅ Course detail pages
- ✅ Video promos/testimonials
- ✅ Basic authentication
- ✅ Admin dashboard (Next.js) for lead management

---

## Phase 1: Enrollment & Payment System 💳

### 1.1 Complete Enrollment Flow

**Current State:**
- ✅ Lead form captures enrollment interest
- ❌ No actual enrollment processing
- ❌ No payment integration
- ❌ No enrollment confirmation

**Features to Add:**

1. **Enrollment Application Form**
   - Extended form with:
     - Educational background
     - Work experience
     - Preferred batch timing
     - Payment plan preference
     - Documents upload (transcripts, ID proof)
   - Form validation
   - Save draft functionality

2. **Payment Integration**
   - Stripe/Razorpay/PayPal integration
   - Multiple payment methods (card, UPI, bank transfer)
   - Payment plans (full payment, installments)
   - Payment gateway selection based on region
   - Payment receipt generation

3. **Enrollment Status Tracking**
   - Application submitted
   - Under review
   - Payment pending
   - Payment received
   - Enrollment confirmed
   - Enrollment rejected (with reason)

4. **Enrollment Confirmation**
   - Email confirmation with enrollment details
   - Welcome package (PDF)
   - Access credentials
   - Next steps guide

**Database Changes:**
- Enhance `enrollments` table with:
  - `status` (enum: pending, under_review, payment_pending, confirmed, rejected)
  - `payment_status` (enum: pending, partial, paid, refunded)
  - `payment_amount`
  - `payment_plan` (full, installment_3, installment_6)
  - `payment_transaction_id`
  - `application_data` (JSONB for form data)
  - `documents` (array of file URLs)
  - `reviewed_by` (faculty/admin ID)
  - `reviewed_at`
  - `rejection_reason`

**Files to Create:**
- `lib/screens/enrollment/enrollment_form_screen.dart`
- `lib/screens/enrollment/payment_screen.dart`
- `lib/screens/enrollment/enrollment_status_screen.dart`
- `lib/services/payment_service.dart`
- `lib/models/enrollment.dart` (enhance existing)
- `lib/widgets/enrollment/enrollment_form_widget.dart`
- `lib/widgets/enrollment/payment_method_selector.dart`

---

### 1.2 Payment Management

**Features:**
- Payment history
- Invoice generation
- Payment reminders
- Refund processing
- Installment tracking

**Files to Create:**
- `lib/screens/enrollment/payment_history_screen.dart`
- `lib/services/invoice_service.dart`
- `lib/widgets/enrollment/invoice_viewer.dart`

---

## Phase 2: Student Portal/Dashboard 🎓

### 2.1 Student Dashboard

**Current State:**
- ❌ No student portal
- ❌ No post-enrollment experience
- ❌ Students can't access their courses

**Features to Add:**

1. **Dashboard Overview**
   - Enrolled courses list
   - Progress overview (completion percentage)
   - Upcoming classes/assignments
   - Recent announcements
   - Quick stats (classes attended, assignments submitted)
   - Upcoming deadlines

2. **My Courses Section**
   - List of enrolled courses
   - Course progress tracking
   - Access course content
   - View schedule
   - Download materials

3. **Profile Management**
   - Edit profile information
   - Upload profile photo
   - Change password
   - Notification preferences
   - Communication preferences

**Database Changes:**
- Create `student_courses` table (many-to-many):
  - `student_id` (references profiles.id)
  - `course_id` (references courses.id)
  - `enrollment_date`
  - `completion_date`
  - `progress_percentage`
  - `status` (active, completed, paused, dropped)

**Files to Create:**
- `lib/screens/student/dashboard_screen.dart`
- `lib/screens/student/my_courses_screen.dart`
- `lib/screens/student/profile_screen.dart`
- `lib/widgets/student/course_progress_card.dart`
- `lib/widgets/student/upcoming_classes_widget.dart`
- `lib/providers/student_provider.dart`

---

### 2.2 Course Content Access

**Features:**
- Course materials library
- Video lectures access
- Downloadable resources
- Assignment submissions
- Quiz/assessment access
- Course schedule/calendar

**Database Changes:**
- Create `course_modules` table:
  - `course_id`
  - `module_number`
  - `title`
  - `description`
  - `type` (video, reading, assignment, quiz)
  - `content_url`
  - `duration`
  - `is_required`
  - `unlock_date`

- Create `student_progress` table:
  - `student_id`
  - `module_id`
  - `status` (not_started, in_progress, completed)
  - `completion_date`
  - `time_spent`
  - `last_accessed`

**Files to Create:**
- `lib/screens/student/course_content_screen.dart`
- `lib/screens/student/video_lecture_screen.dart`
- `lib/screens/student/assignments_screen.dart`
- `lib/widgets/student/module_card.dart`
- `lib/widgets/student/progress_tracker.dart`

---

## Phase 3: Communication & Engagement 💬

### 3.1 Messaging System

**Features:**
- Direct messaging with faculty
- Group messaging for course discussions
- File attachments
- Read receipts
- Message notifications

**Database Changes:**
- Create `conversations` table:
  - `id`
  - `type` (direct, group)
  - `course_id` (for course groups)
  - `created_at`
  - `updated_at`

- Create `messages` table:
  - `id`
  - `conversation_id`
  - `sender_id`
  - `content`
  - `attachments` (JSONB array)
  - `read_at`
  - `created_at`

**Files to Create:**
- `lib/screens/messaging/messages_screen.dart`
- `lib/screens/messaging/chat_screen.dart`
- `lib/widgets/messaging/message_bubble.dart`
- `lib/services/messaging_service.dart`
- `lib/providers/messaging_provider.dart`

---

### 3.2 Announcements & Notifications

**Features:**
- Course announcements
- Institute-wide announcements
- Assignment deadlines
- Class schedule changes
- Payment reminders
- Push notifications (mobile)
- Email notifications

**Database Changes:**
- Create `announcements` table:
  - `id`
  - `title`
  - `content`
  - `type` (course, institute, payment, schedule)
  - `target_audience` (all, specific_course, specific_students)
  - `target_course_id`
  - `target_student_ids` (array)
  - `priority` (low, medium, high, urgent)
  - `published_at`
  - `expires_at`
  - `created_by`

- Create `notification_preferences` table:
  - `user_id`
  - `email_enabled`
  - `push_enabled`
  - `sms_enabled`
  - `notification_types` (JSONB)

**Files to Create:**
- `lib/screens/announcements/announcements_screen.dart`
- `lib/widgets/announcements/announcement_card.dart`
- `lib/services/notification_service.dart`
- `lib/providers/announcements_provider.dart`

---

### 3.3 Live Chat Support

**Features:**
- Real-time chat widget
- Integration with WhatsApp/Telegram
- Chat history
- FAQ integration
- Escalation to human support

**Files to Create:**
- `lib/widgets/support/live_chat_widget.dart`
- `lib/services/support_service.dart`
- `lib/screens/support/chat_history_screen.dart`

---

## Phase 4: Learning Management Features 📚

### 4.1 Assignments & Submissions

**Features:**
- Assignment creation by faculty
- Student submission portal
- File upload support
- Grading system
- Feedback/reviews
- Due date tracking
- Late submission handling

**Database Changes:**
- Create `assignments` table:
  - `id`
  - `course_id`
  - `module_id`
  - `title`
  - `description`
  - `instructions`
  - `due_date`
  - `max_score`
  - `allowed_file_types`
  - `max_file_size`
  - `created_by`
  - `created_at`

- Create `submissions` table:
  - `id`
  - `assignment_id`
  - `student_id`
  - `submitted_at`
  - `files` (array of URLs)
  - `status` (draft, submitted, graded)
  - `score`
  - `feedback`
  - `graded_by`
  - `graded_at`

**Files to Create:**
- `lib/screens/student/assignments_list_screen.dart`
- `lib/screens/student/submit_assignment_screen.dart`
- `lib/widgets/student/assignment_card.dart`
- `lib/services/assignment_service.dart`

---

### 4.2 Quizzes & Assessments

**Features:**
- Online quizzes
- Multiple choice questions
- Timed assessments
- Auto-grading
- Results and feedback
- Retake policies

**Database Changes:**
- Create `quizzes` table:
  - `id`
  - `course_id`
  - `title`
  - `description`
  - `time_limit` (minutes)
  - `max_attempts`
  - `passing_score`
  - `available_from`
  - `available_until`

- Create `quiz_questions` table:
  - `id`
  - `quiz_id`
  - `question_text`
  - `question_type` (multiple_choice, true_false, short_answer)
  - `options` (JSONB)
  - `correct_answer`
  - `points`

- Create `quiz_attempts` table:
  - `id`
  - `quiz_id`
  - `student_id`
  - `started_at`
  - `submitted_at`
  - `score`
  - `answers` (JSONB)
  - `status` (in_progress, submitted, graded)

**Files to Create:**
- `lib/screens/student/quizzes_screen.dart`
- `lib/screens/student/quiz_taking_screen.dart`
- `lib/widgets/student/quiz_question_widget.dart`
- `lib/services/quiz_service.dart`

---

### 4.3 Progress Tracking & Analytics

**Features:**
- Course completion percentage
- Time spent tracking
- Performance analytics
- Learning path visualization
- Certificates on completion
- Badges/achievements

**Database Changes:**
- Enhance `student_progress` table (already mentioned)
- Create `certificates` table:
  - `id`
  - `student_id`
  - `course_id`
  - `certificate_number`
  - `issued_date`
  - `certificate_url`
  - `verification_code`

- Create `achievements` table:
  - `id`
  - `student_id`
  - `achievement_type`
  - `achievement_name`
  - `earned_at`
  - `badge_icon_url`

**Files to Create:**
- `lib/screens/student/progress_screen.dart`
- `lib/widgets/student/progress_chart.dart`
- `lib/screens/student/certificates_screen.dart`
- `lib/services/certificate_service.dart`

---

## Phase 5: Content & Resources 📖

### 5.1 Blog/News Section

**Features:**
- Educational articles
- Industry news
- Student success stories
- Faculty insights
- Study tips
- Career guidance
- Search functionality
- Categories/tags
- Comments (optional)

**Database Changes:**
- Create `blog_posts` table:
  - `id`
  - `title`
  - `slug`
  - `content`
  - `excerpt`
  - `featured_image`
  - `author_id`
  - `category`
  - `tags` (array)
  - `published_at`
  - `status` (draft, published, archived)
  - `views_count`
  - `likes_count`

**Files to Create:**
- `lib/screens/blog/blog_list_screen.dart`
- `lib/screens/blog/blog_detail_screen.dart`
- `lib/widgets/blog/blog_card.dart`
- `lib/providers/blog_provider.dart`

---

### 5.2 Resource Library

**Features:**
- Study materials repository
- Downloadable PDFs
- Video library
- Past papers
- Reference books
- Templates and tools
- Search and filter
- Favorites/bookmarks

**Database Changes:**
- Create `resources` table:
  - `id`
  - `title`
  - `description`
  - `type` (pdf, video, link, tool)
  - `file_url`
  - `course_id` (optional - course-specific)
  - `category`
  - `tags`
  - `download_count`
  - `is_premium` (requires enrollment)

**Files to Create:**
- `lib/screens/resources/resources_library_screen.dart`
- `lib/widgets/resources/resource_card.dart`
- `lib/providers/resources_provider.dart`

---

### 5.3 FAQ Section

**Features:**
- Categorized FAQs
- Search functionality
- Most asked questions
- Submit new question
- Upvote helpful answers

**Database Changes:**
- Create `faqs` table:
  - `id`
  - `question`
  - `answer`
  - `category`
  - `order`
  - `views_count`
  - `helpful_count`
  - `created_at`

**Files to Create:**
- `lib/screens/faq/faq_screen.dart`
- `lib/widgets/faq/faq_item.dart`
- `lib/providers/faq_provider.dart`

---

## Phase 6: Events & Webinars 🎤

### 6.1 Events Management

**Features:**
- Upcoming events calendar
- Webinar registration
- Event reminders
- Recordings access (for past events)
- Event categories (workshops, seminars, webinars)

**Database Changes:**
- Create `events` table:
  - `id`
  - `title`
  - `description`
  - `type` (workshop, webinar, seminar, conference)
  - `start_date`
  - `end_date`
  - `location` (physical or online link)
  - `meeting_link` (for online events)
  - `max_participants`
  - `registration_required`
  - `is_free`
  - `price`
  - `speaker_id`
  - `status` (upcoming, live, completed, cancelled)
  - `recording_url` (for past events)

- Create `event_registrations` table:
  - `id`
  - `event_id`
  - `student_id`
  - `registered_at`
  - `attended` (boolean)
  - `attendance_confirmed_at`

**Files to Create:**
- `lib/screens/events/events_calendar_screen.dart`
- `lib/screens/events/event_detail_screen.dart`
- `lib/widgets/events/event_card.dart`
- `lib/providers/events_provider.dart`

---

## Phase 7: Social & Community 👥

### 7.1 Student Community

**Features:**
- Discussion forums
- Study groups
- Peer connections
- Q&A section
- Student directory (optional, privacy-controlled)

**Database Changes:**
- Create `forums` table:
  - `id`
  - `course_id`
  - `title`
  - `description`
  - `is_public`
  - `created_by`

- Create `forum_posts` table:
  - `id`
  - `forum_id`
  - `author_id`
  - `title`
  - `content`
  - `is_pinned`
  - `views_count`
  - `replies_count`
  - `created_at`

- Create `forum_replies` table:
  - `id`
  - `post_id`
  - `author_id`
  - `content`
  - `is_solution` (marked as best answer)
  - `created_at`

**Files to Create:**
- `lib/screens/community/forums_screen.dart`
- `lib/screens/community/forum_post_screen.dart`
- `lib/widgets/community/post_card.dart`
- `lib/providers/community_provider.dart`

---

### 7.2 Referral Program

**Features:**
- Referral code generation
- Track referrals
- Rewards system
- Referral dashboard
- Leaderboard

**Database Changes:**
- Create `referrals` table:
  - `id`
  - `referrer_id` (student who referred)
  - `referred_email`
  - `referred_name`
  - `referral_code`
  - `status` (pending, enrolled, completed)
  - `reward_earned`
  - `created_at`

**Files to Create:**
- `lib/screens/referrals/referral_dashboard_screen.dart`
- `lib/widgets/referrals/referral_code_widget.dart`
- `lib/services/referral_service.dart`

---

## Phase 8: Enhanced Discovery & Comparison 🔍

### 8.1 Course Comparison Tool

**Features:**
- Side-by-side course comparison
- Compare up to 3 courses
- Highlight differences
- Feature comparison matrix

**Files to Create:**
- `lib/screens/courses/course_comparison_screen.dart`
- `lib/widgets/courses/comparison_table.dart`

---

### 8.2 Advanced Search & Filters

**Features:**
- Full-text search
- Advanced filters (duration, level, price, format)
- Sort options
- Save search preferences
- Search history

**Files to Modify:**
- `lib/screens/courses_screen.dart` - Add advanced filters
- `lib/widgets/shared/search_bar.dart` - Enhance search

---

### 8.3 Course Recommendations

**Features:**
- Personalized course recommendations
- "Students also viewed"
- "Complete your learning path"
- Based on browsing history
- Based on enrolled courses

**Files to Create:**
- `lib/services/recommendation_service.dart`
- `lib/widgets/courses/recommended_courses_widget.dart`

---

## Phase 9: Administrative Features (Student-Facing) ⚙️

### 9.1 Application Status Portal

**Features:**
- View enrollment application status
- Upload additional documents
- Track payment status
- View admission decision
- Appeal/reapply if rejected

**Files to Create:**
- `lib/screens/enrollment/application_status_screen.dart`
- `lib/widgets/enrollment/status_timeline.dart`

---

### 9.2 Financial Aid/Scholarship Portal

**Features:**
- Scholarship applications
- Financial aid calculator
- Application status tracking
- Document submission

**Database Changes:**
- Create `scholarship_applications` table:
  - `id`
  - `student_id`
  - `scholarship_type`
  - `application_data` (JSONB)
  - `documents` (array)
  - `status` (pending, under_review, approved, rejected)
  - `amount_awarded`
  - `created_at`

**Files to Create:**
- `lib/screens/scholarships/scholarship_portal_screen.dart`
- `lib/screens/scholarships/apply_scholarship_screen.dart`

---

## Phase 10: Mobile App Features 📱

### 10.1 Mobile-Optimized Features

**Features:**
- Push notifications
- Offline content download
- Mobile-optimized video player
- Quick actions (enroll, contact, schedule)
- Biometric login
- App shortcuts

---

## Implementation Priority

### High Priority (Immediate Business Value)
1. **Phase 1: Enrollment & Payment** - Critical for revenue
2. **Phase 2: Student Portal** - Core post-enrollment experience
3. **Phase 3.2: Announcements** - Essential communication

### Medium Priority (Enhanced Experience)
4. **Phase 3.1: Messaging** - Student-faculty communication
5. **Phase 4.1: Assignments** - Learning management
6. **Phase 5.3: FAQ** - Reduce support load
7. **Phase 5.1: Blog** - Content marketing

### Lower Priority (Nice to Have)
8. **Phase 4.2: Quizzes** - Assessment system
9. **Phase 6: Events** - Community engagement
10. **Phase 7: Community** - Social features
11. **Phase 8: Enhanced Discovery** - Better UX

---

## Database Migration Summary

### New Tables Needed:
1. `student_courses` - Enrollment tracking
2. `course_modules` - Course content structure
3. `student_progress` - Learning progress
4. `conversations` & `messages` - Messaging
5. `announcements` - Notifications
6. `assignments` & `submissions` - Assignment system
7. `quizzes`, `quiz_questions`, `quiz_attempts` - Assessment system
8. `certificates` - Certificate generation
9. `blog_posts` - Content management
10. `resources` - Resource library
11. `faqs` - FAQ system
12. `events` & `event_registrations` - Events management
13. `forums`, `forum_posts`, `forum_replies` - Community
14. `referrals` - Referral program
15. `scholarship_applications` - Financial aid

### Tables to Enhance:
- `enrollments` - Add payment and status fields
- `profiles` - Add student-specific fields

---

## Success Metrics

### Enrollment Metrics
- Enrollment conversion rate (leads → enrollments)
- Payment completion rate
- Average time to enrollment

### Engagement Metrics
- Daily active users
- Course completion rate
- Assignment submission rate
- Average time spent learning

### Revenue Metrics
- Monthly recurring revenue (MRR)
- Average revenue per student
- Payment plan adoption rate

---

## Next Steps

1. **Prioritize Features** - Review with stakeholders
2. **Create Detailed Specifications** - For each feature
3. **Database Design** - Create migration files
4. **UI/UX Design** - Wireframes and mockups
5. **Development Sprints** - Break into manageable tasks
6. **Testing Strategy** - Plan testing for each feature
7. **Launch Plan** - Phased rollout strategy

---

**Last Updated:** January 2025  
**Next Review:** After Phase 1 completion

