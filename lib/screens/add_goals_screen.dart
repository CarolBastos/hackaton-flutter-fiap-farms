import 'package:fiap_farms/domain/entities/goals.dart';
import 'package:fiap_farms/presentation/controllers/goals_controller.dart';
import 'package:fiap_farms/screens/components/custom_app_bar.dart';
import 'package:fiap_farms/screens/components/custom_button.dart';
import 'package:fiap_farms/screens/components/custom_text_field.dart';
import 'package:fiap_farms/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _targetValueController = TextEditingController();

  String _selectedType = 'producao';
  String _selectedStatus = 'ativa';
  String _selectedUnit = 'kg';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _achievedAt;

  final List<String> _types = ['producao', 'vendas'];
  final List<String> _statuses = [
    'ativa',
    'atingida',
    'cancelada',
    'pendente',
    'planejada',
  ];
  final List<String> _units = [
    'kg',
    'unidade',
    'litro',
    'saca',
    'caixa',
    'reais',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormAppBar(title: 'Adicionar Meta'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nome da Meta
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nome da Meta',
                  hintText: 'Ex: Produção de grão de bico 200kg',
                  prefixIcon: Icons.flag,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome da meta é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tipo de Meta
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _types.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && mounted) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tipo é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Status
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _statuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && mounted) {
                      setState(() {
                        _selectedStatus = value;
                        _achievedAt = _selectedStatus == 'atingida'
                            ? DateTime.now()
                            : null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Unidade de Medida
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unidade *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.straighten),
                  ),
                  items: _units.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && mounted) {
                      setState(() {
                        _selectedUnit = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Unidade é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Valor Atual
                CustomTextField(
                  controller: _currentValueController,
                  labelText: 'Valor Atual',
                  hintText: '0',
                  prefixIcon: Icons.trending_up,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final val = double.tryParse(value);
                      if (val == null || val < 0) {
                        return 'Valor deve ser um número positivo';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Valor Alvo
                CustomTextField(
                  controller: _targetValueController,
                  labelText: 'Valor Alvo *',
                  hintText: '200',
                  prefixIcon: Icons.adjust,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Valor alvo é obrigatório';
                    }
                    final val = double.tryParse(value);
                    if (val == null || val <= 0) {
                      return 'Valor deve ser maior que zero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Data de Início
                ListTile(
                  title: const Text('Data de Início'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, isStartDate: true),
                ),
                const SizedBox(height: 8),

                // Data de Término
                ListTile(
                  title: const Text('Data de Término'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                  leading: const Icon(Icons.event_available),
                  onTap: () => _selectDate(context, isStartDate: false),
                ),
                const SizedBox(height: 16),

                // Data de Conquista (se status for "atingida")
                if (_selectedStatus == 'atingida')
                  ListTile(
                    title: const Text('Data de Conquista'),
                    subtitle: Text(
                      _achievedAt != null
                          ? DateFormat('dd/MM/yyyy').format(_achievedAt!)
                          : 'Selecione',
                    ),
                    leading: const Icon(Icons.celebration),
                    onTap: () => _selectAchievedDate(context),
                  ),
                const SizedBox(height: 24),

                // Botão Salvar e Erros
                Consumer<GoalController>(
                  builder: (context, goalController, child) {
                    return Column(
                      children: [
                        CustomButton.large(
                          onPressed: _saveGoal,
                          text: 'Salvar Meta',
                          variant: ButtonVariant.primary,
                          isLoading: goalController.isLoading,
                        ),
                        const SizedBox(height: 16),
                        if (goalController.errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              border: Border.all(color: AppColors.errorBorder),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              goalController.errorMessage,
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

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectAchievedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _achievedAt ?? DateTime.now(),
      firstDate: _startDate,
      lastDate: _endDate,
    );

    if (picked != null && mounted) {
      setState(() {
        _achievedAt = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    final goal = Goal(
      name: _nameController.text.trim(),
      type: _selectedType,
      status: _selectedStatus,
      targetUnit: _selectedUnit,
      currentValue: double.tryParse(_currentValueController.text) ?? 0,
      targetValue: double.parse(_targetValueController.text),
      startDate: _startDate,
      endDate: _endDate,
      achievedAt: _selectedStatus == 'atingida'
          ? _achievedAt ?? DateTime.now()
          : null,
      createdAt: DateTime.now(),
      createdBy: 'current_user_id',
      entityId: 'default_entity_id',
    );

    try {
      final goalController = Provider.of<GoalController>(
        context,
        listen: false,
      );
      await goalController.createGoal(goal);

      if (mounted) {
        if (goalController.errorMessage.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meta cadastrada com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${goalController.errorMessage}'),
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
    _currentValueController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
