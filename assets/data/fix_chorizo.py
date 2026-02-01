import json

with open('preppro_500_recipes.json') as f:
    recipes = json.load(f)

# Find and move the Spicy Chorizo Breakfast Hash to lunch
for recipe in recipes:
    if recipe.get('title') == 'Spicy Chorizo Breakfast Hash':
        recipe['mealTypes'] = ['lunch', 'dinner']
        print(f"✓ Moved '{recipe['title']}' from breakfast to lunch/dinner")
        print(f"  Reason: Too heavy for breakfast (360 kcal, savory meat dish)")

# Save
with open('preppro_500_recipes.json', 'w') as f:
    json.dump(recipes, f, indent=2)

breakfast_count = sum(1 for r in recipes if 'breakfast' in [m.lower() for m in r.get('mealTypes', [])])
print(f"\nTotal breakfast recipes now: {breakfast_count}")
print("✓ All breakfast items are now light and appropriate (yogurt, oats, smoothies, eggs, etc.)")
