import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:link_preview_generator/src/models/types.dart';
import 'package:link_preview_generator/src/utils/analyzer.dart';
import 'package:link_preview_generator/src/utils/scrapper.dart';
import 'package:universal_html/html.dart';

class TwitterScrapper {
  static WebInfo scrape(HtmlDocument doc, String data, String url) {
    try {
      final scrappedData = json.decode(data);
      final htmlElement = document.createElement('html');
      htmlElement.innerHtml = scrappedData['html'];

      final baseUrl = LinkPreviewScrapper.getBaseUrl(doc, url);

      final image = [
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, "meta[property='og:image']", 'content'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, "meta[property='og:image:user_generated']", 'content'),
        'https://help.twitter.com/content/dam/help-twitter/twitter-logo.png',
      ]
          .where((i) => LinkPreviewAnalyzer.isNotEmpty(i))
          .map((i) => LinkPreviewScrapper.fixRelativeUrls(baseUrl, i!))
          .firstOrNull;

      final video = [
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, "meta[property='og:video:url']", 'content'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, "meta[property='og:video:secure_url']", 'content'),
      ]
          .where((i) => LinkPreviewAnalyzer.isNotEmpty(i))
          .map((i) => LinkPreviewScrapper.fixRelativeUrls(baseUrl, i!))
          .firstOrNull;

      return WebInfo(
        description: htmlElement.querySelector('p')?.text ?? '',
        domain: LinkPreviewScrapper.getDomain(doc, url) ?? url,
        icon: LinkPreviewScrapper.getIcon(doc, url) ?? '',
        image: image ?? '',
        video: video ?? '',
        title: '${scrappedData['author_name']} on Twitter',
        type: LinkPreviewType.twitter,
      );
    } catch (e) {
      print('Twitter scrapper failure Error: $e');
      return WebInfo(
        description: "It's what's happening / Twitter",
        domain: 'twitter.com',
        icon: 'https://twitter.com/favicon.ico',
        image:
            'https://abs.twimg.com/responsive-web/client-web/icon-ios.b1fc7275.png',
        video: '',
        title: 'Twitter',
        type: LinkPreviewType.error,
      );
    }
  }
}
