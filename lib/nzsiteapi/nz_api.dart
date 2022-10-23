import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prefs/prefs.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import './types.dart';

class NzApi extends StatelessWidget {
  static const String baseUrl = "https://nz.ua";

  NzApi({Key? key, required this.onLoad}) : super(key: key);

  Function(NzApi) onLoad;
  WebViewController? _controller;
  NzState? currSiteState;
  NzState? currLoginState;
  String? token;

  final BehaviorSubject<NzState> _loginState = BehaviorSubject();
  Stream<NzState> get loginState => _loginState.stream;

  final BehaviorSubject<NzState> _siteState = BehaviorSubject();
  Stream<NzState> get siteState => _siteState.stream;

  final BehaviorSubject<SideMetadata> _metadata = BehaviorSubject();
  Stream<SideMetadata> get sideMetadata => _metadata.stream;

  late BuildContext _context;

  bool _inited = false;
  bool _loaded = false;

  @override
  build(BuildContext context) {
    _context = context;
    return WebViewPlus(
      onWebViewCreated: (c) {
        print('created');
        c.loadUrl('${baseUrl}/menu');

        _controller = c.webViewController;
        token = Prefs.getString('apiToken');
        print('token = $token');
        if (!_inited && !_loaded) {
          _inited = true;
          _loaded = true;
          onLoad(this);
        }
      },
      onPageFinished: (c) {
        _onUrlChange(c);
        if (!_inited && _controller != null) {
          _inited = true;
          _loaded = true;
          onLoad(this);
        }
      },
      javascriptMode: JavascriptMode.unrestricted,
    );
  }

  /// loads specified URL, parse html and changes [_loginState]
  /// `url` - only url path
  Future<void> loadUrl(String url, {Map<String, String>? headers}) async {
    await _controller!.loadUrl("$baseUrl/$url", headers: headers);
  }

  void _changeLoginState(NzState state) {
    switch (state.runtimeType) {
      case NeedLoginState:
      case NeedEmailState:
        _loginState.add(state);
        currLoginState = state;
        break;
      default:
        if(currLoginState.runtimeType != StateLogined) {
          currLoginState = StateLogined();
          _loginState.add(currLoginState!);
        }
        break;
    }
  }

  void _changeSiteState(NzState state) {
    _siteState.add(state);
    _changeLoginState(state);
    currSiteState = state;

    switch (state.runtimeType) {
      case ProfilePageState:
      case NewsPageState:
      case DiaryPageState:
      case DiaryGridState:
      case SchedulePageState:
      case SecurityPageState:
        _metadata.add((state as dynamic).meta);
    }
  }

  Future<SideMetadata> _getMetadata() async {
    return SideMetadata.fromJson(
        json.decode(await _executeScript('getMetadata.js')));
  }

  void _onUrlChange(String url) async {
    var path = url.substring(baseUrl.length, url.length);
    print(path);
    switch (path) {
      case '/':
      case '/login':
        var u = Prefs.getString('username');
        var p = Prefs.getString('password');
        _changeSiteState(
          NeedLoginState.fromJson(
            json.decode(
              await _executeScript('getLoginPageState.js'),
            ),
          ),
        );
        if (u != "" && p != "") {
          print('login');
          await login(u, p);
        }
        break;
      case '/menu':
        //we already login
        _changeSiteState(MainPageState());
        break;
      case '/account/forgot-password':
        _changeSiteState(NeedEmailState());
        break;
      case '/dashboard/news':
        var tabs =
            TabSet.fromJson(json.decode(await _executeScript('getTabs.js')));
        var news =
            NewsArr.fromJson(json.decode(await _executeScript('getNews.js')));
        var meta = await _getMetadata();
        _changeSiteState(NewsPageState(tabs: tabs, news: news, meta: meta));
        break;
      case '/account/security':
        _changeSiteState(
          SecurityPageState(
            login: await _controller!.runJavascriptReturningResult(
              'document.getElementById(\'accountform-username\').value',
            ),
            email: EmailStatus(
              email: await _controller!.runJavascriptReturningResult(
                'document.getElementById(\'accountform-email\').value',
              ),
              confirmed: await _controller!.runJavascriptReturningResult(
                      'var t = document.getElementsByClassName(\'hint-block\')[0].innerText; t == \'Підтверджено\' || t == \'Подтверждён\';') ==
                  'true',
            ),
            phone: await _controller!.runJavascriptReturningResult(
              'document.getElementById(\'accountform-phonenumber\').value',
            ),
            meta: await _getMetadata(),
          ),
        );
        break;
    }

    var userProfileRegex = RegExp('$baseUrl\/id(.{0,})');
    if (userProfileRegex.hasMatch(url)) {
      var meta = await _getMetadata();
      var p = await _executeScript('getProfile.js');
      var v = ProfilePageState(
          profile: UserProfile.fromJson(
            json.decode(
              p,
            ),
          ),
          meta: meta);
      _changeSiteState(v);
    }

    var diaryRegex = RegExp('\/school.*\/schedule.*\/diary');
    if (diaryRegex.hasMatch(url)) {
      _changeSiteState(
        DiaryPageState(
          content: DiaryContentTopToDown.fromJson(
            json.decode(
              await _executeScript('getDiary.js'),
            ),
          ),
          meta: await _getMetadata(),
        ),
      );
    }

    var diaryGridRegex = RegExp('\/schedule\/grades-statement');
    if (diaryGridRegex.hasMatch(url)) {
      _changeSiteState(
        DiaryGridState(
          content: DiaryMarkGrid.fromJson(
            json.decode(await _executeScript('getDiaryGridTable.js')),
          ),
          meta: await _getMetadata(),
        ),
      );
    }

    var scheduleRegex = RegExp('school.*\/schedule');
    if (scheduleRegex.hasMatch(url)) {
      _changeSiteState(
        SchedulePageState(
          content: SchedulePageContent.fromJson(
            json.decode(
              await _executeScript('getSchedule.js'),
            ),
          ),
          metadata: await _getMetadata(),
        ),
      );
    }
  }

  Future<String> _executeScript(String script) async {
    var str = await DefaultAssetBundle.of(_context)
        .loadString('Assets/scripts/$script');
    var i = (await _controller!.runJavascriptReturningResult(str));
    return i.toString();
  }

  bool _currentStateIs(Type type) {
    return currSiteState?.runtimeType == type;
  }

  Future<bool> login(String name, String password) async {
    if (!_currentStateIs(NeedLoginState)) return true;
    await setValue(Id('loginform-login'), name);
    await setValue(Id('loginform-password'), password);
    await clickButton(ClassName('ms-button form-submit-btn'));

    bool success = true;

    var dio = Dio();
    dio.options.contentType = "application/json";
    await Prefs.setString('username', name);
    await Prefs.setString('password', password);
    try {
      var s = await dio.post('http://api-mobile.nz.ua/v1/user/login', data: """{
        "username": "$name",
        "password": "$password"
      }""");
      var response = ApiLoginResponse.fromJson(s.data);
      token = response.access_token;
      await Prefs.setString('apiToken', token);
    } catch (e) {
      print(e);
      success = false;
    }

    return success;
  }

  Future sendRecoverCode(String email) async {
    await setValue(Id('sendemailform-email'), email);
    await clickButton(ClassName('btn-primary'));
  }

  void forgotPassword() {
    _controller!.loadUrl('$baseUrl/account/forgot-password');
  }

  Future<ApiUserGetResponse?> _getAdditionalUserInfo(int id) async {
    try {
      var d = Dio();
      d.options.headers['content-type'] = 'application/json';
      d.options.headers['Authorization'] = 'Bearer $token';
      var r = await d.get('http://api-mobile.nz.ua/v1/user/$id');

      if (r.statusCode == 200) {
        return ApiUserGetResponse.fromJson(r.data);
      }
    } catch (_) {
      print('err');
    }
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
