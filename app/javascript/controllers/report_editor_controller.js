import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "aggregatedDataList",
    "aggregatedDatumTemplate",
    "emptyAggregatedData",
    "selectedJournalsList",
    "emptySelectedJournals",
    "journalModal",
  ];

  connect() {
    this.newAggregatedIndex = 0;
    this._markAlreadySelectedJournalButtons();
    this._syncAggregatedDataEmptyState();
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

    const card = this.aggregatedDataListTarget.lastElementChild;
    if (card) {
      card.style.setProperty(
        "--report-item-delay",
        `${this.aggregatedDataListTarget.children.length * 30}ms`,
      );
      card.classList.add("report-item-enter");
    }

    this._syncAggregatedDataEmptyState();
  }

  removeAggregatedDatum(event) {
    const card = event.currentTarget.closest(
      '[data-report-editor-target="aggregatedDatumCard"]',
    );

    this._animateRemove(card);
  }

  removeNewAggregatedDatum(event) {
    const card = event.currentTarget.closest(
      '[data-report-editor-target="newAggregatedDatumCard"]',
    );

    this._animateRemove(card);
  }

  addJournal(event) {
    const addButton = event.currentTarget;
    const journalId = addButton.dataset.journalId;

    if (this._hasSelectedJournal(journalId)) {
      return;
    }

    const locale = this.element.dataset.locale || "en";
    const cardUrl = `/${locale}/journals/${journalId}/form_card`;

    fetch(cardUrl, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")
          .content,
      },
    })
      .then((r) => r.text())
      .then((html) => {
        Turbo.renderStreamMessage(html);
        this._animateJournalAdd(journalId);
        this._markJournalButtonSelected(addButton);
        this._syncSelectedJournalEmptyState();
      })
      .catch((error) => console.error("Failed to fetch journal card:", error));
  }

  removeJournal(event) {
    const journalCard = event.currentTarget.closest("[data-journal-id]");
    const journalId = journalCard?.dataset.journalId;

    if (journalCard) {
      this._animateRemove(journalCard, () => this._syncSelectedJournalEmptyState());
    } else {
      this._syncSelectedJournalEmptyState();
    }

    if (journalId) {
      const addButton = this.element.querySelector(
        `[data-action~="report-editor#addJournal"][data-journal-id="${
          journalId
        }"]`,
      );

      if (addButton) {
        this._markJournalButtonAvailable(addButton);
      }
    }

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
        `[data-action~="report-editor#addJournal"][data-journal-id="${
          journalId
        }"]`,
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

  _syncAggregatedDataEmptyState() {
    if (!this.hasEmptyAggregatedDataTarget) {
      return;
    }

    const hasCards = this.aggregatedDataListTarget.querySelector("[data-report-editor-target$='DatumCard']");
    this.emptyAggregatedDataTarget.classList.toggle("hidden", !!hasCards);
  }

  _animateJournalAdd(journalId) {
    const journalCard = this.selectedJournalsListTarget.querySelector(
      `[data-journal-id="${journalId}"]`,
    );

    if (journalCard) {
      journalCard.style.setProperty(
        "--report-item-delay",
        `${this.selectedJournalsListTarget.children.length * 30}ms`,
      );
      journalCard.classList.add("report-item-enter");
    }
  }

  _animateRemove(card, onRemoved = null) {
    if (!card) {
      return;
    }

    card.classList.add("report-item-exit");
    window.setTimeout(() => {
      card.remove();
      this._syncAggregatedDataEmptyState();
      if (onRemoved) {
        onRemoved();
      }
    }, 220);
  }
}
