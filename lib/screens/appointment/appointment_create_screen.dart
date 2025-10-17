import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../model/booking_request.dart';
import '../../widgets/selection_modal.dart';

class AppointmentCreateScreen extends StatefulWidget {
  final String customerId;

  const AppointmentCreateScreen({super.key, required this.customerId});

  @override
  State<AppointmentCreateScreen> createState() =>
      _AppointmentCreateScreenState();
}

class _AppointmentCreateScreenState extends State<AppointmentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;

  // MOCK DATA
  final List<Map<String, String>> _allStaff = List.generate(
    12,
    (index) => {'id': 'staff$index', 'name': 'Nhân viên $index'},
  );
  final List<Map<String, String>> _allVehicles = List.generate(
    12,
    (index) => {'id': 'vehicle$index', 'name': 'Xe Model $index'},
  );
  final List<Map<String, dynamic>> _serviceTypes = [
    {'id': 0, 'name': 'Bảo dưỡng cơ bản'},
    {'id': 1, 'name': 'Bảo dưỡng nâng cao'},
    {'id': 2, 'name': 'Sửa chữa'},
  ];

  String? _selectedStaffId;
  String? _selectedVehicleId;
  int? _selectedServiceTypeId;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        final primaryColor = Theme.of(context).colorScheme.primary;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedVehicleId != null &&
        _selectedStaffId != null &&
        _selectedServiceTypeId != null) {
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );

      final request = BookingRequest(
        customerId: widget.customerId,
        vehicleId: _selectedVehicleId!,
        serviceType: _selectedServiceTypeId!,
        scheduledDate: _selectedDate!.toUtc().toIso8601String(),
        notes: _notesController.text,
        staffId: _selectedStaffId!,
      );

      final success = await bookingProvider.createBooking(request);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tạo lịch thành công!')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bookingProvider.error ?? 'Lỗi không xác định'),
          ),
        );
      }
    }
  }

  Widget selectionTile({
    required String title,
    required String? selectedText,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(selectedText ?? title),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    final brightness = Theme.of(context).brightness;
    return InputDecoration(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo lịch bảo dưỡng'),
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
              // Chọn xe
              selectionTile(
                title: 'Chọn xe',
                selectedText: _selectedVehicleId == null
                    ? null
                    : _allVehicles.firstWhere(
                        (e) => e['id'] == _selectedVehicleId,
                      )['name'],
                onTap: () => showSelectionModal(
                  context: context,
                  title: 'Chọn xe',
                  items: _allVehicles,
                  selectedId: _selectedVehicleId,
                  onSelected: (id) => setState(() => _selectedVehicleId = id),
                ),
              ),
              const SizedBox(height: 16),

              // Chọn loại dịch vụ
              selectionTile(
                title: 'Chọn loại dịch vụ',
                selectedText: _selectedServiceTypeId == null
                    ? null
                    : _serviceTypes.firstWhere(
                        (e) => e['id'] == _selectedServiceTypeId,
                      )['name'],
                onTap: () => showSelectionModal(
                  context: context,
                  title: 'Chọn loại dịch vụ',
                  items: _serviceTypes,
                  selectedId: _selectedServiceTypeId,
                  onSelected: (id) =>
                      setState(() => _selectedServiceTypeId = id),
                ),
              ),
              const SizedBox(height: 16),

              // Ghi chú
              TextFormField(
                controller: _notesController,
                decoration: inputDecoration('Ghi chú', Icons.note),
              ),
              const SizedBox(height: 16),

              // Chọn ngày
              selectionTile(
                title: 'Chọn ngày',
                selectedText: _selectedDate == null
                    ? null
                    : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              // Chọn nhân viên
              selectionTile(
                title: 'Chọn nhân viên',
                selectedText: _selectedStaffId == null
                    ? null
                    : _allStaff.firstWhere(
                        (e) => e['id'] == _selectedStaffId,
                      )['name'],
                onTap: () => showSelectionModal(
                  context: context,
                  title: 'Chọn nhân viên',
                  items: _allStaff,
                  selectedId: _selectedStaffId,
                  onSelected: (id) => setState(() => _selectedStaffId = id),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: bookingProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submit,
                        child: const Text('Tạo lịch'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
