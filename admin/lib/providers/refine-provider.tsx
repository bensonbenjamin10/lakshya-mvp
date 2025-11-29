'use client'

import { Refine } from '@refinedev/core'
import { dataProvider, liveProvider } from '@refinedev/supabase'
import routerProvider from '@refinedev/nextjs-router/app'
import { createClient } from '@/lib/supabase/client'
import { authProvider } from './auth-provider'

export function RefineProvider({ children }: { children: React.ReactNode }) {
  const supabaseClient = createClient()

  return (
    <Refine
      routerProvider={routerProvider}
      dataProvider={dataProvider(supabaseClient)}
      liveProvider={liveProvider(supabaseClient)}
      authProvider={authProvider}
      resources={[
        {
          name: 'leads',
          list: '/leads',
          show: '/leads/:id',
          meta: {
            label: 'Leads',
          },
        },
        {
          name: 'courses',
          list: '/courses',
          create: '/courses/create',
          edit: '/courses/:id',
          meta: {
            label: 'Courses',
          },
        },
        {
          name: 'course_modules',
          list: '/modules',
          create: '/modules/create',
          edit: '/modules/:id',
          meta: {
            label: 'Modules',
          },
        },
        {
          name: 'enrollments',
          list: '/enrollments',
          show: '/enrollments/:id',
          meta: {
            label: 'Enrollments',
          },
        },
        {
          name: 'student_progress',
          list: '/progress',
          meta: {
            label: 'Student Progress',
          },
        },
        {
          name: 'video_promos',
          list: '/videos',
          create: '/videos/create',
          edit: '/videos/:id',
          meta: {
            label: 'Videos',
          },
        },
        {
          name: 'analytics',
          list: '/analytics',
          meta: {
            label: 'Analytics',
          },
        },
      ]}
    options={{
      syncWithLocation: true,
      warnWhenUnsavedChanges: true,
      projectId: 'lakshya-admin',
    }}
    queryOptions={{
      defaultOptions: {
        queries: {
          staleTime: 5 * 60 * 1000, // 5 minutes
          cacheTime: 10 * 60 * 1000, // 10 minutes
          refetchOnWindowFocus: false,
          refetchOnMount: false,
          retry: 1,
        },
      },
    }}
    >
      {children}
    </Refine>
  )
}

