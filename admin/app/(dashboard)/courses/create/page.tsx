'use client'

import { CourseForm } from '@/components/courses/course-form'
import { Suspense } from 'react'

export const dynamic = 'force-dynamic'
export const dynamicParams = true

export default function CreateCoursePage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Create Course</h1>
        <p className="text-gray-600 mt-1">Add a new course to the catalog</p>
      </div>
      <Suspense fallback={<div>Loading...</div>}>
        <CourseForm />
      </Suspense>
    </div>
  )
}

