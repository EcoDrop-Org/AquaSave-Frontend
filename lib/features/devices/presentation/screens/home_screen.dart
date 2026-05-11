import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/user_avatar.dart';
import '../bloc/devices_bloc.dart';
import '../widgets/active_device_card.dart';
import '../widgets/humidity_card.dart';
import '../widgets/quick_control_card.dart';
import '../widgets/weather_card.dart';

/// Frame 44-4 — Inicio (Home). Solo renderiza contenido; el sidebar lo gestiona el router.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DevicesBloc>().add(const LoadDevices());
  }

  @override
  Widget build(BuildContext context) {
    return _HomeContent();
  }
}

class _HomeContent extends StatelessWidget {
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
              Text('Inicio',
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
              if (state is! DevicesLoaded || state.devices.isEmpty) {
                return const Center(child: Text('Sin dispositivos'));
              }

              final device = state.devices.first;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Buenos días , $userName',
                        style: tt.displayMedium
                            ?.copyWith(color: const Color(0xFF2D3D2C))),
                    const SizedBox(height: AppDimensions.spaceLg),
                    ActiveDeviceCard(device: device),
                    const SizedBox(height: AppDimensions.spaceMd),
                    LayoutBuilder(builder: (context, c) {
                      final wide = c.maxWidth >= 600;
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: WeatherCard(device: device)),
                            const SizedBox(width: AppDimensions.spaceMd),
                            Expanded(child: HumidityCard(device: device)),
                          ],
                        );
                      }
                      return Column(children: [
                        WeatherCard(device: device),
                        const SizedBox(height: AppDimensions.spaceMd),
                        HumidityCard(device: device),
                      ]);
                    }),
                    const SizedBox(height: AppDimensions.spaceMd),
                    QuickControlCard(
                      onStartIrrigation: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Riego iniciado')),
                        );
                      },
                      onStopIrrigation: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Riego detenido')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
