// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiaryMarkGridLine _$DiaryMarkGridLineFromJson(Map<String, dynamic> json) =>
    DiaryMarkGridLine(
      index: json['index'] as int,
      lessonName: json['lessonName'] as String,
      marks: (json['marks'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DiaryMarkGridLineToJson(DiaryMarkGridLine instance) =>
    <String, dynamic>{
      'index': instance.index,
      'lessonName': instance.lessonName,
      'marks': instance.marks,
    };

EmailStatus _$EmailStatusFromJson(Map<String, dynamic> json) => EmailStatus(
      email: json['email'] as String,
      confirmed: json['confirmed'] as bool,
    );

Map<String, dynamic> _$EmailStatusToJson(EmailStatus instance) =>
    <String, dynamic>{
      'email': instance.email,
      'confirmed': instance.confirmed,
    };

ScheduleDay _$ScheduleDayFromJson(Map<String, dynamic> json) => ScheduleDay(
      today: json['today'] as bool,
      date: json['date'] as String,
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => ScheduleLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScheduleDayToJson(ScheduleDay instance) =>
    <String, dynamic>{
      'today': instance.today,
      'date': instance.date,
      'lessons': instance.lessons,
    };

ScheduleLesson _$ScheduleLessonFromJson(Map<String, dynamic> json) =>
    ScheduleLesson(
      name: json['name'] as String,
      teacher:
          UserProfileLink.fromJson(json['teacher'] as Map<String, dynamic>),
      classAudience: json['classAudience'] as String,
    );

Map<String, dynamic> _$ScheduleLessonToJson(ScheduleLesson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'teacher': instance.teacher,
      'classAudience': instance.classAudience,
    };

DiaryContentTable _$DiaryContentTableFromJson(Map<String, dynamic> json) =>
    DiaryContentTable(
      date: DateTimeInterval.fromJson(json['date'] as Map<String, dynamic>),
      table: DiaryTable.fromJson(json['table'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DiaryContentTableToJson(DiaryContentTable instance) =>
    <String, dynamic>{
      'date': instance.date,
      'table': instance.table,
    };

DiaryTable _$DiaryTableFromJson(Map<String, dynamic> json) => DiaryTable(
      dateValues: (json['dateValues'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lessonsMarks: (json['lessonsMarks'] as List<dynamic>)
          .map((e) => DiaryTableLessonLine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DiaryTableToJson(DiaryTable instance) =>
    <String, dynamic>{
      'dateValues': instance.dateValues,
      'lessonsMarks': instance.lessonsMarks,
    };

DiaryTableLessonLine _$DiaryTableLessonLineFromJson(
        Map<String, dynamic> json) =>
    DiaryTableLessonLine(
      lessonName: json['lessonName'] as String,
      marks: (json['marks'] as List<dynamic>)
          .map((e) => (e as List<dynamic>?)
              ?.map((e) => Mark.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
    );

Map<String, dynamic> _$DiaryTableLessonLineToJson(
        DiaryTableLessonLine instance) =>
    <String, dynamic>{
      'lessonName': instance.lessonName,
      'marks': instance.marks,
    };

Mark _$MarkFromJson(Map<String, dynamic> json) => Mark(
      value: json['value'] as int,
      lesson: json['lesson'] as String,
      theme: json['theme'] as String?,
    );

Map<String, dynamic> _$MarkToJson(Mark instance) => <String, dynamic>{
      'value': instance.value,
      'theme': instance.theme,
      'lesson': instance.lesson,
    };

DiaryContentTopToDown _$DiaryContentTopToDownFromJson(
        Map<String, dynamic> json) =>
    DiaryContentTopToDown(
      content: (json['content'] as List<dynamic>)
          .map((e) => DiaryDayTopToDown.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DiaryContentTopToDownToJson(
        DiaryContentTopToDown instance) =>
    <String, dynamic>{
      'content': instance.content,
    };

DiaryDayTopToDown _$DiaryDayTopToDownFromJson(Map<String, dynamic> json) =>
    DiaryDayTopToDown(
      dayDate: json['dayDate'] as String,
      lines: (json['lines'] as List<dynamic>)
          .map((e) => DiaryLine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DiaryDayTopToDownToJson(DiaryDayTopToDown instance) =>
    <String, dynamic>{
      'dayDate': instance.dayDate,
      'lines': instance.lines,
    };

DiaryLine _$DiaryLineFromJson(Map<String, dynamic> json) => DiaryLine(
      index: json['index'] as int,
      lessonTime:
          DateTimeInterval.fromJson(json['lessonTime'] as Map<String, dynamic>),
      content: json['content'] == null
          ? null
          : DiaryLineContent.fromJson(json['content'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DiaryLineToJson(DiaryLine instance) => <String, dynamic>{
      'index': instance.index,
      'lessonTime': instance.lessonTime,
      'content': instance.content,
    };

DiaryLineContent _$DiaryLineContentFromJson(Map<String, dynamic> json) =>
    DiaryLineContent(
      name: json['name'] as int,
      topic: json['topic'] as String,
      classAudience: json['classAudience'] as String,
      homework:
          (json['homework'] as List<dynamic>).map((e) => e as String).toList(),
      workType: json['workType'] as String,
      mark: json['mark'] as String?,
    );

Map<String, dynamic> _$DiaryLineContentToJson(DiaryLineContent instance) =>
    <String, dynamic>{
      'name': instance.name,
      'topic': instance.topic,
      'classAudience': instance.classAudience,
      'homework': instance.homework,
      'mark': instance.mark,
      'workType': instance.workType,
    };

SideMetadata _$SideMetadataFromJson(Map<String, dynamic> json) => SideMetadata(
      comingHomework: (json['comingHomework'] as List<dynamic>)
          .map((e) => Homework.fromJson(e as Map<String, dynamic>))
          .toList(),
      latestMarks: (json['latestMarks'] as List<dynamic>)
          .map((e) => Mark.fromJson(e as Map<String, dynamic>))
          .toList(),
      closestBirthdays: (json['closestBirthdays'] as List<dynamic>)
          .map((e) => Birthday.fromJson(e as Map<String, dynamic>))
          .toList(),
      me: UserProfileLink.fromJson(json['me'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SideMetadataToJson(SideMetadata instance) =>
    <String, dynamic>{
      'comingHomework': instance.comingHomework,
      'latestMarks': instance.latestMarks,
      'closestBirthdays': instance.closestBirthdays,
      'me': instance.me,
    };

TabSet _$TabSetFromJson(Map<String, dynamic> json) => TabSet(
      tabs: (json['tabs'] as List<dynamic>)
          .map((e) => Tab.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeTab: json['activeTab'] as String,
    );

Map<String, dynamic> _$TabSetToJson(TabSet instance) => <String, dynamic>{
      'tabs': instance.tabs,
      'activeTab': instance.activeTab,
    };

Tab _$TabFromJson(Map<String, dynamic> json) => Tab(
      link: json['link'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$TabToJson(Tab instance) => <String, dynamic>{
      'link': instance.link,
      'name': instance.name,
    };

NewsArr _$NewsArrFromJson(Map<String, dynamic> json) => NewsArr(
      news: (json['news'] as List<dynamic>)
          .map((e) => News.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NewsArrToJson(NewsArr instance) => <String, dynamic>{
      'news': instance.news,
    };

News _$NewsFromJson(Map<String, dynamic> json) => News(
      author: json['author'] == null
          ? null
          : NewsAuthor.fromJson(json['author'] as Map<String, dynamic>),
      newsTime: json['newsTime'] as String,
      news: json['news'] as String,
    );

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
      'author': instance.author,
      'newsTime': instance.newsTime,
      'news': instance.news,
    };

NewsContent _$NewsContentFromJson(Map<String, dynamic> json) => NewsContent(
      title: json['title'] as String,
      textEntityes: (json['textEntityes'] as List<dynamic>)
          .map((e) => TextEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NewsContentToJson(NewsContent instance) =>
    <String, dynamic>{
      'title': instance.title,
      'textEntityes': instance.textEntityes,
    };

TextEntity _$TextEntityFromJson(Map<String, dynamic> json) => TextEntity(
      text: json['text'] as String,
      entityes: (json['entityes'] as List<dynamic>)
          .map((e) => TextEntityType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TextEntityToJson(TextEntity instance) =>
    <String, dynamic>{
      'text': instance.text,
      'entityes': instance.entityes,
    };

TextEntityType _$TextEntityTypeFromJson(Map<String, dynamic> json) =>
    TextEntityType(
      type: json['type'] as String,
      hyperlink: json['hyperlink'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$TextEntityTypeToJson(TextEntityType instance) =>
    <String, dynamic>{
      'type': instance.type,
      'imageUrl': instance.imageUrl,
      'hyperlink': instance.hyperlink,
    };

NewsAuthor _$NewsAuthorFromJson(Map<String, dynamic> json) => NewsAuthor(
      fullName: json['fullName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String,
      profileUrl: json['profileUrl'] as String,
    );

Map<String, dynamic> _$NewsAuthorToJson(NewsAuthor instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'profileUrl': instance.profileUrl,
    };

Semester _$SemesterFromJson(Map<String, dynamic> json) => Semester(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$SemesterToJson(Semester instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
    };

Birthday _$BirthdayFromJson(Map<String, dynamic> json) => Birthday(
      date: json['date'] as String,
      user: UserProfileLink.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BirthdayToJson(Birthday instance) => <String, dynamic>{
      'user': instance.user,
      'date': instance.date,
    };

Homework _$HomeworkFromJson(Map<String, dynamic> json) => Homework(
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      date: json['date'] as String,
    );

Map<String, dynamic> _$HomeworkToJson(Homework instance) => <String, dynamic>{
      'date': instance.date,
      'exercises': instance.exercises,
    };

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      exercise: json['exercise'] as String,
      lesson: json['lesson'] as String,
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'lesson': instance.lesson,
      'exercise': instance.exercise,
    };

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      fullName: json['fullName'] as String,
      birthDate: json['birthDate'] as String,
      photoProfileUrl: json['photoProfileUrl'] as String,
      parents:
          (json['parents'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'birthDate': instance.birthDate,
      'photoProfileUrl': instance.photoProfileUrl,
      'parents': instance.parents,
    };

UserProfileLink _$UserProfileLinkFromJson(Map<String, dynamic> json) =>
    UserProfileLink(
      fullName: json['fullName'] as String,
      profileUrl: json['profileUrl'] as String,
    );

Map<String, dynamic> _$UserProfileLinkToJson(UserProfileLink instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'profileUrl': instance.profileUrl,
    };

DateTimeInterval _$DateTimeIntervalFromJson(Map<String, dynamic> json) =>
    DateTimeInterval(
      from: json['from'] as String,
      to: json['to'] as String,
    );

Map<String, dynamic> _$DateTimeIntervalToJson(DateTimeInterval instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
    };

Parent _$ParentFromJson(Map<String, dynamic> json) => Parent(
      fullName: json['fullName'] as String,
      role: $enumDecode(_$ParentRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$ParentToJson(Parent instance) => <String, dynamic>{
      'fullName': instance.fullName,
      'role': _$ParentRoleEnumMap[instance.role]!,
    };

const _$ParentRoleEnumMap = {
  ParentRole.mother: 'mother',
  ParentRole.father: 'father',
};
