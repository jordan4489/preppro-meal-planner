import json, re
from pathlib import Path

path = Path(r"C:\Users\Sophie\Downloads\preppro_mobile_blue_pro_exact_patched2\preppro_mobile_blue_pro_exact_patched2\assets\data\preppro_500_recipes.json")
data = json.loads(path.read_text(encoding='utf-8'))

def jazz(step: str) -> str:
    s = step.strip()
    low = s.lower()
    if len([w for w in re.split(r"\s+", s) if w]) >= 8:
        return s
    if re.search(r"\b(preheat)\b", low):
        return s + " until the oven is fully hot."
    if re.search(r"\b(bake|roast)\b", low):
        return s + " until golden and cooked through."
    if re.search(r"\b(simmer)\b", low):
        return s + " until the sauce slightly thickens."
    if re.search(r"\b(boil)\b", low):
        return s + " until tender but not mushy."
    if re.search(r"\b(saute|fry|cook)\b", low):
        return s + " until fragrant and lightly golden."
    if re.search(r"\b(mix|stir|combine|whisk)\b", low):
        return s + " until evenly combined."
    if re.search(r"\b(serve)\b", low):
        return s + " while warm and fresh."
    if re.search(r"\b(garnish)\b", low):
        return s + " for extra color and flavor."
    return s + " until everything looks well combined."

changed = 0
for r in data:
    steps = r.get('steps') or []
    new_steps = []
    for st in steps:
        if isinstance(st, str):
            ns = jazz(st)
            if ns != st:
                changed += 1
            new_steps.append(ns)
        else:
            new_steps.append(st)
    r['steps'] = new_steps

path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
print('Updated steps:', changed)
