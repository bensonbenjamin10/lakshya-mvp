-- Seed initial course data
-- This migration populates the courses table with initial course data

insert into public.courses (
  id,
  slug,
  title,
  description,
  category,
  duration,
  level,
  highlights,
  image_url,
  is_popular,
  is_active
) values
(
  gen_random_uuid(),
  'acca-001',
  'ACCA (Association of Chartered Certified Accountants)',
  'Globally recognized professional accounting qualification that opens doors to a successful career in finance and accounting worldwide.',
  'acca',
  '24-36 months',
  'Professional',
  ARRAY[
    '13 papers covering accounting, finance, and business',
    'Globally recognized qualification',
    'Flexible study options',
    'Career support and guidance',
    'Access to global job opportunities'
  ],
  'assets/images/acca.jpg',
  true,
  true
),
(
  gen_random_uuid(),
  'ca-001',
  'CA (Chartered Accountancy)',
  'The premier accounting qualification in India, recognized for excellence in accounting, auditing, taxation, and financial management.',
  'ca',
  '3-5 years',
  'Professional',
  ARRAY[
    'Three levels: Foundation, Intermediate, Final',
    'Articleship training program',
    'Highly respected in India and abroad',
    'Strong career prospects',
    'Comprehensive curriculum'
  ],
  'assets/images/ca.jpg',
  true,
  true
),
(
  gen_random_uuid(),
  'cma-001',
  'CMA (US) - Certified Management Accountant',
  'The leading management accounting certification in the United States, focusing on financial planning, analysis, control, and decision support.',
  'cma',
  '12-18 months',
  'Professional',
  ARRAY[
    'Two-part examination',
    'Focus on management accounting',
    'US-based certification',
    'High earning potential',
    'Global recognition'
  ],
  'assets/images/cma.jpg',
  false,
  true
),
(
  gen_random_uuid(),
  'bcom-mba-001',
  'Integrated B.Com & MBA',
  'A comprehensive dual-degree program combining undergraduate commerce education with advanced business management skills.',
  'bcom_mba',
  '5 years',
  'Graduate',
  ARRAY[
    'Dual degree program',
    'Industry-integrated curriculum',
    'Internship opportunities',
    'Placement assistance',
    'Holistic business education'
  ],
  'assets/images/bcom-mba.jpg',
  false,
  true
);

