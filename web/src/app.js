import { seedEvent } from "./seed.js";
import {
  aggregateShopping,
  eventTotals,
  initials,
  money,
  personById,
  scaledMealItems,
  settleUp,
  trustSignals
} from "./domain.js";
import { clearQueue, listQueue, loadEvent, queueMutation, resetEvent, saveEvent } from "./offlineStore.js";

let event = loadEvent(seedEvent);
let selectedPanel = "command";
let selectedMealId = event.meals[0]?.id;
let selectedUserId = event.organizerId;

const app = document.querySelector("#app");

if ("serviceWorker" in navigator && location.protocol !== "file:") {
  navigator.serviceWorker.register("./sw.js").catch(() => {});
}

function setEvent(next, mutationType, payload = {}) {
  event = {
    ...next,
    sync: {
      ...next.sync,
      pendingChanges: listQueue().length + 1,
      lastSyncedAt: "queued locally"
    }
  };
  saveEvent(event);
  queueMutation(mutationType, payload);
  render();
}

function render() {
  const totals = eventTotals(event);
  const shopping = aggregateShopping(event);
  const selectedMeal = event.meals.find((meal) => meal.id === selectedMealId) ?? event.meals[0];
  const user = personById(event, selectedUserId) ?? event.people[0];
  const trust = trustSignals(event);
  const queue = listQueue();

  app.innerHTML = `
    <div class="shell">
      ${sidebar()}
      <main class="workspace">
        ${topbar(totals, queue.length)}
        <section class="command-grid" aria-label="Party planning command center">
          <div class="primary-panel">
            ${heroCommand(totals, trust.score)}
            ${panelTabs()}
            <div class="panel-body">
              ${selectedPanel === "command" ? commandPanel(shopping, selectedMeal) : ""}
              ${selectedPanel === "meals" ? mealsPanel(selectedMeal) : ""}
              ${selectedPanel === "money" ? moneyPanel(totals) : ""}
              ${selectedPanel === "crew" ? crewPanel() : ""}
            </div>
          </div>
          <aside class="inspector">
            ${inspector(user, trust, totals, queue)}
          </aside>
        </section>
      </main>
    </div>
  `;

  bindEvents();
}

function sidebar() {
  const nav = [
    ["command", "Command", "bolt"],
    ["meals", "Meals", "utensils"],
    ["money", "Money", "receipt"],
    ["crew", "Crew", "users"]
  ];

  return `
    <aside class="sidebar" aria-label="Primary">
      <a class="brand" href="#" data-action="panel" data-panel="command" aria-label="Party Planner home">
        <span class="brand-mark">P</span>
        <span>
          <strong>Party Planner</strong>
          <small>Organizer Command</small>
        </span>
      </a>
      <nav class="nav-list">
        ${nav
          .map(
            ([id, label, icon]) => `
              <button class="nav-item ${selectedPanel === id ? "is-active" : ""}" data-action="panel" data-panel="${id}">
                ${iconSvg(icon)}
                <span>${label}</span>
              </button>
            `
          )
          .join("")}
      </nav>
      <div class="sidebar-event">
        <span class="event-type">${event.preset}</span>
        <strong>${event.title}</strong>
        <span>${event.dateRange}</span>
      </div>
      <div class="offline-card">
        <span class="pulse"></span>
        <div>
          <strong>Offline-first</strong>
          <span>${event.sync.pendingChanges} local updates queued</span>
        </div>
      </div>
    </aside>
  `;
}

function topbar(totals, queued) {
  return `
    <header class="topbar">
      <div>
        <p class="path">${event.location}</p>
        <h1>${event.title}</h1>
      </div>
      <div class="topbar-actions">
        <button class="icon-button" title="Directions" data-action="directions">${iconSvg("map")}</button>
        <label class="icon-button file-trigger" title="Capture receipt">
          ${iconSvg("camera")}
          <input type="file" accept="image/*" capture="environment" data-action="receipt" />
        </label>
        <button class="sync-button" data-action="sync">
          ${iconSvg("cloud")}
          <span>${queued ? `${queued} queued` : "Synced"}</span>
        </button>
        <button class="reset-button" data-action="reset">Reset demo</button>
      </div>
      <div class="mobile-metrics">
        <span>${totals.progress}% ready</span>
        <span>${money(totals.planTotal)} planned</span>
      </div>
    </header>
  `;
}

function heroCommand(totals, score) {
  return `
    <section class="command-hero">
      <div class="hero-copy">
        <h2>Run the whole party from one clear command surface.</h2>
        <p>Owner-controlled setup, helper-owned updates, offline-safe changes, and deterministic food, supply, lodging, and money logic.</p>
      </div>
      <div class="metric-strip" aria-label="Event readiness">
        ${metric("Readiness", `${totals.progress}%`, "Tasks + supplies")}
        ${metric("Trust", `${score}`, "Realtime score")}
        ${metric("Planned", money(totals.planTotal), "Meals, supplies, lodging")}
        ${metric("Budget", money(totals.remainingBudget), totals.remainingBudget >= 0 ? "Remaining" : "Over")}
      </div>
    </section>
  `;
}

function panelTabs() {
  const tabs = [
    ["command", "Run board"],
    ["meals", "Meal intelligence"],
    ["money", "Expense control"],
    ["crew", "Crew ownership"]
  ];
  return `
    <div class="tabbar" role="tablist">
      ${tabs
        .map(
          ([id, label]) => `
            <button role="tab" class="${selectedPanel === id ? "is-selected" : ""}" data-action="panel" data-panel="${id}">
              ${label}
            </button>
          `
        )
        .join("")}
    </div>
  `;
}

function commandPanel(shopping, selectedMeal) {
  return `
    <div class="split-layout">
      <section class="timeline-panel">
        <div class="section-heading">
          <h3>Next best actions</h3>
          <span>${event.tasks.filter((task) => !task.done).length} open</span>
        </div>
        <ol class="action-list">
          ${event.tasks
            .map((task) => {
              const owner = personById(event, task.ownerId);
              return `
                <li class="${task.done ? "is-done" : ""}">
                  <label class="check-row">
                    <input type="checkbox" ${task.done ? "checked" : ""} data-action="toggle-task" data-id="${task.id}" />
                    <span></span>
                  </label>
                  <div>
                    <strong>${task.title}</strong>
                    <p>${task.kind} · due ${task.due} · ${owner?.name ?? "Unassigned"}</p>
                  </div>
                  <button class="tiny-button" data-action="select-user" data-user="${task.ownerId}">Owner</button>
                </li>
              `;
            })
            .join("")}
        </ol>
      </section>
      <section class="shopping-panel">
        <div class="section-heading">
          <h3>Live shopping merge</h3>
          <span>${shopping.length} lines</span>
        </div>
        <div class="shopping-list">
          ${shopping
            .slice(0, 9)
            .map((line) => {
              const owner = personById(event, line.ownerId);
              const shared = line.mealIds.length > 1;
              return `
                <article class="shopping-row ${line.done ? "is-done" : ""}">
                  <label class="check-row">
                    <input type="checkbox" ${line.done ? "checked" : ""} data-action="toggle-supply" data-id="${line.id}" />
                    <span></span>
                  </label>
                  <div>
                    <strong>${line.name}</strong>
                    <p>${line.quantity} ${line.unit} · ${line.category}${shared ? " · merged across meals" : ""}</p>
                  </div>
                  ${avatar(owner)}
                </article>
              `;
            })
            .join("")}
        </div>
      </section>
      <section class="meal-focus">
        <div class="section-heading">
          <h3>${selectedMeal.title}</h3>
          <span>${selectedMeal.status}</span>
        </div>
        ${mealScaleCard(selectedMeal)}
      </section>
    </div>
  `;
}

function mealsPanel(selectedMeal) {
  return `
    <div class="meal-layout">
      <section>
        <div class="section-heading">
          <h3>Meals</h3>
          <span>${event.adults} adults · ${event.children} kids</span>
        </div>
        <div class="meal-list">
          ${event.meals
            .map((meal) => {
              const owner = personById(event, meal.ownerId);
              return `
                <button class="meal-row ${meal.id === selectedMeal.id ? "is-active" : ""}" data-action="select-meal" data-id="${meal.id}">
                  <span class="service-dot"></span>
                  <span>
                    <strong>${meal.title}</strong>
                    <small>${meal.day} · ${meal.time} · ${owner?.name ?? "Unassigned"}</small>
                  </span>
                  <em>${money(meal.estimatedCost)}</em>
                </button>
              `;
            })
            .join("")}
        </div>
      </section>
      <section class="meal-detail">
        ${mealScaleCard(selectedMeal)}
      </section>
    </div>
  `;
}

function mealScaleCard(meal) {
  const items = scaledMealItems(meal, event);
  return `
    <div class="scale-card">
      <div class="scale-header">
        <div>
          <p>${meal.service} · ${meal.day} ${meal.time}</p>
          <h4>${meal.title}</h4>
        </div>
        ${avatar(personById(event, meal.ownerId))}
      </div>
      <div class="equipment-grid">
        ${metric("Prep", `${Math.max(35, items.length * 18)}m`, "Estimated")}
        ${metric("Pans", `${Math.max(2, Math.ceil(event.guestCount / 12))}`, "Sheet pans")}
        ${metric("Buffer", `${meal.buffer}%`, "Extra quantity")}
      </div>
      <ul class="ingredient-list">
        ${items
          .map(
            (item) => `
              <li>
                <span>
                  <strong>${item.name}</strong>
                  <small>${item.math}</small>
                </span>
                <em>${item.quantity} ${item.unit}</em>
              </li>
            `
          )
          .join("")}
      </ul>
    </div>
  `;
}

function moneyPanel(totals) {
  const balances = settleUp(event);
  return `
    <div class="money-layout">
      <section>
        <div class="section-heading">
          <h3>Expense ledger</h3>
          <span>${money(totals.expenses)} captured</span>
        </div>
        <div class="expense-list">
          ${event.expenses
            .map((expense) => {
              const payer = personById(event, expense.paidBy);
              return `
                <article class="expense-row">
                  ${avatar(payer)}
                  <div>
                    <strong>${expense.title}</strong>
                    <p>${expense.category} · ${expense.split} · ${expense.receipt ? "receipt attached" : "needs receipt"}</p>
                  </div>
                  <em>${money(expense.amount)}</em>
                </article>
              `;
            })
            .join("")}
        </div>
      </section>
      <section>
        <div class="section-heading">
          <h3>Settlement preview</h3>
          <span>adult split</span>
        </div>
        <div class="balance-list">
          ${balances
            .map(
              (row) => `
                <article class="balance-row">
                  ${avatar(row.person)}
                  <span>
                    <strong>${row.person.name}</strong>
                    <small>Paid ${money(row.paid)} · owes ${money(row.owes)}</small>
                  </span>
                  <em class="${row.net >= 0 ? "positive" : "negative"}">${row.net >= 0 ? "+" : ""}${money(row.net)}</em>
                </article>
              `
            )
            .join("")}
        </div>
      </section>
    </div>
  `;
}

function crewPanel() {
  return `
    <div class="crew-grid">
      ${event.people
        .map((person) => {
          const taskCount = event.tasks.filter((task) => task.ownerId === person.id && !task.done).length;
          const supplyCount = event.supplies.filter((supply) => supply.ownerId === person.id && !supply.done).length;
          const mealCount = event.meals.filter((meal) => meal.ownerId === person.id).length;
          return `
            <button class="person-card ${selectedUserId === person.id ? "is-active" : ""}" data-action="select-user" data-user="${person.id}">
              ${avatar(person)}
              <span>
                <strong>${person.name}</strong>
                <small>${person.role} · ${person.phone}</small>
              </span>
              <em>${taskCount + supplyCount + mealCount} owned</em>
            </button>
          `;
        })
        .join("")}
    </div>
  `;
}

function inspector(user, trust, totals, queue) {
  const mineTasks = event.tasks.filter((task) => task.ownerId === user.id);
  const mineMeals = event.meals.filter((meal) => meal.ownerId === user.id);
  const mineSupplies = event.supplies.filter((supply) => supply.ownerId === user.id);
  return `
    <section class="inspector-card user-summary">
      <div class="inspector-title">
        <span>Selected helper</span>
        ${avatar(user, "large")}
      </div>
      <h2>${user.name}</h2>
      <p>${user.role} · can update owned responsibilities, receipts, notes, and assigned meal ingredients.</p>
      <div class="ownership-grid">
        ${metric("Tasks", mineTasks.length, "assigned")}
        ${metric("Meals", mineMeals.length, "owned")}
        ${metric("Supplies", mineSupplies.length, "to bring")}
      </div>
    </section>
    <section class="inspector-card trust-card">
      <div class="score-ring" style="--score:${trust.score}">
        <strong>${trust.score}</strong>
        <span>trust</span>
      </div>
      <div class="signal-list">
        ${trust.signals
          .map(
            (signal) => `
              <article class="${signal.tone}">
                <span></span>
                <div>
                  <strong>${signal.label}: ${signal.value}</strong>
                  <p>${signal.detail}</p>
                </div>
              </article>
            `
          )
          .join("")}
      </div>
    </section>
    <section class="inspector-card">
      <div class="section-heading compact">
        <h3>Sync queue</h3>
        <span>${queue.length}</span>
      </div>
      <div class="queue-list">
        ${
          queue.length
            ? queue
                .slice(-4)
                .reverse()
                .map((item) => `<p><strong>${item.type}</strong><span>${new Date(item.createdAt).toLocaleTimeString()}</span></p>`)
                .join("")
            : "<p><strong>No pending changes</strong><span>Ready</span></p>"
        }
      </div>
    </section>
    <section class="inspector-card venue-card">
      <div class="section-heading compact">
        <h3>Venue</h3>
        <span>Maps ready</span>
      </div>
      <p>${event.address}</p>
      <button class="wide-button" data-action="directions">${iconSvg("map")} Open directions</button>
    </section>
  `;
}

function metric(label, value, detail) {
  return `
    <article class="metric">
      <span>${label}</span>
      <strong>${value}</strong>
      <small>${detail}</small>
    </article>
  `;
}

function avatar(person, size = "") {
  if (!person) return `<span class="avatar ${size}">?</span>`;
  return `<span class="avatar ${size}" style="--hue:${person.hue ?? 180}">${initials(person.name)}</span>`;
}

function bindEvents() {
  document.querySelectorAll("[data-action='panel']").forEach((button) => {
    button.addEventListener("click", () => {
      selectedPanel = button.dataset.panel;
      render();
    });
  });

  document.querySelectorAll("[data-action='select-meal']").forEach((button) => {
    button.addEventListener("click", () => {
      selectedMealId = button.dataset.id;
      selectedPanel = "meals";
      render();
    });
  });

  document.querySelectorAll("[data-action='select-user']").forEach((button) => {
    button.addEventListener("click", () => {
      selectedUserId = button.dataset.user;
      render();
    });
  });

  document.querySelectorAll("[data-action='toggle-task']").forEach((input) => {
    input.addEventListener("change", () => {
      const next = {
        ...event,
        tasks: event.tasks.map((task) => (task.id === input.dataset.id ? { ...task, done: input.checked } : task))
      };
      setEvent(next, "task.updated", { id: input.dataset.id, done: input.checked });
    });
  });

  document.querySelectorAll("[data-action='toggle-supply']").forEach((input) => {
    input.addEventListener("change", () => {
      const next = {
        ...event,
        supplies: event.supplies.map((supply) =>
          supply.id === input.dataset.id ? { ...supply, done: input.checked } : supply
        )
      };
      setEvent(next, "shopping.updated", { id: input.dataset.id, done: input.checked });
    });
  });

  document.querySelectorAll("[data-action='directions']").forEach((button) => {
    button.addEventListener("click", () => {
      window.open(`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(event.address)}`, "_blank", "noopener");
    });
  });

  document.querySelector("[data-action='receipt']")?.addEventListener("change", (input) => {
    if (!input.target.files?.length) return;
    const next = {
      ...event,
      expenses: event.expenses.map((expense) => (expense.receipt ? expense : { ...expense, receipt: true }))
    };
    setEvent(next, "receipt.captured", { fileName: input.target.files[0].name });
  });

  document.querySelector("[data-action='sync']")?.addEventListener("click", () => {
    clearQueue();
    event = { ...event, sync: { ...event.sync, pendingChanges: 0, lastSyncedAt: "just now" } };
    saveEvent(event);
    render();
  });

  document.querySelector("[data-action='reset']")?.addEventListener("click", () => {
    event = resetEvent(seedEvent);
    selectedMealId = event.meals[0].id;
    selectedUserId = event.organizerId;
    selectedPanel = "command";
    render();
  });
}

function iconSvg(name) {
  const icons = {
    bolt: "M13 2 4 14h7l-1 8 9-12h-7l1-8Z",
    utensils: "M4 3v8M8 3v8M4 7h4M6 11v10M16 3v18M16 3c3 2 4 5 4 8 0 2-1 4-4 4",
    receipt: "M6 3h12v18l-2-1-2 1-2-1-2 1-2-1-2 1V3Zm3 5h6M9 12h6M9 16h4",
    users: "M8 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm8 2a3 3 0 1 0 0-6 3 3 0 0 0 0 6ZM2 21a6 6 0 0 1 12 0M13 21a5 5 0 0 1 8 0",
    map: "M9 18 3 21V6l6-3 6 3 6-3v15l-6 3-6-3Zm0 0V3m6 18V6",
    camera: "M4 7h3l2-3h6l2 3h3v13H4V7Zm8 10a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z",
    cloud: "M7 18h10a4 4 0 0 0 0-8 6 6 0 0 0-11-2A5 5 0 0 0 7 18Z"
  };

  return `
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <path d="${icons[name] ?? icons.bolt}" />
    </svg>
  `;
}

render();
