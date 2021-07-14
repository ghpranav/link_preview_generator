import 'dart:convert';

import 'package:link_preview_generator/src/models/types.dart';
import 'package:link_preview_generator/src/utils/scrapper.dart';
import 'package:universal_html/html.dart';

class InstagramScrapper {
  static WebInfo scrape(HtmlDocument doc, String data, String url) {
    try {
      final dynamic scrappedData = json.decode(data);

      return WebInfo(
        description: scrappedData['title'] ??
            scrappedData['graphql']['shortcode_media']['edge_media_to_caption']
                ['edges'][0]['node']['text'] ??
            '',
        domain: LinkPreviewScrapper.getDomain(doc, url) ?? url,
        icon: LinkPreviewScrapper.getIcon(doc, url) ?? '',
        image: scrappedData['graphql']['shortcode_media']['display_url'] ?? '',
        video: '',
        title: scrappedData['graphql']['shortcode_media']
                ['accessibility_caption'] ??
            '',
        type: LinkPreviewType.instagram,
      );
    } catch (e) {
      print('Instagram scrapper failure Error: $e');
      return WebInfo(
        description:
            'Create an account or log in to Instagram - A simple, fun & creative way to capture, edit & share photos, videos & messages with friends & family.',
        domain: 'instagram.com',
        icon: 'https://instagram.com/favicon.ico',
        image:
            'https://instagram.com/static/images/ico/favicon-200.png/ab6eff595bb1.png',
        video: '',
        title: 'Instagram',
        type: LinkPreviewType.error,
      );
    }
  }
}
