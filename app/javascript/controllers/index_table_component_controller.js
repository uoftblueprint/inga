import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["search", "row", "emptyRow"];

  connect() {
    this._rows = this.rowTargets || [];
  }

  filter() {
    const query = (this.searchTarget?.value || "").trim().toLowerCase();

    if (!query) {
      this._rows.forEach((row) => {
        row.style.display = "";
      });

      this.emptyRowTarget.classList.add("hidden");
      return;
    }

    let hasMatch = false;

    this._rows.forEach((row) => {
      const text = row.textContent.replace(/\s+/g, " ").toLowerCase();
      const match = text.includes(query);

      row.style.display = match ? "" : "none";

      if (match) {
        hasMatch = true;
      }
    });
    this.emptyRowTarget.classList.toggle("hidden", hasMatch);
  }
}
