import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String username =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Usuário';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B14),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA1A1AA),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'R\$ 24.850,00',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.greenAccent,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '8,4% este mês',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      value: '128',
                      label: 'Produtos',
                      accentColor: const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      value: '12',
                      label: 'Estoque baixo',
                      accentColor: Colors.amberAccent,
                    ),
                  ),
                ],
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

              _buildMovementItem(
                title: 'Teclado Mecânico',
                type: 'Entrada',
                quantity: '+20',
                isEntry: true,
              ),
              _buildMovementItem(
                title: 'Mouse Logitech',
                type: 'Saída',
                quantity: '-5',
                isEntry: false,
              ),
              _buildMovementItem(
                title: 'Monitor 24"',
                type: 'Entrada',
                quantity: '+10',
                isEntry: true,
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
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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