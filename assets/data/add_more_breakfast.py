import json

with open('preppro_500_recipes.json') as f:
    recipes = json.load(f)

# Add more breakfast recipes - variety of options
more_breakfast_recipes = [
    {
        "id": "b009",
        "title": "Acai Berry Bowl",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 320.0,
            "protein_g": 10.0,
            "carbs_g": 48.0,
            "fat_g": 10.0
        },
        "ingredients": [
            {"name": "acai puree", "quantity": 100, "unit": "g"},
            {"name": "granola", "quantity": 40, "unit": "g"},
            {"name": "almond milk", "quantity": 100, "unit": "ml"},
            {"name": "banana", "quantity": 0.5, "unit": "medium"}
        ],
        "instructions": ["Blend acai with milk", "Pour into bowl", "Top with granola and banana"]
    },
    {
        "id": "b010",
        "title": "Protein Pancakes",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 340.0,
            "protein_g": 20.0,
            "carbs_g": 38.0,
            "fat_g": 8.0
        },
        "ingredients": [
            {"name": "protein powder", "quantity": 30, "unit": "g"},
            {"name": "egg", "quantity": 2, "unit": "large"},
            {"name": "oat flour", "quantity": 40, "unit": "g"},
            {"name": "maple syrup", "quantity": 15, "unit": "ml"}
        ],
        "instructions": ["Mix protein, eggs, oat flour", "Cook on griddle", "Top with maple syrup"]
    },
    {
        "id": "b011",
        "title": "Cottage Cheese Fruit Bowl",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 280.0,
            "protein_g": 22.0,
            "carbs_g": 30.0,
            "fat_g": 5.0
        },
        "ingredients": [
            {"name": "cottage cheese", "quantity": 200, "unit": "g"},
            {"name": "mixed berries", "quantity": 120, "unit": "g"},
            {"name": "honey", "quantity": 10, "unit": "ml"},
            {"name": "almonds", "quantity": 25, "unit": "g"}
        ],
        "instructions": ["Add cottage cheese to bowl", "Top with berries", "Drizzle honey", "Add almonds"]
    },
    {
        "id": "b012",
        "title": "Green Smoothie",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 290.0,
            "protein_g": 15.0,
            "carbs_g": 35.0,
            "fat_g": 8.0
        },
        "ingredients": [
            {"name": "spinach", "quantity": 100, "unit": "g"},
            {"name": "banana", "quantity": 1, "unit": "medium"},
            {"name": "almond milk", "quantity": 250, "unit": "ml"},
            {"name": "protein powder", "quantity": 20, "unit": "g"}
        ],
        "instructions": ["Blend spinach, banana, milk", "Add protein powder", "Blend until smooth"]
    },
    {
        "id": "b013",
        "title": "French Toast with Berries",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 350.0,
            "protein_g": 14.0,
            "carbs_g": 40.0,
            "fat_g": 12.0
        },
        "ingredients": [
            {"name": "whole wheat bread", "quantity": 2, "unit": "slice"},
            {"name": "egg", "quantity": 2, "unit": "large"},
            {"name": "almond milk", "quantity": 50, "unit": "ml"},
            {"name": "mixed berries", "quantity": 100, "unit": "g"}
        ],
        "instructions": ["Dip bread in egg mixture", "Cook on griddle", "Serve with berries"]
    },
    {
        "id": "b014",
        "title": "Chia Seed Pudding",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 310.0,
            "protein_g": 11.0,
            "carbs_g": 32.0,
            "fat_g": 14.0
        },
        "ingredients": [
            {"name": "chia seeds", "quantity": 30, "unit": "g"},
            {"name": "coconut milk", "quantity": 200, "unit": "ml"},
            {"name": "vanilla extract", "quantity": 2, "unit": "ml"},
            {"name": "berries", "quantity": 80, "unit": "g"}
        ],
        "instructions": ["Mix chia seeds with milk", "Add vanilla", "Refrigerate 2 hours", "Top with berries"]
    },
    {
        "id": "b015",
        "title": "Egg White Omelette",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 240.0,
            "protein_g": 24.0,
            "carbs_g": 20.0,
            "fat_g": 6.0
        },
        "ingredients": [
            {"name": "egg whites", "quantity": 4, "unit": "large"},
            {"name": "spinach", "quantity": 80, "unit": "g"},
            {"name": "mushroom", "quantity": 60, "unit": "g"},
            {"name": "cheddar cheese", "quantity": 30, "unit": "g"}
        ],
        "instructions": ["Beat egg whites", "Cook in non-stick pan", "Add veggies and cheese", "Fold omelette"]
    },
    {
        "id": "b016",
        "title": "Quinoa Breakfast Porridge",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 320.0,
            "protein_g": 12.0,
            "carbs_g": 45.0,
            "fat_g": 8.0
        },
        "ingredients": [
            {"name": "quinoa", "quantity": 50, "unit": "g"},
            {"name": "almond milk", "quantity": 200, "unit": "ml"},
            {"name": "cinnamon", "quantity": 1, "unit": "tsp"},
            {"name": "dates", "quantity": 30, "unit": "g"}
        ],
        "instructions": ["Cook quinoa in milk", "Add cinnamon", "Chop dates", "Top and serve"]
    },
    {
        "id": "b017",
        "title": "Muesli with Yogurt",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 300.0,
            "protein_g": 16.0,
            "carbs_g": 40.0,
            "fat_g": 7.0
        },
        "ingredients": [
            {"name": "muesli", "quantity": 60, "unit": "g"},
            {"name": "greek yogurt", "quantity": 180, "unit": "g"},
            {"name": "banana", "quantity": 0.5, "unit": "medium"},
            {"name": "honey", "quantity": 10, "unit": "ml"}
        ],
        "instructions": ["Add muesli to yogurt", "Slice banana on top", "Drizzle honey"]
    },
    {
        "id": "b018",
        "title": "Almond Butter Toast",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 330.0,
            "protein_g": 12.0,
            "carbs_g": 35.0,
            "fat_g": 16.0
        },
        "ingredients": [
            {"name": "whole grain bread", "quantity": 2, "unit": "slice"},
            {"name": "almond butter", "quantity": 30, "unit": "g"},
            {"name": "banana", "quantity": 1, "unit": "medium"},
            {"name": "dark chocolate chips", "quantity": 15, "unit": "g"}
        ],
        "instructions": ["Toast bread", "Spread almond butter", "Add banana slices", "Sprinkle chocolate chips"]
    },
    {
        "id": "b019",
        "title": "Smoothie Bowl with Toppings",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 340.0,
            "protein_g": 16.0,
            "carbs_g": 45.0,
            "fat_g": 8.0
        },
        "ingredients": [
            {"name": "frozen berries", "quantity": 150, "unit": "g"},
            {"name": "protein powder", "quantity": 25, "unit": "g"},
            {"name": "coconut milk", "quantity": 100, "unit": "ml"},
            {"name": "granola", "quantity": 50, "unit": "g"}
        ],
        "instructions": ["Blend berries, powder, milk", "Pour into bowl", "Top with granola"]
    },
    {
        "id": "b020",
        "title": "Bagel with Cream Cheese",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 310.0,
            "protein_g": 12.0,
            "carbs_g": 38.0,
            "fat_g": 11.0
        },
        "ingredients": [
            {"name": "whole wheat bagel", "quantity": 1, "unit": "whole"},
            {"name": "cream cheese", "quantity": 40, "unit": "g"},
            {"name": "smoked salmon", "quantity": 50, "unit": "g"},
            {"name": "dill", "quantity": 5, "unit": "g"}
        ],
        "instructions": ["Toast bagel", "Spread cream cheese", "Add salmon", "Garnish with dill"]
    },
]

# Add to recipes
recipes.extend(more_breakfast_recipes)

# Save
with open('preppro_500_recipes.json', 'w') as f:
    json.dump(recipes, f, indent=2)

print(f"✓ Added 12 more breakfast recipes:")
for b in more_breakfast_recipes:
    print(f"  - {b['title']} ({b['nutrition']['kcal']:.0f} kcal)")
print(f"\nTotal breakfast recipes now: {sum(1 for r in recipes if 'breakfast' in [m.lower() for m in r.get('mealTypes', [])])}")
