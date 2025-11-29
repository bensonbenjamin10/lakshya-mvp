'use client'

import { useForm } from '@refinedev/react-hook-form'
import { useList } from '@refinedev/core'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

interface VideoFormProps {
  videoId?: string
}

export function VideoForm({ videoId }: VideoFormProps) {
  const { data: coursesData } = useList({
    resource: 'courses',
  })
  const courses = coursesData?.data || []

  const {
    refineCore: { onFinish, formLoading },
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    watch,
  } = useForm({
    refineCoreProps: {
      resource: 'video_promos',
      action: videoId ? 'edit' : 'create',
      id: videoId,
    },
  })

  const type = watch('type')
  const isFeatured = watch('is_featured')
  const isActive = watch('is_active')

  const onSubmit = (data: any) => {
    onFinish({
      ...data,
      is_featured: isFeatured || false,
      is_active: isActive !== undefined ? isActive : true,
      display_order: data.display_order || 0,
    })
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>{videoId ? 'Edit Video' : 'Create Video'}</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">
              Vimeo ID *
            </label>
            <input
              {...register('vimeo_id', { required: true })}
              placeholder="123456789"
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            />
            {errors.vimeo_id && (
              <p className="mt-1 text-sm text-red-600">Vimeo ID is required</p>
            )}
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
              Subtitle
            </label>
            <input
              {...register('subtitle')}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              Type *
            </label>
            <select
              {...register('type', { required: true })}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            >
              <option value="welcome">Welcome</option>
              <option value="promo">Promo</option>
              <option value="course_preview">Course Preview</option>
              <option value="testimonial">Testimonial</option>
              <option value="faculty">Faculty</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              Course (Optional)
            </label>
            <select
              {...register('course_id')}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            >
              <option value="">None</option>
              {courses.map((course: any) => (
                <option key={course.id} value={course.id}>
                  {course.title}
                </option>
              ))}
            </select>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Thumbnail URL
              </label>
              <input
                {...register('thumbnail_url')}
                type="url"
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Duration
              </label>
              <input
                {...register('duration')}
                placeholder="2:30"
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              Display Order
            </label>
            <input
              {...register('display_order')}
              type="number"
              defaultValue={0}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            />
          </div>

          <div className="flex items-center gap-4">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={isFeatured || false}
                onChange={(e) => setValue('is_featured', e.target.checked)}
                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="ml-2 text-sm text-gray-700">Featured Video</span>
            </label>
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={isActive !== undefined ? isActive : true}
                onChange={(e) => setValue('is_active', e.target.checked)}
                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="ml-2 text-sm text-gray-700">Active</span>
            </label>
          </div>

          <div className="flex justify-end gap-4">
            <Button type="button" variant="outline" onClick={() => window.history.back()}>
              Cancel
            </Button>
            <Button type="submit" disabled={formLoading}>
              {formLoading ? 'Saving...' : videoId ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  )
}

