'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'

interface LeadFiltersProps {
  filters: {
    status?: string
    source?: string
  }
  onFiltersChange: (filters: { status?: string; source?: string }) => void
}

export function LeadFilters({ filters, onFiltersChange }: LeadFiltersProps) {
  const statuses = ['all', 'new', 'contacted', 'qualified', 'converted', 'lost']
  const sources = ['all', 'website', 'social_media', 'referral', 'advertisement', 'other']

  const handleStatusChange = (status: string) => {
    onFiltersChange({
      ...filters,
      status: status === 'all' ? undefined : status,
    })
  }

  const handleSourceChange = (source: string) => {
    onFiltersChange({
      ...filters,
      source: source === 'all' ? undefined : source,
    })
  }

  return (
    <div className="flex flex-wrap gap-2 p-4 bg-gray-50 rounded-lg">
      <div className="flex items-center gap-2">
        <span className="text-sm font-medium">Status:</span>
        {statuses.map((status) => (
          <Button
            key={status}
            variant={filters.status === status || (!filters.status && status === 'all') ? 'default' : 'outline'}
            size="sm"
            onClick={() => handleStatusChange(status)}
          >
            {status.charAt(0).toUpperCase() + status.slice(1)}
          </Button>
        ))}
      </div>
      <div className="flex items-center gap-2">
        <span className="text-sm font-medium">Source:</span>
        {sources.map((source) => (
          <Button
            key={source}
            variant={filters.source === source || (!filters.source && source === 'all') ? 'default' : 'outline'}
            size="sm"
            onClick={() => handleSourceChange(source)}
          >
            {source.replace('_', ' ').replace(/\b\w/g, (l) => l.toUpperCase())}
          </Button>
        ))}
      </div>
    </div>
  )
}

