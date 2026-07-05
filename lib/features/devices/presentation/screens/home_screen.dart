import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../irrigation_intelligence/presentation/bloc/weather_bloc.dart';
import '../bloc/devices_bloc.dart';
import '../widgets/active_device_card.dart';
import '../widgets/quick_control_card.dart';
import '../widgets/weather_advice_card.dart';

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
    return const _HomeContent();
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated
        ? authState.user.name.split(' ').first
        : l10n.t('userFallback');
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AppHeader(title: l10n.t('navHome')),
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
                  return Center(child: Text(l10n.t('noDevices')));
                }

                final device = state.activeDevice;

                // El pronostico solo se usa para recomendar sobre el riego.
                final weatherState = context.watch<WeatherBloc>().state;
                final forecast =
                    weatherState is WeatherLoaded &&
                        weatherState.forecast.deviceId == device.id
                    ? weatherState.forecast
                    : null;

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
                            l10n.greeting(userName),
                            style: tt.headlineMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.t('homeSubtitle'),
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.68),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceMd),
                          ActiveDeviceCard(device: device),
                          const SizedBox(height: AppDimensions.spaceMd),
                          // Advertencias/recomendaciones de riego segun clima.
                          WeatherAdviceCard(forecast: forecast),
                          if (forecast != null)
                            const SizedBox(height: AppDimensions.spaceMd),
                          QuickControlCard(
                            deviceId: device.id,
                            onStartIrrigation: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.t('irrigationStarted')),
                                ),
                              );
                            },
                            onStopIrrigation: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.t('irrigationStopped')),
                                ),
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
