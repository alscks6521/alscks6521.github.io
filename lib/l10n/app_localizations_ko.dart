// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get prev => '이전';

  @override
  String get next => '다음';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get changeFailed => '변경 실패';

  @override
  String get deliveryFailure => '발송 실패';

  @override
  String get authenticationFailure => '인증 실패';

  @override
  String get login => '로그인';

  @override
  String get serviceLogin => '서비스 로그인';

  @override
  String get serviceLoginSubTitle => '시스템 접근을 위해 로그인이 필요합니다.';

  @override
  String get servicePasswordSubTitle => '새로운 비밀번호로 로그인해주세요.';

  @override
  String get backToLogin => '돌아가기';

  @override
  String get findId => '아이디 찾기';

  @override
  String get patchPassword => '비밀번호 변경';

  @override
  String get patchSuccessPassword => '비밀번호 변경 완료';

  @override
  String get send => '전송';

  @override
  String get name => '이름';

  @override
  String get inputName => '이름을 입력해주세요.';

  @override
  String get birthDate => '생년월일';

  @override
  String get id => '아이디';

  @override
  String get inputId => '아이디를 입력해주세요.';

  @override
  String get password => '비밀번호';

  @override
  String get verifyPassword => '비밀번호 확인';

  @override
  String get inputPassword => '비밀번호를 입력해주세요.';

  @override
  String get passwordNotMatch => '비밀번호가 일치하지 않습니다.';

  @override
  String get passwordValid1 =>
      '비밀번호는 8~20자이며,\n영문 대소문자, 숫자, 특수문자 중\n3가지 이상을 포함해야 합니다.';

  @override
  String get phoneNumber => '휴대전화 번호';

  @override
  String get inputPhoneNumber => '휴대전화 번호를 입력해주세요.';

  @override
  String get phoneNumberNotFormat => '올바른 휴대전화 번호 형식이 아닙니다.';

  @override
  String get authenticationNumber => '인증번호';

  @override
  String get inputAuthenticationNumber => '인증번호를 입력해주세요.';

  @override
  String get authenticationNumberFirst => '먼저 인증번호를 발송해주세요.';

  @override
  String get noNewNotification => '새로운 알림이 없습니다.';

  @override
  String get goToApplicationHistory => '접수기록 바로가기';

  @override
  String get documentVerification => '문서 확인';

  @override
  String get documentBox => '문서함';

  @override
  String get goToDocumentBox => '문서함 바로가기';

  @override
  String get recentDocuments => '최근 문서';

  @override
  String get confirmationDocument => '확인 문서';

  @override
  String get unidentifiedDocument => '미확인 문서';

  @override
  String get reportDetails => '신고 내용';

  @override
  String get inputFillOutTheNearReport => '근접 사고 신고 내용을 작성해주세요.';

  @override
  String get writeReportDetails => '신고 내용 작성';

  @override
  String get pleaseAttachTheNearReportFile => '근접 사고 신고 파일을 첨부해주세요.';

  @override
  String get instructionsForCompletingReport => '신고 작성 안내';

  @override
  String get checkTheWrittenContent => '  • 작성된 내용을 관리자가 확인할 수 있습니다.';

  @override
  String get pleaseBrieflyDescribeTheNear => '  • 근접 사고 내용을 간략하게 작성해주세요.';

  @override
  String get informationOnAttachingReportFile => '신고 파일 첨부 안내';

  @override
  String get registeredFilesCheckedByAdmin => '  • 등록된 파일은 관리자가 확인할 수 있습니다.';

  @override
  String get selectFromAlbum => '앨범에서 선택';

  @override
  String get cameraShooting => '카메라 촬영';

  @override
  String get recordingFile => '녹음 파일';

  @override
  String get submitWithoutAttachments => '첨부 파일 없이 접수하기';

  @override
  String get missReporthasBeenReceived => '근접 사고 신고 접수가\n완료되었습니다';

  @override
  String get feedbackWait => '접수에 맞는 근접사고 피드백을 생성하고 있습니다.\n잠시만 기다려주세요.';

  @override
  String get gatherData => '자료를 모으기';

  @override
  String get gatherData2 => '접수된 신고 내용을 읽어보고 있습니다.';

  @override
  String get analyzeData => '데이터를 분석하기';

  @override
  String get analyzeData2 => '근접사고 데이터를 분석하고 있습니다.';

  @override
  String get creatingAction => '조치 생성하기';

  @override
  String get creatingAction2 => '신고에 올바른 조치를 생성하고 있습니다.';

  @override
  String get greeting => '안녕하세요';

  @override
  String get reportNearMiss => '근접 사고 신고';

  @override
  String get reportNearMissInfo => '현장작업중 발생한 근접 사고 신고';

  @override
  String get regularPeriodicInspection => '정기/수시 정검';

  @override
  String get immediateAction => '즉각조치';
}
