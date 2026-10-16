import 'dart:convert';

import 'package:github_portfolio/features/star/domain/entities/vote_result.dart';
import 'package:http/http.dart' as http;

class StarCounterConfig {
  static const projectId = 'my-web-1eda1';
  static const apiKey = 'AIzaSyDKLtTO2EGuyB0aPr01cXMyW-LejLdC_ak';

  static bool get enabled => projectId.isNotEmpty && apiKey.isNotEmpty;
}

/// Firestore REST API 로 별 카운터를 읽고 올린다 (익명 로그인 1회 = 1표).
class StarRemoteDataSource {
  static const _base = 'https://firestore.googleapis.com/v1';

  final http.Client _client;
  StarRemoteDataSource([http.Client? client])
      : _client = client ?? http.Client();

  bool get enabled => StarCounterConfig.enabled;

  static String get _db =>
      'projects/${StarCounterConfig.projectId}/databases/(default)/documents';

  Future<int?> fetch() async {
    if (!StarCounterConfig.enabled) return null;
    try {
      final res = await _client
          .get(Uri.parse(
              '$_base/$_db/counters/star?key=${StarCounterConfig.apiKey}'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final v = jsonDecode(res.body)['fields']?['count']?['integerValue'];
      return int.tryParse('$v');
    } catch (_) {
      return null;
    }
  }

  Future<VoteResult> vote() async {
    const fail = VoteResult.error;
    if (!StarCounterConfig.enabled) return fail;
    try {
      final auth = await _client
          .post(
            Uri.parse(
                'https://identitytoolkit.googleapis.com/v1/accounts:signUp'
                '?key=${StarCounterConfig.apiKey}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'returnSecureToken': true}),
          )
          .timeout(const Duration(seconds: 8));
      if (auth.statusCode != 200) return fail;
      final a = jsonDecode(auth.body);
      final idToken = a['idToken'] as String;
      final uid = a['localId'] as String;

      final res = await _client
          .post(
            Uri.parse('$_base/projects/${StarCounterConfig.projectId}'
                '/databases/(default)/documents:commit'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode({
              'writes': [
                {
                  'update': {'name': '$_db/stars/$uid', 'fields': {}},
                  'updateTransforms': [
                    {'fieldPath': 'at', 'setToServerValue': 'REQUEST_TIME'}
                  ],
                  'currentDocument': {'exists': false},
                },
                {
                  'transform': {
                    'document': '$_db/counters/star',
                    'fieldTransforms': [
                      {
                        'fieldPath': 'count',
                        'increment': {'integerValue': '1'}
                      }
                    ],
                  }
                },
              ]
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return fail;
      final v = jsonDecode(res.body)['writeResults']?[1]?['transformResults']
          ?[0]?['integerValue'];
      return VoteResult(VoteStatus.ok, int.tryParse('$v'));
    } catch (_) {
      return fail;
    }
  }
}
