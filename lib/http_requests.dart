import 'dart:convert';
import 'dart:developer';

import 'package:eitherx/eitherx.dart';
import 'package:http/http.dart' as http;

class LocalRequest {
  static Future<Either<Failure, http.Response>> getRequest({
    required String host,
    required String path,
    Map<String, dynamic>? queryParams,
    int? timeout,
  }) async {
    try {
      log('start Request');
      final client = http.Client();

      final uri = Uri.http(host, path, queryParams);
      var headers = {
        'Content-Type': 'application/json',
        // 'connection': 'keep-alive'
      };
      log('host: $host');
      log('path: $path');
      log('queryParams: $queryParams');
      http.Response response = await client
          .get(uri, headers: headers)
          .timeout(Duration(milliseconds: timeout ?? 4000));

      // log(response.body.toString());
      if (response.statusCode == 200) {
        log(response.toString());
        return Right(response);
      } else if (response.statusCode == 400) {
        return Left(Failure(400, 'CONNETION_ERROR'));
      } else {
        return Left(Failure(401, response.body.toString()));
      }
    } catch (e, t) {
      log(e.toString());
      log(t.toString());
      log(path);

      return Left(Failure(404, 'CONNETION_ERROR'));
    }
  }

  static Future<Either<Failure, http.Response>> postRequest(
      {required String host,
      required String path,
      int? timeout,
      Map<String, dynamic>? queryParams,
      required Map<String, dynamic> body}) async {
    try {
      final client = http.Client();
      final uri = Uri.http(host, path, queryParams);
      var headers = {
        'Content-Type': 'application/json',
        // 'connection': 'keep-alive',
        //  "Keep-Alive": "timeout=10, max=1000"
      };

      http.Response response = await client
          .post(
            uri,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(Duration(milliseconds: timeout ?? 4000));

      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return Left(Failure(401, 'CONNETION_ERROR'));
      }
    } catch (e, t) {
      log(e.toString());
      log(t.toString());
      log(path);

      return Left(Failure(404, 'CONNETION_ERROR'));
    }
  }
}

class Failure {
  int code; // 200, 201, 400, 303..500 and so on
  String message; // error , success

  Failure(this.code, this.message);
}
