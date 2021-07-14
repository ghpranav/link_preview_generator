import 'package:collection/collection.dart';
import 'package:link_preview_generator/src/models/types.dart';
import 'package:link_preview_generator/src/utils/analyzer.dart';
import 'package:link_preview_generator/src/utils/scrapper.dart';
import 'package:universal_html/html.dart';

class DefaultScrapper {
  static WebInfo scrape(HtmlDocument doc, String url) {
    try {
      var baseUrl = LinkPreviewScrapper.getBaseUrl(doc, url);

      var image = [
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'meta[property="og:logo"]', 'content'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'meta[itemprop="logo"]', 'content'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'img[itemprop="logo"]', 'src'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, "meta[property='og:image']", 'content'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'img[class*="logo" i]', 'src'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'img[src*="logo" i]', 'src'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'meta[property="og:image:secure_url"]', 'content'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'meta[property="og:image:url"]', 'content'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'meta[property="og:image"]', 'content'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'meta[name="twitter:image:src"]', 'content'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'meta[name="twitter:image"]', 'content'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'meta[itemprop="image"]', 'content'),
      ]
          .where((i) => LinkPreviewAnalyzer.isNotEmpty(i))
          .map((i) => LinkPreviewScrapper.fixRelativeUrls(baseUrl, i!))
          .firstOrNull;

      var icon = [
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'meta[property="og:logo"]', 'content'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'meta[itemprop="logo"]', 'content'),
        LinkPreviewScrapper.getAttrOfDocElement(
            doc, 'img[itemprop="logo"]', 'src'),
      ]
          .where((i) => LinkPreviewAnalyzer.isNotEmpty(i))
          .map((i) => LinkPreviewScrapper.fixRelativeUrls(baseUrl, i!))
          .firstOrNull;

      return WebInfo(
        description: _getDescription(doc) ?? '',
        domain: LinkPreviewScrapper.getDomain(doc, url) ?? url,
        icon: LinkPreviewScrapper.getIcon(doc, url) ?? icon ?? '',
        image: image ?? _getDocImage(doc, url) ?? '',
        video: '',
        title: LinkPreviewScrapper.getTitle(doc) ?? '',
        type: LinkPreviewType.def,
      );
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

  static String? _getDescription(HtmlDocument doc) {
    try {
      final ogDescription = doc.querySelector('meta[name=description]');
      if (ogDescription != null &&
          ogDescription.attributes['content'] != null &&
          ogDescription.attributes['content']!.isNotEmpty) {
        return ogDescription.attributes['content'];
      }
      final twitterDescription =
          doc.querySelector('meta[name="twitter:description"]');
      if (twitterDescription != null &&
          twitterDescription.attributes['content'] != null &&
          twitterDescription.attributes['content']!.isNotEmpty) {
        return twitterDescription.attributes['content'];
      }
      final metaDescription = doc.querySelector('meta[name="description"]');
      if (metaDescription != null &&
          metaDescription.attributes['content'] != null &&
          metaDescription.attributes['content']!.isNotEmpty) {
        return metaDescription.attributes['content'];
      }
      final paragraphs = doc.querySelectorAll('p');
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
      print('Get default description resolution failure Error: $e');
      return null;
    }
  }

  static String? _getDocImage(HtmlDocument doc, String url) {
    try {
      List<ImageElement> imgs = doc.querySelectorAll('img');
      var src = <String?>[];
      if (imgs.isNotEmpty) {
        imgs = imgs.where((img) {
          // ignore: unnecessary_null_comparison
          if (img == null ||
              // ignore: unnecessary_null_comparison
              img.naturalHeight == null ||
              // ignore: unnecessary_null_comparison
              img.naturalWidth == null) return false;
          var addImg = true;
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
        if (imgs.isNotEmpty) {
          imgs.forEach((img) {
            if (img.src != null && !img.src!.contains('//')) {
              src.add('${Uri.parse(url).origin}/${img.src!}');
            }
          });
          return LinkPreviewScrapper.handleUrl(src.first!, 'image');
        }
      }
      return null;
    } catch (e) {
      print('Get default image resolution failure Error: $e');
      return null;
    }
  }
}
