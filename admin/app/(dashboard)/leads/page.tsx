'use client'

import { useState } from 'react'
import { LeadFilters } from '@/components/leads/lead-filters'
import { LeadsTable } from '@/components/leads/leads-table'

export default function LeadsPage() {
  const [filters, setFilters] = useState<{
    status?: string
    source?: string
  }>({})

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Leads</h1>
          <p className="text-gray-600 mt-1">Manage and track all leads</p>
        </div>
      </div>

      <LeadFilters filters={filters} onFiltersChange={setFilters} />
      <LeadsTable filters={filters} />
    </div>
  )
}

