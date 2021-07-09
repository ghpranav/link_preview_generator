import 'dart:async';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:link_preview_generator/src/canonical_url.dart';
import 'package:universal_html/html.dart';
import 'package:universal_html/parsing.dart';

abstract class InfoBase {
  late DateTime _timeout;
}

/// Link Preview Utils
class LinkPreviewUtils {
  static final Map<String?, InfoBase> _map = {};
  static final RegExp _instaUrl =
      RegExp(r'^(https?:\/\/www\.)?instagram\.com(\/p\/\w+\/?)$');
  // static final RegExp _twitterUrl =
  //     RegExp(r'^(https?:\/\/(www)?\.?)?twitter\.com\/.+$');
  static final RegExp _base64withMime = RegExp(
      r'^(data:(.*);base64,)?(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$');
  static final _userAgent =
      "facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)";

  /// Get web information
  /// return [InfoBase]
  static Future<InfoBase?> getInfo(String url,
      {Duration cache = const Duration(hours: 24),
      bool multimedia = true}) async {
    // final start = DateTime.now();

    InfoBase? info = getInfoFromCache(url);
    if (info != null) return info;
    try {
      info = await parseInfo(url);

      if (info != null) {
        info._timeout = DateTime.now().add(cache);
        _map[url] = info;
      }
    } catch (e) {
      print("Get web error:$url, Error:$e");
    }

    // print("$url cost ${DateTime.now().difference(start).inMilliseconds}");

    return info;
  }

  /// Get web information
  /// return [InfoBase]
  static InfoBase? getInfoFromCache(String? url) {
    final InfoBase? info = _map[url];
    if (info != null) {
      if (!info._timeout.isAfter(DateTime.now())) {
        _map.remove(url);
      }
    }
    return info;
  }

  /// Is it an empty string
  static bool isNotEmpty(String? str) {
    return str != null && str.isNotEmpty && str.trim().length > 0;
  }

  static Future<InfoBase?> parseInfo(String url) async {
    if (_instaUrl.hasMatch(url)) url = url + "?__a=1&max_id=endcursor";
    // if (_twitterUrl.hasMatch(url))
    //   url = "https://publish.twitter.com/oembed?url=" + url;

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "User-Agent": _userAgent,
      },
    );

    final HtmlDocument _document = parseHtmlDocument(response.body);

    final String _description = _getDescription(_document) ?? "";
    final String _domain = _getDomain(_document, url) ?? url;
    final String _icon = _getIcon(_document, url) ?? "";
    final String _image = await _getImage(_document, url) ?? "";
    final String _title = _getTitle(_document) ?? "";

    return WebInfo(
      description: _description,
      domain: _domain,
      icon: _icon,
      image: _image,
      title: _title,
    );
  }

  static Future<bool> urlImageIsAccessible(String url) async {
    try {
      if (_base64withMime.hasMatch(url)) return true;
      final String correctedUrl =
          UrlCanonicalizer(removeFragment: true).canonicalize(url);
      final urlResponse = await http.get(Uri.parse(correctedUrl));
      final String contentType = urlResponse.headers["content-type"]!;
      return new RegExp("image/*").hasMatch(contentType);
    } catch (e) {
      print("Image accessibility check failure from:$url Error:$e");
      return false;
    }
  }

  static String? _getDescription(HtmlDocument doc) {
    try {
      final ogDescription = doc.querySelector("meta[name=description]");
      if (ogDescription != null &&
          ogDescription.attributes["content"] != null &&
          ogDescription.attributes["content"]!.length > 0)
        return ogDescription.attributes["content"];
      final twitterDescription =
          doc.querySelector('meta[name="twitter:description"]');
      if (twitterDescription != null &&
          twitterDescription.attributes["content"] != null &&
          twitterDescription.attributes["content"]!.length > 0)
        return twitterDescription.attributes["content"];
      final metaDescription = doc.querySelector('meta[name="description"]');
      if (metaDescription != null &&
          metaDescription.attributes["content"] != null &&
          metaDescription.attributes["content"]!.length > 0)
        return metaDescription.attributes["content"];
      final paragraphs = doc.querySelectorAll("p");
      String? fstVisibleParagraph;
      for (var i = 0; i < paragraphs.length; i++) {
        // if object is visible
        if (paragraphs[i].offsetParent != null) {
          fstVisibleParagraph = paragraphs[i].text;
          break;
        }
      }
      return fstVisibleParagraph;
    } catch (e) {
      print("Description resolution failure Error:$e");
      return null;
    }
  }

  static String? _getDomain(HtmlDocument doc, String url) {
    try {
      final String? domainName = () {
        final canonicalLink = doc.querySelector("link[rel=canonical]");
        if (canonicalLink != null && canonicalLink.attributes["href"] != null)
          return canonicalLink.attributes["href"]!;
        final ogUrlMeta = doc.querySelector('meta[property="og:url"]');
        if (ogUrlMeta != null && ogUrlMeta.text!.length > 0)
          return ogUrlMeta.text;
        return null;
      }();

      return domainName != null
          ? Uri.parse(domainName).host.replaceFirst("www.", "")
          : Uri.parse(url).host.replaceFirst("www.", "");
    } catch (e) {
      print("Domain resolution failure Error:$e");
      return null;
    }
  }

  static String? _getIcon(HtmlDocument doc, String url) {
    final List<Element>? meta = doc.querySelectorAll("link");
    if (meta == null || meta.length == 0) return null;

    final Uri uri = Uri.parse(url);
    String? icon = "";
    // get icon first
    Element? metaIcon = meta.firstWhereOrNull((e) {
      final rel = (e.attributes["rel"] ?? "").toLowerCase();
      if (rel == "icon") {
        icon = e.attributes["href"];
        if (icon != null && !icon!.toLowerCase().contains(".svg")) {
          return true;
        }
      }
      return false;
    });

    metaIcon ??= meta.firstWhereOrNull((e) {
      final rel = (e.attributes["rel"] ?? "").toLowerCase();
      if (rel == "shortcut icon") {
        icon = e.attributes["href"];
        if (icon != null && !icon!.toLowerCase().contains(".svg")) {
          return true;
        }
      }
      return false;
    });

    if (metaIcon != null) {
      icon = metaIcon.attributes["href"];
    } else {
      return "${uri.origin}/favicon.ico";
    }

    return _handleUrl(uri, icon);
  }

  static Future<String?> _getImage(HtmlDocument doc, String url) async {
    try {
      final ogImg = doc.querySelector('meta[property="og:image"]');
      if (ogImg != null &&
          ogImg.attributes["content"] != null &&
          ogImg.attributes["content"]!.length > 0 &&
          (await urlImageIsAccessible(ogImg.attributes["content"]!))) {
        return ogImg.attributes["content"];
      }
      final imgRelLink = doc.querySelector('link[rel="image_src"]');
      if (imgRelLink != null &&
          imgRelLink.attributes["href"] != null &&
          imgRelLink.attributes["href"]!.length > 0 &&
          (await urlImageIsAccessible(imgRelLink.attributes["href"]!))) {
        return imgRelLink.attributes["href"];
      }
      final twitterImg = doc.querySelector('meta[name="twitter:image"]');
      if (twitterImg != null &&
          twitterImg.attributes["content"] != null &&
          twitterImg.attributes["content"]!.length > 0 &&
          (await urlImageIsAccessible(twitterImg.attributes["content"]!))) {
        return twitterImg.attributes["content"];
      }

      List<ImageElement> imgs = doc.querySelectorAll('img');
      if (imgs.length > 0) {
        imgs = imgs.where((img) {
          // ignore: unnecessary_null_comparison
          if (img == null ||
              // ignore: unnecessary_null_comparison
              img.naturalHeight == null ||
              // ignore: unnecessary_null_comparison
              img.naturalWidth == null) return false;
          bool addImg = true;
          // ignore: unnecessary_non_null_assertion
          if (img.naturalWidth! > img.naturalHeight!) {
            // ignore: unnecessary_non_null_assertion
            if (img.naturalWidth! / img.naturalHeight! > 3) {
              addImg = false;
            }
          } else {
            // ignore: unnecessary_non_null_assertion
            if (img.naturalHeight! / img.naturalWidth! > 3) {
              addImg = false;
            }
          }
          // ignore: unnecessary_non_null_assertion
          if (img.naturalHeight! <= 50 || img.naturalWidth! <= 50) {
            addImg = false;
          }
          return addImg;
        }).toList();
        if (imgs.length > 0) {
          imgs.forEach((img) {
            if (img.src != null && img.src!.indexOf("//") == -1)
              img.src = Uri.parse(url).origin + '/' + img.src!;
          });
          return imgs[0].src;
        }
      }
      return null;
    } catch (e) {
      print("Image resolution failure Error:$e");
      return null;
    }
  }

  static String? _getTitle(HtmlDocument doc) {
    try {
      final ogTitle = doc.querySelector('meta[property="og:title"]');
      if (ogTitle != null &&
          ogTitle.attributes["content"] != null &&
          ogTitle.attributes["content"]!.length > 0)
        return ogTitle.attributes["content"];
      final twitterTitle = doc.querySelector('meta[name="twitter:title"]');
      if (twitterTitle != null &&
          twitterTitle.attributes["content"] != null &&
          twitterTitle.attributes["content"]!.length > 0)
        return twitterTitle.attributes["content"];
      String? docTitle = doc.title;
      // ignore: unnecessary_null_comparison
      if (docTitle != null && docTitle.length > 0) return docTitle;
      final h1El = doc.querySelector("h1");
      final h1 = h1El != null ? h1El.innerHtml ?? null : null;
      if (h1 != null && h1.length > 0) return h1;
      final h2El = doc.querySelector("h2");
      final h2 = h2El != null ? h2El.innerHtml ?? null : null;
      if (h2 != null && h2.length > 0) return h2;
      return null;
    } catch (e) {
      print("Title resolution failure Error:$e");
      return null;
    }
  }

  static String? _handleUrl(Uri uri, String? source) {
    if (isNotEmpty(source) && !source!.startsWith("http")) {
      if (source.startsWith("//")) {
        source = "${uri.scheme}:$source";
      } else {
        if (source.startsWith("/")) {
          source = "${uri.origin}$source";
        } else {
          source = "${uri.origin}/$source";
        }
      }
    }
    return source;
  }
}

/// Image Information
class WebImageInfo extends InfoBase {
  final String? image;

  WebImageInfo({this.image});
}

/// Web Information
class WebInfo extends InfoBase {
  final String? title;
  final String? icon;
  final String? description;
  final String? image;
  final String? domain;

  WebInfo({this.title, this.icon, this.description, this.image, this.domain});
}
