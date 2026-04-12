import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/chat_controller.dart';
import '../data/providers/api_provider.dart';
import '../data/services/websocket_service.dart';
import '../data/services/chat_websocket_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core services (StorageService already registered in main())
    final api = ApiProvider();
    api.init();
    Get.put(api, permanent: true);

    // WebSocket services — lazy loaded (only when needed)
    Get.lazyPut(() => WebSocketService(), fenix: true);
    Get.lazyPut(() => ChatWebSocketService(), fenix: true);

    // Core controllers — always needed
    Get.put(ThemeController(), permanent: true);
    Get.put(AuthController(), permanent: true);

    // These are needed for badge counts — lazy but auto-created
    Get.lazyPut(() => NotificationController(), fenix: true);
    Get.lazyPut(() => ChatController(), fenix: true);
  }
}
