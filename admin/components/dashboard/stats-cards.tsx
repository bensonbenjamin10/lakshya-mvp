'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Users, BookOpen, TrendingUp, CheckCircle } from 'lucide-react'

interface StatsCardsProps {
  leads: any[]
  courses: any[]
}

export function StatsCards({ leads, courses }: StatsCardsProps) {
  const totalLeads = leads.length
  const newLeads = leads.filter((l) => l.status === 'new').length
  const convertedLeads = leads.filter((l) => l.status === 'converted').length
  const totalCourses = courses.length

  const stats = [
    {
      title: 'Total Leads',
      value: totalLeads,
      icon: Users,
      color: 'text-blue-600',
      bgColor: 'bg-blue-50',
    },
    {
      title: 'New Leads',
      value: newLeads,
      icon: TrendingUp,
      color: 'text-green-600',
      bgColor: 'bg-green-50',
    },
    {
      title: 'Converted',
      value: convertedLeads,
      icon: CheckCircle,
      color: 'text-purple-600',
      bgColor: 'bg-purple-50',
    },
    {
      title: 'Total Courses',
      value: totalCourses,
      icon: BookOpen,
      color: 'text-orange-600',
      bgColor: 'bg-orange-50',
    },
  ]

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      {stats.map((stat) => (
        <Card key={stat.title}>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">{stat.title}</CardTitle>
            <stat.icon className={`h-4 w-4 ${stat.color}`} />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stat.value}</div>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}

