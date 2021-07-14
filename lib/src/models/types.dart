/// Represents the base object for [WebInfo].
abstract class InfoBase {
  late DateTime timeout;
}

/// Represents the link preview style used for rendering the widget.
enum LinkPreviewStyle { large, small }

/// Represents the link preview type/rule used for scrapping the link.
enum LinkPreviewType {
  def,
  audio,
  image,
  video,
  amazon,
  instagram,
  twitter,
  youtube,
  error,
}

/// Represents the Web Information object.
class WebInfo extends InfoBase {
  /// Description of the page.
  final String description;

  /// Domain name of the link.
  final String domain;

  /// Favicon of the page.
  final String icon;

  /// Image URL, if present any in the link.
  final String image;

  /// Title of the page.
  final String title;

  /// Link preview type of the rule used for scrapping the link.
  /// Returns [LinkPreviewType.error] if the scrapping is failed.
  final LinkPreviewType type;

  /// Video URL, if present any in the link.
  final String video;

  /// Creates [WebInfo]
  WebInfo({
    required this.description,
    required this.domain,
    required this.icon,
    required this.image,
    required this.title,
    required this.type,
    required this.video,
  });
}
