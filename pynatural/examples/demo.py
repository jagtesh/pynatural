#!/usr/bin/env python3
"""PyNatural — Example Usage

Demonstrates Apple's NaturalLanguage framework from Python via ApplePy.
Zero model downloads — everything runs on-device using Apple's built-in models.
"""
import pynatural

# ── Language Detection ──────────────────────────────────────

print("=== Language Detection ===\n")

samples = [
    "Hello, how are you today?",
    "Bonjour le monde, comment allez-vous?",
    "東京は世界で最も美しい都市の一つです",
    "Привет мир, как дела?",
    "مرحبا بالعالم",
]

for text in samples:
    lang = pynatural.detect_language(text)
    print(f"  [{lang}] {text[:40]}...")

# Detailed language probabilities
print("\nDetailed detection:")
probs = pynatural.detect_languages("Ciao mondo, come stai?", 3)
for lang, conf in sorted(probs.items(), key=lambda x: -x[1]):
    print(f"  {lang}: {conf:.2%}")

# ── Tokenization ────────────────────────────────────────────

print("\n=== Tokenization ===\n")

# English
words = pynatural.tokenize("The quick brown fox jumps over the lazy dog")
print(f"English words: {words}")

# CJK — no spaces needed, Apple handles it natively
words = pynatural.tokenize("東京は美しい都市です", "word")
print(f"Japanese words: {words}")

# Sentence tokenization
sents = pynatural.tokenize(
    "First sentence. Second sentence! Third sentence?",
    "sentence"
)
print(f"Sentences: {sents}")

# ── Part-of-Speech Tagging ──────────────────────────────────

print("\n=== POS Tagging ===\n")

tags = pynatural.tag("The quick brown fox jumps over the lazy dog", "pos")
# tags is a flat list: [token, tag, token, tag, ...]
pairs = list(zip(tags[0::2], tags[1::2]))
for token, pos in pairs:
    print(f"  {token:12s} → {pos}")

# ── Named Entity Recognition ────────────────────────────────

print("\n=== Named Entity Recognition ===\n")

tags = pynatural.tag("Tim Cook visited Apple Park in Cupertino on Monday", "ner")
pairs = list(zip(tags[0::2], tags[1::2]))
for token, entity in pairs:
    if entity != "OtherWord":
        print(f"  {token:12s} → {entity}")

# ── Lemmatization ───────────────────────────────────────────

print("\n=== Lemmatization ===\n")

tags = pynatural.tag("The cats were running and playing happily", "lemma")
pairs = list(zip(tags[0::2], tags[1::2]))
for token, lemma in pairs:
    print(f"  {token:12s} → {lemma}")

# ── Sentiment Analysis ──────────────────────────────────────

print("\n=== Sentiment Analysis ===\n")

texts = [
    "This product is absolutely amazing and wonderful!",
    "The weather is okay, nothing special.",
    "This is the worst experience I've ever had.",
]
for text in texts:
    score = pynatural.sentiment(text)
    emoji = "😊" if score > 0.3 else "😐" if score > -0.3 else "😞"
    print(f"  {emoji} {score:+.2f}  {text[:50]}")

# ── Word Embeddings ─────────────────────────────────────────

print("\n=== Word Embeddings ===\n")

# Semantic distance (lower = more similar)
pairs_to_compare = [
    ("dog", "cat"),
    ("dog", "puppy"),
    ("dog", "quantum"),
    ("king", "queen"),
]
for w1, w2 in pairs_to_compare:
    dist = pynatural.embedding_distance(w1, w2, "en")
    bar = "█" * int(max(0, 10 - dist * 5))
    print(f"  {w1:8s} ↔ {w2:8s}  dist={dist:.3f}  {bar}")

# Find similar words
print("\nWords similar to 'python':")
similar = pynatural.find_similar("python", "en", 5)
for word, dist in sorted(similar.items(), key=lambda x: x[1]):
    print(f"  {word:15s}  dist={dist:.3f}")

print("\n🎉 All examples passed!")
