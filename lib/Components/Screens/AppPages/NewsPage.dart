import 'package:adobe_spectrum/Components/action_group.dart';
import 'package:design_system_provider/desing_components.dart';
import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:nz_ua/Components/database.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:nz_ua/nzsiteapi/types.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key, required this.api}) : super(key: key);
  final NzApi api;
  @override
  State<StatefulWidget> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);
    return StreamBuilder(
      stream: widget.api.newsStream,
      builder: (_, data) {
        var news = data.data;

        if (news == null) {
          var tabsJSON = Database.get('newsTabs');
          var tabs = tabsJSON != null ? TabSet.fromJson(tabsJSON) : null;
          //lol bruh rewrite state managment
          var newsJSON = Database.get('news#${tabs?.tabs?[1].name}');
          var n = newsJSON != null ? NewsArr.fromJson(newsJSON) : null;
          if (tabs != null && n != null) {
            news = NewsPageState(
              tabs: tabs,
              news: n,
              meta: null,
            );
          }
          widget.api.forceUpdateNews();
          if (news == null) return Container();
        }

        var currentIndex = 0;

        for (var i = 0; i < news!.tabs!.tabs!.length; i++) {
          if (news!.tabs?.tabs?[i].active ?? false) currentIndex = i;
        }

        Database.save(news!.tabs!, 'newsTabs');
        Database.save(
            news!.news!, 'news#${news!.tabs!.tabs![currentIndex].name}');

        return Column(
          children: [
            Padding(
              padding: design.layout.spacing400.bottom,
              child: ActionGroup(
                key: UniqueKey(),
                enableSelection: true,
                size: ButtonSize.small,
                items: [
                  if (news?.tabs?.tabs != null)
                    for (var i in news!.tabs!.tabs!)
                      ActionItem(
                        label: i.name,
                      ),
                ],
                selectedItems: [currentIndex],
                onChange: (items) {
                  var item = items[0];
                  for (var i in news!.tabs!.tabs!) {
                    if (i.name == item.label) {
                      widget.api.forceUpdateNews(url: i.link);
                    }
                  }
                },
              ),
            ),
            for (var news in news.news!.news!)
              Column(
                children: [
                  if (news.author == null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text.rich(
                          design.typography.text(
                            news.newsTime ?? '',
                            size: design.typography.fontSize75.value,
                          ),
                        ),
                      ],
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: design.colors.gray.shade200,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      border: Border.all(
                        color: design.colors.gray.shade300,
                      ),
                    ),
                    margin: design.layout.spacing300.bottom,
                    child: Padding(
                      padding: design.layout.spacing100.all,
                      child: Column(
                        children: [
                          if (news.author != null)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: design.layout.spacing100.right,
                                  child: SizedBox(
                                    height: design
                                        .layout.spacing600.right.horizontal,
                                    width: design
                                        .layout.spacing600.right.horizontal,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.network(
                                        (news.author?.profilePhotoUrl ??
                                                'https://nz.ua/images/no_avatar/man.jpg')
                                            .replaceAll('20x20', '170x170'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      design.typography.text(
                                          news.author?.fullName ?? '',
                                          size: design
                                              .typography.fontSize100.value,
                                          semantic: TextSemantic.heading),
                                    ),
                                    Text.rich(
                                      design.typography.text(
                                        news.newsTime ?? '',
                                        size:
                                            design.typography.fontSize100.value,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          Padding(
                            padding: design.layout.spacing200.top,
                            child: Text.rich(
                              design.typography.text(
                                news.news ?? '',
                                size: design.typography.fontSize100.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
