import 'package:github_portfolio/core/constants/app_assets.dart';
import 'package:github_portfolio/features/project/domain/entities/project.dart';

/// 앱·웹·전체 프로젝트 페이지가 함께 쓰는 프로젝트 데이터.
/// 프로젝트를 추가하거나 문구를 고칠 땐 이 파일만 보면 된다.
class ProjectLocalDataSource {
  const ProjectLocalDataSource();

  List<ProjectItem> get appProjects => const [_isayApp];
  List<ProjectItem> get webProjects => const [_isayWeb];
}

const _isayApp = ProjectItem(
  title: 'ISay App',
  summary: ' 치료 아동·보호자·치료사를 연결하는 모바일 앱',
  description:
      ' 치료가 필요한 아동과 보호자, 그리고 치료사를 연결하여 치료 일정 관리와 상담을 지원하는 모바일 애플리케이션입니다.',
  icon: AppAssets.isayIcon,
  category: '전 직장 프로젝트',
  period: '2024.07 ~ (약 1년)',
  team: '2명 (앱·서버 1 · 서버 1)',
  role: '앱 개발 · 서버 개발',
  features: [
    '실시간 예약 시스템 — 보호자와 치료 센터·치료사를 잇는 플랫폼에서 예약 가능 시간 조회, 예약 신청·확정·취소 상태를 실시간으로 반영',
    '자녀별 치료 이력 추적 — 보호자가 자녀 프로필을 여러 개 만들고 자녀를 선택해 센터에 예약 → 센터가 재원 등록 → 치료사가 회기마다 웹에서 치료 과정과 평가 점수를 기록 → 앱의 자녀 프로필에서 회기별 치료 내역과 점수 변화를 확인하는 앱·웹 연동 데이터 흐름',
    '치료사 1:1 실시간 채팅 — WebSocket 기반으로 다니는 센터의 치료사와 대화하고, 앱이 꺼져 있을 땐 FCM 푸시로 알림',
    'AI 상담 챗봇 — 사용자 질문을 텍스트 임베딩한 뒤 LLM으로 의도를 분류하고, 미리 구축해 둔 도메인 답변 데이터에서 의도에 맞는 답변을 제공',
    'RAG 기반 AI 치료 평가서 — 발달 지연 아동들의 치료 과정 데이터를 임베딩해 벡터 데이터로 구축하고, 평가서 요청 시 해당 자녀의 누적 치료 데이터를 임베딩해 유사 사례를 검색한 뒤 LLM이 앞으로 도움이 될 치료 방향과 예상 치료 기간(개월)을 예측해 평가서로 생성 (AWS Bedrock 서버리스)',
    '소셜 로그인 · 푸시 알림 — Google · Apple · Kakao 로그인, Firebase Cloud Messaging 기반 예약·채팅 알림',
  ],
  contributions: [
    '앱 클라이언트를 Flutter로 단독 설계·개발하고 App Store · Google Play에 출시',
    '서버 개발자와 함께 API를 설계·개발',
    'AI 상담 챗봇(임베딩 + LLM 의도 분류)과 RAG 치료 평가서 파이프라인을 직접 설계·구현',
  ],
  issues: [
    ProjectIssue(
      problem: 'LLM만으로 평가서를 만들면 아이의 실제 치료 이력과 무관한 일반적인 내용이 나올 수 있었습니다.',
      solution:
          '아동들의 치료 데이터를 임베딩해 두고, 요청한 자녀의 누적 데이터와 유사한 사례를 검색해 LLM에 근거로 함께 전달하는 RAG 구조를 AWS Bedrock 서버리스로 구성했습니다.',
      result:
          '자녀의 누적 데이터와 유사 사례에 근거해 치료 방향과 예상 기간을 제시하는 평가서를 만들 수 있게 되었고, 서버 관리 부담도 줄였습니다.',
    ),
  ],
  results: [
    '앱을 혼자 설계·개발해 App Store와 Google Play 출시까지 완주하고 서버 개발에도 참여하며, 클라이언트와 서버를 함께 보는 시야를 얻었습니다.',
    '임베딩과 RAG를 실제 서비스에 적용하며, LLM은 모델 자체보다 어떤 데이터를 근거로 주느냐가 응답 품질을 좌우한다는 것을 배웠습니다.',
  ],
  released: true,
  highlights: ['Flutter', 'Riverpod', 'AWS Bedrock', 'RAG', 'LLM'],
  skills: [
    'Flutter',
    'Dart',
    'Riverpod',
    // AI
    'AWS Bedrock (Serverless)',
    'RAG',
    'Text Embedding',
    'Vector Similarity Search',
    'LLM Intent Classification',
    // 실시간 · 연동
    'WebSocket',
    'Firebase Cloud Messaging',
    'PortOne 결제',
  ],
  screens: AppAssets.isayScreens,
);

const _isayWeb = ProjectItem(
  title: 'ISay Web',
  summary: '치료 센터·치료사를 위한 월 구독형 관리 웹 플랫폼',
  description:
      '치료 센터 관리자(원장)와 치료사가 사용하는 웹 클라이언트입니다. 센터 운영·상담 예약·재원생·치료 수업과 회기별 평가를 관리하고, 기록된 치료 데이터는 보호자 앱(ISay App)으로 연결됩니다. 센터는 월 구독권을 결제해 서비스를 이용합니다.',
  icon: AppAssets.isayWebIcon,
  category: '전 직장 프로젝트',
  period: '2025.01 ~ 2025.10',
  team: '2명 (웹 클라이언트 1 · 서버 1)',
  role: 'Flutter Web 클라이언트 개발 전체 담당',
  features: [
    '센터 소속 승인 체계 — 치료사가 가입할 때 근무하는 센터를 검색해 소속을 요청하고, 센터 관리자(원장)가 수락·거절하면 승인된 센터가 치료사 계정에 연결되어 해당 센터 데이터에 접근 (역할 기반 권한)',
    '센터 운영·상담 관리 — 센터 기본 정보, 휴무일, 업무 시간, 상담 가능 시간을 설정하고 보호자 앱에서 들어온 상담 예약 일정을 관리',
    '재원생 관리 — 상담 후 자녀들을 재원생으로 등록하고, 연결된 보호자(앱 사용자) 계정 정보를 확인',
    '치료 수업 일정 — 치료명·설명·장소·반·정원을 설정하고 반복 일정을 만든 뒤, 재원생 목록에서 수업을 받을 아동을 배정',
    '회기별 치료 평가 기록 — 수업이 끝나면 치료사가 아동별 점수와 개선된 영역 등 평가를 작성하고, 등록 즉시 보호자 앱에 FCM 알림이 가며 앱에 치료 데이터가 누적 (앱의 치료 이력·AI 평가서의 데이터 원천)',
    '보호자 1:1 실시간 채팅 — WebSocket 기반으로 보호자와 대화',
    '센터 월 구독 결제 — 센터 관리자가 월 구독권을 결제해 플랫폼을 이용하는 SaaS 구조, PortOne으로 결제 연동',
  ],
  contributions: [
    '센터 관리자(원장)·치료사용 웹 클라이언트를 Flutter Web으로 단독 설계·개발',
    '서버 개발자와 API 명세를 맞춰 가며 소속 승인, 상담 예약, 반복 수업 일정, 회기별 평가 등 핵심 업무 흐름을 연동',
    'PortOne 구독 결제, WebSocket 채팅, FCM 알림을 웹 클라이언트에 연동',
  ],
  issues: [
    ProjectIssue(
      problem:
          '한 치료사가 여러 센터에 소속될 수 있고 원장과 치료사의 권한도 달라, 화면마다 어떤 데이터를 보여 줄지 기준이 흩어지기 쉬웠습니다.',
      solution:
          '로그인 후 선택한 센터와 계정 역할을 앱 전역 상태로 두고, 메뉴·화면·API 요청이 모두 이 기준을 따르도록 구조를 잡았습니다.',
      result: '센터나 역할이 바뀌어도 화면별로 따로 처리할 필요 없이 일관되게 접근이 분리되었습니다.',
    ),
    ProjectIssue(
      problem: '반복 수업 일정을 만들 때 센터 휴무일이나 업무 시간 밖의 날짜가 섞여 생성될 수 있었습니다.',
      solution:
          '반복 규칙으로 날짜를 펼친 뒤 센터의 휴무일·업무 시간 설정과 대조해, 저장 전에 제외되는 날짜를 확인할 수 있게 했습니다.',
      result: '잘못 생성된 일정을 나중에 일일이 지우는 일이 줄었습니다.',
    ),
  ],
  results: [
    '웹 클라이언트를 혼자 맡아 서버 개발자와 API를 맞추며 출시까지 진행해, 명세 협의와 협업 방식을 몸으로 익혔습니다.',
    '치료사(웹)가 기록한 데이터가 보호자(앱)와 AI 평가서로 이어지는 구조를 앱·웹 양쪽에서 개발하며, 서비스 전체의 데이터 흐름을 설계하는 관점을 얻었습니다.',
  ],
  highlights: ['Flutter Web', 'WebSocket', 'FCM', 'PortOne'],
  skills: [
    'Flutter Web',
    'Dart',
    'WebSocket',
    'Firebase Cloud Messaging',
    'PortOne JS SDK (구독 결제)',
    '역할 기반 권한 (센터 관리자 · 치료사)',
  ],
  screens: AppAssets.isayWebScreens,
);
