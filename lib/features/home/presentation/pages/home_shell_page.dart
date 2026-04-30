import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/product_entity.dart';
import 'cart_page.dart';
import 'categories_page.dart';
import 'home_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onLanguageToggle,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onLanguageToggle;

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<ProductEntity> _cartItems = [];
  int _selectedIndex = 0;

  void _onBottomTap(int index) {
    if (index == 4) {
      _scaffoldKey.currentState?.openDrawer();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _addToCart(ProductEntity product) {
    setState(() => _cartItems.add(product));
  }

  void _removeFromCart(ProductEntity product) {
    setState(() => _cartItems.remove(product));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final pages = <Widget>[
      const HomePage(),
      _SimpleSection(title: loc.t('favorites'), icon: Icons.favorite_border),
      CartPage(
        items: _cartItems,
        onShopNow: () => setState(() => _selectedIndex = 3),
        onRemoveItem: _removeFromCart,
      ),
      CategoriesPage(onAddToCart: _addToCart),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Image.asset(
          'assets/sizeme_logo.png',
          height: 34,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Text(
            'Sizeme',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ),
      drawer: _AppDrawer(
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
        onLanguageToggle: widget.onLanguageToggle,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: _BottomIconBar(
        selectedIndex: _selectedIndex,
        onTap: _onBottomTap,
      ),
    );
  }
}

class _BottomIconBar extends StatelessWidget {
  const _BottomIconBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B1B1B) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavIcon(
                  index: 0,
                  selectedIndex: selectedIndex,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_outlined,
                  onTap: () => onTap(0),
                ),
                _NavIcon(
                  index: 1,
                  selectedIndex: selectedIndex,
                  icon: Icons.favorite_border_rounded,
                  activeIcon: Icons.favorite_outline_rounded,
                  onTap: () => onTap(1),
                ),
                _NavIcon(
                  index: 2,
                  selectedIndex: selectedIndex,
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag_outlined,
                  onTap: () => onTap(2),
                ),
                _NavIcon(
                  index: 3,
                  selectedIndex: selectedIndex,
                  icon: Icons.grid_view_rounded,
                  activeIcon: Icons.grid_view_rounded,
                  onTap: () => onTap(3),
                ),
                _NavIcon(
                  index: 4,
                  selectedIndex: selectedIndex,
                  icon: Icons.menu_rounded,
                  activeIcon: Icons.menu_rounded,
                  onTap: () => onTap(4),
                  forceInactive: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.activeIcon,
    required this.onTap,
    this.forceInactive = false,
  });

  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData activeIcon;
  final VoidCallback onTap;
  final bool forceInactive;

  @override
  Widget build(BuildContext context) {
    final active = !forceInactive && selectedIndex == index;
    final base = Theme.of(context).iconTheme.color ?? Colors.black;
    final color = active ? AppTheme.gold : base.withValues(alpha: 0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            active ? activeIcon : icon,
            size: 22,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _SimpleSection extends StatelessWidget {
  const _SimpleSection({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: AppTheme.gold),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onLanguageToggle,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onLanguageToggle;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: AppTheme.gold.withValues(alpha: 0.4)),
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/sizeme_logo.png',
                height: 44,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(
                  'Sizeme',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(loc.t('drawerAccount')),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: Text(loc.t('drawerOrders')),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(loc.t('drawerSettings')),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.straighten_outlined),
            title: Text(loc.t('drawerSizeGuide')),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: Text(loc.t('drawerShippingInfo')),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(loc.t('drawerLanguage')),
            onTap: () {
              onLanguageToggle();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1_outlined),
            title: Text(loc.t('drawerCreateAccount')),
            onTap: () => Navigator.pop(context),
          ),
          SwitchListTile(
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: isDarkMode,
            title: Text(loc.t('darkMode')),
            onChanged: (_) {
              onThemeToggle();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(loc.t('drawerHelp')),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
