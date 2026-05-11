import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/user_avatar.dart';
import '../../domain/entities/device.dart';
import '../bloc/devices_bloc.dart';
import '../widgets/device_list_card.dart';

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
    final avatarUrl = authState is AuthAuthenticated
        ? authState.user.avatarUrl
        : null;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            height: 88,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(color: cs.outline.withValues(alpha: 0.32)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dispositivos',
                  style: tt.headlineMedium?.copyWith(
                    color: const Color(0xFF2D3D2C),
                  ),
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Notificaciones',
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: cs.onSurface,
                        size: 24,
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 12),
                    UserAvatar(
                      name: userName,
                      avatarUrl: avatarUrl,
                      radius: 22,
                      fontSize: 13,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DevicesBloc, DevicesState>(
              builder: (context, state) {
                if (state is DevicesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DevicesFailureState) {
                  return Center(child: Text(state.message));
                }

                final devices = state is DevicesLoaded
                    ? state.devices
                    : <Device>[];

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spaceLg,
                    AppDimensions.spaceLg,
                    AppDimensions.spaceLg,
                    AppDimensions.spaceXl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final wide = c.maxWidth >= 660;
                          return wide
                              ? _WideGrid(devices: devices)
                              : _NarrowList(devices: devices);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WideGrid extends StatelessWidget {
  final List<Device> devices;

  const _WideGrid({required this.devices});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spaceMd,
      runSpacing: AppDimensions.spaceMd,
      children: [
        ...devices.map(
          (device) => SizedBox(
            width: 420,
            child: DeviceListCard(
              device: device,
              isActive: _isActive(context, device),
              onViewDetails: () => context.read<DevicesBloc>().add(
                SelectActiveDevice(device.id),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 420,
          height: 260,
          child: _AddDeviceCard(onTap: () => _showAddDeviceDialog(context)),
        ),
      ],
    );
  }

  bool _isActive(BuildContext context, Device device) {
    final state = context.watch<DevicesBloc>().state;
    return state is DevicesLoaded && state.activeDevice.id == device.id;
  }
}

class _NarrowList extends StatelessWidget {
  final List<Device> devices;

  const _NarrowList({required this.devices});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...devices.map(
          (device) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
            child: DeviceListCard(
              device: device,
              isActive: _isActive(context, device),
              onViewDetails: () => context.read<DevicesBloc>().add(
                SelectActiveDevice(device.id),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: _AddDeviceCard(onTap: () => _showAddDeviceDialog(context)),
        ),
      ],
    );
  }

  bool _isActive(BuildContext context, Device device) {
    final state = context.watch<DevicesBloc>().state;
    return state is DevicesLoaded && state.activeDevice.id == device.id;
  }
}

class _AddDeviceCard extends StatefulWidget {
  final VoidCallback onTap;

  const _AddDeviceCard({required this.onTap});

  @override
  State<_AddDeviceCard> createState() => _AddDeviceCardState();
}

class _AddDeviceCardState extends State<_AddDeviceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _hovered ? 1.01 : 1,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.24),
              border: Border.all(
                color: const Color(0xFF37593F).withValues(alpha: 0.48),
                width: 1.4,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 48, color: cs.onSurface),
                const SizedBox(height: 14),
                Text(
                  'Agregar dispositivo',
                  textAlign: TextAlign.center,
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showAddDeviceDialog(BuildContext context) async {
  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final plantCountCtrl = TextEditingController(text: '1');
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final tt = Theme.of(dialogContext).textTheme;
      final cs = Theme.of(dialogContext).colorScheme;

      return AlertDialog(
        title: Text(
          'Registrar dispositivo',
          style: tt.headlineMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del huerto',
                    prefixIcon: Icon(Icons.sensors_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Ingresa un nombre valido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spaceMd),
                TextFormField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ubicacion del huerto',
                    hintText: 'Ej. Miraflores, Lima',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Ingresa una ubicacion valida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spaceMd),
                TextFormField(
                  controller: plantCountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad de plantas',
                    prefixIcon: Icon(Icons.eco_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed < 1) {
                      return 'Ingresa al menos 1 planta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                Text(
                  'La ubicacion se usara para buscar el clima actual del huerto. La persistencia queda pendiente hasta integrar Backend.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.66),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              context.read<DevicesBloc>().add(
                AddDeviceRequested(
                  name: nameCtrl.text.trim(),
                  location: locationCtrl.text.trim(),
                  plantCount: int.parse(plantCountCtrl.text.trim()),
                ),
              );
              Navigator.of(dialogContext).pop();
            },
            icon: const Icon(Icons.add),
            label: const Text('Registrar'),
          ),
        ],
      );
    },
  );

  nameCtrl.dispose();
  locationCtrl.dispose();
  plantCountCtrl.dispose();
}
