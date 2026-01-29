class Product {
  final String id;
  final String code;
  final String name;
  final String? categoryName;
  final String? brandName;
  final String? hsn;
  final String? unit;
  final String mrp;
  final String sellingPrice;
  final String stock;
  final String status;
  final String? taxRate;

  Product({
    required this.id,
    required this.code,
    required this.name,
    this.categoryName,
    this.brandName,
    this.hsn,
    this.unit,
    required this.mrp,
    required this.sellingPrice,
    required this.stock,
    required this.status,
    this.taxRate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      categoryName: json['category'] != null ? json['category']['name']?.toString() : json['category_name']?.toString(),
      brandName: json['brand'] != null ? json['brand']['name']?.toString() : json['brand_name']?.toString(),
      hsn: json['hsn']?.toString(),
      unit: json['unit']?.toString() ?? json['unit_name']?.toString(),
      mrp: json['mrp']?.toString() ?? '0',
      sellingPrice: json['sale_price']?.toString() ?? json['price']?.toString() ?? '0',
      stock: json['stock']?.toString() ?? '0',
      status: json['status']?.toString() ?? 'ACTIVE',
      taxRate: json['tax_rate']?.toString() ?? json['tax_rate_percent']?.toString() ?? '0',
    );
  }
}
