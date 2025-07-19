import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/controllers/sales_controller.dart';
import '../presentation/controllers/inventory_controller.dart';
import '../presentation/controllers/product_controller.dart';
import '../domain/entities/sales_record.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../routes.dart';
import 'components/menu_drawer.dart';
import 'components/custom_app_bar.dart';

class InventorySalesScreen extends StatefulWidget {
  const InventorySalesScreen({super.key});

  @override
  State<InventorySalesScreen> createState() => _InventorySalesScreenState();
}

class _InventorySalesScreenState extends State<InventorySalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false).loadProducts();
      Provider.of<InventoryController>(
        context,
        listen: false,
      ).loadInventoryItems();
      Provider.of<SalesController>(context, listen: false).loadSalesRecords();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabAppBar(
        title: 'Controle de Estoque e Vendas',
        tabController: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.inventory), text: 'Estoque'),
          Tab(icon: Icon(Icons.shopping_cart), text: 'Vendas'),
        ],
      ),
      drawer: MenuDrawer(currentRoute: Routes.inventorySales),
      body: TabBarView(
        controller: _tabController,
        children: const [_InventoryTab(), _SalesTab()],
      ),
    );
  }
}

class _InventoryTab extends StatefulWidget {
  const _InventoryTab();

  @override
  State<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<_InventoryTab> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = Provider.of<InventoryController>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGoalAchieved(controller);
    });
  }

  void _checkGoalAchieved(InventoryController controller) {
    final goalName = controller.lastAchievedGoalName;
    if (goalName != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Meta Atingida!'),
          content: Text('A meta "$goalName" foi atingida.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.clearLastAchievedGoalName();
              },
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<InventoryController, ProductController>(
      builder: (context, inventoryController, productController, child) {
        // ✅ Checa a cada rebuild se há uma meta atingida
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkGoalAchieved(inventoryController);
        });

        if (inventoryController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estoque Atual',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddToInventoryDialog(context, productController);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar ao Estoque'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (inventoryController.errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    border: Border.all(color: AppColors.errorBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    inventoryController.errorMessage,
                    style: TextStyle(color: AppColors.errorText),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: inventoryController.inventoryItems.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum item no estoque. Adicione produtos para começar.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textLight,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: inventoryController.inventoryItems.length,
                        itemBuilder: (context, index) {
                          final item =
                              inventoryController.inventoryItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                _showInventoryItemDetails(context, item);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // Ícone e número
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: AppColors.textWhite,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Informações principais
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Disponível: ${item.availableQuantity} ${item.unitOfMeasure}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          if (item.soldQuantity > 0)
                                            Text(
                                              'Vendido: ${item.soldQuantity} ${item.unitOfMeasure}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Preço e custo
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'R\$ ${item.estimatedCostPerUnit.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                          ),
                                          Text(
                                            'por ${item.unitOfMeasure}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textLight,
                                            ),
                                          ),
                                          if (item.soldQuantity > 0)
                                            Text(
                                              'Total vendido: R\$ ${(item.soldQuantity * item.estimatedCostPerUnit).toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddToInventoryDialog(
    BuildContext context,
    ProductController productController,
  ) {
    String? selectedProductId;
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar ao Estoque'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedProductId,
              decoration: const InputDecoration(
                labelText: 'Produto',
                border: OutlineInputBorder(),
              ),
              items: productController.products.map((product) {
                return DropdownMenuItem(
                  value: product.id,
                  child: Text(product.name),
                );
              }).toList(),
              onChanged: (value) {
                selectedProductId = value;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedProductId != null &&
                  quantityController.text.isNotEmpty) {
                final quantity = double.tryParse(quantityController.text);
                if (quantity != null && quantity > 0) {
                  Provider.of<InventoryController>(
                    context,
                    listen: false,
                  ).addToInventory(selectedProductId!, quantity);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showInventoryItemDetails(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalhes do Estoque - ${item.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quantidade disponível: ${item.availableQuantity} ${item.unitOfMeasure}',
            ),
            if (item.soldQuantity > 0)
              Text(
                'Quantidade vendida: ${item.soldQuantity} ${item.unitOfMeasure}',
              ),
            Text(
              'Custo por unidade: R\$ ${item.estimatedCostPerUnit.toStringAsFixed(2)}',
            ),
            Text(
              'Valor total em estoque: R\$ ${(item.availableQuantity * item.estimatedCostPerUnit).toStringAsFixed(2)}',
            ),
            if (item.soldQuantity > 0)
              Text(
                'Valor total vendido: R\$ ${(item.soldQuantity * item.estimatedCostPerUnit).toStringAsFixed(2)}',
              ),
            Text(
              'Última atualização: ${DateFormatter.formatDateTime(item.lastUpdated)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _SalesTab extends StatelessWidget {
  const _SalesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<SalesController, ProductController>(
      builder: (context, salesController, productController, child) {
        // Mostrar pop-up se uma meta foi atingida
        if (salesController.lastAchievedGoalName != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Meta Atingida!'),
                content: Text(
                  'Parabéns! A meta "${salesController.lastAchievedGoalName}" foi atingida.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      salesController.clearLastAchievedGoalName();
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            );
          });
        }

        if (salesController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Registrar Venda',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddSaleDialog(context, productController);
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Nova Venda'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (salesController.errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    border: Border.all(color: AppColors.errorBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    salesController.errorMessage,
                    style: TextStyle(color: AppColors.errorText),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: salesController.salesRecords.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma venda registrada. Registre sua primeira venda!',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textLight,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: salesController.salesRecords.length,
                        itemBuilder: (context, index) {
                          final sale = salesController.salesRecords[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  'R\$',
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                  ),
                                ),
                              ),
                              title: Text(
                                sale.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${sale.quantitySold} ${sale.unitOfMeasure} • ${DateFormatter.formatDateTime(sale.saleDate)}',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'R\$ ${sale.totalSaleAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    'Lucro: R\$ ${sale.calculatedProfit.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                _showSaleDetails(context, sale);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSaleDialog(
    BuildContext context,
    ProductController productController,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _AddSaleDialog(productController: productController),
    );
  }

  void _showSaleDetails(BuildContext context, dynamic sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalhes da Venda - ${sale.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantidade: ${sale.quantitySold} ${sale.unitOfMeasure}'),
            Text(
              'Preço por unidade: R\$ ${sale.salePricePerUnit.toStringAsFixed(2)}',
            ),
            Text('Valor total: R\$ ${sale.totalSaleAmount.toStringAsFixed(2)}'),
            Text(
              'Custo estimado: R\$ ${sale.estimatedCostAtSale.toStringAsFixed(2)}',
            ),
            Text('Lucro: R\$ ${sale.calculatedProfit.toStringAsFixed(2)}'),
            if (sale.clientInfo != null) Text('Cliente: ${sale.clientInfo}'),
            Text('Data: ${DateFormatter.formatDateTime(sale.saleDate)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _AddSaleDialog extends StatefulWidget {
  final ProductController productController;

  const _AddSaleDialog({required this.productController});

  @override
  State<_AddSaleDialog> createState() => _AddSaleDialogState();
}

class _AddSaleDialogState extends State<_AddSaleDialog> {
  String? selectedProductId;
  String? stockError;
  double? availableStock;

  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final clientController = TextEditingController();

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    clientController.dispose();
    super.dispose();
  }

  bool isFormValid() {
    final hasProduct = selectedProductId != null;
    final hasQuantity = quantityController.text.isNotEmpty;
    final hasPrice = priceController.text.isNotEmpty;
    final hasNoStockError = stockError == null;
    return hasProduct && hasQuantity && hasPrice && hasNoStockError;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar Venda'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedProductId,
                decoration: const InputDecoration(
                  labelText: 'Produto',
                  border: OutlineInputBorder(),
                ),
                items: widget.productController.products.map((product) {
                  return DropdownMenuItem(
                    value: product.id,
                    child: Text(product.name),
                  );
                }).toList(),
                onChanged: (value) async {
                  setState(() {
                    selectedProductId = value;
                    stockError = null;
                    availableStock = null;
                  });

                  if (value != null) {
                    final inventoryController =
                        Provider.of<InventoryController>(
                          context,
                          listen: false,
                        );
                    final inventoryItem = await inventoryController
                        .getInventoryItemByProductId(value);

                    setState(() {
                      if (inventoryItem != null) {
                        availableStock = inventoryItem.availableQuantity;
                        if (availableStock == 0) {
                          stockError = 'Produto sem estoque disponível';
                        }
                      } else {
                        stockError = 'Produto não encontrado no estoque';
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final quantity = double.tryParse(value);
                  if (quantity != null &&
                      availableStock != null &&
                      quantity > availableStock!) {
                    setState(() {
                      stockError =
                          'Quantidade solicitada (${quantity.toStringAsFixed(1)}) excede o estoque disponível (${availableStock!.toStringAsFixed(1)})';
                    });
                  } else {
                    setState(() {
                      stockError = null;
                    });
                  }
                },
              ),
              if (availableStock != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Estoque disponível: ${availableStock!.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (stockError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    stockError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.errorText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço por unidade',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: clientController,
                decoration: const InputDecoration(
                  labelText: 'Cliente (opcional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: isFormValid()
              ? () async {
                  final quantity = double.tryParse(quantityController.text);
                  final price = double.tryParse(priceController.text);
                  if (quantity != null &&
                      price != null &&
                      quantity > 0 &&
                      price > 0) {
                    final selectedProduct = widget.productController.products
                        .firstWhere((p) => p.id == selectedProductId);

                    final totalAmount = quantity * price;
                    final estimatedCost =
                        quantity * selectedProduct.estimatedCostPerUnit;
                    final profit = totalAmount - estimatedCost;

                    final salesRecord = SalesRecord(
                      productId: selectedProductId!,
                      productName: selectedProduct.name,
                      quantitySold: quantity,
                      unitOfMeasure: selectedProduct.unitOfMeasure,
                      salePricePerUnit: price,
                      totalSaleAmount: totalAmount,
                      estimatedCostAtSale: estimatedCost,
                      calculatedProfit: profit,
                      saleDate: DateTime.now(),
                      clientInfo: clientController.text.isNotEmpty
                          ? clientController.text
                          : null,
                      createdAt: DateTime.now(),
                      createdBy: '',
                    );

                    await Provider.of<InventoryController>(
                      context,
                      listen: false,
                    ).processSale(selectedProductId!, quantity);

                    Provider.of<SalesController>(
                      context,
                      listen: false,
                    ).createSalesRecord(salesRecord);

                    Navigator.pop(context);
                  }
                }
              : null,
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}
