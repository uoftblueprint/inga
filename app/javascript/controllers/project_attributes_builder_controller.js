import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["list", "row", "title", "type"];
  static values = { submitUrl: String };

  add() {
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
    event.target
      .closest('[data-project-attributes-builder-target="row"]')
      .remove();
  }

  submit() {
    const attributes = this.rowTargets.map((row, i) => ({
      name: this.titleTargets[i].value,
      type: this.typeTargets[i].value,
    }));

    fetch(this.submitUrlValue, {
      method: "PATCH",
      headers: {
        Accept: "text/html",
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")
          .content,
      },
      body: JSON.stringify({ attributes }),
    }).then((response) => {
      if (response.redirected) {
        Turbo.visit(response.url);
      } else if (!response.ok) {
        response.text().then((html) => {
          document.body.innerHTML = html;
        });
      }
    });
  }
}
