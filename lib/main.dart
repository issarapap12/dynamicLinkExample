import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MaterialApp(
    title: 'Dynamic Links Example',
    routes: <String, WidgetBuilder>{
      '/': (BuildContext context) => _MainScreen(),
      '/helloworld': (BuildContext context) => _DynamicLinkScreen(),
    },
  ));
}

class _MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {
  String _linkMessage;
  bool _isCreatingLink = false;
  String _testString = 'To test';

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        // ignore: unawaited_futures
        Navigator.pushNamed(context, deepLink.path);
        print(deepLink.path);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      // ignore: unawaited_futures
      Navigator.pushNamed(context, deepLink.path);
      print(deepLink.path);
    }
  }

  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://issaraphap.page.link',
      link: Uri.parse('https://issaraphap.page.link/helloworld'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.dynamic_link',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.example.dynamic_link',
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic Links Example'),
        ),
        body: Builder(builder: (BuildContext context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: !_isCreatingLink
                          ? () => _createDynamicLink(false)
                          : null,
                      child: const Text('Get Long Link'),
                    ),
                    ElevatedButton(
                      onPressed: !_isCreatingLink
                          ? () => _createDynamicLink(true)
                          : null,
                      child: const Text('Get Short Link'),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    if (_linkMessage != null) {
                      await launch(_linkMessage);
                    }
                  },
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: _linkMessage));
                  },
                  child: Text(
                    _linkMessage ?? '',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                Text(_linkMessage == null ? '' : _testString)
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DynamicLinkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World'),
        ),
        body: Center(
          child: Center(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }
}
