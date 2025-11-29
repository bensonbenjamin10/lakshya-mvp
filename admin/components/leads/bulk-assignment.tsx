'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Database } from '@/lib/types/database.types'
import { Users } from 'lucide-react'

type Profile = Database['public']['Tables']['profiles']['Row']

interface BulkAssignmentProps {
  selectedLeadIds: string[]
  onComplete: () => void
}

export function BulkAssignment({ selectedLeadIds, onComplete }: BulkAssignmentProps) {
  const [profiles, setProfiles] = useState<Profile[]>([])
  const [selectedProfileId, setSelectedProfileId] = useState<string>('')
  const [isLoading, setIsLoading] = useState(false)
  const [isLoadingProfiles, setIsLoadingProfiles] = useState(true)

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
      setIsLoadingProfiles(false)
    }
    loadProfiles()
  }, [])

  const handleAssign = async () => {
    if (!selectedProfileId || selectedLeadIds.length === 0) return

    setIsLoading(true)
    const supabase = createClient()

    try {
      const updateData = {
        assigned_to: selectedProfileId === 'unassign' ? null : selectedProfileId,
        updated_at: new Date().toISOString(),
      }

      const { error } = await (supabase as any)
        .from('leads')
        .update(updateData)
        .in('id', selectedLeadIds)

      if (error) {
        console.error('Error assigning leads:', error)
        alert('Failed to assign leads. Please try again.')
      } else {
        alert(`Successfully assigned ${selectedLeadIds.length} lead(s)`)
        onComplete()
      }
    } catch (err) {
      console.error('Error assigning leads:', err)
      alert('Failed to assign leads. Please try again.')
    } finally {
      setIsLoading(false)
    }
  }

  if (selectedLeadIds.length === 0) {
    return null
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Users className="h-5 w-5" />
          Bulk Assignment ({selectedLeadIds.length} selected)
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex items-center gap-4">
          <select
            value={selectedProfileId}
            onChange={(e) => setSelectedProfileId(e.target.value)}
            className="flex-1 px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={isLoading || isLoadingProfiles}
          >
            <option value="">Select assignee...</option>
            <option value="unassign">Unassign</option>
            {profiles.map((profile) => (
              <option key={profile.id} value={profile.id}>
                {profile.full_name || profile.email} ({profile.role})
              </option>
            ))}
          </select>
          <Button
            onClick={handleAssign}
            disabled={!selectedProfileId || isLoading || isLoadingProfiles}
            size="sm"
          >
            {isLoading ? 'Assigning...' : 'Assign'}
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}

