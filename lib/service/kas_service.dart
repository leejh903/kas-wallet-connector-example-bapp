import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kas_wallet_connector_example_bapp/constant/env.dart';
import 'package:http/http.dart' as http;
import 'package:kas_wallet_connector_example_bapp/model/error.dart';
import 'package:kas_wallet_connector_example_bapp/model/jwt.dart';

class KasService {
  static final endpoint = dotenv.env[kasWalletConnectorUrl]!;
  static final clientId = dotenv.env[kasWalletConnectorClientId]!;

  Future<dynamic> login(String userName, String password) async {
    final response = await http.post(
      Uri.http(endpoint, '/v1/login'),
      body: <String, String>{
        'userName': userName,
        'password': password,
        'clientId': clientId,
      },
    );

    final decode = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      return KasError.fromJson(decode);
    }
    return JWT.fromJson(decode);
  }
}
