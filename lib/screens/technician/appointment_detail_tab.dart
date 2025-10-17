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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết ${appt["id"]}"),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Card ảnh + thông tin ---
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh full width
                  Stack(
                    children: [
                      Image.network(
                        appt["imageUrl"] ??
                            "https://photo2.tinhte.vn/data/attachment-files/2023/08/7237945_VinFast-VF3-tinhte-21.jpg",
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Lớp gradient mờ ở dưới để chữ dễ đọc
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Thông tin nằm đè trên ảnh
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appt["vehicle"] ?? "Xe chưa xác định",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Biển số: ${appt["plate"] ?? "N/A"}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Thời gian: ${appt["time"] ?? "Chưa rõ"}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Mô tả bên dưới ảnh
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Mô tả chi tiết:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appt["description"] ??
                              "Khách hàng phản ánh xe có tiếng kêu khi vận hành. Cần kiểm tra pin và hệ thống phanh.",
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Các bước bảo dưỡng ---
            Text(
              "Các bước bảo dưỡng:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return Card(
                    elevation: isDark ? 0 : 1,
                    margin: const EdgeInsets.only(bottom: 10),
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CheckboxListTile(
                      value: step["done"],
                      activeColor: primary,
                      title: Text(
                        step["name"],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: step["done"]
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: step["done"]
                              ? primary
                              : (isDark
                                    ? Colors.grey.shade200
                                    : Colors.grey.shade800),
                        ),
                      ),
                      onChanged: (v) =>
                          setState(() => step["done"] = v ?? false),
                    ),
                  );
                },
              ),
            ),

            // --- Nút hoàn tất ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: isDark ? 0 : 2,
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                "Hoàn tất bảo dưỡng",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
