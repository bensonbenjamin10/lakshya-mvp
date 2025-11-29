'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts'
import { format, subDays } from 'date-fns'

interface LeadsChartProps {
  leads: any[]
}

export function LeadsChart({ leads }: LeadsChartProps) {
  // Group leads by date for the last 7 days
  const last7Days = Array.from({ length: 7 }, (_, i) => {
    const date = subDays(new Date(), 6 - i)
    const dateStr = format(date, 'yyyy-MM-dd')
    const count = leads.filter((lead) => {
      const leadDate = format(new Date(lead.created_at), 'yyyy-MM-dd')
      return leadDate === dateStr
    }).length
    return {
      date: format(date, 'MMM dd'),
      leads: count,
    }
  })

  return (
    <Card>
      <CardHeader>
        <CardTitle>Leads Over Time</CardTitle>
      </CardHeader>
      <CardContent>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={last7Days}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line
              type="monotone"
              dataKey="leads"
              stroke="#2563eb"
              strokeWidth={2}
              name="Leads"
            />
          </LineChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  )
}

