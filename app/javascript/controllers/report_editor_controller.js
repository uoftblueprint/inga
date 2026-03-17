import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "aggregatedDataList",
    "aggregatedDatumTemplate",
    "selectedJournalsList",
    "emptySelectedJournals",
    "journalModal",
  ];

  connect() {
    this.newAggregatedIndex = 0;
    this._markAlreadySelectedJournalButtons();
    this._syncSelectedJournalEmptyState();
  }

  openJournalModal() {
    this.journalModalTarget.showModal();
  }

  closeJournalModal() {
    this.journalModalTarget.close();
  }

  addAggregatedDatum() {
    const html = this.aggregatedDatumTemplateTarget.innerHTML.replaceAll(
      "__INDEX__",
      this.newAggregatedIndex,
    );

    this.newAggregatedIndex += 1;
    this.aggregatedDataListTarget.insertAdjacentHTML("beforeend", html);
  }

  removeAggregatedDatum(event) {
    event.currentTarget
      .closest('[data-report-editor-target="aggregatedDatumCard"]')
      .remove();
  }

  removeNewAggregatedDatum(event) {
    event.currentTarget
      .closest('[data-report-editor-target="newAggregatedDatumCard"]')
      .remove();
  }

  addJournal(event) {
    const addButton = event.currentTarget;
    const journalId = addButton.dataset.journalId;

    if (this._hasSelectedJournal(journalId)) {
      return;
    }

    const locale = this.element.dataset.locale || "en";
    const cardUrl = `/${locale}/journals/${journalId}/form_card`;

    fetch(cardUrl)
      .then((response) => response.text())
      .then((html) => {
        this.selectedJournalsListTarget.insertAdjacentHTML("beforeend", html);
        this._markJournalButtonSelected(addButton);
        this._syncSelectedJournalEmptyState();
      })
      .catch((error) => console.error("Failed to fetch journal card:", error));
  }

  removeJournal(event) {
    const journalCard = event.currentTarget.closest("[data-journal-id]");
    const journalId = journalCard?.dataset.journalId;

    if (journalCard) {
      journalCard.remove();
    }

    if (journalId) {
      const addButton = this.element.querySelector(
        `[data-action~="report-editor#addJournal"][data-journal-id="${journalId}"]`,
      );

      if (addButton) {
        this._markJournalButtonAvailable(addButton);
      }
    }

    this._syncSelectedJournalEmptyState();
  }

  _hasSelectedJournal(journalId) {
    return !!this.selectedJournalsListTarget.querySelector(
      `[data-journal-id="${journalId}"]`,
    );
  }

  _markAlreadySelectedJournalButtons() {
    const selectedIds = Array.from(
      this.selectedJournalsListTarget.querySelectorAll("[data-journal-id]"),
    ).map((node) => node.dataset.journalId);

    selectedIds.forEach((journalId) => {
      const addButton = this.element.querySelector(
        `[data-action~="report-editor#addJournal"][data-journal-id="${journalId}"]`,
      );

      if (addButton) {
        this._markJournalButtonSelected(addButton);
      }
    });
  }

  _markJournalButtonSelected(button) {
    button.disabled = true;
    button.classList.add("btn-disabled");
    button.textContent = button.dataset.addedLabel || "Added";
  }

  _markJournalButtonAvailable(button) {
    button.disabled = false;
    button.classList.remove("btn-disabled");
    button.textContent = button.dataset.addLabel || "Add";
  }

  _syncSelectedJournalEmptyState() {
    const hasSelected =
      this.selectedJournalsListTarget.querySelector("[data-journal-id]");

    this.emptySelectedJournalsTarget.classList.toggle("hidden", !!hasSelected);
  }
}
