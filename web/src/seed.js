export const seedEvent = {
  id: "evt-weekend-birthday",
  title: "Maya's 40th Weekend",
  preset: "Birthday",
  dateRange: "Aug 14-16",
  location: "Lake House, Traverse City",
  address: "1820 Harbor View Drive, Traverse City, MI",
  organizerId: "u-ava",
  guestCount: 28,
  adults: 22,
  children: 6,
  budgetTarget: 3850,
  sync: {
    state: "offline-ready",
    lastSyncedAt: "2 min ago",
    pendingChanges: 3,
    conflicts: 0
  },
  people: [
    { id: "u-ava", name: "Ava", role: "Owner", phone: "555-0101", isAdult: true, hue: 4 },
    { id: "u-ben", name: "Ben", role: "Cohost", phone: "555-0140", isAdult: true, hue: 174 },
    { id: "u-zoe", name: "Zoe", role: "Helper", phone: "555-0128", isAdult: true, hue: 210 },
    { id: "u-max", name: "Max", role: "Helper", phone: "555-0188", isAdult: true, hue: 42 },
    { id: "u-nia", name: "Nia", role: "Guest", phone: "555-0162", isAdult: true, hue: 326 }
  ],
  meals: [
    {
      id: "meal-friday-dinner",
      title: "Friday taco bar",
      service: "Dinner",
      day: "Friday",
      time: "6:30 PM",
      ownerId: "u-ben",
      status: "In progress",
      buffer: 15,
      estimatedCost: 286,
      items: [
        { name: "Chicken thighs", perAdult: 0.35, perChild: 0.18, unit: "lb", category: "protein" },
        { name: "Tortillas", perAdult: 3, perChild: 2, unit: "ea", category: "side" },
        { name: "Salsa", fixed: 5, unit: "jar", category: "condiment" }
      ]
    },
    {
      id: "meal-sat-brunch",
      title: "Saturday brunch",
      service: "Breakfast",
      day: "Saturday",
      time: "10:00 AM",
      ownerId: "u-zoe",
      status: "Needs review",
      buffer: 12,
      estimatedCost: 218,
      items: [
        { name: "Eggs", perAdult: 2, perChild: 1, unit: "ea", category: "protein" },
        { name: "Coffee", perAdult: 0.08, perChild: 0, unit: "lb", category: "drink" },
        { name: "Fruit trays", fixed: 4, unit: "tray", category: "side" }
      ]
    },
    {
      id: "meal-sat-dinner",
      title: "Grill night",
      service: "Dinner",
      day: "Saturday",
      time: "7:00 PM",
      ownerId: "u-max",
      status: "Assigned",
      buffer: 18,
      estimatedCost: 432,
      items: [
        { name: "Burger patties", perAdult: 1.5, perChild: 1, unit: "ea", category: "protein" },
        { name: "Buns", perAdult: 1.5, perChild: 1, unit: "ea", category: "side" },
        { name: "Charcoal", fixed: 2, unit: "bag", category: "equipment" }
      ]
    }
  ],
  supplies: [
    { id: "s-plates", name: "Dinner plates", category: "Supplies", qty: 76, unit: "count", ownerId: "u-nia", done: false, cost: 34 },
    { id: "s-water", name: "Bottled water", category: "Bar", qty: 180, unit: "bottles", ownerId: "u-ava", done: false, cost: 62 },
    { id: "s-ice", name: "Ice", category: "Bar", qty: 64, unit: "lb", ownerId: "u-ben", done: true, cost: 28 },
    { id: "s-chairs", name: "Extra chairs", category: "Setup", qty: 12, unit: "count", ownerId: "u-zoe", done: false, cost: 144 },
    { id: "s-speaker", name: "Speaker + playlist", category: "Music", qty: 1, unit: "set", ownerId: "u-max", done: false, cost: 0 }
  ],
  tasks: [
    { id: "t-parking", title: "Confirm parking and arrival signs", kind: "Setup", ownerId: "u-ava", due: "Thu 4:00 PM", done: false },
    { id: "t-allergies", title: "Collect final allergy notes", kind: "Guests", ownerId: "u-ben", due: "Wed 8:00 PM", done: false },
    { id: "t-coolers", title: "Stage coolers by beverage type", kind: "Bar", ownerId: "u-nia", due: "Fri 2:30 PM", done: false },
    { id: "t-trash", title: "Assign trash and leftovers crew", kind: "Breakdown", ownerId: "u-zoe", due: "Fri 1:00 PM", done: true }
  ],
  expenses: [
    { id: "e-lodging", title: "Lake house deposit", category: "Lodging", paidBy: "u-ava", amount: 1200, split: "room-weighted", receipt: true },
    { id: "e-tacos", title: "Taco bar groceries", category: "Meals", paidBy: "u-ben", amount: 214.83, split: "assigned-meal", receipt: true },
    { id: "e-decor", title: "Decor and signs", category: "Decor", paidBy: "u-nia", amount: 92.41, split: "equal", receipt: false }
  ],
  rooms: [
    { id: "r-king", name: "King suite", occupants: ["u-ava"], payerId: "u-ava", price: 420 },
    { id: "r-bunk", name: "Bunk room", occupants: ["u-ben", "u-zoe"], payerId: "u-ben", price: 360 },
    { id: "r-loft", name: "Loft", occupants: ["u-max", "u-nia"], payerId: "u-max", price: 280 }
  ],
  board: [
    { id: "n-1", authorId: "u-ben", text: "Taco ingredients are 80% bought. Need one more cooler.", scope: "Board", at: "9:14 AM" },
    { id: "n-2", authorId: "u-ava", text: "Venue confirmed early arrival at 1:00 PM Friday.", scope: "Owner", at: "8:32 AM" }
  ]
};
