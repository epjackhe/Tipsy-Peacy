import Foundation

// === Classic Cocktails (canonical-ish, for demo) ===
let classics: [Classic] = [
    Classic(name: "Daiquiri", family: "Sour", vector: TasteVector([2.5, 0.5, 2.5, 4.0, 0.0, 1.0])),
    Classic(name: "Margarita", family: "Sour", vector: TasteVector([3.0, 0.5, 2.5, 4.0, 0.0, 1.5])),
    Classic(name: "Old Fashioned", family: "Old Fashioned", vector: TasteVector([1.5, 1.5, 4.0, 0.0, 0.0, 2.0])),
    Classic(name: "Negroni", family: "Negroni", vector: TasteVector([1.0, 4.0, 3.0, 0.0, 0.0, 3.0])),
    Classic(name: "Paper Plane", family: "Modern Sour", vector: TasteVector([2.0, 3.0, 2.5, 2.5, 0.0, 2.5])),
    Classic(name: "Whiskey Sour", family: "Sour", vector: TasteVector([2.5, 0.5, 3.0, 3.5, 0.0, 1.5]))
]

// === Double Chicken Please – Coop rough demo vectors (POC) ===
// These are illustrative for the demo; you can tweak live in the UI.
let dcpDrinks: [Drink] = [
    Drink(name: "Waldorf Salad", venue: "Double Chicken Please – Coop",
          vector: TasteVector([2.0, 1.0, 3.0, 1.5, 0.5, 3.0]),
          notes: "Scotch/apple/walnut bitters/soda; crisp, aromatic"),
    Drink(name: "Japanese Cold Noodle", venue: "Double Chicken Please – Coop",
          vector: TasteVector([1.5, 1.0, 2.5, 1.5, 0.5, 3.5]),
          notes: "Clean, savory-aromatic, chilled highball vibe"),
    Drink(name: "Key Lime Pie", venue: "Double Chicken Please – Coop",
          vector: TasteVector([3.5, 0.5, 2.0, 3.5, 0.0, 2.5]),
          notes: "Dessert-leaning sour; creamy aroma and citrus"),
    Drink(name: "Mango Sticky Rice", venue: "Double Chicken Please – Coop",
          vector: TasteVector([4.0, 0.5, 2.0, 2.0, 0.0, 2.0]),
          notes: "Tropical, rich body perception, gentle aroma")
]
