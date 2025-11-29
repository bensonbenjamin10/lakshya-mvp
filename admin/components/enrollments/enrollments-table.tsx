'use client'

import { useList } from '@refinedev/core'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { createClient } from '@/lib/supabase/client'
import { useEffect, useState, useMemo } from 'react'
import { TableSkeleton } from '@/components/ui/table-skeleton'
import { EmptyState } from '@/components/ui/empty-state'
import { SearchInput } from '@/components/ui/search-input'
import { exportToCSV, exportToExcel } from '@/lib/utils/export'
import { Download, ArrowUpDown, ArrowUp, ArrowDown } from 'lucide-react'
import { useToast } from '@/lib/hooks/use-toast'

type SortField = 'status' | 'payment_status' | 'progress_percentage' | 'enrolled_at' | null
type SortOrder = 'asc' | 'desc'

export function EnrollmentsTable() {
  const toast = useToast()
  const [courses, setCourses] = useState<Record<string, string>>({})
  const [students, setStudents] = useState<Record<string, string>>({})
  const [searchQuery, setSearchQuery] = useState('')
  const [sortField, setSortField] = useState<SortField>('enrolled_at')
  const [sortOrder, setSortOrder] = useState<SortOrder>('desc')
  const supabase = createClient()

  useEffect(() => {
    Promise.all([
      supabase.from('courses').select('id, title'),
      supabase.from('profiles').select('id, email, full_name'),
    ]).then(([coursesData, studentsData]) => {
      if (coursesData.data) {
        const courseMap: Record<string, string> = {}
        coursesData.data?.forEach((course: any) => {
          courseMap[course.id] = course.title
        })
        setCourses(courseMap)
      }
      if (studentsData.data) {
        const studentMap: Record<string, string> = {}
        studentsData.data.forEach((student: any) => {
          studentMap[student.id] = student.full_name || student.email
        })
        setStudents(studentMap)
      }
    })
  }, [])

  const listResult = useList({
    resource: 'enrollments',
    sorters: [{ field: 'enrolled_at', order: 'desc' }],
  })

  const allEnrollments = (listResult.result?.data || []) as any[]
  const isLoading = listResult.query?.isLoading || false

  const enrollments = useMemo(() => {
    let filtered = allEnrollments

    // Apply search filter
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter(
        (enrollment) =>
          students[enrollment.student_id]?.toLowerCase().includes(query) ||
          courses[enrollment.course_id]?.toLowerCase().includes(query) ||
          enrollment.status?.toLowerCase().includes(query) ||
          enrollment.payment_status?.toLowerCase().includes(query)
      )
    }

    // Apply client-side sorting
    if (sortField) {
      filtered = [...filtered].sort((a, b) => {
        let aVal = a[sortField]
        let bVal = b[sortField]

        if (sortField === 'enrolled_at') {
          aVal = new Date(aVal || 0).getTime()
          bVal = new Date(bVal || 0).getTime()
        } else if (sortField === 'progress_percentage') {
          aVal = parseFloat(aVal || '0')
          bVal = parseFloat(bVal || '0')
        } else {
          aVal = String(aVal || '').toLowerCase()
          bVal = String(bVal || '').toLowerCase()
        }

        if (sortOrder === 'asc') {
          return aVal > bVal ? 1 : aVal < bVal ? -1 : 0
        } else {
          return aVal < bVal ? 1 : aVal > bVal ? -1 : 0
        }
      })
    }

    return filtered
  }, [allEnrollments, searchQuery, students, courses, sortField, sortOrder])

  const handleSort = (field: SortField) => {
    if (sortField === field) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')
    } else {
      setSortField(field)
      setSortOrder('asc')
    }
  }

  const SortIcon = ({ field }: { field: SortField }) => {
    if (sortField !== field) {
      return <ArrowUpDown className="h-4 w-4 ml-1 text-gray-400" />
    }
    return sortOrder === 'asc' ? (
      <ArrowUp className="h-4 w-4 ml-1 text-blue-600" />
    ) : (
      <ArrowDown className="h-4 w-4 ml-1 text-blue-600" />
    )
  }

  const handleExport = async (format: 'csv' | 'excel') => {
    try {
      const exportData = enrollments.map((enrollment) => ({
        Student: students[enrollment.student_id] || 'Unknown',
        Course: courses[enrollment.course_id] || 'Unknown',
        Status: enrollment.status || 'pending',
        'Payment Status': enrollment.payment_status || 'pending',
        Progress: enrollment.progress_percentage
          ? `${parseFloat(enrollment.progress_percentage).toFixed(0)}%`
          : '0%',
        'Enrolled At': enrollment.enrolled_at
          ? new Date(enrollment.enrolled_at).toLocaleDateString()
          : 'N/A',
      }))

      if (format === 'csv') {
        exportToCSV(exportData, 'enrollments')
        toast.success('Enrollments exported to CSV')
      } else {
        await exportToExcel(exportData, 'enrollments', 'Enrollments')
        toast.success('Enrollments exported to Excel')
      }
    } catch (error: any) {
      toast.error(error?.message || 'Failed to export enrollments')
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

  const getPaymentStatusColor = (status: string) => {
    switch (status) {
      case 'paid':
        return 'bg-green-100 text-green-800'
      case 'partial':
        return 'bg-yellow-100 text-yellow-800'
      case 'pending':
        return 'bg-orange-100 text-orange-800'
      case 'not_required':
        return 'bg-gray-100 text-gray-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  if (isLoading) {
    return <TableSkeleton rows={5} columns={7} />
  }

  if (enrollments.length === 0) {
    return (
      <EmptyState
        title="No enrollments found"
        description="Student enrollments will appear here once they enroll in courses."
      />
    )
  }

  return (
    <Card>
      <CardContent className="p-4">
        <div className="mb-4 flex items-center justify-between gap-4">
          <SearchInput
            placeholder="Search enrollments by student, course, or status..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="max-w-md"
          />
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => handleExport('csv')}
              disabled={enrollments.length === 0}
            >
              <Download className="h-4 w-4 mr-2" />
              Export CSV
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => handleExport('excel')}
              disabled={enrollments.length === 0}
            >
              <Download className="h-4 w-4 mr-2" />
              Export Excel
            </Button>
          </div>
        </div>
      </CardContent>
      <CardContent className="p-0">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Student
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Course
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <button
                    onClick={() => handleSort('status')}
                    className="flex items-center hover:text-gray-700"
                  >
                    Status
                    <SortIcon field="status" />
                  </button>
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <button
                    onClick={() => handleSort('payment_status')}
                    className="flex items-center hover:text-gray-700"
                  >
                    Payment Status
                    <SortIcon field="payment_status" />
                  </button>
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <button
                    onClick={() => handleSort('progress_percentage')}
                    className="flex items-center hover:text-gray-700"
                  >
                    Progress
                    <SortIcon field="progress_percentage" />
                  </button>
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <button
                    onClick={() => handleSort('enrolled_at')}
                    className="flex items-center hover:text-gray-700"
                  >
                    Enrolled
                    <SortIcon field="enrolled_at" />
                  </button>
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {enrollments.map((enrollment: any) => (
                <tr key={enrollment.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {students[enrollment.student_id] || 'Unknown'}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-900">
                    {courses[enrollment.course_id] || 'Unknown Course'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(
                        enrollment.status || 'pending'
                      )}`}
                    >
                      {(enrollment.status || 'pending').toUpperCase()}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPaymentStatusColor(
                        enrollment.payment_status || 'pending'
                      )}`}
                    >
                      {(enrollment.payment_status || 'pending').replace('_', ' ').toUpperCase()}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {enrollment.progress_percentage
                      ? `${parseFloat(enrollment.progress_percentage).toFixed(0)}%`
                      : '0%'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {enrollment.enrolled_at
                      ? new Date(enrollment.enrolled_at).toLocaleDateString()
                      : 'N/A'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <Link href={`/enrollments/${enrollment.id}`}>
                      <Button variant="ghost" size="sm">
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
  )
}

