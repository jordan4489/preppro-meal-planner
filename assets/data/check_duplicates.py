import json
from collections import Counter

with open('preppro_500_recipes.json') as f:
    recipes = json.load(f)

# Check for duplicate titles
titles = [r['title'] for r in recipes]
title_counts = Counter(titles)
duplicates = {title: count for title, count in title_counts.items() if count > 1}

print(f"Total recipes: {len(recipes)}")
print(f"\n=== DUPLICATE TITLES ===")
print(f"Found {len(duplicates)} recipe titles that appear multiple times:\n")

for title, count in sorted(duplicates.items(), key=lambda x: x[1], reverse=True):
    print(f"  {count}x - {title}")

# Check for very similar recipes (pattern-based)
print(f"\n=== PATTERN ANALYSIS ===")

# Count by pattern
patterns = {}
for r in recipes:
    title = r['title']
    # Extract base pattern (e.g., "Blazing", "Power", "Sticky")
    words = title.split()
    if len(words) >= 2:
        prefix = words[0]  # First word (Blazing, Power, etc)
        if prefix in ['Blazing', 'Power', 'Sticky', 'Smoky', 'Crispy', 'Fiery', 'Creamy', 'Epic', 'Supreme', 'Ultimate', 'Mega', 'Super', 'Loaded', 'Golden', 'Tangy', 'Zesty', 'Spicy', 'Sizzling']:
            patterns[prefix] = patterns.get(prefix, 0) + 1

print("\nRecipes by descriptive prefix:")
for prefix, count in sorted(patterns.items(), key=lambda x: x[1], reverse=True):
    print(f"  {count}x - {prefix}")

# Check "Protein Stack" vs "Pasta Pot"
protein_stacks = sum(1 for r in recipes if 'Protein Stack' in r['title'])
pasta_pots = sum(1 for r in recipes if 'Pasta Pot' in r['title'])

print(f"\n=== RECIPE TYPES ===")
print(f"Protein Stack recipes: {protein_stacks}")
print(f"Pasta Pot recipes: {pasta_pots}")
print(f"Other recipes: {len(recipes) - protein_stacks - pasta_pots}")
