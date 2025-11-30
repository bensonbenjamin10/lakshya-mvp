'use client'

import { useState, useEffect } from 'react'
import { useForm } from '@refinedev/react-hook-form'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { RichTextEditor } from '@/components/ui/rich-text-editor'
import { ImageUpload } from '@/components/ui/image-upload'
import { useToast } from '@/lib/hooks/use-toast'
import { useAutoSave } from '@/lib/hooks/use-auto-save'
import { useRouter } from 'next/navigation'
import { Save } from 'lucide-react'

interface CourseFormProps {
  courseId?: string
}

export function CourseForm({ courseId }: CourseFormProps) {
  const toast = useToast()
  const router = useRouter()
  const [draftSaved, setDraftSaved] = useState(false)
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

  const formData = watch()
  const category = watch('category')
  const isPopular = watch('is_popular')
  const isActive = watch('is_active')
  const isFree = watch('is_free')
  const price = watch('price')
  const salePrice = watch('sale_price')
  const currency = watch('currency') || 'INR'
  const freeTrialDays = watch('free_trial_days') || 0

  // Auto-save draft (only for new courses)
  const { clearDraft, loadDraft } = useAutoSave({
    data: formData,
    key: `course_${courseId || 'new'}`,
    enabled: !courseId, // Only auto-save for new courses
  })

  // Load draft on mount
  useEffect(() => {
    if (!courseId) {
      const draft = loadDraft()
      if (draft) {
        Object.keys(draft).forEach((key) => {
          if (draft[key] !== undefined) {
            setValue(key as any, draft[key])
          }
        })
        setDraftSaved(true)
      }
    }
  }, [courseId, loadDraft, setValue])

  // Show draft saved indicator
  useEffect(() => {
    if (!courseId && Object.keys(formData).length > 0) {
      const timer = setTimeout(() => setDraftSaved(true), 2000)
      return () => clearTimeout(timer)
    }
  }, [formData, courseId])

  const onSubmit = async (data: any) => {
    try {
      await onFinish({
        ...data,
        is_popular: isPopular || false,
        is_active: isActive !== undefined ? isActive : true,
        is_free: isFree || false,
        price: isFree ? 0 : (data.price ? parseFloat(data.price) : 0),
        sale_price: isFree || !data.sale_price ? null : parseFloat(data.sale_price),
        currency: data.currency || 'INR',
        free_trial_days: data.free_trial_days ? parseInt(data.free_trial_days) : 0,
      })
      // Clear draft on successful save
      if (!courseId) {
        clearDraft()
      }
      toast.success(courseId ? 'Course updated successfully' : 'Course created successfully')
      router.push('/courses')
    } catch (error: any) {
      toast.error(error?.message || 'Failed to save course')
    }
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle>{courseId ? 'Edit Course' : 'Create Course'}</CardTitle>
          {!courseId && draftSaved && (
            <div className="flex items-center gap-2 text-sm text-gray-500">
              <Save className="h-4 w-4" />
              <span>Draft saved</span>
            </div>
          )}
        </div>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Title *
            </label>
            <Input
              {...register('title', { required: 'Title is required' })}
              error={!!errors.title}
              helperText={errors.title?.message as string}
              placeholder="Enter course title"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Slug *
            </label>
            <Input
              {...register('slug', {
                required: 'Slug is required',
                pattern: {
                  value: /^[a-z0-9-]+$/,
                  message: 'Slug must contain only lowercase letters, numbers, and hyphens',
                },
              })}
              error={!!errors.slug}
              helperText={errors.slug?.message as string}
              placeholder="course-slug"
            />
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
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <RichTextEditor
              content={watch('description') || ''}
              onChange={(content) => setValue('description', content)}
              placeholder="Enter course description"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Course Image
            </label>
            <ImageUpload
              value={watch('image_url')}
              onChange={(url) => setValue('image_url', url)}
              bucket="course-images"
              folder="courses"
              helperText="Upload a course image (max 5MB)"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Duration
              </label>
              <Input
                {...register('duration')}
                placeholder="e.g., 6 months"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Level
              </label>
              <Input
                {...register('level')}
                placeholder="e.g., Beginner, Intermediate"
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

          {/* Pricing Section */}
          <div className="border-t pt-4 mt-4">
            <h3 className="text-lg font-semibold mb-4">Pricing & Access</h3>
            
            <div className="space-y-4">
              <div className="flex items-center">
                <input
                  type="checkbox"
                  checked={isFree || false}
                  onChange={(e) => {
                    setValue('is_free', e.target.checked)
                    if (e.target.checked) {
                      setValue('price', 0)
                      setValue('sale_price', null)
                    }
                  }}
                  className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                />
                <span className="ml-2 text-sm text-gray-700">Free Course</span>
              </div>

              {!isFree && (
                <>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Price *
                      </label>
                      <Input
                        {...register('price', {
                          required: !isFree ? 'Price is required for paid courses' : false,
                          valueAsNumber: true,
                          min: { value: 0, message: 'Price must be 0 or greater' },
                        })}
                        type="number"
                        step="0.01"
                        min="0"
                        error={!!errors.price}
                        helperText={errors.price?.message as string}
                        placeholder="0.00"
                        onChange={(e) => {
                          const value = parseFloat(e.target.value) || 0
                          setValue('price', value)
                        }}
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Sale Price (Optional)
                      </label>
                      <Input
                        {...register('sale_price', {
                          valueAsNumber: true,
                          min: { value: 0, message: 'Sale price must be 0 or greater' },
                          validate: (value) => {
                            if (value && price && value >= price) {
                              return 'Sale price must be less than regular price'
                            }
                            return true
                          },
                        })}
                        type="number"
                        step="0.01"
                        min="0"
                        error={!!errors.sale_price}
                        helperText={errors.sale_price?.message as string}
                        placeholder="0.00"
                        onChange={(e) => {
                          const value = e.target.value ? parseFloat(e.target.value) : null
                          setValue('sale_price', value)
                        }}
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Currency
                    </label>
                    <select
                      {...register('currency')}
                      className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
                    >
                      <option value="INR">INR (₹)</option>
                      <option value="USD">USD ($)</option>
                      <option value="EUR">EUR (€)</option>
                      <option value="GBP">GBP (£)</option>
                    </select>
                  </div>

                  {/* Price Preview */}
                  {price && (
                    <div className="bg-blue-50 p-4 rounded-md">
                      <div className="text-sm font-medium text-gray-700 mb-2">Price Preview:</div>
                      <div className="flex items-baseline gap-2">
                        {salePrice && salePrice < price ? (
                          <>
                            <span className="text-lg line-through text-gray-500">
                              {Number(price).toLocaleString('en-IN', {
                                style: 'currency',
                                currency: currency,
                              })}
                            </span>
                            <span className="text-2xl font-bold text-green-600">
                              {Number(salePrice).toLocaleString('en-IN', {
                                style: 'currency',
                                currency: currency,
                              })}
                            </span>
                            <span className="text-sm text-gray-600">
                              (Save{' '}
                              {(
                                ((price - salePrice) / price) *
                                100
                              ).toFixed(0)}%)
                            </span>
                          </>
                        ) : (
                          <span className="text-2xl font-bold">
                            {Number(price).toLocaleString('en-IN', {
                              style: 'currency',
                              currency: currency,
                            })}
                          </span>
                        )}
                      </div>
                    </div>
                  )}
                </>
              )}

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Free Trial Days
                </label>
                <Input
                  {...register('free_trial_days', {
                    valueAsNumber: true,
                    min: { value: 0, message: 'Trial days must be 0 or greater' },
                  })}
                  type="number"
                  min="0"
                  error={!!errors.free_trial_days}
                  helperText={
                    (errors.free_trial_days?.message as string) ||
                    'Number of days students can access the course for free before payment is required'
                  }
                  placeholder="0"
                  onChange={(e) => {
                    const value = parseInt(e.target.value) || 0
                    setValue('free_trial_days', value)
                  }}
                />
              </div>
            </div>
          </div>

          {/* Status Section */}
          <div className="border-t pt-4 mt-4">
            <h3 className="text-lg font-semibold mb-4">Status & Visibility</h3>
            
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

