import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../services/api_client.dart';
import '../services/export_service.dart';
import '../../features/search/data/sources/search_remote_data_source.dart';
import '../../features/search/data/repositories/search_repository.dart';
import '../../features/search/presentation/providers/search_provider.dart';
import '../../features/chat/data/sources/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository.dart';
import '../../features/chat/presentation/providers/chat_provider.dart';
import '../../features/sessions/data/sources/sessions_remote_data_source.dart';
import '../../features/sessions/data/repositories/sessions_repository.dart';
import '../../features/sessions/presentation/providers/sessions_provider.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  // Dio
  final dio = Dio(BaseOptions(
    baseUrl: ApiClient.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ))..interceptors.add(PrettyDioLogger(requestBody: true, responseBody: false));

  sl.registerSingleton<Dio>(dio);

  // Search
  sl.registerLazySingleton<SearchRemoteDataSource>(() => SearchRemoteDataSource(sl<Dio>()));
  sl.registerLazySingleton<SearchRepository>(() => SearchRepository(sl<SearchRemoteDataSource>()));
  sl.registerFactory<SearchProvider>(() => SearchProvider(sl<SearchRepository>()));

  // Chat
  sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSource(sl<Dio>()));
  sl.registerLazySingleton<ChatRepository>(() => ChatRepository(sl<ChatRemoteDataSource>()));
  sl.registerFactory<ChatProvider>(() => ChatProvider(sl<ChatRepository>()));

  // Sessions
  sl.registerLazySingleton<SessionsRemoteDataSource>(() => SessionsRemoteDataSource(sl<Dio>()));
  sl.registerLazySingleton<SessionsRepository>(() => SessionsRepository(sl<SessionsRemoteDataSource>()));
  sl.registerFactory<SessionsProvider>(() => SessionsProvider(sl<SessionsRepository>()));

  // Export
  sl.registerLazySingleton<ExportService>(() => ExportService());
}
