'use client'

import { useState, useEffect, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { useForm } from '@refinedev/react-hook-form'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { RichTextEditor } from '@/components/ui/rich-text-editor'
import { ImageUpload } from '@/components/ui/image-upload'
import { CurriculumBuilder } from './curriculum-builder'
import { useToast } from '@/lib/hooks/use-toast'
import { useAutoSave } from '@/lib/hooks/use-auto-save'
import { createClient } from '@/lib/supabase/client'
import { Save, ArrowLeft, Eye, EyeOff } from 'lucide-react'
import type { Course, CourseSection, CourseModule, CurriculumData } from './types'

interface CourseBuilderProps {
  courseId?: string
}

export function CourseBuilder({ courseId }: CourseBuilderProps) {
  const toast = useToast()
  const router = useRouter()
  const supabase = createClient()
  const [draftSaved, setDraftSaved] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  const [curriculumData, setCurriculumData] = useState<CurriculumData>({
    sections: [],
    modules: [],
  })
  const [curriculumLoaded, setCurriculumLoaded] = useState(false)

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
    key: `course_builder_${courseId || 'new'}`,
    enabled: !courseId,
  })

  // Load draft on mount for new courses
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

  // Load curriculum data for existing courses
  useEffect(() => {
    const loadCurriculum = async () => {
      if (!courseId) {
        setCurriculumLoaded(true)
        return
      }

      try {
        // Load sections
        const { data: sections, error: sectionsError } = await supabase
          .from('course_sections')
          .select('*')
          .eq('course_id', courseId)
          .order('display_order')

        if (sectionsError) throw sectionsError

        // Load modules
        const { data: modules, error: modulesError } = await supabase
          .from('course_modules')
          .select('*')
          .eq('course_id', courseId)
          .order('display_order')

        if (modulesError) throw modulesError

        setCurriculumData({
          sections: sections || [],
          modules: modules || [],
        })
        setCurriculumLoaded(true)
      } catch (error: any) {
        toast.error('Failed to load curriculum: ' + error.message)
        setCurriculumLoaded(true)
      }
    }

    loadCurriculum()
  }, [courseId, supabase, toast])

  // Show draft saved indicator
  useEffect(() => {
    if (!courseId && Object.keys(formData).length > 0) {
      const timer = setTimeout(() => setDraftSaved(true), 2000)
      return () => clearTimeout(timer)
    }
  }, [formData, courseId])

  // Handle curriculum changes
  const handleCurriculumChange = useCallback((data: CurriculumData) => {
    setCurriculumData(data)
  }, [])

  // Save course and curriculum
  const onSubmit = async (data: any) => {
    setIsSaving(true)
    try {
      // Save course first
      const courseData = {
        ...data,
        is_popular: isPopular || false,
        is_active: isActive !== undefined ? isActive : true,
        is_free: isFree || false,
        price: isFree ? 0 : data.price ? parseFloat(data.price) : 0,
        sale_price: isFree || !data.sale_price ? null : parseFloat(data.sale_price),
        currency: data.currency || 'INR',
        free_trial_days: data.free_trial_days ? parseInt(data.free_trial_days) : 0,
      }

      const result = await onFinish(courseData)
      const savedCourseId = courseId || (result?.data as any)?.id

      if (savedCourseId) {
        // Save sections
        for (const section of curriculumData.sections) {
          if (section.id.startsWith('temp_')) {
            // New section
            const { error } = await supabase.from('course_sections').insert({
              course_id: savedCourseId,
              title: section.title,
              description: section.description,
              display_order: section.display_order,
            })
            if (error) throw error
          } else {
            // Update existing section
            const { error } = await supabase
              .from('course_sections')
              .update({
                title: section.title,
                description: section.description,
                display_order: section.display_order,
              })
              .eq('id', section.id)
            if (error) throw error
          }
        }

        // Save modules
        for (const module of curriculumData.modules) {
          const moduleData = {
            course_id: savedCourseId,
            section_id: module.section_id?.startsWith('temp_') ? null : module.section_id,
            module_number: module.module_number,
            title: module.title,
            description: module.description,
            type: module.type,
            content_url: module.content_url,
            content_body: module.content_body,
            content_type: module.content_type,
            duration_minutes: module.duration_minutes,
            is_required: module.is_required,
            is_free_preview: module.is_free_preview,
            unlock_date: module.unlock_date,
            display_order: module.display_order,
          }

          if (module.id.startsWith('temp_')) {
            const { error } = await supabase.from('course_modules').insert(moduleData)
            if (error) throw error
          } else {
            const { error } = await supabase
              .from('course_modules')
              .update(moduleData)
              .eq('id', module.id)
            if (error) throw error
          }
        }
      }

      // Clear draft on successful save
      if (!courseId) {
        clearDraft()
      }

      toast.success(courseId ? 'Course updated successfully' : 'Course created successfully')
      router.push('/courses')
    } catch (error: any) {
      toast.error(error?.message || 'Failed to save course')
    } finally {
      setIsSaving(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="sticky top-0 z-40 bg-white border-b border-gray-200 px-6 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => router.push('/courses')}
            >
              <ArrowLeft className="h-4 w-4 mr-2" />
              Back
            </Button>
            <div>
              <h1 className="text-xl font-bold">
                {courseId ? 'Edit Course' : 'Create Course'}
              </h1>
              {!courseId && draftSaved && (
                <div className="flex items-center gap-2 text-sm text-gray-500">
                  <Save className="h-3 w-3" />
                  <span>Draft auto-saved</span>
                </div>
              )}
            </div>
          </div>
          <div className="flex items-center gap-3">
            <Button type="button" variant="outline" onClick={() => router.push('/courses')}>
              Cancel
            </Button>
            <Button
              type="submit"
              form="course-form"
              disabled={formLoading || isSaving}
            >
              {isSaving ? 'Saving...' : courseId ? 'Update Course' : 'Create Course'}
            </Button>
          </div>
        </div>
      </div>

      {/* Main Content - Split View */}
      <form id="course-form" onSubmit={handleSubmit(onSubmit)}>
        <div className="flex">
          {/* Left Panel - Course Details (40%) */}
          <div className="w-2/5 border-r border-gray-200 bg-white min-h-[calc(100vh-73px)] overflow-y-auto">
            <div className="p-6 space-y-6">
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">Basic Information</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
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
                          message: 'Lowercase letters, numbers, hyphens only',
                        },
                      })}
                      error={!!errors.slug}
                      helperText={errors.slug?.message as string}
                      placeholder="course-slug"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Category *
                    </label>
                    <select
                      {...register('category', { required: true })}
                      className="block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
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
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">Media</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
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

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Brochure URL
                    </label>
                    <Input
                      {...register('brochure_url')}
                      type="url"
                      placeholder="https://..."
                    />
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">Course Details</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
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
                        placeholder="e.g., Beginner"
                      />
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">Pricing & Access</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
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
                              required: !isFree ? 'Price is required' : false,
                              valueAsNumber: true,
                              min: { value: 0, message: 'Price must be 0 or greater' },
                            })}
                            type="number"
                            step="0.01"
                            min="0"
                            error={!!errors.price}
                            helperText={errors.price?.message as string}
                            placeholder="0.00"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Sale Price
                          </label>
                          <Input
                            {...register('sale_price', {
                              valueAsNumber: true,
                              min: { value: 0, message: 'Must be 0 or greater' },
                            })}
                            type="number"
                            step="0.01"
                            min="0"
                            error={!!errors.sale_price}
                            helperText={errors.sale_price?.message as string}
                            placeholder="0.00"
                          />
                        </div>
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Currency
                        </label>
                        <select
                          {...register('currency')}
                          className="block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
                        >
                          <option value="INR">INR (₹)</option>
                          <option value="USD">USD ($)</option>
                          <option value="EUR">EUR (€)</option>
                          <option value="GBP">GBP (£)</option>
                        </select>
                      </div>

                      {price && (
                        <div className="bg-blue-50 p-3 rounded-md">
                          <div className="text-xs font-medium text-gray-600 mb-1">Preview:</div>
                          <div className="flex items-baseline gap-2">
                            {salePrice && salePrice < price ? (
                              <>
                                <span className="text-sm line-through text-gray-500">
                                  {Number(price).toLocaleString('en-IN', {
                                    style: 'currency',
                                    currency: currency,
                                  })}
                                </span>
                                <span className="text-lg font-bold text-green-600">
                                  {Number(salePrice).toLocaleString('en-IN', {
                                    style: 'currency',
                                    currency: currency,
                                  })}
                                </span>
                              </>
                            ) : (
                              <span className="text-lg font-bold">
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
                        min: { value: 0, message: 'Must be 0 or greater' },
                      })}
                      type="number"
                      min="0"
                      placeholder="0"
                    />
                    <p className="mt-1 text-xs text-gray-500">
                      Days students can access for free before payment
                    </p>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">Status & Visibility</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center gap-6">
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
                      <span className="ml-2 text-sm text-gray-700 flex items-center gap-1">
                        {isActive ? <Eye className="h-4 w-4" /> : <EyeOff className="h-4 w-4" />}
                        Active
                      </span>
                    </label>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>

          {/* Right Panel - Curriculum Builder (60%) */}
          <div className="w-3/5 bg-gray-50 min-h-[calc(100vh-73px)] overflow-y-auto">
            <div className="p-6">
              <CurriculumBuilder
                courseId={courseId}
                data={curriculumData}
                onChange={handleCurriculumChange}
                isLoading={!curriculumLoaded}
              />
            </div>
          </div>
        </div>
      </form>
    </div>
  )
}

