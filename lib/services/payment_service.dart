import 'api_service.dart';
import '../models/payment.dart';

class PaymentService {
  static Future<Map<String, dynamic>> getPayments({
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

    final result = await ApiService.get(ApiService.ENDPOINT_PAYMENTS, queryParams: queryParams);

    if (result['success']) {
      try {
        final response = PaymentListResponse.fromJson(result['data']);
        return {
          'success': true,
          'data': response,
        };
      } catch (e, stack) {
        print('Error parsing payments: $e');
        print(stack);
        return {
          'success': false,
          'message': 'Error parsing payment data: $e',
        };
      }
    }

    return result;
  }
}
