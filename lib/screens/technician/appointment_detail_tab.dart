import 'package:flutter/material.dart';

class TechnicianAppointmentDetail extends StatefulWidget {
  final Map<String, dynamic> appointment;
  const TechnicianAppointmentDetail({super.key, required this.appointment});

  @override
  State<TechnicianAppointmentDetail> createState() =>
      _TechnicianAppointmentDetailState();
}

class _TechnicianAppointmentDetailState
    extends State<TechnicianAppointmentDetail> {
  final List<Map<String, dynamic>> steps = [
    {"name": "Kiểm tra tổng quan", "done": true},
    {"name": "Thay pin / kiểm tra điện", "done": false},
    {"name": "Lau chùi & vệ sinh xe", "done": false},
    {"name": "Kiểm tra phanh và lốp", "done": false},
    {"name": "Kiểm thử vận hành", "done": false},
  ];

  @override
  Widget build(BuildContext context) {
    final appt = widget.appointment;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết ${appt["id"]}"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Xe: ${appt["vehicle"]} (${appt["plate"]})",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text("Thời gian: ${appt["time"]}"),
            const SizedBox(height: 16),
            const Text(
              "Các bước bảo dưỡng:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return CheckboxListTile(
                    value: step["done"],
                    title: Text(step["name"]),
                    activeColor: primaryColor,
                    onChanged: (v) {
                      setState(() => step["done"] = v ?? false);
                    },
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Hoàn tất bảo dưỡng"),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đã cập nhật tiến độ xe thành công!"),
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
