import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final loc = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return loc!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'appName': 'سايزمي',
      'home': 'الرئيسية',
      'favorites': 'المفضلة',
      'cart': 'السلة',
      'categories': 'الفئات',
      'menu': 'القائمة',
      'welcome': 'أناقة فاخرة.. مصممة لك',
      'subtitle': 'اكتشف أحدث صيحات الموضة بجودة عالية ولمسة ذهبية.',
      'featured': 'مختارات مميزة',
      'newCollection': 'تشكيلة جديدة',
      'viewAll': 'عرض الكل',
      'darkMode': 'الوضع الليلي',
      'offers': 'عروض اليوم',
      'drawerAccount': 'حسابي',
      'drawerOrders': 'طلباتي',
      'drawerSettings': 'الإعدادات',
      'drawerHelp': 'المساعدة',
      'drawerSizeGuide': 'حاسبة المقاسات',
      'drawerShippingInfo': 'معلومات الشحن',
      'drawerLanguage': 'تغيير اللغة',
      'drawerCreateAccount': 'إنشاء حساب',
      'cartEmptyTitle': 'السلة فارغة',
      'cartEmptySubtitle': 'قم بالتسوق الآن',
      'cartShopNowCta': 'تصفح المنتجات',
      'sectionTshirt': 'تي شيرت',
      'sectionPolo': 'بولو',
      'sectionShirt': 'قميص',
      'sectionPants': 'بنطلون',
      'sectionTracksuit': 'تراكسوت',
      'sectionMenAccessories': 'إكسسوارات رجالية',
      'noProductsInSection': 'لا توجد صور في هذا القسم بعد.',
      'addToCart': 'أضف للسلة',
      'addedToCart': 'تمت إضافة المنتج إلى السلة',
      'productsCount': 'عدد المنتجات',
      'removeFromCart': 'حذف من السلة',
      'cartTotal': 'الإجمالي',
      'filterBrand': 'فلتر الماركة',
      'filterColor': 'فلتر اللون',
      'all': 'الكل',
      'chooseSize': 'اختر القياس',
    },
    'en': {
      'appName': 'Sizeme',
      'home': 'Home',
      'favorites': 'Favorites',
      'cart': 'Cart',
      'categories': 'Categories',
      'menu': 'Menu',
      'welcome': 'Luxury style, tailored for you',
      'subtitle': 'Discover premium fashion with elegant golden accents.',
      'featured': 'Featured Picks',
      'newCollection': 'New Collection',
      'viewAll': 'View all',
      'darkMode': 'Dark mode',
      'offers': 'Today Offers',
      'drawerAccount': 'My Account',
      'drawerOrders': 'My Orders',
      'drawerSettings': 'Settings',
      'drawerHelp': 'Help',
      'drawerSizeGuide': 'Size Guide',
      'drawerShippingInfo': 'Shipping Info',
      'drawerLanguage': 'Change Language',
      'drawerCreateAccount': 'Create Account',
      'cartEmptyTitle': 'Your cart is empty',
      'cartEmptySubtitle': 'Start shopping now',
      'cartShopNowCta': 'Browse products',
      'sectionTshirt': 'T‑Shirts',
      'sectionPolo': 'Polo',
      'sectionShirt': 'Shirts',
      'sectionPants': 'Pants',
      'sectionTracksuit': 'Tracksuits',
      'sectionMenAccessories': "Men's accessories",
      'noProductsInSection': 'No images in this section yet.',
      'addToCart': 'Add to cart',
      'addedToCart': 'Product added to cart',
      'productsCount': 'Products',
      'removeFromCart': 'Remove',
      'cartTotal': 'Total',
      'filterBrand': 'Brand filter',
      'filterColor': 'Color filter',
      'all': 'All',
      'chooseSize': 'Choose size',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
