'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { createClient } from '@/lib/supabase/client'
import { Database } from '@/lib/types/database.types'

type Profile = Database['public']['Tables']['profiles']['Row']

interface LeadFiltersProps {
  filters: {
    status?: string
    source?: string
    assignedTo?: string
  }
  onFiltersChange: (filters: { status?: string; source?: string; assignedTo?: string }) => void
}

export function LeadFilters({ filters, onFiltersChange }: LeadFiltersProps) {
  const [profiles, setProfiles] = useState<Profile[]>([])
  const statuses = ['all', 'new', 'contacted', 'qualified', 'converted', 'lost']
  const sources = ['all', 'website', 'social_media', 'referral', 'advertisement', 'other']

  useEffect(() => {
    const supabase = createClient()
    const loadProfiles = async () => {
      const { data: profilesData } = await supabase
        .from('profiles')
        .select('*')
        .in('role', ['admin', 'faculty'])
        .order('full_name')

      if (profilesData) {
        setProfiles(profilesData as Profile[])
      }
    }
    loadProfiles()
  }, [])

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

  const handleAssignedToChange = (assignedTo: string) => {
    onFiltersChange({
      ...filters,
      assignedTo: assignedTo === 'all' ? undefined : assignedTo,
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
      <div className="flex items-center gap-2">
        <span className="text-sm font-medium">Assigned:</span>
        <Button
          variant={!filters.assignedTo || filters.assignedTo === 'all' ? 'default' : 'outline'}
          size="sm"
          onClick={() => handleAssignedToChange('all')}
        >
          All
        </Button>
        <Button
          variant={filters.assignedTo === 'unassigned' ? 'default' : 'outline'}
          size="sm"
          onClick={() => handleAssignedToChange('unassigned')}
        >
          Unassigned
        </Button>
        {profiles.map((profile) => (
          <Button
            key={profile.id}
            variant={filters.assignedTo === profile.id ? 'default' : 'outline'}
            size="sm"
            onClick={() => handleAssignedToChange(profile.id)}
          >
            {profile.full_name || profile.email}
          </Button>
        ))}
      </div>
    </div>
  )
}

