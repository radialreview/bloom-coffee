import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "display"]
  static values  = { basePrice: Number }

  calculate() {
    const addOnTotal = this.checkboxTargets
      .filter(cb => cb.checked)
      .reduce((sum, cb) => sum + parseFloat(cb.dataset.price), 0)

    const total = this.basePriceValue + addOnTotal
    this.displayTarget.textContent = this.formatCurrency(total)
  }

  formatCurrency(amount) {
    return `$${amount.toFixed(2)}`
  }
}
