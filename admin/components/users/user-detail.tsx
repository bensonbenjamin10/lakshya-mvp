'use client'

import { useOne } from '@refinedev/core'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { createClient } from '@/lib/supabase/client'
import { useState, useEffect } from 'react'
import { useToast } from '@/lib/hooks/use-toast'
import { Database } from '@/lib/types/database.types'
import { ArrowLeft, UserCheck, UserX, Mail, Phone, MapPin, Calendar } from 'lucide-react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'

type Profile = Database['public']['Tables']['profiles']['Row']
type Enrollment = Database['public']['Tables']['enrollments']['Row']
type Payment = Database['public']['Tables']['payments']['Row']
type Course = Database['public']['Tables']['courses']['Row']
type StudentProgress = Database['public']['Tables']['student_progress']['Row']

interface UserDetailProps {
  userId: string
}

export function UserDetail({ userId }: UserDetailProps) {
  const toast = useToast()
  const router = useRouter()
  const supabase = createClient()
  const [enrollments, setEnrollments] = useState<Enrollment[]>([])
  const [payments, setPayments] = useState<Payment[]>([])
  const [courses, setCourses] = useState<Record<string, Course>>({})
  const [progress, setProgress] = useState<StudentProgress[]>([])
  const [isUpdating, setIsUpdating] = useState(false)

  const { result, query } = useOne({
    resource: 'profiles',
    id: userId,
  })

  const user = result?.data as Profile | undefined
  const isLoading = query?.isLoading || false

  useEffect(() => {
    if (user) {
      Promise.all([
        supabase
          .from('enrollments')
          .select('*')
          .eq('student_id', user.id)
          .order('enrolled_at', { ascending: false }),
        supabase
          .from('payments')
          .select('*')
          .eq('student_id', user.id)
          .order('created_at', { ascending: false }),
        supabase.from('courses').select('*'),
        supabase
          .from('student_progress')
          .select('*')
          .eq('student_id', user.id),
      ]).then(([enrollmentsData, paymentsData, coursesData, progressData]) => {
        if (enrollmentsData.data) setEnrollments(enrollmentsData.data as Enrollment[])
        if (paymentsData.data) setPayments(paymentsData.data as Payment[])
        if (coursesData.data) {
          const courseMap: Record<string, Course> = {}
          coursesData.data.forEach((course: any) => {
            courseMap[course.id] = course as Course
          })
          setCourses(courseMap)
        }
        if (progressData.data) setProgress(progressData.data as StudentProgress[])
      })
    }
  }, [user, supabase])

  const handleRoleChange = async (newRole: string) => {
    if (!user) return

    if (
      !confirm(
        `Are you sure you want to change ${user.full_name || user.email}'s role to ${newRole}?`
      )
    ) {
      return
    }

    setIsUpdating(true)
    try {
      const updateData = {
        role: newRole,
        updated_at: new Date().toISOString(),
      }
      const { error } = await (supabase
        .from('profiles') as any)
        .update(updateData)
        .eq('id', user.id)

      if (error) throw error

      toast.success(`User role updated to ${newRole}`)
      window.location.reload()
    } catch (error: any) {
      toast.error(error?.message || 'Failed to update user role')
    } finally {
      setIsUpdating(false)
    }
  }

  const getRoleColor = (role: string) => {
    switch (role) {
      case 'admin':
        return 'bg-red-100 text-red-800'
      case 'faculty':
        return 'bg-blue-100 text-blue-800'
      case 'student':
        return 'bg-green-100 text-green-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'bg-green-100 text-green-800'
      case 'completed':
        return 'bg-blue-100 text-blue-800'
      case 'pending':
        return 'bg-yellow-100 text-yellow-800'
      case 'dropped':
        return 'bg-red-100 text-red-800'
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

  if (!user) {
    return (
      <Card>
        <CardContent className="pt-6">
          <div className="text-center py-8">
            <p className="text-gray-500">User not found</p>
            <Button variant="outline" onClick={() => router.push('/users')} className="mt-4">
              <ArrowLeft className="h-4 w-4 mr-2" />
              Back to Users
            </Button>
          </div>
        </CardContent>
      </Card>
    )
  }

  const totalRevenue = payments
    .filter((p) => p.payment_status === 'completed')
    .reduce((sum, p) => sum + Number(p.amount || 0), 0)

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <Button variant="outline" onClick={() => router.push('/users')}>
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back to Users
        </Button>
        {user.role !== 'admin' && (
          <div className="flex gap-2">
            {user.role !== 'admin' && (
              <Button
                variant="outline"
                onClick={() => handleRoleChange('admin')}
                disabled={isUpdating}
                className="text-red-600"
              >
                <UserCheck className="h-4 w-4 mr-2" />
                Make Admin
              </Button>
            )}
            {user.role !== 'faculty' && (
              <Button
                variant="outline"
                onClick={() => handleRoleChange('faculty')}
                disabled={isUpdating}
              >
                <UserCheck className="h-4 w-4 mr-2" />
                Make Faculty
              </Button>
            )}
            {user.role !== 'student' && (
              <Button
                variant="outline"
                onClick={() => handleRoleChange('student')}
                disabled={isUpdating}
              >
                <UserX className="h-4 w-4 mr-2" />
                Make Student
              </Button>
            )}
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* User Information */}
        <Card>
          <CardHeader>
            <CardTitle>User Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center gap-4">
              {user.avatar_url ? (
                <img
                  className="h-20 w-20 rounded-full"
                  src={user.avatar_url}
                  alt={user.full_name || 'User'}
                />
              ) : (
                <div className="h-20 w-20 rounded-full bg-gray-300 flex items-center justify-center">
                  <span className="text-gray-600 font-medium text-2xl">
                    {(user.full_name || user.email || 'U')[0].toUpperCase()}
                  </span>
                </div>
              )}
              <div>
                <h2 className="text-2xl font-bold">{user.full_name || 'No name'}</h2>
                <Badge className={getRoleColor(user.role)}>{user.role.toUpperCase()}</Badge>
              </div>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500 flex items-center gap-2">
                <Mail className="h-4 w-4" />
                Email
              </label>
              <p className="text-lg">{user.email}</p>
            </div>
            {user.phone && (
              <div>
                <label className="text-sm font-medium text-gray-500 flex items-center gap-2">
                  <Phone className="h-4 w-4" />
                  Phone
                </label>
                <p className="text-lg">{user.phone}</p>
              </div>
            )}
            {user.country && (
              <div>
                <label className="text-sm font-medium text-gray-500 flex items-center gap-2">
                  <MapPin className="h-4 w-4" />
                  Country
                </label>
                <p className="text-lg">{user.country}</p>
              </div>
            )}
            <div>
              <label className="text-sm font-medium text-gray-500 flex items-center gap-2">
                <Calendar className="h-4 w-4" />
                Member Since
              </label>
              <p className="text-lg">
                {user.created_at ? new Date(user.created_at).toLocaleDateString() : 'N/A'}
              </p>
            </div>
          </CardContent>
        </Card>

        {/* Statistics */}
        <Card>
          <CardHeader>
            <CardTitle>Statistics</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <label className="text-sm font-medium text-gray-500">Total Enrollments</label>
              <p className="text-2xl font-bold">{enrollments.length}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Active Enrollments</label>
              <p className="text-2xl font-bold text-green-600">
                {enrollments.filter((e) => e.status === 'active').length}
              </p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Total Payments</label>
              <p className="text-2xl font-bold">{payments.length}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Total Revenue</label>
              <p className="text-2xl font-bold text-green-600">
                {totalRevenue.toLocaleString('en-IN', {
                  style: 'currency',
                  currency: 'INR',
                  maximumFractionDigits: 0,
                })}
              </p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Modules Completed</label>
              <p className="text-2xl font-bold">
                {progress.filter((p) => p.status === 'completed').length}
              </p>
            </div>
          </CardContent>
        </Card>

        {/* Enrollments */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Enrollments</CardTitle>
          </CardHeader>
          <CardContent>
            {enrollments.length === 0 ? (
              <p className="text-gray-500">No enrollments found</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Course
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Status
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Progress
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Enrolled At
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Actions
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {enrollments.map((enrollment) => (
                      <tr key={enrollment.id}>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                          {courses[enrollment.course_id]?.title || 'Unknown Course'}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <Badge className={getStatusColor(enrollment.status || 'pending')}>
                            {(enrollment.status || 'pending').toUpperCase()}
                          </Badge>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm">
                          {enrollment.progress_percentage?.toFixed(1) || 0}%
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {enrollment.enrolled_at
                            ? new Date(enrollment.enrolled_at).toLocaleDateString()
                            : 'N/A'}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                          <Link href={`/enrollments/${enrollment.id}`}>
                            <Button variant="outline" size="sm">
                              View
                            </Button>
                          </Link>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Recent Payments */}
        {payments.length > 0 && (
          <Card className="lg:col-span-2">
            <CardHeader>
              <CardTitle>Recent Payments</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Date
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Course
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Amount
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Status
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Actions
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {payments.slice(0, 10).map((payment) => (
                      <tr key={payment.id}>
                        <td className="px-6 py-4 whitespace-nowrap text-sm">
                          {payment.created_at
                            ? new Date(payment.created_at).toLocaleDateString()
                            : 'N/A'}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm">
                          {courses[payment.course_id]?.title || 'Unknown Course'}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                          {Number(payment.amount || 0).toLocaleString('en-IN', {
                            style: 'currency',
                            currency: payment.currency || 'INR',
                          })}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <Badge
                            className={
                              payment.payment_status === 'completed'
                                ? 'bg-green-100 text-green-800'
                                : 'bg-yellow-100 text-yellow-800'
                            }
                          >
                            {payment.payment_status.toUpperCase()}
                          </Badge>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                          <Link href={`/payments/${payment.id}`}>
                            <Button variant="outline" size="sm">
                              View
                            </Button>
                          </Link>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  )
}

