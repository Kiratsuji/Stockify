import 'package:flutter/material.dart';
import '../models/productModel.dart';
import '../services/productService.dart';

enum ProductFilter { all, lowStock, zeroStock }

class ProductsScreen extends StatefulWidget {
  final ProductFilter initialFilter;

  const ProductsScreen({
    super.key,
    this.initialFilter = ProductFilter.all,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  late ProductFilter _selectedFilter;

  final List<String> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddCategoryModal(BuildContext parentContext, StateSetter modalSetState) {
    final newCategoryController = TextEditingController();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181524),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nova Categoria',
                    style: TextStyle(
                      fontSize: 18,
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
              _buildTextField(
                controller: newCategoryController,
                label: 'Nome da Categoria',
                hint: 'Ex: Eletrônicos',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final newCat = newCategoryController.text.trim();
                    if (newCat.isNotEmpty) {
                      setState(() {
                        if (!_categories.contains(newCat)) {
                          _categories.add(newCat);
                        }
                      });
                      modalSetState(() {
                        _selectedCategory = newCat;
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Salvar Categoria', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAddProductModal(BuildContext context) {
    final nameController = TextEditingController();
    final costPriceController = TextEditingController();
    final salePriceController = TextEditingController();
    final quantityController = TextEditingController();
    final minQuantityController = TextEditingController(text: '5');
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
          builder: (BuildContext context, StateSetter modalSetState) {
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
                            'Novo Produto',
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
                      _buildTextField(
                        controller: nameController,
                        label: 'Nome do Produto',
                        hint: 'Ex: Teclado Mecânico',
                        validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                      ),
                      const SizedBox(height: 12),

                      // Categoria
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Categoria',
                            style: TextStyle(
                              color: Color(0xFFA1A1AA),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            dropdownColor: const Color(0xFF181524),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Selecione uma categoria',
                              hintStyle: const TextStyle(color: Color(0xFF52525B)),
                              filled: true,
                              fillColor: const Color(0xFF0D0B14),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF262135)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF262135)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                              ),
                            ),
                            items: [
                              ..._categories.map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              )),
                              const DropdownMenuItem(
                                value: '__ADD_NEW__',
                                child: Row(
                                  children: [
                                    Icon(Icons.add, color: Color(0xFF8B5CF6), size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Criar categoria',
                                      style: TextStyle(
                                        color: Color(0xFF8B5CF6),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val == '__ADD_NEW__') {
                                _openAddCategoryModal(ctx, modalSetState);
                              } else {
                                modalSetState(() {
                                  _selectedCategory = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: quantityController,
                              label: 'Qtd. Inicial',
                              hint: '0',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Informe a qtd.';
                                if (int.tryParse(v) == null) return 'Inválido';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: minQuantityController,
                              label: 'Estoque Mínimo',
                              hint: '5',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Informe o mín.';
                                if (int.tryParse(v) == null) return 'Inválido';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: costPriceController,
                              label: 'Preço de Custo (R\$)',
                              hint: '0.00',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Informe o custo';
                                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Inválido';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: salePriceController,
                              label: 'Preço de Venda (R\$)',
                              hint: '0.00',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Informe a venda';
                                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Inválido';
                                return null;
                              },
                            ),
                          ),
                        ],
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
                            if (formKey.currentState!.validate()) {
                              final newProduct = Product(
                                name: nameController.text.trim(),
                                category: _selectedCategory,
                                costPrice: double.parse(costPriceController.text.replaceAll(',', '.')),
                                price: double.parse(salePriceController.text.replaceAll(',', '.')),
                                quantity: int.parse(quantityController.text),
                                minQuantity: int.parse(minQuantityController.text),
                                createdAt: DateTime.now(),
                              );

                              await _productService.addProduct(newProduct);
                              if (ctx.mounted) Navigator.pop(ctx);
                            }
                          },
                          child: const Text(
                            'Cadastrar Produto',
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
                'Estoque de Produtos',
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
                  onPressed: () => _openAddProductModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: const Text(
                    'Adicionar Novo Produto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de Busca + Menu Suspenso de Filtro
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF181524),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF262135)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase().trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Pesquisar produto...',
                          hintStyle: const TextStyle(color: Color(0xFF52525B)),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFA1A1AA)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFFA1A1AA), size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Menu Suspenso de Filtro
                  PopupMenuButton<ProductFilter>(
                    initialValue: _selectedFilter,
                    tooltip: 'Filtrar produtos',
                    onSelected: (ProductFilter filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFF262135)),
                    ),
                    color: const Color(0xFF181524),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _selectedFilter != ProductFilter.all
                            ? const Color(0xFF8B5CF6).withOpacity(0.2)
                            : const Color(0xFF181524),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedFilter != ProductFilter.all
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFF262135),
                        ),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: _selectedFilter != ProductFilter.all
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFFA1A1AA),
                      ),
                    ),
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<ProductFilter>(
                        value: ProductFilter.lowStock,
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 18),
                            SizedBox(width: 10),
                            Text('Estoque Baixo', style: TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<ProductFilter>(
                        value: ProductFilter.zeroStock,
                        child: Row(
                          children: [
                            Icon(Icons.remove_shopping_cart_outlined, color: Colors.redAccent, size: 18),
                            SizedBox(width: 10),
                            Text('Estoque Zerado', style: TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(height: 1),
                      const PopupMenuItem<ProductFilter>(
                        value: ProductFilter.all,
                        child: Row(
                          children: [
                            Icon(Icons.clear_all_rounded, color: Color(0xFFA1A1AA), size: 18),
                            SizedBox(width: 10),
                            Text('Limpar Filtros', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Lista de Produtos
              Expanded(
                child: StreamBuilder<List<Product>>(
                  stream: _productService.getProductsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                        ),
                      );
                    }

                    final allProducts = snapshot.data ?? [];

                    final filteredProducts = allProducts.where((product) {
                      final matchesSearch = product.name.toLowerCase().contains(_searchQuery);

                      bool matchesFilter = true;
                      if (_selectedFilter == ProductFilter.lowStock) {
                        matchesFilter = product.quantity <= product.minQuantity && product.quantity > 0;
                      } else if (_selectedFilter == ProductFilter.zeroStock) {
                        matchesFilter = product.quantity == 0;
                      }

                      return matchesSearch && matchesFilter;
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Text(
                          _searchQuery.isNotEmpty || _selectedFilter != ProductFilter.all
                              ? 'Nenhum produto encontrado.'
                              : 'Nenhum produto cadastrado no estoque.',
                          style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredProducts.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final isZeroStock = product.quantity == 0;
                        final isLowStock = product.quantity <= product.minQuantity;

                        Color statusColor = const Color(0xFF8B5CF6);
                        if (isZeroStock) {
                          statusColor = Colors.redAccent;
                        } else if (isLowStock) {
                          statusColor = Colors.amberAccent;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF181524),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isZeroStock || isLowStock
                                  ? statusColor.withOpacity(0.4)
                                  : const Color(0xFF262135),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: statusColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product.category ?? 'Sem categoria'} • R\$ ${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Color(0xFFA1A1AA),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${product.quantity} un',
                                    style: TextStyle(
                                      color: isZeroStock || isLowStock ? statusColor : Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isZeroStock) ...[
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Estoque Zerado',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ] else if (isLowStock) ...[
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Estoque Baixo',
                                      style: TextStyle(
                                        color: Colors.amberAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFA1A1AA),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF52525B)),
            filled: true,
            fillColor: const Color(0xFF0D0B14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF262135)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF262135)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
            ),
          ),
        ),
      ],
    );
  }
}