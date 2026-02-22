import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { mapping: Object }
  static targets = ["project", "subproject"]

  connect() {
    this.updateSubprojects()
    if (this.hasProjectTarget) {
      this.projectTarget.addEventListener("change", this._onProjectChange)
    }
  }

  disconnect() {
    if (this.hasProjectTarget) {
      this.projectTarget.removeEventListener("change", this._onProjectChange)
    }
  }

  _onProjectChange = () => {
    this.updateSubprojects()
  }

  updateSubprojects() {
    if (!this.hasSubprojectTarget || !this.hasProjectTarget) return

    const projectId = this.projectTarget.value || ""
    const select = this.subprojectTarget
    const previousSelection = select.value

    // Clear existing options
    while (select.firstChild) select.removeChild(select.firstChild)

    // Add blank option
    const blank = document.createElement("option")
    blank.value = ""
    blank.textContent = "Select a subproject"
    select.appendChild(blank)

    if (!projectId) return

    const entries = this.mappingValue[projectId] || []
    entries.forEach(entry => {
      const opt = document.createElement("option")
      opt.value = entry.id
      opt.textContent = entry.name
      select.appendChild(opt)
    })

    // Restore previous selection if still present
    if (previousSelection) select.value = previousSelection
  }
}
