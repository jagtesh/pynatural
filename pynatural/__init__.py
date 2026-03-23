"""pynatural — Apple NaturalLanguage framework from Python

Powered by Swift & ApplePy. Provides on-device NLP with zero model downloads:
language detection, tokenization (CJK native), POS tagging, NER,
sentiment analysis, and word embeddings.

Usage:
    import pynatural
    lang = pynatural.detect_language("Bonjour le monde")  # "fr"
    words = pynatural.tokenize("Hello world")  # ["Hello", "world"]
"""
import importlib
import os
import sys

if sys.platform != "darwin":
    raise ImportError("pynatural only supports macOS")


def _load_native():
    """Load the compiled Swift extension module."""
    pkg_dir = os.path.dirname(os.path.abspath(__file__))
    so_path = os.path.join(pkg_dir, "_native", "pynatural.so")

    if not os.path.exists(so_path):
        raise ImportError(
            "Native extension not found. Build it first:\n"
            "  pip install -e .\n"
            "  # or: python setup.py build_ext --inplace"
        )

    spec = importlib.util.spec_from_file_location("pynatural._native.pynatural", so_path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


_native = _load_native()

# Re-export all public functions
detect_language = _native.detect_language
detect_languages = _native.detect_languages
tokenize = _native.tokenize
tag = _native.tag
sentiment = _native.sentiment
embedding_distance = _native.embedding_distance
find_similar = _native.find_similar

__all__ = [
    "detect_language",
    "detect_languages",
    "tokenize",
    "tag",
    "sentiment",
    "embedding_distance",
    "find_similar",
]

__version__ = "0.2.1"
