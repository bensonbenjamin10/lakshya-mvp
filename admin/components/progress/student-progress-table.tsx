'use client'

import { useList } from '@refinedev/core'
import { Card, CardContent } from '@/components/ui/card'
import { createClient } from '@/lib/supabase/client'
import { useEffect, useState } from 'react'
import { CardSkeleton } from '@/components/ui/card-skeleton'
import { EmptyState } from '@/components/ui/empty-state'

export function StudentProgressTable() {
  const [enrollments, setEnrollments] = useState<Record<string, any>>({})
  const [courses, setCourses] = useState<Record<string, string>>({})
  const [students, setStudents] = useState<Record<string, string>>({})
  const supabase = createClient()

  useEffect(() => {
    Promise.all([
      supabase.from('enrollments').select('id, course_id, student_id, progress_percentage'),
      supabase.from('courses').select('id, title'),
      supabase.from('profiles').select('id, email, full_name'),
    ]).then(([enrollmentsData, coursesData, studentsData]) => {
      if (enrollmentsData.data) {
        const enrollmentMap: Record<string, any> = {}
        enrollmentsData.data.forEach((enrollment) => {
          enrollmentMap[enrollment.id] = enrollment
        })
        setEnrollments(enrollmentMap)
      }
      if (coursesData.data) {
        const courseMap: Record<string, string> = {}
        coursesData.data.forEach((course) => {
          courseMap[course.id] = course.title
        })
        setCourses(courseMap)
      }
      if (studentsData.data) {
        const studentMap: Record<string, string> = {}
        studentsData.data.forEach((student) => {
          studentMap[student.id] = student.full_name || student.email
        })
        setStudents(studentMap)
      }
    })
  }, [])

  const listResult = useList({
    resource: 'student_progress',
    sorters: [{ field: 'created_at', order: 'desc' }],
  })

  const progress = (listResult.result?.data || []) as any[]
  const isLoading = listResult.query?.isLoading || false

  // Group progress by enrollment
  const progressByEnrollment: Record<string, any[]> = {}
  progress.forEach((p) => {
    if (!progressByEnrollment[p.enrollment_id]) {
      progressByEnrollment[p.enrollment_id] = []
    }
    progressByEnrollment[p.enrollment_id].push(p)
  })

  if (isLoading) {
    return (
      <div className="space-y-4">
        {Array.from({ length: 3 }).map((_, i) => (
          <CardSkeleton key={i} lines={4} />
        ))}
      </div>
    )
  }

  if (Object.keys(progressByEnrollment).length === 0) {
    return (
      <EmptyState
        title="No progress data found"
        description="Student progress will appear here as they complete course modules."
      />
    )
  }

  return (
    <div className="space-y-4">
      {Object.entries(progressByEnrollment).map(([enrollmentId, progressList]) => {
        const enrollment = enrollments[enrollmentId]
        if (!enrollment) return null

        const completedCount = progressList.filter((p) => p.status === 'completed').length
        const totalCount = progressList.length
        const progressPercentage = totalCount > 0 ? (completedCount / totalCount) * 100 : 0

        return (
          <Card key={enrollmentId}>
            <CardContent className="p-6">
              <div className="flex justify-between items-start mb-4">
                <div>
                  <h3 className="font-semibold text-lg">
                    {students[enrollment.student_id] || 'Unknown Student'}
                  </h3>
                  <p className="text-sm text-gray-600">
                    {courses[enrollment.course_id] || 'Unknown Course'}
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-2xl font-bold text-blue-600">
                    {progressPercentage.toFixed(0)}%
                  </p>
                  <p className="text-xs text-gray-500">
                    {completedCount} of {totalCount} modules
                  </p>
                </div>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2 mb-4">
                <div
                  className="bg-blue-600 h-2 rounded-full transition-all"
                  style={{ width: `${progressPercentage}%` }}
                />
              </div>
              <div className="grid grid-cols-3 gap-2 text-xs">
                <div className="text-center">
                  <p className="font-semibold">{completedCount}</p>
                  <p className="text-gray-500">Completed</p>
                </div>
                <div className="text-center">
                  <p className="font-semibold">
                    {progressList.filter((p) => p.status === 'in_progress').length}
                  </p>
                  <p className="text-gray-500">In Progress</p>
                </div>
                <div className="text-center">
                  <p className="font-semibold">
                    {progressList.filter((p) => p.status === 'not_started').length}
                  </p>
                  <p className="text-gray-500">Not Started</p>
                </div>
              </div>
            </CardContent>
          </Card>
        )
      })}
    </div>
  )
}

