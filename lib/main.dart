import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
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
import 'features/analytics/presentation/screens/analytics_screen.dart';
import 'features/devices/presentation/screens/add_device_dialog.dart';
import 'features/devices/presentation/screens/devices_screen.dart';
import 'features/devices/presentation/screens/home_screen.dart';
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

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: LoginUseCase(authRepo),
            registerUseCase: RegisterUseCase(authRepo),
          ),
        ),
        BlocProvider<DevicesBloc>(
          create: (_) => DevicesBloc(
            getDevicesUseCase: GetDevicesUseCase(devicesRepo),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AquaSave',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const _AppRouter(),
      ),
    );
  }
}

// ── Router ────────────────────────────────────────────────────────────────────

enum _AuthScreen { login, register }
enum _AppScreen  { home, devices, analytics, profile }

class _AppRouter extends StatefulWidget {
  const _AppRouter();
  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  _AuthScreen _authScreen = _AuthScreen.login;
  _AppScreen  _appScreen  = _AppScreen.home;

  void _goTo(_AppScreen s) => setState(() => _appScreen = s);

  void _onSidebarTap(SidebarItem item) {
    switch (item) {
      case SidebarItem.home:     _goTo(_AppScreen.home);
      case SidebarItem.devices:  _goTo(_AppScreen.devices);
      case SidebarItem.analysis: _goTo(_AppScreen.analytics);
      case SidebarItem.profile:  _goTo(_AppScreen.profile);
      default: break;
    }
  }

  SidebarItem get _activeSidebar => switch (_appScreen) {
    _AppScreen.home      => SidebarItem.home,
    _AppScreen.devices   => SidebarItem.devices,
    _AppScreen.analytics => SidebarItem.analysis,
    _AppScreen.profile   => SidebarItem.profile,
  };

  int get _navIndex => switch (_appScreen) {
    _AppScreen.home      => 0,
    _AppScreen.devices   => 1,
    _AppScreen.analytics => 2,
    _AppScreen.profile   => 3,
  };

  Widget get _screen => switch (_appScreen) {
    _AppScreen.home    => const HomeScreen(),
    _AppScreen.devices => DevicesScreen(
        onAddDevice: () => showAddDeviceDialog(context),
      ),
    _AppScreen.analytics => const AnalyticsScreen(),
    _AppScreen.profile   => const UserProfileScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) setState(() => _appScreen = _AppScreen.home);
        if (state is AuthInitial)       setState(() => _authScreen = _AuthScreen.login);
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return switch (_authScreen) {
              _AuthScreen.login => LoginScreen(
                  onGoToRegister: () => setState(() => _authScreen = _AuthScreen.register),
                  onLoginSuccess: () {},
                ),
              _AuthScreen.register => RegisterScreen(
                  onGoToLogin: () => setState(() => _authScreen = _AuthScreen.login),
                  onRegisterSuccess: () {},
                ),
            };
          }

          final wide = MediaQuery.of(context).size.width >= 800;

          return Scaffold(
            body: SafeArea(
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppSidebar(activeItem: _activeSidebar, onItemTap: _onSidebarTap),
                        Expanded(child: _screen),
                      ],
                    )
                  : _screen,
            ),
            bottomNavigationBar: wide
                ? null
                : NavigationBar(
                    selectedIndex: _navIndex,
                    onDestinationSelected: (i) => _goTo(
                      switch (i) {
                        0 => _AppScreen.home,
                        1 => _AppScreen.devices,
                        2 => _AppScreen.analytics,
                        _ => _AppScreen.profile,
                      }
                    ),
                    destinations: const [
                      NavigationDestination(icon: Icon(Icons.home_outlined),      label: 'Inicio'),
                      NavigationDestination(icon: Icon(Icons.devices_outlined),   label: 'Dispositivos'),
                      NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Análisis'),
                      NavigationDestination(icon: Icon(Icons.person_outline),     label: 'Perfil'),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
