import 'dart:async';
import 'dart:developer';

import 'package:local_server/dumy_data.dart';

import 'http_requests.dart';
import 'local_end_points.dart';

class ClientService {
  //
  Completer<void>? _clientCompleter;

  Future<bool> checkConnection({
    required String hostIp,
    int? port,
    int timeout = 1000,
  }) async {
    bool isSuccess = false;
    final response = await LocalRequest.getRequest(
      host: port == null ? '$hostIp:8080' : '$hostIp:$port',
      path: LocalEndPoints.checkConnection,
      timeout: timeout,
      queryParams: {'senderIp': ""},
    );
    response.fold(
      (l) {
        log(l.code.toString());
        log(l.message);
      },
      (r) {
        isSuccess = true;
        log(r.body);
      },
    );
    return isSuccess;
  }

  Future<(bool,String)> checkItemValidToUpdate({
    required String hostIp,
    int? port,
    int timeout = 1000,
    required String orderId,
    required String itemGuid,
    required String delete,
  }) async {
    bool isSuccess = false;
    final response = await LocalRequest.getRequest(
      host: port == null ? '$hostIp:8080' : '$hostIp:$port',
      path: LocalEndPoints.checkItemValidToUpdate,
      timeout: timeout,
      queryParams: {'orderId': orderId, 'itemGuid': itemGuid, 'delete': delete},
    );
    response.fold(
      (l) {
        log(l.code.toString());
        log(l.message);
        isSuccess = false;
      },
      (r) {
        isSuccess = true;
        log(r.body);
      },
    );
    return (isSuccess, response.fold((l) => l.message, (r) => r.body));
  }

  //
  _completeSendToNotifierCompleter() {
    _clientCompleter?.complete();
    _clientCompleter = null;
  }

  Future<void> sendOrderToKDS({
    required String hostIp,
    // required int orderId,
  }) async {
    final orderModel = await generateKdsModel();
    if (_clientCompleter != null && !_clientCompleter!.isCompleted) {
      await _clientCompleter!.future;
    }
    final isConnected = await checkConnection(hostIp: hostIp);
    if (!isConnected) {
      _completeSendToNotifierCompleter();
    }
    _clientCompleter = Completer<void>();
    final response = await LocalRequest.postRequest(
      host: '$hostIp:8080',
      path: LocalEndPoints.sendOrderToKDS,
      body: orderModel,
    );
    response.fold(
      (l) {
        log(l.code.toString());
        log(l.message);
        _completeSendToNotifierCompleter();
      },
      (r) {
        _completeSendToNotifierCompleter();
      },
    );
  }
}
