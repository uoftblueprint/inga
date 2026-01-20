import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["list", "row"];
  static values = { submitUrl: String };

  add(event) {
    event.preventDefault();

    fetch(this.addUrl(), {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")
          .content,
      },
    })
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }

  addUrl() {
    return `${this.submitUrlValue}/new_row`;
  }

  remove(event) {
    event.preventDefault();
    event.target
      .closest('[data-project-attributes-builder-target="row"]')
      .remove();
  }
}
