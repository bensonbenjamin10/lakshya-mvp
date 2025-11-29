'use client'

import { useRouter } from 'next/navigation'
import { ModulesTable } from '@/components/modules/modules-table'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'

export default function ModulesPage() {
  const router = useRouter()

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Course Modules</h1>
          <p className="text-gray-600 mt-1">Manage course content modules</p>
        </div>
        <Button onClick={() => router.push('/modules/create')}>
          <Plus className="h-4 w-4 mr-2" />
          Add Module
        </Button>
      </div>

      <ModulesTable />
    </div>
  )
}

