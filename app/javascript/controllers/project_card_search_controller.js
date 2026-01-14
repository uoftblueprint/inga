import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "card", "projectName"];

  filter() {
    const query = this.inputTarget.value.toLowerCase();

    this.cardTargets.forEach((card) => {
      const name = card.dataset.projectName.toLowerCase();
      const isVisible = name.includes(query);
      card.classList.toggle("hidden", !isVisible);
    });
  }
}
