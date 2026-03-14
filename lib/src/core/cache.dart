import 'dart:collection';
import 'package:text_mark/src/core/token.dart';
import 'package:text_mark/src/tokens/tokens.dart';

/// A least-recently-used (LRU) cache for [TextMarkParser] results.
///
/// Parsing is deterministic for a given (text, rules fingerprint) pair.
/// Caching avoids re-parsing the same string on every rebuild — which is
/// especially valuable inside [ListView] or any widget that rebuilds often.
///
/// The cache is keyed by [_CacheKey] which combines the raw text and a
/// fingerprint of the active rules. When either changes the entry misses
/// and a fresh parse is stored.
///
/// [maxSize] (default 200) caps memory use. When the limit is reached the
/// oldest entry is evicted automatically via [LinkedHashMap]'s insertion order.
///
/// The cache instance lives on [TextMarkTheme] so it is shared across the
/// entire subtree and survives widget rebuilds.
class TextMarkCache {
  final int maxSize;
  final LinkedHashMap<_CacheKey, List<TextToken>> _store;

  TextMarkCache({this.maxSize = 200})
      : _store = LinkedHashMap<_CacheKey, List<TextToken>>();

  /// Returns the cached token list for [text] + [rulesFingerprint], or null.
  ///
  /// On cache hit, the entry is promoted to most recently used (MRU).
  List<TextToken>? get(String text, int rulesFingerprint) {
    final key = _CacheKey(text, rulesFingerprint);
    final value = _store.remove(key);
    if (value != null) {
      _store[key] = value;
    }
    return value;
  }

  /// Stores [tokens] under [text] + [rulesFingerprint], evicting the oldest
  /// entry if [maxSize] is exceeded.
  void set(String text, int rulesFingerprint, List<TextToken> tokens) {
    final key = _CacheKey(text, rulesFingerprint);
    if (_store.containsKey(key)) {
      _store.remove(key);
    } else if (_store.length >= maxSize) {
      _store.remove(_store.keys.first);
    }
    _store[key] = tokens;
  }

  /// Removes all cached entries.
  void clear() => _store.clear();

  /// Current number of cached entries.
  int get length => _store.length;
}

/// Immutable cache key: raw text + rules fingerprint.
class _CacheKey {
  final String text;
  final int rulesFingerprint;

  const _CacheKey(this.text, this.rulesFingerprint);

  @override
  bool operator ==(Object other) =>
      other is _CacheKey &&
      other.text == text &&
      other.rulesFingerprint == rulesFingerprint;

  @override
  int get hashCode => Object.hash(text, rulesFingerprint);
}

/// Computes a stable integer fingerprint for a set of [StyleRule] keys.
///
/// The fingerprint changes whenever the set of registered tag names changes.
/// It does NOT track style value changes — if the user swaps the [TextStyle]
/// behind a tag without changing the tag name, the cache will return stale
/// results. This is acceptable because style maps are typically constants.
int computeRulesFingerprint(Iterable<String> tagNames) {
  final sorted = [...tagNames]..sort();
  return Object.hashAll(sorted);
}
