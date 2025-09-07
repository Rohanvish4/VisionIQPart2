import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/verification_models.dart';
import '../provider/background_verification_provider.dart';
import '../utils/sample_data_provider.dart';

class DeclaredDataInputPage extends StatefulWidget {
  const DeclaredDataInputPage({super.key});

  @override
  State<DeclaredDataInputPage> createState() => _DeclaredDataInputPageState();
}

class _DeclaredDataInputPageState extends State<DeclaredDataInputPage> {
  final _formKey = GlobalKey<FormState>();

  EnvironmentType _selectedEnvironment = EnvironmentType.home;
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _additionalInfoController =
      TextEditingController();

  final List<DeclaredItemInput> _declaredItems = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final provider = Get.find<BackgroundVerificationProvider>();
    final existingData = provider.declaredData;

    if (existingData != null) {
      _selectedEnvironment = existingData.declaredEnvironment;
      _businessTypeController.text = existingData.businessType;
      _additionalInfoController.text = existingData.additionalInfo;

      for (final item in existingData.declaredItems) {
        _declaredItems.add(
          DeclaredItemInput(
            name: item.itemName,
            quantity: item.expectedQuantity,
            description: item.description,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Declared Information'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: _loadSampleData,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Home Environment',
                child: Text('Load Home Sample'),
              ),
              const PopupMenuItem(
                value: 'Shop/Store Environment',
                child: Text('Load Shop Sample'),
              ),
              const PopupMenuItem(
                value: 'Office Environment',
                child: Text('Load Office Sample'),
              ),
              const PopupMenuItem(
                value: 'Warehouse Environment',
                child: Text('Load Warehouse Sample'),
              ),
            ],
            icon: const Icon(Icons.science),
            tooltip: 'Load Sample Data',
          ),
          TextButton(
            onPressed: _saveData,
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 24),
              _buildEnvironmentSection(),
              const SizedBox(height: 24),
              _buildBusinessInfoSection(),
              const SizedBox(height: 24),
              _buildDeclaredItemsSection(),
              const SizedBox(height: 24),
              _buildAdditionalInfoSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: Colors.orange.shade600, size: 24),
              const SizedBox(width: 8),
              Text(
                'Customer Declaration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the information declared by the customer for verification comparison.',
            style: TextStyle(color: Colors.orange.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Environment Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: EnvironmentType.values
                  .where((env) => env != EnvironmentType.unknown)
                  .map(
                    (env) => ChoiceChip(
                      label: Text(_getEnvironmentLabel(env)),
                      selected: _selectedEnvironment == env,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedEnvironment = env;
                          });
                        }
                      },
                      selectedColor: Colors.orange.shade100,
                      checkmarkColor: Colors.orange.shade600,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getEnvironmentLabel(EnvironmentType env) {
    switch (env) {
      case EnvironmentType.home:
        return 'Home';
      case EnvironmentType.office:
        return 'Office';
      case EnvironmentType.shop:
        return 'Shop/Store';
      case EnvironmentType.warehouse:
        return 'Warehouse';
      case EnvironmentType.outdoor:
        return 'Outdoor';
      default:
        return 'Unknown';
    }
  }

  Widget _buildBusinessInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _businessTypeController,
              decoration: const InputDecoration(
                labelText: 'Business Type',
                hintText: 'e.g., Retail Store, Restaurant, Office Space',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeclaredItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Declared Items/Assets',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addDeclaredItem,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_declaredItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  'No items declared yet. Add items that should be present in the environment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _declaredItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _buildDeclaredItemCard(index),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeclaredItemCard(int index) {
    final item = _declaredItems[index];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: item.name,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g., Refrigerator, Shelves, Desk',
                    isDense: true,
                  ),
                  onChanged: (value) {
                    _declaredItems[index] = item.copyWith(name: value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextFormField(
                  initialValue: item.quantity.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final qty = int.tryParse(value) ?? 0;
                    _declaredItems[index] = item.copyWith(quantity: qty);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeDeclaredItem(index),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Remove item',
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: item.description,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Additional details about the item',
              isDense: true,
            ),
            onChanged: (value) {
              _declaredItems[index] = item.copyWith(description: value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _additionalInfoController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                hintText: 'Any other relevant information...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save & Continue'),
          ),
        ),
      ],
    );
  }

  void _addDeclaredItem() {
    setState(() {
      _declaredItems.add(
        DeclaredItemInput(name: '', quantity: 1, description: ''),
      );
    });
  }

  void _removeDeclaredItem(int index) {
    setState(() {
      _declaredItems.removeAt(index);
    });
  }

  void _saveData() {
    if (_formKey.currentState?.validate() ?? false) {
      final declaredData = DeclaredData(
        declaredEnvironment: _selectedEnvironment,
        declaredItems: _declaredItems
            .where((item) => item.name.isNotEmpty)
            .map(
              (item) => DeclaredItem(
                itemName: item.name,
                expectedQuantity: item.quantity,
                description: item.description,
              ),
            )
            .toList(),
        businessType: _businessTypeController.text,
        additionalInfo: _additionalInfoController.text,
      );

      final provider = Get.find<BackgroundVerificationProvider>();
      provider.setDeclaredData(declaredData);

      Get.back();

      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text('Declared data saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _businessTypeController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _loadSampleData(String sampleType) {
    final sampleData = SampleDataProvider.getAllSampleData()[sampleType];
    if (sampleData != null) {
      setState(() {
        _selectedEnvironment = sampleData.declaredEnvironment;
        _businessTypeController.text = sampleData.businessType;
        _additionalInfoController.text = sampleData.additionalInfo;

        _declaredItems.clear();
        for (final item in sampleData.declaredItems) {
          _declaredItems.add(
            DeclaredItemInput(
              name: item.itemName,
              quantity: item.expectedQuantity,
              description: item.description,
            ),
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loaded $sampleType sample data'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class DeclaredItemInput {
  final String name;
  final int quantity;
  final String description;

  DeclaredItemInput({
    required this.name,
    required this.quantity,
    required this.description,
  });

  DeclaredItemInput copyWith({
    String? name,
    int? quantity,
    String? description,
  }) {
    return DeclaredItemInput(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
    );
  }
}
