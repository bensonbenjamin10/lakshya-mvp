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
import { Badge } from '@/components/ui/badge'
import { Download, ArrowUpDown, ArrowUp, ArrowDown, Filter } from 'lucide-react'
import { useToast } from '@/lib/hooks/use-toast'
import { Database } from '@/lib/types/database.types'

type Payment = Database['public']['Tables']['payments']['Row']
type SortField = 'amount' | 'payment_status' | 'created_at' | 'payment_provider' | null
type SortOrder = 'asc' | 'desc'

export function PaymentsTable() {
  const toast = useToast()
  const [courses, setCourses] = useState<Record<string, string>>({})
  const [students, setStudents] = useState<Record<string, string>>({})
  const [searchQuery, setSearchQuery] = useState('')
  const [sortField, setSortField] = useState<SortField>('created_at')
  const [sortOrder, setSortOrder] = useState<SortOrder>('desc')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [providerFilter, setProviderFilter] = useState<string>('all')
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
    resource: 'payments',
    pagination: {
      mode: 'off',
    },
  })

  const payments = (listResult.result?.data as Payment[]) || []
  const isLoading = listResult.query?.isLoading || false

  const filteredAndSortedPayments = useMemo(() => {
    let filtered = payments

    // Search filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter((payment) => {
        const studentName = students[payment.student_id]?.toLowerCase() || ''
        const courseName = courses[payment.course_id]?.toLowerCase() || ''
        const transactionId = payment.transaction_id?.toLowerCase() || ''
        const amount = payment.amount.toString()
        return (
          studentName.includes(query) ||
          courseName.includes(query) ||
          transactionId.includes(query) ||
          amount.includes(query)
        )
      })
    }

    // Status filter
    if (statusFilter !== 'all') {
      filtered = filtered.filter((payment) => payment.payment_status === statusFilter)
    }

    // Provider filter
    if (providerFilter !== 'all') {
      filtered = filtered.filter((payment) => payment.payment_provider === providerFilter)
    }

    // Sort
    if (sortField) {
      filtered = [...filtered].sort((a, b) => {
        let aValue: any = a[sortField as keyof Payment]
        let bValue: any = b[sortField as keyof Payment]

        if (sortField === 'amount') {
          aValue = Number(aValue) || 0
          bValue = Number(bValue) || 0
        } else if (sortField === 'created_at') {
          aValue = new Date(aValue || 0).getTime()
          bValue = new Date(bValue || 0).getTime()
        } else {
          aValue = String(aValue || '').toLowerCase()
          bValue = String(bValue || '').toLowerCase()
        }

        if (sortOrder === 'asc') {
          return aValue > bValue ? 1 : -1
        } else {
          return aValue < bValue ? 1 : -1
        }
      })
    }

    return filtered
  }, [payments, searchQuery, statusFilter, providerFilter, sortField, sortOrder, courses, students])

  const handleSort = (field: SortField) => {
    if (sortField === field) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')
    } else {
      setSortField(field)
      setSortOrder('desc')
    }
  }

  const SortIcon = ({ field }: { field: SortField }) => {
    if (sortField !== field) return <ArrowUpDown className="ml-1 h-3 w-3 opacity-50" />
    return sortOrder === 'asc' ? (
      <ArrowUp className="ml-1 h-3 w-3" />
    ) : (
      <ArrowDown className="ml-1 h-3 w-3" />
    )
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

  const getProviderColor = (provider: string) => {
    switch (provider) {
      case 'razorpay':
        return 'bg-indigo-100 text-indigo-800'
      case 'revenuecat':
        return 'bg-pink-100 text-pink-800'
      case 'manual':
        return 'bg-gray-100 text-gray-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const handleExport = async (format: 'csv' | 'excel') => {
    try {
      const exportData = filteredAndSortedPayments.map((payment) => ({
        'Transaction ID': payment.transaction_id || 'N/A',
        'Student': students[payment.student_id] || 'Unknown',
        'Course': courses[payment.course_id] || 'Unknown',
        'Amount': payment.amount,
        'Currency': payment.currency || 'INR',
        'Status': payment.payment_status,
        'Provider': payment.payment_provider,
        'Payment Method': payment.payment_method || 'N/A',
        'Payment Plan': payment.payment_plan || 'N/A',
        'Created At': payment.created_at ? new Date(payment.created_at).toLocaleString() : 'N/A',
        'Completed At': payment.completed_at ? new Date(payment.completed_at).toLocaleString() : 'N/A',
      }))

      if (format === 'csv') {
        const { exportToCSV } = await import('@/lib/utils/export')
        exportToCSV(exportData, 'payments')
        toast.success('Payments exported to CSV')
      } else {
        const { exportToExcel } = await import('@/lib/utils/export')
        await exportToExcel(exportData, 'payments')
        toast.success('Payments exported to Excel')
      }
    } catch (error) {
      toast.error('Failed to export payments')
    }
  }

  const totalRevenue = useMemo(() => {
    return filteredAndSortedPayments
      .filter((p) => p.payment_status === 'completed')
      .reduce((sum, p) => sum + Number(p.amount || 0), 0)
  }, [filteredAndSortedPayments])

  if (isLoading) {
    return <TableSkeleton />
  }

  return (
    <div className="space-y-4">
      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-gray-600">Total Payments</div>
            <div className="text-2xl font-bold">{filteredAndSortedPayments.length}</div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-gray-600">Total Revenue</div>
            <div className="text-2xl font-bold text-green-600">
              {totalRevenue.toLocaleString('en-IN', {
                style: 'currency',
                currency: 'INR',
                maximumFractionDigits: 0,
              })}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-gray-600">Completed</div>
            <div className="text-2xl font-bold text-green-600">
              {filteredAndSortedPayments.filter((p) => p.payment_status === 'completed').length}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-gray-600">Pending</div>
            <div className="text-2xl font-bold text-yellow-600">
              {filteredAndSortedPayments.filter((p) => p.payment_status === 'pending').length}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Filters and Search */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col md:flex-row gap-4 mb-4">
            <div className="flex-1">
              <SearchInput
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search by student, course, transaction ID..."
              />
            </div>
            <div className="flex gap-2">
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="rounded-md border border-gray-300 px-3 py-2 text-sm"
              >
                <option value="all">All Status</option>
                <option value="pending">Pending</option>
                <option value="processing">Processing</option>
                <option value="completed">Completed</option>
                <option value="failed">Failed</option>
                <option value="refunded">Refunded</option>
                <option value="cancelled">Cancelled</option>
              </select>
              <select
                value={providerFilter}
                onChange={(e) => setProviderFilter(e.target.value)}
                className="rounded-md border border-gray-300 px-3 py-2 text-sm"
              >
                <option value="all">All Providers</option>
                <option value="razorpay">Razorpay</option>
                <option value="revenuecat">RevenueCat</option>
                <option value="manual">Manual</option>
              </select>
              <div className="flex gap-2">
                <Button variant="outline" size="sm" onClick={() => handleExport('csv')}>
                  <Download className="h-4 w-4 mr-1" />
                  CSV
                </Button>
                <Button variant="outline" size="sm" onClick={() => handleExport('excel')}>
                  <Download className="h-4 w-4 mr-1" />
                  Excel
                </Button>
              </div>
            </div>
          </div>

          {filteredAndSortedPayments.length === 0 ? (
            <EmptyState
              title="No payments found"
              description="No payments match your search criteria."
            />
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                      onClick={() => handleSort('created_at')}
                    >
                      Date
                      <SortIcon field="created_at" />
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Transaction ID
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Student
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Course
                    </th>
                    <th
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                      onClick={() => handleSort('amount')}
                    >
                      Amount
                      <SortIcon field="amount" />
                    </th>
                    <th
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                      onClick={() => handleSort('payment_status')}
                    >
                      Status
                      <SortIcon field="payment_status" />
                    </th>
                    <th
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                      onClick={() => handleSort('payment_provider')}
                    >
                      Provider
                      <SortIcon field="payment_provider" />
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredAndSortedPayments.map((payment) => (
                    <tr key={payment.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {payment.created_at
                          ? new Date(payment.created_at).toLocaleDateString()
                          : 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {payment.transaction_id || 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {students[payment.student_id] || 'Unknown'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {courses[payment.course_id] || 'Unknown'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {Number(payment.amount || 0).toLocaleString('en-IN', {
                          style: 'currency',
                          currency: payment.currency || 'INR',
                          maximumFractionDigits: 0,
                        })}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <Badge className={getStatusColor(payment.payment_status)}>
                          {payment.payment_status.replace('_', ' ').toUpperCase()}
                        </Badge>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <Badge className={getProviderColor(payment.payment_provider)}>
                          {payment.payment_provider.toUpperCase()}
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
          )}
        </CardContent>
      </Card>
    </div>
  )
}

