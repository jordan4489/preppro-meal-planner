import json
import csv
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR / "preppro_500_recipes.json"
OUT_PATH = BASE_DIR / "sdxl_prompts_30.csv"
LIMIT = 30

NEGATIVE = "blurry, lowres, text, watermark, logo, people, hands, deformed, extra fingers, bad anatomy, oversaturated, messy plating"

with DATA_PATH.open("r", encoding="utf-8") as f:
    recipes = json.load(f)

rows = []
for r in recipes[:LIMIT]:
    title = r.get("title", "Recipe").strip()
    meal_types = r.get("mealTypes", [])
    tags = r.get("tags", [])
    ingredients = r.get("ingredients", [])
    ing_names = [i.get("name", "").strip() for i in ingredients if i.get("name")]
    main_ings = ", ".join(ing_names[:5]) if ing_names else "fresh ingredients"
    meal_label = ", ".join([m for m in meal_types if m])
    tag_label = ", ".join([t for t in tags if t])

    prompt_parts = [
        f"modern, tasty, attractive food photography of {title}",
        main_ings,
        "social media ready",
        "editorial food styling",
        "soft natural light",
        "shallow depth of field",
        "crisp focus",
        "clean background",
        "vibrant but realistic colors",
        "plated beautifully",
        "minimal props",
        "subtle garnish",
        "hero shot, 45 degree angle",
        "composition centered",
        "4:5 portrait",
        "appetizing",
    ]
    if meal_label:
        prompt_parts.append(meal_label)
    if tag_label:
        prompt_parts.append(tag_label)

    prompt = ", ".join(prompt_parts)
    rows.append({
        "name": r.get("id", title),
        "prompt": prompt,
        "negative_prompt": NEGATIVE,
    })

with OUT_PATH.open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["name", "prompt", "negative_prompt"])
    writer.writeheader()
    writer.writerows(rows)

print(f"Wrote {len(rows)} prompts to {OUT_PATH}")
