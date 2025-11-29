'use client'

import { ModuleForm } from '@/components/modules/module-form'

export const dynamic = 'force-dynamic'

export default function CreateModulePage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Create Module</h1>
        <p className="text-gray-600 mt-1">Add a new course module</p>
      </div>
      <ModuleForm />
    </div>
  )
}

