import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class Utility {
  static Future<String> getStableId() async {
    return const Uuid().v4();
  }

  static String randomNonce([int length = 32]) {
    const cs =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final r = Random.secure();
    return List.generate(length, (_) => cs[r.nextInt(cs.length)]).join();
  }

  static String createSHA256(String s) =>
      sha256.convert(utf8.encode(s)).toString();
}
