import { createClient } from '@/lib/supabase/server'
import { LeadsChart } from '@/components/dashboard/leads-chart'
import { ConversionFunnel } from '@/components/dashboard/conversion-funnel'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  Legend,
  Tooltip,
} from 'recharts'

export default async function AnalyticsPage() {
  const supabase = await createClient()

  const [leadsData, coursesData] = await Promise.all([
    supabase.from('leads').select('*'),
    supabase.from('courses').select('*'),
  ])

  const leads = leadsData.data || []
  const courses = coursesData.data || []

  // Lead source breakdown
  const sourceData = [
    { name: 'Website', value: leads.filter((l) => l.source === 'website').length },
    { name: 'Social Media', value: leads.filter((l) => l.source === 'social_media').length },
    { name: 'Referral', value: leads.filter((l) => l.source === 'referral').length },
    { name: 'Advertisement', value: leads.filter((l) => l.source === 'advertisement').length },
    { name: 'Other', value: leads.filter((l) => l.source === 'other').length },
  ].filter((item) => item.value > 0)

  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8']

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Analytics</h1>
        <p className="text-gray-600 mt-1">Detailed analytics and insights</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Lead Sources</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={sourceData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {sourceData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <LeadsChart leads={leads} />
      </div>

      <ConversionFunnel leads={leads} />
    </div>
  )
}

