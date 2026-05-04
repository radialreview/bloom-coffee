import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { apiClient } from '../api/client'
import { useAuth } from '../context/useAuth'

const EMPTY_FORM = {
  name: '',
  description: '',
  base_price: '',
}

function AdminDrinksPage() {
  const navigate = useNavigate()
  const { logout } = useAuth()
  const [drinks, setDrinks] = useState([])
  const [formData, setFormData] = useState(EMPTY_FORM)
  const [editingDrinkId, setEditingDrinkId] = useState(null)
  const [error, setError] = useState('')
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)

  useEffect(() => {
    loadDrinks()
  }, [])

  const isEditing = useMemo(() => editingDrinkId !== null, [editingDrinkId])

  async function loadDrinks() {
    setIsLoading(true)
    setError('')

    try {
      const { data } = await apiClient.get('/api/v1/drinks')
      setDrinks(data.drinks || [])
    } catch {
      setError('Unable to load drinks right now.')
    } finally {
      setIsLoading(false)
    }
  }

  function startEdit(drink) {
    setEditingDrinkId(drink.id)
    setFormData({
      name: drink.name || '',
      description: drink.description || '',
      base_price: String(drink.base_price ?? ''),
    })
    setError('')
  }

  function resetForm() {
    setEditingDrinkId(null)
    setFormData(EMPTY_FORM)
    setError('')
  }

  async function handleSubmit(event) {
    event.preventDefault()
    setIsSaving(true)
    setError('')

    const payload = {
      ...formData,
      base_price: Number(formData.base_price),
    }

    try {
      if (isEditing) {
        await apiClient.patch(`/api/v1/drinks/${editingDrinkId}`, payload)
      } else {
        await apiClient.post('/api/v1/drinks', payload)
      }

      await loadDrinks()
      resetForm()
    } catch (apiError) {
      const message = apiError?.response?.data?.error || 'Unable to save drink.'
      setError(message)
    } finally {
      setIsSaving(false)
    }
  }

  async function handleDelete(drink) {
    const didConfirm = window.confirm(`Delete "${drink.name}"?`)
    if (!didConfirm) return

    try {
      await apiClient.delete(`/api/v1/drinks/${drink.id}`)
      await loadDrinks()
      if (editingDrinkId === drink.id) resetForm()
    } catch (apiError) {
      const message = apiError?.response?.data?.error || 'Unable to delete drink.'
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
            <h1>Manage Drinks</h1>
            <p className="subtle-text">Create, edit, and remove drinks from the menu.</p>
          </div>
          <button type="button" onClick={handleLogout}>
            Log out
          </button>
        </header>

        <form onSubmit={handleSubmit} className="drink-form">
          <h2>{isEditing ? 'Edit Drink' : 'Add Drink'}</h2>

          <label htmlFor="drink-name">Name</label>
          <input
            id="drink-name"
            value={formData.name}
            onChange={(event) => setFormData((prev) => ({ ...prev, name: event.target.value }))}
            required
          />

          <label htmlFor="drink-description">Description</label>
          <textarea
            id="drink-description"
            rows="3"
            value={formData.description}
            onChange={(event) => setFormData((prev) => ({ ...prev, description: event.target.value }))}
          />

          <label htmlFor="drink-price">Base price</label>
          <input
            id="drink-price"
            type="number"
            step="0.01"
            min="0.01"
            value={formData.base_price}
            onChange={(event) => setFormData((prev) => ({ ...prev, base_price: event.target.value }))}
            required
          />

          {error ? <p className="error-text">{error}</p> : null}

          <div className="row-actions">
            <button type="submit" disabled={isSaving}>
              {isSaving ? 'Saving...' : isEditing ? 'Update drink' : 'Create drink'}
            </button>
            {isEditing ? (
              <button type="button" className="secondary-button" onClick={resetForm}>
                Cancel edit
              </button>
            ) : null}
          </div>
        </form>

        <section className="drinks-list">
          <h2>Current Drinks</h2>
          {isLoading ? <p className="subtle-text">Loading drinks...</p> : null}
          {!isLoading && drinks.length === 0 ? <p className="subtle-text">No drinks yet.</p> : null}

          {drinks.map((drink) => (
            <article key={drink.id} className="drink-row">
              <div>
                <h3>{drink.name}</h3>
                <p className="subtle-text">{drink.description || 'No description.'}</p>
                <p className="drink-price">${Number(drink.base_price).toFixed(2)}</p>
              </div>
              <div className="row-actions">
                <button type="button" className="secondary-button" onClick={() => startEdit(drink)}>
                  Edit
                </button>
                <button type="button" className="danger-button" onClick={() => handleDelete(drink)}>
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

export default AdminDrinksPage
