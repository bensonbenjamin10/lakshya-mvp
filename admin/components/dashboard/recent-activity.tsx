'use client'

import { useEffect, useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { createClient } from '@/lib/supabase/client'
import { format } from 'date-fns'
import {
  UserPlus,
  BookOpen,
  GraduationCap,
  FileText,
  Video,
  CheckCircle,
  Clock,
  AlertCircle,
} from 'lucide-react'

interface Activity {
  id: string
  type: 'lead' | 'enrollment' | 'course' | 'module' | 'video'
  action: string
  description: string
  timestamp: string
  user?: string
}

export function RecentActivity() {
  const [activities, setActivities] = useState<Activity[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const supabase = createClient()

  useEffect(() => {
    const loadActivities = async () => {
      try {
        const [leadsData, enrollmentsData, coursesData, modulesData, videosData] =
          await Promise.all([
            supabase
              .from('leads')
              .select('id, name, status, created_at')
              .order('created_at', { ascending: false })
              .limit(5),
            supabase
              .from('enrollments')
              .select('id, enrolled_at, status')
              .order('enrolled_at', { ascending: false })
              .limit(5),
            supabase
              .from('courses')
              .select('id, title, created_at')
              .order('created_at', { ascending: false })
              .limit(5),
            supabase
              .from('course_modules')
              .select('id, title, created_at')
              .order('created_at', { ascending: false })
              .limit(5),
            supabase
              .from('video_promos')
              .select('id, title, created_at')
              .order('created_at', { ascending: false })
              .limit(5),
          ])

        const allActivities: Activity[] = []

        // Process leads
        leadsData.data?.forEach((lead: any) => {
          allActivities.push({
            id: lead.id,
            type: 'lead',
            action: lead.status === 'new' ? 'created' : 'updated',
            description: `New lead: ${lead.name}`,
            timestamp: lead.created_at,
          })
        })

        // Process enrollments
        enrollmentsData.data?.forEach((enrollment: any) => {
          allActivities.push({
            id: enrollment.id,
            type: 'enrollment',
            action: 'created',
            description: `New enrollment (${enrollment.status})`,
            timestamp: enrollment.enrolled_at,
          })
        })

        // Process courses
        coursesData.data?.forEach((course: any) => {
          allActivities.push({
            id: course.id,
            type: 'course',
            action: 'created',
            description: `Course created: ${course.title}`,
            timestamp: course.created_at,
          })
        })

        // Process modules
        modulesData.data?.forEach((module: any) => {
          allActivities.push({
            id: module.id,
            type: 'module',
            action: 'created',
            description: `Module created: ${module.title}`,
            timestamp: module.created_at,
          })
        })

        // Process videos
        videosData.data?.forEach((video: any) => {
          allActivities.push({
            id: video.id,
            type: 'video',
            action: 'created',
            description: `Video created: ${video.title}`,
            timestamp: video.created_at,
          })
        })

        // Sort by timestamp and take most recent 10
        allActivities.sort(
          (a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
        )
        setActivities(allActivities.slice(0, 10))
      } catch (error) {
        console.error('Failed to load activities:', error)
      } finally {
        setIsLoading(false)
      }
    }

    loadActivities()
  }, [])

  const getActivityIcon = (type: Activity['type']) => {
    switch (type) {
      case 'lead':
        return <UserPlus className="h-4 w-4 text-blue-600" />
      case 'enrollment':
        return <GraduationCap className="h-4 w-4 text-green-600" />
      case 'course':
        return <BookOpen className="h-4 w-4 text-purple-600" />
      case 'module':
        return <FileText className="h-4 w-4 text-orange-600" />
      case 'video':
        return <Video className="h-4 w-4 text-red-600" />
      default:
        return <Clock className="h-4 w-4 text-gray-600" />
    }
  }

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Recent Activity</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3">
                <div className="h-8 w-8 rounded-full bg-gray-200 animate-pulse" />
                <div className="flex-1 space-y-2">
                  <div className="h-4 w-3/4 bg-gray-200 rounded animate-pulse" />
                  <div className="h-3 w-1/2 bg-gray-200 rounded animate-pulse" />
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Recent Activity</CardTitle>
      </CardHeader>
      <CardContent>
        {activities.length === 0 ? (
          <p className="text-sm text-gray-500 text-center py-4">No recent activity</p>
        ) : (
          <div className="space-y-4">
            {activities.map((activity) => (
              <div key={activity.id} className="flex items-start gap-3">
                <div className="mt-0.5 flex-shrink-0">{getActivityIcon(activity.type)}</div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm text-gray-900">{activity.description}</p>
                  <p className="text-xs text-gray-500 mt-1">
                    {format(new Date(activity.timestamp), 'MMM dd, yyyy HH:mm')}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  )
}

