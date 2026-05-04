import { useCallback, useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { apiClient } from '../api/client'
import { useAuth } from '../context/useAuth'

export function useAdminCrud({ endpoint, dataKey, emptyForm, buildPayload }) {
  const navigate = useNavigate()
  const { logout } = useAuth()

  const [records, setRecords] = useState([])
  const [formData, setFormData] = useState(emptyForm)
  const [editingId, setEditingId] = useState(null)
  const [error, setError] = useState('')
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)

  const isEditing = editingId !== null

  const loadRecords = useCallback(async () => {
    setIsLoading(true)
    setError('')

    try {
      const { data } = await apiClient.get(endpoint)
      setRecords(data[dataKey] || [])
    } catch {
      setError(`Unable to load ${dataKey.replace('_', ' ')} right now.`)
    } finally {
      setIsLoading(false)
    }
  }, [endpoint, dataKey])

  useEffect(() => {
    loadRecords()
  }, [loadRecords])

  function startEdit(record, toFormData) {
    setEditingId(record.id)
    setFormData(toFormData(record))
    setError('')
  }

  function resetForm() {
    setEditingId(null)
    setFormData(emptyForm)
    setError('')
  }

  function updateField(field, value) {
    setFormData((prev) => ({ ...prev, [field]: value }))
  }

  async function handleSubmit(event) {
    event.preventDefault()
    setIsSaving(true)
    setError('')

    const payload = buildPayload(formData)

    try {
      if (isEditing) {
        await apiClient.patch(`${endpoint}/${editingId}`, payload)
      } else {
        await apiClient.post(endpoint, payload)
      }

      await loadRecords()
      resetForm()
    } catch (apiError) {
      const message = apiError?.response?.data?.error || `Unable to save ${dataKey.replace('_', ' ').slice(0, -1)}.`
      setError(message)
    } finally {
      setIsSaving(false)
    }
  }

  async function handleDelete(record) {
    const didConfirm = window.confirm(`Delete "${record.name}"?`)
    if (!didConfirm) return

    try {
      await apiClient.delete(`${endpoint}/${record.id}`)
      await loadRecords()
      if (editingId === record.id) resetForm()
    } catch (apiError) {
      const message = apiError?.response?.data?.error || `Unable to delete ${dataKey.replace('_', ' ').slice(0, -1)}.`
      setError(message)
    }
  }

  async function handleLogout() {
    await logout()
    navigate('/admin/login')
  }

  return {
    records,
    formData,
    isEditing,
    isLoading,
    isSaving,
    error,
    startEdit,
    resetForm,
    updateField,
    handleSubmit,
    handleDelete,
    handleLogout,
  }
}
