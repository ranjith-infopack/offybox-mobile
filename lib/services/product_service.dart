import 'api_service.dart';
import '../models/product.dart';

class ProductService {
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final result = await ApiService.get(ApiService.ENDPOINT_PRODUCTS, queryParams: queryParams);
    print('ProductService.getProducts result: $result');

    if (result['success']) {
      try {
        final body = result['data'];
        final List dataList;
        
        if (body is List) {
          dataList = body;
        } else if (body is Map) {
          // Check for 'data' key which might contain the list or another nested 'data'
          if (body['data'] is List) {
            dataList = body['data'];
          } else if (body['data'] is Map && body['data']['data'] is List) {
            dataList = body['data']['data'];
          } else {
            dataList = [];
          }
        } else {
          dataList = [];
        }

        final products = dataList
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
            
        return {
          'success': true,
          'data': products,
        };
      } catch (e) {
        print('Error parsing products: $e');
        return {
          'success': false,
          'message': 'Error processing product data. Please contact support.',
        };
      }
    }

    return result;
  }
}
