import { Link } from 'react-router-dom'
import { useAdminCrud } from '../hooks/useAdminCrud'

const EMPTY_FORM = { name: '', price: '' }

function toFormData(addOn) {
  return {
    name: addOn.name || '',
    price: String(addOn.price ?? ''),
  }
}

function buildPayload(formData) {
  return { ...formData, price: Number(formData.price) }
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
            required
          />

          <label htmlFor="add-on-price">Price</label>
          <input
            id="add-on-price"
            type="number"
            step="0.01"
            min="0"
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
                <p className="drink-price">${Number(addOn.price).toFixed(2)}</p>
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
