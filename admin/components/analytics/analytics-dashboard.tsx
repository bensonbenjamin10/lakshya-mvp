'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Database } from '@/lib/types/database.types'
import { format } from 'date-fns'
import {
  PieChart,
  Pie,
  Cell,
  BarChart,
  Bar,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts'

type Lead = Database['public']['Tables']['leads']['Row']
type Profile = Database['public']['Tables']['profiles']['Row']
type LeadActivity = Database['public']['Tables']['lead_activities']['Row']
type Course = Database['public']['Tables']['courses']['Row']
type Payment = Database['public']['Tables']['payments']['Row']
type Enrollment = Database['public']['Tables']['enrollments']['Row']

interface AnalyticsDashboardProps {
  leads: Lead[]
  courses: Course[]
  profiles: Profile[]
  activities: LeadActivity[]
  payments: Payment[]
  enrollments: Enrollment[]
}

export function AnalyticsDashboard({
  leads,
  courses,
  profiles,
  activities,
  payments,
  enrollments,
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
    if (!lead.created_at) return null

    const firstActivity = leadActivities
      .filter((a) => a.created_at)
      .sort(
        (a, b) => new Date(a.created_at!).getTime() - new Date(b.created_at!).getTime()
      )[0]

    if (!firstActivity?.created_at) return null

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
  const thirtyDaysAgoLeads = new Date()
  thirtyDaysAgoLeads.setDate(thirtyDaysAgoLeads.getDate() - 30)

  const leadsOverTime = leads
    .filter((lead) => lead.created_at && new Date(lead.created_at) >= thirtyDaysAgoLeads)
    .reduce((acc, lead) => {
      if (!lead.created_at) return acc
      const date = format(new Date(lead.created_at), 'yyyy-MM-dd')
      acc[date] = (acc[date] || 0) + 1
      return acc
    }, {} as Record<string, number>)

  const getProfileName = (profileId: string) => {
    const profile = profiles.find((p) => p.id === profileId)
    return profile?.full_name || profile?.email || 'Unknown'
  }

  // Revenue metrics
  const totalRevenue = payments
    .filter((p) => p.payment_status === 'completed')
    .reduce((sum, p) => sum + Number(p.amount || 0), 0)

  const completedPayments = payments.filter((p) => p.payment_status === 'completed').length
  const paymentSuccessRate =
    payments.length > 0 ? (completedPayments / payments.length) * 100 : 0

  // Enrollment metrics
  const totalEnrollments = enrollments.length
  const activeEnrollments = enrollments.filter((e) => e.status === 'active').length
  const completedEnrollments = enrollments.filter((e) => e.status === 'completed').length
  const enrollmentConversionRate =
    leads.length > 0 ? (totalEnrollments / leads.length) * 100 : 0

  // Course completion rate
  const avgProgress =
    enrollments.length > 0
      ? enrollments.reduce((sum, e) => sum + Number(e.progress_percentage || 0), 0) /
        enrollments.length
      : 0

  // Revenue by course
  const revenueByCourse = payments
    .filter((p) => p.payment_status === 'completed')
    .reduce((acc, p) => {
      const course = courses.find((c) => c.id === p.course_id)
      const courseName = course?.title || 'Unknown'
      acc[courseName] = (acc[courseName] || 0) + Number(p.amount || 0)
      return acc
    }, {} as Record<string, number>)

  const revenueByCourseData = Object.entries(revenueByCourse)
    .map(([name, value]) => ({ name, value }))
    .sort((a, b) => b.value - a.value)
    .slice(0, 10)

  // Enrollment trends (last 30 days)
  const thirtyDaysAgoEnrollments = new Date()
  thirtyDaysAgoEnrollments.setDate(thirtyDaysAgoEnrollments.getDate() - 30)

  const enrollmentTrends = enrollments
    .filter((e) => e.enrolled_at && new Date(e.enrolled_at) >= thirtyDaysAgoEnrollments)
    .reduce((acc, e) => {
      if (!e.enrolled_at) return acc
      const date = format(new Date(e.enrolled_at), 'yyyy-MM-dd')
      acc[date] = (acc[date] || 0) + 1
      return acc
    }, {} as Record<string, number>)

  const enrollmentTrendsData = Object.entries(enrollmentTrends)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([date, count]) => ({
      date: format(new Date(date), 'MMM dd'),
      enrollments: count,
    }))

  // Revenue trends (last 30 days)
  const thirtyDaysAgoRevenue = new Date()
  thirtyDaysAgoRevenue.setDate(thirtyDaysAgoRevenue.getDate() - 30)

  const revenueTrends = payments
    .filter(
      (p) =>
        p.payment_status === 'completed' &&
        p.created_at &&
        new Date(p.created_at) >= thirtyDaysAgoRevenue
    )
    .reduce((acc, p) => {
      if (!p.created_at) return acc
      const date = format(new Date(p.created_at), 'yyyy-MM-dd')
      acc[date] = (acc[date] || 0) + Number(p.amount || 0)
      return acc
    }, {} as Record<string, number>)

  const revenueTrendsData = Object.entries(revenueTrends)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([date, revenue]) => ({
      date: format(new Date(date), 'MMM dd'),
      revenue,
    }))

  // Course popularity (by enrollment count)
  const coursePopularity = enrollments.reduce((acc, e) => {
    const course = courses.find((c) => c.id === e.course_id)
    const courseName = course?.title || 'Unknown'
    acc[courseName] = (acc[courseName] || 0) + 1
    return acc
  }, {} as Record<string, number>)

  const coursePopularityData = Object.entries(coursePopularity)
    .map(([name, count]) => ({ name, count }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 10)

  // Lead to enrollment conversion funnel
  const conversionFunnel = {
    leads: leads.length,
    contacted: leads.filter((l) => l.status === 'contacted' || l.status === 'qualified').length,
    qualified: leads.filter((l) => l.status === 'qualified').length,
    converted: leads.filter((l) => l.status === 'converted').length,
    enrolled: totalEnrollments,
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

      {/* Revenue & Enrollment Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-gray-600">Total Revenue</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-green-600">
              {totalRevenue.toLocaleString('en-IN', {
                style: 'currency',
                currency: 'INR',
                maximumFractionDigits: 0,
              })}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-gray-600">Payment Success Rate</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{paymentSuccessRate.toFixed(1)}%</div>
            <div className="text-sm text-gray-500">
              {completedPayments} of {payments.length} payments
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-gray-600">Total Enrollments</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{totalEnrollments}</div>
            <div className="text-sm text-gray-500">
              {activeEnrollments} active, {completedEnrollments} completed
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-gray-600">Conversion Rate</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{enrollmentConversionRate.toFixed(1)}%</div>
            <div className="text-sm text-gray-500">Leads to enrollments</div>
          </CardContent>
        </Card>
      </div>

      {/* Revenue Trends */}
      {revenueTrendsData.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Revenue Trends (Last 30 Days)</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={revenueTrendsData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis />
                <Tooltip
                  formatter={(value: number) =>
                    Number(value).toLocaleString('en-IN', {
                      style: 'currency',
                      currency: 'INR',
                      maximumFractionDigits: 0,
                    })
                  }
                />
                <Legend />
                <Area
                  type="monotone"
                  dataKey="revenue"
                  stroke="#10b981"
                  fill="#10b981"
                  fillOpacity={0.6}
                  name="Revenue"
                />
              </AreaChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      )}

      {/* Enrollment Trends */}
      {enrollmentTrendsData.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Enrollment Trends (Last 30 Days)</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={enrollmentTrendsData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Area
                  type="monotone"
                  dataKey="enrollments"
                  stroke="#2563eb"
                  fill="#2563eb"
                  fillOpacity={0.6}
                  name="Enrollments"
                />
              </AreaChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Revenue by Course */}
        {revenueByCourseData.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle>Revenue by Course</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={revenueByCourseData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" angle={-45} textAnchor="end" height={100} />
                  <YAxis />
                  <Tooltip
                    formatter={(value: number) =>
                      Number(value).toLocaleString('en-IN', {
                        style: 'currency',
                        currency: 'INR',
                        maximumFractionDigits: 0,
                      })
                    }
                  />
                  <Legend />
                  <Bar dataKey="value" fill="#10b981" name="Revenue" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        )}

        {/* Course Popularity */}
        {coursePopularityData.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle>Course Popularity (Enrollments)</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={coursePopularityData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" angle={-45} textAnchor="end" height={100} />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="count" fill="#2563eb" name="Enrollments" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        )}

        {/* Conversion Funnel */}
        <Card>
          <CardHeader>
            <CardTitle>Lead to Enrollment Conversion Funnel</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Leads</span>
                  <span className="text-sm font-bold">{conversionFunnel.leads}</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-4">
                  <div
                    className="bg-blue-600 h-4 rounded-full"
                    style={{ width: '100%' }}
                  />
                </div>
              </div>
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Contacted</span>
                  <span className="text-sm font-bold">{conversionFunnel.contacted}</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-4">
                  <div
                    className="bg-purple-600 h-4 rounded-full"
                    style={{
                      width: `${(conversionFunnel.contacted / conversionFunnel.leads) * 100}%`,
                    }}
                  />
                </div>
              </div>
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Qualified</span>
                  <span className="text-sm font-bold">{conversionFunnel.qualified}</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-4">
                  <div
                    className="bg-indigo-600 h-4 rounded-full"
                    style={{
                      width: `${(conversionFunnel.qualified / conversionFunnel.leads) * 100}%`,
                    }}
                  />
                </div>
              </div>
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Converted</span>
                  <span className="text-sm font-bold">{conversionFunnel.converted}</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-4">
                  <div
                    className="bg-green-600 h-4 rounded-full"
                    style={{
                      width: `${(conversionFunnel.converted / conversionFunnel.leads) * 100}%`,
                    }}
                  />
                </div>
              </div>
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Enrolled</span>
                  <span className="text-sm font-bold">{conversionFunnel.enrolled}</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-4">
                  <div
                    className="bg-emerald-600 h-4 rounded-full"
                    style={{
                      width: `${(conversionFunnel.enrolled / conversionFunnel.leads) * 100}%`,
                    }}
                  />
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Average Progress */}
        <Card>
          <CardHeader>
            <CardTitle>Average Course Progress</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-center h-full">
              <div className="text-center">
                <div className="text-5xl font-bold text-blue-600">{avgProgress.toFixed(1)}%</div>
                <div className="text-sm text-gray-500 mt-2">Average completion rate</div>
                <div className="mt-4 w-64 mx-auto">
                  <div className="w-full bg-gray-200 rounded-full h-4">
                    <div
                      className="bg-blue-600 h-4 rounded-full transition-all"
                      style={{ width: `${avgProgress}%` }}
                    />
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Lead Status Breakdown */}
      <Card>
        <CardHeader>
          <CardTitle>Lead Status Breakdown</CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={Object.entries(statusBreakdown).map(([status, count]) => ({
                  name: status.charAt(0).toUpperCase() + status.slice(1).replace('_', ' '),
                  value: count,
                }))}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                outerRadius={80}
                fill="#8884d8"
                dataKey="value"
              >
                {Object.entries(statusBreakdown).map((_, index) => (
                  <Cell
                    key={`cell-${index}`}
                    fill={['#2563eb', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'][index % 5]}
                  />
                ))}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      {/* Lead Source Breakdown */}
      <Card>
        <CardHeader>
          <CardTitle>Lead Source Breakdown</CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart
              data={Object.entries(sourceBreakdown).map(([source, count]) => ({
                name: source.charAt(0).toUpperCase() + source.slice(1).replace('_', ' '),
                count,
              }))}
            >
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="count" fill="#10b981" name="Leads" />
            </BarChart>
          </ResponsiveContainer>
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
          {Object.keys(leadsOverTime).length === 0 ? (
            <p className="text-sm text-gray-500 text-center py-8">No leads in the last 30 days</p>
          ) : (
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart
                data={Object.entries(leadsOverTime)
                  .sort(([a], [b]) => a.localeCompare(b))
                  .map(([date, count]) => ({
                    date: format(new Date(date), 'MMM dd'),
                    leads: count,
                  }))}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Area
                  type="monotone"
                  dataKey="leads"
                  stroke="#2563eb"
                  fill="#2563eb"
                  fillOpacity={0.6}
                  name="Leads"
                />
              </AreaChart>
            </ResponsiveContainer>
          )}
        </CardContent>
      </Card>
    </div>
  )
}

