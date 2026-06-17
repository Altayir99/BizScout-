import '../models/search_result.dart';
import '../models/research_result.dart';
import '../sources/search_remote_data_source.dart';

class SearchRepository {
  final SearchRemoteDataSource _source;
  SearchRepository(this._source);

  Future<SearchResult> search(String query, String mode) =>
      _source.search(query, mode);

  Future<ResearchResult> research(String query, String mode) =>
      _source.research(query, mode);
}
