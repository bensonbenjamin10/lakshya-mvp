'use client'

import { useState, useEffect } from 'react'
import { useList, useInvalidate } from '@refinedev/core'
import { format } from 'date-fns'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { createClient } from '@/lib/supabase/client'
import { Database } from '@/lib/types/database.types'
import { BulkAssignment } from './bulk-assignment'

type Profile = Database['public']['Tables']['profiles']['Row']

interface LeadsTableProps {
  filters: {
    status?: string
    source?: string
    assignedTo?: string
  }
}

export function LeadsTable({ filters }: LeadsTableProps) {
  const [profiles, setProfiles] = useState<Map<string, Profile>>(new Map())
  const [selectedLeadIds, setSelectedLeadIds] = useState<Set<string>>(new Set())
  const invalidate = useInvalidate()

  const [currentPage, setCurrentPage] = useState(1)
  const pageSize = 20

  const listResult = useList({
    resource: 'leads',
    filters: [
      ...(filters.status ? [{ field: 'status', operator: 'eq' as const, value: filters.status }] : []),
      ...(filters.source ? [{ field: 'source', operator: 'eq' as const, value: filters.source }] : []),
      ...(filters.assignedTo === 'unassigned' ? [{ field: 'assigned_to', operator: 'null' as const }] : []),
      ...(filters.assignedTo && filters.assignedTo !== 'unassigned' ? [{ field: 'assigned_to', operator: 'eq' as const, value: filters.assignedTo }] : []),
    ],
    sorters: [{ field: 'created_at', order: 'desc' as const }],
    pagination: {
      current: currentPage,
      pageSize: pageSize,
    },
  })

  const leads = (listResult.result?.data || []) as any[]
  const isLoading = listResult.query?.isLoading || false
  const total = listResult.result?.total || 0
  const totalPages = Math.ceil(total / pageSize)

  useEffect(() => {
    const supabase = createClient()
    const loadProfiles = async () => {
      const { data: profilesData } = await supabase
        .from('profiles')
        .select('*')
        .in('role', ['admin', 'faculty'])

      if (profilesData) {
        const profilesMap = new Map<string, Profile>()
        profilesData.forEach((profile) => {
          profilesMap.set(profile.id, profile as Profile)
        })
        setProfiles(profilesMap)
      }
    }
    loadProfiles()
  }, [])

  const getAssignedName = (assignedTo: string | null) => {
    if (!assignedTo) return 'Unassigned'
    const profile = profiles.get(assignedTo)
    return profile?.full_name || profile?.email || 'Unknown'
  }

  const toggleLeadSelection = (leadId: string) => {
    const newSelection = new Set(selectedLeadIds)
    if (newSelection.has(leadId)) {
      newSelection.delete(leadId)
    } else {
      newSelection.add(leadId)
    }
    setSelectedLeadIds(newSelection)
  }

  const toggleAllLeads = () => {
    if (selectedLeadIds.size === leads.length) {
      setSelectedLeadIds(new Set())
    } else {
      setSelectedLeadIds(new Set(leads.map((lead: any) => lead.id)))
    }
  }

  const handleBulkAssignmentComplete = () => {
    setSelectedLeadIds(new Set())
    // Invalidate and refetch the leads list
    invalidate({ resource: 'leads', invalidates: ['list'] })
  }

  // Reset to page 1 when filters change
  useEffect(() => {
    setCurrentPage(1)
  }, [filters.status, filters.source, filters.assignedTo])

  if (isLoading) {
    return <div className="p-4">Loading leads...</div>
  }

  if (leads.length === 0) {
    return (
      <Card>
        <CardContent className="p-8 text-center text-gray-500">
          No leads found
        </CardContent>
      </Card>
    )
  }

  return (
    <>
      {selectedLeadIds.size > 0 && (
        <BulkAssignment
          selectedLeadIds={Array.from(selectedLeadIds)}
          onComplete={handleBulkAssignmentComplete}
        />
      )}
      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b">
                <tr>
                  <th className="px-6 py-3 text-left">
                    <input
                      type="checkbox"
                      checked={selectedLeadIds.size === leads.length && leads.length > 0}
                      onChange={toggleAllLeads}
                      className="rounded border-gray-300"
                    />
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Name
                  </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Email
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Phone
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Source
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Assigned To
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Created
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {leads.map((lead: any) => (
                <tr key={lead.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <input
                      type="checkbox"
                      checked={selectedLeadIds.has(lead.id)}
                      onChange={() => toggleLeadSelection(lead.id)}
                      className="rounded border-gray-300"
                    />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {lead.name}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {lead.email}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {lead.phone}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        lead.status === 'new'
                          ? 'bg-blue-100 text-blue-800'
                          : lead.status === 'converted'
                          ? 'bg-green-100 text-green-800'
                          : lead.status === 'lost'
                          ? 'bg-red-100 text-red-800'
                          : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {lead.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {lead.source.replace('_', ' ')}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {getAssignedName(lead.assigned_to)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {format(new Date(lead.created_at), 'MMM dd, yyyy')}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <Link href={`/leads/${lead.id}`}>
                      <Button variant="ghost" size="sm">
                        View
                      </Button>
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {totalPages > 1 && (
          <div className="px-6 py-4 border-t flex items-center justify-between">
            <div className="text-sm text-gray-600">
              Showing {(currentPage - 1) * pageSize + 1} to {Math.min(currentPage * pageSize, total)} of {total} leads
            </div>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                disabled={currentPage === 1 || isLoading}
              >
                Previous
              </Button>
              <div className="flex items-center gap-1">
                {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                  let pageNum: number
                  if (totalPages <= 5) {
                    pageNum = i + 1
                  } else if (currentPage <= 3) {
                    pageNum = i + 1
                  } else if (currentPage >= totalPages - 2) {
                    pageNum = totalPages - 4 + i
                  } else {
                    pageNum = currentPage - 2 + i
                  }
                  return (
                    <Button
                      key={pageNum}
                      variant={currentPage === pageNum ? 'default' : 'outline'}
                      size="sm"
                      onClick={() => setCurrentPage(pageNum)}
                      disabled={isLoading}
                    >
                      {pageNum}
                    </Button>
                  )
                })}
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                disabled={currentPage === totalPages || isLoading}
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  )
}

