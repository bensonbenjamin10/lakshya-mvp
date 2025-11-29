'use client'

import { useList, useNavigation } from '@refinedev/core'
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

type SortField = 'module_number' | 'title' | 'type' | null
type SortOrder = 'asc' | 'desc'

export function ModulesTable() {
  const toast = useToast()
  const [courses, setCourses] = useState<Record<string, string>>({})
  const [searchQuery, setSearchQuery] = useState('')
  const [sortField, setSortField] = useState<SortField>('module_number')
  const [sortOrder, setSortOrder] = useState<SortOrder>('asc')
  const supabase = createClient()

  useEffect(() => {
    // Load courses for display
    supabase
      .from('courses')
      .select('id, title')
      .then(({ data }) => {
        if (data) {
          const courseMap: Record<string, string> = {}
          data.forEach((course: any) => {
            courseMap[course.id] = course.title
          })
          setCourses(courseMap)
        }
      })
  }, [])

  const listResult = useList({
    resource: 'course_modules',
    sorters: [{ field: 'display_order', order: 'asc' }, { field: 'module_number', order: 'asc' }],
  })

  const allModules = (listResult.result?.data || []) as any[]
  const isLoading = listResult.query?.isLoading || false

  const modules = useMemo(() => {
    let filtered = allModules

    // Apply search filter
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter(
        (module) =>
          module.title?.toLowerCase().includes(query) ||
          module.type?.toLowerCase().includes(query) ||
          module.description?.toLowerCase().includes(query) ||
          courses[module.course_id]?.toLowerCase().includes(query)
      )
    }

    // Apply client-side sorting
    if (sortField) {
      filtered = [...filtered].sort((a, b) => {
        let aVal = a[sortField]
        let bVal = b[sortField]

        if (sortField === 'module_number') {
          aVal = Number(aVal) || 0
          bVal = Number(bVal) || 0
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
  }, [allModules, searchQuery, courses, sortField, sortOrder])

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
      const exportData = modules.map((module) => ({
        'Module #': module.module_number,
        Title: module.title,
        Course: courses[module.course_id] || 'Unknown',
        Type: module.type,
        Duration: module.duration_minutes ? `${module.duration_minutes} min` : 'N/A',
        Required: module.is_required ? 'Yes' : 'No',
      }))

      if (format === 'csv') {
        exportToCSV(exportData, 'modules')
        toast.success('Modules exported to CSV')
      } else {
        await exportToExcel(exportData, 'modules', 'Modules')
        toast.success('Modules exported to Excel')
      }
    } catch (error: any) {
      toast.error(error?.message || 'Failed to export modules')
    }
  }

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'video':
        return 'bg-blue-100 text-blue-800'
      case 'reading':
        return 'bg-green-100 text-green-800'
      case 'assignment':
        return 'bg-yellow-100 text-yellow-800'
      case 'quiz':
        return 'bg-purple-100 text-purple-800'
      case 'live_session':
        return 'bg-indigo-100 text-indigo-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  if (isLoading) {
    return <TableSkeleton rows={5} columns={7} />
  }

  if (modules.length === 0) {
    return (
      <EmptyState
        title="No modules found"
        description="Create your first course module to get started."
      />
    )
  }

  return (
    <Card>
      <CardContent className="p-4">
        <div className="mb-4 flex items-center justify-between gap-4">
          <SearchInput
            placeholder="Search modules by title, type, or course..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="max-w-md"
          />
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => handleExport('csv')}
              disabled={modules.length === 0}
            >
              <Download className="h-4 w-4 mr-2" />
              Export CSV
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => handleExport('excel')}
              disabled={modules.length === 0}
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
                  <button
                    onClick={() => handleSort('module_number')}
                    className="flex items-center hover:text-gray-700"
                  >
                    Module #
                    <SortIcon field="module_number" />
                  </button>
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
                  Course
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <button
                    onClick={() => handleSort('type')}
                    className="flex items-center hover:text-gray-700"
                  >
                    Type
                    <SortIcon field="type" />
                  </button>
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Duration
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Required
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {modules.map((module: any) => (
                <tr key={module.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {module.module_number}
                  </td>
                  <td className="px-6 py-4 text-sm font-medium text-gray-900">
                    {module.title}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {courses[module.course_id] || 'Unknown Course'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getTypeColor(
                        module.type
                      )}`}
                    >
                      {module.type.replace('_', ' ').toUpperCase()}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {module.duration_minutes ? `${module.duration_minutes} min` : 'N/A'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        module.is_required
                          ? 'bg-green-100 text-green-800'
                          : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {module.is_required ? 'Required' : 'Optional'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <Link href={`/modules/${module.id}`}>
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

