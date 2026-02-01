import json
from pathlib import Path

DATA_PATH = Path("preppro_500_recipes.json")
IMAGES_DIR = Path("..") / "images" / "recipes"

with DATA_PATH.open("r", encoding="utf-8") as f:
    recipes = json.load(f)

found = 0
missing = 0

for r in recipes:
    rid = r.get("id", "")
    if not rid:
        continue
    jpg = IMAGES_DIR / f"{rid}.jpg"
    png = IMAGES_DIR / f"{rid}.png"
    if jpg.exists():
        r["image"] = f"assets/images/recipes/{rid}.jpg"
        found += 1
    elif png.exists():
        r["image"] = f"assets/images/recipes/{rid}.png"
        found += 1
    else:
        r.pop("image", None)
        missing += 1

with DATA_PATH.open("w", encoding="utf-8") as f:
    json.dump(recipes, f, indent=2)

print(f"✓ Mapped images: {found}")
print(f"✗ Missing images: {missing}")
