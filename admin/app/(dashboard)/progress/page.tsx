'use client'

import { StudentProgressTable } from '@/components/progress/student-progress-table'

export default function ProgressPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Student Progress</h1>
        <p className="text-gray-600 mt-1">Track student learning progress across courses</p>
      </div>

      <StudentProgressTable />
    </div>
  )
}

