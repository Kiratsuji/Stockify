import 'package:flutter/material.dart';
import 'package:stockify/screens/util/screenUtils.dart';

import 'createCompanyStep2Screen.dart';

class CreateCompanyStep1Screen extends StatefulWidget {
  const CreateCompanyStep1Screen({super.key});

  @override
  State<CreateCompanyStep1Screen> createState() => _CreateCompanyStep1ScreenState();
}

class _CreateCompanyStep1ScreenState extends State<CreateCompanyStep1Screen> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController tradeNameController = TextEditingController();

  String? selectedSegment;

  final List<String> segments = [
    'Comércio',
    'Alimentação',
    'Eletrônicos',
    'Vestuário',
    'Construção',
    'Automotivo',
    'Farmácia',
    'Informática',
    'Outro',
  ];

  @override
  void dispose() {
    companyNameController.dispose();
    tradeNameController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (companyNameController.text.trim().isEmpty ||
        selectedSegment == null ||
        tradeNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final companyDataStep1 = {
      'companyName': companyNameController.text.trim(),
      'segment': selectedSegment,
      'tradeName': tradeNameController.text.trim(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCompanyStep2Screen(companyData: companyDataStep1),
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
          'Configurar Empresa',
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
                'Passo 1 de 3',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Conte um pouco sobre sua empresa. Essas informações serão usadas para personalizar seu Stockify.',
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
                      CommonTextField(
                        controller: companyNameController,
                        labelText: 'Nome da empresa',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedSegment,
                        dropdownColor: const Color(0xFF181524),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Segmento',
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
                        items: segments.map((String segment) {
                          return DropdownMenuItem<String>(
                            value: segment,
                            child: Text(segment),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedSegment = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      CommonTextField(
                        controller: tradeNameController,
                        labelText: 'Nome fantasia',
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