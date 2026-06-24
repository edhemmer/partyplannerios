export function money(value) {
  return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value);
}

export function personById(event, id) {
  return event.people.find((person) => person.id === id);
}

export function initials(name) {
  return name
    .split(" ")
    .map((part) => part[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();
}

export function scaledMealItems(meal, event) {
  return meal.items.map((item) => {
    const base =
      item.fixed ??
      event.adults * (item.perAdult ?? 0) +
        event.children * (item.perChild ?? Math.max((item.perAdult ?? 0) * 0.55, 0));
    const buffered = Math.ceil(base * (1 + meal.buffer / 100));
    return {
      ...item,
      quantity: buffered,
      math: item.fixed
        ? "fixed event amount"
        : `${event.adults} adults + ${event.children} kids + ${meal.buffer}% buffer`
    };
  });
}

export function aggregateShopping(event) {
  const lines = new Map();

  for (const meal of event.meals) {
    for (const item of scaledMealItems(meal, event)) {
      const key = `${item.name.toLowerCase()}::${item.unit}`;
      const existing = lines.get(key);
      if (existing) {
        existing.quantity += item.quantity;
        existing.mealIds.push(meal.id);
        existing.contributions.push({ mealId: meal.id, quantity: item.quantity });
      } else {
        lines.set(key, {
          id: `line-${key.replace(/[^a-z0-9]/g, "-")}`,
          name: item.name,
          category: item.category,
          unit: item.unit,
          quantity: item.quantity,
          ownerId: meal.ownerId,
          mealIds: [meal.id],
          contributions: [{ mealId: meal.id, quantity: item.quantity }],
          done: false
        });
      }
    }
  }

  for (const supply of event.supplies) {
    lines.set(`supply::${supply.id}`, {
      id: supply.id,
      name: supply.name,
      category: supply.category,
      unit: supply.unit,
      quantity: supply.qty,
      ownerId: supply.ownerId,
      mealIds: [],
      contributions: [],
      done: supply.done,
      cost: supply.cost
    });
  }

  return Array.from(lines.values()).sort((a, b) => {
    if (a.done !== b.done) return a.done ? 1 : -1;
    if (a.category !== b.category) return a.category.localeCompare(b.category);
    return a.name.localeCompare(b.name);
  });
}

export function eventTotals(event) {
  const mealEstimate = event.meals.reduce((sum, meal) => sum + meal.estimatedCost, 0);
  const supplyEstimate = event.supplies.reduce((sum, item) => sum + item.cost, 0);
  const expenses = event.expenses.reduce((sum, expense) => sum + expense.amount, 0);
  const roomTotal = event.rooms.reduce((sum, room) => sum + room.price, 0);
  const assignedTasks = event.tasks.filter((task) => !task.done).length;
  const receiptsMissing = event.expenses.filter((expense) => !expense.receipt).length;
  const planTotal = mealEstimate + supplyEstimate + roomTotal;

  return {
    mealEstimate,
    supplyEstimate,
    expenses,
    roomTotal,
    planTotal,
    remainingBudget: event.budgetTarget - Math.max(planTotal, expenses),
    assignedTasks,
    receiptsMissing,
    progress: Math.round(
      ((event.tasks.filter((task) => task.done).length + event.supplies.filter((item) => item.done).length) /
        Math.max(1, event.tasks.length + event.supplies.length)) *
        100
    )
  };
}

export function settleUp(event) {
  const attendees = event.people.filter((person) => person.isAdult);
  const paid = new Map(attendees.map((person) => [person.id, 0]));
  const owes = new Map(attendees.map((person) => [person.id, 0]));

  for (const expense of event.expenses) {
    paid.set(expense.paidBy, (paid.get(expense.paidBy) ?? 0) + expense.amount);
    const share = roundMoney(expense.amount / attendees.length);
    for (const attendee of attendees) owes.set(attendee.id, (owes.get(attendee.id) ?? 0) + share);
  }

  for (const room of event.rooms) {
    paid.set(room.payerId, (paid.get(room.payerId) ?? 0) + room.price);
    const roomShare = roundMoney(room.price / Math.max(1, room.occupants.length));
    for (const occupantId of room.occupants) {
      owes.set(occupantId, (owes.get(occupantId) ?? 0) + roomShare);
    }
  }

  return attendees
    .map((person) => {
      const paidAmount = paid.get(person.id) ?? 0;
      const owesAmount = owes.get(person.id) ?? 0;
      return {
        person,
        paid: paidAmount,
        owes: owesAmount,
        net: roundMoney(paidAmount - owesAmount)
      };
    })
    .sort((a, b) => b.net - a.net);
}

export function trustSignals(event) {
  const totals = eventTotals(event);
  const signals = [
    {
      label: "Backend contract",
      value: "Ready to wire",
      tone: "good",
      detail: "Supabase adapter boundary is isolated from UI."
    },
    {
      label: "Offline safety",
      value: `${event.sync.pendingChanges} queued`,
      tone: event.sync.pendingChanges ? "warn" : "good",
      detail: "Changes persist locally before sync."
    },
    {
      label: "Receipts",
      value: totals.receiptsMissing ? `${totals.receiptsMissing} missing` : "Complete",
      tone: totals.receiptsMissing ? "warn" : "good",
      detail: "Require review before settlement."
    },
    {
      label: "Budget",
      value: totals.remainingBudget >= 0 ? "On track" : "Over target",
      tone: totals.remainingBudget >= 0 ? "good" : "danger",
      detail: `${money(Math.abs(totals.remainingBudget))} ${totals.remainingBudget >= 0 ? "remaining" : "over"}`
    }
  ];

  const score = Math.max(
    0,
    100 -
      event.sync.pendingChanges * 3 -
      event.sync.conflicts * 12 -
      totals.receiptsMissing * 7 -
      totals.assignedTasks * 2
  );

  return { score, signals };
}

function roundMoney(value) {
  return Math.round(value * 100) / 100;
}
