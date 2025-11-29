'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Users, BookOpen, TrendingUp, CheckCircle, GraduationCap, UserCheck } from 'lucide-react'

interface StatsCardsProps {
  leads: any[]
  courses: any[]
  enrollments: any[]
}

export function StatsCards({ leads, courses, enrollments }: StatsCardsProps) {
  const totalLeads = leads.length
  const newLeads = leads.filter((l) => l.status === 'new').length
  const convertedLeads = leads.filter((l) => l.status === 'converted').length
  const totalCourses = courses.length
  const totalEnrollments = enrollments.length
  const activeStudents = enrollments.filter((e) => e.status === 'active').length
  const conversionRate =
    totalLeads > 0 ? ((convertedLeads / totalLeads) * 100).toFixed(1) : '0.0'

  const stats = [
    {
      title: 'Total Leads',
      value: totalLeads,
      icon: Users,
      color: 'text-blue-600',
      bgColor: 'bg-blue-50',
      trend: null,
    },
    {
      title: 'New Leads',
      value: newLeads,
      icon: TrendingUp,
      color: 'text-green-600',
      bgColor: 'bg-green-50',
      trend: null,
    },
    {
      title: 'Converted',
      value: convertedLeads,
      icon: CheckCircle,
      color: 'text-purple-600',
      bgColor: 'bg-purple-50',
      subtitle: `${conversionRate}% conversion rate`,
    },
    {
      title: 'Total Courses',
      value: totalCourses,
      icon: BookOpen,
      color: 'text-orange-600',
      bgColor: 'bg-orange-50',
      trend: null,
    },
    {
      title: 'Enrollments',
      value: totalEnrollments,
      icon: GraduationCap,
      color: 'text-indigo-600',
      bgColor: 'bg-indigo-50',
      trend: null,
    },
    {
      title: 'Active Students',
      value: activeStudents,
      icon: UserCheck,
      color: 'text-emerald-600',
      bgColor: 'bg-emerald-50',
      trend: null,
    },
  ]

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6">
      {stats.map((stat) => (
        <Card key={stat.title}>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">{stat.title}</CardTitle>
            <stat.icon className={`h-4 w-4 ${stat.color}`} />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stat.value}</div>
            {stat.subtitle && (
              <p className="text-xs text-gray-500 mt-1">{stat.subtitle}</p>
            )}
          </CardContent>
        </Card>
      ))}
    </div>
  )
}

