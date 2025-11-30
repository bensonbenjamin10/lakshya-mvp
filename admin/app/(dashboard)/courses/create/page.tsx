'use client'

import { CourseBuilder } from '@/components/courses/course-builder'
import { Suspense } from 'react'

export const dynamic = 'force-dynamic'
export const dynamicParams = true

export default function CreateCoursePage() {
  return (
    <Suspense fallback={<div className="flex items-center justify-center min-h-screen">Loading...</div>}>
      <CourseBuilder />
    </Suspense>
  )
}
