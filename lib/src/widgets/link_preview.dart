import 'dart:async';

import 'package:flutter/material.dart';
import 'package:link_preview_generator/src/types.dart';
import 'package:link_preview_generator/src/utils.dart';
import 'package:link_preview_generator/src/widgets/link_view_horizontal.dart';
import 'package:link_preview_generator/src/widgets/link_view_vertical.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget to convert your links into beautiful previews
class LinkPreviewGenerator extends StatefulWidget {
  final Key? key;

  /// Link Preview display style. One among `large, small`
  /// By default it is `large`
  final LinkPreviewStyle linkPreviewStyle;

  /// Web address (Url that need to be parsed)
  final String link;

  /// Customize background colour
  /// Deaults to `Color.fromRGBO(248, 248, 248, 1.0)`
  final Color? backgroundColor;

  /// Widget that need to be shown when
  /// package is trying to fetch metadata
  /// If not given anything then default one will be shown
  final Widget? placeholderWidget;

  /// Widget that need to be shown if something goes wrong
  /// Defaults to plain container with given background colour
  /// If the issue is know then we will show customized UI
  /// Other options of error params are used
  final Widget? errorWidget;

  /// Title that need to be shown if something goes wrong
  /// Deaults to `Something went wrong!`
  final String? errorTitle;

  /// Body that need to be shown if something goes wrong
  /// Deaults to `Oops! Unable to parse the url. We have sent feedback to our developers & we will try to fix this in our next release. Thanks!`
  final String? errorBody;

  /// Image that will be shown if something goes wrong
  /// & when multimedia enabled & no meta data is available
  /// Deaults to `A semi-soccer ball image that looks like crying`
  final String? errorImage;

  /// Give the overflow type for body text (Description)
  /// Deaults to `TextOverflow.ellipsis`
  final TextOverflow bodyTextOverflow;

  /// Give the limit to body text (Description)
  /// Deaults to `3`
  final int bodyMaxLines;

  /// Cache result time, default cache `30 days`
  /// Works only for IOS & not for android
  final Duration cache;

  /// Customize body `TextStyle`
  final TextStyle? titleStyle;

  /// Customize body `TextStyle`
  final TextStyle? bodyStyle;

  /// Show or Hide image if available defaults to `true`
  final bool showGraphic;

  /// BorderRadius for the card. Deafults to `12`
  final double? borderRadius;

  /// To remove the card elevation set it to `true`
  /// Default value is `false`
  final bool removeElevation;

  /// Box shadow for the card. Deafults to `[BoxShadow(blurRadius: 3, color: Colors.grey)]`
  final List<BoxShadow>? boxShadow;

  /// Creates [LinkPreviewGenerator]
  const LinkPreviewGenerator({
    this.key,
    required this.link,
    this.cache = const Duration(days: 30),
    this.titleStyle,
    this.bodyStyle,
    this.linkPreviewStyle = LinkPreviewStyle.large,
    this.showGraphic = true,
    this.backgroundColor = const Color.fromRGBO(248, 248, 248, 1.0),
    this.bodyMaxLines = 3,
    this.bodyTextOverflow = TextOverflow.ellipsis,
    this.placeholderWidget,
    this.errorWidget,
    this.errorBody,
    this.errorImage,
    this.errorTitle,
    this.borderRadius,
    this.boxShadow,
    this.removeElevation = false,
  }) : super(key: key);

  @override
  _LinkPreviewGeneratorState createState() => _LinkPreviewGeneratorState();
}

class _LinkPreviewGeneratorState extends State<LinkPreviewGenerator> {
  InfoBase? _info;
  String? _errorImage, _errorTitle, _errorBody, _url;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final WebInfo? info = _info as WebInfo?;
    double _height = (widget.linkPreviewStyle == LinkPreviewStyle.small ||
            !widget.showGraphic)
        ? ((MediaQuery.of(context).size.height) * 0.15)
        : ((MediaQuery.of(context).size.height) * 0.25);

    if (_loading)
      return widget.placeholderWidget ??
          Container(
            height: _height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              color: Colors.grey[200],
            ),
            alignment: Alignment.center,
            child: Text('Fetching data...'),
          );

    if (_info is WebImageInfo) {
      String img = (_info as WebImageInfo).image!;
      return _buildLinkContainer(
        _height,
        title: _errorTitle,
        desc: _errorBody,
        image: img.trim() == "" ? _errorImage : img,
      );
    }

    return _info == null
        ? widget.errorWidget ??
            _buildPlaceHolder(widget.backgroundColor!, _height)
        : _buildLinkContainer(
            _height,
            domain:
                LinkPreviewUtils.isNotEmpty(info!.domain) ? info.domain : "",
            title: LinkPreviewUtils.isNotEmpty(info.title)
                ? info.title
                : _errorTitle,
            desc: LinkPreviewUtils.isNotEmpty(info.description)
                ? info.description
                : _errorBody,
            image: LinkPreviewUtils.isNotEmpty(info.image)
                ? info.image
                : LinkPreviewUtils.isNotEmpty(info.icon)
                    ? info.icon
                    : _errorImage,
            isIcon: LinkPreviewUtils.isNotEmpty(info.image) ? false : true,
          );
  }

  @override
  void initState() {
    _errorImage = widget.errorImage ??
        "https://github.com/ghpranav/link_preview_generator/blob/main/lib/assets/giphy.gif?raw=true";
    _errorTitle = widget.errorTitle ?? "Something went wrong!";
    _errorBody = widget.errorBody ??
        "Oops! Unable to parse the url. We have sent feedback to our developers & we will try to fix this in our next release. Thanks!";
    _url = widget.link.trim();
    _info = LinkPreviewUtils.getInfoFromCache(_url);
    if (_info == null) {
      _loading = true;
      _getInfo();
    }
    super.initState();
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
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
        boxShadow: widget.removeElevation
            ? []
            : widget.boxShadow ??
                [BoxShadow(blurRadius: 3, color: Colors.grey)],
      ),
      height: _height,
      child: (widget.linkPreviewStyle == LinkPreviewStyle.small)
          ? LinkViewHorizontal(
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
              radius: widget.borderRadius ?? 12,
            )
          : LinkViewVertical(
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
              radius: widget.borderRadius ?? 12,
            ),
    );
  }

  Widget _buildPlaceHolder(Color color, double defaultHeight) {
    return Container(
      height: defaultHeight,
      child: LayoutBuilder(builder: (context, constraints) {
        var layoutWidth = constraints.biggest.width;
        var layoutHeight = constraints.biggest.height;

        return Container(
          color: color,
          width: layoutWidth,
          height: layoutHeight,
        );
      }),
    );
  }

  Future<void> _getInfo() async {
    if (_url!.startsWith("http") || _url!.startsWith("https")) {
      _info = await LinkPreviewUtils.getInfo(_url!,
          cache: widget.cache, multimedia: true);
      if (this.mounted) {
        setState(() {
          _loading = false;
        });
      }
    } else {
      print("$_url is not starting with either http or https");
    }
  }

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      try {
        await launch(url);
      } catch (err) {
        throw 'Could not launch $url. Error: $err';
      }
    }
  }
}
