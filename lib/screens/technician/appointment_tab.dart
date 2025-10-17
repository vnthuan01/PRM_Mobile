import 'package:flutter/material.dart';
import 'appointment_detail_tab.dart';

class TechnicianAppointmentsTab extends StatefulWidget {
  const TechnicianAppointmentsTab({super.key});

  @override
  State<TechnicianAppointmentsTab> createState() =>
      _TechnicianAppointmentsTabState();
}

class _TechnicianAppointmentsTabState extends State<TechnicianAppointmentsTab> {
  List<Map<String, dynamic>> appointments = [
    {
      "id": "APPT001",
      "vehicle": "VinFast VF3",
      "plate": "51H-88888",
      "time": "2025-10-16 14:00",
      "status": "In Progress",
      "progress": 60,
    },
    {
      "id": "APPT002",
      "vehicle": "Yadea Xmen Neo",
      "plate": "59D1-34567",
      "time": "2025-10-16 16:30",
      "status": "Pending",
      "progress": 0,
    },
  ];

  void _updateStatus(int index, String newStatus) {
    setState(() {
      appointments[index]["status"] = newStatus;
      appointments[index]["progress"] = newStatus == "Completed"
          ? 100
          : (newStatus == "In Progress" ? 50 : 0);
    });
  }

  Color _getStatusColor(String status, Color primary) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "In Progress":
        return primary;
      default:
        return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách lịch hẹn"),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: primary,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appt = appointments[index];
            final statusColor = _getStatusColor(appt["status"], primary);

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TechnicianAppointmentDetail(appointment: appt),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: primary.withOpacity(0.15),
                        child: Icon(
                          Icons.electric_bike,
                          color: primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appt["vehicle"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Biển số: ${appt["plate"]}",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Thời gian: ${appt["time"]}",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: appt["progress"] / 100,
                                minHeight: 6,
                                color: statusColor,
                                backgroundColor: Colors.grey.shade300,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  appt["status"],
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (v) => _updateStatus(index, v),
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: "Pending",
                                      child: Text("Pending"),
                                    ),
                                    PopupMenuItem(
                                      value: "In Progress",
                                      child: Text("In Progress"),
                                    ),
                                    PopupMenuItem(
                                      value: "Completed",
                                      child: Text("Completed"),
                                    ),
                                  ],
                                  icon: const Icon(Icons.more_vert, size: 20),
                                ),
                              ],
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
    );
  }
}
