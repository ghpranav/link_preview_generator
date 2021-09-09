# Link Preview Generator

[![Pub](https://img.shields.io/pub/v/link_preview_generator)](https://pub.dev/packages/link_preview_generator)
[![build](https://github.com/ghpranav/link_preview_generator/workflows/build/badge.svg)](https://github.com/ghpranav/link_preview_generator/actions?query=workflow%3Abuild)
[![CodeFactor](https://www.codefactor.io/repository/github/ghpranav/link_preview_generator/badge)](https://www.codefactor.io/repository/github/ghpranav/link_preview_generator)
[![License](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Donate](https://img.shields.io/badge/Donate-UPI-green.svg)](https://upayi.ml/bedrepranav@okhdfcbank)

<p align="center">
  <img src="https://raw.githubusercontent.com/ghpranav/link_preview_generator/main/assets/header.png" width="480">
</p>

A cross-platform flutter package to convert your links into rich beautiful previews. <br>
This package is inspired from [Any Link Preview](https://pub.dartlang.org/packages/any_link_preview) package, but the entire parsing & scrapping logic has been re-written to be more robust & to support more links. It also provides control over complete customization of the widget.

## Usage

<p align="center">
<img src="https://raw.githubusercontent.com/ghpranav/link_preview_generator/main/assets/demo-1.png" height="480">
<img src="https://raw.githubusercontent.com/ghpranav/link_preview_generator/main/assets/demo-2.png" height="480">
</p>

### Widget Example

```dart
import 'package:link_preview_generator/link_preview_generator.dart';

/// Generate a beautiful link preview card widget
LinkPreviewGenerator(
    bodyMaxLines: 3,
    link: 'https://github.com/ghpranav/link_preview_generator',
    linkPreviewStyle: LinkPreviewStyle.large,
    showGraphic: true,
)
```

### Function Example

```dart
import 'package:link_preview_generator/link_preview_generator.dart';

/// Pass the URL to be parsed/scraped
/// to build your own custom widget with parsed data
final WebInfo info = await LinkPreview.scrapeFromURL('https://github.com/ghpranav/link_preview_generator');

/// Description of the page.
final String description = info.description;

/// Domain name of the link.
final String domain = info.domain;

/// Favicon of the page.
final String icon = info.icon;

/// Image URL, if present any in the link.
final String image = info.image;

/// Title of the page.
final String title = info.title;

/// Link preview type of the rule used for scrapping the link.
/// Returns [LinkPreviewType.error] if the scrapping is failed.
final LinkPreviewType type = info.type;

/// Video URL, if present any in the link.
final String video = info.video;
```

## Props & Methods

### LinkPreviewGenerator

| PropName              | Description                                                 | PropType          | value                                                                                                                               | required |
| --------------------- | ----------------------------------------------------------- | ----------------- | ----------------------------------------------------------------------------------------------------------------------------------- | -------- |
| **link**              | URL to display as preview                                   | String            |                                                                                                                                     | `true`   |
| **backgroundColor**   | Customize the background colour of widget                   | Color             | default(`Color.fromRGBO(248, 248, 248, 1.0)`)                                                                                       | `false`  |
| **bodyMaxLines**      | Maximum number of description body lines                    | int               | default(`auto`)                                                                                                                     | `false`  |
| **bodyStyle**         | Customize the description body style                        | TextStyle         | N.A                                                                                                                                 | `false`  |
| **bodyTextOverflow**  | Overflow type for description body text                     | TextOverflow      | default(`TextOverflow.ellipsis`)                                                                                                    | `false`  |
| **borderRadius**      | Border radius for the widget card                           | double            | default(`12.0`)                                                                                                                     | `false`  |
| **boxShadow**         | Box shadow for the widget card                              | List<`BoxShadow`> |                                                                                                                                     | `false`  |
| **cacheDuration**     | Cache the parsed result for a certain duration              | Duration          | default(`Duration(days: 7)`)                                                                                                        | `false`  |
| **errorBody**         | Body that need to be shown if parsing fails                 | String            | default(`Oops! Unable to parse the url.`)                                                                                           | `false`  |
| **errorImage**        | Image URL that will be shown if parsing fails               | String            | default([A crying semi-soccer ball image](https://raw.githubusercontent.com/ghpranav/link_preview_generator/main/assets/giphy.gif)) | `false`  |
| **errorTitle**        | Title that need to be shown if parsing fails                | String            | default(`Something went wrong!`)                                                                                                    | `false`  |
| **errorWidget**       | Widget shown if parsing fails. Defaults to plain container  | Widget            |                                                                                                                                     | `false`  |
| **graphicFit**        | Adjust the box fit of the image                             | BoxFit            | default(`BoxFit.cover`)                                                                                                             | `false`  |
| **linkPreviewStyle**  | Link Preview card display style                             | LinkPreviewStyle  | default(`large`) `small`,`large`                                                                                                    | `false`  |
| **onTap**             | Function that needs to be called when user taps on the card | Function()        | default(`launchURL(link)`)                                                                                                          | `false`  |
| **placeholderWidget** | Widget shown when parsing the link                          | Widget            |                                                                                                                                     | `false`  |
| **proxyUrl**          | Proxy URL to pass that resolve CORS issues on web           | String            | example(`https://cors-anywhere.herokuapp.com/`)                                                                                     | `false`  |
| **removeElevation**   | To remove the widget card elevation                         | bool              | default(`false`) `true`,`false`                                                                                                     | `false`  |
| **showBody**          | Show or Hide body text (Description)                        | bool              | default(`true`) `true`,`false`                                                                                                      | `false`  |
| **showDomain**        | Show or Hide domain name                                    | bool              | default(`true`) `true`,`false`                                                                                                      | `false`  |
| **showGraphic**       | Show or Hide the image after parsing, if available          | bool              | default(`true`) `true`,`false`                                                                                                      | `false`  |
| **showTitle**         | Show or Hide title                                          | bool              | default(`true`) `true`,`false`                                                                                                      | `false`  |
| **titleStyle**        | Customize the title style                                   | TextStyle         | N.A                                                                                                                                 | `false`  |

## Contributing

1. Fork it

2. Create your feature branch (`git checkout -b my-new-feature`)

3. Commit your changes (`git commit -am 'Added some feature'`)

4. Push to the branch (`git push origin my-new-feature`)

5. Create new Pull Request

## Contributors

<a href="https://github.com/ghpranav/link_preview_generator/graphs/contributors"><img src="https://contributors-img.firebaseapp.com/image?repo=ghpranav/link_preview_generator" alt="Image of contributors"></a>

## License

[MIT](LICENSE)
