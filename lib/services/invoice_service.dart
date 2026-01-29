import 'api_service.dart';
import '../models/invoice.dart';

class InvoiceService {
  static Future<Map<String, dynamic>> getInvoices({
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

    final result = await ApiService.get(ApiService.ENDPOINT_INVOICES, queryParams: queryParams);

    if (result['success']) {
      try {
        final response = InvoiceListResponse.fromJson(result['data']);
        return {
          'success': true,
          'data': response,
        };
      } catch (e) {
        print('Error parsing invoices: $e');
        return {
          'success': false,
          'message': 'Error parsing invoice data',
        };
      }
    }

    return result;
  }
}
