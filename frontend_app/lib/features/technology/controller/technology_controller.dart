import '../model/technology.dart';
import '../service/technology_service.dart';

class TechnologyController {
  final TechnologyService _service = TechnologyService();

  Future<List<TechTrend>> getTechTrends(String category) async {
    return await _service.getTechTrends(category);
  }
}