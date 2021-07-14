import 'package:path/path.dart' as p;

bool _matchesPort(String scheme, int port) {
  if (scheme == 'http' && port == 80) return true;
  if (scheme == 'https' && port == 443) return true;
  return false;
}

/// The UrlCanonicalizer is used for the process of converting an URL into a
/// canonical (normalized) form.
class UrlCanonicalizer {
  final List<String>? blacklist;

  final List<String>? order;
  final bool removeFragment;
  final bool sort;
  final bool sortValues;
  final List<String>? whitelist;

  UrlCanonicalizer({
    this.sort = true,
    this.sortValues = false,
    this.order,
    this.removeFragment = false,
    this.whitelist,
    this.blacklist,
  });

  /// Converts a URL into a canonical (normalized) form.
  T canonicalize<T>(T url, {T? context}) {
    final uri = url is String ? Uri.parse(url) : url as Uri;
    final contextUri = context != null
        ? (context is String ? Uri.parse(context) : context as Uri?)
        : null;
    final canonical = _canonicalize(_contextualize(uri, contextUri));
    return (url is String ? canonical.toString() : canonical) as T;
  }

  List<T> canonicalizeUrls<T>(Iterable<T> urls, {T? context}) {
    return urls.map((T url) => canonicalize(url, context: context)).toList();
  }

  Uri _canonicalize(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final params = _params(uri);
    final fragment =
        (removeFragment || !(uri.hasFragment && uri.fragment.isNotEmpty))
            ? null
            : uri.fragment;
    final port =
        uri.hasPort && !_matchesPort(scheme, uri.port) ? uri.port : null;
    String path;
    if (uri.hasAbsolutePath) {
      path = p.canonicalize(uri.path);
      if (uri.path.endsWith('/') && !path.endsWith('/')) {
        path = '$path/';
      }
    } else {
      path = uri.path;
    }
    final host = uri.host.toLowerCase();
    return Uri(
      scheme: scheme,
      host: host.isEmpty ? null : host,
      port: port,
      path: path,
      queryParameters: params == null || params.isEmpty ? null : params,
      fragment: fragment,
    );
  }

  Uri _contextualize(Uri uri, Uri? context) {
    if (context == null) return uri;
    if (uri.hasScheme) return uri;

    String path;
    if (uri.path.startsWith('/')) {
      path = uri.path;
    } else {
      path = p.canonicalize(p.join(_dirname(context.path), uri.path));
      if (uri.path.endsWith('/') && !path.endsWith('/')) {
        path = '$path/';
      }
    }
    return context.replace(
      path: path,
      queryParameters: uri.queryParametersAll,
      fragment: uri.fragment,
    );
  }

  String _dirname(String path) {
    if (path.endsWith('/')) return path;
    final list = p.split(path);
    list.removeLast();
    return list.join('/');
  }

  Map<String, List<String>?>? _params(Uri uri) {
    Map<String, List<String>?>? params;
    if (uri.hasQuery) {
      final map = Map<String, List<String>>.from(uri.queryParametersAll);
      blacklist?.forEach(map.remove);
      if (whitelist != null) {
        map.removeWhere((key, value) => !whitelist!.contains(key));
      }
      if (map.isNotEmpty) {
        params = <String, List<String>?>{};
        order?.forEach((p) {
          if (map.containsKey(p)) {
            params![p] = map[p];
          }
        });
        if (params.length != map.length) {
          Iterable<String> keys;
          if (sort) {
            final set = map.keys.toSet();
            if (order != null) {
              set.removeAll(order!);
            }
            keys = set.toList()..sort();
          } else {
            keys = map.keys.where((s) => order == null || !order!.contains(s));
          }
          for (var key in keys) {
            params[key] = map[key];
          }
        }
        if (sortValues) {
          params = params.map((key, values) {
            if (values!.length > 1) {
              values = List<String>.from(values);
              values.sort();
            }
            return MapEntry(key, values);
          });
        }
        assert(params.length == map.length);
      }
    }
    return params;
  }
}
