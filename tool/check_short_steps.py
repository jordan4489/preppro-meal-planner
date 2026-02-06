import json, re
from pathlib import Path

path = Path(r"C:\Users\Sophie\Downloads\preppro_mobile_blue_pro_exact_patched2\preppro_mobile_blue_pro_exact_patched2\assets\data\preppro_500_recipes.json")
data = json.loads(path.read_text(encoding='utf-8'))

short = []
for r in data:
    steps = r.get('steps') or []
    for st in steps:
        if isinstance(st, str):
            words = [w for w in re.split(r"\s+", st.strip()) if w]
            if len(words) < 6:
                short.append((r.get('title',''), st, len(words)))

print('short steps', len(short))
for item in short[:10]:
    print(item)
