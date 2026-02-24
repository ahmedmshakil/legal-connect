import 'dart:async';
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../app/config/api_config.dart';
import 'storage_service.dart';

class WebSocketService extends GetxService {
  StompClient? _client;
  final RxBool isConnected = false.obs;
  final _subscriptions = <String, StompUnsubscribe>{};
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

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
        onStompError: (frame) {
          isConnected.value = false;
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
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      Duration(seconds: 2 * (_reconnectAttempts + 1)),
      () {
        _reconnectAttempts++;
        connect();
      },
    );
  }

  void subscribe(String destination, void Function(StompFrame) callback) {
    if (_client == null || !isConnected.value) return;
    if (_subscriptions.containsKey(destination)) return;

    final unsub = _client!.subscribe(
      destination: destination,
      callback: callback,
    );
    _subscriptions[destination] = unsub;
  }

  void unsubscribe(String destination) {
    final unsub = _subscriptions.remove(destination);
    if (unsub != null) {
      unsub(unsubscribeHeaders: {});
    }
  }

  void send(String destination, String body) {
    if (_client == null || !isConnected.value) return;
    _client!.send(destination: destination, body: body);
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    for (final key in _subscriptions.keys.toList()) {
      unsubscribe(key);
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
