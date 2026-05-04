import { Link } from 'react-router-dom'
import { useAdminCrud } from '../hooks/useAdminCrud'

const EMPTY_FORM = { name: '', description: '', base_price: '' }

function toFormData(drink) {
  return {
    name: drink.name || '',
    description: drink.description || '',
    base_price: String(drink.base_price ?? ''),
  }
}

function buildPayload(formData) {
  return { ...formData, base_price: Number(formData.base_price) }
}

function AdminDrinksPage() {
  const {
    records: drinks,
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
  } = useAdminCrud({
    endpoint: '/api/v1/drinks',
    dataKey: 'drinks',
    emptyForm: EMPTY_FORM,
    buildPayload,
  })

  return (
    <main className="page-wrapper">
      <section className="admin-panel">
        <header className="admin-header">
          <div>
            <h1>Manage Drinks</h1>
            <p className="subtle-text">Create, edit, and remove drinks from the menu.</p>
          </div>
          <div className="row-actions">
            <Link className="secondary-button inline-link-button" to="/admin/add-ons">
              Manage add-ons
            </Link>
            <button type="button" onClick={handleLogout}>
              Log out
            </button>
          </div>
        </header>

        <form onSubmit={handleSubmit} className="drink-form">
          <h2>{isEditing ? 'Edit Drink' : 'Add Drink'}</h2>

          <label htmlFor="drink-name">Name</label>
          <input
            id="drink-name"
            value={formData.name}
            onChange={(event) => updateField('name', event.target.value)}
            required
          />

          <label htmlFor="drink-description">Description</label>
          <textarea
            id="drink-description"
            rows="3"
            value={formData.description}
            onChange={(event) => updateField('description', event.target.value)}
          />

          <label htmlFor="drink-price">Base price</label>
          <input
            id="drink-price"
            type="number"
            step="0.01"
            min="0.01"
            value={formData.base_price}
            onChange={(event) => updateField('base_price', event.target.value)}
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
                <button type="button" className="secondary-button" onClick={() => startEdit(drink, toFormData)}>
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
