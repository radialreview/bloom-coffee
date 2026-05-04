import { useEffect, useMemo, useRef, useState } from 'react'
import { Link } from 'react-router-dom'
import { apiClient } from '../api/client'
import { useOrder } from '../context/useOrder'

function formatMoney(value) {
  return `$${Number(value).toFixed(2)}`
}

function CustomerMenuPage() {
  const { addItem, itemCount, total } = useOrder()
  const [drinks, setDrinks] = useState([])
  const [addOns, setAddOns] = useState([])
  const [activeDrinkId, setActiveDrinkId] = useState(null)
  const [selectedAddOnIds, setSelectedAddOnIds] = useState([])
  const [error, setError] = useState('')
  const [isLoading, setIsLoading] = useState(true)
  const customizerRef = useRef(null)

  useEffect(() => {
    let active = true

    Promise.all([apiClient.get('/api/v1/drinks'), apiClient.get('/api/v1/add_ons')])
      .then(([drinksResponse, addOnsResponse]) => {
        if (!active) return
        setDrinks(drinksResponse.data.drinks || [])
        setAddOns(addOnsResponse.data.add_ons || [])
      })
      .catch(() => {
        if (!active) return
        setError('Unable to load the menu right now.')
      })
      .finally(() => {
        if (!active) return
        setIsLoading(false)
      })

    return () => {
      active = false
    }
  }, [])

  const activeDrink = useMemo(
    () => drinks.find((drink) => drink.id === activeDrinkId) || null,
    [drinks, activeDrinkId],
  )

  const selectedAddOns = useMemo(
    () => addOns.filter((addOn) => selectedAddOnIds.includes(addOn.id)),
    [addOns, selectedAddOnIds],
  )

  const activeLineTotal = useMemo(() => {
    if (!activeDrink) return 0
    const addOnTotal = selectedAddOns.reduce((sum, addOn) => sum + Number(addOn.price), 0)
    return Number(activeDrink.base_price) + addOnTotal
  }, [activeDrink, selectedAddOns])

  useEffect(() => {
    if (!activeDrink || !customizerRef.current) return

    customizerRef.current.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }, [activeDrink])

  function openCustomizer(drinkId) {
    setActiveDrinkId(drinkId)
    setSelectedAddOnIds([])
  }

  function toggleAddOn(addOnId) {
    setSelectedAddOnIds((current) =>
      current.includes(addOnId) ? current.filter((id) => id !== addOnId) : [...current, addOnId],
    )
  }

  function addActiveDrinkToOrder() {
    if (!activeDrink) return
    addItem(activeDrink, selectedAddOns)
    setActiveDrinkId(null)
    setSelectedAddOnIds([])
  }

  return (
    <main className="customer-page">
      <header className="customer-header">
        <div>
          <h1>Bloom Coffee Menu</h1>
          <p className="subtle-text">Slow morning energy in a cup. Choose your drink and make it yours.</p>
        </div>
        <Link className="secondary-button inline-link-button" to="/admin/login">
          Admin login
        </Link>
      </header>

      {isLoading ? <p className="subtle-text">Loading menu...</p> : null}
      {error ? <p className="error-text">{error}</p> : null}

      <section className="menu-grid">
        {drinks.map((drink) => (
          <article key={drink.id} className="menu-card">
            <h2>{drink.name}</h2>
            <p className="subtle-text">{drink.description || 'No description.'}</p>
            <p className="drink-price">{formatMoney(drink.base_price)}</p>
            <button type="button" onClick={() => openCustomizer(drink.id)}>
              Customize
            </button>
          </article>
        ))}
      </section>

      {activeDrink ? (
        <section ref={customizerRef} className="customizer-card">
          <h2>Customize {activeDrink.name}</h2>
          <p className="subtle-text">Select add-ons and preview line total.</p>

          <div className="add-ons-grid">
            {addOns.map((addOn) => (
              <label key={addOn.id} className="add-on-option">
                <input
                  type="checkbox"
                  checked={selectedAddOnIds.includes(addOn.id)}
                  onChange={() => toggleAddOn(addOn.id)}
                />
                <span>
                  {addOn.name} ({formatMoney(addOn.price)})
                </span>
              </label>
            ))}
          </div>

          <div className="customizer-footer">
            <p>
              Line total: <strong>{formatMoney(activeLineTotal)}</strong>
            </p>
            <div className="row-actions">
              <button type="button" className="secondary-button" onClick={() => setActiveDrinkId(null)}>
                Cancel
              </button>
              <button type="button" onClick={addActiveDrinkToOrder}>
                Add to order
              </button>
            </div>
          </div>
        </section>
      ) : null}

      <footer className="order-summary-bar">
        <p>
          {itemCount} item{itemCount === 1 ? '' : 's'} in order
        </p>
        <p>
          Total: <strong>{formatMoney(total)}</strong>
        </p>
        <Link className="inline-link-button" to="/order">
          Review order
        </Link>
      </footer>
    </main>
  )
}

export default CustomerMenuPage
