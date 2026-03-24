import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];

  connect() {
    this.boundDocumentClick = this.handleDocumentClick.bind(this);
    document.addEventListener("click", this.boundDocumentClick);
  }

  disconnect() {
    document.removeEventListener("click", this.boundDocumentClick);
  }

  openMenu(event) {
    event.stopPropagation();

    const row = event.currentTarget.closest(
      "[data-index-table-component-target='row']",
    );

    const menu = row?.querySelector(
      "[data-table-actions-dropdown-target='menu']",
    );

    if (!menu) return;

    // close other menus first
    const allMenus = Array.from(
      document.querySelectorAll("[data-table-actions-dropdown-target='menu']"),
    );

    allMenus.forEach((m) => {
      if (m !== menu) this._closeMenu(m);
    });

    // if already open, do nothing; document click will close
    if (!menu.classList.contains("hidden")) return;

    this._openMenu(menu, row);
  }

  navigateToRecord(event) {
    // only navigate if not clicking on the menu button or menu
    if (
      event.target.closest("[data-table-actions-dropdown-target='menu']") ||
      event.target.closest("[data-action*='table-actions-dropdown#openMenu']")
    ) {
      return;
    }

    const path = event.currentTarget.dataset.recordPath;

    if (!path) return;

    if (path.endsWith(".turbo_stream")) {
      fetch(path, {
        headers: {
          Accept: "text/vnd.turbo-stream.html",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")
            .content,
        },
      })
        .then((r) => r.text())
        .then((body) => {
          Turbo.renderStreamMessage(body);
        });
    } else {
      window.location.href = path;
    }
  }

  _openMenu(menu, row) {
    menu.classList.remove("hidden");

    // store original parent so we can restore later
    if (!menu._originalParent) {
      menu._originalParent = menu.parentNode;
    }

    // append to body so z-index isn't constrained by ancestors
    document.body.appendChild(menu);
    menu.style.position = "fixed";

    const rect = row.getBoundingClientRect();

    const left = Math.max(8, rect.right - menu.offsetWidth);
    const top = rect.bottom;

    menu.style.left = `${left}px`;
    menu.style.top = `${top}px`;
    menu.style.right = "auto";
  }

  _closeMenu(menu) {
    menu.classList.add("hidden");

    if (menu._originalParent) {
      menu.style.position = "";
      menu.style.left = "";
      menu.style.top = "";
      menu.style.right = "";

      menu._originalParent.appendChild(menu);

      delete menu._originalParent;
    }
  }

  handleDocumentClick() {
    const allMenus = Array.from(
      document.querySelectorAll("[data-table-actions-dropdown-target='menu']"),
    );

    allMenus.forEach((menu) => this._closeMenu(menu));
  }
}
