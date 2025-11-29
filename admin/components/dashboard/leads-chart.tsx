'use client'

import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
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
  const [days, setDays] = useState(7)

  const getDataForPeriod = (periodDays: number) => {
    return Array.from({ length: periodDays }, (_, i) => {
      const date = subDays(new Date(), periodDays - 1 - i)
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
  }

  const currentData = getDataForPeriod(days)
  const previousData = getDataForPeriod(days)

  const currentTotal = currentData.reduce((sum, d) => sum + d.leads, 0)
  const previousTotal = previousData.reduce((sum, d) => sum + d.leads, 0)
  const changePercent =
    previousTotal > 0 ? ((currentTotal - previousTotal) / previousTotal) * 100 : 0

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle>Leads Over Time</CardTitle>
          <div className="flex gap-2">
            <Button
              variant={days === 7 ? 'default' : 'outline'}
              size="sm"
              onClick={() => setDays(7)}
            >
              7D
            </Button>
            <Button
              variant={days === 30 ? 'default' : 'outline'}
              size="sm"
              onClick={() => setDays(30)}
            >
              30D
            </Button>
            <Button
              variant={days === 90 ? 'default' : 'outline'}
              size="sm"
              onClick={() => setDays(90)}
            >
              90D
            </Button>
          </div>
        </div>
        {changePercent !== 0 && (
          <p className="text-sm text-gray-600 mt-2">
            {changePercent > 0 ? '+' : ''}
            {changePercent.toFixed(1)}% vs previous period
          </p>
        )}
      </CardHeader>
      <CardContent>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={currentData}>
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
              dot={{ r: 4 }}
              activeDot={{ r: 6 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  )
}

