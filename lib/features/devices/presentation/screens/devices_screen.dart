import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/user_avatar.dart';
import '../bloc/devices_bloc.dart';
import '../widgets/device_list_card.dart';
import 'device_detail_dialog.dart';

/// Frame 44-5 — Dispositivos. Solo renderiza contenido; el sidebar lo gestiona el router.
class DevicesScreen extends StatefulWidget {
  /// Llamado cuando el usuario toca "Agregar Dispositivo". El router lo maneja.
  final VoidCallback? onAddDevice;

  const DevicesScreen({super.key, this.onAddDevice});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DevicesBloc>().add(const LoadDevices());
  }

  @override
  Widget build(BuildContext context) =>
      _DevicesContent(onAddDevice: widget.onAddDevice);
}

class _DevicesContent extends StatelessWidget {
  final VoidCallback? onAddDevice;
  const _DevicesContent({this.onAddDevice});

  @override
  Widget build(BuildContext context) {
    final tt = AppTextStyles.of(context);
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 800;

    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated
        ? authState.user.name.split(' ').first
        : 'Usuario';
    final avatarUrl =
        authState is AuthAuthenticated ? authState.user.avatarUrl : null;

    return Column(
      children: [
        // Top bar
        Container(
          height: isWide ? 80 : 60,
          padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dispositivos',
                  style: tt.displayMedium
                      ?.copyWith(color: const Color(0xFF2D3D2C))),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined,
                        color: cs.onSurface, size: isWide ? 28 : 22),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  UserAvatar(
                      name: userName, avatarUrl: avatarUrl,
                      radius: isWide ? 24 : 18,
                      fontSize: 12),
                ],
              ),
            ],
          ),
        ),

        // Body
        Expanded(
          child: BlocBuilder<DevicesBloc, DevicesState>(
            builder: (context, state) {
              if (state is DevicesLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DevicesFailureState) {
                return Center(child: Text(state.message));
              }

              final devices =
                  state is DevicesLoaded ? state.devices : <dynamic>[];

              return SingleChildScrollView(
                padding: EdgeInsets.all(isWide ? AppDimensions.spaceLg : AppDimensions.spaceMd),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth >= 600;
                    return wide
                        ? _WideGrid(devices: devices, onAddDevice: onAddDevice)
                        : _NarrowList(devices: devices, onAddDevice: onAddDevice);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WideGrid extends StatelessWidget {
  final List<dynamic> devices;
  final VoidCallback? onAddDevice;
  const _WideGrid({required this.devices, this.onAddDevice});

  @override
  Widget build(BuildContext context) {
    final tt = AppTextStyles.of(context);

    return Wrap(
      spacing: AppDimensions.spaceMd,
      runSpacing: AppDimensions.spaceMd,
      children: [
        ...devices.map((d) => SizedBox(
              width: 480,
              child: DeviceListCard(device: d, onViewDetails: () => showDeviceDetailDialog(context, d)),
            )),
        SizedBox(
          width: 480,
          height: 220,
          child: _AddDeviceCard(
              textStyle: tt.displayMedium, onTap: onAddDevice),
        ),
      ],
    );
  }
}

class _NarrowList extends StatelessWidget {
  final List<dynamic> devices;
  final VoidCallback? onAddDevice;
  const _NarrowList({required this.devices, this.onAddDevice});

  @override
  Widget build(BuildContext context) {
    final tt = AppTextStyles.of(context);

    return Column(
      children: [
        ...devices.map((d) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.spaceMd),
              child: DeviceListCard(device: d, onViewDetails: () => showDeviceDetailDialog(context, d)),
            )),
        _AddDeviceCard(textStyle: tt.displayMedium, onTap: onAddDevice),
      ],
    );
  }
}

class _AddDeviceCard extends StatelessWidget {
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  const _AddDeviceCard({this.textStyle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap == null ? null : () => Future.delayed(Duration.zero, onTap!),
      borderRadius: BorderRadius.circular(46),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF37593F), width: 2),
          borderRadius: BorderRadius.circular(46),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                size: 56, color: cs.onSurface),
            const SizedBox(height: 16),
            Text('Agregar Dispositivo',
                style: textStyle?.copyWith(color: cs.onSurface)),
          ],
        ),
      ),
    );
  }
}
