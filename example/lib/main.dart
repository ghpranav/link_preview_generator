import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link Preveiw Generator Demo',
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
  List<String> get urls => const [
        'https://flyer.chat',
        "https://www.espn.in/football/soccer-transfers/story/4163866/transfer-talk-lionel-messi-tells-barcelona-hes-more-likely-to-leave-then-stay",
        "https://speakerdeck.com/themsaid/the-power-of-laravel-queues",
        "https://twitter.com/laravelphp/status/1222535498880692225",
        "https://www.youtube.com/watch?v=W1pNjxmNHNQ",
        "https://www.google.com",
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text('Link Preveiw Generator'),
      ),
      body: ListView.builder(
        itemCount: urls.length,
        itemBuilder: (context, index) => Container(
          key: ValueKey(urls[index]),
          margin: const EdgeInsets.all(15),
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
