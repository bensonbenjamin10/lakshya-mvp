'use client'

import { CourseForm } from '@/components/courses/course-form'
import { useParams } from 'next/navigation'

export default function EditCoursePage() {
  const params = useParams()
  const courseId = params.id as string

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Edit Course</h1>
        <p className="text-gray-600 mt-1">Update course information</p>
      </div>
      <CourseForm courseId={courseId} />
    </div>
  )
}

