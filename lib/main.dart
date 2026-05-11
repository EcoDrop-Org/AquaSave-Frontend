import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_colors.dart';
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
import 'features/history/presentation/screens/history_screen.dart';
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
enum _AppScreen  { home, devices, analytics, history, profile }

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
      case SidebarItem.history:  _goTo(_AppScreen.history);
      case SidebarItem.profile:  _goTo(_AppScreen.profile);
      default: break;
    }
  }

  SidebarItem get _activeSidebar => switch (_appScreen) {
    _AppScreen.home      => SidebarItem.home,
    _AppScreen.devices   => SidebarItem.devices,
    _AppScreen.analytics => SidebarItem.analysis,
    _AppScreen.history   => SidebarItem.history,
    _AppScreen.profile   => SidebarItem.profile,
  };

  int get _navIndex => switch (_appScreen) {
    _AppScreen.home      => 0,
    _AppScreen.devices   => 1,
    _AppScreen.analytics => 2,
    _AppScreen.history   => 3,
    _AppScreen.profile   => 4,
  };

  Widget get _screen => switch (_appScreen) {
    _AppScreen.home    => const HomeScreen(),
    _AppScreen.devices => DevicesScreen(
        onAddDevice: () => showAddDeviceDialog(context),
      ),
    _AppScreen.analytics => const AnalyticsScreen(),
    _AppScreen.history   => const HistoryScreen(),
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
                : _AppBottomNav(
                    selectedIndex: _navIndex,
                    onTap: (i) => _goTo(
                      switch (i) {
                        0 => _AppScreen.home,
                        1 => _AppScreen.devices,
                        2 => _AppScreen.analytics,
                        3 => _AppScreen.history,
                        _ => _AppScreen.profile,
                      },
                    ),
                  ),
          );
        },
      ),
    );
  }
}

// ── Bottom navigation bar (mobile) ───────────────────────────────────────────

class _AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _AppBottomNav({required this.selectedIndex, required this.onTap});

  static const _items = [
    (Icons.home_outlined,        Icons.home,        'Inicio'),
    (Icons.devices_outlined,     Icons.devices,     'Dispositivos'),
    (Icons.bar_chart_outlined,   Icons.bar_chart,   'Análisis'),
    (Icons.description_outlined, Icons.description, 'Historial'),
    (Icons.person_outline,       Icons.person,      'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    const activeColor = AppColors.lightPrimary;
    final inactiveColor = cs.onSurface.withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final (outlinedIcon, filledIcon, label) = _items[i];
              final isSelected = i == selectedIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? filledIcon : outlinedIcon,
                        color: isSelected ? activeColor : inactiveColor,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? activeColor : inactiveColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
