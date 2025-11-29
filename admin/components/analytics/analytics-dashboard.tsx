'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Database } from '@/lib/types/database.types'
import { format } from 'date-fns'

type Lead = Database['public']['Tables']['leads']['Row']
type Profile = Database['public']['Tables']['profiles']['Row']
type LeadActivity = Database['public']['Tables']['lead_activities']['Row']
type Course = Database['public']['Tables']['courses']['Row']

interface AnalyticsDashboardProps {
  leads: Lead[]
  courses: Course[]
  profiles: Profile[]
  activities: LeadActivity[]
}

export function AnalyticsDashboard({
  leads,
  courses,
  profiles,
  activities,
}: AnalyticsDashboardProps) {
  // Lead status breakdown
  const statusBreakdown = leads.reduce((acc, lead) => {
    const status = lead.status || 'new'
    acc[status] = (acc[status] || 0) + 1
    return acc
  }, {} as Record<string, number>)

  // Lead source breakdown
  const sourceBreakdown = leads.reduce((acc, lead) => {
    const source = lead.source || 'website'
    acc[source] = (acc[source] || 0) + 1
    return acc
  }, {} as Record<string, number>)

  // Assignment breakdown
  const assignmentBreakdown = leads.reduce((acc, lead) => {
    const assignedTo = lead.assigned_to || 'unassigned'
    acc[assignedTo] = (acc[assignedTo] || 0) + 1
    return acc
  }, {} as Record<string, number>)

  // Conversion rates by assigned faculty
  const conversionByFaculty = profiles.map((profile) => {
    const assignedLeads = leads.filter((lead) => lead.assigned_to === profile.id)
    const convertedLeads = assignedLeads.filter((lead) => lead.status === 'converted')
    const conversionRate =
      assignedLeads.length > 0 ? (convertedLeads.length / assignedLeads.length) * 100 : 0

    return {
      profile,
      totalLeads: assignedLeads.length,
      convertedLeads: convertedLeads.length,
      conversionRate,
    }
  })

  // Response time metrics (time from creation to first activity)
  const responseTimes = leads.map((lead) => {
    const leadActivities = activities.filter((activity) => activity.lead_id === lead.id)
    if (leadActivities.length === 0) return null

    const firstActivity = leadActivities.sort(
      (a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
    )[0]

    const createdTime = new Date(lead.created_at).getTime()
    const firstActivityTime = new Date(firstActivity.created_at).getTime()
    const responseTimeHours = (firstActivityTime - createdTime) / (1000 * 60 * 60)

    return {
      leadId: lead.id,
      responseTimeHours,
    }
  }).filter((rt): rt is { leadId: string; responseTimeHours: number } => rt !== null)

  const avgResponseTime =
    responseTimes.length > 0
      ? responseTimes.reduce((sum, rt) => sum + rt.responseTimeHours, 0) / responseTimes.length
      : 0

  // Leads over time (last 30 days)
  const thirtyDaysAgo = new Date()
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)

  const leadsOverTime = leads
    .filter((lead) => new Date(lead.created_at) >= thirtyDaysAgo)
    .reduce((acc, lead) => {
      const date = format(new Date(lead.created_at), 'yyyy-MM-dd')
      acc[date] = (acc[date] || 0) + 1
      return acc
    }, {} as Record<string, number>)

  const getProfileName = (profileId: string) => {
    const profile = profiles.find((p) => p.id === profileId)
    return profile?.full_name || profile?.email || 'Unknown'
  }

  return (
    <div className="space-y-6">
      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-gray-600">Total Leads</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{leads.length}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-gray-600">Converted</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-green-600">
              {statusBreakdown['converted'] || 0}
            </div>
            <div className="text-sm text-gray-500">
              {leads.length > 0
                ? ((statusBreakdown['converted'] || 0) / leads.length * 100).toFixed(1)
                : 0}
              % conversion rate
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-gray-600">Unassigned</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-orange-600">
              {assignmentBreakdown['unassigned'] || 0}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-gray-600">Avg Response Time</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">
              {avgResponseTime > 0 ? avgResponseTime.toFixed(1) : 'N/A'}
            </div>
            <div className="text-sm text-gray-500">hours</div>
          </CardContent>
        </Card>
      </div>

      {/* Lead Status Breakdown */}
      <Card>
        <CardHeader>
          <CardTitle>Lead Status Breakdown</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            {Object.entries(statusBreakdown).map(([status, count]) => (
              <div key={status} className="flex items-center justify-between">
                <span className="text-sm capitalize">{status.replace('_', ' ')}</span>
                <div className="flex items-center gap-4">
                  <div className="w-32 bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-blue-600 h-2 rounded-full"
                      style={{ width: `${(count / leads.length) * 100}%` }}
                    />
                  </div>
                  <span className="text-sm font-medium w-12 text-right">{count}</span>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Lead Source Breakdown */}
      <Card>
        <CardHeader>
          <CardTitle>Lead Source Breakdown</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            {Object.entries(sourceBreakdown).map(([source, count]) => (
              <div key={source} className="flex items-center justify-between">
                <span className="text-sm capitalize">{source.replace('_', ' ')}</span>
                <div className="flex items-center gap-4">
                  <div className="w-32 bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-green-600 h-2 rounded-full"
                      style={{ width: `${(count / leads.length) * 100}%` }}
                    />
                  </div>
                  <span className="text-sm font-medium w-12 text-right">{count}</span>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Conversion Rates by Faculty */}
      <Card>
        <CardHeader>
          <CardTitle>Conversion Rates by Assigned Faculty</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {conversionByFaculty
              .filter((item) => item.totalLeads > 0)
              .sort((a, b) => b.conversionRate - a.conversionRate)
              .map((item) => (
                <div key={item.profile.id} className="space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-medium">
                      {item.profile.full_name || item.profile.email}
                    </span>
                    <span className="text-sm text-gray-600">
                      {item.conversionRate.toFixed(1)}% ({item.convertedLeads}/{item.totalLeads})
                    </span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-purple-600 h-2 rounded-full"
                      style={{ width: `${item.conversionRate}%` }}
                    />
                  </div>
                </div>
              ))}
            {conversionByFaculty.filter((item) => item.totalLeads > 0).length === 0 && (
              <p className="text-sm text-gray-500">No assigned leads yet</p>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Assignment Breakdown */}
      <Card>
        <CardHeader>
          <CardTitle>Assignment Breakdown</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium">Unassigned</span>
              <span className="text-sm font-medium">{assignmentBreakdown['unassigned'] || 0}</span>
            </div>
            {Object.entries(assignmentBreakdown)
              .filter(([id]) => id !== 'unassigned')
              .map(([profileId, count]) => (
                <div key={profileId} className="flex items-center justify-between">
                  <span className="text-sm">{getProfileName(profileId)}</span>
                  <span className="text-sm font-medium">{count}</span>
                </div>
              ))}
          </div>
        </CardContent>
      </Card>

      {/* Leads Over Time */}
      <Card>
        <CardHeader>
          <CardTitle>Leads Over Time (Last 30 Days)</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            {Object.entries(leadsOverTime)
              .sort(([a], [b]) => a.localeCompare(b))
              .map(([date, count]) => (
                <div key={date} className="flex items-center justify-between">
                  <span className="text-sm">{format(new Date(date), 'MMM dd, yyyy')}</span>
                  <div className="flex items-center gap-4">
                    <div className="w-32 bg-gray-200 rounded-full h-2">
                      <div
                        className="bg-blue-600 h-2 rounded-full"
                        style={{
                          width: `${
                            (count /
                              Math.max(...Object.values(leadsOverTime), 1)) *
                            100
                          }%`,
                        }}
                      />
                    </div>
                    <span className="text-sm font-medium w-12 text-right">{count}</span>
                  </div>
                </div>
              ))}
            {Object.keys(leadsOverTime).length === 0 && (
              <p className="text-sm text-gray-500">No leads in the last 30 days</p>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

