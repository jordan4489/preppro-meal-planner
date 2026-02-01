import json

with open('preppro_500_recipes.json') as f:
    recipes = json.load(f)

# Add more exciting, tasty breakfast recipes
exciting_breakfast = [
    {
        "id": "b021",
        "title": "Mediterranean Shakshuka",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "spicy"],
        "servings": 1,
        "nutrition": {
            "kcal": 320.0,
            "protein_g": 16.0,
            "carbs_g": 28.0,
            "fat_g": 14.0
        },
        "ingredients": [
            {"name": "eggs", "quantity": 2, "unit": "large"},
            {"name": "tomatoes", "quantity": 200, "unit": "g"},
            {"name": "bell pepper", "quantity": 80, "unit": "g"},
            {"name": "feta cheese", "quantity": 30, "unit": "g"}
        ],
        "instructions": ["Sauté peppers and tomatoes", "Create wells for eggs", "Cook until eggs set", "Top with feta"]
    },
    {
        "id": "b022",
        "title": "Breakfast Burrito Bowl",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "spicy"],
        "servings": 1,
        "nutrition": {
            "kcal": 360.0,
            "protein_g": 18.0,
            "carbs_g": 38.0,
            "fat_g": 12.0
        },
        "ingredients": [
            {"name": "scrambled eggs", "quantity": 2, "unit": "large"},
            {"name": "black beans", "quantity": 80, "unit": "g"},
            {"name": "avocado", "quantity": 50, "unit": "g"},
            {"name": "salsa", "quantity": 40, "unit": "g"}
        ],
        "instructions": ["Scramble eggs", "Heat black beans", "Assemble bowl", "Top with avocado and salsa"]
    },
    {
        "id": "b023",
        "title": "Cinnamon Apple Protein Oats",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "sweet"],
        "servings": 1,
        "nutrition": {
            "kcal": 310.0,
            "protein_g": 16.0,
            "carbs_g": 42.0,
            "fat_g": 6.0
        },
        "ingredients": [
            {"name": "rolled oats", "quantity": 60, "unit": "g"},
            {"name": "apple", "quantity": 1, "unit": "medium"},
            {"name": "protein powder", "quantity": 25, "unit": "g"},
            {"name": "cinnamon", "quantity": 2, "unit": "tsp"}
        ],
        "instructions": ["Cook oats with diced apple", "Add cinnamon", "Stir in protein powder", "Top with extra apple"]
    },
    {
        "id": "b024",
        "title": "Smoked Salmon Bagel Stack",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["pescatarian", "protein"],
        "servings": 1,
        "nutrition": {
            "kcal": 340.0,
            "protein_g": 22.0,
            "carbs_g": 35.0,
            "fat_g": 10.0
        },
        "ingredients": [
            {"name": "whole grain bagel", "quantity": 1, "unit": "whole"},
            {"name": "smoked salmon", "quantity": 60, "unit": "g"},
            {"name": "cream cheese", "quantity": 30, "unit": "g"},
            {"name": "capers", "quantity": 10, "unit": "g"}
        ],
        "instructions": ["Toast bagel", "Spread cream cheese", "Layer salmon", "Add capers and red onion"]
    },
    {
        "id": "b025",
        "title": "Blueberry Protein Waffles",
        "isAirFryer": True,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "sweet"],
        "servings": 1,
        "nutrition": {
            "kcal": 330.0,
            "protein_g": 20.0,
            "carbs_g": 38.0,
            "fat_g": 8.0
        },
        "ingredients": [
            {"name": "protein powder", "quantity": 30, "unit": "g"},
            {"name": "oat flour", "quantity": 50, "unit": "g"},
            {"name": "egg", "quantity": 2, "unit": "large"},
            {"name": "blueberries", "quantity": 80, "unit": "g"}
        ],
        "instructions": ["Mix batter ingredients", "Add blueberries", "Cook in waffle maker", "Serve with maple syrup"]
    },
    {
        "id": "b026",
        "title": "Peanut Butter Banana Protein Shake",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "quick"],
        "servings": 1,
        "nutrition": {
            "kcal": 340.0,
            "protein_g": 22.0,
            "carbs_g": 36.0,
            "fat_g": 10.0
        },
        "ingredients": [
            {"name": "banana", "quantity": 1, "unit": "medium"},
            {"name": "peanut butter", "quantity": 25, "unit": "g"},
            {"name": "protein powder", "quantity": 30, "unit": "g"},
            {"name": "oat milk", "quantity": 250, "unit": "ml"}
        ],
        "instructions": ["Blend all ingredients", "Add ice if desired", "Pour and serve"]
    },
    {
        "id": "b027",
        "title": "Breakfast Egg Muffins",
        "isAirFryer": True,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "protein"],
        "servings": 1,
        "nutrition": {
            "kcal": 290.0,
            "protein_g": 20.0,
            "carbs_g": 18.0,
            "fat_g": 14.0
        },
        "ingredients": [
            {"name": "eggs", "quantity": 3, "unit": "large"},
            {"name": "spinach", "quantity": 60, "unit": "g"},
            {"name": "cheddar cheese", "quantity": 40, "unit": "g"},
            {"name": "cherry tomatoes", "quantity": 80, "unit": "g"}
        ],
        "instructions": ["Whisk eggs", "Add veggies and cheese", "Bake in muffin tin", "Serve warm"]
    },
    {
        "id": "b028",
        "title": "Tropical Mango Smoothie Bowl",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "tropical"],
        "servings": 1,
        "nutrition": {
            "kcal": 320.0,
            "protein_g": 14.0,
            "carbs_g": 48.0,
            "fat_g": 7.0
        },
        "ingredients": [
            {"name": "frozen mango", "quantity": 150, "unit": "g"},
            {"name": "coconut milk", "quantity": 100, "unit": "ml"},
            {"name": "protein powder", "quantity": 20, "unit": "g"},
            {"name": "coconut flakes", "quantity": 20, "unit": "g"}
        ],
        "instructions": ["Blend mango, milk, protein", "Pour into bowl", "Top with coconut and fruit"]
    },
    {
        "id": "b029",
        "title": "Caprese Breakfast Sandwich",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "italian"],
        "servings": 1,
        "nutrition": {
            "kcal": 330.0,
            "protein_g": 16.0,
            "carbs_g": 32.0,
            "fat_g": 14.0
        },
        "ingredients": [
            {"name": "ciabatta roll", "quantity": 1, "unit": "whole"},
            {"name": "mozzarella", "quantity": 60, "unit": "g"},
            {"name": "tomato", "quantity": 1, "unit": "medium"},
            {"name": "basil", "quantity": 10, "unit": "g"}
        ],
        "instructions": ["Toast ciabatta", "Layer mozzarella and tomato", "Add fresh basil", "Drizzle balsamic glaze"]
    },
    {
        "id": "b030",
        "title": "Chocolate Banana Protein Crepes",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "sweet"],
        "servings": 1,
        "nutrition": {
            "kcal": 350.0,
            "protein_g": 18.0,
            "carbs_g": 42.0,
            "fat_g": 10.0
        },
        "ingredients": [
            {"name": "protein powder", "quantity": 25, "unit": "g"},
            {"name": "egg", "quantity": 2, "unit": "large"},
            {"name": "banana", "quantity": 1, "unit": "medium"},
            {"name": "dark chocolate", "quantity": 20, "unit": "g"}
        ],
        "instructions": ["Make thin crepe batter", "Cook crepes", "Fill with banana", "Drizzle melted chocolate"]
    },
    {
        "id": "b031",
        "title": "Savory Mushroom Scramble",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "savory"],
        "servings": 1,
        "nutrition": {
            "kcal": 300.0,
            "protein_g": 18.0,
            "carbs_g": 22.0,
            "fat_g": 14.0
        },
        "ingredients": [
            {"name": "eggs", "quantity": 3, "unit": "large"},
            {"name": "mushrooms", "quantity": 100, "unit": "g"},
            {"name": "spinach", "quantity": 60, "unit": "g"},
            {"name": "goat cheese", "quantity": 30, "unit": "g"}
        ],
        "instructions": ["Sauté mushrooms and spinach", "Scramble eggs", "Combine and top with cheese"]
    },
    {
        "id": "b032",
        "title": "Cacao Nib Overnight Oats",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "chocolate"],
        "servings": 1,
        "nutrition": {
            "kcal": 310.0,
            "protein_g": 14.0,
            "carbs_g": 42.0,
            "fat_g": 8.0
        },
        "ingredients": [
            {"name": "rolled oats", "quantity": 60, "unit": "g"},
            {"name": "almond milk", "quantity": 200, "unit": "ml"},
            {"name": "cacao nibs", "quantity": 20, "unit": "g"},
            {"name": "maple syrup", "quantity": 15, "unit": "ml"}
        ],
        "instructions": ["Mix all ingredients", "Refrigerate overnight", "Stir and serve cold"]
    },
    {
        "id": "b033",
        "title": "Spicy Chorizo Breakfast Hash",
        "isAirFryer": True,
        "mealTypes": ["breakfast"],
        "tags": ["spicy", "protein"],
        "servings": 1,
        "nutrition": {
            "kcal": 360.0,
            "protein_g": 20.0,
            "carbs_g": 28.0,
            "fat_g": 16.0
        },
        "ingredients": [
            {"name": "turkey chorizo", "quantity": 80, "unit": "g"},
            {"name": "sweet potato", "quantity": 150, "unit": "g"},
            {"name": "egg", "quantity": 1, "unit": "large"},
            {"name": "bell pepper", "quantity": 60, "unit": "g"}
        ],
        "instructions": ["Dice and air fry potatoes", "Cook chorizo and peppers", "Top with fried egg"]
    },
    {
        "id": "b034",
        "title": "Coconut Berry Chia Bowl",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegan", "tropical"],
        "servings": 1,
        "nutrition": {
            "kcal": 300.0,
            "protein_g": 12.0,
            "carbs_g": 36.0,
            "fat_g": 12.0
        },
        "ingredients": [
            {"name": "chia seeds", "quantity": 30, "unit": "g"},
            {"name": "coconut yogurt", "quantity": 150, "unit": "g"},
            {"name": "mixed berries", "quantity": 120, "unit": "g"},
            {"name": "coconut flakes", "quantity": 15, "unit": "g"}
        ],
        "instructions": ["Mix chia with yogurt", "Let sit 10 minutes", "Top with berries and coconut"]
    },
    {
        "id": "b035",
        "title": "Apple Cinnamon Protein Pancakes",
        "isAirFryer": False,
        "mealTypes": ["breakfast"],
        "tags": ["vegetarian", "sweet"],
        "servings": 1,
        "nutrition": {
            "kcal": 340.0,
            "protein_g": 22.0,
            "carbs_g": 40.0,
            "fat_g": 8.0
        },
        "ingredients": [
            {"name": "protein powder", "quantity": 30, "unit": "g"},
            {"name": "apple", "quantity": 1, "unit": "medium"},
            {"name": "egg", "quantity": 2, "unit": "large"},
            {"name": "cinnamon", "quantity": 2, "unit": "tsp"}
        ],
        "instructions": ["Grate apple into batter", "Add protein and cinnamon", "Cook pancakes", "Serve with yogurt"]
    },
]

# Add to recipes
recipes.extend(exciting_breakfast)

# Save
with open('preppro_500_recipes.json', 'w') as f:
    json.dump(recipes, f, indent=2)

print(f"✓ Added 15 more exciting breakfast recipes:")
for b in exciting_breakfast:
    tags_str = ", ".join(b['tags'])
    print(f"  - {b['title']} ({b['nutrition']['kcal']:.0f} kcal) - {tags_str}")

print(f"\nTotal breakfast recipes now: {sum(1 for r in recipes if 'breakfast' in [m.lower() for m in r.get('mealTypes', [])])}")
