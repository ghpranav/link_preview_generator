import 'package:link_preview_generator/src/models/types.dart';
import 'package:link_preview_generator/src/utils/scrapper.dart';
import 'package:universal_html/html.dart';

class YouTubeScrapper {
  static String? getYoutTubeVideoId(String url) {
    final youtubeRegex = RegExp(
        r'.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*');
    if (youtubeRegex.hasMatch(url)) {
      return youtubeRegex.firstMatch(url)?.group(7);
    }
  }

  static WebInfo scrape(HtmlDocument doc, String url) {
    try {
      final id = getYoutTubeVideoId(url);
      var title = RegExp('"title":"(.+?)"')
          .firstMatch(doc.querySelector('html')?.innerHtml ?? '')
          ?.group(0)
          ?.split(':')[1]
          .trim();
      title = title != null
          ? title.substring(1, title.length - 1)
          : doc.querySelector('title')?.innerText;

      return WebInfo(
        description: LinkPreviewScrapper.getAttrOfDocElement(
                doc, 'meta[name="description"]', 'content') ??
            LinkPreviewScrapper.getAttrOfDocElement(
                doc, 'meta[name="twitter:description"]', 'content') ??
            url,
        domain: LinkPreviewScrapper.getDomain(doc, url) ?? url,
        icon: LinkPreviewScrapper.getIcon(doc, url) ?? '',
        image: id != null ? 'https://img.youtube.com/vi/$id/0.jpg' : '',
        video: '',
        title: title ?? '',
        type: LinkPreviewType.youtube,
      );
    } catch (e) {
      print('Youtube scrapper failure Error: $e');
      return WebInfo(
        description:
            'Enjoy the videos and music that you love, upload original content and share it all with friends, family and the world on YouTube.',
        domain: 'youtube.com',
        icon:
            'https://www.youtube.com/s/desktop/ff5301c8/img/favicon_96x96.png',
        image: '',
        video: '',
        title: 'YouTube',
        type: LinkPreviewType.error,
      );
    }
  }
}
