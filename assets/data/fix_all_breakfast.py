import json

with open('preppro_500_recipes.json') as f:
    recipes = json.load(f)

# Move all current breakfast items to lunch (they're too heavy)
for recipe in recipes:
    if 'breakfast' in [m.lower() for m in recipe.get('mealTypes', [])]:
        recipe['mealTypes'] = ['lunch']

# Add proper breakfast recipes (light, quick)
breakfast_recipes = [
    {
        "id": "b001",
        "title": "Greek Yogurt Granola Bowl",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 280.0,
            "protein_g": 18.0,
            "carbs_g": 35.0,
            "fat_g": 8.0
        },
        "ingredients": [
            {"name": "greek yogurt", "quantity": 200, "unit": "g"},
            {"name": "granola", "quantity": 50, "unit": "g"},
            {"name": "honey", "quantity": 15, "unit": "ml"},
            {"name": "berries", "quantity": 100, "unit": "g"}
        ],
        "instructions": ["Add yogurt to bowl", "Top with granola", "Drizzle honey", "Add fresh berries"]
    },
    {
        "id": "b002",
        "title": "Protein Smoothie Bowl",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 310.0,
            "protein_g": 22.0,
            "carbs_g": 40.0,
            "fat_g": 6.0
        },
        "ingredients": [
            {"name": "protein powder", "quantity": 30, "unit": "g"},
            {"name": "banana", "quantity": 1, "unit": "medium"},
            {"name": "almond milk", "quantity": 250, "unit": "ml"},
            {"name": "granola", "quantity": 40, "unit": "g"}
        ],
        "instructions": ["Blend protein, banana, almond milk", "Pour into bowl", "Top with granola and fruit"]
    },
    {
        "id": "b003",
        "title": "Overnight Oats with Chia",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 290.0,
            "protein_g": 12.0,
            "carbs_g": 45.0,
            "fat_g": 7.0
        },
        "ingredients": [
            {"name": "rolled oats", "quantity": 50, "unit": "g"},
            {"name": "almond milk", "quantity": 200, "unit": "ml"},
            {"name": "chia seeds", "quantity": 15, "unit": "g"},
            {"name": "berries", "quantity": 80, "unit": "g"}
        ],
        "instructions": ["Mix oats with milk", "Add chia seeds", "Refrigerate overnight", "Top with berries"]
    },
    {
        "id": "b004",
        "title": "Scrambled Eggs with Toast",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 320.0,
            "protein_g": 16.0,
            "carbs_g": 28.0,
            "fat_g": 14.0
        },
        "ingredients": [
            {"name": "eggs", "quantity": 2, "unit": "large"},
            {"name": "whole wheat bread", "quantity": 2, "unit": "slice"},
            {"name": "butter", "quantity": 10, "unit": "g"},
            {"name": "cherry tomatoes", "quantity": 100, "unit": "g"}
        ],
        "instructions": ["Scramble eggs in butter", "Toast bread", "Serve with tomatoes"]
    },
    {
        "id": "b005",
        "title": "Banana Nut Butter Smoothie",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 350.0,
            "protein_g": 15.0,
            "carbs_g": 38.0,
            "fat_g": 12.0
        },
        "ingredients": [
            {"name": "banana", "quantity": 1, "unit": "medium"},
            {"name": "peanut butter", "quantity": 25, "unit": "g"},
            {"name": "almond milk", "quantity": 250, "unit": "ml"},
            {"name": "protein powder", "quantity": 20, "unit": "g"}
        ],
        "instructions": ["Blend all ingredients", "Pour into glass", "Serve immediately"]
    },
    {
        "id": "b006",
        "title": "Fruit and Honey Parfait",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 270.0,
            "protein_g": 14.0,
            "carbs_g": 42.0,
            "fat_g": 4.0
        },
        "ingredients": [
            {"name": "greek yogurt", "quantity": 180, "unit": "g"},
            {"name": "honey", "quantity": 20, "unit": "ml"},
            {"name": "mixed berries", "quantity": 120, "unit": "g"},
            {"name": "almonds", "quantity": 30, "unit": "g"}
        ],
        "instructions": ["Layer yogurt and berries", "Drizzle honey", "Top with almonds"]
    },
    {
        "id": "b007",
        "title": "Avocado Toast with Egg",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 340.0,
            "protein_g": 14.0,
            "carbs_g": 32.0,
            "fat_g": 16.0
        },
        "ingredients": [
            {"name": "whole grain bread", "quantity": 2, "unit": "slice"},
            {"name": "avocado", "quantity": 0.5, "unit": "medium"},
            {"name": "egg", "quantity": 1, "unit": "large"},
            {"name": "lemon juice", "quantity": 5, "unit": "ml"}
        ],
        "instructions": ["Toast bread", "Mash avocado with lemon", "Fry egg", "Assemble and serve"]
    },
    {
        "id": "b008",
        "title": "Protein Oatmeal with Berries",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 300.0,
            "protein_g": 18.0,
            "carbs_g": 42.0,
            "fat_g": 5.0
        },
        "ingredients": [
            {"name": "rolled oats", "quantity": 60, "unit": "g"},
            {"name": "protein powder", "quantity": 25, "unit": "g"},
            {"name": "water", "quantity": 200, "unit": "ml"},
            {"name": "mixed berries", "quantity": 100, "unit": "g"}
        ],
        "instructions": ["Cook oats in water", "Stir in protein powder", "Top with berries"]
    },
]

# Add new breakfast recipes
recipes.extend(breakfast_recipes)

# Save
with open('preppro_500_recipes.json', 'w') as f:
    json.dump(recipes, f, indent=2)

print(f"✓ Moved all 98 Protein Stacks to lunch")
print(f"✓ Added 8 new breakfast recipes:")
for b in breakfast_recipes:
    print(f"  - {b['title']}")
