class Outlet {
  final String id;
  final String companyName;
  final String? email;
  final String? phone;
  final String? mobile;
  final String creditLimit;
  final String outstanding;
  final String? outletType;
  final String status;
  final String? gstn;
  final String? outletCategoryId;
  final String? salesPersonId;
  final OutletCategory? outletCategory;
  final SalesPerson? salesPerson;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Addresses array
  final List<OutletAddress> addresses;
  
  // Contact person fields
  final String? contactPersonName;
  final String? contactPersonPhone;
  final String? contactPersonEmail;
  final String? contactPersonDesignation;

  Outlet({
    required this.id,
    required this.companyName,
    this.email,
    this.phone,
    this.mobile,
    required this.creditLimit,
    required this.outstanding,
    this.outletType,
    required this.status,
    this.gstn,
    this.outletCategoryId,
    this.salesPersonId,
    this.outletCategory,
    this.salesPerson,
    this.createdAt,
    this.updatedAt,
    this.addresses = const [],
    this.contactPersonName,
    this.contactPersonPhone,
    this.contactPersonEmail,
    this.contactPersonDesignation,
  });

  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      id: json['id'] ?? '',
      companyName: json['company_name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      mobile: json['mobile'],
      creditLimit: json['credit_limit'] ?? '0',
      outstanding: json['outstanding'] ?? '0',
      outletType: json['outlet_type'],
      status: json['status'] ?? '',
      gstn: json['gstn'],
      outletCategoryId: json['outlet_category_id'],
      salesPersonId: json['sales_person_id'],
      outletCategory: json['outlet_category'] != null
          ? OutletCategory.fromJson(json['outlet_category'])
          : null,
      salesPerson: json['sales_person'] != null
          ? SalesPerson.fromJson(json['sales_person'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      // Addresses array
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => OutletAddress.fromJson(e))
              .toList() ??
          [],
      // Contact person
      contactPersonName: json['contact_person_name'] ?? json['contact_name'],
      contactPersonPhone: json['contact_person_phone'] ?? json['contact_phone'],
      contactPersonEmail: json['contact_person_email'] ?? json['contact_email'],
      contactPersonDesignation: json['contact_person_designation'] ?? json['contact_designation'],
    );
  }

  // Get billing address
  OutletAddress? get billingAddress {
    try {
      return addresses.firstWhere((a) => a.type.toLowerCase() == 'billing');
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  // Get shipping address
  OutletAddress? get shippingAddress {
    try {
      return addresses.firstWhere((a) => a.type.toLowerCase() == 'shipping');
    } catch (_) {
      return null;
    }
  }

  bool get hasAddresses => addresses.isNotEmpty;

  bool get hasContactPerson =>
      (contactPersonName != null && contactPersonName!.isNotEmpty) ||
      (contactPersonPhone != null && contactPersonPhone!.isNotEmpty) ||
      (contactPersonEmail != null && contactPersonEmail!.isNotEmpty);
}

class OutletAddress {
  final String id;
  final String type;
  final String? name;
  final String? address1;
  final String? address2;
  final String? pincode;
  final String? countryId;
  final String? stateId;
  final String? cityId;
  final String status;

  OutletAddress({
    required this.id,
    required this.type,
    this.name,
    this.address1,
    this.address2,
    this.pincode,
    this.countryId,
    this.stateId,
    this.cityId,
    required this.status,
  });

  factory OutletAddress.fromJson(Map<String, dynamic> json) {
    return OutletAddress(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      name: json['name'],
      address1: json['address1'],
      address2: json['address2'],
      pincode: json['pincode'],
      countryId: json['country_id'],
      stateId: json['state_id'],
      cityId: json['city_id'],
      status: json['status'] ?? '',
    );
  }

  String get fullAddress {
    final parts = <String>[];
    if (address1 != null && address1!.isNotEmpty) parts.add(address1!);
    if (address2 != null && address2!.isNotEmpty) parts.add(address2!);
    if (pincode != null && pincode!.isNotEmpty) parts.add(pincode!);
    return parts.join(', ');
  }

  bool get hasAddress => fullAddress.isNotEmpty;
}

class OutletCategory {
  final String id;
  final String name;
  final String status;

  OutletCategory({
    required this.id,
    required this.name,
    required this.status,
  });

  factory OutletCategory.fromJson(Map<String, dynamic> json) {
    return OutletCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class SalesPerson {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String code;

  SalesPerson({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.code,
  });

  factory SalesPerson.fromJson(Map<String, dynamic> json) {
    return SalesPerson(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      code: json['code'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName';
}

class OutletListResponse {
  final List<Outlet> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  OutletListResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory OutletListResponse.fromJson(Map<String, dynamic> json) {
    return OutletListResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Outlet.fromJson(e))
              .toList() ??
          [],
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}
