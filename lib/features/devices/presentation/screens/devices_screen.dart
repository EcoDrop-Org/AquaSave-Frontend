import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/user_avatar.dart';
import '../bloc/devices_bloc.dart';
import '../widgets/device_list_card.dart';

/// Frame 44-5 — Dispositivos. Solo renderiza contenido; el sidebar lo gestiona el router.
class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

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
  Widget build(BuildContext context) => _DevicesContent();
}

class _DevicesContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

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
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 32),
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
                        color: cs.onSurface, size: 28),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  UserAvatar(
                      name: userName, avatarUrl: avatarUrl, radius: 24,
                      fontSize: 14),
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
                padding: const EdgeInsets.all(AppDimensions.spaceLg),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth >= 600;
                    return wide
                        ? _WideGrid(devices: devices)
                        : _NarrowList(devices: devices);
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
  const _WideGrid({required this.devices});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Wrap(
      spacing: AppDimensions.spaceMd,
      runSpacing: AppDimensions.spaceMd,
      children: [
        ...devices.map((d) => SizedBox(
              width: 480,
              child: DeviceListCard(
                device: d,
                onViewDetails: () {},
              ),
            )),
        // Agregar dispositivo
        SizedBox(
          width: 480,
          height: 289,
          child: _AddDeviceCard(textStyle: tt.displayMedium),
        ),
      ],
    );
  }
}

class _NarrowList extends StatelessWidget {
  final List<dynamic> devices;
  const _NarrowList({required this.devices});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        ...devices.map((d) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.spaceMd),
              child: DeviceListCard(device: d, onViewDetails: () {}),
            )),
        _AddDeviceCard(textStyle: tt.displayMedium),
      ],
    );
  }
}

class _AddDeviceCard extends StatelessWidget {
  final TextStyle? textStyle;
  const _AddDeviceCard({this.textStyle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {},
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
