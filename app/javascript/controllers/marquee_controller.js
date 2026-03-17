import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["track", "list"];
  static values = {
    speed: { type: Number, default: 20 }, // Speed of the animation (the lower the number, the faster the animation)
    hoverSpeed: { type: Number, default: 0 }, // Speed when hovered (the lower the number, the slower the animation)
    direction: { type: String, default: "left" }, // left or right
    clones: { type: Number, default: 2 }, // Number of clones to create
  };

  connect() {
    this.isPaused = false;
    this.setupMarquee();

    // Restart animation when content changes
    this.resizeObserver = new ResizeObserver(() => {
      this.restartAnimation();
    });
    this.resizeObserver.observe(this.listTarget);
  }

  disconnect() {
    this.cleanupAnimation();
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
  }

  setupMarquee() {
    // Remove any existing clones first
    const existingClones = this.trackTarget.querySelectorAll(".marquee-clone");
    existingClones.forEach((clone) => clone.remove());

    // Ensure the list has proper flex properties
    this.listTarget.style.flexShrink = "0";

    // Create multiple clones for seamless loop
    for (let i = 0; i < this.clonesValue; i++) {
      const clone = this.listTarget.cloneNode(true);
      clone.setAttribute("aria-hidden", "true");
      clone.classList.add("marquee-clone");
      clone.style.flexShrink = "0";

      // Remove data-marquee-target from clone to avoid Stimulus conflicts
      clone.removeAttribute("data-marquee-target");

      // Append clone after the previous content
      this.trackTarget.appendChild(clone);
    }

    // Ensure track is set up correctly for side-by-side display
    this.trackTarget.style.display = "flex";
    this.trackTarget.style.flexWrap = "nowrap";

    // For right direction, we might need to adjust the initial position
    if (this.directionValue === "right") {
      // Start from the cloned content for right direction
      const contentWidth = this.listTarget.offsetWidth;
      this.trackTarget.style.transform = `translateX(-${contentWidth}px)`;
    }

    // Add smooth transition for transform changes (only for speed changes)
    this.trackTarget.style.transition = "transform 0.5s ease-out";

    // Setup CSS animation
    requestAnimationFrame(() => {
      this.applyAnimation();
    });
  }

  applyAnimation() {
    // Get the actual width of one set of content
    const contentWidth = this.listTarget.offsetWidth;

    // Create unique animation name for this instance
    const animationId = `marquee-${this.element.dataset.marqueeId || Date.now()}`;
    const animationName = `${animationId}-${this.directionValue}`;

    // Reset transform before applying animation
    this.trackTarget.style.transform = "";

    // Apply animation to track
    this.trackTarget.style.animation = `${animationName} ${this.speedValue}s linear infinite`;

    // Inject keyframes with the actual content width
    this.injectKeyframes(animationName, contentWidth);
  }

  injectKeyframes(animationName, contentWidth) {
    // Remove any existing keyframes for this animation
    const existingStyle = document.getElementById(animationName);
    if (existingStyle) {
      existingStyle.remove();
    }

    const style = document.createElement("style");
    style.id = animationName;

    // The animation moves by exactly one content width
    // When it completes, it jumps back to start, but since we have clones,
    // this jump is invisible to the user
    if (this.directionValue === "left") {
      style.textContent = `
        @keyframes ${animationName} {
          0% { transform: translateX(0); }
          100% { transform: translateX(-${contentWidth}px); }
        }
      `;
    } else {
      // For right direction, we animate from -contentWidth to 0
      style.textContent = `
        @keyframes ${animationName} {
          0% { transform: translateX(-${contentWidth}px); }
          100% { transform: translateX(0); }
        }
      `;
    }

    document.head.appendChild(style);

    // Also inject base styles if not already present
    this.injectBaseStyles();
  }

  injectBaseStyles() {
    const baseStyleId = "marquee-base-styles";

    if (document.getElementById(baseStyleId)) return;

    const style = document.createElement("style");
    style.id = baseStyleId;
    style.textContent = `
      /* Ensure smooth rendering */
      [data-marquee-target="track"] {
        will-change: transform;
        backface-visibility: hidden;
        perspective: 1000px;
      }

      /* Override transition during animation to prevent interference */
      [data-marquee-target="track"]:not(.marquee-transitioning) {
        transition: none !important;
      }

      /* Ensure original and clone are displayed side by side */
      [data-marquee-target="list"],
      .marquee-clone {
        flex-shrink: 0;
        min-width: max-content;
      }
    `;

    document.head.appendChild(style);
  }

  togglePauseAnimation() {
    if (this.isPaused) {
      this.resumeAnimationFromPause();
    } else {
      this.pauseAnimation();
    }
  }

  pauseAnimation() {
    this.trackTarget.style.animationPlayState = "paused";
    this.isPaused = true;
  }

  slowAnimation() {
    if (this.isPaused) {
      return;
    }

    if (this.hoverSpeedValue === 0) {
      this.pauseAnimation();
    } else {
      // Smoothly slow down
      this.smoothSpeedChange(this.hoverSpeedValue);
    }
  }

  resumeAnimationFromPause() {
    // Resume from pause
    this.trackTarget.style.animationPlayState = "running";
    this.isPaused = false;
  }

  resumeAnimationFromSlow() {
    if (!this.isPaused && this.hoverSpeedValue > 0) {
      // Return to normal speed
      this.smoothSpeedChange(this.speedValue);
    }
  }

  smoothSpeedChange(newSpeed) {
    // Get current transform
    const currentTransform = window.getComputedStyle(
      this.trackTarget,
    ).transform;

    // Add transitioning class
    this.trackTarget.classList.add("marquee-transitioning");

    // Apply current position and remove animation
    this.trackTarget.style.animation = "none";
    this.trackTarget.style.transform = currentTransform;

    // Force reflow
    void this.trackTarget.offsetHeight;

    // Remove transitioning class and reapply animation with new speed
    requestAnimationFrame(() => {
      this.trackTarget.classList.remove("marquee-transitioning");

      // Get content width for accurate animation
      const contentWidth = this.listTarget.offsetWidth;
      const animationId = `marquee-${this.element.dataset.marqueeId || Date.now()}`;
      const animationName = `${animationId}-${this.directionValue}`;

      this.trackTarget.style.animation = `${animationName} ${newSpeed}s linear infinite`;

      // Update keyframes if needed
      this.injectKeyframes(animationName, contentWidth);

      // Calculate progress to maintain position
      const matrix = new DOMMatrix(currentTransform);
      const currentX = matrix.m41;

      // Calculate progress through the animation cycle
      let progress;
      if (this.directionValue === "left") {
        // For left: 0 to -contentWidth
        progress = Math.abs(currentX) / contentWidth;
      } else {
        // For right: -contentWidth to 0
        progress = (contentWidth + currentX) / contentWidth;
      }

      // Ensure progress is between 0 and 1
      progress = Math.max(0, Math.min(1, progress));

      // Apply negative delay to start from current position
      this.trackTarget.style.animationDelay = `${-progress * newSpeed}s`;
    });
  }

  restartAnimation() {
    if (!this.hasTrackTarget || !this.hasListTarget) return;

    // Clear animation
    this.trackTarget.style.animation = "none";

    // Force reflow
    void this.trackTarget.offsetHeight;

    // Re-setup marquee
    this.setupMarquee();
  }

  cleanupAnimation() {
    // Remove cloned elements
    const clones = this.trackTarget.querySelectorAll(".marquee-clone");
    clones.forEach((clone) => clone.remove());

    // Remove animation styles for this instance
    const animationId = `marquee-${this.element.dataset.marqueeId || Date.now()}`;
    const styles = document.querySelectorAll(`[id^="${animationId}"]`);
    styles.forEach((style) => style.remove());
  }

  // Value change callbacks
  speedValueChanged() {
    if (this.hasTrackTarget && !this.isPaused) {
      this.smoothSpeedChange(this.speedValue);
    }
  }

  directionValueChanged() {
    if (this.hasTrackTarget) {
      this.restartAnimation();
    }
  }

  clonesValueChanged() {
    if (this.hasTrackTarget) {
      this.restartAnimation();
    }
  }
}
