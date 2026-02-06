import json, re, collections
path = r"C:\Users\Sophie\Downloads\preppro_mobile_blue_pro_exact_patched2\preppro_mobile_blue_pro_exact_patched2\assets\data\preppro_500_recipes.json"
data = json.load(open(path, encoding='utf-8'))
size_words = re.compile(r"\b(large|small|medium|xl|extra\s*large|jumbo)\b", re.I)
egg_units = collections.Counter()
size_names = collections.Counter()
for r in data:
    for ing in (r.get('ingredients') or []):
        name = (ing.get('name') or '').lower().strip()
        unit = (ing.get('unit') or '').lower().strip()
        if 'egg' in name and unit:
            egg_units[unit] += 1
        if size_words.search(name):
            size_names[name] += 1
print('Egg units:', egg_units.most_common(20))
print('Egg name size entries:', [n for n,_ in size_names.most_common(40) if 'egg' in n])
print('Top size names:', size_names.most_common(20))
