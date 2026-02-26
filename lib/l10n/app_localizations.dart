import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @prev.
  ///
  /// In ko, this message translates to:
  /// **'이전'**
  String get prev;

  /// No description provided for @next.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get next;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @changeFailed.
  ///
  /// In ko, this message translates to:
  /// **'변경 실패'**
  String get changeFailed;

  /// No description provided for @deliveryFailure.
  ///
  /// In ko, this message translates to:
  /// **'발송 실패'**
  String get deliveryFailure;

  /// No description provided for @authenticationFailure.
  ///
  /// In ko, this message translates to:
  /// **'인증 실패'**
  String get authenticationFailure;

  /// No description provided for @login.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get login;

  /// No description provided for @serviceLogin.
  ///
  /// In ko, this message translates to:
  /// **'서비스 로그인'**
  String get serviceLogin;

  /// No description provided for @serviceLoginSubTitle.
  ///
  /// In ko, this message translates to:
  /// **'시스템 접근을 위해 로그인이 필요합니다.'**
  String get serviceLoginSubTitle;

  /// No description provided for @servicePasswordSubTitle.
  ///
  /// In ko, this message translates to:
  /// **'새로운 비밀번호로 로그인해주세요.'**
  String get servicePasswordSubTitle;

  /// No description provided for @backToLogin.
  ///
  /// In ko, this message translates to:
  /// **'돌아가기'**
  String get backToLogin;

  /// No description provided for @findId.
  ///
  /// In ko, this message translates to:
  /// **'아이디 찾기'**
  String get findId;

  /// No description provided for @patchPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 변경'**
  String get patchPassword;

  /// No description provided for @patchSuccessPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 변경 완료'**
  String get patchSuccessPassword;

  /// No description provided for @send.
  ///
  /// In ko, this message translates to:
  /// **'전송'**
  String get send;

  /// No description provided for @name.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get name;

  /// No description provided for @inputName.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력해주세요.'**
  String get inputName;

  /// No description provided for @birthDate.
  ///
  /// In ko, this message translates to:
  /// **'생년월일'**
  String get birthDate;

  /// No description provided for @id.
  ///
  /// In ko, this message translates to:
  /// **'아이디'**
  String get id;

  /// No description provided for @inputId.
  ///
  /// In ko, this message translates to:
  /// **'아이디를 입력해주세요.'**
  String get inputId;

  /// No description provided for @password.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get password;

  /// No description provided for @verifyPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 확인'**
  String get verifyPassword;

  /// No description provided for @inputPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 입력해주세요.'**
  String get inputPassword;

  /// No description provided for @passwordNotMatch.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호가 일치하지 않습니다.'**
  String get passwordNotMatch;

  /// No description provided for @passwordValid1.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호는 8~20자이며,\n영문 대소문자, 숫자, 특수문자 중\n3가지 이상을 포함해야 합니다.'**
  String get passwordValid1;

  /// No description provided for @phoneNumber.
  ///
  /// In ko, this message translates to:
  /// **'휴대전화 번호'**
  String get phoneNumber;

  /// No description provided for @inputPhoneNumber.
  ///
  /// In ko, this message translates to:
  /// **'휴대전화 번호를 입력해주세요.'**
  String get inputPhoneNumber;

  /// No description provided for @phoneNumberNotFormat.
  ///
  /// In ko, this message translates to:
  /// **'올바른 휴대전화 번호 형식이 아닙니다.'**
  String get phoneNumberNotFormat;

  /// No description provided for @authenticationNumber.
  ///
  /// In ko, this message translates to:
  /// **'인증번호'**
  String get authenticationNumber;

  /// No description provided for @inputAuthenticationNumber.
  ///
  /// In ko, this message translates to:
  /// **'인증번호를 입력해주세요.'**
  String get inputAuthenticationNumber;

  /// No description provided for @authenticationNumberFirst.
  ///
  /// In ko, this message translates to:
  /// **'먼저 인증번호를 발송해주세요.'**
  String get authenticationNumberFirst;

  /// No description provided for @noNewNotification.
  ///
  /// In ko, this message translates to:
  /// **'새로운 알림이 없습니다.'**
  String get noNewNotification;

  /// No description provided for @goToApplicationHistory.
  ///
  /// In ko, this message translates to:
  /// **'접수기록 바로가기'**
  String get goToApplicationHistory;

  /// No description provided for @documentVerification.
  ///
  /// In ko, this message translates to:
  /// **'문서 확인'**
  String get documentVerification;

  /// No description provided for @documentBox.
  ///
  /// In ko, this message translates to:
  /// **'문서함'**
  String get documentBox;

  /// No description provided for @goToDocumentBox.
  ///
  /// In ko, this message translates to:
  /// **'문서함 바로가기'**
  String get goToDocumentBox;

  /// No description provided for @recentDocuments.
  ///
  /// In ko, this message translates to:
  /// **'최근 문서'**
  String get recentDocuments;

  /// No description provided for @confirmationDocument.
  ///
  /// In ko, this message translates to:
  /// **'확인 문서'**
  String get confirmationDocument;

  /// No description provided for @unidentifiedDocument.
  ///
  /// In ko, this message translates to:
  /// **'미확인 문서'**
  String get unidentifiedDocument;

  /// No description provided for @reportDetails.
  ///
  /// In ko, this message translates to:
  /// **'신고 내용'**
  String get reportDetails;

  /// No description provided for @inputFillOutTheNearReport.
  ///
  /// In ko, this message translates to:
  /// **'근접 사고 신고 내용을 작성해주세요.'**
  String get inputFillOutTheNearReport;

  /// No description provided for @writeReportDetails.
  ///
  /// In ko, this message translates to:
  /// **'신고 내용 작성'**
  String get writeReportDetails;

  /// No description provided for @pleaseAttachTheNearReportFile.
  ///
  /// In ko, this message translates to:
  /// **'근접 사고 신고 파일을 첨부해주세요.'**
  String get pleaseAttachTheNearReportFile;

  /// No description provided for @instructionsForCompletingReport.
  ///
  /// In ko, this message translates to:
  /// **'신고 작성 안내'**
  String get instructionsForCompletingReport;

  /// No description provided for @checkTheWrittenContent.
  ///
  /// In ko, this message translates to:
  /// **'  • 작성된 내용을 관리자가 확인할 수 있습니다.'**
  String get checkTheWrittenContent;

  /// No description provided for @pleaseBrieflyDescribeTheNear.
  ///
  /// In ko, this message translates to:
  /// **'  • 근접 사고 내용을 간략하게 작성해주세요.'**
  String get pleaseBrieflyDescribeTheNear;

  /// No description provided for @informationOnAttachingReportFile.
  ///
  /// In ko, this message translates to:
  /// **'신고 파일 첨부 안내'**
  String get informationOnAttachingReportFile;

  /// No description provided for @registeredFilesCheckedByAdmin.
  ///
  /// In ko, this message translates to:
  /// **'  • 등록된 파일은 관리자가 확인할 수 있습니다.'**
  String get registeredFilesCheckedByAdmin;

  /// No description provided for @selectFromAlbum.
  ///
  /// In ko, this message translates to:
  /// **'앨범에서 선택'**
  String get selectFromAlbum;

  /// No description provided for @cameraShooting.
  ///
  /// In ko, this message translates to:
  /// **'카메라 촬영'**
  String get cameraShooting;

  /// No description provided for @recordingFile.
  ///
  /// In ko, this message translates to:
  /// **'녹음 파일'**
  String get recordingFile;

  /// No description provided for @submitWithoutAttachments.
  ///
  /// In ko, this message translates to:
  /// **'첨부 파일 없이 접수하기'**
  String get submitWithoutAttachments;

  /// No description provided for @missReporthasBeenReceived.
  ///
  /// In ko, this message translates to:
  /// **'근접 사고 신고 접수가\n완료되었습니다'**
  String get missReporthasBeenReceived;

  /// No description provided for @feedbackWait.
  ///
  /// In ko, this message translates to:
  /// **'접수에 맞는 근접사고 피드백을 생성하고 있습니다.\n잠시만 기다려주세요.'**
  String get feedbackWait;

  /// No description provided for @gatherData.
  ///
  /// In ko, this message translates to:
  /// **'자료를 모으기'**
  String get gatherData;

  /// No description provided for @gatherData2.
  ///
  /// In ko, this message translates to:
  /// **'접수된 신고 내용을 읽어보고 있습니다.'**
  String get gatherData2;

  /// No description provided for @analyzeData.
  ///
  /// In ko, this message translates to:
  /// **'데이터를 분석하기'**
  String get analyzeData;

  /// No description provided for @analyzeData2.
  ///
  /// In ko, this message translates to:
  /// **'근접사고 데이터를 분석하고 있습니다.'**
  String get analyzeData2;

  /// No description provided for @creatingAction.
  ///
  /// In ko, this message translates to:
  /// **'조치 생성하기'**
  String get creatingAction;

  /// No description provided for @creatingAction2.
  ///
  /// In ko, this message translates to:
  /// **'신고에 올바른 조치를 생성하고 있습니다.'**
  String get creatingAction2;

  /// No description provided for @greeting.
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요'**
  String get greeting;

  /// No description provided for @reportNearMiss.
  ///
  /// In ko, this message translates to:
  /// **'근접 사고 신고'**
  String get reportNearMiss;

  /// No description provided for @reportNearMissInfo.
  ///
  /// In ko, this message translates to:
  /// **'현장작업중 발생한 근접 사고 신고'**
  String get reportNearMissInfo;

  /// No description provided for @regularPeriodicInspection.
  ///
  /// In ko, this message translates to:
  /// **'정기/수시 정검'**
  String get regularPeriodicInspection;

  /// No description provided for @immediateAction.
  ///
  /// In ko, this message translates to:
  /// **'즉각조치'**
  String get immediateAction;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
