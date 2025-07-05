import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/entities/production_batch.dart';
import '../presentation/controllers/production_controller.dart';
import '../presentation/controllers/product_controller.dart';
import '../utils/app_colors.dart';
import 'components/custom_app_bar.dart';
import 'components/custom_button.dart';
import 'components/custom_text_field.dart';

class AddProductionScreen extends StatefulWidget {
  const AddProductionScreen({super.key});

  @override
  State<AddProductionScreen> createState() => _AddProductionScreenState();
}

class _AddProductionScreenState extends State<AddProductionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedProductId;
  String? _selectedProductName;
  DateTime _startDate = DateTime.now();
  DateTime _estimatedEndDate = DateTime.now().add(const Duration(days: 90));
  ProductionStatus _selectedStatus = ProductionStatus.planejado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormAppBar(title: 'Novo Lote de Produção'),
      body: Consumer2<ProductionController, ProductController>(
        builder: (context, productionController, productController, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Seleção do Produto
                    _buildProductSelector(productController),
                    const SizedBox(height: 16),

                    // Data de Início
                    _buildDateField(
                      label: 'Data de Início *',
                      value: _startDate,
                      onChanged: (date) {
                        setState(() {
                          _startDate = date;
                          // Ajusta a data de colheita se necessário
                          if (_estimatedEndDate.isBefore(_startDate)) {
                            _estimatedEndDate = _startDate.add(
                              const Duration(days: 90),
                            );
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Data Estimada de Colheita
                    _buildDateField(
                      label: 'Data Estimada de Colheita *',
                      value: _estimatedEndDate,
                      onChanged: (date) {
                        setState(() {
                          _estimatedEndDate = date;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quantidade Estimada
                    CustomTextField(
                      controller: _quantityController,
                      labelText: 'Quantidade Estimada',
                      hintText: '0,0',
                      prefixIcon: Icons.scale,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Quantidade estimada é obrigatória';
                        }
                        final quantity = double.tryParse(value);
                        if (quantity == null || quantity <= 0) {
                          return 'Quantidade deve ser um número maior que zero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Status Inicial
                    DropdownButtonFormField<ProductionStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status Inicial *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: ProductionStatus.values.map((status) {
                        // Criar um batch temporário para acessar os getters
                        final tempBatch = ProductionBatch(
                          productId: '',
                          productName: '',
                          startDate: DateTime.now(),
                          estimatedEndDate: DateTime.now(),
                          status: status,
                          estimatedQuantity: 0,
                          createdAt: DateTime.now(),
                          createdBy: '',
                          lastUpdatedAt: DateTime.now(),
                        );

                        return DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Text(tempBatch.statusEmoji),
                              const SizedBox(width: 8),
                              Text(tempBatch.statusString),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Observações
                    CustomTextField(
                      controller: _notesController,
                      labelText: 'Observações',
                      hintText: 'Informações adicionais sobre o lote...',
                      prefixIcon: Icons.note,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Botão Salvar
                    CustomButton.large(
                      onPressed: _saveProductionBatch,
                      text: 'Criar Lote de Produção',
                      variant: ButtonVariant.primary,
                      isLoading: productionController.isLoading,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSelector(ProductController productController) {

    return DropdownButtonFormField<String>(
      value: _selectedProductId,
      decoration: const InputDecoration(
        labelText: 'Produto *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.inventory),
      ),
      items: productController.products.map((product) {
        return DropdownMenuItem(value: product.id, child: Text(product.name));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedProductId = value;
          _selectedProductName = productController.products
              .firstWhere((product) => product.id == value)
              .name;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecione um produto';
        }
        return null;
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _saveProductionBatch() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProductId == null || _selectedProductName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione um produto'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_estimatedEndDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Data de colheita deve ser posterior à data de início',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final batch = ProductionBatch(
      productId: _selectedProductId!,
      productName: _selectedProductName!,
      startDate: _startDate,
      estimatedEndDate: _estimatedEndDate,
      status: _selectedStatus,
      estimatedQuantity: double.parse(_quantityController.text),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: DateTime.now(),
      createdBy: 'Usuário Atual', // TODO: Pegar do AuthController
      lastUpdatedAt: DateTime.now(),
    );

    Provider.of<ProductionController>(context, listen: false)
        .createProductionBatch(batch)
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Lote de produção criado com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar lote: $error'),
              backgroundColor: AppColors.danger,
            ),
          );
        });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
