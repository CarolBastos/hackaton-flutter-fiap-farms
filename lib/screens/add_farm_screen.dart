import 'package:fiap_farms/domain/entities/farm.dart';
import 'package:fiap_farms/presentation/controllers/farm_controller.dart';
import 'package:fiap_farms/presentation/controllers/product_controller.dart';
import 'package:fiap_farms/screens/components/custom_app_bar.dart';
import 'package:fiap_farms/screens/components/custom_button.dart';
import 'package:fiap_farms/screens/components/custom_text_field.dart';
import 'package:fiap_farms/screens/location_pick_screen.dart';
import 'package:fiap_farms/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddFarmScreen extends StatefulWidget {
  const AddFarmScreen({super.key});

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _annualProductionController = TextEditingController();
  final _areaController = TextEditingController();

  String _selectedProductType = 'Soja';
  double _latitude = -15.7934;
  double _longitude = -47.8822;
  DateTime? _establishedDate;

  List<String> _productTypes = ['Soja'];

  @override
  void initState() {
    super.initState();
    _loadProductTypes();
  }

  Future<void> _loadProductTypes() async {
    try {
      final productController = Provider.of<ProductController>(
        context,
        listen: false,
      );
      await productController.loadProducts();

      if (mounted) {
        setState(() {
          _productTypes = productController.products
              .map((product) => product.name)
              .toList();

          if (_productTypes.isEmpty || !_productTypes.contains('Soja')) {
            _productTypes.insert(0, 'Soja');
          }

          _selectedProductType = _productTypes.first;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _productTypes = [
            'Soja',
            'Milho',
            'Café',
            'Cana-de-açúcar',
            'Algodão',
            'Trigo',
            'Arroz',
            'Outros',
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormAppBar(title: 'Adicionar Fazenda'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nome da Fazenda
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nome da Fazenda',
                  hintText: 'Ex: Fazenda São João',
                  prefixIcon: Icons.agriculture,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome da fazenda é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Endereço
                CustomTextField(
                  controller: _addressController,
                  labelText: 'Endereço',
                  hintText: 'Ex: Rodovia BR-020, Km 134',
                  prefixIcon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Endereço é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tipo de Produto
                DropdownButtonFormField<String>(
                  value: _selectedProductType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Produto *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _productTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && mounted) {
                      setState(() {
                        _selectedProductType = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tipo de produto é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Produção Anual
                CustomTextField(
                  controller: _annualProductionController,
                  labelText: 'Produção Anual (ton) *',
                  hintText: 'Ex: 25000',
                  prefixIcon: Icons.assessment,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Produção anual é obrigatória';
                    }
                    final val = double.tryParse(value);
                    if (val == null || val <= 0) {
                      return 'Valor deve ser maior que zero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Área (hectares)
                CustomTextField(
                  controller: _areaController,
                  labelText: 'Área (hectares)',
                  hintText: 'Ex: 250',
                  prefixIcon: Icons.square_foot,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final val = double.tryParse(value);
                      if (val == null || val <= 0) {
                        return 'Valor deve ser maior que zero';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Data de Fundação
                ListTile(
                  title: const Text('Data de Fundação'),
                  subtitle: Text(
                    _establishedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_establishedDate!)
                        : 'Selecione',
                  ),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () => _selectEstablishedDate(context),
                ),
                const SizedBox(height: 16),

                // Localização
                ListTile(
                  title: const Text('Localização'),
                  subtitle: Text('Lat: $_latitude, Long: $_longitude'),
                  leading: const Icon(Icons.map),
                  onTap: () => _selectLocation(context),
                ),
                const SizedBox(height: 24),

                // Botão Salvar
                Consumer<FarmController>(
                  builder: (context, farmController, child) {
                    return Column(
                      children: [
                        CustomButton.large(
                          onPressed: _saveFarm,
                          text: 'Salvar Fazenda',
                          variant: ButtonVariant.primary,
                          isLoading: farmController.isLoading,
                        ),
                        const SizedBox(height: 16),
                        if (farmController.errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              border: Border.all(color: AppColors.errorBorder),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              farmController.errorMessage,
                              style: TextStyle(color: AppColors.errorText),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectEstablishedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _establishedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _establishedDate = picked;
      });
    }
  }

  Future<void> _selectLocation(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLat: _latitude,
          initialLong: _longitude,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  Future<void> _saveFarm() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    final farm = Farm(
      id: '', // Será gerado pelo Firestore
      name: _nameController.text.trim(),
      productType: _selectedProductType,
      annualProduction: double.parse(_annualProductionController.text),
      location: Location(latitude: _latitude, longitude: _longitude),
      address: _addressController.text.trim(),
      area: _areaController.text.isNotEmpty
          ? double.parse(_areaController.text)
          : null,
      establishedDate: _establishedDate,
    );

    try {
      final farmController = Provider.of<FarmController>(
        context,
        listen: false,
      );
      await farmController.createFarm(farm);

      if (mounted) {
        if (farmController.errorMessage.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fazenda cadastrada com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${farmController.errorMessage}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _annualProductionController.dispose();
    _areaController.dispose();
    super.dispose();
  }
}
