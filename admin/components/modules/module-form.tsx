'use client'

import { useState, useEffect } from 'react'
import { useForm } from '@refinedev/react-hook-form'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { createClient } from '@/lib/supabase/client'
import { useToast } from '@/lib/hooks/use-toast'
import { useRouter } from 'next/navigation'

interface ModuleFormProps {
  moduleId?: string
}

export function ModuleForm({ moduleId }: ModuleFormProps) {
  const toast = useToast()
  const router = useRouter()
  const [courses, setCourses] = useState<any[]>([])
  const supabase = createClient()

  useEffect(() => {
    supabase
      .from('courses')
      .select('id, title')
      .order('title')
      .then(({ data }) => {
        if (data) setCourses(data)
      })
  }, [])

  const {
    refineCore: { onFinish, formLoading },
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    watch,
  } = useForm({
    refineCoreProps: {
      resource: 'course_modules',
      action: moduleId ? 'edit' : 'create',
      id: moduleId,
    },
  })

  const courseId = watch('course_id')
  const type = watch('type')
  const isRequired = watch('is_required')
  const unlockDate = watch('unlock_date')

  const onSubmit = async (data: any) => {
    try {
      const submitData: any = {
        ...data,
        module_number: parseInt(data.module_number) || 1,
        duration_minutes: data.duration_minutes ? parseInt(data.duration_minutes) : null,
        display_order: data.display_order ? parseInt(data.display_order) : 0,
        is_required: isRequired !== undefined ? isRequired : true,
        unlock_date: unlockDate || null,
      }

      await onFinish(submitData)
      toast.success(moduleId ? 'Module updated successfully' : 'Module created successfully')
      router.push('/modules')
    } catch (error: any) {
      toast.error(error?.message || 'Failed to save module')
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>{moduleId ? 'Edit Module' : 'Create Module'}</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">
              Course *</label>
            <select
              {...register('course_id', { required: true })}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            >
              <option value="">Select a course</option>
              {courses.map((course) => (
                <option key={course.id} value={course.id}>
                  {course.title}
                </option>
              ))}
            </select>
            {errors.course_id && (
              <p className="mt-1 text-sm text-red-600">Course is required</p>
            )}
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Module Number *
              </label>
              <input
                type="number"
                {...register('module_number', { required: true, valueAsNumber: true })}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
              />
              {errors.module_number && (
                <p className="mt-1 text-sm text-red-600">Module number is required</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">
                Display Order
              </label>
              <input
                type="number"
                {...register('display_order', { valueAsNumber: true })}
                defaultValue={0}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              Title *
            </label>
            <input
              {...register('title', { required: true })}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            />
            {errors.title && (
              <p className="mt-1 text-sm text-red-600">Title is required</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              Description
            </label>
            <textarea
              {...register('description')}
              rows={3}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Type *
              </label>
              <select
                {...register('type', { required: true })}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
              >
                <option value="video">Video</option>
                <option value="reading">Reading</option>
                <option value="assignment">Assignment</option>
                <option value="quiz">Quiz</option>
                <option value="live_session">Live Session</option>
              </select>
              {errors.type && (
                <p className="mt-1 text-sm text-red-600">Type is required</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">
                Duration (minutes)
              </label>
              <input
                type="number"
                {...register('duration_minutes', { valueAsNumber: true })}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              Content URL
            </label>
            <input
              type="url"
              {...register('content_url')}
              placeholder="https://example.com/video"
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  {...register('is_required')}
                  defaultChecked={true}
                  className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                />
                <span className="ml-2 text-sm text-gray-700">Required Module</span>
              </label>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">
                Unlock Date (optional)
              </label>
              <input
                type="datetime-local"
                {...register('unlock_date')}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
              />
            </div>
          </div>

          <div className="flex justify-end space-x-4">
            <Button
              type="button"
              variant="outline"
              onClick={() => window.history.back()}
            >
              Cancel
            </Button>
            <Button type="submit" disabled={formLoading}>
              {formLoading ? 'Saving...' : moduleId ? 'Update Module' : 'Create Module'}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  )
}

