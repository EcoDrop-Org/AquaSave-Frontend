class AppConstants {
  AppConstants._();

  // Routes
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeProfile = '/profile';
  static const String routeHome = '/home';

  // Mock asset paths
  static const String mockAuthPath = 'assets/mock/auth.json';

  // Cuando es true usa los JSON locales de assets/mock en lugar de la API.
  // Se puede forzar con: flutter run --dart-define=USE_MOCK=true
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: false,
  );

  // API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://aquasave-backend.onrender.com',
  );
  static const String authTokenKey = 'auth_token';
  static const String authExpiresAtKey = 'auth_expires_at';

  // Image asset paths
  static const String imgLoginPlant = 'assets/images/login-plant.png';
  static const String imgCactusSidebar = 'assets/images/cactus-sidebar.png';
  static const String imgAquaSaveLogo = 'assets/images/AquaSaveLogo.PNG';
  static const String imgAquaSaveLogoWhite =
      'assets/images/AquaSaveLogoBlanco.png';
  static const String imgAvatarPlaceholder = 'assets/images/avatar.png';

  // Strings UI
  static const String appName = 'AquaSave';
  static const String labelUsername = 'Nombre de Usuario';
  static const String labelPassword = 'Contraseña';
  static const String labelConfirmPwd = 'Confirmar Contraseña';
  static const String labelEmail = 'EMAIL';
  static const String labelUserType = 'TIPO DE USUARIO';
  static const String btnLogin = 'Iniciar Sesión';
  static const String btnRegister = 'Registrarse';
  static const String btnSaveChanges = 'Guardar Cambios';
  static const String noAccount = '¿No tienes cuenta? ';
  static const String hasAccount = '¿Tienes Cuenta? ';
  static const String linkRegister = 'Regístrate';
  static const String linkLogin = 'Inicia Sesión';
  static const String titleWelcome = 'Bienvenido de vuelta';
  static const String titlePersonalData = 'Datos personales';

  // Nav labels
  static const String navHome = 'Inicio';
  static const String navDevices = 'Dispositivos';
  static const String navAnalysis = 'Análisis';
  static const String navHistory = 'Historial';
  static const String navProfile = 'Perfil';
  static const String navSettings = 'Configuracion';
}
