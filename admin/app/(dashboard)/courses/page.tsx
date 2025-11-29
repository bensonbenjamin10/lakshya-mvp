'use client'

import { useNavigation } from '@refinedev/core'
import { CoursesTable } from '@/components/courses/courses-table'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'

export default function CoursesPage() {
  const { push } = useNavigation()

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Courses</h1>
          <p className="text-gray-600 mt-1">Manage course catalog</p>
        </div>
        <Button onClick={() => push('/courses/create')}>
          <Plus className="h-4 w-4 mr-2" />
          Add Course
        </Button>
      </div>

      <CoursesTable />
    </div>
  )
}

