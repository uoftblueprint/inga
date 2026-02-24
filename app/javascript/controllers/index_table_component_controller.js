import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["search", "row", "emptyRow", "pagination", "pageInfo"];
  static values = { perPage: { type: Number, default: 10 } };

  connect() {
    this._rows = this.rowTargets || [];
    this._filteredRows = [...this._rows];
    this._page = 0;
    this._paginate();
  }

  filter() {
    const query = (this.searchTarget?.value || "").trim().toLowerCase();

    if (!query) {
      this._filteredRows = [...this._rows];
    } else {
      this._filteredRows = this._rows.filter((row) => {
        const text = row.textContent.replace(/\s+/g, " ").toLowerCase();
        return text.includes(query);
      });
    }

    this._page = 0;
    this._paginate();
  }

  previousPage() {
    if (this._page > 0) {
      this._page--;
      this._paginate();
    }
  }

  nextPage() {
    if (this._page < this._lastPage()) {
      this._page++;
      this._paginate();
    }
  }

  // --- Private ---

  _lastPage() {
    return Math.max(
      0,
      Math.ceil(this._filteredRows.length / this.perPageValue) - 1,
    );
  }

  _paginate() {
    const perPage = this.perPageValue;
    const start = this._page * perPage;
    const end = (this._page + 1) * perPage;

    this._rows.forEach((row) => (row.style.display = "none"));
    this._filteredRows
      .slice(start, end)
      .forEach((row) => (row.style.display = ""));

    // Toggle empty state
    this.emptyRowTarget.classList.toggle(
      "hidden",
      this._filteredRows.length > 0,
    );

    // Update pagination
    if (this.hasPaginationTarget) {
      this._updatePagination();
    }
  }

  _updatePagination() {
    const lastPage = this._lastPage();
    const container = this.paginationTarget;

    if (lastPage === 0) {
      container.classList.add("hidden");
      return;
    }

    container.classList.remove("hidden");

    const prevBtn = container.querySelector("[data-prev]");
    const nextBtn = container.querySelector("[data-next]");

    if (prevBtn) {
      prevBtn.disabled = this._page === 0;
      prevBtn.classList.toggle("btn-disabled", this._page === 0);
    }

    if (nextBtn) {
      nextBtn.disabled = this._page === lastPage;
      nextBtn.classList.toggle("btn-disabled", this._page === lastPage);
    }

    if (this.hasPageInfoTarget) {
      this.pageInfoTarget.textContent = `${this._page + 1} of ${lastPage + 1}`;
    }
  }
}
