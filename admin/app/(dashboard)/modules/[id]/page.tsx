'use client'

import { ModuleForm } from '@/components/modules/module-form'
import { useParams } from 'next/navigation'

export const dynamic = 'force-dynamic'

export default function EditModulePage() {
  const params = useParams()
  const moduleId = params.id as string

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Edit Module</h1>
        <p className="text-gray-600 mt-1">Update module information</p>
      </div>
      <ModuleForm moduleId={moduleId} />
    </div>
  )
}

