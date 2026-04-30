import '../../domain/entities/category_entity.dart';

class HomeRepository {
  List<CategoryEntity> getCategories() {
    return const [
      CategoryEntity(id: '1', nameAr: 'فساتين', nameEn: 'Dresses', icon: '👗'),
      CategoryEntity(id: '2', nameAr: 'عبايات', nameEn: 'Abayas', icon: '🖤'),
      CategoryEntity(id: '3', nameAr: 'أحذية', nameEn: 'Shoes', icon: '👠'),
      CategoryEntity(id: '4', nameAr: 'حقائب', nameEn: 'Bags', icon: '👜'),
      CategoryEntity(id: '5', nameAr: 'إكسسوارات', nameEn: 'Accessories', icon: '✨'),
    ];
  }
}
