import { useEffect, useState } from 'react'
import { Link, useLocation, useParams } from 'react-router-dom'
import { apiClient } from '../api/client'
import { formatMoney } from '../utils/format'

function OrderConfirmationPage() {
  const { token } = useParams()
  const location = useLocation()
  const [order, setOrder] = useState(location.state?.order || null)
  const [isLoading, setIsLoading] = useState(!location.state?.order)
  const [error, setError] = useState('')

  useEffect(() => {
    if (order) return
    let active = true

    apiClient
      .get(`/api/v1/orders/${token}`)
      .then(({ data }) => {
        if (!active) return
        setOrder(data.order)
      })
      .catch(() => {
        if (!active) return
        setError('Unable to load order confirmation.')
      })
      .finally(() => {
        if (!active) return
        setIsLoading(false)
      })

    return () => {
      active = false
    }
  }, [token, order])

  return (
    <main className="customer-page">
      <header className="customer-header">
        <div>
          <h1>Order Confirmed</h1>
          <p className="subtle-text">Thanks for stopping by Bloom Coffee.</p>
        </div>
      </header>

      {isLoading ? <p className="subtle-text">Loading confirmation...</p> : null}
      {error ? <p className="error-text">{error}</p> : null}

      {order ? (
        <section className="confirmation-card">
          <h2>Order #{order.order_number}</h2>
          <p className="subtle-text">We'll call {order.customer_name} when your order is ready.</p>

          <div className="drinks-list">
            {order.items.map((item, index) => (
              <article key={`${item.drink.id}-${index}`} className="drink-row">
                <div>
                  <h3>{item.drink.name}</h3>
                  <p className="subtle-text">
                    Qty {item.quantity}
                    {item.add_ons.length > 0
                      ? ` + ${item.add_ons.map((addOn) => `${addOn.name} (${formatMoney(addOn.price)})`).join(', ')}`
                      : ' (no add-ons)'}
                  </p>
                </div>
                <p className="drink-price">{formatMoney(item.line_total)}</p>
              </article>
            ))}
          </div>

          <p>
            Total: <strong>{formatMoney(order.total)}</strong>
          </p>
        </section>
      ) : null}

      <Link className="inline-link-button" to="/menu">
        Start another order
      </Link>
    </main>
  )
}

export default OrderConfirmationPage
