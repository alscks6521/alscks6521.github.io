import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:github_portfolio/features/project/domain/entities/project.dart';
import 'package:github_portfolio/features/project/presentation/theme/project_style.dart';
import 'package:github_portfolio/features/project/presentation/widgets/project_card.dart';
import 'package:github_portfolio/features/project/presentation/widgets/project_detail.dart';
import 'package:github_portfolio/features/project/presentation/widgets/project_heroes.dart';

/// 프로젝트를 한눈에 보여주는 그리드. 비어 있는 칸은 빈 그리드로 채운다.
class ProjectScreen extends StatefulWidget {
  final String title;
  final String description;
  final List<ProjectItem> items;
  final int minSlots;
  final String? open; // 들어오자마자 상세를 펼칠 프로젝트 slug
  const ProjectScreen(
      {super.key,
      required this.title,
      required this.description,
      this.items = const [],
      this.minSlots = 6,
      this.open});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final _cardKeys = <String, GlobalKey>{};

  GlobalKey _keyOf(ProjectItem item) =>
      _cardKeys.putIfAbsent(item.slug, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    final item = widget.items.where((it) => it.slug == widget.open).firstOrNull;
    if (item == null) return;
    // 페이지 전환이 끝난 뒤, 해당 카드 자리에서 상세를 펼친다.
    Future.delayed(const Duration(milliseconds: 650), () {
      final ctx = _cardKeys[item.slug]?.currentContext;
      if (ctx != null && ctx.mounted) openProjectDetail(ctx, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title,
        description = widget.description,
        items = widget.items;
    final minSlots = widget.minSlots;
    for (final it in items) {
      precacheImage(projectIconImage(it.icon), context);
    }
    final slots = items.length > minSlots ? items.length : minSlots;
    return Scaffold(
      backgroundColor: ProjectColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: CustomScrollView(slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                sliver: SliverToBoxAdapter(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () => context.go('/home'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Text('← 홈으로',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: ProjectColors.accent)),
                        ),
                        const SizedBox(height: 20),
                        Text(title,
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: ProjectColors.text)),
                        const SizedBox(height: 8),
                        Text(description,
                            style: const TextStyle(
                                fontSize: 16,
                                height: 1.7,
                                color: ProjectColors.muted)),
                      ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                sliver: SliverLayoutBuilder(builder: (context, box) {
                  final w = box.crossAxisExtent;
                  final cols = w < 520 ? 1 : (w < 820 ? 2 : 3);
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      // 비율 대신 카드 내용 높이로 고정해 어떤 폭·글자 배율에서도 넘치지 않게 한다.
                      mainAxisExtent:
                          ProjectCard.extent(MediaQuery.textScalerOf(context)),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => i < items.length
                          ? ProjectCard(
                              key: _keyOf(items[i]),
                              item: items[i],
                              index: i + 1)
                          : const EmptyProjectCard(),
                      childCount: slots,
                    ),
                  );
                }),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
