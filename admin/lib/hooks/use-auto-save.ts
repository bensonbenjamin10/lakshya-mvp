import { useEffect, useRef } from 'react'

interface UseAutoSaveOptions {
  data: any
  key: string
  enabled?: boolean
  debounceMs?: number
}

export function useAutoSave({ data, key, enabled = true, debounceMs = 1000 }: UseAutoSaveOptions) {
  const timeoutRef = useRef<NodeJS.Timeout | undefined>(undefined)
  const lastSavedRef = useRef<string>('')

  useEffect(() => {
    if (!enabled || !data) return

    const dataString = JSON.stringify(data)
    if (dataString === lastSavedRef.current) return

    // Clear existing timeout
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current)
    }

    // Set new timeout
    timeoutRef.current = setTimeout(() => {
      try {
        localStorage.setItem(`draft_${key}`, dataString)
        lastSavedRef.current = dataString
      } catch (error) {
        console.error('Failed to save draft:', error)
      }
    }, debounceMs)

    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current)
      }
    }
  }, [data, key, enabled, debounceMs])

  const clearDraft = () => {
    try {
      localStorage.removeItem(`draft_${key}`)
      lastSavedRef.current = ''
    } catch (error) {
      console.error('Failed to clear draft:', error)
    }
  }

  const loadDraft = () => {
    try {
      const draft = localStorage.getItem(`draft_${key}`)
      if (draft) {
        return JSON.parse(draft)
      }
    } catch (error) {
      console.error('Failed to load draft:', error)
    }
    return null
  }

  return { clearDraft, loadDraft }
}

