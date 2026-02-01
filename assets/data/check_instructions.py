import json

with open('preppro_500_recipes.json', encoding='utf-8') as f:
    data = json.load(f)

missing = [r['title'] for r in data if not r.get('instructions') or len(r.get('instructions', [])) == 0]

print(f'Total recipes: {len(data)}')
print(f'Recipes with instructions: {len(data) - len(missing)}')
print(f'Recipes missing instructions: {len(missing)}')
print(f'\nAverage instructions per recipe: {sum(len(r.get("instructions", [])) for r in data) / len(data):.1f}')
print(f'Min instructions: {min(len(r.get("instructions", [])) for r in data)}')
print(f'Max instructions: {max(len(r.get("instructions", [])) for r in data)}')
print('\nFirst 5 missing:', missing[:5] if missing else 'None')
