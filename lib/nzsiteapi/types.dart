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
    required this.me,
    required this.meta,
  });
  final UserProfile me;
  final SideMetadata meta;
}

/// /dashboard/news
class NewsPageState implements NzState {
  NewsPageState({
    required this.tabs,
    required this.news,
    required this.meta,
  });
  final TabSet tabs;
  final News news;
  final SideMetadata meta;
}

/// /school{id}/schedule/diary
class DiaryPageState implements NzState {
  DiaryPageState({
    required this.content,
    required this.meta,
  });
  final DiaryContent content;
  final SideMetadata meta;
}

/// /schedule/grades-statement?student_id={id}
class DiaryMarkGrid extends NzState {
  DiaryMarkGrid({
    required this.interval,
    required this.lines,
  });
  final DateTimeInterval interval;
  final List<DiaryMarkGridLine> lines;
}

class DiaryMarkGridLine {
  DiaryMarkGridLine({
    required this.index,
    required this.lessonName,
    required this.marks,
  });
  final int index;
  final String lessonName;
  final List<String> marks;
}

class SchedulePageState implements NzState {
  SchedulePageState({
    required this.timings,
    required this.days,
  });
  final List<DateTimeInterval> timings;
  final List<ScheduleDay>? days;
}

class SecurityPageState implements NzState {
  SecurityPageState({
    required this.login,
    required this.email,
    required this.phone,
  });
  final String login;
  final EmailStatus email;
  final String? phone;
}

class EmailStatus {
  EmailStatus({
    required this.email,
    required this.confirmed,
  });
  final String email;
  final bool confirmed;
}

class ScheduleDay {
  ScheduleDay({
    required this.today,
    required this.date,
    required this.lessons,
  });
  final bool today;
  final String date;
  final List<ScheduleLesson> lessons;
}

class ScheduleLesson {
  ScheduleLesson({
    required this.name,
    required this.teacher,
    required this.classAudience,
  });
  final String name;
  final UserProfileLink teacher;
  final String classAudience;
}

abstract class DiaryContent {}

class DiaryContentTable implements DiaryContent {
  DiaryContentTable({
    required this.date,
    required this.table,
  });
  final DateTimeInterval date;
  final DiaryTable table;
}

class DiaryTable {
  DiaryTable({
    required this.dateValues,
    required this.lessonsMarks,
  });
  final List<String> dateValues;
  final List<DiaryTableLessonLine> lessonsMarks;
}

class DiaryTableLessonLine {
  DiaryTableLessonLine({
    required this.lessonName,
    required this.marks,
  });
  final String lessonName;
  final List<List<Mark>?> marks;
}

class Mark {
  Mark({
    required this.value,
    required this.theme,
  });
  final int value;
  /**theme? тематична/контрольна/поточна/... */
  final String theme;
}

class DiaryContentTopToDown implements DiaryContent {
  DiaryContentTopToDown({required this.content});
  final List<DiaryDayTopToDown> content;
}

class DiaryDayTopToDown {
  DiaryDayTopToDown({
    required this.dayDate,
    required this.lines,
  });
  final String dayDate;
  final List<DiaryLine> lines;
}

class DiaryLine {
  DiaryLine({
    required this.index,
    required this.lessonTime,
    this.content,
  });
  final int index;

  final DateTimeInterval lessonTime;
  final DiaryLineContent? content;
}

class DiaryLineContent {
  DiaryLineContent({
    required this.name,
    required this.topic,
    required this.classAudience,
    required this.homework,
    required this.workType,
    this.mark,
  });
  final int name;
  final String topic;
  final String classAudience;
  final List<String> homework;
  final String? mark;
  /**Поточна/лабараторна/контрольна - те, що і Mark.theme*/
  final String workType;
}

class SideMetadata {
  SideMetadata({
    required this.comingHomework,
    required this.latestMarks,
    required this.closestBirthdays,
    required this.me,
  });
  final List<Homework> comingHomework;
  final List<Mark> latestMarks;
  final List<Birthdays> closestBirthdays;
  final UserProfileLink me;
}

class TabSet {
  TabSet({
    required this.tabs,
    required this.activeTab,
  });
  final List<Tab> tabs;
  final int activeTab;
}

class Tab {
  Tab({
    required this.link,
    required this.name,
  });
  final String link;
  final String name;
}

abstract class News {}

class MyNews implements News {
  MyNews({
    required this.author,
    required this.newsTime,
    required this.news,
  });
  final NewsAuthor author;
  final String newsTime;
  final String news;
}

class ProjectNews implements News {
  ProjectNews({
    required this.newsTime,
    required this.content,
  });
  final String newsTime;
  final NewsContent content;
}

class NewsContent {
  NewsContent({
    required this.title,
    required this.textEntityes,
  });
  final String title;
  final List<TextEntity> textEntityes;
}

class TextEntity {
  TextEntity({
    required this.text,
    required this.entityes,
  });
  final String text;
  final List<TextEntityType> entityes;
}

abstract class TextEntityType {}

class TextEntityBold implements TextEntityType {}

class TextEntityHyperink implements TextEntityType {}

class TextEntityImage implements TextEntityType {
  TextEntityImage({
    required this.imageUrl,
  });
  final String imageUrl;
}

class NewsAuthor {
  NewsAuthor({
    required this.fullName,
    required this.profilePhotoUrl,
    required this.profileUrl,
  });
  final String fullName;
  final String profilePhotoUrl;
  final String profileUrl;
}

class Semester {
  Semester({required this.id, required this.name});
  final String name;
  final String id;
}

class Birthdays {
  Birthdays({required this.date, required this.fullName});
  final String fullName;
  final String date;
}

class Homework {
  Homework({required this.exercise, required this.lesson, required this.date});
  final String date;
  final String lesson;
  final String exercise;
}

class UserProfile {
  UserProfile({
    required this.fullName,
    required this.birthDate,
    required this.photoProfileUrl,
    required this.parents,
  });
  final String fullName;
  final String birthDate;
  final String photoProfileUrl;
  final List<String> parents;
}

class UserProfileLink {
  UserProfileLink({
    required this.fullName,
    required this.profileUrl,
  });
  final String fullName;
  final String profileUrl;
}

class DateTimeInterval {
  DateTimeInterval({required this.from, required this.to});
  final String from;
  final String to;
}

class Parent {
  Parent({
    required this.fullName,
    required this.role,
  });
  final String fullName;
  final ParentRole role;
}

enum ParentRole {
  mother,
  father,
}
