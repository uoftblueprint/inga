import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.element.classList.remove("hidden");
  }

  close(event) {
    if (event?.detail?.success === false) return;

    this.element.classList.add("hidden");
    this.element.innerHTML = "";
  }
}
