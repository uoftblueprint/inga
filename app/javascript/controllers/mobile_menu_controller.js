import { Controller } from "@hotwired/stimulus";

// Mobile menu controller for toggling sidebar on mobile devices
export default class extends Controller {
  static targets = ["sidebar", "overlay", "menuButton"];

  connect() {
    // Close menu on window resize if screen becomes larger
    this.handleResize = this.handleResize.bind(this);
    window.addEventListener("resize", this.handleResize);
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize);
  }

  toggle() {
    const isOpen = !this.sidebarTarget.classList.contains("-translate-x-full");

    if (isOpen) {
      this.close();
    } else {
      this.open();
    }
  }

  open() {
    this.sidebarTarget.classList.remove("-translate-x-full");
    this.overlayTarget.classList.remove("hidden");
    document.body.style.overflow = "hidden";
  }

  close() {
    this.sidebarTarget.classList.add("-translate-x-full");
    this.overlayTarget.classList.add("hidden");
    document.body.style.overflow = "";
  }

  handleResize() {
    // Close menu if screen becomes large (md breakpoint = 768px)
    if (window.innerWidth >= 768) {
      this.close();
    }
  }
}
