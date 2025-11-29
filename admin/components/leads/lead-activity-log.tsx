'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { format } from 'date-fns'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Database } from '@/lib/types/database.types'

type LeadActivity = Database['public']['Tables']['lead_activities']['Row']
type Profile = Database['public']['Tables']['profiles']['Row']

interface LeadActivityLogProps {
  leadId: string
}

export function LeadActivityLog({ leadId }: LeadActivityLogProps) {
  const [activities, setActivities] = useState<LeadActivity[]>([])
  const [profiles, setProfiles] = useState<Map<string, Profile>>(new Map())
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const supabase = createClient()

    const loadActivities = async () => {
      const { data: activitiesData, error: activitiesError } = await supabase
        .from('lead_activities')
        .select('*')
        .eq('lead_id', leadId)
        .order('created_at', { ascending: false })

      if (activitiesError) {
        console.error('Error loading activities:', activitiesError)
        setIsLoading(false)
        return
      }

      if (activitiesData) {
        setActivities(activitiesData as LeadActivity[])

        // Load profile names for created_by
        const userIds = activitiesData
          .map((a) => a.created_by)
          .filter((id): id is string => id !== null)

        if (userIds.length > 0) {
          const { data: profilesData } = await supabase
            .from('profiles')
            .select('*')
            .in('id', userIds)

          if (profilesData) {
            const profilesMap = new Map<string, Profile>()
            profilesData.forEach((profile) => {
              profilesMap.set(profile.id, profile as Profile)
            })
            setProfiles(profilesMap)
          }
        }
      }

      setIsLoading(false)
    }

    loadActivities()
  }, [leadId])

  const getActivityIcon = (activityType: string) => {
    switch (activityType) {
      case 'status_change':
        return '🔄'
      case 'assignment':
        return '👤'
      case 'notes_update':
        return '📝'
      case 'created':
        return '✨'
      default:
        return '📌'
    }
  }

  const getActivityColor = (activityType: string) => {
    switch (activityType) {
      case 'status_change':
        return 'bg-blue-50 border-blue-200'
      case 'assignment':
        return 'bg-purple-50 border-purple-200'
      case 'notes_update':
        return 'bg-yellow-50 border-yellow-200'
      case 'created':
        return 'bg-green-50 border-green-200'
      default:
        return 'bg-gray-50 border-gray-200'
    }
  }

  const getCreatedByName = (userId: string | null) => {
    if (!userId) return 'System'
    const profile = profiles.get(userId)
    return profile?.full_name || profile?.email || 'Unknown'
  }

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Activity Log</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center py-4 text-gray-500">Loading activities...</div>
        </CardContent>
      </Card>
    )
  }

  if (activities.length === 0) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Activity Log</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center py-4 text-gray-500">No activities yet</div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Activity Log</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {activities.map((activity) => (
            <div
              key={activity.id}
              className={`p-4 rounded-lg border ${getActivityColor(activity.activity_type)}`}
            >
              <div className="flex items-start gap-3">
                <div className="text-2xl">{getActivityIcon(activity.activity_type)}</div>
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <p className="font-medium text-sm">{activity.description || activity.activity_type}</p>
                    <span className="text-xs text-gray-500">
                      {format(new Date(activity.created_at), 'MMM dd, yyyy HH:mm')}
                    </span>
                  </div>
                  {activity.old_value && activity.new_value && (
                    <div className="mt-2 text-xs text-gray-600">
                      <span className="line-through">{activity.old_value}</span>
                      {' → '}
                      <span className="font-medium">{activity.new_value}</span>
                    </div>
                  )}
                  {activity.created_by && (
                    <div className="mt-1 text-xs text-gray-500">
                      by {getCreatedByName(activity.created_by)}
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}

