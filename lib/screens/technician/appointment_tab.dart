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
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appt = appointments[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: primary.withOpacity(0.15),
                  child: const Icon(Icons.build, color: Colors.black87),
                ),
                title: Text("${appt["vehicle"]} (${appt["plate"]})"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Thời gian: ${appt["time"]}"),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: appt["progress"] / 100,
                      color: primary,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 4),
                    Text("Trạng thái: ${appt["status"]}"),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) => _updateStatus(index, v),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "Pending", child: Text("Pending")),
                    PopupMenuItem(
                      value: "In Progress",
                      child: Text("In Progress"),
                    ),
                    PopupMenuItem(value: "Completed", child: Text("Completed")),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TechnicianAppointmentDetail(appointment: appt),
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
