import json

with open('preppro_500_recipes.json') as f:
    recipes = json.load(f)

# Find chicken recipes with breakfast tag
breakfast_chicken = [r for r in recipes if 'breakfast' in [m.lower() for m in r.get('mealTypes', [])] and 'chicken' in r.get('title', '').lower()]

print(f"Found {len(breakfast_chicken)} chicken recipes tagged as breakfast:\n")
for r in breakfast_chicken[:10]:
    print(f"- {r['title']}")
    print(f"  Meal types: {r.get('mealTypes', [])}\n")

# Show all breakfast recipes
all_breakfast = [r for r in recipes if 'breakfast' in [m.lower() for m in r.get('mealTypes', [])]]
print(f"\nTotal breakfast recipes: {len(all_breakfast)}")
print("First 10 breakfast recipes:")
for r in all_breakfast[:10]:
    print(f"- {r['title']}")
    print(f"  Types: {r.get('mealTypes', [])}")
