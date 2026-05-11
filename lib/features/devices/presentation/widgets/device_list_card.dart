import 'package:flutter/material.dart';
import '../../domain/entities/device.dart';

/// Tarjeta de dispositivo individual en la lista (Frame Dispositivos).
class DeviceListCard extends StatelessWidget {
  final Device device;
  final VoidCallback? onViewDetails;

  const DeviceListCard({
    super.key,
    required this.device,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF94BC9A),
        borderRadius: BorderRadius.circular(46),
        border: Border.all(color: const Color(0xFF37593F), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF43574A),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi,
                      color: Colors.white,
                      size: 16),
                  const SizedBox(width: 6),
                  Text(
                    device.status == DeviceStatus.online
                        ? 'En línea'
                        : 'Sin conexión',
                    style: tt.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(device.name,
              style: tt.displayMedium?.copyWith(color: Colors.black)),
          const Divider(color: Colors.black54, thickness: 1, height: 20),
          // Stats row
          Row(
            children: [
              const Icon(Icons.eco_outlined, color: Colors.black54, size: 18),
              const SizedBox(width: 4),
              Text('${device.plantCount} Plantas',
                  style: tt.bodySmall?.copyWith(color: Colors.white)),
              const SizedBox(width: 20),
              const Icon(Icons.battery_3_bar, color: Colors.black54, size: 18),
              const SizedBox(width: 4),
              Text('${device.batteryPct}%',
                  style: tt.bodySmall
                      ?.copyWith(color: Colors.black, fontSize: 10)),
              const SizedBox(width: 2),
              Text('Batería',
                  style: tt.bodySmall?.copyWith(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onViewDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3E5C48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 2,
            ),
            child: Text('Ver Detalles',
                style: tt.bodyLarge?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
