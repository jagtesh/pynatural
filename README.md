# PyNatural

Apple NaturalLanguage framework from Python — powered by Swift & [ApplePy](../ApplePy).

**Zero model downloads** — uses Apple's built-in on-device NLP models.

> **macOS only** — requires Swift 6.0+ toolchain

## Install

```bash
pip install -e .
```

## Usage

```python
import pynatural

# Language detection (60+ languages)
pynatural.detect_language("Bonjour le monde")  # "fr"

# Tokenization (handles CJK natively)
pynatural.tokenize("東京は美しい", "word")  # ["東京", "は", "美しい"]

# POS tagging
pynatural.tag("The quick brown fox", "pos")
# ["The", "Determiner", "quick", "Adjective", ...]

# Named Entity Recognition
pynatural.tag("Tim Cook visited Apple Park", "ner")
# ["Tim", "PersonalName", "Cook", "PersonalName", ...]

# Sentiment analysis
pynatural.sentiment("This is amazing!")  # ~0.8

# Word embeddings
pynatural.embedding_distance("dog", "cat", "en")  # small distance
pynatural.find_similar("python", "en", 5)  # {"snake": 0.3, ...}
```

## API

| Function | Returns | Description |
|----------|---------|-------------|
| `detect_language(text)` | `str` | ISO language code |
| `detect_languages(text, max_results=5)` | `dict[str, float]` | Languages with confidence |
| `tokenize(text, unit="word")` | `list[str]` | Tokenize (word/sentence/paragraph) |
| `tag(text, scheme="pos")` | `list[str]` | POS/NER/lemma tags (alternating token/tag) |
| `sentiment(text)` | `float` | Score from -1.0 to 1.0 |
| `embedding_distance(w1, w2, lang="en")` | `float` | Semantic distance |
| `find_similar(word, lang="en", n=5)` | `dict[str, float]` | Similar words with distance |

## Examples

See [`pynatural/examples/demo.py`](pynatural/examples/demo.py) for a full demo.

## License

BSD-3-Clause © Jagtesh Chadha — see [LICENSE](LICENSE).
