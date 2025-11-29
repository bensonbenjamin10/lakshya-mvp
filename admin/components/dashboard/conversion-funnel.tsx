'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts'

interface ConversionFunnelProps {
  leads: any[]
}

export function ConversionFunnel({ leads }: ConversionFunnelProps) {
  const statusCounts = {
    new: leads.filter((l) => l.status === 'new').length,
    contacted: leads.filter((l) => l.status === 'contacted').length,
    qualified: leads.filter((l) => l.status === 'qualified').length,
    converted: leads.filter((l) => l.status === 'converted').length,
    lost: leads.filter((l) => l.status === 'lost').length,
  }

  const data = Object.entries(statusCounts).map(([status, count]) => ({
    status: status.charAt(0).toUpperCase() + status.slice(1),
    count,
  }))

  return (
    <Card>
      <CardHeader>
        <CardTitle>Lead Status Breakdown</CardTitle>
      </CardHeader>
      <CardContent>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={data}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="status" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Bar dataKey="count" fill="#2563eb" name="Leads" />
          </BarChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  )
}

