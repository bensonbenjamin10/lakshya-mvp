'use client'

import { useState, useRef, useEffect } from 'react'
import { useSortable } from '@dnd-kit/sortable'
import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'
import { Card, CardContent, CardHeader } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { ModuleCard } from './module-card'
import {
  ChevronDown,
  ChevronRight,
  GripVertical,
  Plus,
  Trash2,
  Edit2,
  Check,
  X,
} from 'lucide-react'
import { cn } from '@/lib/utils/cn'
import type { CourseSection, CourseModule } from './types'

interface SectionCardProps {
  section: CourseSection
  modules: CourseModule[]
  isExpanded: boolean
  onToggleExpanded: () => void
  onUpdate: (updates: Partial<CourseSection>) => void
  onDelete: () => void
  onAddModule: () => void
  onEditModule: (module: CourseModule) => void
  onDeleteModule: (moduleId: string) => void
  onDuplicateModule: (moduleId: string) => void
}

export function SectionCard({
  section,
  modules,
  isExpanded,
  onToggleExpanded,
  onUpdate,
  onDelete,
  onAddModule,
  onEditModule,
  onDeleteModule,
  onDuplicateModule,
}: SectionCardProps) {
  const [isEditing, setIsEditing] = useState(false)
  const [editTitle, setEditTitle] = useState(section.title)
  const inputRef = useRef<HTMLInputElement>(null)

  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: section.id })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  }

  // Focus input when editing starts
  useEffect(() => {
    if (isEditing && inputRef.current) {
      inputRef.current.focus()
      inputRef.current.select()
    }
  }, [isEditing])

  const handleSaveTitle = () => {
    if (editTitle.trim()) {
      onUpdate({ title: editTitle.trim() })
    } else {
      setEditTitle(section.title)
    }
    setIsEditing(false)
  }

  const handleCancelEdit = () => {
    setEditTitle(section.title)
    setIsEditing(false)
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSaveTitle()
    } else if (e.key === 'Escape') {
      handleCancelEdit()
    }
  }

  const handleDeleteClick = () => {
    if (confirm(`Delete section "${section.title}"? Modules will be moved to ungrouped.`)) {
      onDelete()
    }
  }

  return (
    <Card
      ref={setNodeRef}
      style={style}
      className={cn(
        'transition-all duration-200',
        isDragging && 'opacity-50 shadow-lg ring-2 ring-blue-500'
      )}
    >
      <CardHeader className="py-3 px-4">
        <div className="flex items-center gap-2">
          {/* Drag Handle */}
          <button
            {...attributes}
            {...listeners}
            className="cursor-grab active:cursor-grabbing p-1 hover:bg-gray-100 rounded"
          >
            <GripVertical className="h-4 w-4 text-gray-400" />
          </button>

          {/* Expand/Collapse Toggle */}
          <button
            onClick={onToggleExpanded}
            className="p-1 hover:bg-gray-100 rounded"
          >
            {isExpanded ? (
              <ChevronDown className="h-4 w-4 text-gray-500" />
            ) : (
              <ChevronRight className="h-4 w-4 text-gray-500" />
            )}
          </button>

          {/* Section Title */}
          <div className="flex-1 min-w-0">
            {isEditing ? (
              <div className="flex items-center gap-2">
                <input
                  ref={inputRef}
                  type="text"
                  value={editTitle}
                  onChange={(e) => setEditTitle(e.target.value)}
                  onKeyDown={handleKeyDown}
                  onBlur={handleSaveTitle}
                  className="flex-1 px-2 py-1 text-sm font-medium border border-blue-500 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
                <button
                  onClick={handleSaveTitle}
                  className="p-1 text-green-600 hover:bg-green-50 rounded"
                >
                  <Check className="h-4 w-4" />
                </button>
                <button
                  onClick={handleCancelEdit}
                  className="p-1 text-gray-500 hover:bg-gray-100 rounded"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>
            ) : (
              <div className="flex items-center gap-2">
                <span
                  className="font-medium text-gray-900 truncate cursor-pointer hover:text-blue-600"
                  onDoubleClick={() => setIsEditing(true)}
                >
                  {section.title}
                </span>
                <span className="text-xs text-gray-500">
                  ({modules.length} {modules.length === 1 ? 'module' : 'modules'})
                </span>
              </div>
            )}
          </div>

          {/* Actions */}
          {!isEditing && (
            <div className="flex items-center gap-1">
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setIsEditing(true)}
                className="h-8 w-8 p-0"
              >
                <Edit2 className="h-4 w-4 text-gray-500" />
              </Button>
              <Button
                variant="ghost"
                size="sm"
                onClick={onAddModule}
                className="h-8 w-8 p-0"
              >
                <Plus className="h-4 w-4 text-gray-500" />
              </Button>
              <Button
                variant="ghost"
                size="sm"
                onClick={handleDeleteClick}
                className="h-8 w-8 p-0 hover:bg-red-50"
              >
                <Trash2 className="h-4 w-4 text-red-500" />
              </Button>
            </div>
          )}
        </div>
      </CardHeader>

      {/* Modules List */}
      {isExpanded && (
        <CardContent className="pt-0 pb-3 px-4">
          {modules.length > 0 ? (
            <SortableContext
              items={modules.map((m) => m.id)}
              strategy={verticalListSortingStrategy}
            >
              <div className="space-y-2 pl-8">
                {modules.map((module) => (
                  <ModuleCard
                    key={module.id}
                    module={module}
                    onEdit={() => onEditModule(module)}
                    onDelete={() => onDeleteModule(module.id)}
                    onDuplicate={() => onDuplicateModule(module.id)}
                  />
                ))}
              </div>
            </SortableContext>
          ) : (
            <div className="pl-8 py-4 text-center">
              <p className="text-sm text-gray-500 mb-2">
                This section is empty
              </p>
              <Button variant="outline" size="sm" onClick={onAddModule}>
                <Plus className="h-4 w-4 mr-1" />
                Add Module
              </Button>
            </div>
          )}
        </CardContent>
      )}
    </Card>
  )
}

