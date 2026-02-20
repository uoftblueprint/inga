import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["search", "row", "emptyRow", "pagination"];
  static values = { perPage: { type: Number, default: 10 } };

  connect() {
    this._rows = this.rowTargets || [];
    this._currentPage = 1;
    this._filteredRows = [...this._rows];
    this.paginate();
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

    // Reset to first page when filtering
    this._currentPage = 1;
    this.paginate();
  }

  goToPage(event) {
    const page = parseInt(event.currentTarget.dataset.page, 10);
    if (page >= 1 && page <= this._totalPages()) {
      this._currentPage = page;
      this.paginate();
    }
  }

  previousPage() {
    if (this._currentPage > 1) {
      this._currentPage--;
      this.paginate();
    }
  }

  nextPage() {
    if (this._currentPage < this._totalPages()) {
      this._currentPage++;
      this.paginate();
    }
  }

  paginate() {
    const perPage = this.perPageValue;
    const totalPages = this._totalPages();
    const start = (this._currentPage - 1) * perPage;
    const end = start + perPage;

    // Hide all rows first
    this._rows.forEach((row) => {
      row.style.display = "none";
    });

    // Show only filtered rows for the current page
    this._filteredRows.forEach((row, index) => {
      row.style.display = index >= start && index < end ? "" : "none";
    });

    // Toggle empty state
    this.emptyRowTarget.classList.toggle("hidden", this._filteredRows.length > 0);

    // Render pagination controls
    if (this.hasPaginationTarget) {
      this._renderPagination(totalPages);
    }
  }

  // --- Private ---

  _totalPages() {
    return Math.max(1, Math.ceil(this._filteredRows.length / this.perPageValue));
  }

  _renderPagination(totalPages) {
    const container = this.paginationTarget;

    // Hide pagination if only one page
    if (totalPages <= 1) {
      container.classList.add("hidden");
      return;
    }

    container.classList.remove("hidden");

    const pages = this._pageSeries(totalPages);
    let html = "";

    html += `<button class="join-item btn btn-sm${this._currentPage === 1 ? " btn-disabled" : ""}"
      data-action="index-table-component#previousPage" ${this._currentPage === 1 ? "disabled" : ""}>«</button>`;

    pages.forEach((page) => {
      if (page === "gap") {
        html += `<button class="join-item btn btn-sm btn-disabled">…</button>`;
      } else {
        const isActive = page === this._currentPage;
        html += `<button class="join-item btn btn-sm${isActive ? " btn-active" : ""}"
          data-action="index-table-component#goToPage" data-page="${page}">${page}</button>`;
      }
    });

    html += `<button class="join-item btn btn-sm${this._currentPage === totalPages ? " btn-disabled" : ""}"
      data-action="index-table-component#nextPage" ${this._currentPage === totalPages ? "disabled" : ""}>»</button>`;

    container.innerHTML = html;
  }

  _pageSeries(totalPages) {
    const current = this._currentPage;

    if (totalPages <= 7) {
      return Array.from({ length: totalPages }, (_, i) => i + 1);
    }

    const pages = [];

    pages.push(1);

    if (current > 3) {
      pages.push("gap");
    }

    const rangeStart = Math.max(2, current - 1);
    const rangeEnd = Math.min(totalPages - 1, current + 1);

    for (let i = rangeStart; i <= rangeEnd; i++) {
      pages.push(i);
    }

    if (current < totalPages - 2) {
      pages.push("gap");
    }

    pages.push(totalPages);

    return pages;
  }
}
