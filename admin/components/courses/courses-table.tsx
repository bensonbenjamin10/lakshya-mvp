'use client'

import { useState, useMemo } from 'react'
import { useList, useNavigation, useDeleteMany } from '@refinedev/core'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { TableSkeleton } from '@/components/ui/table-skeleton'
import { EmptyState } from '@/components/ui/empty-state'
import { SearchInput } from '@/components/ui/search-input'
import { exportToCSV, exportToExcel } from '@/lib/utils/export'
import { Download, ArrowUpDown, ArrowUp, ArrowDown, Trash2 } from 'lucide-react'
import { useToast } from '@/lib/hooks/use-toast'

type SortField = 'title' | 'category' | 'created_at' | null
type SortOrder = 'asc' | 'desc'

export function CoursesTable() {
  const toast = useToast()
  const [searchQuery, setSearchQuery] = useState('')
  const [sortField, setSortField] = useState<SortField>('created_at')
  const [sortOrder, setSortOrder] = useState<SortOrder>('desc')
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set())
  const { mutate: deleteMany } = useDeleteMany()

  const listResult = useList({
    resource: 'courses',
    sorters: sortField ? [{ field: sortField, order: sortOrder }] : [],
  })

  const allCourses = (listResult.result?.data || []) as any[]
  const isLoading = listResult.query?.isLoading || false

  const courses = useMemo(() => {
    let filtered = allCourses

    // Apply search filter
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter(
        (course) =>
          course.title?.toLowerCase().includes(query) ||
          course.category?.toLowerCase().includes(query) ||
          course.description?.toLowerCase().includes(query)
      )
    }

    // Apply client-side sorting if needed
    if (sortField) {
      filtered = [...filtered].sort((a, b) => {
        let aVal = a[sortField]
        let bVal = b[sortField]

        if (sortField === 'created_at') {
          aVal = new Date(aVal).getTime()
          bVal = new Date(bVal).getTime()
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
  }, [allCourses, searchQuery, sortField, sortOrder])

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
      const exportData = courses.map((course) => ({
        Title: course.title,
        Category: course.category,
        Duration: course.duration || 'N/A',
        Status: course.is_active ? 'Active' : 'Inactive',
        Created: course.created_at ? new Date(course.created_at).toLocaleDateString() : 'N/A',
      }))

      if (format === 'csv') {
        exportToCSV(exportData, 'courses')
        toast.success('Courses exported to CSV')
      } else {
        await exportToExcel(exportData, 'courses', 'Courses')
        toast.success('Courses exported to Excel')
      }
    } catch (error: any) {
      toast.error(error?.message || 'Failed to export courses')
    }
  }

  const handleBulkDelete = () => {
    if (selectedIds.size === 0) return

    if (confirm(`Are you sure you want to delete ${selectedIds.size} course(s)?`)) {
      deleteMany(
        {
          resource: 'courses',
          ids: Array.from(selectedIds),
        },
        {
          onSuccess: () => {
            toast.success(`${selectedIds.size} course(s) deleted successfully`)
            setSelectedIds(new Set())
          },
          onError: (error: any) => {
            toast.error(error?.message || 'Failed to delete courses')
          },
        }
      )
    }
  }

  const toggleSelection = (id: string) => {
    const newSelection = new Set(selectedIds)
    if (newSelection.has(id)) {
      newSelection.delete(id)
    } else {
      newSelection.add(id)
    }
    setSelectedIds(newSelection)
  }

  const toggleAll = () => {
    if (selectedIds.size === courses.length) {
      setSelectedIds(new Set())
    } else {
      setSelectedIds(new Set(courses.map((c) => c.id)))
    }
  }

  if (isLoading) {
    return <TableSkeleton rows={5} columns={5} />
  }

  if (courses.length === 0) {
    return (
      <EmptyState
        title="No courses found"
        description="Get started by creating your first course."
      />
    )
  }

  return (
    <Card>
      <CardContent className="p-4">
        <div className="mb-4 flex items-center justify-between gap-4">
          <SearchInput
            placeholder="Search courses by title, category, or description..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="max-w-md"
          />
          <div className="flex gap-2">
            {selectedIds.size > 0 && (
              <Button
                variant="destructive"
                size="sm"
                onClick={handleBulkDelete}
              >
                <Trash2 className="h-4 w-4 mr-2" />
                Delete ({selectedIds.size})
              </Button>
            )}
            <Button
              variant="outline"
              size="sm"
              onClick={() => handleExport('csv')}
              disabled={courses.length === 0}
            >
              <Download className="h-4 w-4 mr-2" />
              Export CSV
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => handleExport('excel')}
              disabled={courses.length === 0}
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
                <th className="px-6 py-3 text-left">
                  <input
                    type="checkbox"
                    checked={selectedIds.size === courses.length && courses.length > 0}
                    onChange={toggleAll}
                    className="rounded border-gray-300"
                  />
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <button
                    onClick={() => handleSort('title')}
                    className="flex items-center hover:text-gray-700"
                  >
                    Title
                    <SortIcon field="title" />
                  </button>
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <button
                    onClick={() => handleSort('category')}
                    className="flex items-center hover:text-gray-700"
                  >
                    Category
                    <SortIcon field="category" />
                  </button>
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Duration
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <button
                    onClick={() => handleSort('created_at')}
                    className="flex items-center hover:text-gray-700"
                  >
                    Created
                    <SortIcon field="created_at" />
                  </button>
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {courses.map((course: any) => (
                <tr key={course.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <input
                      type="checkbox"
                      checked={selectedIds.has(course.id)}
                      onChange={() => toggleSelection(course.id)}
                      className="rounded border-gray-300"
                    />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {course.title}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {course.category.replace('_', ' ').toUpperCase()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {course.duration || 'N/A'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        course.is_active
                          ? 'bg-green-100 text-green-800'
                          : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {course.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {course.created_at
                      ? new Date(course.created_at).toLocaleDateString()
                      : 'N/A'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <Link href={`/courses/${course.id}`}>
                      <Button variant="ghost" size="sm">
                        Edit
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

