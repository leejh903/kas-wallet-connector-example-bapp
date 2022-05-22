import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kas_wallet_connector_example_bapp/constant/env.dart';
import 'package:http/http.dart' as http;
import 'package:kas_wallet_connector_example_bapp/constant/storage.dart';
import 'package:kas_wallet_connector_example_bapp/model/error.dart';
import 'package:kas_wallet_connector_example_bapp/model/jwt.dart';

class KasService {
  static final endpoint = dotenv.env[kasWalletConnectorUrl]!;
  static final clientId = dotenv.env[kasWalletConnectorClientId]!;
  static final poolId = dotenv.env[kasWalletConnectorPoolId]!;
  static final xchainId = dotenv.env[chainId]!;

  Future<dynamic> login(String userName, String password) async {
    Map data = {
      'userName': userName,
      'password': password,
      'clientId': clientId,
      //FIXME: remove poolId if backend API spec changed
      'poolId': poolId,
    };
    final body = json.encode(data);

    final response = await http.post(
      Uri.https(endpoint, '/v1/login'),
      body: body,
    );

    final decode = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      return KasError.fromJson(decode);
    }
    return JWT.fromJson(decode);
  }

  Future<dynamic> register(
      String userName, String password, String name) async {
    Map data = {
      'userName': userName,
      'password': password,
      'userAttributes': [
        {
          'name': 'name',
          'value': name,
        },
      ],
      'clientId': clientId
    };
    final body = json.encode(data);

    final response = await http.post(
      Uri.https(endpoint, '/v1/account'),
      body: body,
    );

    final decode = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      return KasError.fromJson(decode);
    }
    return decode;
  }

  Future<dynamic> sendLegacyTransaction(String to, String value) async {
    const storage = FlutterSecureStorage();
    final accessKey = await storage.read(key: accessToken);
    Map data = {
      'to': to,
      'value': value,
      'submit': true,
    };
    final body = json.encode(data);

    final response = await http.post(
      Uri.https(endpoint, '/v1/wallet/tx/legacy'),
      body: body,
      headers: <String, String>{
        'Authorization': accessKey!,
        'x-chain-id': xchainId,
        //FIXME: remove x-account-id
        'x-account-id': 'wc-bapp-demo',
      },
    );

    final decode = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      return KasError.fromJson(decode);
    }
    return decode;
  }

  Future<dynamic> sendVerificationCode(String userName) async {
    Map data = {
      'clientId': clientId,
    };
    final body = json.encode(data);

    final response = await http.post(
      Uri.https(endpoint, '/v1/account/$userName/verification'),
      body: body,
    );

    final decode = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      return KasError.fromJson(decode);
    }
    return decode;
  }

  Future<dynamic> confirmVerificationCode(
      String userName, String newPassword, String confirmCode) async {
    Map data = {
      'confirmCode': confirmCode,
      'newPassword': newPassword,
      'clientId': clientId,
    };
    final body = json.encode(data);

    final response = await http.post(
      Uri.https(endpoint, '/v1/account/$userName/confirm'),
      body: body,
    );

    final decode = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      return KasError.fromJson(decode);
    }
    return decode;
  }
}
