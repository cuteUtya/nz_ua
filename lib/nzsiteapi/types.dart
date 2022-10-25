import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nz_ua/nzsiteapi/nz_db.dart';

part 'types.g.dart';

abstract class ElementIdentifier {
  String getValue();
}

class Id implements ElementIdentifier {
  Id(this.value);
  final String value;

  @override
  String getValue() {
    return value;
  }
}

class ClassName implements ElementIdentifier {
  ClassName(this.value);
  final String value;
  @override
  String getValue() {
    return value;
  }
}

abstract class NzState {}

@JsonSerializable()
class NeedLoginState implements NzState {
  const NeedLoginState({
    required this.alerts,
  });
  final List<PageAlert> alerts;

  factory NeedLoginState.fromJson(Map<String, dynamic> json) =>
      _$NeedLoginStateFromJson(json);
  Map<String, dynamic> toJson() => _$NeedLoginStateToJson(this);
}

@JsonSerializable()
class PageAlert {
  const PageAlert({
    required this.text,
    required this.type,
  });
  final AlertType type;
  final String text;

  factory PageAlert.fromJson(Map<String, dynamic> json) =>
      _$PageAlertFromJson(json);
  Map<String, dynamic> toJson() => _$PageAlertToJson(this);
}

enum AlertType {
  success,
  info,
  warning,
  danger,
}

class NeedEmailState implements NzState {}

/// /menu
class MainPageState implements NzState {}

class StateLogined implements NzState {}

/// /id{id}
class ProfilePageState implements NzState {
  ProfilePageState({
    required this.profile,
    required this.meta,
  });
  final UserProfile? profile;
  final SideMetadata? meta;
}

class ISQLObject<T> {
  ISQLObject({
    required this.schema,
  });

  Map<String, Type> schema;

  String get TEXT => "TEXT";
  String get DOUBLE => "DOUBLE";
  String get SQL_OBJECT => "SQL_OBJECT";
  String get INTEGER => "INTEGER";
  String get BOOLEAN => "BOOLEAN";
  String get DATETIME => "DATETIME";
  String get LIST => "LIST";

  get _fields => (_object as dynamic).toJson();
  get _object => this as T;
  get dbTableName => ISQLObject.getNameOfDB(type: (this as T).runtimeType);

  static String getNameOfDB<T>({Type? type}) {
    return type == null ? T.toString() : type.toString();
  }

  static String getNameOfChildDB(String defTableName) {
    return '${defTableName}_childdb';
  }

  Future deleteAllValues() async {
    nzdb.execute('DROP TABLE $dbTableName');
  }

  Future<int> saveAsChild(String childOf) async {
    var name = getNameOfChildDB(dbTableName);
    if (!await tableIsExists(name)) {
      createTable(schema, isChild: true, name: name);
    }

    await this.save(tableName: name);

    return await _getLastInsertRowID();
  }

  Future<int> _getLastInsertRowID() async {
    var i = (await nzdb.rawQuery('SELECT last_insert_rowid();'))[0];
    return int.parse(i['last_insert_rowid()'].toString());
  }

  static Future<Map<String, dynamic>?> getByIdTableName(
      int id, String tableName) async {
    var query = 'SELECT * FROM $tableName WHERE DB_ID == $id';
    var r = await nzdb.rawQuery(query);

    var obj = await _deserializeSQLObject(r[0]!);

    return obj;
  }

  static Future<Map<String, dynamic>?> getById<T>(int id,
      {bool isChild = false}) async {
    assert(id >= 1);
    var name = ISQLObject.getNameOfDB<T>();
    if (isChild) name = ISQLObject.getNameOfChildDB(name);

    return getByIdTableName(id, name);
  }

  static Future<Map<String, dynamic>?> _deserializeSQLObject<T>(
      Map<String, Object?> s) async {
    Map<String, dynamic> jsonMap = {};

    var objectRegex = RegExp(r'\$object_link\$=\((\d*)\:(.*)\)');
    var arrayRegex = RegExp(r'\$arr_link\$=\((.*),(\d*):(\d*)\)');
    var booleanRegex = RegExp(r'\$bool_value\$:(.*)');

    var mKey = s.keys.toList();
    var mValues = s.values.toList();

    for (var j = 0; j < s.length; j++) {
      var key = mKey[j];
      var value = mValues[j];

      var val;
      if (value is String) {
        if (objectRegex.hasMatch(value)) {
          var regResult = objectRegex.firstMatch(value)!;
          var i = int.parse(regResult.group(1)!);
          var n = regResult.group(2)!;
          val = await ISQLObject.getByIdTableName(i, n);
          //this is object
        } else if (arrayRegex.hasMatch(value)) {
          List<dynamic> arr = [];

          var regResult = arrayRegex.firstMatch(value)!;
          var n = regResult.group(1)!;

          if (n != "__empty__") {
            var from = int.parse(regResult.group(2)!);
            var to = int.parse(regResult.group(3)!);

            for (var index = from; index <= to; index++) {
              arr.add(await ISQLObject.getByIdTableName(index, n));
            }
          }
          val = arr;
        } else if (booleanRegex.hasMatch(value)) {
          var l = booleanRegex.firstMatch(value)!.group(1)!;
          val = l == "true" || l == "True";
        }
      }

      val ??= value;

      jsonMap[key] = val;
    }

    return jsonMap;
  }

  Future<int> save({String? tableName}) async {
    var fields = _fields;

    if (!await tableIsExists(dbTableName)) {
      createTable(schema);
    }

    String getFields() {
      var s = '';
      schema.forEach((key, value) {
        s += "$key, ";
      });
      s = s.substring(0, s.length - 2);
      return s;
    }

    var query =
        'INSERT INTO ${tableName ?? dbTableName} (${getFields()})\nVALUES (';
    var kList = schema.keys.toList();
    var vList = schema.values.toList();
    for (var i = 0; i < schema.length; i++) {
      var key = kList[i];
      var value = vList[i];

      var t = getFieldType(value);
      var val = fields[key];
      if (val == null) {
        query += "NULL";
      } else {
        if (t != LIST && t != SQL_OBJECT && t != BOOLEAN) {
          if (t == TEXT) {
            query += "'${val.toString()}'";
          } else if (t == DATETIME) {
            query += "${(val as DateTime)}";
          } else {
            query += "$val";
          }
        } else {
          if (t == SQL_OBJECT) {
            ISQLObject sqlObject = val as ISQLObject;
            var tableN = getNameOfChildDB(sqlObject.dbTableName);
            var id = await sqlObject.saveAsChild(T.runtimeType.toString());
            query += "'\$object_link\$=($id:$tableN)'";
          } else if (t == LIST) {
            //check if arr.length == 0
            var from = 0;
            var valList = val as List;
            if (valList.isEmpty) {
              query += "'\$arr_link\$=(__empty__,0:0)'";
            } else {
              var tableN =
                  getNameOfChildDB((valList[0] as ISQLObject).dbTableName);
              for (var e in valList) {
                ISQLObject sq = e as ISQLObject;
                var id = await sq.saveAsChild(T.runtimeType.toString());
                if (valList.indexOf(e) == 0) {
                  from = id;
                }
              }
              query +=
                  "'\$arr_link\$=($tableN,$from:${from + valList.length - 1})'";
            }
          } else if (t == BOOLEAN) {
            query += "'\$bool_value\$:${val.toString()}'";
          }
        }
      }

      query += ", ";
    }

    query = query.substring(0, query.length - 2);

    query += ')';

    await nzdb.execute(query);

    return await _getLastInsertRowID();
  }

  String? getFieldType(Type type) {
    switch (type) {
      case String:
        return TEXT;
      case int:
        return INTEGER;
      case double:
        return DOUBLE;
      case bool:
        return BOOLEAN;
      case DateTime:
        return DATETIME;
      case List:
        return LIST;
    }

    return SQL_OBJECT;
    // if field have type of object (SQL_OBJECT or LIST) - we should create separate table for this type of object
    // and leave in current object only link to object in another table
  }

  Future createTable(Map<String, Type> object,
      {bool isChild = false, String? name}) async {
    var tableName = name ?? dbTableName;
    String fields = "";
    //if (isChild) {
    fields += "DB_ID INTEGER PRIMARY KEY,";
    //}
    object.forEach((key, t) {
      var type = getFieldType(t);
      if (type != LIST && type != SQL_OBJECT && type != BOOLEAN) {
        fields += ' $key $type NULL,\n';
      } else {
        //here be a link for object in another table
        fields += ' $key TEXT,\n';
      }
    });
    fields = fields.substring(0, fields.length - 2);

    var query = """CREATE TABLE IF NOT EXISTS $tableName(
$fields
    );""";
    nzdb.execute(query);
  }

  Future<bool> tableIsExists(String name) async {
    var r = await nzdb.rawQuery(
        """SELECT name FROM sqlite_master WHERE type='table' AND name='$name';""");

    return r.isNotEmpty;
  }
}

/// /dashboard/news
class NewsPageState implements NzState {
  NewsPageState({
    required this.tabs,
    required this.news,
    required this.meta,
  });
  final TabSet? tabs;
  final NewsArr? news;
  final SideMetadata? meta;
}

/// /school{id}/schedule/diary?student_id=
class DiaryPageState implements NzState {
  DiaryPageState({
    required this.content,
    required this.meta,
  });
  final DiaryContentTopToDown? content;
  final SideMetadata? meta;
}

class DiaryGridState implements NzState {
  DiaryGridState({
    required this.content,
    required this.meta,
  });
  final DiaryMarkGrid? content;
  final SideMetadata? meta;
}

/// /schedule/grades-statement?student_id={id}
@JsonSerializable()
class DiaryMarkGrid {
  DiaryMarkGrid({
    required this.interval,
    required this.lines,
  });
  final DateTimeInterval? interval;
  final List<DiaryMarkGridLine>? lines;

  factory DiaryMarkGrid.fromJson(Map<String, dynamic> json) =>
      _$DiaryMarkGridFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryMarkGridToJson(this);
}

@JsonSerializable()
class DiaryMarkGridLine {
  DiaryMarkGridLine({
    required this.index,
    required this.lessonName,
    required this.marks,
  });
  final int? index;
  final String? lessonName;
  final List<String>? marks;

  factory DiaryMarkGridLine.fromJson(Map<String, dynamic> json) =>
      _$DiaryMarkGridLineFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryMarkGridLineToJson(this);
}

class SchedulePageState implements NzState {
  SchedulePageState({
    required this.metadata,
    required this.content,
  });
  final SchedulePageContent content;
  final SideMetadata? metadata;
}

@JsonSerializable()
class SchedulePageContent {
  SchedulePageContent({
    required this.timings,
    required this.days,
  });
  final List<DateTimeInterval>? timings;
  final List<ScheduleDay>? days;

  factory SchedulePageContent.fromJson(Map<String, dynamic> json) =>
      _$SchedulePageContentFromJson(json);
  Map<String, dynamic> toJson() => _$SchedulePageContentToJson(this);
}

class SecurityPageState implements NzState {
  SecurityPageState({
    required this.login,
    required this.email,
    required this.phone,
    required this.meta,
  });
  final String? login;
  final EmailStatus? email;
  final String? phone;
  final SideMetadata? meta;
}

@JsonSerializable()
class EmailStatus extends ISQLObject {
  EmailStatus({
    required this.email,
    required this.confirmed,
  }) : super(schema: {
          'email': String,
          'confirmed': bool,
        });
  final String? email;
  final bool? confirmed;

  factory EmailStatus.fromJson(Map<String, dynamic> json) =>
      _$EmailStatusFromJson(json);
  Map<String, dynamic> toJson() => _$EmailStatusToJson(this);
}

@JsonSerializable()
class ScheduleDay extends ISQLObject {
  ScheduleDay({
    required this.today,
    required this.date,
    required this.lessons,
  }) : super(schema: {'today': bool, 'date': String, 'lessons': List});
  final bool? today;
  final String? date;
  final List<ScheduleLesson?>? lessons;

  factory ScheduleDay.fromJson(Map<String, dynamic> json) =>
      _$ScheduleDayFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleDayToJson(this);
}

@JsonSerializable()
class ScheduleLesson extends ISQLObject {
  ScheduleLesson({
    required this.name,
    required this.teacher,
    required this.classAudience,
  }) : super(schema: {
          'name': String,
          'teacher': UserProfileLink,
          'classAudience': String,
        });
  final String? name;
  final UserProfileLink? teacher;
  final String? classAudience;

  factory ScheduleLesson.fromJson(Map<String, dynamic> json) =>
      _$ScheduleLessonFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleLessonToJson(this);
}

abstract class DiaryContent {}

@JsonSerializable()
class DiaryContentTable implements DiaryContent {
  DiaryContentTable({
    required this.date,
    required this.table,
  });
  final DateTimeInterval? date;
  final DiaryTable? table;

  factory DiaryContentTable.fromJson(Map<String, dynamic> json) =>
      _$DiaryContentTableFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryContentTableToJson(this);
}

@JsonSerializable()
class DiaryTable {
  DiaryTable({
    required this.dateValues,
    required this.lessonsMarks,
  });
  final List<String>? dateValues;
  final List<DiaryTableLessonLine>? lessonsMarks;

  factory DiaryTable.fromJson(Map<String, dynamic> json) =>
      _$DiaryTableFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryTableToJson(this);
}

@JsonSerializable()
class DiaryTableLessonLine {
  DiaryTableLessonLine({
    required this.lessonName,
    required this.marks,
  });
  final String? lessonName;
  final List<List<Mark>?>? marks;

  factory DiaryTableLessonLine.fromJson(Map<String, dynamic> json) =>
      _$DiaryTableLessonLineFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryTableLessonLineToJson(this);
}

@JsonSerializable()
class Mark extends ISQLObject {
  Mark({
    required this.value,
    required this.lesson,
    this.theme,
  }) : super(schema: {
          'value': int,
          'theme': String,
          'lesson': String,
        });
  final int? value;
  /**theme? тематична/контрольна/поточна/... */
  final String? theme;
  final String? lesson;

  factory Mark.fromJson(Map<String, dynamic> json) => _$MarkFromJson(json);
  Map<String, dynamic> toJson() => _$MarkToJson(this);
}

@JsonSerializable()
class DiaryContentTopToDown {
  DiaryContentTopToDown({
    required this.content,
    required this.interval,
  });
  final DateTimeInterval? interval;
  final List<DiaryDayTopToDown>? content;

  factory DiaryContentTopToDown.fromJson(Map<String, dynamic> json) =>
      _$DiaryContentTopToDownFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryContentTopToDownToJson(this);
}

@JsonSerializable()
class DiaryDayTopToDown {
  DiaryDayTopToDown({
    required this.dayDate,
    required this.lines,
  });
  final String? dayDate;
  final List<DiaryLine>? lines;

  factory DiaryDayTopToDown.fromJson(Map<String, dynamic> json) =>
      _$DiaryDayTopToDownFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryDayTopToDownToJson(this);
}

@JsonSerializable()
class DiaryLine {
  DiaryLine({
    required this.index,
    required this.lessonTime,
    this.content,
  });
  final int? index;

  final DateTimeInterval lessonTime;

  /// it can be two or more lessons for one period
  final List<DiaryLineContent>? content;

  factory DiaryLine.fromJson(Map<String, dynamic> json) =>
      _$DiaryLineFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryLineToJson(this);
}

@JsonSerializable()
class DiaryLineContent {
  DiaryLineContent({
    required this.name,
    required this.topic,
    required this.classAudience,
    required this.homework,
    required this.workType,
    this.mark,
  });
  final String? name;
  final String? topic;
  final String? classAudience;
  final List<String>? homework;
  final String? mark;
  /**Поточна/лабараторна/контрольна - те, що і Mark.theme*/
  final String? workType;

  factory DiaryLineContent.fromJson(Map<String, dynamic> json) =>
      _$DiaryLineContentFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryLineContentToJson(this);
}

@JsonSerializable()
class SideMetadata extends ISQLObject {
  SideMetadata({
    required this.comingHomework,
    required this.latestMarks,
    required this.closestBirthdays,
    required this.me,
  }) : super(schema: {
          'comingHomework': List,
          'latestMarks': List,
          'closestBirthdays': List,
          'me': UserProfileLink,
        });
  final List<Homework>? comingHomework;
  final List<Mark>? latestMarks;
  final List<Birthday>? closestBirthdays;
  final UserProfileLink? me;

  factory SideMetadata.fromJson(Map<String, dynamic> json) =>
      _$SideMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$SideMetadataToJson(this);
}

@JsonSerializable()
class TabSet {
  TabSet({
    required this.tabs,
    required this.activeTab,
  });
  final List<Tab>? tabs;
  final String? activeTab;

  factory TabSet.fromJson(Map<String, dynamic> json) => _$TabSetFromJson(json);
  Map<String, dynamic> toJson() => _$TabSetToJson(this);
}

@JsonSerializable()
class Tab {
  Tab({
    required this.link,
    required this.name,
  });
  final String? link;
  final String? name;

  factory Tab.fromJson(Map<String, dynamic> json) => _$TabFromJson(json);
  Map<String, dynamic> toJson() => _$TabToJson(this);
}

@JsonSerializable()
class NewsArr {
  NewsArr({required this.news});
  final List<News>? news;

  factory NewsArr.fromJson(Map<String, dynamic> json) =>
      _$NewsArrFromJson(json);
  Map<String, dynamic> toJson() => _$NewsArrToJson(this);
}

@JsonSerializable()
class News {
  News({
    this.author,
    required this.newsTime,
    required this.news,
  });
  final NewsAuthor? author;
  final String? newsTime;
  final String? news;

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);
  Map<String, dynamic> toJson() => _$NewsToJson(this);
}

@JsonSerializable()
class NewsContent {
  NewsContent({
    required this.title,
    required this.textEntityes,
  });
  final String? title;
  final List<TextEntity>? textEntityes;

  factory NewsContent.fromJson(Map<String, dynamic> json) =>
      _$NewsContentFromJson(json);
  Map<String, dynamic> toJson() => _$NewsContentToJson(this);
}

@JsonSerializable()
class TextEntity {
  TextEntity({
    required this.text,
    required this.entityes,
  });
  final String? text;
  final List<TextEntityType>? entityes;

  factory TextEntity.fromJson(Map<String, dynamic> json) =>
      _$TextEntityFromJson(json);
  Map<String, dynamic> toJson() => _$TextEntityToJson(this);
}

@JsonSerializable()
class TextEntityType {
  TextEntityType({required this.type, this.hyperlink, this.imageUrl});
  final String? type;
  final String? imageUrl;
  final String? hyperlink;

  factory TextEntityType.fromJson(Map<String, dynamic> json) =>
      _$TextEntityTypeFromJson(json);
  Map<String, dynamic> toJson() => _$TextEntityTypeToJson(this);
}

@JsonSerializable()
class NewsAuthor {
  NewsAuthor({
    required this.fullName,
    required this.profilePhotoUrl,
    required this.profileUrl,
  });
  final String? fullName;
  final String? profilePhotoUrl;
  final String? profileUrl;

  factory NewsAuthor.fromJson(Map<String, dynamic> json) =>
      _$NewsAuthorFromJson(json);
  Map<String, dynamic> toJson() => _$NewsAuthorToJson(this);
}

@JsonSerializable()
class Semester {
  Semester({required this.id, required this.name});
  final String? name;
  final String? id;

  factory Semester.fromJson(Map<String, dynamic> json) =>
      _$SemesterFromJson(json);
  Map<String, dynamic> toJson() => _$SemesterToJson(this);
}

@JsonSerializable()
class Birthday extends ISQLObject {
  Birthday({
    required this.date,
    required this.user,
  }) : super(
          schema: {
            'user': UserProfileLink,
            'date': String,
          },
        );
  final UserProfileLink? user;
  final String? date;

  factory Birthday.fromJson(Map<String, dynamic> json) =>
      _$BirthdayFromJson(json);
  Map<String, dynamic> toJson() => _$BirthdayToJson(this);
}

@JsonSerializable()
class Homework extends ISQLObject {
  Homework({
    required this.exercises,
    required this.date,
  }) : super(schema: {'date': String, 'exercises': List});
  final String? date;
  final List<Exercise>? exercises;

  factory Homework.fromJson(Map<String, dynamic> json) =>
      _$HomeworkFromJson(json);
  Map<String, dynamic> toJson() => _$HomeworkToJson(this);
}

@JsonSerializable()
class Exercise extends ISQLObject {
  Exercise({
    required this.exercise,
    required this.lesson,
  }) : super(schema: {
          'lesson': String,
          'exercise': String,
        });
  final String? lesson;
  final String? exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}

@JsonSerializable()
class UserProfile {
  UserProfile({
    required this.isTeacher,
    required this.fullName,
    required this.subjects,
    required this.classes,
    required this.formMasterOf,
    required this.currentClass,
    required this.birthDate,
    required this.photoProfileUrl,
    required this.parents,
    required this.schoolName,
  });
  final bool? isTeacher;
  final String? fullName;
  final List<String>? classes;
  final String? formMasterOf;
  final List<String>? subjects;
  final String? schoolName;
  final String? currentClass;
  final String? birthDate;
  final String? photoProfileUrl;
  final List<String>? parents;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

@JsonSerializable()
class UserProfileLink extends ISQLObject {
  UserProfileLink({
    required this.fullName,
    required this.profileUrl,
  }) : super(
          schema: {
            'fullName': String,
            'profileUrl': String,
          },
        );
  final String? fullName;
  final String? profileUrl;

  factory UserProfileLink.fromJson(Map<String, dynamic> json) =>
      _$UserProfileLinkFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileLinkToJson(this);
}

@JsonSerializable()
class DateTimeInterval {
  DateTimeInterval({required this.from, required this.to});
  final String? from;
  final String? to;

  factory DateTimeInterval.fromJson(Map<String, dynamic> json) =>
      _$DateTimeIntervalFromJson(json);
  Map<String, dynamic> toJson() => _$DateTimeIntervalToJson(this);
}

@JsonSerializable()
class Parent {
  Parent({
    required this.fullName,
    required this.role,
  });
  final String? fullName;
  final ParentRole? role;

  factory Parent.fromJson(Map<String, dynamic> json) => _$ParentFromJson(json);
  Map<String, dynamic> toJson() => _$ParentToJson(this);
}

@JsonSerializable()
class ApiLoginResponse {
  ApiLoginResponse({
    required this.access_token,
    required this.refresh_token,
    required this.email_hash,
    required this.student_id,
    required this.avatar,
    required this.error_message,
    required this.FIO,
    required this.permissions,
  });
  final String? access_token;
  final String? refresh_token;
  final String? email_hash;
  final int? student_id;
  final String? FIO;
  final AvatarResponse? avatar;
  final PermissionsResponse? permissions;
  final String? error_message;

  factory ApiLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiLoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiLoginResponseToJson(this);
}

@JsonSerializable()
class PermissionsResponse {
  PermissionsResponse({required this.isuo_nzportal_children});
  final List<String> isuo_nzportal_children;

  factory PermissionsResponse.fromJson(Map<String, dynamic> json) =>
      _$PermissionsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionsResponseToJson(this);
}

@JsonSerializable()
class AvatarResponse {
  AvatarResponse({required this.image_url, required this.datetime});
  final String? image_url;
  final String? datetime;

  factory AvatarResponse.fromJson(Map<String, dynamic> json) =>
      _$AvatarResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AvatarResponseToJson(this);
}

@JsonSerializable()
class ApiUserGetResponse {
  final int? id;
  final String? first_name;
  final String? last_name;
  final String? email_address;
  final String? username;
  final String? algorithm;
  final String? salt;
  final String? password;
  final int? is_active;
  final int? is_super_admin;
  final String? last_login;
  final String? created_at;
  final String? updated_at;
  final String? patronymic;
  final String? updated_by;
  final String? created_by;
  final int? is_blocked;
  final String? tmp_email;
  final String? created_on;

  ApiUserGetResponse(
      {this.id,
      this.first_name,
      this.last_name,
      this.email_address,
      this.username,
      this.algorithm,
      this.salt,
      this.password,
      this.is_active,
      this.is_super_admin,
      this.last_login,
      this.created_at,
      this.updated_at,
      this.patronymic,
      this.updated_by,
      this.created_by,
      this.is_blocked,
      this.tmp_email,
      this.created_on});

  factory ApiUserGetResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiUserGetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiUserGetResponseToJson(this);
}

enum ParentRole {
  mother,
  father,
}
