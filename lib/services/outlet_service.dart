import '../models/outlet.dart';
import 'api_service.dart';

class OutletService {
  static Future<Map<String, dynamic>> getOutlets({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final result = await ApiService.get('/outlet', queryParams: queryParams);

    if (result['success']) {
      final response = OutletListResponse.fromJson(result['data']);
      return {
        'success': true,
        'data': response,
      };
    }

    return result;
  }

  static Future<Map<String, dynamic>> getOutletById(String id) async {
    final result = await ApiService.get('/outlet/$id');

    if (result['success']) {
      final outlet = Outlet.fromJson(result['data']);
      return {
        'success': true,
        'data': outlet,
      };
    }

    return result;
  }
}
