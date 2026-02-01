import json

with open('preppro_500_recipes.json') as f:
    recipes = json.load(f)

# Recipes that should be lunch/dinner, not breakfast
problematic_titles = [
    "Blazing Indian Spiced Chicken Pasta Pot",
    "Smoky Chicken Protein Stack",
    "Epic Teriyaki Chicken Pasta Pot",
    "Blazing Chicken Protein Stack",
    "Super Chicken Protein Stack",
    "Supreme Chicken Protein Stack",
    "Crispy Korean BBQ Chicken Pasta Pot",
    "Sticky Chicken Protein Stack",
    "Power Chicken Protein Stack"
]

fixed_count = 0
for recipe in recipes:
    if recipe['title'] in problematic_titles:
        # Change from breakfast to lunch
        recipe['mealTypes'] = ['lunch']
        print(f"Fixed: {recipe['title']} -> lunch")
        fixed_count += 1

# Save fixed recipes
with open('preppro_500_recipes.json', 'w') as f:
    json.dump(recipes, f, indent=2)

print(f"\nRecipe data updated! Fixed {fixed_count} recipes.")
