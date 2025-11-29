'use client'

import { useState, useEffect } from 'react'
import { useForm } from '@refinedev/react-hook-form'
import { useSaveContext } from '@refinedev/core'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

interface CourseFormProps {
  courseId?: string
}

export function CourseForm({ courseId }: CourseFormProps) {
  const {
    refineCore: { onFinish, formLoading },
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    watch,
  } = useForm({
    refineCoreProps: {
      resource: 'courses',
      action: courseId ? 'edit' : 'create',
      id: courseId,
    },
  })

  const category = watch('category')
  const isPopular = watch('is_popular')
  const isActive = watch('is_active')

  const onSubmit = (data: any) => {
    onFinish({
      ...data,
      is_popular: isPopular || false,
      is_active: isActive !== undefined ? isActive : true,
    })
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>{courseId ? 'Edit Course' : 'Create Course'}</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
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
              Slug *
            </label>
            <input
              {...register('slug', { required: true })}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            />
            {errors.slug && (
              <p className="mt-1 text-sm text-red-600">Slug is required</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              Category *
            </label>
            <select
              {...register('category', { required: true })}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            >
              <option value="acca">ACCA</option>
              <option value="ca">CA</option>
              <option value="cma">CMA</option>
              <option value="bcom_mba">B.Com & MBA</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              Description
            </label>
            <textarea
              {...register('description')}
              rows={4}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Duration
              </label>
              <input
                {...register('duration')}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Level
              </label>
              <input
                {...register('level')}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              Image URL
            </label>
            <input
              {...register('image_url')}
              type="url"
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              Brochure URL
            </label>
            <input
              {...register('brochure_url')}
              type="url"
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
            />
          </div>

          <div className="flex items-center gap-4">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={isPopular || false}
                onChange={(e) => setValue('is_popular', e.target.checked)}
                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="ml-2 text-sm text-gray-700">Mark as Popular</span>
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
              {formLoading ? 'Saving...' : courseId ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  )
}

