import 'package:flutter/material.dart';
import 'package:link_preview_generator/link_preview_generator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link Preview Generator Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List of links to preview.
  List<String> get urls => const [
        'https://github.com/ghpranav/link_preview_generator',
        'https://www.espn.in/football/soccer-transfers/story/4163866/transfer-talk-lionel-messi-tells-barcelona-hes-more-likely-to-leave-then-stay',
        'https://speakerdeck.com/themsaid/the-power-of-laravel-queues',
        'https://twitter.com/laravelphp/status/1222535498880692225',
        'https://www.youtube.com/watch?v=W1pNjxmNHNQ',
        'https://www.instagram.com/p/CQ3WCUOru1T/',
        'https://www.google.com/'
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text('Link Preview Generator'),
      ),
      body: ListView.builder(
        itemCount: urls.length,
        itemBuilder: (context, index) => Container(
          key: ValueKey(urls[index]),
          margin: const EdgeInsets.all(15),
          // Generate a preview for each link.
          // Alternate between a large and small type preview widget.
          child: LinkPreviewGenerator(
            link: urls[index],
            linkPreviewStyle: index % 2 == 0
                ? LinkPreviewStyle.large
                : LinkPreviewStyle.small,
          ),
        ),
      ),
    );
  }
}
