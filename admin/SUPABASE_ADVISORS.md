# Supabase Advisors Report

This document summarizes the security and performance advisors from Supabase.

## Security Advisors

### ⚠️ Leaked Password Protection Disabled
**Level:** WARN  
**Issue:** Leaked password protection is currently disabled.  
**Impact:** Supabase Auth prevents the use of compromised passwords by checking against HaveIBeenPwned.org.  
**Recommendation:** Enable this feature to enhance security.  
**Remediation:** https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

## Performance Advisors

### ⚠️ Auth RLS Initialization Plan
**Level:** WARN  
**Issue:** Multiple RLS policies are re-evaluating `auth.uid()` for each row, causing suboptimal performance.  
**Affected Tables:**
- `profiles` - "Users can update own profile"
- `courses` - "Admin and faculty can manage courses"
- `leads` - "Staff can view leads", "Staff can update leads"
- `enrollments` - "Students can view own enrollments", "Staff can view all enrollments", "Students can create own enrollments"

**Recommendation:** Replace `auth.uid()` with `(select auth.uid())` in RLS policies.  
**Remediation:** https://supabase.com/docs/guides/database/postgres/row-level-security#call-functions-with-select

### ⚠️ Multiple Permissive Policies
**Level:** WARN  
**Issue:** Multiple permissive RLS policies on the same table for the same role/action can impact performance.  
**Affected Tables:**
- `courses` - Multiple SELECT policies
- `enrollments` - Multiple SELECT policies
- `video_promos` - Multiple SELECT policies

**Recommendation:** Consider consolidating policies where possible.  
**Remediation:** https://supabase.com/docs/guides/database/database-linter?lint=0006_multiple_permissive_policies

### ℹ️ Unindexed Foreign Keys
**Level:** INFO  
**Issue:** Foreign keys without covering indexes can impact query performance.  
**Affected:**
- `courses.created_by` → `profiles.id`
- `leads.course_id` → `courses.id`
- `video_promos.course_id` → `courses.id`

**Recommendation:** Add indexes on foreign key columns if frequently queried.  
**Remediation:** https://supabase.com/docs/guides/database/database-linter?lint=0001_unindexed_foreign_keys

### ℹ️ Unused Indexes
**Level:** INFO  
**Issue:** Several indexes have not been used and may be candidates for removal.  
**Note:** These may become useful as the application scales and query patterns evolve. Consider monitoring before removal.

## Action Items

1. **High Priority:**
   - Enable leaked password protection in Supabase Auth settings
   - Optimize RLS policies by using `(select auth.uid())` instead of `auth.uid()`

2. **Medium Priority:**
   - Review and consolidate multiple permissive policies where possible
   - Add indexes on foreign keys if they're frequently used in queries

3. **Low Priority:**
   - Monitor unused indexes - they may become useful as the app scales

