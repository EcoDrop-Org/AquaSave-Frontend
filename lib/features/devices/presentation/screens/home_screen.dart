import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/user_avatar.dart';
import '../../../irrigation_intelligence/presentation/bloc/weather_bloc.dart';
import '../bloc/devices_bloc.dart';
import '../widgets/active_device_card.dart';
import '../widgets/humidity_card.dart';
import '../widgets/quick_control_card.dart';
import '../widgets/weather_card.dart';

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
                  'Inicio',
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
            child: BlocConsumer<DevicesBloc, DevicesState>(
              listener: (context, state) {
                if (state is DevicesLoaded && state.devices.isNotEmpty) {
                  context.read<WeatherBloc>().add(
                    LoadWeatherForDevice(state.activeDevice),
                  );
                }
              },
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

                final device = state.activeDevice;

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buenos dias, $userName',
                            style: tt.headlineMedium?.copyWith(
                              color: const Color(0xFF2D3D2C),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Estado actual del huerto y decisiones de riego.',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.68),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceMd),
                          ActiveDeviceCard(device: device),
                          const SizedBox(height: AppDimensions.spaceMd),
                          LayoutBuilder(
                            builder: (context, c) {
                              final wide = c.maxWidth >= 600;
                              if (wide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: WeatherCard(device: device),
                                    ),
                                    const SizedBox(
                                      width: AppDimensions.spaceMd,
                                    ),
                                    Expanded(
                                      child: HumidityCard(device: device),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  WeatherCard(device: device),
                                  const SizedBox(height: AppDimensions.spaceMd),
                                  HumidityCard(device: device),
                                ],
                              );
                            },
                          ),
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
