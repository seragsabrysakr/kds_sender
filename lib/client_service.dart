import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:local_server/main.dart';

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
 

  //
  _completeSendToNotifierCompleter() {
    _clientCompleter?.complete();
    _clientCompleter = null;
  }

  Future<void> sendOrderToKDS({
    required String hostIp,
    // required int orderId,
  }) async {
    // final orderModel = await generateKdsModel();
    final orderModel = {
      'id': 17472223323100,
      'invoiceId': 'INV-17472223323100',
      'order_id': 17472223323100,
      'created_at': '2025-05-14T11:32:12.399521',
      'status': 'Pending',
      'table_number': '',
      'customer_name': '',
      'items': [
        {
          'sortOrder': 1,
          'itemGuid': '1cac6791-3593-4d53-b650-c9f6516d49a2',
          'customerNo': 'P1',
          'itemStatus': 'Pending',
          'name': 'كباب مشوي',
          'nameEn': 'Grilled Kebab',
          'quantity': '2',
          'orderRefId': 'INV-17472223323100',
        },
        // {
        //   'sortOrder': 1,
        //   'itemGuid': '0bf3b4ab-42e5-4c07-89d3-ba070f0f739d',
        //   'customerNo': 'P1',
        //   'itemStatus': 'Pending',
        //   'name': 'كباب مشوي',
        //   'nameEn': 'Grilled Kebab',
        //   'quantity': '2',
        //   'orderRefId': 'INV-17472223323100',
        //   'modifires': "['وجبة', 'صلصة حارة', 'جبنة زيادة']",
        //   'modifiresEn': "['Meal', 'Spicy Sauce', 'Extra Cheese']",
        // },
        // {
        //   'sortOrder': 2,
        //   'itemGuid': '28c05727-f22f-409d-9982-a5846bf2e5ec',
        //   'customerNo': 'P1',
        //   'itemStatus': 'Pending',
        //   'name': 'كباب مشوي',
        //   'nameEn': 'Grilled Kebab',
        //   'quantity': '2',
        //   'orderRefId': 'INV-17472223323100',
        // },
      ],
    };
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
        ScaffoldMessenger.of(
          appNavigatorKey.currentState!.context,
        ).showSnackBar(SnackBar(content: Text(l.message)));
        log(l.code.toString());
        log(l.message);
        _completeSendToNotifierCompleter();
      },
      (r) {
        ScaffoldMessenger.of(
          appNavigatorKey.currentState!.context,
        ).showSnackBar(SnackBar(content: Text(r.body)));
        log(r.body);
        _completeSendToNotifierCompleter();
      },
    );
  }
}
