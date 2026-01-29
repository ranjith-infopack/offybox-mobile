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
        final productsData = result['data']['data'] as List? ?? [];
        final products = productsData
            .map((e) => Product.fromJson(e))
            .toList();
        return {
          'success': true,
          'data': products,
        };
      } catch (e) {
        print('Error parsing products: $e');
        return {
          'success': false,
          'message': 'Error parsing product data: $e',
        };
      }
    }

    return result;
  }
}
