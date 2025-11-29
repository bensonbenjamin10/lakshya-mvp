'use client'

import { useParams } from 'next/navigation'
import { useOne } from '@refinedev/core'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { createClient } from '@/lib/supabase/client'
import { useEffect, useState } from 'react'
import { useToast } from '@/lib/hooks/use-toast'

export default function EnrollmentDetailPage() {
  const params = useParams()
  const enrollmentId = params.id as string
  const supabase = createClient()
  const toast = useToast()

  const { result, query } = useOne({
    resource: 'enrollments',
    id: enrollmentId,
  })

  const [course, setCourse] = useState<any>(null)
  const [student, setStudent] = useState<any>(null)
  const [progress, setProgress] = useState<any[]>([])

  const enrollment = result?.data as any
  const isLoading = query?.isLoading || false

  useEffect(() => {
    if (enrollment) {
      // Load course
      supabase
        .from('courses')
        .select('*')
        .eq('id', enrollment.course_id)
        .single()
        .then(({ data }) => setCourse(data))

      // Load student
      supabase
        .from('profiles')
        .select('*')
        .eq('id', enrollment.student_id)
        .single()
        .then(({ data }) => setStudent(data))

      // Load progress
      supabase
        .from('student_progress')
        .select('*, course_modules(*)')
        .eq('enrollment_id', enrollment.id)
        .then(({ data }) => setProgress(data || []))
    }
  }, [enrollment])

  const updateStatus = async (newStatus: string) => {
    try {
      const { error } = await (supabase as any)
        .from('enrollments')
        .update({ status: newStatus })
        .eq('id', enrollmentId)
      
      if (error) throw error
      
      toast.success(`Enrollment status updated to ${newStatus}`)
      window.location.reload()
    } catch (error: any) {
      toast.error(error?.message || 'Failed to update enrollment status')
    }
  }

  if (isLoading) {
    return <div className="p-4">Loading...</div>
  }

  if (!enrollment) {
    return <div className="p-4">Enrollment not found</div>
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Enrollment Details</h1>
          <p className="text-gray-600 mt-1">View and manage enrollment</p>
        </div>
        <Button onClick={() => window.history.back()}>Back</Button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Student Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-2">
            <div>
              <span className="text-sm text-gray-500">Name:</span>
              <p className="font-medium">{student?.full_name || 'N/A'}</p>
            </div>
            <div>
              <span className="text-sm text-gray-500">Email:</span>
              <p className="font-medium">{student?.email || 'N/A'}</p>
            </div>
            <div>
              <span className="text-sm text-gray-500">Phone:</span>
              <p className="font-medium">{student?.phone || 'N/A'}</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Course Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-2">
            <div>
              <span className="text-sm text-gray-500">Course:</span>
              <p className="font-medium">{course?.title || 'Loading...'}</p>
            </div>
            <div>
              <span className="text-sm text-gray-500">Category:</span>
              <p className="font-medium">
                {course?.category?.replace('_', ' ').toUpperCase() || 'N/A'}
              </p>
            </div>
            <div>
              <span className="text-sm text-gray-500">Duration:</span>
              <p className="font-medium">{course?.duration || 'N/A'}</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Enrollment Status</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <span className="text-sm text-gray-500">Status:</span>
              <p className="font-medium capitalize">{enrollment.status || 'pending'}</p>
            </div>
            <div>
              <span className="text-sm text-gray-500">Payment Status:</span>
              <p className="font-medium capitalize">
                {enrollment.payment_status?.replace('_', ' ') || 'pending'}
              </p>
            </div>
            <div>
              <span className="text-sm text-gray-500">Progress:</span>
              <p className="font-medium">
                {enrollment.progress_percentage
                  ? `${parseFloat(enrollment.progress_percentage).toFixed(0)}%`
                  : '0%'}
              </p>
            </div>
            <div>
              <span className="text-sm text-gray-500">Enrolled:</span>
              <p className="font-medium">
                {enrollment.enrolled_at
                  ? new Date(enrollment.enrolled_at).toLocaleString()
                  : 'N/A'}
              </p>
            </div>
            <div className="pt-4 border-t">
              <p className="text-sm font-medium mb-2">Update Status:</p>
              <div className="flex flex-wrap gap-2">
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => updateStatus('active')}
                >
                  Activate
                </Button>
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => updateStatus('completed')}
                >
                  Complete
                </Button>
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => updateStatus('dropped')}
                >
                  Drop
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Module Progress</CardTitle>
          </CardHeader>
          <CardContent>
            {progress.length === 0 ? (
              <p className="text-sm text-gray-500">No progress recorded yet</p>
            ) : (
              <div className="space-y-2">
                {progress.map((p: any) => (
                  <div
                    key={p.id}
                    className="flex justify-between items-center p-2 bg-gray-50 rounded"
                  >
                    <span className="text-sm">
                      {p.course_modules?.title || 'Unknown Module'}
                    </span>
                    <span
                      className={`text-xs px-2 py-1 rounded ${
                        p.status === 'completed'
                          ? 'bg-green-100 text-green-800'
                          : p.status === 'in_progress'
                            ? 'bg-yellow-100 text-yellow-800'
                            : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {p.status?.replace('_', ' ').toUpperCase()}
                    </span>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

