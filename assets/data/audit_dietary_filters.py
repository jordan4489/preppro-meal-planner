import json
from pathlib import Path
from collections import defaultdict

DATA_PATH = Path(__file__).resolve().parent / "preppro_500_recipes.json"

ALLERGEN_KEYWORDS = {
    "dairy": [
        "milk","cheese","cream","butter","yogurt","yoghurt","ghee","whey","casein","curd",
        "paneer","ricotta","mozzarella","parmesan","cheddar","feta","halloumi","sour cream",
        "cream cheese","creme","crème"
    ],
    "egg": ["egg","eggs","albumen","mayonnaise","mayo"],
    "gluten": [
        "wheat","flour","bread","pasta","noodle","breadcrumbs","couscous","semolina","bulgur",
        "farro","spelt","rye","barley","malt","soy sauce"
    ],
    "nuts": [
        "peanut","peanuts","almond","almonds","cashew","cashews","walnut","walnuts","pecan",
        "pecans","pistachio","hazelnut","macadamia","brazil nut","nut butter"
    ],
    "soy": ["soy","soya","tofu","tempeh","miso","edamame"],
    "fish": [
        "fish","salmon","tuna","cod","mackerel","haddock","trout","sardine","sardines",
        "anchovy","anchovies","tilapia","halibut","snapper","mahi","mahi-mahi","swordfish",
        "catfish","pollock","herring"
    ],
    "shellfish": [
        "seafood","prawn","prawns","shrimp","crab","lobster","scallop","mussel","mussels",
        "clam","clams","octopus","squid","calamari"
    ],
    "sesame": ["sesame","tahini"],
}

DIET_FILTERS = {
    "dairy-free": lambda h: not any(k in h for k in ALLERGEN_KEYWORDS["dairy"]),
    "gluten-free": lambda h: not any(k in h for k in ALLERGEN_KEYWORDS["gluten"]),
    "vegetarian": lambda h: not any(k in h for k in (
        ["chicken","beef","pork","lamb","turkey","bacon","ham","sausage"]
        + ALLERGEN_KEYWORDS["fish"] + ALLERGEN_KEYWORDS["shellfish"]
    )),
    "vegan": lambda h: (
        not any(k in h for k in (
            ["chicken","beef","pork","lamb","turkey","bacon","ham","sausage"]
            + ALLERGEN_KEYWORDS["fish"] + ALLERGEN_KEYWORDS["shellfish"]
            + ALLERGEN_KEYWORDS["dairy"]
            + ALLERGEN_KEYWORDS["egg"]
        ))
        and "honey" not in h and "gelatin" not in h
    ),
}

with DATA_PATH.open("r", encoding="utf-8") as f:
    data = json.load(f)

allergen_hits = defaultdict(list)

for r in data:
    title = r.get("title", "")
    tags = r.get("tags", []) or []
    ingredients = r.get("ingredients", []) or []
    ing_names = [i.get("name", "") for i in ingredients]
    haystack = " ".join([title] + tags + ing_names).lower()

    for allergen, keys in ALLERGEN_KEYWORDS.items():
        if any(k in haystack for k in keys):
            allergen_hits[allergen].append(title)

print(f"Total recipes: {len(data)}")
print("\nAllergen coverage (by keyword scan):")
for allergen in sorted(ALLERGEN_KEYWORDS.keys()):
    hits = allergen_hits.get(allergen, [])
    print(f"- {allergen}: {len(hits)}")

print("\nDiet filter pass counts (keyword logic):")
for diet, fn in DIET_FILTERS.items():
    ok = 0
    for r in data:
        title = r.get("title", "")
        tags = r.get("tags", []) or []
        ingredients = r.get("ingredients", []) or []
        ing_names = [i.get("name", "") for i in ingredients]
        haystack = " ".join([title] + tags + ing_names).lower()
        if fn(haystack):
            ok += 1
    print(f"- {diet}: {ok}")

print("\nSample titles per allergen (first 10):")
for allergen in sorted(ALLERGEN_KEYWORDS.keys()):
    hits = allergen_hits.get(allergen, [])
    print(f"\n{allergen} ({len(hits)}):")
    for t in hits[:10]:
        print(f"  - {t}")
