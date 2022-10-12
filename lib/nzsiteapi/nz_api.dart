import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import './types.dart';

class NzApi extends StatelessWidget {
  static const String baseUrl = "https://nz.ua";

  NzApi({Key? key, required this.onLoad}) : super(key: key);

  Function(NzApi) onLoad;
  WebViewController? _controller;
  NzState? currState;
  final BehaviorSubject<NzState> _state = BehaviorSubject();
  Stream<NzState> get state => _state.stream;
  late BuildContext _context;

  bool _inited = false;
  bool _loaded = false;

  @override
  build(BuildContext context) {
    _context = context;
    return Opacity(
      opacity: 1,
      child: Visibility(
        visible: true,
        child: WebViewPlus(
          initialUrl: '$baseUrl/menu',
          onPageFinished: (c) {
            _onUrlChange(c);

            if (!_inited && _controller != null) {
              _inited = true;
              _loaded = true;
              onLoad(this);
            }
          },
          onWebViewCreated: (c) {
            _controller = c.webViewController;
            print(_controller);
            if (!_inited && !_loaded) {
              _inited = true;
              _loaded = true;
              onLoad(this);
            }
          },
          onProgress: (progress) {},
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }

  /// loads specified URL, parse html and changes [_state]
  /// `url` - only url path
  Future<void> loadUrl(String url, {Map<String, String>? headers}) async {
    await _controller!.loadUrl("$baseUrl/$url", headers: headers);
  }

  void _changeState(NzState state) {
    _state.add(state);
    currState = state;
  }

  Future<SideMetadata> _getMetadata() async {
    var j = json.decode(await _executeScript('getMetadata.js'));
    return SideMetadata.fromJson(
        json.decode(await _executeScript('getMetadata.js')));
  }

  void _onUrlChange(String url) async {
    var path = url.substring(baseUrl.length, url.length);
    print(path);
    switch (path) {
      case '/login':
        _changeState(NeedLoginState());
        break;
      case '/menu':
        //we already login
        _changeState(MainPageState());
        break;
      case '/account/forgot-password':
        _changeState(NeedEmailState());
        break;
      case '/dashboard/news':
        var tabs =
            TabSet.fromJson(json.decode(await _executeScript('getTabs.js')));
        var news = NewsArr.fromJson(json.decode(await _executeScript('getNews.js')));
        var meta = await _getMetadata();
        _changeState(NewsPageState(
            tabs: tabs,
            news: news,
            meta: meta));
        break;
    }
  }

  Future<String> _executeScript(String script) async {
    var str = await DefaultAssetBundle.of(_context)
        .loadString('Assets/scripts/$script');
    return (await _controller!.runJavascriptReturningResult(str)).toString();
  }

  bool _currentStateIs(Type type) {
    return currState?.runtimeType == type;
  }

  Future<void> login(String name, String password) async {
    if (!_currentStateIs(NeedLoginState)) return;
    await setValue(Id('loginform-login'), name);
    await setValue(Id('loginform-password'), password);
    await clickButton(ClassName('ms-button form-submit-btn'));
  }

  void toggleCheckBox(ElementIdentifier identifier, bool value) async {
    await _controller!.runJavascript(
      "${_getObjectCall(identifier)}.value = $value",
    );
  }

  Future<void> goto(String path) async {
    await _controller!.loadUrl(NzApi.baseUrl + path);
  }

  Future<void> setValue(ElementIdentifier identifier, String value,
      {String valueName = "value", bool valueIsString = true}) async {
    var c = valueIsString ? "\"" : '';
    var js = "${_getObjectCall(identifier)}.$valueName = $c$value$c";
    await _controller!.runJavascript(js);
  }

  Future<void> clickButton(ElementIdentifier identifier) async {
    await _controller!.runJavascript("${_getObjectCall(identifier)}.click()");
  }

  String _getObjectCall(ElementIdentifier identifier) {
    var method = "";
    bool returnArray = false;
    switch (identifier.runtimeType) {
      case Id:
        method = "getElementById";
        break;
      case ClassName:
        method = "getElementsByClassName";
        returnArray = true;
        break;
    }

    return "document.$method(\"${identifier.getValue()}\")${returnArray ? '[0]' : ''}";
  }
}
