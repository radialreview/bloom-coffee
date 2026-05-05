import { Link } from 'react-router-dom'
import { useAdminCrud } from '../hooks/useAdminCrud'
import { formatMoney } from '../utils/format'

const EMPTY_FORM = { name: '', description: '', base_price: '' }
const MAX_NAME_LENGTH = 120
const MAX_DESCRIPTION_LENGTH = 500
const MAX_BASE_PRICE = 999999.99

function toFormData(drink) {
  return {
    name: drink.name || '',
    description: drink.description || '',
    base_price: String(drink.base_price ?? ''),
  }
}

function buildPayload(formData) {
  return {
    name: formData.name.trim(),
    description: formData.description.trim(),
    base_price: Number(formData.base_price),
  }
}

function validateDrinkForm(formData) {
  const name = formData.name.trim()
  const description = formData.description.trim()
  const basePrice = Number(formData.base_price)

  if (!name) return 'Name is required.'
  if (name.length > MAX_NAME_LENGTH) return `Name cannot exceed ${MAX_NAME_LENGTH} characters.`
  if (description.length > MAX_DESCRIPTION_LENGTH) return `Description cannot exceed ${MAX_DESCRIPTION_LENGTH} characters.`
  if (!Number.isFinite(basePrice)) return 'Base price must be a valid number.'
  if (basePrice <= 0) return 'Base price must be greater than 0.'
  if (basePrice > MAX_BASE_PRICE) return `Base price cannot exceed ${MAX_BASE_PRICE}.`

  return ''
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
    validateForm: validateDrinkForm,
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
            maxLength={MAX_NAME_LENGTH}
            required
          />

          <label htmlFor="drink-description">Description</label>
          <textarea
            id="drink-description"
            rows="3"
            value={formData.description}
            onChange={(event) => updateField('description', event.target.value)}
            maxLength={MAX_DESCRIPTION_LENGTH}
          />

          <label htmlFor="drink-price">Base price</label>
          <input
            id="drink-price"
            type="number"
            step="0.01"
            min="0.01"
            max={MAX_BASE_PRICE}
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
          <div className="menu-header-row">
            <h2>Current Drinks</h2>
            {!isLoading ? <p className="subtle-text">{drinks.length} available</p> : null}
          </div>
          {isLoading ? <p className="subtle-text">Loading drinks...</p> : null}
          {!isLoading && drinks.length === 0 ? <p className="subtle-text">No drinks yet.</p> : null}

          {drinks.map((drink) => (
            <article key={drink.id} className="drink-row">
              <div>
                <h3>{drink.name}</h3>
                <p className="subtle-text">{drink.description || 'No description.'}</p>
                <p className="drink-price">{formatMoney(drink.base_price)}</p>
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
