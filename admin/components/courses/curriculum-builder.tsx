'use client'

import { useState, useCallback } from 'react'
import {
  DndContext,
  DragOverlay,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragStartEvent,
  DragEndEvent,
  DragOverEvent,
} from '@dnd-kit/core'
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { SectionCard } from './section-card'
import { ModuleCard } from './module-card'
import { AddModuleDialog } from './add-module-dialog'
import { Plus, Loader2, FolderPlus } from 'lucide-react'
import type { CourseSection, CourseModule, CurriculumData } from './types'

interface CurriculumBuilderProps {
  courseId?: string
  data: CurriculumData
  onChange: (data: CurriculumData) => void
  isLoading?: boolean
}

export function CurriculumBuilder({
  courseId,
  data,
  onChange,
  isLoading = false,
}: CurriculumBuilderProps) {
  const [activeId, setActiveId] = useState<string | null>(null)
  const [activeType, setActiveType] = useState<'section' | 'module' | null>(null)
  const [editingModule, setEditingModule] = useState<CourseModule | null>(null)
  const [addModuleDialog, setAddModuleDialog] = useState<{ open: boolean; sectionId: string | null }>({ open: false, sectionId: null })
  const [expandedSections, setExpandedSections] = useState<Set<string>>(new Set())

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  )

  // Get modules for a specific section (or ungrouped)
  const getModulesForSection = useCallback(
    (sectionId: string | null) => {
      return data.modules
        .filter((m) => m.section_id === sectionId)
        .sort((a, b) => a.display_order - b.display_order)
    },
    [data.modules]
  )

  // Get ungrouped modules (modules without a section)
  const ungroupedModules = getModulesForSection(null)

  // Add new section
  const handleAddSection = useCallback(() => {
    const newSection: CourseSection = {
      id: `temp_${Date.now()}`,
      course_id: courseId || '',
      title: 'New Section',
      display_order: data.sections.length,
    }
    const newSections = [...data.sections, newSection]
    onChange({ ...data, sections: newSections })
    setExpandedSections((prev) => new Set([...prev, newSection.id]))
  }, [data, courseId, onChange])

  // Update section
  const handleUpdateSection = useCallback(
    (sectionId: string, updates: Partial<CourseSection>) => {
      const newSections = data.sections.map((s) =>
        s.id === sectionId ? { ...s, ...updates } : s
      )
      onChange({ ...data, sections: newSections })
    },
    [data, onChange]
  )

  // Delete section
  const handleDeleteSection = useCallback(
    (sectionId: string) => {
      // Move all modules in this section to ungrouped
      const newModules = data.modules.map((m) =>
        m.section_id === sectionId ? { ...m, section_id: null } : m
      )
      const newSections = data.sections.filter((s) => s.id !== sectionId)
      // Re-order remaining sections
      const reorderedSections = newSections.map((s, index) => ({
        ...s,
        display_order: index,
      }))
      onChange({ sections: reorderedSections, modules: newModules })
    },
    [data, onChange]
  )

  // Add new module
  const handleAddModule = useCallback(
    (moduleData: Partial<CourseModule>) => {
      const sectionModules = getModulesForSection(moduleData.section_id || null)
      const newModule: CourseModule = {
        id: `temp_${Date.now()}`,
        course_id: courseId || '',
        section_id: moduleData.section_id || null,
        module_number: data.modules.length + 1,
        title: moduleData.title || 'New Module',
        description: moduleData.description,
        type: moduleData.type || 'video',
        content_url: moduleData.content_url,
        content_body: moduleData.content_body,
        content_type: moduleData.content_type,
        duration_minutes: moduleData.duration_minutes,
        is_required: moduleData.is_required ?? true,
        is_free_preview: moduleData.is_free_preview ?? false,
        unlock_date: moduleData.unlock_date,
        display_order: sectionModules.length,
      }
      onChange({ ...data, modules: [...data.modules, newModule] })
      setAddModuleDialog({ open: false, sectionId: null })
    },
    [data, courseId, getModulesForSection, onChange]
  )

  // Update module
  const handleUpdateModule = useCallback(
    (moduleId: string, updates: Partial<CourseModule>) => {
      const newModules = data.modules.map((m) =>
        m.id === moduleId ? { ...m, ...updates } : m
      )
      onChange({ ...data, modules: newModules })
      setEditingModule(null)
    },
    [data, onChange]
  )

  // Delete module
  const handleDeleteModule = useCallback(
    (moduleId: string) => {
      const newModules = data.modules.filter((m) => m.id !== moduleId)
      // Re-number modules
      const renumberedModules = newModules.map((m, index) => ({
        ...m,
        module_number: index + 1,
      }))
      onChange({ ...data, modules: renumberedModules })
    },
    [data, onChange]
  )

  // Duplicate module
  const handleDuplicateModule = useCallback(
    (moduleId: string) => {
      const module = data.modules.find((m) => m.id === moduleId)
      if (!module) return

      const newModule: CourseModule = {
        ...module,
        id: `temp_${Date.now()}`,
        title: `${module.title} (Copy)`,
        module_number: data.modules.length + 1,
        display_order: module.display_order + 1,
      }

      // Insert after original and reorder
      const insertIndex = data.modules.findIndex((m) => m.id === moduleId) + 1
      const newModules = [
        ...data.modules.slice(0, insertIndex),
        newModule,
        ...data.modules.slice(insertIndex),
      ]

      // Update display orders for modules in the same section
      const reorderedModules = newModules.map((m, index) => ({
        ...m,
        module_number: index + 1,
      }))

      onChange({ ...data, modules: reorderedModules })
    },
    [data, onChange]
  )

  // Toggle section expansion
  const toggleSectionExpanded = useCallback((sectionId: string) => {
    setExpandedSections((prev) => {
      const newSet = new Set(prev)
      if (newSet.has(sectionId)) {
        newSet.delete(sectionId)
      } else {
        newSet.add(sectionId)
      }
      return newSet
    })
  }, [])

  // Drag handlers
  const handleDragStart = (event: DragStartEvent) => {
    const { active } = event
    setActiveId(active.id as string)

    // Determine if dragging section or module
    if (data.sections.find((s) => s.id === active.id)) {
      setActiveType('section')
    } else {
      setActiveType('module')
    }
  }

  const handleDragOver = (event: DragOverEvent) => {
    const { active, over } = event
    if (!over) return

    const activeId = active.id as string
    const overId = over.id as string

    // If dragging a module over a different section
    if (activeType === 'module') {
      const activeModule = data.modules.find((m) => m.id === activeId)
      const overSection = data.sections.find((s) => s.id === overId)

      if (activeModule && overSection && activeModule.section_id !== overId) {
        // Move module to new section
        const newModules = data.modules.map((m) =>
          m.id === activeId ? { ...m, section_id: overId } : m
        )
        onChange({ ...data, modules: newModules })
      }
    }
  }

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event

    setActiveId(null)
    setActiveType(null)

    if (!over) return

    const activeId = active.id as string
    const overId = over.id as string

    if (activeId === overId) return

    if (activeType === 'section') {
      // Reorder sections
      const oldIndex = data.sections.findIndex((s) => s.id === activeId)
      const newIndex = data.sections.findIndex((s) => s.id === overId)

      if (oldIndex !== -1 && newIndex !== -1) {
        const newSections = arrayMove(data.sections, oldIndex, newIndex).map(
          (s, index) => ({ ...s, display_order: index })
        )
        onChange({ ...data, sections: newSections })
      }
    } else if (activeType === 'module') {
      // Reorder modules within same section
      const activeModule = data.modules.find((m) => m.id === activeId)
      const overModule = data.modules.find((m) => m.id === overId)

      if (activeModule && overModule && activeModule.section_id === overModule.section_id) {
        const sectionModules = getModulesForSection(activeModule.section_id)
        const oldIndex = sectionModules.findIndex((m) => m.id === activeId)
        const newIndex = sectionModules.findIndex((m) => m.id === overId)

        if (oldIndex !== -1 && newIndex !== -1) {
          const reorderedSection = arrayMove(sectionModules, oldIndex, newIndex).map(
            (m, index) => ({ ...m, display_order: index })
          )

          const otherModules = data.modules.filter(
            (m) => m.section_id !== activeModule.section_id
          )
          onChange({ ...data, modules: [...otherModules, ...reorderedSection] })
        }
      }
    }
  }

  // Get active item for drag overlay
  const getActiveItem = () => {
    if (!activeId) return null

    if (activeType === 'section') {
      return data.sections.find((s) => s.id === activeId)
    } else {
      return data.modules.find((m) => m.id === activeId)
    }
  }

  if (isLoading) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center py-12">
          <Loader2 className="h-8 w-8 animate-spin text-gray-400" />
        </CardContent>
      </Card>
    )
  }

  const sortedSections = [...data.sections].sort(
    (a, b) => a.display_order - b.display_order
  )

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold">Curriculum Builder</h2>
          <p className="text-sm text-gray-500">
            Organize your course content into sections and modules
          </p>
        </div>
        <Button onClick={handleAddSection} size="sm">
          <FolderPlus className="h-4 w-4 mr-2" />
          Add Section
        </Button>
      </div>

      <DndContext
        sensors={sensors}
        collisionDetection={closestCenter}
        onDragStart={handleDragStart}
        onDragOver={handleDragOver}
        onDragEnd={handleDragEnd}
      >
        <SortableContext
          items={sortedSections.map((s) => s.id)}
          strategy={verticalListSortingStrategy}
        >
          <div className="space-y-3">
            {sortedSections.map((section) => (
              <SectionCard
                key={section.id}
                section={section}
                modules={getModulesForSection(section.id)}
                isExpanded={expandedSections.has(section.id)}
                onToggleExpanded={() => toggleSectionExpanded(section.id)}
                onUpdate={(updates) => handleUpdateSection(section.id, updates)}
                onDelete={() => handleDeleteSection(section.id)}
                onAddModule={() => setAddModuleDialog({ open: true, sectionId: section.id })}
                onEditModule={(module) => setEditingModule(module)}
                onDeleteModule={handleDeleteModule}
                onDuplicateModule={handleDuplicateModule}
              />
            ))}
          </div>
        </SortableContext>

        {/* Ungrouped Modules */}
        {ungroupedModules.length > 0 && (
          <Card className="mt-4">
            <CardHeader className="py-3">
              <div className="flex items-center justify-between">
                <CardTitle className="text-sm font-medium text-gray-600">
                  Ungrouped Modules ({ungroupedModules.length})
                </CardTitle>
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => setAddModuleDialog({ open: true, sectionId: null })}
                >
                  <Plus className="h-4 w-4 mr-1" />
                  Add
                </Button>
              </div>
            </CardHeader>
            <CardContent className="pt-0">
              <SortableContext
                items={ungroupedModules.map((m) => m.id)}
                strategy={verticalListSortingStrategy}
              >
                <div className="space-y-2">
                  {ungroupedModules.map((module) => (
                    <ModuleCard
                      key={module.id}
                      module={module}
                      onEdit={() => setEditingModule(module)}
                      onDelete={() => handleDeleteModule(module.id)}
                      onDuplicate={() => handleDuplicateModule(module.id)}
                    />
                  ))}
                </div>
              </SortableContext>
            </CardContent>
          </Card>
        )}

        {/* Empty State */}
        {data.sections.length === 0 && ungroupedModules.length === 0 && (
          <Card>
            <CardContent className="py-12 text-center">
              <FolderPlus className="h-12 w-12 mx-auto text-gray-300 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">
                No curriculum yet
              </h3>
              <p className="text-sm text-gray-500 mb-4">
                Start by adding sections to organize your course content
              </p>
              <Button onClick={handleAddSection}>
                <Plus className="h-4 w-4 mr-2" />
                Add First Section
              </Button>
            </CardContent>
          </Card>
        )}

        {/* Drag Overlay */}
        <DragOverlay>
          {activeId && activeType === 'section' && (
            <div className="bg-white rounded-lg border-2 border-blue-500 shadow-lg p-3 opacity-90">
              <span className="font-medium">
                {(getActiveItem() as CourseSection)?.title}
              </span>
            </div>
          )}
          {activeId && activeType === 'module' && (
            <div className="bg-white rounded-md border-2 border-blue-500 shadow-lg p-2 opacity-90">
              <span className="text-sm">
                {(getActiveItem() as CourseModule)?.title}
              </span>
            </div>
          )}
        </DragOverlay>
      </DndContext>

      {/* Add Module Dialog */}
      <AddModuleDialog
        open={addModuleDialog.open}
        onOpenChange={(open) => {
          if (!open) setAddModuleDialog({ open: false, sectionId: null })
        }}
        sectionId={addModuleDialog.sectionId}
        onSubmit={handleAddModule}
      />

      {/* Edit Module Dialog */}
      {editingModule && (
        <AddModuleDialog
          open={!!editingModule}
          onOpenChange={(open) => !open && setEditingModule(null)}
          sectionId={editingModule.section_id}
          module={editingModule}
          onSubmit={(updates) => handleUpdateModule(editingModule.id, updates)}
        />
      )}
    </div>
  )
}

