// Types for Course Builder

export interface CourseSection {
  id: string
  course_id: string
  title: string
  description?: string
  display_order: number
  is_expanded?: boolean
  created_at?: string
  updated_at?: string
}

export interface CourseModule {
  id: string
  course_id: string
  section_id?: string | null
  module_number: number
  title: string
  description?: string
  type: 'video' | 'reading' | 'assignment' | 'quiz' | 'live_session'
  content_url?: string
  content_body?: string
  content_type?: 'url' | 'markdown'
  duration_minutes?: number
  is_required: boolean
  is_free_preview?: boolean
  unlock_date?: string
  display_order: number
  created_at?: string
  updated_at?: string
}

export interface Course {
  id?: string
  slug: string
  title: string
  description?: string
  category: 'acca' | 'ca' | 'cma' | 'bcom_mba'
  duration?: string
  level?: string
  highlights?: string[]
  image_url?: string
  brochure_url?: string
  is_popular?: boolean
  is_active?: boolean
  is_free?: boolean
  price?: number
  sale_price?: number | null
  currency?: string
  free_trial_days?: number
  created_at?: string
  updated_at?: string
}

export interface CurriculumData {
  sections: CourseSection[]
  modules: CourseModule[]
}

// Module type configuration
export const MODULE_TYPES = {
  video: {
    label: 'Video',
    icon: 'Video',
    color: 'bg-blue-100 text-blue-800',
  },
  reading: {
    label: 'Reading',
    icon: 'BookOpen',
    color: 'bg-green-100 text-green-800',
  },
  assignment: {
    label: 'Assignment',
    icon: 'FileText',
    color: 'bg-yellow-100 text-yellow-800',
  },
  quiz: {
    label: 'Quiz',
    icon: 'HelpCircle',
    color: 'bg-purple-100 text-purple-800',
  },
  live_session: {
    label: 'Live Session',
    icon: 'Radio',
    color: 'bg-indigo-100 text-indigo-800',
  },
} as const

export type ModuleType = keyof typeof MODULE_TYPES

