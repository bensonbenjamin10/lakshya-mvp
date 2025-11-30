'use client'

import { useState, useEffect } from 'react'
import dynamic from 'next/dynamic'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import {
  Video,
  BookOpen,
  FileText,
  HelpCircle,
  Radio,
} from 'lucide-react'
import { cn } from '@/lib/utils/cn'
import type { CourseModule, ModuleType } from './types'

// Dynamic import for Markdown editor (SSR-safe)
const MDEditor = dynamic(() => import('@uiw/react-md-editor'), { ssr: false })

interface AddModuleDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  sectionId: string | null
  module?: CourseModule
  onSubmit: (data: Partial<CourseModule>) => void
}

const MODULE_TYPE_OPTIONS: {
  type: ModuleType
  label: string
  icon: typeof Video
  description: string
}[] = [
  {
    type: 'video',
    label: 'Video',
    icon: Video,
    description: 'Video lesson or lecture',
  },
  {
    type: 'reading',
    label: 'Reading',
    icon: BookOpen,
    description: 'Text content or article',
  },
  {
    type: 'assignment',
    label: 'Assignment',
    icon: FileText,
    description: 'Practice exercise or project',
  },
  {
    type: 'quiz',
    label: 'Quiz',
    icon: HelpCircle,
    description: 'Assessment or test',
  },
  {
    type: 'live_session',
    label: 'Live Session',
    icon: Radio,
    description: 'Live class or webinar',
  },
]

export function AddModuleDialog({
  open,
  onOpenChange,
  sectionId,
  module,
  onSubmit,
}: AddModuleDialogProps) {
  const [formData, setFormData] = useState<Partial<CourseModule>>({
    title: '',
    description: '',
    type: 'video',
    content_url: '',
    content_body: '',
    content_type: 'url',
    duration_minutes: undefined,
    is_required: true,
    is_free_preview: false,
    unlock_date: '',
    section_id: sectionId,
  })

  const isEditing = !!module

  // Reset form when dialog opens or module changes
  useEffect(() => {
    if (open) {
      if (module) {
        setFormData({
          title: module.title || '',
          description: module.description || '',
          type: module.type || 'video',
          content_url: module.content_url || '',
          content_body: module.content_body || '',
          content_type: module.content_type || 'url',
          duration_minutes: module.duration_minutes,
          is_required: module.is_required ?? true,
          is_free_preview: module.is_free_preview ?? false,
          unlock_date: module.unlock_date || '',
          section_id: module.section_id,
        })
      } else {
        setFormData({
          title: '',
          description: '',
          type: 'video',
          content_url: '',
          content_body: '',
          content_type: 'url',
          duration_minutes: undefined,
          is_required: true,
          is_free_preview: false,
          unlock_date: '',
          section_id: sectionId,
        })
      }
    }
  }, [open, module, sectionId])

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!formData.title?.trim()) return

    onSubmit({
      ...formData,
      section_id: sectionId,
    })
    onOpenChange(false)
  }

  const updateField = (field: keyof CourseModule, value: any) => {
    setFormData((prev) => ({ ...prev, [field]: value }))
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent
        onClose={() => onOpenChange(false)}
        className="max-w-2xl max-h-[90vh] overflow-y-auto"
      >
        <DialogHeader>
          <DialogTitle>
            {isEditing ? 'Edit Module' : 'Add Module'}
          </DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Module Type Selection */}
          {!isEditing && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Module Type
              </label>
              <div className="grid grid-cols-5 gap-2">
                {MODULE_TYPE_OPTIONS.map((option) => {
                  const Icon = option.icon
                  const isSelected = formData.type === option.type
                  return (
                    <button
                      key={option.type}
                      type="button"
                      onClick={() => {
                        updateField('type', option.type)
                        // Set default content_type for reading modules
                        if (option.type === 'reading') {
                          updateField('content_type', 'markdown')
                        } else {
                          updateField('content_type', 'url')
                        }
                      }}
                      className={cn(
                        'flex flex-col items-center gap-1 p-3 rounded-lg border-2 transition-all',
                        isSelected
                          ? 'border-blue-500 bg-blue-50'
                          : 'border-gray-200 hover:border-gray-300'
                      )}
                    >
                      <Icon
                        className={cn(
                          'h-5 w-5',
                          isSelected ? 'text-blue-600' : 'text-gray-500'
                        )}
                      />
                      <span
                        className={cn(
                          'text-xs font-medium',
                          isSelected ? 'text-blue-700' : 'text-gray-600'
                        )}
                      >
                        {option.label}
                      </span>
                    </button>
                  )
                })}
              </div>
            </div>
          )}

          {/* Title */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Title *
            </label>
            <Input
              value={formData.title}
              onChange={(e) => updateField('title', e.target.value)}
              placeholder="Enter module title"
              required
            />
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <Textarea
              value={formData.description || ''}
              onChange={(e) => updateField('description', e.target.value)}
              placeholder="Brief description of this module"
              rows={2}
            />
          </div>

          {/* Content Type (for reading modules) */}
          {formData.type === 'reading' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Content Type
              </label>
              <select
                value={formData.content_type || 'markdown'}
                onChange={(e) => updateField('content_type', e.target.value)}
                className="block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-blue-500"
              >
                <option value="markdown">Markdown (In-App Reader)</option>
                <option value="url">External URL</option>
              </select>
            </div>
          )}

          {/* Content URL (for video, quiz, assignment, live_session, or reading with URL) */}
          {(formData.type !== 'reading' || formData.content_type === 'url') && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Content URL
              </label>
              <Input
                type="url"
                value={formData.content_url || ''}
                onChange={(e) => updateField('content_url', e.target.value)}
                placeholder="https://..."
              />
            </div>
          )}

          {/* Markdown Editor (for reading modules with markdown content) */}
          {formData.type === 'reading' && formData.content_type === 'markdown' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Reading Content (Markdown)
              </label>
              <div data-color-mode="light" className="border rounded-md overflow-hidden">
                <MDEditor
                  value={formData.content_body || ''}
                  onChange={(val) => updateField('content_body', val || '')}
                  height={250}
                  preview="edit"
                />
              </div>
              <p className="mt-1 text-xs text-gray-500">
                Supports headings, lists, bold, italic, code blocks, and tables.
              </p>
            </div>
          )}

          {/* Duration */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Duration (minutes)
              </label>
              <Input
                type="number"
                min="0"
                value={formData.duration_minutes || ''}
                onChange={(e) =>
                  updateField(
                    'duration_minutes',
                    e.target.value ? parseInt(e.target.value) : undefined
                  )
                }
                placeholder="e.g., 30"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Unlock Date (optional)
              </label>
              <Input
                type="datetime-local"
                value={formData.unlock_date || ''}
                onChange={(e) => updateField('unlock_date', e.target.value)}
              />
            </div>
          </div>

          {/* Toggles */}
          <div className="flex items-center gap-6">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={formData.is_required ?? true}
                onChange={(e) => updateField('is_required', e.target.checked)}
                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="ml-2 text-sm text-gray-700">Required Module</span>
            </label>
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={formData.is_free_preview ?? false}
                onChange={(e) => updateField('is_free_preview', e.target.checked)}
                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="ml-2 text-sm text-gray-700">Free Preview</span>
            </label>
          </div>

          <DialogFooter className="gap-2 pt-4">
            <Button
              type="button"
              variant="outline"
              onClick={() => onOpenChange(false)}
            >
              Cancel
            </Button>
            <Button type="submit" disabled={!formData.title?.trim()}>
              {isEditing ? 'Update Module' : 'Add Module'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}

