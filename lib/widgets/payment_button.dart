import 'package:flutter/material.dart';
import 'package:prm_project/model/maintenance.dart';
import 'package:prm_project/providers/maintence_provider.dart';
import 'package:prm_project/providers/auth_provider.dart';
import 'package:prm_project/services/payment_serivce.dart';
import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PaymentButton extends StatefulWidget {
  /// Nếu true thì auto tạo payment cho tất cả completed maintenances
  final bool autoPay;

  const PaymentButton({super.key, this.autoPay = false});

  @override
  State<PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<PaymentButton> {
  final _paymentService = PaymentService();
  bool _isLoading = false;

  Future<void> _createPayment({List<Maintenance>? selectedMaintenances}) async {
    final authProvider = context.read<AuthProvider>();
    final staffId = authProvider.staffId;

    if (staffId == null || staffId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không xác định được kỹ thuật viên.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final maintenanceProvider = context.read<MaintenanceProvider>();
      await maintenanceProvider.fetchMaintenances(
        userId: staffId,
        role: UserRole.Technician,
        newPagesize: 100,
      );

      final List<Maintenance> maintenances = maintenanceProvider.maintenances
          .where((m) => m.isCompleted)
          .toList();

      if (maintenances.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có bảo dưỡng hoàn thành nào.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final toPay = selectedMaintenances ?? maintenances;

      for (final maintenance in toPay) {
        final bookingId = maintenance.bookingId;
        final payment = await _paymentService.createPayment(bookingId);

        final checkoutUrl = payment?.data?.paymentLink?.checkoutUrl?.trim();
        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          print('[PaymentButton] Launching URL: $checkoutUrl');

          // Dùng launchUrlString cho ổn định
          try {
            if (await canLaunchUrlString(checkoutUrl)) {
              await launchUrlString(
                checkoutUrl,
                mode: LaunchMode.externalApplication,
              );
            } else {
              print('[PaymentButton] Cannot launch URL: $checkoutUrl');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Không thể mở liên kết thanh toán.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          } catch (e) {
            print('[PaymentButton] Launch error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi mở liên kết thanh toán: $e'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        } else {
          print(
            '[PaymentButton] Checkout URL is null or empty for bookingId: $bookingId',
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tạo thanh toán.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showSelectMaintenanceModal(
    List<Maintenance> maintenances,
  ) async {
    final selected = <Maintenance>{};

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Chọn bảo dưỡng để thanh toán',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: maintenances.length,
                      itemBuilder: (context, index) {
                        final m = maintenances[index];
                        final isSelected = selected.contains(m);
                        return CheckboxListTile(
                          title: Text(
                            'Mã: ${m.maintenanceId}\nXe: ${m.vehicleModel ?? ''}',
                          ),
                          subtitle: Text('Ngày: ${m.serviceDate}'),
                          value: isSelected,
                          onChanged: (val) {
                            setStateModal(() {
                              if (val == true) {
                                selected.add(m);
                              } else {
                                selected.remove(m);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: selected.isEmpty
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            _createPayment(
                              selectedMaintenances: selected.toList(),
                            );
                          },
                    child: const Text('Tạo thanh toán cho các mục đã chọn'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _isLoading
          ? null
          : () async {
              final authProvider = context.read<AuthProvider>();
              final staffId = authProvider.staffId;

              if (staffId == null) return;

              final maintenanceProvider = context.read<MaintenanceProvider>();
              await maintenanceProvider.fetchMaintenances(
                userId: staffId,
                role: UserRole.Technician,
                newPagesize: 100,
              );

              final completed = maintenanceProvider.maintenances
                  .where((m) => m.isCompleted)
                  .toList();

              if (completed.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không có bảo dưỡng hoàn thành nào.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              if (widget.autoPay) {
                // Auto tạo payment cho tất cả
                _createPayment(selectedMaintenances: completed);
              } else {
                // Hiển thị list cho tech chọn
                _showSelectMaintenanceModal(completed);
              }
            },
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.payment_rounded, color: Colors.white),
      label: Text(
        _isLoading ? 'Đang xử lý...' : 'Tạo thanh toán',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
