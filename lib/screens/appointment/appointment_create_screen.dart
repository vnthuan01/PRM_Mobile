import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../model/dto/request/booking_request.dart';
import '../../model/dto/response/vehicle_response.dart';
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
  DateTime? _selectedDateTime;

  String? _selectedVehicleId;
  int? _selectedServiceTypeId;

  bool _loadingVehicles = true;
  List<VehicleResponse> _vehicles = [];

  final List<Map<String, dynamic>> _serviceTypes = [
    {'id': 0, 'name': 'Bảo dưỡng cơ bản'},
    {'id': 1, 'name': 'Sửa chữa'},
  ];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicleProvider = Provider.of<VehicleProvider>(
        context,
        listen: false,
      );
      final vehicles = await vehicleProvider.fetchVehicles(widget.customerId);

      setState(() {
        _vehicles = vehicles;
        _loadingVehicles = false;
      });
    } catch (e) {
      print('[AppointmentCreateScreen] fetchVehicles error: $e');
      setState(() => _loadingVehicles = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể tải danh sách xe: $e')));
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() => _selectedDateTime = selectedDateTime);
      }
    }
  }

  void _submit() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate() &&
        _selectedDateTime != null &&
        _selectedVehicleId != null &&
        _selectedServiceTypeId != null) {
      try {
        final bookingProvider = Provider.of<BookingProvider>(
          context,
          listen: false,
        );

        final request = BookingRequest(
          customerId: widget.customerId,
          vehicleId: _selectedVehicleId!,
          serviceType: _selectedServiceTypeId!,
          scheduledDate: _selectedDateTime!.toUtc().toIso8601String(),
          notes: _notesController.text.isNotEmpty
              ? _notesController.text.trim()
              : null,
        );

        final response = await bookingProvider.createBooking(request);

        final success = response?.success ?? false;
        final message =
            response?.message ??
            (success
                ? 'Đặt lịch thành công!'
                : 'Đặt lịch thất bại, vui lòng thử lại.');

        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            content: Text(message),
            backgroundColor: success ? Colors.green : Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );

        if (success) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (context.mounted) Navigator.pop(context, true);
        }
      } catch (e, st) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            content: Text('Lỗi không xác định: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
        debugPrint('[ERROR] $e\n$st');
      }
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Color.fromARGB(255, 255, 162, 41),
        ),
      );
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
            Expanded(
              child: Text(
                selectedText ?? title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
      ),
      body: _loadingVehicles
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
          ? const Center(child: Text('Bạn chưa có xe nào!'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // chọn xe
                    selectionTile(
                      title: 'Chọn xe',
                      selectedText: _selectedVehicleId == null
                          ? null
                          : _vehicles
                                .firstWhere(
                                  (e) => e.id == _selectedVehicleId,
                                  orElse: () => _vehicles.first,
                                )
                                .model,
                      onTap: () => showSelectionModal(
                        context: context,
                        title: 'Chọn xe',
                        items: _vehicles
                            .map(
                              (v) => {
                                'id': v.id,
                                'name': v.model ?? 'Xe không rõ tên',
                              },
                            )
                            .toList(),
                        selectedId: _selectedVehicleId,
                        onSelected: (id) =>
                            setState(() => _selectedVehicleId = id),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // chọn loại dịch vụ
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

                    TextFormField(
                      controller: _notesController,
                      decoration: inputDecoration('Ghi chú', Icons.note),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),

                    selectionTile(
                      title: 'Chọn ngày/Giờ',
                      selectedText: _selectedDateTime == null
                          ? null
                          : _selectedDateTime!.toLocal().toString().substring(
                              0,
                              16,
                            ),
                      onTap: _selectDateTime,
                    ),
                    const SizedBox(height: 24),

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
