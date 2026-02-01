import json

with open('preppro_500_recipes.json') as f:
    recipes = json.load(f)

# Get all breakfast recipes
all_breakfast = [r for r in recipes if 'breakfast' in [m.lower() for m in r.get('mealTypes', [])]]

print(f"Total breakfast recipes: {len(all_breakfast)}\n")
print("All breakfast recipes:")
for r in all_breakfast:
    title = r['title']
    tags = r.get('tags', [])
    kcal = r.get('nutrition', {}).get('kcal', 0)
    print(f"- {title}")
    print(f"  Tags: {tags}, Kcal: {kcal}\n")
