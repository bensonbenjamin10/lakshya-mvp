'use client'

import { CourseBuilder } from '@/components/courses/course-builder'
import { useParams } from 'next/navigation'
import { Suspense } from 'react'

export const dynamic = 'force-dynamic'

export default function EditCoursePage() {
  const params = useParams()
  const courseId = params.id as string

  return (
    <Suspense fallback={<div className="flex items-center justify-center min-h-screen">Loading...</div>}>
      <CourseBuilder courseId={courseId} />
    </Suspense>
  )
}
