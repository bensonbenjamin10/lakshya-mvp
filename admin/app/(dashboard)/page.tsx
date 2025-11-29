import { StatsCards } from '@/components/dashboard/stats-cards'
import { LeadsChart } from '@/components/dashboard/leads-chart'
import { ConversionFunnel } from '@/components/dashboard/conversion-funnel'
import { RecentActivity } from '@/components/dashboard/recent-activity'
import { QuickActions } from '@/components/dashboard/quick-actions'
import { createClient } from '@/lib/supabase/server'

export default async function DashboardPage() {
  const supabase = await createClient()

  // Fetch dashboard data
  const [leadsData, coursesData, enrollmentsData] = await Promise.all([
    supabase.from('leads').select('*').order('created_at', { ascending: false }),
    supabase.from('courses').select('*'),
    supabase.from('enrollments').select('*'),
  ])

  const leads = leadsData.data || []
  const courses = coursesData.data || []
  const enrollments = enrollmentsData.data || []

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="text-gray-600 mt-1">Welcome back! Here's what's happening.</p>
      </div>

      <StatsCards leads={leads} courses={courses} enrollments={enrollments} />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <LeadsChart leads={leads} />
        <ConversionFunnel leads={leads} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <QuickActions />
        <RecentActivity />
      </div>
    </div>
  )
}

