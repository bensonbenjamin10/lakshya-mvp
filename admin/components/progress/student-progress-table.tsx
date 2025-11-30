'use client'

import { useList } from '@refinedev/core'
import { Card, CardContent } from '@/components/ui/card'
import { createClient } from '@/lib/supabase/client'
import { useEffect, useState, useMemo } from 'react'
import { CardSkeleton } from '@/components/ui/card-skeleton'
import { EmptyState } from '@/components/ui/empty-state'
import { SearchInput } from '@/components/ui/search-input'
import { Badge } from '@/components/ui/badge'
import { Download, ArrowUpDown, ArrowUp, ArrowDown } from 'lucide-react'
import { useToast } from '@/lib/hooks/use-toast'
import { Database } from '@/lib/types/database.types'
import Link from 'next/link'
import { Button } from '@/components/ui/button'

type Enrollment = Database['public']['Tables']['enrollments']['Row']
type Course = Database['public']['Tables']['courses']['Row']
type Profile = Database['public']['Tables']['profiles']['Row']
type StudentProgress = Database['public']['Tables']['student_progress']['Row']

type SortField = 'progress_percentage' | 'student_name' | 'course_name' | 'last_accessed' | null
type SortOrder = 'asc' | 'desc'

export function StudentProgressTable() {
  const toast = useToast()
  const [enrollments, setEnrollments] = useState<Record<string, Enrollment>>({})
  const [courses, setCourses] = useState<Record<string, Course>>({})
  const [students, setStudents] = useState<Record<string, Profile>>({})
  const [searchQuery, setSearchQuery] = useState('')
  const [sortField, setSortField] = useState<SortField>('progress_percentage')
  const [sortOrder, setSortOrder] = useState<SortOrder>('desc')
  const [courseFilter, setCourseFilter] = useState<string>('all')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [progressRangeFilter, setProgressRangeFilter] = useState<string>('all')
  const supabase = createClient()

  useEffect(() => {
    Promise.all([
      supabase.from('enrollments').select('*'),
      supabase.from('courses').select('*'),
      supabase.from('profiles').select('*'),
    ]).then(([enrollmentsData, coursesData, studentsData]) => {
      if (enrollmentsData.data) {
        const enrollmentMap: Record<string, Enrollment> = {}
        enrollmentsData.data.forEach((enrollment: any) => {
          enrollmentMap[enrollment.id] = enrollment as Enrollment
        })
        setEnrollments(enrollmentMap)
      }
      if (coursesData.data) {
        const courseMap: Record<string, Course> = {}
        coursesData.data.forEach((course: any) => {
          courseMap[course.id] = course as Course
        })
        setCourses(courseMap)
      }
      if (studentsData.data) {
        const studentMap: Record<string, Profile> = {}
        studentsData.data.forEach((student: any) => {
          studentMap[student.id] = student as Profile
        })
        setStudents(studentMap)
      }
    })
  }, [])

  const listResult = useList({
    resource: 'student_progress',
    pagination: {
      mode: 'off',
    },
  })

  const progress = (listResult.result?.data || []) as StudentProgress[]
  const isLoading = listResult.query?.isLoading || false

  // Group progress by enrollment
  const progressByEnrollment = useMemo(() => {
    const grouped: Record<string, StudentProgress[]> = {}
    progress.forEach((p) => {
      if (!grouped[p.enrollment_id]) {
        grouped[p.enrollment_id] = []
      }
      grouped[p.enrollment_id].push(p)
    })
    return grouped
  }, [progress])

  // Calculate progress metrics for each enrollment
  const enrollmentProgress = useMemo(() => {
    return Object.entries(progressByEnrollment).map(([enrollmentId, progressList]) => {
      const enrollment = enrollments[enrollmentId]
      if (!enrollment) return null

      const completedCount = progressList.filter((p) => p.status === 'completed').length
      const totalCount = progressList.length
      const progressPercentage = totalCount > 0 ? (completedCount / totalCount) * 100 : 0
      const student = students[enrollment.student_id]
      const course = courses[enrollment.course_id]

      // Calculate total time spent
      const totalTimeSpent = progressList.reduce(
        (sum, p) => sum + Number(p.time_spent_minutes || 0),
        0
      )

      // Get last accessed date
      const lastAccessedDates = progressList
        .map((p) => (p.last_accessed_at ? new Date(p.last_accessed_at).getTime() : 0))
        .filter((d) => d > 0)
      const lastAccessed = lastAccessedDates.length > 0 ? Math.max(...lastAccessedDates) : 0

      return {
        enrollmentId,
        enrollment,
        progressList,
        completedCount,
        totalCount,
        progressPercentage,
        student,
        course,
        totalTimeSpent,
        lastAccessed,
        status: enrollment.status || 'pending',
      }
    })
  }, [progressByEnrollment, enrollments, students, courses])

  // Filter and sort
  const filteredAndSortedProgress = useMemo(() => {
    let filtered = enrollmentProgress.filter((item): item is NonNullable<typeof item> => item !== null)

    // Search filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter((item) => {
        const studentName = (item.student?.full_name || item.student?.email || '').toLowerCase()
        const courseName = (item.course?.title || '').toLowerCase()
        return studentName.includes(query) || courseName.includes(query)
      })
    }

    // Course filter
    if (courseFilter !== 'all') {
      filtered = filtered.filter((item) => item.enrollment.course_id === courseFilter)
    }

    // Status filter
    if (statusFilter !== 'all') {
      filtered = filtered.filter((item) => item.status === statusFilter)
    }

    // Progress range filter
    if (progressRangeFilter !== 'all') {
      filtered = filtered.filter((item) => {
        const progress = item.progressPercentage
        switch (progressRangeFilter) {
          case '0-25':
            return progress >= 0 && progress <= 25
          case '26-50':
            return progress > 25 && progress <= 50
          case '51-75':
            return progress > 50 && progress <= 75
          case '76-100':
            return progress > 75 && progress <= 100
          default:
            return true
        }
      })
    }

    // Sort
    if (sortField) {
      filtered = [...filtered].sort((a, b) => {
        let aValue: any
        let bValue: any

        switch (sortField) {
          case 'progress_percentage':
            aValue = a.progressPercentage
            bValue = b.progressPercentage
            break
          case 'student_name':
            aValue = (a.student?.full_name || a.student?.email || '').toLowerCase()
            bValue = (b.student?.full_name || b.student?.email || '').toLowerCase()
            break
          case 'course_name':
            aValue = (a.course?.title || '').toLowerCase()
            bValue = (b.course?.title || '').toLowerCase()
            break
          case 'last_accessed':
            aValue = a.lastAccessed
            bValue = b.lastAccessed
            break
          default:
            return 0
        }

        if (sortOrder === 'asc') {
          return aValue > bValue ? 1 : -1
        } else {
          return aValue < bValue ? 1 : -1
        }
      })
    }

    return filtered
  }, [
    enrollmentProgress,
    searchQuery,
    courseFilter,
    statusFilter,
    progressRangeFilter,
    sortField,
    sortOrder,
  ])

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

  const handleExport = async (format: 'csv' | 'excel') => {
    try {
      const exportData = filteredAndSortedProgress.map((item) => ({
        'Student': item.student?.full_name || item.student?.email || 'Unknown',
        'Course': item.course?.title || 'Unknown',
        'Progress': `${item.progressPercentage.toFixed(1)}%`,
        'Completed Modules': item.completedCount,
        'Total Modules': item.totalCount,
        'Time Spent (minutes)': item.totalTimeSpent,
        'Status': item.status,
        'Last Accessed': item.lastAccessed
          ? new Date(item.lastAccessed).toLocaleString()
          : 'N/A',
      }))

      if (format === 'csv') {
        const { exportToCSV } = await import('@/lib/utils/export')
        exportToCSV(exportData, 'student-progress')
        toast.success('Student progress exported to CSV')
      } else {
        const { exportToExcel } = await import('@/lib/utils/export')
        await exportToExcel(exportData, 'student-progress')
        toast.success('Student progress exported to Excel')
      }
    } catch (error) {
      toast.error('Failed to export student progress')
    }
  }

  // Calculate summary statistics
  const summaryStats = useMemo(() => {
    const total = filteredAndSortedProgress.length
    const avgProgress =
      total > 0
        ? filteredAndSortedProgress.reduce((sum, item) => sum + item.progressPercentage, 0) / total
        : 0
    const totalTimeSpent = filteredAndSortedProgress.reduce(
      (sum, item) => sum + item.totalTimeSpent,
      0
    )
    const completedEnrollments = filteredAndSortedProgress.filter(
      (item) => item.progressPercentage === 100
    ).length

    return {
      total,
      avgProgress,
      totalTimeSpent,
      completedEnrollments,
    }
  }, [filteredAndSortedProgress])

  if (isLoading) {
    return (
      <div className="space-y-4">
        {Array.from({ length: 3 }).map((_, i) => (
          <CardSkeleton key={i} lines={4} />
        ))}
      </div>
    )
  }

  return (
    <div className="space-y-4">
      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-gray-600">Total Enrollments</div>
            <div className="text-2xl font-bold">{summaryStats.total}</div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-gray-600">Average Progress</div>
            <div className="text-2xl font-bold text-blue-600">
              {summaryStats.avgProgress.toFixed(1)}%
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-gray-600">Completed Courses</div>
            <div className="text-2xl font-bold text-green-600">{summaryStats.completedEnrollments}</div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-gray-600">Total Time Spent</div>
            <div className="text-2xl font-bold">
              {Math.round(summaryStats.totalTimeSpent / 60)}h {summaryStats.totalTimeSpent % 60}m
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
                placeholder="Search by student name or course..."
              />
            </div>
            <div className="flex gap-2 flex-wrap">
              <select
                value={courseFilter}
                onChange={(e) => setCourseFilter(e.target.value)}
                className="rounded-md border border-gray-300 px-3 py-2 text-sm"
              >
                <option value="all">All Courses</option>
                {Object.values(courses).map((course) => (
                  <option key={course.id} value={course.id}>
                    {course.title}
                  </option>
                ))}
              </select>
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="rounded-md border border-gray-300 px-3 py-2 text-sm"
              >
                <option value="all">All Status</option>
                <option value="pending">Pending</option>
                <option value="active">Active</option>
                <option value="completed">Completed</option>
                <option value="dropped">Dropped</option>
              </select>
              <select
                value={progressRangeFilter}
                onChange={(e) => setProgressRangeFilter(e.target.value)}
                className="rounded-md border border-gray-300 px-3 py-2 text-sm"
              >
                <option value="all">All Progress</option>
                <option value="0-25">0-25%</option>
                <option value="26-50">26-50%</option>
                <option value="51-75">51-75%</option>
                <option value="76-100">76-100%</option>
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

          {filteredAndSortedProgress.length === 0 ? (
            <EmptyState
              title="No progress data found"
              description="No student progress matches your search criteria"
            />
          ) : (
            <div className="space-y-4">
              {filteredAndSortedProgress.map((item) => {
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

                return (
                  <Card key={item.enrollmentId}>
                    <CardContent className="p-6">
                      <div className="flex justify-between items-start mb-4">
                        <div className="flex-1">
                          <div className="flex items-center gap-3 mb-2">
                            <h3 className="font-semibold text-lg">
                              {item.student?.full_name || item.student?.email || 'Unknown Student'}
                            </h3>
                            <Badge className={getStatusColor(item.status)}>
                              {item.status.toUpperCase()}
                            </Badge>
                          </div>
                          <p className="text-sm text-gray-600 mb-1">
                            {item.course?.title || 'Unknown Course'}
                          </p>
                          {item.lastAccessed > 0 && (
                            <p className="text-xs text-gray-500">
                              Last accessed: {new Date(item.lastAccessed).toLocaleString()}
                            </p>
                          )}
                        </div>
                        <div className="text-right">
                          <p className="text-2xl font-bold text-blue-600">
                            {item.progressPercentage.toFixed(0)}%
                          </p>
                          <p className="text-xs text-gray-500">
                            {item.completedCount} of {item.totalCount} modules
                          </p>
                          {item.totalTimeSpent > 0 && (
                            <p className="text-xs text-gray-500 mt-1">
                              {Math.round(item.totalTimeSpent / 60)}h {item.totalTimeSpent % 60}m
                            </p>
                          )}
                        </div>
                      </div>
                      <div className="w-full bg-gray-200 rounded-full h-2 mb-4">
                        <div
                          className="bg-blue-600 h-2 rounded-full transition-all"
                          style={{ width: `${item.progressPercentage}%` }}
                        />
                      </div>
                      <div className="grid grid-cols-3 gap-2 text-xs">
                        <div className="text-center">
                          <p className="font-semibold">{item.completedCount}</p>
                          <p className="text-gray-500">Completed</p>
                        </div>
                        <div className="text-center">
                          <p className="font-semibold">
                            {item.progressList.filter((p) => p.status === 'in_progress').length}
                          </p>
                          <p className="text-gray-500">In Progress</p>
                        </div>
                        <div className="text-center">
                          <p className="font-semibold">
                            {item.progressList.filter((p) => p.status === 'not_started').length}
                          </p>
                          <p className="text-gray-500">Not Started</p>
                        </div>
                      </div>
                      <div className="mt-4 flex justify-end">
                        <Link href={`/enrollments/${item.enrollmentId}`}>
                          <Button variant="outline" size="sm">
                            View Details
                          </Button>
                        </Link>
                      </div>
                    </CardContent>
                  </Card>
                )
              })}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
