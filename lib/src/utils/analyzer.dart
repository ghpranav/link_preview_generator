import 'package:link_preview_generator/src/models/types.dart';
import 'package:link_preview_generator/src/utils/scrapper.dart';

/// Link Preview Analyzer
class LinkPreviewAnalyzer {
  static final Map<String?, InfoBase> _map = {};

  /// Get web information
  /// return [InfoBase]
  static Future<InfoBase?> getInfo(
    String url, {
    Duration cacheDuration = const Duration(hours: 24),
    bool multimedia = true,
  }) async {
    // final start = DateTime.now();

    var info = getInfoFromCache(url);
    if (info != null) return info;
    try {
      info = await LinkPreview.scrapeFromURL(url);

      info.timeout = DateTime.now().add(cacheDuration);
      _map[url] = info;
    } catch (e) {
      print('Get web error: $url, Error: $e');
    }

    // print("$url cost ${DateTime.now().difference(start).inMilliseconds}");

    return info;
  }

  /// Get web information
  /// return [InfoBase]
  static InfoBase? getInfoFromCache(String? url) {
    final info = _map[url];
    if (info != null && !info.timeout.isAfter(DateTime.now())) {
      _map.remove(url);
      return null;
    }
    return info;
  }

  /// Is it an empty string
  static bool isNotEmpty(String? str) =>
      str != null && str.isNotEmpty && str.trim().isNotEmpty;
}
