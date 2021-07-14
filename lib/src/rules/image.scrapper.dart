import 'package:link_preview_generator/src/models/types.dart';
import 'package:link_preview_generator/src/utils/scrapper.dart';
import 'package:universal_html/html.dart';

class ImageScrapper {
  static WebInfo scrape(HtmlDocument doc, String url) {
    try {
      return WebInfo(
        description: url,
        domain: LinkPreviewScrapper.getDomain(doc, url) ?? url,
        icon: LinkPreviewScrapper.getIcon(doc, url) ?? '',
        image: '',
        video: '',
        title: url.substring(url.lastIndexOf('/') + 1),
        type: LinkPreviewType.image,
      );
    } catch (e) {
      print('Image scrapper failure Error: $e');
      return WebInfo(
        description: url,
        domain: LinkPreviewScrapper.getDomain(doc, url) ?? url,
        icon: '',
        image: '',
        video: '',
        title: url.substring(url.lastIndexOf('/') + 1),
        type: LinkPreviewType.error,
      );
    }
  }
}
