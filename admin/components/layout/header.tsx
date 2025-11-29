'use client'

import { useGetIdentity } from '@refinedev/core'
import { User } from 'lucide-react'

export function Header() {
  const { data: identity } = useGetIdentity()

  return (
    <header className="flex h-16 items-center justify-between border-b border-gray-200 bg-white px-6">
      <div className="flex items-center gap-4">
        <h2 className="text-lg font-semibold text-gray-900">Admin Panel</h2>
      </div>
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2 text-sm text-gray-600">
          <User className="h-5 w-5" />
          <span>{identity?.name || identity?.email || 'Admin'}</span>
        </div>
      </div>
    </header>
  )
}

