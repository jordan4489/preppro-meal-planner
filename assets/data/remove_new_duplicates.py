import json

with open('preppro_500_recipes.json') as f:
    recipes = json.load(f)

# Check for duplicates
from collections import Counter
titles = [r['title'] for r in recipes]
duplicates = {title: count for title, count in Counter(titles).items() if count > 1}

print("Duplicate recipes found:")
for title, count in sorted(duplicates.items(), key=lambda x: -x[1]):
    print(f"  {count}x - {title}")

# Remove duplicates, keeping only the first occurrence
seen = set()
unique_recipes = []
removed_count = 0

for recipe in recipes:
    title = recipe['title']
    if title not in seen:
        seen.add(title)
        unique_recipes.append(recipe)
    else:
        removed_count += 1
        print(f"  Removing duplicate: {title}")

# Save
with open('preppro_500_recipes.json', 'w') as f:
    json.dump(unique_recipes, f, indent=2)

print(f"\n✓ Removed {removed_count} duplicate recipes")
print(f"✓ Total recipes now: {len(unique_recipes)}")

breakfast_count = sum(1 for r in unique_recipes if 'breakfast' in [m.lower() for m in r.get('mealTypes', [])])
print(f"✓ Total breakfast recipes: {breakfast_count}")
