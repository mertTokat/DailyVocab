import zipfile
import sqlite3
import json
import os
import html
from bs4 import BeautifulSoup

# Step 1: Unzip the .apkg file
def extract_apkg(apkg_path, extract_to="extracted_apkg"):
    with zipfile.ZipFile(apkg_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)
    print(f"Extracted to {extract_to}")
    return os.path.join(extract_to, "collection.anki2")

# Step 2: Connect to the SQLite DB and read notes
def read_notes_from_db(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    cursor.execute("SELECT flds FROM notes")
    rows = cursor.fetchall()
    conn.close()

    return [row[0] for row in rows]

# Step 3: Parse field content
def parse_note_fields(fields):
    parts = fields.split('\x1f')  # Anki separates fields with ASCII 31
    if len(parts) < 6:
        return None

    def clean(text):
        return BeautifulSoup(html.unescape(text), 'html.parser').get_text().strip()

    return {
        "popularity": clean(parts[0]),
        "turkish_word": clean(parts[1]),
        "part_of_speech": clean(parts[2]),
        "english_meaning": clean(parts[3]),
        "turkish_sentence": clean(parts[6]),
        "english_translation": clean(parts[7]),
        "word_audio": clean(parts[12]),
        "sentence_audio": clean(parts[13]),
    }

# Step 4: Chunk entries by total word count
def split_and_save(entries, word_counts, base_filename="output"):
    start = 0
    for i, target_word_count in enumerate(word_counts):
        chunk = []
        total_words = 0
        while start < len(entries) and total_words < target_word_count:
            entry = entries[start]
            words_in_entry = sum(len(entry[k].split()) for k in entry)
            total_words += words_in_entry
            chunk.append(entry)
            start += 1


        with open(f"{base_filename}_{i+1}.json", "w", encoding="utf-8") as f:
            json.dump(chunk, f, ensure_ascii=False, indent=2)
        print(f"Saved {len(chunk)} entries to {base_filename}_{i+1}.json")

# Main runner
def process_apkg(apkg_path):
    db_path = extract_apkg(apkg_path)
    raw_notes = read_notes_from_db(db_path)
    parsed = [parse_note_fields(note) for note in raw_notes]
    parsed = [p for p in parsed if p is not None]

    word_counts = [300 * 24, 500 * 24, 700 * 24, 1000 * 24, 2500 * 24]
    split_and_save(parsed, word_counts)

# === Run this ===
if __name__ == "__main__":
    apkg_file = "The_Ultimate_Guide_to_Turkish__The_Most_Used_5000_Words.apkg"  # Update path if needed
    process_apkg(apkg_file)
