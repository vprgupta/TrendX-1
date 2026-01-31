import '../model/world_trend.dart';
import '../service/world_service.dart';

class WorldController {
  final WorldService _service = WorldService();

  Future<List<WorldTrend>> getTop50WorldTrends() async {
    return await _service.getTop50WorldTrends();
  }
}