import 'package:github_portfolio/core/constants/app_assets.dart';
import 'package:github_portfolio/features/home/domain/entities/featured_project.dart';
import 'package:github_portfolio/features/home/domain/entities/skill_group.dart';
import 'package:github_portfolio/features/project/domain/entities/project.dart';

/// 홈 화면에 들어가는 정적 콘텐츠. 문구를 고칠 땐 이 파일만 보면 된다.
class HomeLocalDataSource {
  const HomeLocalDataSource();

  List<FeaturedProject> get featuredProjects => const [
        FeaturedProject(
          ' 치료 관리 모바일 애플리케이션',
          'ISay App',
          ' 치료가 필요한 아동과 보호자, 그리고 치료사를 연결하여 치료 일정 관리와 상담을 지원하는 모바일 애플리케이션입니다.',
          'Flutter 기반 모바일 앱 개발 전체 담당',
          AppAssets.isayIcon,
          '앱 프로젝트 보러가기',
          ProjectScope.app,
          'isay-app',
          [
            'Flutter',
            'Riverpod',
            'AWS Bedrock',
            'RAG',
            'LLM',
            'WebSocket',
            'Firebase Cloud Messaging'
          ],
          screens: AppAssets.isayScreens,
          imageRadius: 16,
          released: true,
        ),
        FeaturedProject(
          ' 치료 관리 웹 플랫폼',
          'ISay Web',
          ' 치료 서비스 이용자와 치료사를 위한 관리 플랫폼으로, 치료 일정 관리, 상담, 사용자 관리 기능을 제공하는 웹 서비스입니다.',
          'Flutter Web 개발 전체 담당',
          AppAssets.isayWebIcon,
          '웹 프로젝트 보러가기',
          ProjectScope.web,
          'isay-web',
          [
            'Flutter Web',
            'WebSocket',
            'Firebase Cloud Messaging',
            'PortOne 구독 결제',
            '역할 기반 권한'
          ],
          screens: AppAssets.isayWebScreens,
          imageRadius: 16,
          screenCols: 2,
        ),
      ];

  List<SkillGroup> get skills => const [
        SkillGroup('Framework', 'Flutter · Flutter Web · Riverpod'),
        SkillGroup('AI',
            'AWS Bedrock (Serverless) · RAG · Text Embedding · Vector Search · LLM Intent Classification'),
        SkillGroup('Realtime', 'WebSocket 채팅 · Firebase Cloud Messaging'),
        SkillGroup('Backend', 'REST API 설계·개발 · 역할 기반 권한'),
        SkillGroup('Payment', 'PortOne 구독 결제'),
        SkillGroup('Release', 'App Store · Google Play 출시'),
      ];
}
