#!/usr/bin/env python3
"""Fix all generic recipe names to exciting modern names"""
import json
import random

# Style C naming components
EXCITING_PREFIXES = [
    'Fiery', 'Smoky', 'Zesty', 'Creamy', 'Sticky', 'Crispy',
    'Golden', 'Blazing', 'Sizzling', 'Tangy', 'Spicy', 'Loaded',
    'Ultimate', 'Supreme', 'Epic', 'Power', 'Mega', 'Super'
]

FLAVOR_DESCRIPTORS = [
    'Cajun', 'Garlic Herb', 'Peri-Peri', 'Korean BBQ', 'Chipotle',
    'Harissa', 'Teriyaki', 'Honey Mustard', 'Lemon Pepper',
    'Thai Coconut', 'Mediterranean', 'Mexican Spiced', 'Indian Spiced',
    'Sesame Ginger', 'Buffalo', 'BBQ', 'Tikka', 'Satay'
]

CONTAINER_TYPES = [
    'Power Bowl', 'Protein Pot', 'Fuel Box', 'Energy Bowl',
    'Build Bowl', 'Lift Pot', 'Macro Bowl', 'Prep Box'
]

def generate_exciting_name(protein, recipe_type, meal_type):
    """Generate exciting Style C name"""
    prefix = random.choice(EXCITING_PREFIXES)
    flavor = random.choice(FLAVOR_DESCRIPTORS)
    protein_clean = protein.replace('_', ' ').replace(' mince', '').replace(' fillet', '').replace(' breast', '').title()
    
    if 'burger' in recipe_type.lower():
        return f"{prefix} {flavor} {protein_clean} Smash Burger"
    elif 'pasta' in recipe_type.lower() or 'noodle' in recipe_type.lower():
        return f"{prefix} {flavor} {protein_clean} Pasta Pot"
    elif 'curry' in recipe_type.lower() or 'masala' in recipe_type.lower():
        return f"{prefix} {flavor} {protein_clean} Curry Box"
    elif 'flatbread' in recipe_type.lower() or 'wrap' in recipe_type.lower():
        return f"{prefix} {flavor} {protein_clean} Flatbread"
    elif 'breakfast' in meal_type.lower() or 'pancake' in recipe_type.lower():
        return f"{prefix} {protein_clean} Protein Stack"
    else:
        container = random.choice(CONTAINER_TYPES)
        return f"{prefix} {flavor} {protein_clean} {container}"

# Load recipes
with open('preppro_500_recipes.json', 'r', encoding='utf-8') as f:
    recipes = json.load(f)

print("Renaming generic recipes to exciting names...")
renamed = 0

for recipe in recipes:
    title = recipe['title']
    
    # Check if name is generic (has numbers or basic "bowl/meal prep" structure)
    is_generic = (
        any(word in title.lower() for word in ['bowl', 'meal prep', 'power bowl', 'energy bowl']) and
        any(c.isdigit() for c in title)
    ) or (
        'bowl' in title.lower() and len(title.split()) <= 4
    )
    
    if is_generic:
        # Extract protein from ingredients
        ingredients = recipe.get('ingredients', [])
        protein = ingredients[0]['name'] if ingredients else 'Protein'
        
        # Extract recipe type hints
        meal_types = recipe.get('mealTypes', [])
        tags = recipe.get('tags', [])
        meal_type = meal_types[0] if meal_types else 'lunch'
        
        # Determine recipe type from ingredients/tags
        recipe_type = 'bowl'
        for ing in ingredients:
            ing_name = ing['name'].lower()
            if 'pasta' in ing_name or 'noodle' in ing_name:
                recipe_type = 'pasta'
                break
            elif 'flatbread' in ing_name or 'wrap' in ing_name:
                recipe_type = 'flatbread'
                break
        
        for tag in tags:
            if 'burger' in tag:
                recipe_type = 'burger'
            elif 'curry' in tag:
                recipe_type = 'curry'
        
        # Generate new exciting name
        new_name = generate_exciting_name(protein, recipe_type, meal_type)
        recipe['title'] = new_name
        renamed += 1

print(f"✓ Renamed {renamed} recipes to exciting names")

# Save updated recipes
with open('preppro_500_recipes.json', 'w', encoding='utf-8') as f:
    json.dump(recipes, f, indent=2, ensure_ascii=False)

print(f"✓ Saved updated dataset with exciting names!")
