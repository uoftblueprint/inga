import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["panel"];

  connect() {
    requestAnimationFrame(() => {
      this.element.classList.remove("opacity-0");
      if (!this.hasPanelTarget) return;

      this.panelTarget.style.setProperty("--ui-enter-duration", "320ms");
      this.panelTarget.style.setProperty("--ui-enter-from-y", "12px");
      this.panelTarget.style.setProperty("--ui-enter-from-scale", "0.99");

      this.panelTarget.classList.remove("ui-enter-item");
      void this.panelTarget.offsetWidth;
      this.panelTarget.classList.add("ui-enter-item");
    });
  }

  close(event) {
    if (event?.detail?.success === false) return;

    if (!this.hasPanelTarget) {
      this.element.remove();
      return;
    }

    this.element.classList.add("opacity-0");
    this.panelTarget.classList.add(
      "opacity-0",
      "translate-y-3",
      "scale-[0.99]",
    );

    setTimeout(() => {
      this.element.remove();
    }, 220);
  }
}
