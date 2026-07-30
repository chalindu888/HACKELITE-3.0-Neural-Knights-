import json
import re

def to_snake_case(name):
    clean = re.sub(r'[^\w\s]', '', name.lower())
    return clean.replace(' ', '_')

def to_title_case(name):
    return ' '.join(word.capitalize() for word in name.split())

with open('assets/model_schema.json', 'r', encoding='utf-8') as f:
    schema = json.load(f)

raw_symptoms = schema['features']

print(f"Generating Flutter features for {len(raw_symptoms)} symptoms...")

# Build HealthFeature code
feature_code_lines = []
translation_entries_en = []
translation_entries_si = []
translation_entries_ta = []

for sym in raw_symptoms:
    key = to_snake_case(sym)
    title = to_title_case(sym)
    
    feature_code_lines.append(f"""        const HealthFeature(
          id: '{key}',
          translationKey: '{key}',
          type: FeatureType.boolean,
          defaultValue: false,
        ),""")
    
    translation_entries_en.append(f"      '{key}': '{title}',")
    translation_entries_si.append(f"      '{key}': '{title}',")
    translation_entries_ta.append(f"      '{key}': '{title}',")

# Write updated HealthFeature file
health_feature_dart = f"""enum FeatureType {{
  boolean,
  numerical,
  categorical,
}}

class HealthFeature {{
  final String id;
  final String translationKey;
  final FeatureType type;
  final dynamic defaultValue;
  final String? unit;
  final num? minValue;
  final num? maxValue;

  const HealthFeature({{
    required this.id,
    required this.translationKey,
    required this.type,
    required this.defaultValue,
    this.unit,
    this.minValue,
    this.maxValue,
  }});

  static List<HealthFeature> get prototypeFeatures => [
{chr(10).join(feature_code_lines)}
      ];
}}
"""

with open('lib/data/models/health_feature.dart', 'w', encoding='utf-8') as f:
    f.write(health_feature_dart)

print("Updated lib/data/models/health_feature.dart")
