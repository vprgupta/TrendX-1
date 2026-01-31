import '../model/country.dart';
import '../service/country_service.dart';

class CountryController {
  final CountryService _service = CountryService();

  Future<List<CountryTrend>> getCountryTrends(String country) async {
    return await _service.getCountryTrends(country);
  }
}