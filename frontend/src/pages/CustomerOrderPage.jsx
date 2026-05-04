import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { apiClient } from '../api/client'
import { useOrder } from '../context/useOrder'
import { formatMoney } from '../utils/format'

const MAX_CUSTOMER_NAME_LENGTH = 120

function CustomerOrderPage() {
  const navigate = useNavigate()
  const { items, itemCount, total, removeItem, updateQuantity, clearOrder } = useOrder()
  const [customerName, setCustomerName] = useState('')
  const [submitError, setSubmitError] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)

  async function handleSubmitOrder() {
    const trimmedCustomerName = customerName.trim()
    if (!trimmedCustomerName) {
      setSubmitError('Customer name is required.')
      return
    }
    if (trimmedCustomerName.length > MAX_CUSTOMER_NAME_LENGTH) {
      setSubmitError(`Customer name cannot exceed ${MAX_CUSTOMER_NAME_LENGTH} characters.`)
      return
    }

    setSubmitError('')
    setIsSubmitting(true)

    try {
      const payload = {
        customer_name: trimmedCustomerName,
        items: items.map((item) => ({
          drink_id: item.drink.id,
          quantity: item.quantity,
          add_on_ids: item.addOns.map((addOn) => addOn.id),
        })),
      }

      const { data } = await apiClient.post('/api/v1/orders', payload)
      clearOrder()
      navigate(`/order/confirmation/${data.order.public_token}`, { state: { order: data.order } })
    } catch (apiError) {
      const message = apiError?.response?.data?.error || 'Unable to place your order right now.'
      setSubmitError(message)
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <main className="customer-page">
      <header className="customer-header">
        <div>
          <h1>Your Order</h1>
          <p className="subtle-text">Take a quick look before we start brewing.</p>
        </div>
        <Link className="secondary-button inline-link-button" to="/menu">
          Back to menu
        </Link>
      </header>

      {items.length === 0 ? (
        <section className="empty-state-card">
          <p>Your order is empty.</p>
          <Link className="inline-link-button" to="/menu">
            Start adding drinks
          </Link>
        </section>
      ) : (
        <section className="drinks-list">
          {items.map((item) => (
            <article key={item.id} className="drink-row">
              <div>
                <h2>{item.drink.name}</h2>
                <p className="subtle-text">
                  Base {formatMoney(item.drink.base_price)}
                  {item.addOns.length > 0
                    ? ` + ${item.addOns.map((addOn) => `${addOn.name} (${formatMoney(addOn.price)})`).join(', ')}`
                    : ' (no add-ons)'}
                </p>
                <p className="drink-price">Line total: {formatMoney(item.lineTotal)}</p>
              </div>

              <div className="row-actions">
                <button type="button" className="secondary-button" onClick={() => updateQuantity(item.id, item.quantity - 1)}>
                  -
                </button>
                <span className="quantity-pill">{item.quantity}</span>
                <button type="button" className="secondary-button" disabled={item.quantity >= 20} onClick={() => updateQuantity(item.id, item.quantity + 1)}>
                  +
                </button>
                <button type="button" className="danger-button" onClick={() => removeItem(item.id)}>
                  Remove
                </button>
              </div>
            </article>
          ))}
        </section>
      )}

      <footer className="order-summary-bar">
        <p>
          {itemCount} item{itemCount === 1 ? '' : 's'} in order
        </p>
        <p>
          Total: <strong>{formatMoney(total)}</strong>
        </p>
      </footer>

      {items.length > 0 ? (
        <section className="checkout-card">
          <h2>Checkout</h2>
          <label htmlFor="customer-name">Name for pickup</label>
          <input
            id="customer-name"
            value={customerName}
            onChange={(event) => setCustomerName(event.target.value)}
            placeholder="What should we call out?"
            maxLength={MAX_CUSTOMER_NAME_LENGTH}
            required
          />
          {submitError ? <p className="error-text">{submitError}</p> : null}
          <button
            type="button"
            onClick={handleSubmitOrder}
            disabled={isSubmitting || customerName.trim().length === 0}
          >
            {isSubmitting ? 'Placing order...' : 'Place order'}
          </button>
        </section>
      ) : null}
    </main>
  )
}

export default CustomerOrderPage
