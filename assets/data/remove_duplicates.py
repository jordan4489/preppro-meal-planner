import json

with open('preppro_500_recipes.json') as f:
    recipes = json.load(f)

print(f"Starting with: {len(recipes)} recipes")

# Remove duplicates - keep first occurrence of each title
seen_titles = set()
unique_recipes = []

for recipe in recipes:
    title = recipe['title']
    if title not in seen_titles:
        seen_titles.add(title)
        unique_recipes.append(recipe)

removed = len(recipes) - len(unique_recipes)

# Save cleaned recipes
with open('preppro_500_recipes.json', 'w') as f:
    json.dump(unique_recipes, f, indent=2)

print(f"Removed {removed} duplicate recipes")
print(f"Final count: {len(unique_recipes)} unique recipes")
