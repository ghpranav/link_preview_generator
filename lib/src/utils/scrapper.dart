import 'dart:async';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:link_preview_generator/src/models/types.dart';
import 'package:link_preview_generator/src/rules/amazon.scrapper.dart';
import 'package:link_preview_generator/src/rules/default.scrapper.dart';
import 'package:link_preview_generator/src/rules/image.scrapper.dart';
import 'package:link_preview_generator/src/rules/instagram.scrapper.dart';
import 'package:link_preview_generator/src/rules/twitter.scrapper.dart';
import 'package:link_preview_generator/src/rules/video.scrapper.dart';
import 'package:link_preview_generator/src/rules/youtube.scrapper.dart';
import 'package:link_preview_generator/src/utils/analyzer.dart';
import 'package:link_preview_generator/src/utils/canonical_url.dart';
import 'package:universal_html/html.dart';
import 'package:universal_html/parsing.dart';

/// Generate data required for a link preview.
/// Wrapper object for the link preview generator.
class LinkPreview {
  /// User agent user for making GET request to given URL.
  /// Uses `WhatsApp v2.21.12.21` user agent.
  static const _userAgent = 'WhatsApp/2.21.12.21 A';

  /// Scraps the link from the given `url` to get the data for the preview.
  /// Returns the data in the form [WebInfo]
  static Future<WebInfo> scrapeFromURL(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': _userAgent,
        },
      );

      final mimeType = response.headers['content-type'] ?? '';
      final data = response.body;
      final doc = parseHtmlDocument(data);

      if (LinkPreviewScrapper.isMimeVideo(mimeType)) {
        return VideoScrapper.scrape(doc, url);
      } else if (LinkPreviewScrapper.isMimeAudio(mimeType)) {
        return ImageScrapper.scrape(doc, url);
      } else if (LinkPreviewScrapper.isMimeImage(mimeType)) {
        return ImageScrapper.scrape(doc, url);
      } else if (LinkPreviewScrapper.isUrlInsta(url)) {
        final instagramResponse = await http.get(
          Uri.parse('$url?__a=1&max_id=endcursor'),
        );
        return InstagramScrapper.scrape(doc, instagramResponse.body, url);
      } else if (LinkPreviewScrapper.isUrlYoutube(url)) {
        return YouTubeScrapper.scrape(doc, url);
      } else if (LinkPreviewScrapper.isUrlAmazon(url)) {
        return AmazonScrapper.scrape(doc, url);
      } else if (LinkPreviewScrapper.isUrlTwitter(url)) {
        final twitterResponse = await http.get(
          Uri.parse('https://publish.twitter.com/oembed?url=$url'),
        );
        return TwitterScrapper.scrape(doc, twitterResponse.body, url);
      } else {
        return DefaultScrapper.scrape(doc, url);
      }
    } catch (e) {
      print('Default scrapper failure Error: $e');
      return WebInfo(
        description: '',
        domain: url,
        icon: '',
        image: '',
        video: '',
        title: '',
        type: LinkPreviewType.error,
      );
    }
  }
}

/// Utils required for the link preview generator.
class LinkPreviewScrapper {
  // static final RegExp _base64withMime = RegExp(
  //     r'^(data:(.*);base64,)?(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$');
  static final RegExp _amazonUrl =
      RegExp(r'https?:\/\/(.*amazon\..*\/.*|.*amzn\..*\/.*|.*a\.co\/.*)$');

  static final RegExp _instaUrl =
      RegExp(r'^(https?:\/\/www\.)?instagram\.com(\/p\/\w+\/?)');

  static final RegExp _twitterUrl =
      RegExp(r'^(https?:\/\/(www)?\.?)?twitter\.com\/.+');

  static final RegExp _youtubeUrl =
      RegExp(r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/.+$');

  static String fixRelativeUrls(String baseUrl, String itemUrl) {
    final normalizedUrl = itemUrl.toLowerCase();
    if (normalizedUrl.startsWith('http://') ||
        normalizedUrl.startsWith('https://')) {
      return itemUrl;
    }
    return UrlCanonicalizer(removeFragment: true)
        .canonicalize('$baseUrl/$itemUrl');
  }

  static String? getAttrOfDocElement(
      HtmlDocument doc, String query, String attr) {
    var attribute = doc.querySelectorAll(query).firstOrNull?.getAttribute(attr);

    if (attribute != null && attribute.isNotEmpty) return attribute;
  }

  static String getBaseUrl(HtmlDocument doc, String url) =>
      getAttrOfDocElement(doc, 'base', 'href') ?? Uri.parse(url).origin;

  static String? getDomain(HtmlDocument doc, String url) {
    try {
      final domainName = () {
        final canonicalLink = doc.querySelector('link[rel=canonical]');
        if (canonicalLink != null && canonicalLink.attributes['href'] != null) {
          return canonicalLink.attributes['href'];
        }
        final ogUrlMeta = doc.querySelector('meta[property="og:url"]');
        if (ogUrlMeta != null && ogUrlMeta.text!.isNotEmpty) {
          return ogUrlMeta.text;
        }
        return null;
      }();

      return domainName != null
          ? Uri.parse(domainName).host.replaceFirst('www.', '')
          : Uri.parse(url).host.replaceFirst('www.', '');
    } catch (e) {
      print('Domain resolution failure Error:$e');
      return null;
    }
  }

  static String? getIcon(HtmlDocument doc, String url) {
    final List<Element>? meta = doc.querySelectorAll('link');
    String? icon = '';
    Element? metaIcon;
    if (meta != null && meta.isNotEmpty) {
      // get icon first
      metaIcon = meta.firstWhereOrNull((e) {
        final rel = (e.attributes['rel'] ?? '').toLowerCase();
        if (rel == 'icon') {
          icon = e.attributes['href'];
          if (icon != null && !icon!.toLowerCase().contains('.svg')) {
            return true;
          }
        }
        return false;
      });

      metaIcon ??= meta.firstWhereOrNull((e) {
        final rel = (e.attributes['rel'] ?? '').toLowerCase();
        if (rel == 'shortcut icon') {
          icon = e.attributes['href'];
          if (icon != null && !icon!.toLowerCase().contains('.svg')) {
            return true;
          }
        }
        return false;
      });
    }
    if (metaIcon != null) {
      icon = metaIcon.attributes['href'];
      return LinkPreviewScrapper.handleUrl(url, icon);
    }
    return '${Uri.parse(url).origin}/favicon.ico';
  }

  static String? getTitle(HtmlDocument doc) {
    try {
      final ogTitle = doc.querySelector('meta[property="og:title"]');
      if (ogTitle != null &&
          ogTitle.attributes['content'] != null &&
          ogTitle.attributes['content']!.isNotEmpty) {
        return ogTitle.attributes['content'];
      }
      final twitterTitle = doc.querySelector('meta[name="twitter:title"]');
      if (twitterTitle != null &&
          twitterTitle.attributes['content'] != null &&
          twitterTitle.attributes['content']!.isNotEmpty) {
        return twitterTitle.attributes['content'];
      }
      String? docTitle = doc.title;
      // ignore: unnecessary_null_comparison
      if (docTitle != null && docTitle.isNotEmpty) return docTitle;
      final h1El = doc.querySelector('h1');
      final h1 = h1El?.innerHtml;
      if (h1 != null && h1.isNotEmpty) return h1;
      final h2El = doc.querySelector('h2');
      final h2 = h2El?.innerHtml;
      if (h2 != null && h2.isNotEmpty) return h2;
      return null;
    } catch (e) {
      print('Title resolution failure Error:$e');
      return null;
    }
  }

  static String? handleUrl(String url, String? source) {
    var uri = Uri.parse(url);
    if (LinkPreviewAnalyzer.isNotEmpty(source) && !source!.startsWith('http')) {
      if (source.startsWith('//')) {
        source = '${uri.scheme}:$source';
      } else {
        if (source.startsWith('/')) {
          source = '${uri.origin}$source';
        } else {
          source = '${uri.origin}/$source';
        }
      }
    }
    return source;
  }

  static bool isMimeAudio(String mimeType) => mimeType.startsWith('audio/');

  static bool isMimeImage(String mimeType) => mimeType.startsWith('image/');

  static bool isMimeVideo(String mimeType) => mimeType.startsWith('video/');

  static bool isUrlAmazon(String url) => _amazonUrl.hasMatch(url);

  static bool isUrlInsta(String url) => _instaUrl.hasMatch(url);

  static bool isUrlTwitter(String url) => _twitterUrl.hasMatch(url);

  static bool isUrlYoutube(String url) => _youtubeUrl.hasMatch(url);
}
