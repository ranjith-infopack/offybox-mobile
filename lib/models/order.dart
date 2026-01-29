class Order {
  final String id;
  final String orderNo;
  final DateTime? orderDate;
  final int itemCount;
  final String netAmount;
  final String discountAmount;
  final String taxAmount;
  final String totalAmount;
  final String roundOffAmount;
  final String orderType;
  final String orderStatus;
  final String? billingAddressId;
  final String? shippingAddressId;
  final String? outletId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final OrderOutlet? outlet;
  final OrderAddress? billingAddress;
  final OrderAddress? shippingAddress;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.orderNo,
    this.orderDate,
    required this.itemCount,
    required this.netAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.roundOffAmount,
    required this.orderType,
    required this.orderStatus,
    this.billingAddressId,
    this.shippingAddressId,
    this.outletId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.outlet,
    this.billingAddress,
    this.shippingAddress,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      orderNo: json['order_no']?.toString() ?? '',
      orderDate: json['order_date'] != null
          ? DateTime.tryParse(json['order_date'].toString())
          : null,
      itemCount: json['item_count'] is int ? json['item_count'] : int.tryParse(json['item_count']?.toString() ?? '0') ?? 0,
      netAmount: json['net_amount']?.toString() ?? '0',
      discountAmount: json['discount_amount']?.toString() ?? '0',
      taxAmount: json['tax_amount']?.toString() ?? '0',
      totalAmount: json['total_amount']?.toString() ?? '0',
      roundOffAmount: json['round_off_amount']?.toString() ?? '0',
      orderType: json['order_type']?.toString() ?? '',
      orderStatus: json['order_status']?.toString() ?? '',
      billingAddressId: json['billing_address_id']?.toString(),
      shippingAddressId: json['shipping_address_id']?.toString(),
      outletId: json['outlet_id']?.toString(),
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      outlet: json['outlet'] != null
          ? OrderOutlet.fromJson(json['outlet'])
          : null,
      billingAddress: json['billing_address'] != null
          ? OrderAddress.fromJson(json['billing_address'])
          : null,
      shippingAddress: json['shipping_address'] != null
          ? OrderAddress.fromJson(json['shipping_address'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : null,
    );
  }

  String get formattedDate {
    if (orderDate == null) return '';
    return '${orderDate!.day} ${_monthName(orderDate!.month)} ${orderDate!.year}';
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String get formattedTotalAmount {
    final amount = double.tryParse(totalAmount) ?? 0;
    return '₹${amount.toStringAsFixed(2)}';
  }
}

class OrderOutlet {
  final String id;
  final String companyName;
  final String? email;

  OrderOutlet({
    required this.id,
    required this.companyName,
    this.email,
  });

  factory OrderOutlet.fromJson(Map<String, dynamic> json) {
    return OrderOutlet(
      id: json['id'] ?? '',
      companyName: json['company_name'] ?? '',
      email: json['email'],
    );
  }
}

class OrderAddress {
  final String id;
  final String? name;
  final String? address1;
  final String? address2;
  final String? pincode;
  final String? city;
  final String? state;

  OrderAddress({
    required this.id,
    this.name,
    this.address1,
    this.address2,
    this.pincode,
    this.city,
    this.state,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      address1: json['address1']?.toString() ?? json['address_line_1']?.toString(),
      address2: json['address2']?.toString() ?? json['address_line_2']?.toString(),
      pincode: json['pincode']?.toString(),
      city: json['city'] is Map ? json['city']['name']?.toString() : json['city']?.toString(),
      state: json['state'] is Map ? json['state']['name']?.toString() : json['state']?.toString(),
    );
  }

  String get fullAddress {
    final parts = <String>[];
    if (address1 != null && address1!.isNotEmpty) parts.add(address1!);
    if (address2 != null && address2!.isNotEmpty) parts.add(address2!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (pincode != null && pincode!.isNotEmpty) parts.add(pincode!);
    return parts.join(', ');
  }
}

class OrderItem {
  final String id;
  final String? productId;
  final String? productName;
  final int quantity;
  final String price;
  final String amount;
  final String? discountAmount;
  final String? taxAmount;
  final String? totalAmount;

  OrderItem({
    required this.id,
    this.productId,
    this.productName,
    required this.quantity,
    required this.price,
    required this.amount,
    this.discountAmount,
    this.taxAmount,
    this.totalAmount,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString(),
      productName: json['product'] != null 
          ? json['product']['name']?.toString() 
          : json['product_name']?.toString(),
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      price: json['price']?.toString() ?? '0',
      amount: json['amount']?.toString() ?? '0',
      discountAmount: json['discount_amount']?.toString(),
      taxAmount: json['tax_amount']?.toString(),
      totalAmount: json['total_amount']?.toString(),
    );
  }

  String get formattedPrice => '₹${(double.tryParse(price) ?? 0).toStringAsFixed(2)}';
  String get formattedAmount => '₹${(double.tryParse(totalAmount ?? amount) ?? 0).toStringAsFixed(2)}';
}

class OrderListResponse {
  final List<Order> data;
  final int page;
  final int limit;
  final int total;

  OrderListResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      data: (json['data'] as List? ?? [])
          .map((item) => Order.fromJson(item))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}
