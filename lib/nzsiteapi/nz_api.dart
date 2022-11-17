import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prefs/prefs.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import './types.dart';

class NzApi extends StatelessWidget {
  static const String baseUrl = "https://nz.ua";

  NzApi({Key? key, required this.onLoad}) : super(key: key);

  Function(NzApi) onLoad;
  static WebViewController? controller;
  NzState? currSiteState;
  NzState? currLoginState;
  String? token;

  final BehaviorSubject<NzState> _loginState = BehaviorSubject();
  Stream<NzState> get loginState => _loginState.stream;

  final BehaviorSubject<NzState> _siteState = BehaviorSubject();
  Stream<NzState> get siteState => _siteState.stream;

  final BehaviorSubject<SideMetadata> _metadata = BehaviorSubject();
  Stream<SideMetadata> get sideMetadata => _metadata.stream;

  final BehaviorSubject<DiaryContentTopToDown> _diaryContentTopDown =
      BehaviorSubject();
  Stream<DiaryContentTopToDown> get diaryContentTopDown =>
      _diaryContentTopDown.stream;

  final BehaviorSubject<DiaryMarkGrid> _diaryContentGrid = BehaviorSubject();
  Stream<DiaryMarkGrid> get diaryContentGrid => _diaryContentGrid.stream;

  final BehaviorSubject<NewsPageState> _newsState = BehaviorSubject();
  Stream<NewsPageState> get newsStream => _newsState.stream;

  final BehaviorSubject<ProfilePageState> _profilePageState = BehaviorSubject();
  Stream<ProfilePageState> get profilePages => _profilePageState.stream;

  late BuildContext _context;

  bool _inited = false;
  bool _loaded = false;

  bool _hasInternet = false;

  @override
  build(BuildContext context) {
    _context = context;
    return FutureBuilder(
      future: (Connectivity().checkConnectivity()),
      builder: (_, d) {
        if (d.hasData) {
          _hasInternet = d.data != ConnectivityResult.none;
          Connectivity().onConnectivityChanged.listen((event) {
            bool n = event != ConnectivityResult.none;

            if (n != _hasInternet) {
              _hasInternet = n;
              if (_hasInternet) {
                _onInternetReturn();
              }
            }

            if (!_hasInternet &&
                currLoginState is NeedLoginState &&
                Prefs.getString('username').isNotEmpty) {
              //offline login
              _changeLoginState(StateLogined());
            }
          });
        }
        return WebViewPlus(
          onWebViewCreated: (c) {
            print('created');
            c.loadUrl('${baseUrl}/menu');

            controller ??= c.webViewController;
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
            if (!_inited && controller != null) {
              _inited = true;
              _loaded = true;
              onLoad(this);
            }
          },
          javascriptMode: JavascriptMode.unrestricted,
        );
      },
    );
  }

  void _onInternetReturn() {
    controller?.reload();
  }

  /// loads specified URL, parse html and changes [_loginState]
  /// `url` - only url path
  Future<void> loadUrl(String url, {Map<String, String>? headers}) async {
    await controller!.loadUrl("$baseUrl/$url", headers: headers);
  }

  void _changeLoginState(NzState state) {
    switch (state.runtimeType) {
      case NeedLoginState:
      case NeedEmailState:
        _loginState.add(state);
        currLoginState = state;
        break;
      default:
        if (currLoginState.runtimeType != StateLogined) {
          currLoginState = StateLogined();
          _loginState.add(currLoginState!);
        }
        break;
    }
  }

  void openProfile({String? id}) async {
    if (id == null) {
      var url = await controller!.runJavascriptReturningResult(
          'document.getElementsByClassName(\'profile-menu\')[0].children[0].href');
      await controller!.loadUrl(url.replaceAll('\"', ''));
    } else {
      controller!.loadUrl('$baseUrl/id$id');
    }
  }

  void forceUpdateNews({String? url}) {
    controller!.loadUrl(url ?? '$baseUrl/dashboard/news');
  }

  void forceUpdateGridDiary({String? fromDate}) async {
    await forceUpdateDiary();
    var link = await controller!.runJavascriptReturningResult(
        'document.getElementsByClassName(\'table-view-link\')[0].href');
    link = link.replaceAll('\"', '');
    print('grid diry link is $link');
    await controller!.loadUrl(link);
  }

  Future forceUpdateDiary({String? fromDate}) async {
    try {
      var url = await _executeScript('getScheduleLink.js');
      if (fromDate != null) {
        url = url.replaceFirst('diary', 'diary?start_date=$fromDate');
      }
      controller!.loadUrl(url.replaceAll('\"', ''));
    } catch (e) {
      // we have no internet or smth like that
    }
  }

  void forceUpdateMetadata() {
    controller!.loadUrl('$baseUrl/dashboard/news');
  }

  void _changeSiteState(NzState state) {
    _siteState.add(state);
    _changeLoginState(state);
    currSiteState = state;

    switch (state.runtimeType) {
      case DiaryPageState:
        var c = (state as DiaryPageState).content;
        if (c != null) _diaryContentTopDown.add(c);
        break;

      case DiaryGridState:
        var c = (state as DiaryGridState).content;
        if (c != null) _diaryContentGrid.add(c);
        break;

      case NewsPageState:
        _newsState.add((state as NewsPageState));
        break;

      case ProfilePageState:
        _profilePageState.add(state as ProfilePageState);
        break;
    }

    //meta
    switch (state.runtimeType) {
      case ProfilePageState:
      case NewsPageState:
      case DiaryPageState:
      case DiaryGridState:
      case SchedulePageState:
      case SecurityPageState:
        _metadata.add((state as dynamic).meta);
        break;
    }
  }

  bool hasInternetConnection() => _hasInternet;

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

      case '/dashboard/school-news':
      case '/dashboard/global-news':
      case '/dashboard/news':
        if (_hasInternet) {
          var tabs =
              TabSet.fromJson(json.decode(await _executeScript('getTabs.js')));
          String script = path == '/dashboard/global-news'
              ? 'getProjectNews.js'
              : 'getNews.js';
          var news = NewsArr.fromJson(
            json.decode(
              await _executeScript(script),
            ),
          );
          var meta = await _getMetadata();
          _changeSiteState(NewsPageState(tabs: tabs, news: news, meta: meta));
        }
        break;
      case '/account/security':
        if (_hasInternet) {
          _changeSiteState(
            SecurityPageState(
              login: await controller!.runJavascriptReturningResult(
                'document.getElementById(\'accountform-username\').value',
              ),
              email: EmailStatus(
                email: await controller!.runJavascriptReturningResult(
                  'document.getElementById(\'accountform-email\').value',
                ),
                confirmed: await controller!.runJavascriptReturningResult(
                        'var t = document.getElementsByClassName(\'hint-block\')[0].innerText; t == \'Підтверджено\' || t == \'Подтверждён\';') ==
                    'true',
              ),
              phone: await controller!.runJavascriptReturningResult(
                'document.getElementById(\'accountform-phonenumber\').value',
              ),
              meta: await _getMetadata(),
            ),
          );
        }
        break;
    }

    if (!_hasInternet) return;

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

    var scheduleGridRegex = RegExp('schedule\/journal');
    print(url);
    if (scheduleGridRegex.hasMatch(url)) {
      _changeSiteState(
        DiaryGridState(
          content: DiaryMarkGrid.fromJson(
            json.decode(
              await _executeScript('getDiaryGrid.js'),
            ),
          ),
          meta: await _getMetadata(),
        ),
      );
    }

    var scheduleRegex = RegExp('school.*\/schedule');
    if (scheduleRegex.hasMatch(url)) {
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
  }

  String formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<StudentPerfomanceResponce?> getPerfomance({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    var json = await _makeAPIRequest('/v1/schedule/student-performance', """{
      "start_date": "${formatDate(fromDate)}", 	
      "end_date": "${formatDate(toDate)}",
      "student_id": ${Prefs.getInt('studentID')}
    }""", bearer: Prefs.getString('apiToken'));

    if(json != null) return StudentPerfomanceResponce.fromJson(json!);

    return null;
  }

  Future<String> _executeScript(String script) async {
    var str = await DefaultAssetBundle.of(_context)
        .loadString('Assets/scripts/$script');
    var i = (await controller!.runJavascriptReturningResult(str));
    return i.toString();
  }

  void nextDiaryPage() {
    _executeScript('diaryNext.js');
  }

  void previusDiaryPage() {
    _executeScript('diaryPrev.js');
  }

  void currentDiaryPage() {
    _executeScript('diaryCurrent.js');
  }

  Future<dynamic> _makeAPIRequest(String path, String body, {String? bearer}) async {
    var dio = Dio();
    dio.options.contentType = "application/json";

    if(bearer != null) dio.options.headers['Authorization'] = 'Bearer $bearer';

    try {
      var s = await dio.post(
        'http://api-mobile.nz.ua$path',
        data: body,
      );
      return s.data;
    } catch (e) {
      print(e);
    }
  }

  Future<bool> login(String name, String password) async {
    await setValue(Id('loginform-login'), name);
    await setValue(Id('loginform-password'), password);
    await clickButton(ClassName('ms-button form-submit-btn'));

    await Prefs.setString('username', name);
    await Prefs.setString('password', password);

    var json = await _makeAPIRequest('/v1/user/login', """{
        "username": "$name",
        "password": "$password"
      }""");

    if(json == null) return false;

    var response = ApiLoginResponse.fromJson(json);
    token = response.access_token;
    await Prefs.setString('apiToken', token);
    await Prefs.setInt('studentID', response.student_id);

    return true;
  }

  Future sendRecoverCode(String email) async {
    await setValue(Id('sendemailform-email'), email);
    await clickButton(ClassName('btn-primary'));
  }

  void forgotPassword() {
    controller!.loadUrl('$baseUrl/account/forgot-password');
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
    await controller!.runJavascript(
      "${_getObjectCall(identifier)}.value = $value",
    );
  }

  Future<void> goto(String path) async {
    await controller!.loadUrl(NzApi.baseUrl + path);
  }

  Future<void> setValue(ElementIdentifier identifier, String value,
      {String valueName = "value", bool valueIsString = true}) async {
    var c = valueIsString ? "\"" : '';
    var js = "${_getObjectCall(identifier)}.$valueName = $c$value$c";
    await controller!.runJavascript(js);
  }

  Future<void> clickButton(ElementIdentifier identifier) async {
    await controller!.runJavascript("${_getObjectCall(identifier)}.click()");
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
