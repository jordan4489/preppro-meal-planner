import json

with open('preppro_500_recipes.json') as f:
    recipes = json.load(f)

# Find all instances of "Spicy Chorizo Breakfast Hash"
chorizo_recipes = [r for r in recipes if 'chorizo' in r['title'].lower()]

print(f"Found {len(chorizo_recipes)} recipes with 'chorizo' in title:")
for r in chorizo_recipes:
    print(f"  - {r['title']} (ID: {r['id']}, MealTypes: {r['mealTypes']})")
