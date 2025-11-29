'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { useRouter } from 'next/navigation'
import {
  Plus,
  BookOpen,
  FileText,
  UserPlus,
  GraduationCap,
  AlertCircle,
} from 'lucide-react'
import { createClient } from '@/lib/supabase/client'
import { useEffect, useState } from 'react'

export function QuickActions() {
  const router = useRouter()
  const [pendingEnrollments, setPendingEnrollments] = useState(0)
  const supabase = createClient()

  useEffect(() => {
    const loadPendingEnrollments = async () => {
      const { count } = await supabase
        .from('enrollments')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'pending')

      setPendingEnrollments(count || 0)
    }

    loadPendingEnrollments()
  }, [])

  const actions = [
    {
      label: 'Create Course',
      icon: BookOpen,
      onClick: () => router.push('/courses/create'),
      color: 'bg-blue-50 hover:bg-blue-100 text-blue-700',
    },
    {
      label: 'Create Module',
      icon: FileText,
      onClick: () => router.push('/modules/create'),
      color: 'bg-purple-50 hover:bg-purple-100 text-purple-700',
    },
    {
      label: 'Add Lead',
      icon: UserPlus,
      onClick: () => router.push('/leads'),
      color: 'bg-green-50 hover:bg-green-100 text-green-700',
    },
    {
      label: 'Pending Enrollments',
      icon: GraduationCap,
      onClick: () => router.push('/enrollments?status=pending'),
      color: 'bg-orange-50 hover:bg-orange-100 text-orange-700',
      badge: pendingEnrollments > 0 ? pendingEnrollments : undefined,
    },
  ]

  return (
    <Card>
      <CardHeader>
        <CardTitle>Quick Actions</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-2 gap-3">
          {actions.map((action) => (
            <Button
              key={action.label}
              variant="outline"
              className={`${action.color} flex flex-col items-center gap-2 h-auto py-4 relative`}
              onClick={action.onClick}
            >
              <action.icon className="h-5 w-5" />
              <span className="text-sm font-medium">{action.label}</span>
              {action.badge && (
                <span className="absolute top-2 right-2 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-xs font-semibold text-white">
                  {action.badge}
                </span>
              )}
            </Button>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}

