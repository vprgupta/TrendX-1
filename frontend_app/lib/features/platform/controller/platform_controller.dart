import '../model/platform.dart';
import '../service/platform_service.dart';
import '../../../core/services/socket_service.dart';

class PlatformController {
  final PlatformService _service = PlatformService();
  final SocketService _socketService = SocketService();
  Function()? _onUpdate;

  void setUpdateCallback(Function() callback) {
    _onUpdate = callback;
    _socketService.addTrendListener(_handleSocketUpdate);
  }

  void _handleSocketUpdate(Map<String, dynamic> update) {
    if (update['type'] == 'created' || update['type'] == 'deleted') {
      _onUpdate?.call();
    }
  }

  Future<List<PlatformTrend>> getPlatformTrends(String platform, [String? countryCode]) async {
    return await _service.getPlatformTrends(platform, countryCode);
  }

  void dispose() {
    _socketService.removeTrendListener(_handleSocketUpdate);
  }
}