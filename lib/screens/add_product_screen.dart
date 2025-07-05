import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/entities/product.dart';
import '../presentation/controllers/product_controller.dart';
import '../utils/app_colors.dart';
import 'components/custom_app_bar.dart';
import 'components/custom_button.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();

  String _selectedCategory = 'Hortaliças';
  String _selectedUnit = 'kg';
  bool _isActive = true;

  final List<String> _categories = [
    'Hortaliças',
    'Frutas',
    'Grãos',
    'Legumes',
    'Tubérculos',
    'Outros',
  ];

  final List<String> _units = [
    'kg',
    'unidade',
    'molho',
    'litro',
    'caixa',
    'saca',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormAppBar(title: 'Cadastrar Produto'),
      body: Consumer<ProductController>(
        builder: (context, productController, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nome do Produto
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Produto *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nome do produto é obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descrição
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Categoria
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoria *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Categoria é obrigatória';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Unidade de Medida
                    DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unidade de Medida *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Unidade de medida é obrigatória';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Custo Estimado
                    TextFormField(
                      controller: _costController,
                      decoration: const InputDecoration(
                        labelText: 'Custo Estimado por Unidade *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Custo estimado é obrigatório';
                        }
                        final cost = double.tryParse(value);
                        if (cost == null || cost <= 0) {
                          return 'Custo deve ser um número maior que zero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Produto Ativo
                    SwitchListTile(
                      title: const Text('Produto Ativo'),
                      subtitle: const Text('Disponível para produção e venda'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      secondary: Icon(
                        _isActive ? Icons.check_circle : Icons.cancel,
                        color: _isActive ? AppColors.success : AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão Salvar
                    CustomButton.large(
                      onPressed: _saveProduct,
                      text: 'Cadastrar Produto',
                      variant: ButtonVariant.primary,
                      isLoading: productController.isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Mensagem de Erro
                    if (productController.errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          border: Border.all(color: AppColors.errorBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          productController.errorMessage,
                          style: TextStyle(color: AppColors.errorText),
                        ),
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

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        unitOfMeasure: _selectedUnit,
        estimatedCostPerUnit: double.parse(_costController.text),
        createdAt: DateTime.now(),
        createdBy: '', // Será preenchido pelo repositório
        isActive: _isActive,
      );

      final productController = Provider.of<ProductController>(
        context,
        listen: false,
      );
      await productController.createProduct(product);

      if (productController.errorMessage.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produto cadastrado com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }
}
