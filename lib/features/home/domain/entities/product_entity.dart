class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.title,
    required this.imagePaths,
    required this.price,
    required this.sectionId,
    required this.brand,
    required this.sku,
    this.colorCode,
    this.colorNameAr,
    this.colorHex,
  });

  final String id;
  final String title;
  final List<String> imagePaths;
  final double price;
  final String sectionId;
  final String brand;
  final String sku;
  final String? colorCode;
  final String? colorNameAr;
  final String? colorHex;

  String get coverImage => imagePaths.first;
}
