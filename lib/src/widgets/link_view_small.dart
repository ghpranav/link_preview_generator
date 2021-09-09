import 'package:flutter/material.dart';

/// Small type LinkPreviewGenerator widget
class LinkViewSmall extends StatelessWidget {
  final Color? bgColor;
  final int? bodyMaxLines;
  final TextOverflow? bodyTextOverflow;
  final TextStyle? bodyTextStyle;
  final String description;
  final String domain;
  final TextStyle? domainTextStyle;
  final String imageUri;
  final bool isIcon;
  final double? radius;
  final bool showBody;
  final bool showDomain;
  final bool showGraphic;
  final bool showTitle;
  final BoxFit graphicFit;
  final String title;
  final TextStyle? titleTextStyle;
  final String url;

  const LinkViewSmall({
    Key? key,
    required this.url,
    required this.domain,
    required this.title,
    required this.description,
    required this.imageUri,
    required this.graphicFit,
    required this.showBody,
    required this.showDomain,
    required this.showGraphic,
    required this.showTitle,
    this.titleTextStyle,
    this.bodyTextStyle,
    this.domainTextStyle,
    this.bodyTextOverflow,
    this.bodyMaxLines,
    this.isIcon = false,
    this.bgColor,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var layoutWidth = constraints.biggest.width;
        var layoutHeight = constraints.biggest.height;

        var _titleFontSize = titleTextStyle ??
            TextStyle(
              fontSize: computeTitleFontSize(layoutWidth),
              color: Colors.black,
              fontWeight: FontWeight.bold,
            );
        var _bodyFontSize = bodyTextStyle ??
            TextStyle(
              fontSize: computeTitleFontSize(layoutWidth) - 1,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            );
        var _domainTS = bodyTextStyle ??
            TextStyle(
              fontSize: computeTitleFontSize(layoutHeight) - 1,
              color: Colors.blue,
              fontWeight: FontWeight.w400,
            );

        return Row(
          children: <Widget>[
            showGraphic
                ? Expanded(
                    flex: 2,
                    child: imageUri == ''
                        ? Container(color: bgColor ?? Colors.grey)
                        : Container(
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(imageUri),
                                fit: isIcon ? BoxFit.contain : graphicFit,
                              ),
                              borderRadius: radius == 0
                                  ? BorderRadius.zero
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(radius!),
                                      bottomLeft: Radius.circular(radius!),
                                    ),
                            ),
                          ),
                  )
                : const SizedBox(width: 5),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    showTitle
                        ? _buildTitleContainer(
                            _titleFontSize, computeTitleLines(layoutHeight))
                        : const SizedBox(),
                    showBody
                        ? _buildBodyContainer(_bodyFontSize, _domainTS,
                            computeBodyLines(layoutHeight))
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int computeBodyLines(layoutHeight) {
    var lines = 1;
    if (layoutHeight > 60) {
      lines += (layoutHeight - 60.0) ~/ 30.0 as int;
    }
    lines += (showDomain ? 0 : 1) + (showTitle ? 0 : 1);
    return lines;
  }

  double computeTitleFontSize(double width) {
    var size = width * 0.13;
    if (size > 15) {
      size = 15;
    }
    return size;
  }

  int computeTitleLines(layoutHeight) {
    return layoutHeight >= 100 ? 2 : 1;
  }

  Widget _buildBodyContainer(
      TextStyle _bodyTS, TextStyle _domainTS, _maxLines) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 3, 5, 0),
        child: Column(
          children: <Widget>[
            showDomain
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Align(
                      alignment: const Alignment(-1.0, -1.0),
                      child: Text(
                        domain,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: _domainTS,
                      ),
                    ),
                  )
                : const SizedBox(),
            Expanded(
              child: Container(
                alignment: const Alignment(-1.0, -1.0),
                child: Text(
                  description,
                  textAlign: TextAlign.left,
                  style: _bodyTS,
                  overflow: bodyTextOverflow ?? TextOverflow.ellipsis,
                  maxLines: bodyMaxLines ?? _maxLines,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleContainer(TextStyle _titleTS, _maxLines) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 3, 1),
      child: Column(
        children: <Widget>[
          Container(
            alignment: const Alignment(-1.0, -1.0),
            child: Text(
              title,
              style: _titleTS,
              overflow: TextOverflow.ellipsis,
              maxLines: _maxLines,
            ),
          ),
        ],
      ),
    );
  }
}
