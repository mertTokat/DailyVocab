import zipfile
import sqlite3
import json
import os

def extract_apkg_to_json(apkg_file_path, output_json_path):
    # Step 1: Unzip the .apkg file
    with zipfile.ZipFile(apkg_file_path, 'r') as zip_ref:
        extract_dir = os.path.splitext(apkg_file_path)[0]
        zip_ref.extractall(extract_dir)

    db_path = os.path.join(extract_dir, "collection.anki2")

    # Step 2: Connect to the SQLite database
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Step 3: Extract notes
    cursor.execute("SELECT flds FROM notes")
    rows = cursor.fetchall()

    entries = []
    for row in rows:
        fields = row[0].split("\x1f")  # ASCII Unit Separator used by Anki
        if len(fields) >= 4:
            entry = {
                "chinese": fields[0].strip(),
                "pinyin": fields[1].strip(),
                "explanation": fields[2].strip(),
            }
            entries.append(entry)

    # Step 4: Write to JSON
    with open(output_json_path, 'w', encoding='utf-8') as f:
        json.dump(entries, f, ensure_ascii=False, indent=2)

    print(f"Extracted {len(entries)} entries to {output_json_path}")

# Example usage
apkg_path = "Chinese_HSK_1_-_150_Words_300_Example_Sentences_with_Audio.apkg"
output_path = "hsk1_full.json"
extract_apkg_to_json(apkg_path, output_path)
