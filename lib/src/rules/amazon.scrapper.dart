import 'package:collection/collection.dart';
import 'package:link_preview_generator/src/models/types.dart';
import 'package:link_preview_generator/src/utils/analyzer.dart';
import 'package:link_preview_generator/src/utils/scrapper.dart';
import 'package:universal_html/html.dart';

class AmazonScrapper {
  static WebInfo scrape(HtmlDocument doc, String url) {
    try {
      var baseUrl = LinkPreviewScrapper.getBaseUrl(doc, url);

      var image = [
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, '.a-dynamic-image', 'data-old-hires'),
        LinkPreviewScrapper.getAttrOfDocElement(doc, '.a-dynamic-image', 'src'),
      ]
          .where((i) => LinkPreviewAnalyzer.isNotEmpty(i))
          .map((i) => LinkPreviewScrapper.fixRelativeUrls(baseUrl, i!))
          .firstOrNull;

      return WebInfo(
        description: LinkPreviewScrapper.getAttrOfDocElement(
                doc, "meta[name='description']", 'content') ??
            '',
        domain: LinkPreviewScrapper.getDomain(doc, url) ?? url,
        icon: LinkPreviewScrapper.getIcon(doc, url) ?? '',
        image: image ?? '',
        video: '',
        title: LinkPreviewScrapper.getTitle(doc) ?? '',
        type: LinkPreviewType.amazon,
      );
    } catch (e) {
      print('Amazon scrapper failure Error: $e');
      return WebInfo(
        description:
            'Free shipping on millions of items. Get the best of Shopping and Entertainment with Prime. Enjoy low prices and great deals on the largest selection of everyday essentials and other products, including fashion, home, beauty, electronics, Alexa Devices, sporting goods, toys, automotive, pets, baby, books, video games, musical instruments, office supplies, and more.',
        domain: LinkPreviewScrapper.getDomain(doc, url) ?? url,
        icon: 'https://www.amazon.com/favicon.ico',
        image:
            'http://g-ec2.images-amazon.com/images/G/01/social/api-share/amazon_logo_500500._V323939215_.png',
        video: '',
        title: 'Amazon.com. Spend less. Smile more.',
        type: LinkPreviewType.error,
      );
    }
  }
}
