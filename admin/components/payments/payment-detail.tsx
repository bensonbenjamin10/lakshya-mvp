'use client'

import { useOne } from '@refinedev/core'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { createClient } from '@/lib/supabase/client'
import { useState, useEffect } from 'react'
import { useToast } from '@/lib/hooks/use-toast'
import { Database } from '@/lib/types/database.types'
import { ArrowLeft, CheckCircle, XCircle, RefreshCw } from 'lucide-react'
import { useRouter } from 'next/navigation'

type Payment = Database['public']['Tables']['payments']['Row']
type Course = Database['public']['Tables']['courses']['Row']
type Profile = Database['public']['Tables']['profiles']['Row']
type Enrollment = Database['public']['Tables']['enrollments']['Row']

interface PaymentDetailProps {
  paymentId: string
}

export function PaymentDetail({ paymentId }: PaymentDetailProps) {
  const toast = useToast()
  const router = useRouter()
  const supabase = createClient()
  const [course, setCourse] = useState<Course | null>(null)
  const [student, setStudent] = useState<Profile | null>(null)
  const [enrollment, setEnrollment] = useState<Enrollment | null>(null)
  const [isUpdating, setIsUpdating] = useState(false)

  const { result, query } = useOne({
    resource: 'payments',
    id: paymentId,
  })

  const payment = result?.data as Payment | undefined
  const isLoading = query?.isLoading || false

  useEffect(() => {
    if (payment) {
      const fetchRelatedData = async () => {
        const [courseData, studentData, enrollmentData] = await Promise.all([
          supabase.from('courses').select('*').eq('id', payment.course_id).single(),
          supabase.from('profiles').select('*').eq('id', payment.student_id).single(),
          payment.enrollment_id
            ? supabase.from('enrollments').select('*').eq('id', payment.enrollment_id).single()
            : Promise.resolve({ data: null, error: null }),
        ]) as any[]
        
        if (courseData?.data && !courseData?.error) setCourse(courseData.data as Course)
        if (studentData?.data && !studentData?.error) setStudent(studentData.data as Profile)
        if (enrollmentData?.data && !enrollmentData?.error)
          setEnrollment(enrollmentData.data as Enrollment)
      }
      fetchRelatedData()
    }
  }, [payment, supabase])

  const handleStatusUpdate = async (newStatus: string) => {
    if (!payment) return

    setIsUpdating(true)
    try {
      const updateData = {
        payment_status: newStatus,
        updated_at: new Date().toISOString(),
        ...(newStatus === 'completed' && !payment.completed_at
          ? { completed_at: new Date().toISOString() }
          : {}),
      }
      const { error } = await (supabase
        .from('payments') as any)
        .update(updateData)
        .eq('id', payment.id)

      if (error) throw error

      toast.success(`Payment status updated to ${newStatus}`)
      window.location.reload()
    } catch (error: any) {
      toast.error(error?.message || 'Failed to update payment status')
    } finally {
      setIsUpdating(false)
    }
  }

  const handleRefund = async () => {
    if (!payment) return

    const refundAmount = prompt('Enter refund amount:', payment.amount.toString())
    if (!refundAmount) return

    const refundReason = prompt('Enter refund reason:')
    if (!refundReason) return

    setIsUpdating(true)
    try {
      const updateData = {
        payment_status: 'refunded',
        refund_amount: parseFloat(refundAmount),
        refund_reason: refundReason,
        updated_at: new Date().toISOString(),
      }
      const { error } = await (supabase
        .from('payments') as any)
        .update(updateData)
        .eq('id', payment.id)

      if (error) throw error

      toast.success('Refund processed successfully')
      window.location.reload()
    } catch (error: any) {
      toast.error(error?.message || 'Failed to process refund')
    } finally {
      setIsUpdating(false)
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'bg-green-100 text-green-800'
      case 'processing':
        return 'bg-blue-100 text-blue-800'
      case 'pending':
        return 'bg-yellow-100 text-yellow-800'
      case 'failed':
        return 'bg-red-100 text-red-800'
      case 'refunded':
        return 'bg-purple-100 text-purple-800'
      case 'cancelled':
        return 'bg-gray-100 text-gray-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  if (isLoading) {
    return (
      <Card>
        <CardContent className="pt-6">
          <div className="animate-pulse space-y-4">
            <div className="h-4 bg-gray-200 rounded w-3/4"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2"></div>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (!payment) {
    return (
      <Card>
        <CardContent className="pt-6">
          <div className="text-center py-8">
            <p className="text-gray-500">Payment not found</p>
            <Button variant="outline" onClick={() => router.push('/payments')} className="mt-4">
              <ArrowLeft className="h-4 w-4 mr-2" />
              Back to Payments
            </Button>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <Button variant="outline" onClick={() => router.push('/payments')}>
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back to Payments
        </Button>
        <div className="flex gap-2">
          {payment.payment_status === 'pending' && (
            <Button
              variant="outline"
              onClick={() => handleStatusUpdate('processing')}
              disabled={isUpdating}
            >
              <RefreshCw className="h-4 w-4 mr-2" />
              Mark Processing
            </Button>
          )}
          {payment.payment_status !== 'completed' && payment.payment_status !== 'refunded' && (
            <Button
              variant="outline"
              onClick={() => handleStatusUpdate('completed')}
              disabled={isUpdating}
            >
              <CheckCircle className="h-4 w-4 mr-2" />
              Mark Completed
            </Button>
          )}
          {payment.payment_status === 'completed' && (
            <Button variant="outline" onClick={handleRefund} disabled={isUpdating}>
              Process Refund
            </Button>
          )}
          {payment.payment_status !== 'failed' && (
            <Button
              variant="outline"
              onClick={() => handleStatusUpdate('failed')}
              disabled={isUpdating}
              className="text-red-600"
            >
              <XCircle className="h-4 w-4 mr-2" />
              Mark Failed
            </Button>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Payment Information */}
        <Card>
          <CardHeader>
            <CardTitle>Payment Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <label className="text-sm font-medium text-gray-500">Transaction ID</label>
              <p className="text-lg font-semibold">{payment.transaction_id || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Status</label>
              <div className="mt-1">
                <Badge className={getStatusColor(payment.payment_status)}>
                  {payment.payment_status.replace('_', ' ').toUpperCase()}
                </Badge>
              </div>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Amount</label>
              <p className="text-2xl font-bold text-green-600">
                {Number(payment.amount || 0).toLocaleString('en-IN', {
                  style: 'currency',
                  currency: payment.currency || 'INR',
                })}
              </p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Payment Provider</label>
              <p className="text-lg">{payment.payment_provider.toUpperCase()}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Payment Method</label>
              <p className="text-lg">{payment.payment_method || 'N/A'}</p>
            </div>
            {payment.payment_plan && (
              <div>
                <label className="text-sm font-medium text-gray-500">Payment Plan</label>
                <p className="text-lg">
                  {payment.payment_plan.replace('_', ' ').toUpperCase()}
                  {payment.installment_number && ` - Installment ${payment.installment_number}`}
                </p>
              </div>
            )}
            <div>
              <label className="text-sm font-medium text-gray-500">Created At</label>
              <p className="text-lg">
                {payment.created_at ? new Date(payment.created_at).toLocaleString() : 'N/A'}
              </p>
            </div>
            {payment.completed_at && (
              <div>
                <label className="text-sm font-medium text-gray-500">Completed At</label>
                <p className="text-lg">{new Date(payment.completed_at).toLocaleString()}</p>
              </div>
            )}
            {payment.refund_amount && (
              <div>
                <label className="text-sm font-medium text-gray-500">Refund Amount</label>
                <p className="text-lg text-red-600">
                  {Number(payment.refund_amount).toLocaleString('en-IN', {
                    style: 'currency',
                    currency: payment.currency || 'INR',
                  })}
                </p>
              </div>
            )}
            {payment.refund_reason && (
              <div>
                <label className="text-sm font-medium text-gray-500">Refund Reason</label>
                <p className="text-lg">{payment.refund_reason}</p>
              </div>
            )}
            {payment.failure_reason && (
              <div>
                <label className="text-sm font-medium text-gray-500">Failure Reason</label>
                <p className="text-lg text-red-600">{payment.failure_reason}</p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Student Information */}
        <Card>
          <CardHeader>
            <CardTitle>Student Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {student ? (
              <>
                <div>
                  <label className="text-sm font-medium text-gray-500">Name</label>
                  <p className="text-lg font-semibold">{student.full_name || 'N/A'}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">Email</label>
                  <p className="text-lg">{student.email}</p>
                </div>
                {student.phone && (
                  <div>
                    <label className="text-sm font-medium text-gray-500">Phone</label>
                    <p className="text-lg">{student.phone}</p>
                  </div>
                )}
              </>
            ) : (
              <p className="text-gray-500">Loading student information...</p>
            )}
          </CardContent>
        </Card>

        {/* Course Information */}
        <Card>
          <CardHeader>
            <CardTitle>Course Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {course ? (
              <>
                <div>
                  <label className="text-sm font-medium text-gray-500">Course Title</label>
                  <p className="text-lg font-semibold">{course.title}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">Category</label>
                  <p className="text-lg">{course.category.toUpperCase()}</p>
                </div>
              </>
            ) : (
              <p className="text-gray-500">Loading course information...</p>
            )}
          </CardContent>
        </Card>

        {/* Enrollment Information */}
        {enrollment && (
          <Card>
            <CardHeader>
              <CardTitle>Enrollment Information</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <label className="text-sm font-medium text-gray-500">Enrollment Status</label>
                <p className="text-lg">{enrollment.status?.toUpperCase() || 'N/A'}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Enrolled At</label>
                <p className="text-lg">
                  {enrollment.enrolled_at
                    ? new Date(enrollment.enrolled_at).toLocaleString()
                    : 'N/A'}
                </p>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Metadata */}
        {payment.metadata && (
          <Card className="lg:col-span-2">
            <CardHeader>
              <CardTitle>Additional Information</CardTitle>
            </CardHeader>
            <CardContent>
              <pre className="bg-gray-50 p-4 rounded-md overflow-auto">
                {JSON.stringify(payment.metadata, null, 2)}
              </pre>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  )
}

