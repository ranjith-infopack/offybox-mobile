class Invoice {
  final String id;
  final String invoiceNo;
  final DateTime? invoiceDate;
  final int itemCount;
  final String netAmount;
  final String taxAmount;
  final String totalAmount;
  final String status;
  final String? outletName;
  final String? orderNo;

  Invoice({
    required this.id,
    required this.invoiceNo,
    this.invoiceDate,
    required this.itemCount,
    required this.netAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.status,
    this.outletName,
    this.orderNo,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    // Helper to get nested values safely
    String? getNested(Map<String, dynamic> data, List<String> path) {
      dynamic current = data;
      for (var key in path) {
        if (current is Map && current.containsKey(key)) {
          current = current[key];
        } else {
          return null;
        }
      }
      return current?.toString();
    }

    return Invoice(
      id: json['id']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? json['number']?.toString() ?? '',
      invoiceDate: json['invoice_date'] != null
          ? DateTime.tryParse(json['invoice_date'].toString())
          : null,
      itemCount: json['item_count'] is int ? json['item_count'] : int.tryParse(json['item_count']?.toString() ?? '0') ?? 0,
      netAmount: json['net_amount']?.toString() ?? '0',
      taxAmount: json['tax_amount']?.toString() ?? '0',
      totalAmount: json['total_amount']?.toString() ?? '0',
      status: json['status']?.toString() ?? 'PENDING',
      outletName: getNested(json, ['outlet', 'company_name']) ?? json['outlet_name']?.toString(),
      orderNo: getNested(json, ['order', 'order_no']) ?? json['order_no']?.toString(),
    );
  }

  String get formattedDate {
    if (invoiceDate == null) return '';
    return '${invoiceDate!.day}/${invoiceDate!.month}/${invoiceDate!.year}';
  }
}

class InvoiceListResponse {
  final List<Invoice> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  InvoiceListResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory InvoiceListResponse.fromJson(Map<String, dynamic> json) {
    final List dataList;
    if (json['data'] is List) {
      dataList = json['data'];
    } else if (json['data'] is Map && json['data']['data'] is List) {
      dataList = json['data']['data'];
    } else {
      dataList = [];
    }

    return InvoiceListResponse(
      data: dataList.whereType<Map<String, dynamic>>().map((e) => Invoice.fromJson(e)).toList(),
      page: json['page'] ?? json['current_page'] ?? 1,
      limit: json['limit'] ?? json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? json['last_page'] ?? 1,
    );
  }
}
