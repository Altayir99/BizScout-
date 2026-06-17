import 'package:dio/dio.dart';
import '../models/search_result.dart';

class SearchRemoteDataSource {
  final Dio _dio;
  SearchRemoteDataSource(this._dio);

  Future<SearchResult> search(String query, String mode) async {
    final response = await _dio.post('/search', data: {'query': query, 'mode': mode});
    return SearchResult.fromJson(response.data as Map<String, dynamic>);
  }
}
