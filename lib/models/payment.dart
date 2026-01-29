class Payment {
  final String id;
  final String paymentNo;
  final DateTime? paymentDate;
  final String ledgerName;
  final String amount;
  final String paymentMode;
  final String? referenceNo;
  final String status;

  Payment({
    required this.id,
    required this.paymentNo,
    this.paymentDate,
    required this.ledgerName,
    required this.amount,
    required this.paymentMode,
    this.referenceNo,
    required this.status,
  });

  factory Payment.fromJson(dynamic json) {
    if (json == null || json is! Map) {
      return Payment(
        id: '',
        paymentNo: '',
        ledgerName: '-',
        amount: '0',
        paymentMode: '-',
        status: 'PENDING',
      );
    }
    
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);

    // Helper to get nested values safely
    String? getNested(Map<String, dynamic> d, List<String> path) {
      dynamic current = d;
      for (var key in path) {
        if (current is Map && current.containsKey(key)) {
          current = current[key];
        } else {
          return null;
        }
      }
      return current?.toString();
    }

    return Payment(
      id: data['id']?.toString() ?? '',
      paymentNo: data['payment_no']?.toString() ?? data['number']?.toString() ?? '',
      paymentDate: data['payment_date'] != null
          ? DateTime.tryParse(data['payment_date'].toString())
          : null,
      ledgerName: getNested(data, ['outlet', 'company_name']) ?? 
                  data['ledger_name']?.toString() ?? 
                  data['outlet_name']?.toString() ?? '-',
      amount: (data['amount'] ?? data['net_amount'] ?? '0').toString(),
      paymentMode: data['payment_mode']?.toString() ?? data['mode']?.toString() ?? '-',
      referenceNo: data['reference_no']?.toString() ?? data['reference']?.toString(),
      status: data['status']?.toString() ?? 'PENDING',
    );
  }

  String get formattedDate {
    if (paymentDate == null) return '';
    return '${paymentDate!.day}/${paymentDate!.month}/${paymentDate!.year}';
  }
}

class PaymentListResponse {
  final List<Payment> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaymentListResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaymentListResponse.fromJson(dynamic json) {
    if (json == null) {
      return PaymentListResponse(data: [], page: 1, limit: 10, total: 0, totalPages: 1);
    }

    List dataList = [];
    Map<String, dynamic> rootMap = {};

    if (json is List) {
      dataList = json;
    } else if (json is Map) {
      rootMap = Map<String, dynamic>.from(json);
      if (rootMap['data'] is List) {
        dataList = rootMap['data'];
      } else if (rootMap['data'] is Map && rootMap['data']['data'] is List) {
        dataList = rootMap['data']['data'];
      }
    }

    return PaymentListResponse(
      data: dataList.map((e) => Payment.fromJson(e)).toList(),
      page: rootMap['page'] ?? rootMap['current_page'] ?? 1,
      limit: rootMap['limit'] ?? rootMap['per_page'] ?? 10,
      total: rootMap['total'] ?? 0,
      totalPages: rootMap['total_pages'] ?? rootMap['last_page'] ?? 1,
    );
  }
}
