import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockify/screens/movementsScreen.dart';
import 'package:stockify/screens/profileScreen.dart';
import 'package:stockify/screens/welcome.dart';
import '../models/movementModel.dart';
import '../models/productModel.dart';
import '../services/authService.dart';
import '../services/companyService.dart';
import '../services/movementServices.dart';
import '../services/productService.dart';
import 'productsScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  ProductFilter _productsInitialFilter = ProductFilter.all;
  final AuthService _authService = AuthService();
  final CompanyService _companyService = CompanyService();

  void _navigateToProducts({ProductFilter filter = ProductFilter.all}) {
    setState(() {
      _productsInitialFilter = filter;
      _currentIndex = 1;
    });
  }

  void _showCompanyInfoDialog(BuildContext context) async {
    final company = await _companyService.getCurrentCompany();
    if (!context.mounted) return;

    if (company == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível carregar os dados da empresa.')),
      );
      return;
    }

    final String name = company['companyName'] ?? company['name'] ?? 'Empresa';
    final String inviteCode = company['inviteCode'] ?? '------';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181524),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Compartilhe este código para outras pessoas entrarem na sua empresa:',
                style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0B14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF262135)),
                ),
                child: Text(
                  inviteCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar', style: TextStyle(color: Color(0xFFA1A1AA))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: inviteCode));
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Código copiado!')),
                );
              },
              child: const Text('Copiar código', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181524),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF262135),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded, color: Color(0xFF8B5CF6)),
                  title: const Text('Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business_center_outlined, color: Color(0xFF8B5CF6)),
                  title: const Text('Minha Empresa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showCompanyInfoDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: Color(0xFF8B5CF6)),
                  title: const Text('Configurações', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tela de Configurações em desenvolvimento.'),
                        backgroundColor: Color(0xFF181524),
                      ),
                    );
                  },
                ),
                const Divider(color: Color(0xFF262135)),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text('Sair', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _authService.logout();

                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                            (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _DashboardHomeBody(
        onNavigateToProducts: _navigateToProducts,
      ),
      ProductsScreen(
        key: ValueKey(_productsInitialFilter),
        initialFilter: _productsInitialFilter,
      ),
      const MovementsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B14),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            _showMoreMenu(context);
          } else {
            setState(() {
              if (index == 1) {
                _productsInitialFilter = ProductFilter.all;
              }
              _currentIndex = index;
            });
          }
        },
        backgroundColor: const Color(0xFF181524),
        selectedItemColor: const Color(0xFF8B5CF6),
        unselectedItemColor: const Color(0xFFA1A1AA),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Produtos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_vert_rounded),
            label: 'Mov.',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_rounded),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
}

class _DashboardHomeBody extends StatelessWidget {
  final Function({ProductFilter filter}) onNavigateToProducts;

  const _DashboardHomeBody({required this.onNavigateToProducts});

  @override
  Widget build(BuildContext context) {
    final ProductService productService = ProductService();
    final MovementService movementService = MovementService();
    final user = FirebaseAuth.instance.currentUser;
    final String username = user?.displayName ?? 'Usuário';
    final String initialLetter = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return SafeArea(
      child: StreamBuilder<List<Product>>(
        stream: productService.getProductsStream(),
        builder: (context, snapshotProducts) {
          if (snapshotProducts.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            );
          }

          final products = snapshotProducts.data ?? [];

          final totalProducts = products.length;
          final lowStockCount =
              products.where((p) => p.quantity <= p.minQuantity).length;
          final double totalValue = products.fold(
            0.0,
                (sum, item) => sum + (item.price * item.quantity),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, $username',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Veja como está seu estoque.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFA1A1AA),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF8B5CF6),
                        child: Text(
                          initialLetter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Card Valor Total do Estoque
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181524),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF262135)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Valor do estoque',
                        style: TextStyle(fontSize: 14, color: Color(0xFFA1A1AA)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'R\$ ${totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onNavigateToProducts(filter: ProductFilter.all),
                        child: _buildStatCard(
                          value: '$totalProducts',
                          label: 'Produtos',
                          accentColor: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onNavigateToProducts(filter: ProductFilter.lowStock),
                        child: _buildStatCard(
                          value: '$lowStockCount',
                          label: 'Estoque baixo',
                          accentColor: Colors.amberAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => onNavigateToProducts(filter: ProductFilter.all),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF262135)),
                      backgroundColor: const Color(0xFF181524),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.inventory_2_outlined, color: Color(0xFF8B5CF6), size: 18),
                    label: const Text(
                      'Ver todos os produtos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Movimentações recentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                StreamBuilder<List<Movement>>(
                  stream: movementService.getRecentMovementsStream(),
                  builder: (context, snapshotMovements) {
                    if (snapshotMovements.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                        ),
                      );
                    }

                    final movements = snapshotMovements.data ?? [];

                    if (movements.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Nenhuma movimentação registrada.',
                          style: TextStyle(color: Color(0xFFA1A1AA)),
                        ),
                      );
                    }

                    return Column(
                      children: movements.map((m) {
                        final isEntry = m.type == 'Entrada';
                        final quantityText =
                            '${isEntry ? '+' : '-'}${m.quantity}';

                        return _buildMovementItem(
                          title: m.productName,
                          type: m.type,
                          quantity: quantityText,
                          isEntry: isEntry,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF181524),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF262135)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFA1A1AA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementItem({
    required String title,
    required String type,
    required String quantity,
    required bool isEntry,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF181524),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isEntry
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            child: Icon(
              isEntry ? Icons.arrow_downward : Icons.arrow_upward,
              color: isEntry ? Colors.greenAccent : Colors.redAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  type,
                  style: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            quantity,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isEntry ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}