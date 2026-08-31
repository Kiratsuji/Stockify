import 'package:flutter/material.dart';
import 'package:stockify/models/productModel.dart';
import 'package:stockify/screens/dashboard.dart';
import 'package:stockify/screens/util/screenUtils.dart';
import 'package:stockify/services/companyService.dart';
import 'package:stockify/services/productService.dart';

class CreateCompanyStep3Screen extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const CreateCompanyStep3Screen({
    super.key,
    required this.companyData,
  });

  @override
  State<CreateCompanyStep3Screen> createState() => _CreateCompanyStep3ScreenState();
}

class _CreateCompanyStep3ScreenState extends State<CreateCompanyStep3Screen> {
  final _formKey = GlobalKey<FormState>();
  final CompanyService _companyService = CompanyService();
  final ProductService _productService = ProductService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController minQuantityController = TextEditingController(text: '5');
  final TextEditingController costPriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();

  // Categorias criadas durante o onboarding. Vão junto no momento em que a
  // empresa é efetivamente criada (_finishSetup), então não se perdem mais.
  final List<String> categories = [];
  String? selectedCategory;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    minQuantityController.dispose();
    costPriceController.dispose();
    salePriceController.dispose();
    super.dispose();
  }

  void _openAddCategoryModal() {
    final newCategoryController = TextEditingController();

    showModalBottomSheet(
      context: context,
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
              CommonTextField(
                controller: newCategoryController,
                labelText: 'Nome da Categoria',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final newCat = newCategoryController.text.trim();
                    if (newCat.isNotEmpty) {
                      setState(() {
                        if (!categories.contains(newCat)) {
                          categories.add(newCat);
                        }
                        selectedCategory = newCat;
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

  Future<void> _finishSetup({Product? firstProduct}) async {
    setState(() => isLoading = true);

    try {
      // 1. Cria a empresa já com as categorias do onboarding e o código de
      // convite (necessário para outras pessoas entrarem depois), e vincula
      // o usuário atual como dono.
      await _companyService.createCompany(
        companyData: widget.companyData,
        categories: categories,
      );

      // 2. Cadastra o primeiro produto, se preenchido. Nesse ponto o
      // companyId do usuário já foi atualizado, então o ProductService
      // consegue resolver a empresa normalmente.
      if (firstProduct != null) {
        await _productService.addProduct(firstProduct);
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao concluir cadastro: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _handleAddProduct() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        name: nameController.text.trim(),
        category: selectedCategory,
        quantity: int.parse(quantityController.text.trim()),
        minQuantity: int.parse(minQuantityController.text.trim()),
        costPrice: double.parse(costPriceController.text.replaceAll(',', '.').trim()),
        price: double.parse(salePriceController.text.replaceAll(',', '.').trim()),
        createdAt: DateTime.now(),
      );

      _finishSetup(firstProduct: product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Comece seu Estoque',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Passo 3 de 3',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cadastre seu primeiro produto para começar a controlar seu estoque.',
                style: TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CommonTextField(
                          controller: nameController,
                          labelText: 'Nome do produto',
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Categoria com Opção de Criar
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          dropdownColor: const Color(0xFF181524),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Categoria',
                            labelStyle: const TextStyle(color: Color(0xFFA1A1AA)),
                            filled: true,
                            fillColor: const Color(0xFF181524),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF262135)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                            ),
                          ),
                          items: [
                            ...categories.map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            )),
                            const DropdownMenuItem(
                              value: '__ADD_NEW__',
                              child: Row(
                                children: [
                                  Icon(Icons.add, color: Color(0xFF8B5CF6), size: 20),
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
                              _openAddCategoryModal();
                            } else {
                              setState(() => selectedCategory = val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: CommonTextField(
                                controller: quantityController,
                                labelText: 'Quantidade inicial',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CommonTextField(
                                controller: minQuantityController,
                                labelText: 'Estoque mínimo',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: CommonTextField(
                                controller: costPriceController,
                                labelText: 'Preço de custo',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CommonTextField(
                                controller: salePriceController,
                                labelText: 'Preço de venda',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Botões de Ação
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleAddProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text(
                      'Adicionar produto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: isLoading ? null : () => _finishSetup(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC4B5FD),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                        color: Color(0xFF4C1D95),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Fazer depois',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}