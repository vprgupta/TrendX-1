import 'package:get_it/get_it.dart';
import '../services/news_service.dart';
import '../services/preferences_service.dart';
import '../../services/youtube_service.dart';
import '../services/theme_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Services
  getIt.registerLazySingleton<NewsService>(() => NewsService());
  getIt.registerLazySingleton<PreferencesService>(() => PreferencesService());
  getIt.registerLazySingleton<YoutubeService>(() => YoutubeService());
  getIt.registerLazySingleton<ThemeService>(() => ThemeService());
}
