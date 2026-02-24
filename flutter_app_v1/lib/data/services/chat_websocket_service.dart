import 'dart:async';
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../app/config/api_config.dart';
import 'storage_service.dart';

class ChatWebSocketService extends GetxService {
  StompClient? _client;
  final RxBool isConnected = false.obs;
  final _subscriptions = <String, StompUnsubscribe>{};
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  Future<void> connect() async {
    if (_client != null && isConnected.value) return;

    final storage = Get.find<StorageService>();
    final token = await storage.getToken();
    if (token == null) return;

    _client = StompClient(
      config: StompConfig.sockJS(
        url: ApiConfig.wsBaseUrl,
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onWebSocketError: (error) {
          isConnected.value = false;
          _scheduleReconnect();
        },
      ),
    );

    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    isConnected.value = true;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
  }

  void _onDisconnect(StompFrame frame) {
    isConnected.value = false;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= 10) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      Duration(seconds: 2 * (_reconnectAttempts + 1)),
      () {
        _reconnectAttempts++;
        connect();
      },
    );
  }

  void subscribeToMessages(String userId, void Function(StompFrame) callback) {
    final dest = '/user/$userId/messages';
    if (_subscriptions.containsKey(dest)) return;
    if (_client == null || !isConnected.value) return;

    final unsub = _client!.subscribe(destination: dest, callback: callback);
    _subscriptions[dest] = unsub;
  }

  void subscribeToReadStatus(
    String userId,
    void Function(StompFrame) callback,
  ) {
    final dest = '/user/$userId/read-status';
    if (_subscriptions.containsKey(dest)) return;
    if (_client == null || !isConnected.value) return;

    final unsub = _client!.subscribe(destination: dest, callback: callback);
    _subscriptions[dest] = unsub;
  }

  void sendMessage(String destination, String body) {
    if (_client == null || !isConnected.value) return;
    _client!.send(destination: destination, body: body);
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    for (final key in _subscriptions.keys.toList()) {
      final unsub = _subscriptions.remove(key);
      unsub?.call(unsubscribeHeaders: {});
    }
    _client?.deactivate();
    _client = null;
    isConnected.value = false;
    _reconnectAttempts = 0;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
