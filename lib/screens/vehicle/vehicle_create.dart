// vehicle_create.dart
import 'package:flutter/material.dart';
import 'package:prm_project/model/dto/request/vehicle_request.dart';
import 'package:prm_project/providers/vehicle_provider.dart';
import 'package:prm_project/widgets/selection_modal.dart';
import 'package:provider/provider.dart';

class VehicleCreateScreen extends StatefulWidget {
  final String customerId;

  const VehicleCreateScreen({super.key, required this.customerId});

  @override
  State<VehicleCreateScreen> createState() => _VehicleCreateScreenState();
}

class _VehicleCreateScreenState extends State<VehicleCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _vinController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _odometerController = TextEditingController();

  int? _selectedYear;

  @override
  void dispose() {
    _modelController.dispose();
    _vinController.dispose();
    _licensePlateController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Widget inputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final brightness = Theme.of(context).brightness;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.isEmpty ? 'Vui lòng nhập $label' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget yearSelector() {
    final currentYear = DateTime.now().year;
    final years = List.generate(30, (index) => currentYear - index);

    return InkWell(
      onTap: () => showSelectionModal(
        context: context,
        title: 'Chọn năm sản xuất',
        items: years
            .map((y) => {'id': y.toString(), 'name': y.toString()})
            .toList(),
        selectedId: _selectedYear?.toString(),
        onSelected: (id) => setState(() => _selectedYear = int.parse(id)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_selectedYear?.toString() ?? 'Chọn năm sản xuất'),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedYear != null) {
      final vehicleProvider = Provider.of<VehicleProvider>(
        context,
        listen: false,
      );

      final request = VehicleRequest(
        customerId: widget.customerId,
        model: _modelController.text,
        vin: _vinController.text,
        licensePlate: _licensePlateController.text,
        year: _selectedYear!,
        odometerKm: int.tryParse(_odometerController.text) ?? 0,
        status: 'Active',
      );

      try {
        final vehicle = await vehicleProvider.createVehicle(request);

        if (vehicle != null)
          Navigator.pop(context, vehicle); // trả về xe mới tạo
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo xe thất bại, vui lòng thử lại')),
        );
      }
    } else if (_selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn năm sản xuất')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo xe mới'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              inputField(
                label: 'Model',
                icon: Icons.directions_car,
                controller: _modelController,
              ),
              const SizedBox(height: 16),
              inputField(
                label: 'VIN',
                icon: Icons.qr_code,
                controller: _vinController,
              ),
              const SizedBox(height: 16),
              inputField(
                label: 'Biển số',
                icon: Icons.confirmation_number,
                controller: _licensePlateController,
              ),
              const SizedBox(height: 16),
              yearSelector(),
              const SizedBox(height: 16),
              inputField(
                label: 'Odometer (km)',
                icon: Icons.speed,
                controller: _odometerController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text('Tạo xe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
