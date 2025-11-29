'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { format } from 'date-fns'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import Link from 'next/link'
import { ArrowLeft, Save, User } from 'lucide-react'
import { Database } from '@/lib/types/database.types'
import { LeadActivityLog } from '@/components/leads/lead-activity-log'

type Lead = Database['public']['Tables']['leads']['Row']
type LeadUpdate = Database['public']['Tables']['leads']['Update']
type Profile = Database['public']['Tables']['profiles']['Row']

interface LeadDetailPageProps {
  params: Promise<{ id: string }>
}

export default function LeadDetailPage({ params }: LeadDetailPageProps) {
  const [leadId, setLeadId] = useState<string | null>(null)
  const [lead, setLead] = useState<Lead | null>(null)
  const [profiles, setProfiles] = useState<Profile[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [notes, setNotes] = useState('')
  const [assignedTo, setAssignedTo] = useState<string | null>(null)
  const [status, setStatus] = useState<string>('new')
  const router = useRouter()

  useEffect(() => {
    params.then((p) => setLeadId(p.id))
  }, [params])

  useEffect(() => {
    if (!leadId) return

    const supabase = createClient()

    // Load lead
    const loadLead = async () => {
      const { data: leadData, error: leadError } = await supabase
        .from('leads')
        .select('*')
        .eq('id', leadId)
        .single()

      if (leadError) {
        console.error('Error loading lead:', leadError)
        return
      }

      if (leadData) {
        const lead = leadData as Lead
        setLead(lead)
        setNotes(lead.notes || '')
        setAssignedTo(lead.assigned_to)
        setStatus(lead.status || 'new')
      }
    }

    // Load profiles (admin and faculty only)
    const loadProfiles = async () => {
      const { data: profilesData, error: profilesError } = await supabase
        .from('profiles')
        .select('*')
        .in('role', ['admin', 'faculty'])
        .order('full_name')

      if (profilesError) {
        console.error('Error loading profiles:', profilesError)
        return
      }

      if (profilesData) {
        setProfiles(profilesData as Profile[])
      }
    }

    Promise.all([loadLead(), loadProfiles()]).then(() => {
      setIsLoading(false)
    })
  }, [leadId])

  const handleSave = async () => {
    if (!leadId) return

    setIsSaving(true)
    const supabase = createClient()

    try {
      const updateData = {
        notes: notes || null,
        assigned_to: assignedTo || null,
        status: status,
        updated_at: new Date().toISOString(),
      }
      
      // Use RPC or direct SQL if update doesn't work
      const { error } = await (supabase as any)
        .from('leads')
        .update(updateData)
        .eq('id', leadId)

      if (error) {
        console.error('Error updating lead:', error)
        alert('Failed to update lead. Please try again.')
      } else {
        // Reload lead data
        const { data: leadData } = await supabase
          .from('leads')
          .select('*')
          .eq('id', leadId)
          .single()

        if (leadData) {
          setLead(leadData as Lead)
        }
        alert('Lead updated successfully!')
      }
    } catch (err) {
      console.error('Error updating lead:', err)
      alert('Failed to update lead. Please try again.')
    } finally {
      setIsSaving(false)
    }
  }

  const getAssignedProfileName = () => {
    if (!assignedTo) return 'Unassigned'
    const profile = profiles.find((p) => p.id === assignedTo)
    return profile?.full_name || profile?.email || 'Unknown'
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading lead details...</p>
        </div>
      </div>
    )
  }

  if (!lead) {
    return (
      <div className="p-4">
        <p>Lead not found</p>
        <Link href="/leads">
          <Button variant="ghost" size="sm" className="mt-4">
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Leads
          </Button>
        </Link>
      </div>
    )
  }

  const hasChanges =
    notes !== (lead.notes || '') ||
    assignedTo !== lead.assigned_to ||
    status !== (lead.status || 'new')

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link href="/leads">
            <Button variant="ghost" size="sm">
              <ArrowLeft className="h-4 w-4 mr-2" />
              Back to Leads
            </Button>
          </Link>
          <div>
            <h1 className="text-3xl font-bold">{lead.name}</h1>
            <p className="text-gray-600 mt-1">Lead Details</p>
          </div>
        </div>
        {hasChanges && (
          <Button onClick={handleSave} disabled={isSaving} size="sm">
            <Save className="h-4 w-4 mr-2" />
            {isSaving ? 'Saving...' : 'Save Changes'}
          </Button>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Contact Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <label className="text-sm font-medium text-gray-500">Email</label>
              <p className="text-sm">{lead.email}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Phone</label>
              <p className="text-sm">{lead.phone}</p>
            </div>
            {lead.country && (
              <div>
                <label className="text-sm font-medium text-gray-500">Country</label>
                <p className="text-sm">{lead.country}</p>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Lead Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <label className="text-sm font-medium text-gray-500 mb-2 block">Status</label>
              <select
                value={status}
                onChange={(e) => setStatus(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="new">New</option>
                <option value="contacted">Contacted</option>
                <option value="qualified">Qualified</option>
                <option value="converted">Converted</option>
                <option value="lost">Lost</option>
              </select>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Source</label>
              <p className="text-sm">{lead.source?.replace('_', ' ') || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Inquiry Type</label>
              <p className="text-sm">{lead.inquiry_type?.replace('_', ' ') || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500 mb-2 block">Assigned To</label>
              <div className="flex items-center gap-2">
                <select
                  value={assignedTo || ''}
                  onChange={(e) => setAssignedTo(e.target.value || null)}
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">Unassigned</option>
                  {profiles.map((profile) => (
                    <option key={profile.id} value={profile.id}>
                      {profile.full_name || profile.email} ({profile.role})
                    </option>
                  ))}
                </select>
                {assignedTo && (
                  <div className="flex items-center text-sm text-gray-600">
                    <User className="h-4 w-4 mr-1" />
                    {getAssignedProfileName()}
                  </div>
                )}
              </div>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Created</label>
              <p className="text-sm">{lead.created_at ? format(new Date(lead.created_at), 'PPpp') : 'N/A'}</p>
            </div>
          </CardContent>
        </Card>

        {lead.message && (
          <Card className="md:col-span-2">
            <CardHeader>
              <CardTitle>Message</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm whitespace-pre-wrap">{lead.message}</p>
            </CardContent>
          </Card>
        )}

        <Card className="md:col-span-2">
          <CardHeader>
            <CardTitle>Notes</CardTitle>
          </CardHeader>
          <CardContent>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Add notes about this lead..."
              rows={6}
              className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 resize-y"
            />
            <p className="text-xs text-gray-500 mt-2">
              Notes are only visible to admin and faculty members.
            </p>
          </CardContent>
        </Card>
      </div>

      {leadId && <LeadActivityLog leadId={leadId} />}
    </div>
  )
}
