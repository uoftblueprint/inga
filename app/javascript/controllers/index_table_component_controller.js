import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["search", "row", "emptyRow", "pagination", "pageInfo"];
  static values = { perPage: { type: Number, default: 10 } };

  connect() {
    this._query = "";
    this._page = 0;
    this.refreshLayout();
  }

  filter() {
    this._query = (this.searchTarget?.value || "").trim().toLowerCase();
    this._page = 0;
    this._refreshRows();
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

  refreshLayout() {
    this._refreshRows();
  }

  // --- Private ---

  _refreshRows() {
    this._rows = this._activeRows();
    this._filteredRows = this._filterRows(this._rows);
    this._page = Math.min(this._page, this._lastPage());
    this._paginate();
  }

  _activeRows() {
    return this.rowTargets.filter((row) => {
      const layout = row.closest("[data-index-table-component-layout]");
      return layout && window.getComputedStyle(layout).display !== "none";
    });
  }

  _filterRows(rows) {
    if (!this._query) return [...rows];

    return rows.filter((row) => {
      const text = row.textContent.replace(/\s+/g, " ").toLowerCase();
      return text.includes(this._query);
    });
  }

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

    this.rowTargets.forEach((row) => (row.style.display = "none"));
    this._filteredRows.slice(start, end).forEach((row) => (row.style.display = ""));

    this.emptyRowTargets.forEach((emptyRow) => {
      const layout = emptyRow.closest("[data-index-table-component-layout]");
      const isActive = layout && window.getComputedStyle(layout).display !== "none";
      emptyRow.classList.toggle("hidden", !isActive || this._filteredRows.length > 0);
    });

    if (this.hasPaginationTarget) {
      this._updatePagination(this._lastPage());
    }
  }

  _updatePagination(lastPage) {
    this.paginationTargets.forEach((container, index) => {
      const layout = container.closest("[data-index-table-component-layout]");
      const isActive = layout && window.getComputedStyle(layout).display !== "none";

      if (!isActive || lastPage === 0) {
        container.classList.add("hidden");
      } else {
        container.classList.remove("hidden");
      }

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

      const pageInfo = this.pageInfoTargets[index];
      if (pageInfo) {
        pageInfo.textContent = `${this._page + 1} of ${lastPage + 1}`;
      }
    });
  }
}
