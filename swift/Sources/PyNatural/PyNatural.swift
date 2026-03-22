// PyNatural — Apple NaturalLanguage framework from Python
// A showcase example for ApplePy.
//
// Usage from Python:
//   import pynatural
//   lang = pynatural.detect_language("Bonjour le monde")  # "fr"
//   words = pynatural.tokenize("Hello world")  # ["Hello", "world"]
//   tags = pynatural.tag("The quick brown fox", "pos")

import ApplePy
import Foundation
import NaturalLanguage
@preconcurrency import ApplePyFFI

// MARK: - Custom Exception

let NaturalError = PyExceptionType(name: "pynatural.NaturalError", doc: "NaturalLanguage operation failed")

enum NaturalBridgeError: Error, PyExceptionMapping {
    case operationFailed(String)
    case unsupportedScheme(String)

    var pythonExceptionType: PyExceptionType { NaturalError }
    var pythonMessage: String {
        switch self {
        case .operationFailed(let msg): return msg
        case .unsupportedScheme(let scheme): return "Unsupported tag scheme: \(scheme). Use: pos, ner, lemma, language, script"
        }
    }
}

// MARK: - detect_language

/// Detect the dominant language of a text string.
/// Returns an ISO language code (e.g., "en", "fr", "ja") or "und" if undetermined.
///
/// ```python
/// lang = pynatural.detect_language("Bonjour le monde")  # "fr"
/// ```
@PyFunction
func detect_language(text: String) -> String {
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(text)
    return recognizer.dominantLanguage?.rawValue ?? "und"
}

// MARK: - detect_languages

/// Detect all probable languages with confidence scores.
/// Returns a dict of {language_code: confidence}.
///
/// ```python
/// langs = pynatural.detect_languages("Bonjour le monde")
/// # {"fr": 0.98, "it": 0.01, ...}
/// ```
@PyFunction
func detect_languages(text: String, max_results: Int = 5) -> [String: Double] {
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(text)
    let hypotheses = recognizer.languageHypotheses(withMaximum: max_results)
    var result: [String: Double] = [:]
    for (lang, confidence) in hypotheses {
        result[lang.rawValue] = confidence
    }
    return result
}

// MARK: - tokenize

/// Tokenize text into words, sentences, or paragraphs.
/// Handles CJK text natively (no spaces needed).
///
/// ```python
/// words = pynatural.tokenize("Hello world")  # ["Hello", "world"]
/// words = pynatural.tokenize("東京は美しい", "word")  # ["東京", "は", "美しい"]
/// sents = pynatural.tokenize("Hello. World.", "sentence")
/// ```
@PyFunction
func tokenize(text: String, unit: String = "word") -> [String] {
    let tokenUnit: NLTokenUnit
    switch unit.lowercased() {
    case "word": tokenUnit = .word
    case "sentence": tokenUnit = .sentence
    case "paragraph": tokenUnit = .paragraph
    default: tokenUnit = .word
    }

    let tokenizer = NLTokenizer(unit: tokenUnit)
    tokenizer.string = text

    var tokens: [String] = []
    tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
        tokens.append(String(text[range]))
        return true
    }
    return tokens
}

// MARK: - tag

/// Tag text with linguistic annotations.
/// Supported schemes: "pos" (part-of-speech), "ner" (named entities),
/// "lemma" (lemmatization), "language" (per-word language), "script" (script detection).
///
/// Returns a list of [token, tag] pairs as a flat list (alternating token/tag).
///
/// ```python
/// tags = pynatural.tag("The quick brown fox jumps", "pos")
/// # ["The", "Determiner", "quick", "Adjective", "brown", "Adjective", ...]
///
/// entities = pynatural.tag("Tim Cook visited Apple Park", "ner")
/// # ["Tim", "PersonalName", "Cook", "PersonalName", "visited", "OtherWord", ...]
/// ```
@PyFunction
func tag(text: String, scheme: String = "pos") throws -> [String] {
    let tagScheme: NLTagScheme
    switch scheme.lowercased() {
    case "pos": tagScheme = .lexicalClass
    case "ner", "namedentity": tagScheme = .nameType
    case "lemma": tagScheme = .lemma
    case "language": tagScheme = .language
    case "script": tagScheme = .script
    default:
        throw NaturalBridgeError.unsupportedScheme(scheme)
    }

    let tagger = NLTagger(tagSchemes: [tagScheme])
    tagger.string = text

    var result: [String] = []
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: tagScheme) { tag, range in
        let token = String(text[range])
        let tagName = tag?.rawValue ?? "Unknown"
        result.append(token)
        result.append(tagName)
        return true
    }
    return result
}

// MARK: - sentiment

/// Analyze sentiment of text.
/// Returns a score from -1.0 (negative) to 1.0 (positive).
///
/// ```python
/// score = pynatural.sentiment("This is great!")  # ~0.8
/// score = pynatural.sentiment("This is terrible")  # ~-0.5
/// ```
@PyFunction
func sentiment(text: String) -> Double {
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    tagger.string = text
    let range = text.startIndex..<text.endIndex

    var totalScore = 0.0
    var count = 0

    tagger.enumerateTags(in: range, unit: .paragraph, scheme: .sentimentScore) { tag, _ in
        if let tag = tag, let score = Double(tag.rawValue) {
            totalScore += score
            count += 1
        }
        return true
    }

    return count > 0 ? totalScore / Double(count) : 0.0
}

// MARK: - embedding_distance

/// Compute the semantic distance between two words using Apple's built-in embeddings.
/// Returns a distance value (lower = more similar). Returns -1.0 if embeddings unavailable.
///
/// ```python
/// dist = pynatural.embedding_distance("dog", "cat", "en")  # small value
/// dist = pynatural.embedding_distance("dog", "quantum", "en")  # large value
/// ```
@PyFunction
func embedding_distance(word1: String, word2: String, language: String = "en") -> Double {
    guard let lang = NLLanguage(rawValue: language) as NLLanguage?,
          let embedding = NLEmbedding.wordEmbedding(for: lang) else {
        return -1.0
    }
    return embedding.distance(between: word1, and: word2)
}

// MARK: - find_similar

/// Find words similar to a given word using Apple's built-in embeddings.
/// Returns a dict of {word: distance}.
///
/// ```python
/// similar = pynatural.find_similar("dog", "en", 5)
/// # {"cat": 0.3, "puppy": 0.4, ...}
/// ```
@PyFunction
func find_similar(word: String, language: String = "en", max_results: Int = 5) -> [String: Double] {
    guard let lang = NLLanguage(rawValue: language) as NLLanguage?,
          let embedding = NLEmbedding.wordEmbedding(for: lang) else {
        return [:]
    }

    var result: [String: Double] = [:]
    embedding.enumerateNeighbors(for: word, maximumCount: max_results) { neighbor, distance in
        result[neighbor] = distance
        return true
    }
    return result
}

// MARK: - Module Entry Point

@PyModule("pynatural", functions: [
    detect_language,
    detect_languages,
    tokenize,
    tag,
    sentiment,
    embedding_distance,
    find_similar,
])
func pynatural() {}
