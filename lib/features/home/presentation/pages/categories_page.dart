import 'package:flutter/material.dart';

import '../../../../core/assets/app_asset_manifest.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/product_entity.dart';

class _SectionConfig {
  const _SectionConfig({
    required this.id,
    required this.assetPrefixes,
    required this.titleKey,
  });

  final String id;
  final List<String> assetPrefixes;
  final String titleKey;
}

const List<_SectionConfig> _kSections = [
  _SectionConfig(
    id: 'tshirt',
    assetPrefixes: ['assets/products/tshirt/'],
    titleKey: 'sectionTshirt',
  ),
  _SectionConfig(
    id: 'polo',
    assetPrefixes: ['assets/products/polo/'],
    titleKey: 'sectionPolo',
  ),
  _SectionConfig(
    id: 'shirt',
    assetPrefixes: ['assets/products/shirt/'],
    titleKey: 'sectionShirt',
  ),
  _SectionConfig(
    id: 'jeans',
    assetPrefixes: ['assets/products/jeans/'],
    titleKey: 'sectionPants',
  ),
  _SectionConfig(
    id: 'tracksuit',
    assetPrefixes: ['assets/products/tracksuit/'],
    titleKey: 'sectionTracksuit',
  ),
  _SectionConfig(
    id: 'mens_accessories',
    assetPrefixes: [
      'assets/products/mens_accessories/',
      'assets/products/accessories/',
    ],
    titleKey: 'sectionMenAccessories',
  ),
];

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({
    super.key,
    required this.onAddToCart,
  });

  final ValueChanged<ProductEntity> onAddToCart;

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<Map<String, List<ProductEntity>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, List<ProductEntity>>> _load() async {
    final map = <String, List<ProductEntity>>{};
    for (final s in _kSections) {
      final merged = <String>[];
      for (final prefix in s.assetPrefixes) {
        merged.addAll(await AppAssetManifest.imagePathsUnder(prefix));
      }
      merged.sort();
      map[s.id] = _groupToProducts(s.id, merged);
    }
    return map;
  }

  List<ProductEntity> _groupToProducts(String sectionId, List<String> paths) {
    final grouped = <String, List<String>>{};
    for (final path in paths) {
      final fileName = path.split('/').last;
      final nameOnly = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;
      final match = RegExp(r'^(\d+)-(\d+)-(.+)$').firstMatch(nameOnly);
      final productNumber = match?.group(1) ?? nameOnly;
      grouped.putIfAbsent(productNumber, () => []).add(path);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => int.tryParse(a)?.compareTo(int.tryParse(b) ?? 0) ?? a.compareTo(b));

    final products = <ProductEntity>[];
    for (final key in sortedKeys) {
      final images = grouped[key]!..sort(_compareByImageIndex);
      final parsed = _parseMeta(images.first);
      products.add(
        ProductEntity(
          id: '$sectionId-$key',
          title: parsed.displayTitle,
          imagePaths: images,
          price: 79 + products.length * 12,
          sectionId: sectionId,
          brand: parsed.brand,
          sku: parsed.sku,
          colorCode: parsed.colorCode,
          colorNameAr: parsed.colorNameAr,
          colorHex: parsed.colorHex,
        ),
      );
    }
    return products;
  }

  int _compareByImageIndex(String a, String b) {
    int parse(String path) {
      final fileName = path.split('/').last;
      final nameOnly = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;
      final m = RegExp(r'^\d+-(\d+)-').firstMatch(nameOnly);
      return int.tryParse(m?.group(1) ?? '0') ?? 0;
    }

    return parse(a).compareTo(parse(b));
  }

  _ProductMeta _parseMeta(String path) {
    final fileName = path.split('/').last;
    final nameOnly = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    final match = RegExp(r'^\d+-\d+-(.+)$').firstMatch(nameOnly);
    final payload = (match?.group(1) ?? nameOnly).toLowerCase();
    final parts = payload.split('-').where((e) => e.isNotEmpty).toList();
    final brand = parts.isNotEmpty ? parts.first : 'brand';
    final sku = parts.length > 1 ? parts[1].toUpperCase() : 'SKU';
    final color = _detectColor(payload);
    return _ProductMeta(
      brand: brand,
      sku: sku,
      colorCode: color?.code,
      colorNameAr: color?.nameAr,
      colorHex: color?.hex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return FutureBuilder<Map<String, List<ProductEntity>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }
        final byPrefix = snapshot.data ?? {};

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: _kSections.length,
          itemBuilder: (context, index) {
            final cfg = _kSections[index];
            final products = byPrefix[cfg.id] ?? [];
            return Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        loc.t(cfg.titleKey),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: products.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => _SectionProductsPage(
                                      sectionTitle: loc.t(cfg.titleKey),
                                      products: products,
                                      onAddToCart: widget.onAddToCart,
                                    ),
                                  ),
                                );
                              },
                        child: Text(loc.t('viewAll')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (products.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        loc.t('noProductsInSection'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.65),
                            ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          return _ProductCard(
                            product: products[i],
                            onAddToCart: widget.onAddToCart,
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onAddToCart,
  });

  final ProductEntity product;
  final ValueChanged<ProductEntity> onAddToCart;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _ProductGalleryPage(
                      product: product,
                      onAddToCart: onAddToCart,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Image.asset(
                    product.coverImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${product.price.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppTheme.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            product.brand.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (product.colorNameAr != null)
            Text(
              '${product.colorNameAr} (${product.colorCode})',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          const SizedBox(height: 6),
          SizedBox(
            height: 30,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                onAddToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.t('addedToCart'))),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.gold),
                foregroundColor: AppTheme.gold,
                padding: EdgeInsets.zero,
              ),
              child: Text(loc.t('addToCart')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGalleryPage extends StatefulWidget {
  const _ProductGalleryPage({
    required this.product,
    required this.onAddToCart,
  });

  final ProductEntity product;
  final ValueChanged<ProductEntity> onAddToCart;

  @override
  State<_ProductGalleryPage> createState() => _ProductGalleryPageState();
}

class _ProductGalleryPageState extends State<_ProductGalleryPage> {
  late final PageController _controller;
  int _current = 0;
  String? _selectedColorCode;
  String _selectedSize = 'M';
  static const List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.90,
      initialPage: 0,
    );
    _selectedColorCode = widget.product.colorCode;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final loc = AppLocalizations.of(context);
    final colorOptions = _colorCatalog;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.title),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 420,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: PageView.builder(
                controller: _controller,
                padEnds: false,
                pageSnapping: true,
                itemCount: p.imagePaths.length,
                onPageChanged: (value) => setState(() => _current = value),
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      double delta = 0;
                      if (_controller.hasClients &&
                          _controller.position.haveDimensions) {
                        delta = ((_controller.page ?? 0) - index).abs();
                      }
                      final scale = (1 - (delta * 0.06)).clamp(0.90, 1.0);
                      return Transform.scale(
                        scale: scale,
                        child: Transform.translate(
                          // Slight overlap for "attached" feel.
                          offset: const Offset(-6, 0),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.gold.withValues(alpha: 0.26),
                            ),
                          ),
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            panEnabled: false,
                            child: Image.asset(
                              p.imagePaths[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          _GalleryDots(
            count: p.imagePaths.length,
            currentIndex: _current,
          ),
          const SizedBox(height: 16),
          Text(
            p.brand.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            p.sku,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              loc.t('filterColor'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colorOptions.map((c) {
                final selected = _selectedColorCode == c.code;
                return ChoiceChip(
                  avatar: CircleAvatar(
                    radius: 8,
                    backgroundColor: _hexToColor(c.hex),
                  ),
                  label: Text('${c.nameAr} ${c.code}'),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedColorCode = c.code),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              loc.t('chooseSize'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sizes
                  .map(
                    (size) => ChoiceChip(
                      label: Text(size),
                      selected: _selectedSize == size,
                      onSelected: (_) => setState(() => _selectedSize = size),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                widget.onAddToCart(widget.product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.t('addedToCart'))),
                );
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(loc.t('addToCart')),
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryDots extends StatelessWidget {
  const _GalleryDots({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == currentIndex ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == currentIndex
                ? AppTheme.gold
                : Theme.of(context).dividerColor.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _SectionProductsPage extends StatelessWidget {
  const _SectionProductsPage({
    required this.sectionTitle,
    required this.products,
    required this.onAddToCart,
  });

  final String sectionTitle;
  final List<ProductEntity> products;
  final ValueChanged<ProductEntity> onAddToCart;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final brands = {
      for (final p in products) p.brand.toLowerCase(),
    }.toList()
      ..sort();
    final colors = {
      for (final p in products)
        if (p.colorCode != null) '${p.colorCode}|${p.colorNameAr}|${p.colorHex}',
    }.toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(title: Text(sectionTitle)),
      body: _SectionProductsFilterView(
        sectionTitle: sectionTitle,
        products: products,
        brands: brands,
        colors: colors,
        onAddToCart: onAddToCart,
        loc: loc,
      ),
    );
  }
}

class _SectionProductsFilterView extends StatefulWidget {
  const _SectionProductsFilterView({
    required this.sectionTitle,
    required this.products,
    required this.brands,
    required this.colors,
    required this.onAddToCart,
    required this.loc,
  });

  final String sectionTitle;
  final List<ProductEntity> products;
  final List<String> brands;
  final List<String> colors;
  final ValueChanged<ProductEntity> onAddToCart;
  final AppLocalizations loc;

  @override
  State<_SectionProductsFilterView> createState() =>
      _SectionProductsFilterViewState();
}

class _SectionProductsFilterViewState extends State<_SectionProductsFilterView> {
  String _brand = '';
  String _color = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.products.where((p) {
      final brandOk = _brand.isEmpty || p.brand.toLowerCase() == _brand;
      final colorOk = _color.isEmpty || (p.colorCode ?? '') == _color;
      return brandOk && colorOk;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.loc.t('filterBrand')),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(widget.loc.t('all')),
                    selected: _brand.isEmpty,
                    onSelected: (_) => setState(() => _brand = ''),
                  ),
                  ...widget.brands.map(
                    (b) => ChoiceChip(
                      label: Text(b.toUpperCase()),
                      selected: _brand == b,
                      onSelected: (_) => setState(() => _brand = b),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(widget.loc.t('filterColor')),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(widget.loc.t('all')),
                    selected: _color.isEmpty,
                    onSelected: (_) => setState(() => _color = ''),
                  ),
                  ...widget.colors.map((raw) {
                    final parts = raw.split('|');
                    final code = parts[0];
                    final nameAr = parts.length > 1 ? parts[1] : code;
                    final hex = parts.length > 2 ? parts[2] : '#111111';
                    return ChoiceChip(
                      avatar: CircleAvatar(
                        radius: 8,
                        backgroundColor: _hexToColor(hex),
                      ),
                      label: Text('$nameAr $code'),
                      selected: _color == code,
                      onSelected: (_) => setState(() => _color = code),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, index) {
              return _ProductCard(
                product: filtered[index],
                onAddToCart: widget.onAddToCart,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductMeta {
  const _ProductMeta({
    required this.brand,
    required this.sku,
    this.colorCode,
    this.colorNameAr,
    this.colorHex,
  });

  final String brand;
  final String sku;
  final String? colorCode;
  final String? colorNameAr;
  final String? colorHex;

  String get displayTitle => '${brand.toUpperCase()} $sku';
}

class _ColorMeta {
  const _ColorMeta(this.code, this.nameAr, this.hex);
  final String code;
  final String nameAr;
  final String hex;
}

const _colorCatalog = <_ColorMeta>[
  _ColorMeta('C.BLK', 'اسود', '#111111'),
  _ColorMeta('C.WHT', 'ابيض', '#FAFAFA'),
  _ColorMeta('C.DNV', 'نيلي', '#091E5B'),
  _ColorMeta('C.RBL', 'ازرق', '#1E3FB5'),
  _ColorMeta('C.BRN', 'جوزي', '#4A2C1D'),
  _ColorMeta('C.BRG', 'ماروني', '#732020'),
  _ColorMeta('C.CHR', 'رصاصي', '#2D2D2D'),
  _ColorMeta('C.TPE', 'توبي', '#8E8475'),
  _ColorMeta('C.OLV', 'زيتوني', '#3D4A2A'),
];

_ColorMeta? _detectColor(String payload) {
  final normalized = payload.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
  for (final c in _colorCatalog) {
    final codeNormalized = c.code.replaceAll('.', '');
    if (normalized.contains(codeNormalized)) {
      return c;
    }
  }
  return null;
}

Color _hexToColor(String hex) {
  final value = hex.replaceAll('#', '');
  return Color(int.parse('FF$value', radix: 16));
}
