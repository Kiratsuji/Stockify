import 'package:flutter/material.dart';
import 'package:stockify/screens/company/createCompanyStep3Screen.dart';

class CreateCompanyStep2Screen extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const CreateCompanyStep2Screen({
    super.key,
    required this.companyData,
  });

  @override
  State<CreateCompanyStep2Screen> createState() => _CreateCompanyStep2ScreenState();
}

class _CreateCompanyStep2ScreenState extends State<CreateCompanyStep2Screen> {
  String selectedCurrency = 'BRL (R\$)';
  String selectedUnit = 'Unidade';
  bool notifyLowStock = true;
  bool allowNegativeStock = false;

  final List<Map<String, String>> currencies = [
    {'code': 'BRL (R\$)', 'label': 'Real (R\$)'},
    {'code': 'USD (\$)', 'label': 'Dólar (\$)'},
    {'code': 'EUR (€)', 'label': 'Euro (€)'},
  ];

  final List<String> defaultUnits = [
    'Unidade',
    'Kg',
    'g',
    'Litro',
    'ml',
    'Metro',
    'Caixa',
    'Pacote',
  ];

  void _goToNextStep() {
    final updatedCompanyData = {
      ...widget.companyData,
      'currency': selectedCurrency,
      'defaultUnit': selectedUnit,
      'notifyLowStock': notifyLowStock,
      'allowNegativeStock': allowNegativeStock,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCompanyStep3Screen(companyData: updatedCompanyData),
      ),
    );
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
          'Configurar Estoque',
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
                'Passo 2 de 3',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vamos definir algumas configurações para o seu estoque.',
                style: TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Seleção de Moeda
                      DropdownButtonFormField<String>(
                        value: selectedCurrency,
                        dropdownColor: const Color(0xFF181524),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Moeda principal',
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
                        items: currencies.map((currency) {
                          return DropdownMenuItem<String>(
                            value: currency['code'],
                            child: Text(currency['label']!),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => selectedCurrency = newValue);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Unidade Padrão
                      DropdownButtonFormField<String>(
                        value: selectedUnit,
                        dropdownColor: const Color(0xFF181524),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Unidade de medida padrão',
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
                        items: defaultUnits.map((String unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => selectedUnit = newValue);
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Switch: Alerta de estoque mínimo
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF181524),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF262135)),
                        ),
                        child: SwitchListTile(
                          activeColor: const Color(0xFF8B5CF6),
                          title: const Text(
                            'Alertas de estoque mínimo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: const Text(
                            'Receber notificações quando itens atingirem a quantidade mínima',
                            style: TextStyle(
                              color: Color(0xFFA1A1AA),
                              fontSize: 13,
                            ),
                          ),
                          value: notifyLowStock,
                          onChanged: (bool value) {
                            setState(() => notifyLowStock = value);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Switch: Permitir estoque negativo
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF181524),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF262135)),
                        ),
                        child: SwitchListTile(
                          activeColor: const Color(0xFF8B5CF6),
                          title: const Text(
                            'Permitir estoque negativo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: const Text(
                            'Permite movimentações mesmo quando a quantidade estiver zerada ou negativa',
                            style: TextStyle(
                              color: Color(0xFFA1A1AA),
                              fontSize: 13,
                            ),
                          ),
                          value: allowNegativeStock,
                          onChanged: (bool value) {
                            setState(() => allowNegativeStock = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}