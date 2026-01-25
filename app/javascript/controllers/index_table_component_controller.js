import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["search", "row"];

  connect() {
    this._rows = this.rowTargets || [];
  }

  filter() {
    const query = (this.searchTarget?.value || "").trim().toLowerCase();

    if (!query) {
      this._rows.forEach((r) => (r.style.display = ""));
      return;
    }

    this._rows.forEach((row) => {
      // take the entire row's displayed text, trim whitespace, make case
      // insensitive
      const text = row.textContent.replace(/\s+/g, " ").toLowerCase();
      const match = text.indexOf(query) !== -1;

      // only show rows that match
      row.style.display = match ? "" : "none";
    });
  }
}
