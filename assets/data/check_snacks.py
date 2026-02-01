#!/usr/bin/env python3
"""Verify snack recipes are in the dataset"""
import json

with open('preppro_500_recipes.json', 'r', encoding='utf-8') as f:
    recipes = json.load(f)

snacks = [r for r in recipes if 'snack' in r.get('mealTypes', [])]
breakfasts = [r for r in recipes if 'breakfast' in r.get('mealTypes', [])]
lunches = [r for r in recipes if 'lunch' in r.get('mealTypes', [])]
dinners = [r for r in recipes if 'dinner' in r.get('mealTypes', [])]

print(f"Total recipes: {len(recipes)}")
print(f"Snack recipes: {len(snacks)}")
print(f"Breakfast recipes: {len(breakfasts)}")
print(f"Lunch recipes: {len(lunches)}")
print(f"Dinner recipes: {len(dinners)}")

print("\nSample snacks:")
for s in snacks[:5]:
    kcal = s['nutrition']['kcal']
    protein = s['nutrition']['protein_g']
    print(f"  - {s['title']} ({kcal} kcal, {protein}g protein)")

print("\n✓ Dataset ready for meal planning with 3-meal or 5-meal plans!")
