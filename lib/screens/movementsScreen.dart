import 'package:flutter/material.dart';
import '../models/movementModel.dart';
import '../models/productModel.dart';
import '../services/movementServices.dart';
import '../services/productService.dart';

class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  final MovementService _movementService = MovementService();
  final ProductService _productService = ProductService();

  void _openAddMovementModal(BuildContext context) {
    Product? selectedProduct;
    String movementType = 'Entrada';
    final quantityController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181524),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nova Movimentação',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close, color: Color(0xFFA1A1AA)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(
                                child: Text(
                                  'Entrada',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              selected: movementType == 'Entrada',
                              selectedColor: Colors.green.withOpacity(0.2),
                              side: BorderSide(
                                color: movementType == 'Entrada'
                                    ? Colors.greenAccent
                                    : const Color(0xFF262135),
                              ),
                              labelStyle: TextStyle(
                                color: movementType == 'Entrada'
                                    ? Colors.greenAccent
                                    : const Color(0xFFA1A1AA),
                              ),
                              backgroundColor: const Color(0xFF0D0B14),
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() => movementType = 'Entrada');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(
                                child: Text(
                                  'Saída',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              selected: movementType == 'Saída',
                              selectedColor: Colors.red.withOpacity(0.2),
                              side: BorderSide(
                                color: movementType == 'Saída'
                                    ? Colors.redAccent
                                    : const Color(0xFF262135),
                              ),
                              labelStyle: TextStyle(
                                color: movementType == 'Saída'
                                    ? Colors.redAccent
                                    : const Color(0xFFA1A1AA),
                              ),
                              backgroundColor: const Color(0xFF0D0B14),
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() => movementType = 'Saída');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Produto',
                        style: TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      StreamBuilder<List<Product>>(
                        stream: _productService.getProductsStream(),
                        builder: (context, snapshot) {
                          final products = snapshot.data ?? [];
                          return DropdownButtonFormField<Product>(
                            dropdownColor: const Color(0xFF181524),
                            style: const TextStyle(color: Colors.white),
                            value: selectedProduct,
                            hint: const Text(
                              'Selecione um produto',
                              style: TextStyle(color: Color(0xFF52525B)),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF0D0B14),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF262135)),
                              ),
                            ),
                            items: products.map((prod) {
                              return DropdownMenuItem<Product>(
                                value: prod,
                                child: Text('${prod.name} (${prod.quantity} un em estoque)'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setModalState(() => selectedProduct = val);
                            },
                            validator: (val) =>
                            val == null ? 'Selecione um produto' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Quantidade',
                        style: TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: const TextStyle(color: Color(0xFF52525B)),
                          filled: true,
                          fillColor: const Color(0xFF0D0B14),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF262135)),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe a quantidade';
                          final q = int.tryParse(v);
                          if (q == null || q <= 0) return 'Quantidade inválida';
                          if (movementType == 'Saída' &&
                              selectedProduct != null &&
                              q > selectedProduct!.quantity) {
                            return 'Estoque insuficiente (${selectedProduct!.quantity} un)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate() &&
                                selectedProduct != null) {
                              final int qty = int.parse(quantityController.text);

                              final movement = Movement(
                                productId: selectedProduct!.id,
                                productName: selectedProduct!.name,
                                type: movementType,
                                quantity: qty,
                                createdAt: DateTime.now(),
                              );

                              final newQuantity = movementType == 'Entrada'
                                  ? selectedProduct!.quantity + qty
                                  : selectedProduct!.quantity - qty;

                              await _movementService.addMovement(movement);
                              if (selectedProduct!.id != null) {
                                await _productService.updateProductQuantity(
                                  selectedProduct!.id!,
                                  newQuantity,
                                );
                              }

                              if (ctx.mounted) Navigator.pop(ctx);
                            }
                          },
                          child: const Text(
                            'Confirmar Movimentação',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Histórico de Movimentações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _openAddMovementModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.swap_vert_rounded, color: Colors.white),
                  label: const Text(
                    'Registrar Movimentação',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<Movement>>(
                  stream: _movementService.getAllMovementsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                        ),
                      );
                    }

                    final movements = snapshot.data ?? [];

                    if (movements.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma movimentação registrada ainda.',
                          style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: movements.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = movements[index];
                        final isEntry = item.type == 'Entrada';
                        final dateFormatted =
                            '${item.createdAt.day.toString().padLeft(2, '0')}/${item.createdAt.month.toString().padLeft(2, '0')}/${item.createdAt.year} às ${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF181524),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF262135)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: isEntry
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.red.withOpacity(0.15),
                                child: Icon(
                                  isEntry
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: isEntry
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateFormatted,
                                      style: const TextStyle(
                                        color: Color(0xFFA1A1AA),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isEntry ? '+' : '-'}${item.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isEntry
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}