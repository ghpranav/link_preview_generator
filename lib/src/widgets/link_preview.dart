import 'dart:async';

import 'package:flutter/material.dart';
import 'package:link_preview_generator/src/models/types.dart';
import 'package:link_preview_generator/src/utils/analyzer.dart';
import 'package:link_preview_generator/src/widgets/link_view_large.dart';
import 'package:link_preview_generator/src/widgets/link_view_small.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget to convert your links into beautiful previews.
class LinkPreviewGenerator extends StatefulWidget {
  /// Customize the background colour
  /// Deaults to `Color.fromRGBO(248, 248, 248, 1.0)`.
  final Color backgroundColor;

  /// Give the limit to body text (Description).
  /// Deaults to `3`.
  final int bodyMaxLines;

  /// Customize `body` [TextStyle].
  final TextStyle? bodyStyle;

  /// Give the overflow type for body text (Description).
  /// Deaults to `TextOverflow.ellipsis`.
  final TextOverflow bodyTextOverflow;

  /// BorderRadius for the card.
  /// Deafults to `12`.
  final double borderRadius;

  /// Box shadow for the card.
  ///  Deafults to `[BoxShadow(
  ///               spreadRadius: 1,
  ///               blurRadius: 5,
  ///               color: Colors.grey.withOpacity(0.5),
  ///               offset: Offset(0, 3),)]`.
  final List<BoxShadow>? boxShadow;

  /// Cache result time, default cache `30 days`.
  final Duration cacheDuration;

  /// Body that need to be shown if something goes wrong.
  /// Deaults to `Oops! Unable to parse the url.`
  final String errorBody;

  /// Image URL that will be shown if something goes wrong
  /// & when multimedia enabled & no meta data is available.
  /// Deaults to `A semi-soccer ball image that looks like crying`.
  /// https://github.com/ghpranav/link_preview_generator/blob/main/assets/giphy.gif?raw=true1
  final String errorImage;

  /// Title that need to be shown if something goes wrong.
  /// Deaults to `Something went wrong!`
  final String errorTitle;

  /// Widget that needs to be shown if something goes wrong.
  /// Defaults to plain container with given background colour.
  final Widget? errorWidget;

  /// Web address (URL that needs to be parsed/scrapped).
  final String link;

  /// Link Preview display style. One among `large` or `small`.
  /// Defaults to [LinkPreviewStyle.large].
  final LinkPreviewStyle linkPreviewStyle;

  /// Widget that needs to be shown when
  /// package is trying to fetch metadata.
  /// If not given anything then default widget will be shown.
  final Widget? placeholderWidget;

  /// Proxy URL to pass that resolve CORS issues on web.
  final String? proxyUrl;

  /// To remove the card elevation set it to `true`.
  /// Defaults to `false`.
  final bool removeElevation;

  /// Show or Hide image, if available.
  /// Defaults to `true`.
  final bool showGraphic;

  /// Customize `title` [TextStyle].
  final TextStyle? titleStyle;

  /// Creates [LinkPreviewGenerator]
  const LinkPreviewGenerator({
    Key? key,
    required this.link,
    this.cacheDuration = const Duration(days: 30),
    this.titleStyle,
    this.bodyStyle,
    this.linkPreviewStyle = LinkPreviewStyle.large,
    this.showGraphic = true,
    this.backgroundColor = const Color.fromRGBO(248, 248, 248, 1.0),
    this.bodyMaxLines = 3,
    this.bodyTextOverflow = TextOverflow.ellipsis,
    this.placeholderWidget,
    this.proxyUrl,
    this.errorWidget,
    this.errorBody = 'Oops! Unable to parse the url.',
    this.errorImage =
        'https://github.com/ghpranav/link_preview_generator/blob/main/assets/giphy.gif?raw=true',
    this.errorTitle = 'Something went wrong!',
    this.borderRadius = 12,
    this.boxShadow,
    this.removeElevation = false,
  }) : super(key: key);

  @override
  _LinkPreviewGeneratorState createState() => _LinkPreviewGeneratorState();
}

class _LinkPreviewGeneratorState extends State<LinkPreviewGenerator> {
  WebInfo? _info;
  bool _loading = false;
  late String _url;

  @override
  Widget build(BuildContext context) {
    final info = _info;
    var _height = (widget.linkPreviewStyle == LinkPreviewStyle.small ||
            !widget.showGraphic)
        ? ((MediaQuery.of(context).size.height) * 0.15)
        : ((MediaQuery.of(context).size.height) * 0.25);

    if (_loading) {
      return widget.placeholderWidget ??
          Container(
            height: _height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: const Color.fromRGBO(248, 248, 248, 1.0),
            ),
            alignment: Alignment.center,
            child: const Text('Fetching data...'),
          );
    }

    if (_info != null) {
      if (_info!.type == LinkPreviewType.image) {
        var img = _info!.image;
        return _buildLinkContainer(
          _height,
          title: widget.errorTitle,
          desc: widget.errorBody,
          image: (widget.proxyUrl ?? '') +
              (img.trim() == '' ? widget.errorImage : img),
        );
      }
    }

    return _info == null
        ? widget.errorWidget ??
            _buildPlaceHolder(widget.backgroundColor, _height)
        : _buildLinkContainer(
            _height,
            domain:
                LinkPreviewAnalyzer.isNotEmpty(info!.domain) ? info.domain : '',
            title: LinkPreviewAnalyzer.isNotEmpty(info.title)
                ? info.title
                : widget.errorTitle,
            desc: LinkPreviewAnalyzer.isNotEmpty(info.description)
                ? info.description
                : widget.errorBody,
            image: LinkPreviewAnalyzer.isNotEmpty(info.image)
                ? info.image
                : LinkPreviewAnalyzer.isNotEmpty(info.icon)
                    ? info.icon
                    : widget.errorImage,
            isIcon: LinkPreviewAnalyzer.isNotEmpty(info.image) ? false : true,
          );
  }

  @override
  void initState() {
    super.initState();

    _url = ((widget.proxyUrl ?? '') + widget.link).trim();
    _info = LinkPreviewAnalyzer.getInfoFromCache(_url) as WebInfo?;
    if (_info == null) {
      _loading = true;
      _getInfo();
    }
  }

  Widget _buildLinkContainer(
    double _height, {
    String? domain = '',
    String? title = '',
    String? desc = '',
    String? image = '',
    bool isIcon = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.removeElevation
            ? []
            : widget.boxShadow ??
                [
                  BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 5,
                    color: Colors.grey.withOpacity(0.5),
                    offset: const Offset(0, 3),
                  )
                ],
      ),
      height: _height,
      child: (widget.linkPreviewStyle == LinkPreviewStyle.small)
          ? LinkViewSmall(
              key: widget.key ?? Key(widget.link.toString()),
              url: widget.link,
              domain: domain!,
              title: title!,
              description: desc!,
              imageUri: image!,
              onTap: _launchURL,
              titleTextStyle: widget.titleStyle,
              bodyTextStyle: widget.bodyStyle,
              bodyTextOverflow: widget.bodyTextOverflow,
              bodyMaxLines: widget.bodyMaxLines,
              showMultiMedia: widget.showGraphic,
              isIcon: isIcon,
              bgColor: widget.backgroundColor,
              radius: widget.borderRadius,
            )
          : LinkViewLarge(
              key: widget.key ?? Key(widget.link.toString()),
              url: widget.link,
              domain: domain!,
              title: title!,
              description: desc!,
              imageUri: image!,
              onTap: _launchURL,
              titleTextStyle: widget.titleStyle,
              bodyTextStyle: widget.bodyStyle,
              bodyTextOverflow: widget.bodyTextOverflow,
              bodyMaxLines: widget.bodyMaxLines,
              showMultiMedia: widget.showGraphic,
              isIcon: isIcon,
              bgColor: widget.backgroundColor,
              radius: widget.borderRadius,
            ),
    );
  }

  Widget _buildPlaceHolder(Color color, double defaultHeight) {
    return SizedBox(
      height: defaultHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          var layoutWidth = constraints.biggest.width;
          var layoutHeight = constraints.biggest.height;

          return Container(
            color: color,
            width: layoutWidth,
            height: layoutHeight,
          );
        },
      ),
    );
  }

  Future<void> _getInfo() async {
    if (_url.startsWith('http') || _url.startsWith('https')) {
      _info = await LinkPreviewAnalyzer.getInfo(_url,
          cacheDuration: widget.cacheDuration, multimedia: true) as WebInfo?;
    } else {
      print('Error: $_url is not starting with either http or https.');
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      try {
        await launch(url);
      } catch (err) {
        throw Exception('Could not launch $url. Error: $err');
      }
    }
  }
}
