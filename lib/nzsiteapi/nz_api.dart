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

  bool _inited = false;

  @override
  build(BuildContext context) {
    return Visibility(
      visible: true,
      child: WebViewPlus(
        initialUrl: '$baseUrl/login',
        onPageFinished: (c) {
          _onUrlChange(c);
          if(!_inited) {
            _inited = true;
            onLoad(this);
          }
        },
        onWebViewCreated: (c) async {
          print('onWebViewCreated ${c.webViewController}');
          _controller = c.webViewController;
          print(_controller);
        },
        javascriptMode: JavascriptMode.unrestricted,
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

  void _onUrlChange(String url) {
    var path = url.substring(baseUrl.length, url.length);
    print(path);
    switch (path) {
      case '/login':
        _changeState(NeedLoginState());
        print('login');
        break;
    }
  }

  bool _currentStateIs(Type type) {
    return currState?.runtimeType == type;
  }

  void login(String name, String password) async {
    if (!_currentStateIs(NeedLoginState)) return;
    await setValue(Id('loginform-login'), name);
    await setValue(Id('loginform-password'), password);
    //await clickButton(ClassName('ms-button form-submit-btn'));
  }

  void toggleCheckBox(ElementIdentifier identifier, bool value) async {
    await _controller!.runJavascript(
      "${_getObjectCall(identifier)}.value = $value",
    );
  }

  Future<void> setValue(ElementIdentifier identifier, String value, {String valueName = "value", bool valueIsString = true}) async {
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
