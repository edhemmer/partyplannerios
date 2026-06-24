const EVENT_KEY = "party-planner.command.event.v1";
const QUEUE_KEY = "party-planner.command.queue.v1";

export function loadEvent(fallback) {
  const stored = read(EVENT_KEY);
  return stored ?? fallback;
}

export function saveEvent(event) {
  localStorage.setItem(EVENT_KEY, JSON.stringify(event));
}

export function resetEvent(fallback) {
  localStorage.removeItem(EVENT_KEY);
  localStorage.removeItem(QUEUE_KEY);
  saveEvent(fallback);
  return fallback;
}

export function queueMutation(type, payload) {
  const queue = listQueue();
  queue.push({
    id: `mut-${Date.now()}-${Math.random().toString(16).slice(2)}`,
    type,
    payload,
    createdAt: new Date().toISOString()
  });
  localStorage.setItem(QUEUE_KEY, JSON.stringify(queue));
  return queue;
}

export function listQueue() {
  return read(QUEUE_KEY) ?? [];
}

export function clearQueue() {
  localStorage.setItem(QUEUE_KEY, JSON.stringify([]));
}

function read(key) {
  try {
    const raw = localStorage.getItem(key);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}
