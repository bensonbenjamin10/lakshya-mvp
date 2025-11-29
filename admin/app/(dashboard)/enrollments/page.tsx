'use client'

import { EnrollmentsTable } from '@/components/enrollments/enrollments-table'

export default function EnrollmentsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Enrollments</h1>
        <p className="text-gray-600 mt-1">Manage student enrollments</p>
      </div>

      <EnrollmentsTable />
    </div>
  )
}

