import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_server/client_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _ipController = TextEditingController();
  final ClientService _clientService = ClientService();
  bool _isSending = false;
  bool _isSending2 = false;

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _sendOrderToKDS() async {
    if (_ipController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a host IP')));
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _clientService.sendOrderToKDS(hostIp: _ipController.text);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order sent successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending order: $e')));
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _updateItemToKDS() async {
    if (_ipController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a host IP')));
      return;
    }

    setState(() {
      _isSending2 = true;
    });

    try {
      final result = await _clientService.checkItemValidToUpdate(
        hostIp: _ipController.text,
        orderId: "1746969192103",
        itemGuid: "0e66bbb4-1f6e-4c6c-9ad3-8f697897ad48",
        delete: "1",
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.$2)));
      setState(() {
        _isSending2 = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending order: $e')));
    } finally {
      setState(() {
        _isSending2 = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Host IP Address',
                hintText: 'Enter KDS host IP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.computer),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isSending ? null : _sendOrderToKDS,
              icon:
                  _isSending
                      ? const CircularProgressIndicator.adaptive()
                      : const Icon(Icons.send),
              label: Text(_isSending ? 'Sending...' : 'Send Order to KDS'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isSending2 ? null : _updateItemToKDS,
              icon:
                  _isSending2
                      ? const CircularProgressIndicator.adaptive()
                      : const Icon(Icons.send),
              label: Text(_isSending2 ? 'Sending...' : 'Update Item to KDS'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
