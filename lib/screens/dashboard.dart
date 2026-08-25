import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/movementModel.dart';
import '../models/productModel.dart';
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

  // Lista de telas que correspondem aos itens da barra inferior
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _DashboardHomeBody(), // Widget com o conteúdo da Dashboard principal
      const ProductsScreen(),      // Tela de Produtos na posição index 1
      const Center(child: Text('Tela de Movimentações', style: TextStyle(color: Colors.white))), // Exemplo para index 2
      const Center(child: Text('Mais Opções', style: TextStyle(color: Colors.white))),             // Exemplo para index 3
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B14),
      // O body troca de tela de acordo com o index selecionado
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Atualiza o índice para trocar a tela
          });
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

// Widget privado contendo todo o conteúdo original do seu início/dashboard
class _DashboardHomeBody extends StatelessWidget {
  const _DashboardHomeBody();

  @override
  Widget build(BuildContext context) {
    final ProductService productService = ProductService();
    final MovementService movementService = MovementService();
    final String username =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Usuário';

    return SafeArea(
      child: StreamBuilder<List<Product>>(
        stream: productService.getProductsStream(),
        builder: (context, snapshotProducts) {
          if (snapshotProducts.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                // Cabeçalho
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
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 28,
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

                // Cards Menores
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        value: '$totalProducts',
                        label: 'Produtos',
                        accentColor: const Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        value: '$lowStockCount',
                        label: 'Estoque baixo',
                        accentColor: Colors.amberAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Seção de Movimentações Recentes
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
                      return const Center(child: CircularProgressIndicator());
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

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {},
                    label: const Text(
                      'Ver tudo',
                      style: TextStyle(color: Color(0xFF8B5CF6)),
                    ),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
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