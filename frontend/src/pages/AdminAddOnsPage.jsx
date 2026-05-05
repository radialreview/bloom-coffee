import { Link } from 'react-router-dom'
import { useAdminCrud } from '../hooks/useAdminCrud'
import { formatMoney } from '../utils/format'

const EMPTY_FORM = { name: '', price: '' }
const MAX_NAME_LENGTH = 120
const MAX_PRICE = 999999.99

function toFormData(addOn) {
  return {
    name: addOn.name || '',
    price: String(addOn.price ?? ''),
  }
}

function buildPayload(formData) {
  return {
    name: formData.name.trim(),
    price: Number(formData.price),
  }
}

function validateAddOnForm(formData) {
  const name = formData.name.trim()
  const price = Number(formData.price)

  if (!name) return 'Name is required.'
  if (name.length > MAX_NAME_LENGTH) return `Name cannot exceed ${MAX_NAME_LENGTH} characters.`
  if (!Number.isFinite(price)) return 'Price must be a valid number.'
  if (price < 0) return 'Price cannot be negative.'
  if (price > MAX_PRICE) return `Price cannot exceed ${MAX_PRICE}.`

  return ''
}

function AdminAddOnsPage() {
  const {
    records: addOns,
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
    endpoint: '/api/v1/add_ons',
    dataKey: 'add_ons',
    emptyForm: EMPTY_FORM,
    buildPayload,
    validateForm: validateAddOnForm,
  })

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
            onChange={(event) => updateField('name', event.target.value)}
            maxLength={MAX_NAME_LENGTH}
            required
          />

          <label htmlFor="add-on-price">Price</label>
          <input
            id="add-on-price"
            type="number"
            step="0.01"
            min="0"
            max={MAX_PRICE}
            value={formData.price}
            onChange={(event) => updateField('price', event.target.value)}
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
                <p className="drink-price">{formatMoney(addOn.price)}</p>
              </div>
              <div className="row-actions">
                <button type="button" className="secondary-button" onClick={() => startEdit(addOn, toFormData)}>
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
