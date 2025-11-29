import { createClient } from '@/lib/supabase/server'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { AnalyticsDashboard } from '@/components/analytics/analytics-dashboard'

export default async function AnalyticsPage() {
  const supabase = await createClient()

  const [leadsData, coursesData, profilesData, activitiesData] = await Promise.all([
    supabase.from('leads').select('*'),
    supabase.from('courses').select('*'),
    supabase.from('profiles').select('*').in('role', ['admin', 'faculty']),
    supabase.from('lead_activities').select('*'),
  ])

  const leads = leadsData.data || []
  const courses = coursesData.data || []
  const profiles = profilesData.data || []
  const activities = activitiesData.data || []

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Analytics</h1>
        <p className="text-gray-600 mt-1">Detailed analytics and insights</p>
      </div>

      <AnalyticsDashboard
        leads={leads}
        courses={courses}
        profiles={profiles}
        activities={activities}
      />
    </div>
  )
}
