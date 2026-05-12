import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

import 'core/l10n/app_localizations.dart';
import 'core/l10n/locale_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_cubit.dart';
import 'features/auth/data/datasources/local/auth_local_datasource.dart';
import 'features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/user_profile_screen.dart';
import 'features/devices/data/datasources/local/devices_local_datasource.dart';
import 'features/devices/data/datasources/remote/devices_remote_datasource.dart';
import 'features/devices/data/repositories/devices_repository_impl.dart';
import 'features/devices/domain/usecases/get_devices_usecase.dart';
import 'features/devices/presentation/bloc/devices_bloc.dart';
import 'features/devices/presentation/bloc/irrigation_cubit.dart';
import 'features/devices/presentation/screens/analysis_screen.dart';
import 'features/devices/presentation/screens/devices_screen.dart';
import 'features/devices/presentation/screens/history_screen.dart';
import 'features/devices/presentation/screens/home_screen.dart';
import 'features/devices/presentation/screens/settings_screen.dart';
import 'features/irrigation_intelligence/data/datasources/remote/weather_remote_datasource.dart';
import 'features/irrigation_intelligence/data/repositories/weather_repository_impl.dart';
import 'features/irrigation_intelligence/domain/usecases/get_current_weather_for_device_usecase.dart';
import 'features/irrigation_intelligence/presentation/bloc/weather_bloc.dart';
import 'features/subscription/presentation/cubit/plan_cubit.dart';
import 'shared/widgets/app_sidebar.dart';

const bool useMock = true;

void main() {
  runApp(const AquaSaveApp());
}

class AquaSaveApp extends StatelessWidget {
  const AquaSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepositoryImpl(
      localDataSource: AuthLocalDataSourceImpl(),
      remoteDataSource: AuthRemoteDataSourceImpl(),
      useMock: useMock,
    );
    final devicesRepo = DevicesRepositoryImpl(
      localDataSource: DevicesLocalDataSourceImpl(),
      remoteDataSource: DevicesRemoteDataSourceImpl(),
      useMock: useMock,
    );
    final weatherRepo = WeatherRepositoryImpl(
      remoteDataSource: OpenMeteoWeatherRemoteDataSource(client: http.Client()),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
        BlocProvider<ThemeModeCubit>(create: (_) => ThemeModeCubit()),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: LoginUseCase(authRepo),
            registerUseCase: RegisterUseCase(authRepo),
          ),
        ),
        BlocProvider<DevicesBloc>(
          create: (_) =>
              DevicesBloc(getDevicesUseCase: GetDevicesUseCase(devicesRepo)),
        ),
        BlocProvider<WeatherBloc>(
          create: (_) => WeatherBloc(
            getCurrentWeatherForDeviceUseCase:
                GetCurrentWeatherForDeviceUseCase(weatherRepo),
          ),
        ),
        BlocProvider<IrrigationCubit>(create: (_) => IrrigationCubit()),
        BlocProvider<PlanCubit>(create: (_) => PlanCubit()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeModeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                title: 'AquaSave',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const _AppRouter(),
              );
            },
          );
        },
      ),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  _AuthScreen _authScreen = _AuthScreen.login;
  _AppScreen _appScreen = _AppScreen.home;
  String? _lastWeatherDeviceKey;

  void _goTo(_AppScreen screen) => setState(() => _appScreen = screen);

  void _onSidebarTap(SidebarItem item) {
    switch (item) {
      case SidebarItem.home:
        _goTo(_AppScreen.home);
      case SidebarItem.devices:
        _goTo(_AppScreen.devices);
      case SidebarItem.analysis:
        _goTo(_AppScreen.analysis);
      case SidebarItem.history:
        _goTo(_AppScreen.history);
      case SidebarItem.profile:
        _goTo(_AppScreen.profile);
      case SidebarItem.settings:
        _goTo(_AppScreen.settings);
    }
  }

  SidebarItem get _activeSidebarItem => switch (_appScreen) {
    _AppScreen.home => SidebarItem.home,
    _AppScreen.devices => SidebarItem.devices,
    _AppScreen.analysis => SidebarItem.analysis,
    _AppScreen.history => SidebarItem.history,
    _AppScreen.profile => SidebarItem.profile,
    _AppScreen.settings => SidebarItem.settings,
  };

  Widget get _currentScreen => switch (_appScreen) {
    _AppScreen.home => const HomeScreen(),
    _AppScreen.devices => const DevicesScreen(),
    _AppScreen.analysis => const AnalysisScreen(),
    _AppScreen.history => const HistoryScreen(),
    _AppScreen.profile => const UserProfileScreen(),
    _AppScreen.settings => const SettingsScreen(),
  };

  void _loadWeatherForActiveDevice(BuildContext context, DevicesState state) {
    if (state is! DevicesLoaded || state.devices.isEmpty) return;

    final device = state.activeDevice;
    final deviceKey = '${device.id}:${device.location}';
    if (_lastWeatherDeviceKey == deviceKey) return;

    _lastWeatherDeviceKey = deviceKey;
    context.read<WeatherBloc>().add(LoadWeatherForDevice(device));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          setState(() => _appScreen = _AppScreen.home);
        }
        if (state is AuthInitial) {
          setState(() => _authScreen = _AuthScreen.login);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return switch (_authScreen) {
              _AuthScreen.login => LoginScreen(
                onGoToRegister: () =>
                    setState(() => _authScreen = _AuthScreen.register),
                onLoginSuccess: () {},
              ),
              _AuthScreen.register => RegisterScreen(
                onGoToLogin: () =>
                    setState(() => _authScreen = _AuthScreen.login),
                onRegisterSuccess: () {},
              ),
            };
          }

          return BlocListener<DevicesBloc, DevicesState>(
            listener: _loadWeatherForActiveDevice,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final l10n = AppLocalizations.of(context);
                final isWide = constraints.maxWidth >= 800;

                if (isWide) {
                  return Scaffold(
                    body: Row(
                      children: [
                        AppSidebar(
                          activeItem: _activeSidebarItem,
                          onItemTap: _onSidebarTap,
                        ),
                        Expanded(child: _currentScreen),
                      ],
                    ),
                  );
                }

                return Scaffold(
                  body: _currentScreen,
                  bottomNavigationBar: NavigationBar(
                    selectedIndex: _appScreen.index,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.onlyShowSelected,
                    onDestinationSelected: (i) => _goTo(_AppScreen.values[i]),
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(Icons.home_outlined),
                        label: l10n.t('navHome'),
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.devices_outlined),
                        label: l10n.t('navDevices'),
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.bar_chart_outlined),
                        label: l10n.t('navAnalysis'),
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.description_outlined),
                        label: l10n.t('navHistory'),
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.person_outline),
                        label: l10n.t('navProfile'),
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.settings_outlined),
                        label: l10n.t('navSettings'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

enum _AuthScreen { login, register }

enum _AppScreen { home, devices, analysis, history, profile, settings }
