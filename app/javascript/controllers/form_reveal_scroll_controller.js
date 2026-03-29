import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // delay one frame to ensure layout is stable after Turbo frame replacement.
    requestAnimationFrame(() => {
      if (this.isFullyVisible()) return;

      const prefersReducedMotion = window.matchMedia(
        "(prefers-reduced-motion: reduce)",
      ).matches;

      this.element.scrollIntoView({
        behavior: prefersReducedMotion ? "auto" : "smooth",
        block: "start",
      });
    });
  }

  isFullyVisible() {
    const rect = this.element.getBoundingClientRect();
    return rect.top >= 0 && rect.bottom <= window.innerHeight;
  }
}
