import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/controllers/sales_controller.dart';
import '../presentation/controllers/inventory_controller.dart';
import '../presentation/controllers/product_controller.dart';
import '../domain/entities/sales_record.dart';
import '../utils/app_colors.dart';
import '../routes.dart';
import 'components/user_header_widget.dart';
import 'components/app_drawer.dart';

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
    _tabController = TabController(length: 3, vsync: this);

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
      appBar: AppBar(
        title: const Text('Controle de Estoque e Vendas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.inventory), text: 'Estoque'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Vendas'),
            Tab(icon: Icon(Icons.history), text: 'Histórico'),
          ],
        ),
      ),
      drawer: AppDrawer(currentRoute: Routes.inventorySales),
      body: TabBarView(
        controller: _tabController,
        children: const [_InventoryTab(), _SalesTab(), _HistoryTab()],
      ),
    );
  }
}

class _InventoryTab extends StatelessWidget {
  const _InventoryTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<InventoryController, ProductController>(
      builder: (context, inventoryController, productController, child) {
        if (inventoryController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UserHeader(),
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
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (inventoryController.errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    inventoryController.errorMessage,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: inventoryController.inventoryItems.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum item no estoque. Adicione produtos para começar.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: inventoryController.inventoryItems.length,
                        itemBuilder: (context, index) {
                          final item =
                              inventoryController.inventoryItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${item.availableQuantity} ${item.unitOfMeasure}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'R\$ ${item.estimatedCostPerUnit.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'por ${item.unitOfMeasure}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                _showInventoryItemDetails(context, item);
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
            Text('Quantidade: ${item.availableQuantity} ${item.unitOfMeasure}'),
            Text(
              'Custo por unidade: R\$ ${item.estimatedCostPerUnit.toStringAsFixed(2)}',
            ),
            Text(
              'Valor total: R\$ ${(item.availableQuantity * item.estimatedCostPerUnit).toStringAsFixed(2)}',
            ),
            Text(
              'Última atualização: ${item.lastUpdated.toString().substring(0, 16)}',
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
        if (salesController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UserHeader(),
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
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (salesController.errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    salesController.errorMessage,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: salesController.salesRecords.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma venda registrada. Registre sua primeira venda!',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
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
                                backgroundColor: Colors.green,
                                child: Text(
                                  'R\$',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                sale.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${sale.quantitySold} ${sale.unitOfMeasure} • ${sale.saleDate.toString().substring(0, 16)}',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'R\$ ${sale.totalSaleAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Lucro: R\$ ${sale.calculatedProfit.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
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
    String? selectedProductId;
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final clientController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Venda'),
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
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Preço por unidade',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: clientController,
              decoration: const InputDecoration(
                labelText: 'Cliente (opcional)',
                border: OutlineInputBorder(),
              ),
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
                  quantityController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                final quantity = double.tryParse(quantityController.text);
                final price = double.tryParse(priceController.text);
                if (quantity != null &&
                    price != null &&
                    quantity > 0 &&
                    price > 0) {
                  final selectedProduct = productController.products.firstWhere(
                    (product) => product.id == selectedProductId,
                  );

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

                  Provider.of<SalesController>(
                    context,
                    listen: false,
                  ).createSalesRecord(salesRecord);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
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
            Text('Data: ${sale.saleDate.toString().substring(0, 16)}'),
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

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesController>(
      builder: (context, salesController, child) {
        if (salesController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UserHeader(),
              const SizedBox(height: 16),
              const Text(
                'Histórico de Vendas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: salesController.salesRecords.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma venda registrada.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
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
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.history, color: Colors.white),
                              ),
                              title: Text(
                                sale.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${sale.quantitySold} ${sale.unitOfMeasure} • ${sale.saleDate.toString().substring(0, 16)}',
                              ),
                              trailing: Text(
                                'R\$ ${sale.totalSaleAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
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
}
