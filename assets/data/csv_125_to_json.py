import csv
import json
import re
from pathlib import Path

# Adjust these if your files live elsewhere
HERE = Path(__file__).resolve().parent
EXISTING_JSON = HERE / "preppro_500_recipes.json"
CSV_FILE = HERE / "125recipes_final.csv"  # put your cleaned CSV here
OUTPUT_JSON = HERE / "preppro_625_recipes.json"


def _norm(name: str) -> str:
    """Normalize CSV header names to a simple, comparable form."""
    return re.sub(r"[^a-z0-9]+", "_", name.strip().lower())


def _build_header_map(fieldnames):
    norm_map = { _norm(h): h for h in fieldnames }

    def find(possible_prefixes, *, required=True):
        for norm_name, original in norm_map.items():
            for p in possible_prefixes:
                if norm_name.startswith(p):
                    return original
        if required:
            raise KeyError(f"Could not find CSV column matching any of: {possible_prefixes} in {list(fieldnames)}")
        return None

    cols = {
        "id": find(["id"], required=False),  # optional, we'll generate if missing
        "name": find(["name", "title"]),
        "meal": find(["meal"]),
        "tags": find(["tags"], required=False),
        "servings": find(["servings", "serves"], required=False),
        "ingredients": find(["ingredients"]),
        "method": find(["method", "steps", "instructions"]),
        "notes": find(["allergen", "diet"], required=False),
        "kcal": find(["kcal", "calorie"], required=False),
        "protein": find(["protein"], required=False),
        "carbs": find(["carb"], required=False),
        "fat": find(["fat"], required=False),
    }
    return cols


def _parse_float(value, default=0.0):
    if value is None:
        return default
    s = str(value).strip()
    if not s:
        return default
    try:
        return float(s)
    except ValueError:
        # Try replacing commas etc.
        s = s.replace(",", ".")
        try:
            return float(s)
        except ValueError:
            return default


def _parse_meal_type(meal: str) -> list[str]:
    if not meal:
        return []
    m = meal.strip().lower()
    # Normalise common variants
    if m.startswith("breakfast"):
        return ["breakfast"]
    if m.startswith("lunch"):
        return ["lunch"]
    if m.startswith("dinner") or m.startswith("tea"):
        return ["dinner"]
    if m.startswith("snack") or m.startswith("snacks"):
        return ["snack"]
    return [m]


def _derive_tags(tags_raw: str | None, notes_raw: str | None) -> list[str]:
    text = f"{tags_raw or ''} {notes_raw or ''}".lower()
    tokens = re.split(r"[\s,;/]+", text)
    tags: set[str] = set()

    def has_any(*candidates: str) -> bool:
        return any(c in tokens for c in candidates) or any(c in text for c in candidates)

    if has_any("vgn", "vegan"):
        tags.add("vegan")
    if has_any("vgt", "veg", "vegetarian"):
        tags.add("vegetarian")
    if has_any("gf", "gluten_free", "gluten free"):
        tags.add("gluten-free")
    if has_any("df", "dairy_free", "dairy free"):
        tags.add("dairy-free")
    if has_any("hp", "high_protein", "high protein") or "protein" in tokens or "p" in tokens:
        tags.add("high-protein")
    if has_any("low_carb", "low carb", "lc"):
        tags.add("low-carb")
    if has_any("air_fryer", "airfryer", "air-fryer", "af"):
        tags.add("air-fryer")

    return sorted(tags)


def _is_air_fryer(name: str, tags: list[str]) -> bool:
    hay = f"{name} {' '.join(tags)}".lower()
    return any(k in hay for k in ["air fryer", "air-fryer", "airfryer"])


_ING_PATTERN_NUM = re.compile(r"^\s*(\d+(?:\.\d+)?)\s*([a-zA-Zµ%]+)?\s+(.*)$")
_ING_PATTERN_FRAC = re.compile(r"^\s*(\d+)/(\d+)\s*([a-zA-Zµ%]+)?\s+(.*)$")


def _parse_ingredient(text: str | None):
    if not text:
        return None
    s = text.strip()
    if not s:
        return None

    m = _ING_PATTERN_NUM.match(s)
    if m:
        qty = float(m.group(1))
        unit = (m.group(2) or "").strip()
        name = m.group(3).strip()
        return {"name": name, "quantity": qty, "unit": unit}

    m2 = _ING_PATTERN_FRAC.match(s)
    if m2:
        num = float(m2.group(1))
        den = float(m2.group(2)) or 1.0
        qty = num / den
        unit = (m2.group(3) or "").strip()
        name = m2.group(4).strip()
        return {"name": name, "quantity": qty, "unit": unit}

    # Fallback: treat whole string as name, quantity 1
    return {"name": s, "quantity": 1.0, "unit": ""}


def _parse_ingredients_field(raw: str | None) -> list[dict]:
    if not raw:
        return []
    parts = [p.strip() for p in raw.split(";")]
    out: list[dict] = []
    for p in parts:
        ing = _parse_ingredient(p)
        if ing:
            out.append(ing)
    return out


def _parse_instructions(raw: str | None) -> list[str]:
    if not raw:
        return []
    # Split on newlines or semicolons into steps
    steps = re.split(r"[\n;]+", str(raw))
    return [s.strip() for s in steps if s.strip()]


def _next_id_generator(existing_recipes: list[dict]):
    max_n = 0
    for r in existing_recipes:
        rid = str(r.get("id", ""))
        m = re.match(r"^r(\d+)$", rid)
        if m:
            try:
                n = int(m.group(1))
                if n > max_n:
                    max_n = n
            except ValueError:
                continue

    current = max_n

    def _next():
        nonlocal current
        current += 1
        return f"r{current:03d}"

    return _next


def main():
    if not EXISTING_JSON.exists():
        raise SystemExit(f"Existing JSON not found: {EXISTING_JSON}")
    if not CSV_FILE.exists():
        raise SystemExit(f"CSV file not found: {CSV_FILE}")

    print(f"Loading existing recipes from {EXISTING_JSON}...")
    existing = json.loads(EXISTING_JSON.read_text(encoding="utf-8"))
    next_id = _next_id_generator(existing)

    print(f"Reading CSV from {CSV_FILE}...")
    with CSV_FILE.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        cols = _build_header_map(reader.fieldnames or [])
        print("Detected columns:", cols)

        new_recipes: list[dict] = []
        for row in reader:
            name = (row.get(cols["name"]) or "").strip()
            if not name:
                continue  # skip blank rows

            raw_id = row.get(cols["id"]) if cols["id"] else None
            rid = (raw_id or "").strip() or next_id()

            meal_raw = row.get(cols["meal"]) if cols["meal"] else ""
            meal_types = _parse_meal_type(meal_raw or "")

            tags_raw = row.get(cols["tags"]) if cols["tags"] else ""
            notes_raw = row.get(cols["notes"]) if cols["notes"] else ""
            tags = _derive_tags(tags_raw, notes_raw)

            servings_raw = row.get(cols["servings"]) if cols["servings"] else "1"
            try:
                servings = int(float(servings_raw)) if str(servings_raw).strip() else 1
            except ValueError:
                servings = 1

            kcal = _parse_float(row.get(cols["kcal"]) if cols["kcal"] else None, default=0.0)
            protein = _parse_float(row.get(cols["protein"]) if cols["protein"] else None, default=0.0)
            carbs = _parse_float(row.get(cols["carbs"]) if cols["carbs"] else None, default=0.0)
            fat = _parse_float(row.get(cols["fat"]) if cols["fat"] else None, default=0.0)

            ingredients_raw = row.get(cols["ingredients"]) if cols["ingredients"] else ""
            ingredients = _parse_ingredients_field(ingredients_raw)

            method_raw = row.get(cols["method"]) if cols["method"] else ""
            instructions = _parse_instructions(method_raw)

            recipe_obj = {
                "id": rid,
                "title": name,
                "isAirFryer": _is_air_fryer(name, tags),
                "mealTypes": meal_types,
                "tags": tags,
                "servings": servings,
                "nutrition": {
                    "kcal": float(kcal),
                    "protein_g": float(protein),
                    "carbs_g": float(carbs),
                    "fat_g": float(fat),
                },
                "ingredients": ingredients,
                # Use 'instructions' – Recipe.fromJson can consume this
                "instructions": instructions,
                "prepTime": 10,  # default placeholder; adjust if you have columns
                "cookTime": 15,
                "image": None,
                "steps": [],
            }

            new_recipes.append(recipe_obj)

    all_recipes = existing + new_recipes
    OUTPUT_JSON.write_text(json.dumps(all_recipes, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {len(new_recipes)} new recipes; total {len(all_recipes)} → {OUTPUT_JSON}")


if __name__ == "__main__":
    main()
