import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/cart_state.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/legal_texts.dart';
import '../widgets/info_dialog.dart';

const _orange = Color(0xFFFF6B00);
const _card = Color(0xFF232326);

// Sample data until the catalog (Firestore) section is built.
class _Sport {
  final String label;
  final IconData icon;
  const _Sport(this.label, this.icon);
}

class _Product {
  final String name;
  final String seller;
  final double rating;
  final int price;
  final String? badge; // LIMITED / NEW
  final String image; // asset path, credits in ATTRIBUTIONS.md
  const _Product(this.name, this.seller, this.rating, this.price, this.badge,
      this.image);
}

class _Shop {
  final String name;
  final String subtitle;
  final double rating;
  final String tag;
  final Color color;
  const _Shop(this.name, this.subtitle, this.rating, this.tag, this.color);
}

const _sports = [
  _Sport('CRICKET', Icons.sports_cricket),
  _Sport('FOOTBALL', Icons.sports_soccer),
  _Sport('OTHERS', Icons.more_horiz),
];

const _products = [
  _Product('Retro 90s Classic Kit', 'Windy City Vintage', 4.9, 4500, 'LIMITED',
      'assets/images/jerseys/retro_classic.jpg'),
  _Product('Midnight Away Kit', 'Camp Nou Originals', 4.7, 3800, 'NEW',
      'assets/images/jerseys/midnight_away.jpg'),
  _Product('City Edition 2025', 'Hoops Hub', 4.8, 5200, null,
      'assets/images/jerseys/city_edition.jpg'),
  _Product('Home Kit 24/25', 'Euro Elite', 4.6, 3500, 'NEW',
      'assets/images/jerseys/home_kit.jpg'),
];

const _shops = [
  _Shop('TEAM USA STORE', 'OFFICIAL GEAR', 4.9, 'Trusted Merchant',
      Color(0xFF14233F)),
  _Shop('EURO ELITE', 'PREMIER LEAGUE KITS', 4.8, 'Verified Club',
      Color(0xFF2A1A33)),
];

class HomeContent extends StatefulWidget {
  /// Switches the bottom-nav tab (0 Home, 1 Explore, 2 Hot, 3 Cart, 4 Profile).
  final void Function(int)? onNavigate;
  const HomeContent({super.key, this.onNavigate});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final Set<int> _wishlisted = {};

  void _go(int tab) => widget.onNavigate?.call(tab);

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121214),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildHero(),
            _buildSports(),
            _buildSectionTitle('TRENDING NOW',
                action: 'VIEW ALL', onAction: () => _go(1)),
            _buildTrending(),
            _buildSectionTitle('FEATURED SHOPS', accent: _orange),
            ..._shops.map(_buildShop),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── header & search ─────────────────────────

  Widget _buildHeader(BuildContext context) {
    final name = AuthService().currentUser?.displayName?.trim() ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            // Opens the drawer of the surrounding MainShell scaffold.
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          const Text(
            'JERSEY',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.5,
            ),
          ),
          const Text(
            'HUB',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _snack('Notifications are coming soon'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none,
                    color: Colors.white, size: 26),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: _orange,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF121214), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => _go(4),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.primary.withValues(alpha: 0.25),
              child: name.isEmpty
                  ? const Icon(Icons.person_outline,
                      size: 20, color: AppColors.primary)
                  : Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: GestureDetector(
        onTap: () => _go(1), // search lives on the Explore tab
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[500], size: 22),
              const SizedBox(width: 12),
              Text(
                'Search by player, team, or league',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── hero ─────────────────────────

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 210,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/kimmich.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.25),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'SEASON DEALS',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '30% OFF ON\nCLASSIC KITS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () => _go(1),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text(
                    'SHOP COLLECTION',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  iconAlignment: IconAlignment.end,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F8EFF),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: const Color(0xFF4F8EFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── sports chips ─────────────────────────

  Widget _buildSports() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [for (final sport in _sports) _buildSportChip(sport)],
      ),
    );
  }

  Widget _buildSportChip(_Sport sport) {
    final isOthers = sport.label == 'OTHERS';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Explore will filter by sport once the catalog exists.
      onTap: () => isOthers ? _snack('Other sports are coming soon') : _go(1),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(sport.icon, color: Colors.white70, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            sport.label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── sections ─────────────────────────

  Widget _buildSectionTitle(
    String title, {
    String? action,
    VoidCallback? onAction,
    Color accent = AppColors.primary,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(
                    action,
                    style: const TextStyle(
                      color: Color(0xFF4F8EFF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFF4F8EFF), size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrending() {
    return SizedBox(
      height: 350,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _buildProductCard(i, _products[i]),
      ),
    );
  }

  Widget _buildProductCard(int index, _Product p) {
    final liked = _wishlisted.contains(index);
    return Container(
      width: 235,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  p.image,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (p.badge != null)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: p.badge == 'LIMITED'
                          ? const Color(0xFF4F8EFF)
                          : Colors.black54,
                      borderRadius: BorderRadius.circular(5),
                      border: p.badge == 'NEW'
                          ? Border.all(color: Colors.white70)
                          : null,
                    ),
                    child: Text(
                      p.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () => setState(() {
                    liked ? _wishlisted.remove(index) : _wishlisted.add(index);
                  }),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? const Color(0xFFFF453A) : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            p.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  p.seller,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Color(0xFFFFB84D), size: 13),
              const SizedBox(width: 2),
              Text(
                p.rating.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '৳${_formatPrice(p.price)}',
                style: const TextStyle(
                  color: Color(0xFF4F8EFF),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              GestureDetector(
                onTap: () {
                  cartItemCount.value++;
                  _snack('${p.name} added to cart');
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E32),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_shopping_cart,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    return s.length > 3 ? '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}' : s;
  }

  Widget _buildShop(_Shop shop) {
    return GestureDetector(
      onTap: () => _snack('${shop.name} store page is coming soon'),
      child: Container(
        height: 140,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [shop.color, const Color(0xFF0E0E10)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  shop.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.verified,
                    color: Color(0xFF4F8EFF), size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              shop.subtitle,
              style: const TextStyle(
                color: Color(0xFF4F8EFF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_border,
                      color: Color(0xFFFFB84D), size: 15),
                  const SizedBox(width: 4),
                  Text(
                    '${shop.rating} ${shop.tag}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── legal footer ─────────────────────────

  Widget _buildFooter() {
    void info(String title, String content) =>
        InfoDialog.show(context, title, content);

    Widget link(String text, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        children: [
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'JERSEY',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'HUB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your marketplace for authentic jerseys from trusted sellers.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              link(
                'About Us',
                () => info(
                  'About Us',
                  'JerseyHub is a marketplace for authentic sports jerseys '
                      'from trusted sellers.\n\n${AppConstants.tagline}.',
                ),
              ),
              link(AppConstants.termsOfService,
                  () => info(AppConstants.termsOfService, LegalTexts.termsOfService)),
              link(AppConstants.privacyPolicy,
                  () => info(AppConstants.privacyPolicy, LegalTexts.privacyPolicy)),
              link('Help & Support',
                  () => info('Help & Support', LegalTexts.helpCenter)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '© 2026 ${AppConstants.appName} • v1.0.0',
            style: TextStyle(color: Colors.grey[700], fontSize: 11),
          ),
        ],
      ),
    );
  }
}
