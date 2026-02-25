import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["projectSelect", "subprojectSelect", "journalFields"];

  load() {
    const projectId = this.projectSelectTarget.value;
    if (!projectId) {
      this.journalFieldsTarget.innerHTML = "";
      return;
    }

    fetch(`/projects/${projectId}/load_subprojects`, {
      headers: { Accept: "text/vnd.turbo-stream.html" },
    })
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }

  subprojectSelectTargetConnected(element) {
    if (element.options.length > 1) {
      element.disabled = false;
    }

    element.addEventListener("change", () => {
      this.loadForm();
    });
  }

  loadForm() {
    const projectId = this.projectSelectTarget.value;
    const subprojectId = this.subprojectSelectTarget.value;
    if (!projectId || !subprojectId) return;

    fetch(
      `/projects/${projectId}/load_journal_form?subproject_id=${subprojectId}`,
      {
        headers: { Accept: "text/vnd.turbo-stream.html" },
      }
    )
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }
}