/// 프로젝트 페이지 구분.
enum ProjectScope { app, web, all }

/// 그리드 한 칸에 들어가는 프로젝트 정보.
/// 상세 화면은 처음 보는 사람도 읽을 수 있도록 고정된 규격(섹션 순서)으로 보여준다.
/// 비어 있는 항목은 '작성 예정'으로 표시된다.
class ProjectItem {
  final String title, summary, description, icon;
  final List<String> skills, screens;
  final List<String> highlights; // 그리드 카드에 보여줄 핵심 기술 몇 개
  final bool released; // App Store · Google Play 출시 여부 (뱃지 표시)

  // 한눈에 보기
  final String category; // 구분 예) 전 직장 프로젝트, 개인 프로젝트
  final String period; // 개발 기간 예) 2024.03 ~ 2024.12
  final String team; // 참여 인원 예) 4명 (FE 1, BE 2, 디자인 1)
  final String role; // 담당 역할 예) Flutter 앱 개발 전체

  final List<String> features; // 주요 기능
  final List<String> contributions; // 내가 한 일 (구체적으로)
  final List<ProjectIssue> issues; // 기술적 문제와 해결
  final List<String> results; // 성과 / 배운 점

  const ProjectItem({
    required this.title,
    required this.summary,
    required this.description,
    required this.icon,
    this.skills = const [],
    this.screens = const [],
    this.highlights = const [],
    this.released = false,
    this.category = '',
    this.period = '',
    this.team = '',
    this.role = '',
    this.features = const [],
    this.contributions = const [],
    this.issues = const [],
    this.results = const [],
  });

  /// 주소용 식별자 예) ISay App → isay-app
  String get slug => title.toLowerCase().replaceAll(' ', '-');
}

/// 기술적 문제 → 해결 → 결과 한 묶음.
class ProjectIssue {
  final String problem, solution, result;
  const ProjectIssue(
      {required this.problem, required this.solution, this.result = ''});
}
