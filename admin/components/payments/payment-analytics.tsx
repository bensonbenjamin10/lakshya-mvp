'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Database } from '@/lib/types/database.types'
import {
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts'
import { format, subDays, startOfDay } from 'date-fns'

type Payment = Database['public']['Tables']['payments']['Row']
type Course = Database['public']['Tables']['courses']['Row']

interface PaymentAnalyticsProps {
  payments: Payment[]
  courses: Course[]
}

export function PaymentAnalytics({ payments, courses }: PaymentAnalyticsProps) {
  const courseMap = new Map(courses.map((c) => [c.id, c.title]))

  // Total revenue
  const totalRevenue = payments
    .filter((p) => p.payment_status === 'completed')
    .reduce((sum, p) => sum + Number(p.amount || 0), 0)

  // Payment success rate
  const totalPayments = payments.length
  const completedPayments = payments.filter((p) => p.payment_status === 'completed').length
  const successRate = totalPayments > 0 ? (completedPayments / totalPayments) * 100 : 0

  // Revenue by course
  const revenueByCourse = payments
    .filter((p) => p.payment_status === 'completed')
    .reduce((acc, p) => {
      const courseName = courseMap.get(p.course_id) || 'Unknown'
      acc[courseName] = (acc[courseName] || 0) + Number(p.amount || 0)
      return acc
    }, {} as Record<string, number>)

  const revenueByCourseData = Object.entries(revenueByCourse)
    .map(([name, value]) => ({ name, value }))
    .sort((a, b) => b.value - a.value)
    .slice(0, 10)

  // Payment method breakdown
  const paymentMethodBreakdown = payments.reduce((acc, p) => {
    const method = p.payment_method || 'Unknown'
    acc[method] = (acc[method] || 0) + 1
    return acc
  }, {} as Record<string, number>)

  const paymentMethodData = Object.entries(paymentMethodBreakdown).map(([name, value]) => ({
    name,
    value,
  }))

  // Payment provider breakdown
  const providerBreakdown = payments.reduce((acc, p) => {
    acc[p.payment_provider] = (acc[p.payment_provider] || 0) + 1
    return acc
  }, {} as Record<string, number>)

  const providerData = Object.entries(providerBreakdown).map(([name, value]) => ({
    name: name.toUpperCase(),
    value,
  }))

  // Refund rate
  const refundedPayments = payments.filter((p) => p.payment_status === 'refunded').length
  const refundRate = totalPayments > 0 ? (refundedPayments / totalPayments) * 100 : 0

  // Average transaction value
  const avgTransactionValue =
    completedPayments > 0 ? totalRevenue / completedPayments : 0

  // Revenue trends (last 30 days)
  const thirtyDaysAgo = startOfDay(subDays(new Date(), 30))
  const revenueTrends = payments
    .filter(
      (p) =>
        p.payment_status === 'completed' &&
        p.created_at &&
        new Date(p.created_at) >= thirtyDaysAgo
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

  // Status breakdown
  const statusBreakdown = payments.reduce((acc, p) => {
    acc[p.payment_status] = (acc[p.payment_status] || 0) + 1
    return acc
  }, {} as Record<string, number>)

  const statusData = Object.entries(statusBreakdown).map(([name, value]) => ({
    name: name.replace('_', ' ').toUpperCase(),
    value,
  }))

  const COLORS = ['#2563eb', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899']

  return (
    <div className="space-y-6">
      {/* Summary Cards */}
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
            <CardTitle className="text-sm font-medium text-gray-600">Success Rate</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">{successRate.toFixed(1)}%</div>
            <div className="text-sm text-gray-500">
              {completedPayments} of {totalPayments} payments
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-gray-600">Refund Rate</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-red-600">{refundRate.toFixed(1)}%</div>
            <div className="text-sm text-gray-500">{refundedPayments} refunded</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-gray-600">Avg Transaction</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold">
              {avgTransactionValue.toLocaleString('en-IN', {
                style: 'currency',
                currency: 'INR',
                maximumFractionDigits: 0,
              })}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Revenue Trends */}
      <Card>
        <CardHeader>
          <CardTitle>Revenue Trends (Last 30 Days)</CardTitle>
        </CardHeader>
        <CardContent>
          {revenueTrendsData.length === 0 ? (
            <p className="text-sm text-gray-500 text-center py-8">
              No revenue data in the last 30 days
            </p>
          ) : (
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
          )}
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Revenue by Course */}
        <Card>
          <CardHeader>
            <CardTitle>Revenue by Course</CardTitle>
          </CardHeader>
          <CardContent>
            {revenueByCourseData.length === 0 ? (
              <p className="text-sm text-gray-500 text-center py-8">No revenue data</p>
            ) : (
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
                  <Bar dataKey="value" fill="#2563eb" name="Revenue" />
                </BarChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>

        {/* Payment Status Breakdown */}
        <Card>
          <CardHeader>
            <CardTitle>Payment Status Breakdown</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={statusData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {statusData.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Payment Provider Breakdown */}
        <Card>
          <CardHeader>
            <CardTitle>Payment Provider Breakdown</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={providerData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {providerData.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Payment Method Breakdown */}
        {paymentMethodData.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle>Payment Method Breakdown</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={paymentMethodData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="value" fill="#8b5cf6" name="Count" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  )
}

