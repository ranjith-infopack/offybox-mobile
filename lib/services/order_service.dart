import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static Future<OrderListResponse> getOrders({
    int page = 1,
    int limit = 20,
    String orderType = 'QUOTATION',
  }) async {
    final response = await ApiService.get(
      '/orders?page=$page&limit=$limit&order_type=$orderType',
    );

    if (response['success'] == true && response['data'] != null) {
      return OrderListResponse.fromJson(response['data']);
    }

    return OrderListResponse(data: [], page: 1, limit: limit, total: 0);
  }

  static Future<Order?> getOrderById(String id) async {
    final response = await ApiService.get('/orders/$id');

    print('OrderService.getOrderById response: $response');

    if (response['success'] == true) {
      // Check if data is wrapped in 'data' field or returned directly
      final orderData = response['data'];
      if (orderData != null) {
        // If data contains 'id', it's the order object directly
        // If data contains nested 'data', extract it
        if (orderData is Map<String, dynamic>) {
          if (orderData.containsKey('id')) {
            print('Parsing order from data: $orderData');
            return Order.fromJson(orderData);
          } else if (orderData.containsKey('data') && orderData['data'] is Map<String, dynamic>) {
            print('Parsing order from nested data: ${orderData['data']}');
            return Order.fromJson(orderData['data']);
          }
        }
      }
    }

    print('Failed to parse order - returning null');
    return null;
  }
}
