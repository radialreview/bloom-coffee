import { useEffect, useMemo, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { apiClient } from '../api/client'
import { useAuth } from '../context/useAuth'

const EMPTY_FORM = {
  name: '',
  price: '',
}

function AdminAddOnsPage() {
  const navigate = useNavigate()
  const { logout } = useAuth()
  const [addOns, setAddOns] = useState([])
  const [formData, setFormData] = useState(EMPTY_FORM)
  const [editingAddOnId, setEditingAddOnId] = useState(null)
  const [error, setError] = useState('')
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)

  useEffect(() => {
    loadAddOns()
  }, [])

  const isEditing = useMemo(() => editingAddOnId !== null, [editingAddOnId])

  async function loadAddOns() {
    setIsLoading(true)
    setError('')

    try {
      const { data } = await apiClient.get('/api/v1/add_ons')
      setAddOns(data.add_ons || [])
    } catch {
      setError('Unable to load add-ons right now.')
    } finally {
      setIsLoading(false)
    }
  }

  function startEdit(addOn) {
    setEditingAddOnId(addOn.id)
    setFormData({
      name: addOn.name || '',
      price: String(addOn.price ?? ''),
    })
    setError('')
  }

  function resetForm() {
    setEditingAddOnId(null)
    setFormData(EMPTY_FORM)
    setError('')
  }

  async function handleSubmit(event) {
    event.preventDefault()
    setIsSaving(true)
    setError('')

    const payload = {
      ...formData,
      price: Number(formData.price),
    }

    try {
      if (isEditing) {
        await apiClient.patch(`/api/v1/add_ons/${editingAddOnId}`, payload)
      } else {
        await apiClient.post('/api/v1/add_ons', payload)
      }

      await loadAddOns()
      resetForm()
    } catch (apiError) {
      const message = apiError?.response?.data?.error || 'Unable to save add-on.'
      setError(message)
    } finally {
      setIsSaving(false)
    }
  }

  async function handleDelete(addOn) {
    const didConfirm = window.confirm(`Delete "${addOn.name}"?`)
    if (!didConfirm) return

    try {
      await apiClient.delete(`/api/v1/add_ons/${addOn.id}`)
      await loadAddOns()
      if (editingAddOnId === addOn.id) resetForm()
    } catch (apiError) {
      const message = apiError?.response?.data?.error || 'Unable to delete add-on.'
      setError(message)
    }
  }

  async function handleLogout() {
    await logout()
    navigate('/admin/login')
  }

  return (
    <main className="page-wrapper">
      <section className="admin-panel">
        <header className="admin-header">
          <div>
            <h1>Manage Add-ons</h1>
            <p className="subtle-text">Create, edit, and remove menu add-ons.</p>
          </div>
          <div className="row-actions">
            <Link className="secondary-button inline-link-button" to="/admin/drinks">
              Manage drinks
            </Link>
            <button type="button" onClick={handleLogout}>
              Log out
            </button>
          </div>
        </header>

        <form onSubmit={handleSubmit} className="drink-form">
          <h2>{isEditing ? 'Edit Add-on' : 'Add Add-on'}</h2>

          <label htmlFor="add-on-name">Name</label>
          <input
            id="add-on-name"
            value={formData.name}
            onChange={(event) => setFormData((prev) => ({ ...prev, name: event.target.value }))}
            required
          />

          <label htmlFor="add-on-price">Price</label>
          <input
            id="add-on-price"
            type="number"
            step="0.01"
            min="0"
            value={formData.price}
            onChange={(event) => setFormData((prev) => ({ ...prev, price: event.target.value }))}
            required
          />

          {error ? <p className="error-text">{error}</p> : null}

          <div className="row-actions">
            <button type="submit" disabled={isSaving}>
              {isSaving ? 'Saving...' : isEditing ? 'Update add-on' : 'Create add-on'}
            </button>
            {isEditing ? (
              <button type="button" className="secondary-button" onClick={resetForm}>
                Cancel edit
              </button>
            ) : null}
          </div>
        </form>

        <section className="drinks-list">
          <h2>Current Add-ons</h2>
          {isLoading ? <p className="subtle-text">Loading add-ons...</p> : null}
          {!isLoading && addOns.length === 0 ? <p className="subtle-text">No add-ons yet.</p> : null}

          {addOns.map((addOn) => (
            <article key={addOn.id} className="drink-row">
              <div>
                <h3>{addOn.name}</h3>
                <p className="drink-price">${Number(addOn.price).toFixed(2)}</p>
              </div>
              <div className="row-actions">
                <button type="button" className="secondary-button" onClick={() => startEdit(addOn)}>
                  Edit
                </button>
                <button type="button" className="danger-button" onClick={() => handleDelete(addOn)}>
                  Delete
                </button>
              </div>
            </article>
          ))}
        </section>
      </section>
    </main>
  )
}

export default AdminAddOnsPage
