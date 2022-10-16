import 'package:json_annotation/json_annotation.dart';

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

class NeedLoginState implements NzState {}

class NeedEmailState implements NzState {}

///
class NeedCodeState implements NzState {}

/// /menu
class MainPageState implements NzState {}

/// /id{id}
class ProfilePageState implements NzState {
  ProfilePageState({
    required this.profile,
    required this.meta,
  });
  final UserProfile? profile;
  final SideMetadata? meta;
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
class DiaryMarkGrid  {
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
    required this.timings,
    required this.days,
  });
  final List<DateTimeInterval>? timings;
  final List<ScheduleDay>? days;
}

class SecurityPageState implements NzState {
  SecurityPageState({
    required this.login,
    required this.email,
    required this.phone,
  });
  final String? login;
  final EmailStatus? email;
  final String? phone;
}

@JsonSerializable()
class EmailStatus {
  EmailStatus({
    required this.email,
    required this.confirmed,
  });
  final String? email;
  final bool? confirmed;

  factory EmailStatus.fromJson(Map<String, dynamic> json) =>
      _$EmailStatusFromJson(json);
  Map<String, dynamic> toJson() => _$EmailStatusToJson(this);
}

@JsonSerializable()
class ScheduleDay {
  ScheduleDay({
    required this.today,
    required this.date,
    required this.lessons,
  });
  final bool? today;
  final String? date;
  final List<ScheduleLesson>? lessons;

  factory ScheduleDay.fromJson(Map<String, dynamic> json) =>
      _$ScheduleDayFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleDayToJson(this);
}

@JsonSerializable()
class ScheduleLesson {
  ScheduleLesson({
    required this.name,
    required this.teacher,
    required this.classAudience,
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
class Mark {
  Mark({
    required this.value,
    required this.lesson,
    this.theme,
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
class SideMetadata {
  SideMetadata({
    required this.comingHomework,
    required this.latestMarks,
    required this.closestBirthdays,
    required this.me,
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
class Birthday {
  Birthday({required this.date, required this.user});
  final UserProfileLink? user;
  final String? date;

  factory Birthday.fromJson(Map<String, dynamic> json) =>
      _$BirthdayFromJson(json);
  Map<String, dynamic> toJson() => _$BirthdayToJson(this);
}

@JsonSerializable()
class Homework {
  Homework({required this.exercises, required this.date});
  final String? date;
  final List<Exercise>? exercises;

  factory Homework.fromJson(Map<String, dynamic> json) =>
      _$HomeworkFromJson(json);
  Map<String, dynamic> toJson() => _$HomeworkToJson(this);
}

@JsonSerializable()
class Exercise {
  Exercise({required this.exercise, required this.lesson});
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
class UserProfileLink {
  UserProfileLink({
    required this.fullName,
    required this.profileUrl,
  });
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
