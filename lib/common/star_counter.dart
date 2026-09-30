import 'dart:convert';

import 'package:http/http.dart' as http;

class StarCounterConfig {
  static const projectId = 'my-web-1eda1';
  static const apiKey = 'AIzaSyDKLtTO2EGuyB0aPr01cXMyW-LejLdC_ak';

  static bool get enabled => projectId.isNotEmpty && apiKey.isNotEmpty;
}

enum VoteStatus { ok, already, error }

class StarCounter {
  static const _base = 'https://firestore.googleapis.com/v1';

  static String get _db =>
      'projects/${StarCounterConfig.projectId}/databases/(default)/documents';

  static Future<int?> fetch() async {
    if (!StarCounterConfig.enabled) return null;
    try {
      final res = await http
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

  static Future<({VoteStatus status, int? count})> vote() async {
    const fail = (status: VoteStatus.error, count: null);
    if (!StarCounterConfig.enabled) return fail;
    try {
      final auth = await http
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

      final res = await http
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
      return (status: VoteStatus.ok, count: int.tryParse('$v'));
    } catch (_) {
      return fail;
    }
  }
}
