import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const supportedLocales = [Locale('es'), Locale('en')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isEs => locale.languageCode == 'es';

  String t(String key) {
    return _values[locale.languageCode]?[key] ?? _values['es']![key] ?? key;
  }

  String greeting(String name) {
    return isEs ? 'Buenos días, $name' : 'Good morning, $name';
  }

  String plants(int count) {
    if (isEs) return '$count ${count == 1 ? 'planta' : 'plantas'}';
    return '$count ${count == 1 ? 'plant' : 'plants'}';
  }

  String temperature(double value) => '${value.toStringAsFixed(0)}°C';

  String weatherCondition(int code) {
    if (code == 0) return t('weatherClear');
    if ([1, 2, 3].contains(code)) return t('weatherPartlyCloudy');
    if ([45, 48].contains(code)) return t('weatherFog');
    if ([51, 53, 55, 56, 57].contains(code)) return t('weatherDrizzle');
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
      return t('weatherRain');
    }
    if ([71, 73, 75, 77, 85, 86].contains(code)) return t('weatherSnow');
    if ([95, 96, 99].contains(code)) return t('weatherStorm');
    return t('weatherVariable');
  }

  static const Map<String, Map<String, String>> _values = {
    'es': {
      'appName': 'AquaSave',
      'navHome': 'Inicio',
      'navDevices': 'Dispositivos',
      'navAnalysis': 'Análisis',
      'navHistory': 'Historial',
      'navProfile': 'Perfil',
      'navSettings': 'Configuración',
      'username': 'Nombre de usuario',
      'password': 'Contraseña',
      'confirmPassword': 'Confirmar contraseña',
      'email': 'EMAIL',
      'phone': 'TELÉFONO',
      'userType': 'TIPO DE USUARIO',
      'name': 'NOMBRE',
      'login': 'Iniciar sesión',
      'register': 'Registrarse',
      'saveChanges': 'Guardar cambios',
      'noAccount': '¿No tienes cuenta? ',
      'hasAccount': '¿Tienes cuenta? ',
      'registerLink': 'Regístrate',
      'loginLink': 'Inicia sesión',
      'welcomeBack': 'Bienvenido de vuelta',
      'userFallback': 'Usuario',
      'personalData': 'Datos personales',
      'passwordMismatch': 'Las contraseñas no coinciden',
      'notifications': 'Notificaciones',
      'notificationCenter': 'Centro de notificaciones',
      'noNotifications': 'No hay alertas activas',
      'close': 'Cerrar',
      'irrigationActiveNotice': 'Riego activo',
      'irrigationActiveBody':
          'El ciclo manual sigue corriendo aunque cambies de pestaña.',
      'weatherPauseNotice': 'Pausa recomendada',
      'weatherPauseBody': 'Hay lluvia o alta probabilidad de precipitación.',
      'heatWaterNotice': 'Riego recomendado',
      'heatWaterBody':
          'Temperatura alta y humedad baja: revisa el riego del huerto.',
      'batteryNotice': 'Batería baja',
      'batteryBody': 'Revisa el dispositivo cuando puedas.',
      'notificationsEnabled': 'Alertas de humedad crítica y eventos de riego.',
      'homeSubtitle': 'Estado actual del huerto y decisiones de riego.',
      'noDevices': 'Sin dispositivos',
      'irrigationStarted': 'Riego iniciado',
      'irrigationStopped': 'Riego detenido',
      'activeDevice': 'Dispositivo activo',
      'online': 'En línea',
      'offline': 'Sin conexión',
      'active': 'Activo',
      'plantsLabel': 'Plantas',
      'humidity': 'Humedad',
      'battery': 'Batería',
      'viewDetails': 'Ver detalles',
      'viewDeviceData': 'Mostrar este dispositivo en la plataforma',
      'addDevice': 'Agregar dispositivo',
      'editDevice': 'Editar dispositivo',
      'registerDevice': 'Registrar dispositivo',
      'gardenName': 'Nombre del huerto',
      'country': 'Pais',
      'city': 'Ciudad',
      'district': 'Distrito / zona',
      'postalCode': 'Codigo postal',
      'countryHint': 'Ej. Peru o PE',
      'cityHint': 'Ej. Lima',
      'districtHint': 'Ej. Miraflores',
      'postalCodeHint': 'Opcional',
      'postalCodeHelper': 'Alternativa si hay zonas con nombres repetidos.',
      'locationLookupTitle': 'Ubicacion precisa',
      'locationFieldsNotSaved':
          'Pais, ciudad, distrito y codigo postal no se guardan por separado; solo se usan con la API para encontrar la zona climatica del dispositivo.',
      'postalAlternativeHelp':
          'Si no encuentras correctamente tu ubicacion, escribe tu pais y codigo postal. AquaSave consultara APIs externas para ubicar la zona exacta.',
      'resolveLocation': 'Verificar zona',
      'resolvedLocation': 'Zona detectada',
      'locationResolvedWithPostal': 'Zona detectada por codigo postal',
      'locationNotFound':
          'No se encontro una coincidencia clara. Revisa pais, ciudad o codigo postal.',
      'gardenLocation': 'Ubicación del huerto',
      'gardenLocationHint': 'Ej. Miraflores, Lima',
      'plantCount': 'Cantidad de plantas',
      'invalidName': 'Ingresa un nombre válido',
      'invalidLocation': 'Ingresa una ubicación válida',
      'invalidPlantCount': 'Ingresa al menos 1 planta',
      'locationHelp':
          'La ubicación se usará para buscar el clima actual del huerto.',
      'cancel': 'Cancelar',
      'weatherGarden': 'Clima del huerto',
      'rain': 'Lluvia',
      'wind': 'Viento',
      'waitingWeather': 'Esperando clima en tiempo real',
      'pauseIrrigation': 'No se debe regar',
      'waterRecommended': 'Se recomienda regar',
      'continueIrrigation': 'Riego puede continuar',
      'averageHumidity': 'Humedad promedio',
      'humidityGoal': 'Rango objetivo para mantener el cultivo saludable.',
      'quickControl': 'Control rápido',
      'manualActions': 'Acciones manuales para el ciclo de riego.',
      'watering': 'Regando',
      'stopped': 'Detenido',
      'wateringSessionTime': 'Tiempo regando en esta sesión',
      'timerWillStart': 'El contador iniciará al activar el riego',
      'startIrrigation': 'Iniciar riego',
      'stopIrrigation': 'Detener riego',
      'changePassword': 'Cambiar contraseña',
      'currentPassword': 'Contraseña actual',
      'newPassword': 'Nueva contraseña',
      'language': 'Idioma',
      'darkMode': 'Modo oscuro',
      'lightMode': 'Modo claro',
      'spanish': 'Español',
      'english': 'Inglés',
      'languageSubtitle': 'Cambia el idioma de la interfaz.',
      'analyticsTitle': 'Análisis del cultivo',
      'analyticsSubtitle':
          'Estrés hídrico evitado, estabilidad del suelo y retención del sustrato.',
      'waterSaved': 'Agua ahorrada',
      'savingRate': 'Ahorro estimado',
      'cropHealth': 'Salud del cultivo',
      'sustainability': 'Sostenibilidad',
      'weeklyTrend': 'Tendencia semanal',
      'waterStressAvoided': 'Estrés hídrico evitado',
      'waterStressAvoidedShort': 'Estrés evitado',
      'stressAvoidedHighCaption': 'El riego oportuno redujo el riesgo hídrico.',
      'stressAvoidedMediumCaption':
          'Riesgo parcialmente controlado; vigila los próximos ciclos.',
      'stressAvoidedLowCaption':
          'Aún hay riesgo de sequedad crítica en el cultivo.',
      'soilStability': 'Estabilidad del suelo',
      'stabilityResult': 'Resultado',
      'stabilityHighCaption': 'Humedad constante en rango saludable.',
      'stabilityMediumCaption': 'Hay pequeñas variaciones por revisar.',
      'stabilityLowCaption': 'La humedad cambia con demasiada brusquedad.',
      'weeklyMoistureTrend': 'Tendencia semanal de humedad',
      'weeklyMoistureSubtitle':
          'Lecturas recientes del sensor para detectar fluctuaciones.',
      'substrateRetention': 'Retención del sustrato',
      'pumpWaterTank': 'Depósito de la bomba',
      'pumpTankShort': 'Depósito',
      'pumpTankHighCaption': 'Agua suficiente para los próximos ciclos.',
      'pumpTankMediumCaption': 'Conviene revisar el depósito pronto.',
      'pumpTankLowCaption': 'Recarga el depósito antes del siguiente riego.',
      'advancedDiagnosis': 'Diagnóstico avanzado',
      'enoughHistory': 'Historial suficiente',
      'collectingHistory': 'Recolectando historial',
      'excellent': 'Excelente',
      'stable': 'Estable',
      'needsReview': 'Revisar',
      'unstable': 'Inestable',
      'regular': 'Regular',
      'poor': 'Pobre',
      'retentionWaitingShort': 'Aún no hay datos suficientes',
      'retentionWaitingBody':
          'AquaSave necesita más lecturas de humedad antes y después del riego para evaluar cómo se comporta la tierra.',
      'retentionWaitingRecommendation':
          'Mantén el dispositivo activo durante algunos ciclos para habilitar este diagnóstico.',
      'retentionPoorShort': 'Pierde humedad muy rápido',
      'retentionPoorBody':
          'La humedad cae con rapidez después del riego. El sustrato podría estar demasiado arenoso o tener poca materia orgánica.',
      'retentionPoorRecommendation':
          'Sugerencia: agrega compost o mulch para mejorar la capacidad de retención.',
      'retentionRegularShort': 'Retención aceptable',
      'retentionRegularBody':
          'La tierra conserva parte de la humedad, pero todavía presenta caídas notables entre lecturas.',
      'retentionRegularRecommendation':
          'Sugerencia: revisa el horario de riego y mejora el sustrato si las caídas se repiten.',
      'retentionExcellentShort': 'Conserva bien la humedad',
      'retentionExcellentBody':
          'Tu tierra actúa como una esponja: mantiene la humedad de forma gradual y evita cambios bruscos.',
      'retentionExcellentRecommendation':
          'Sigue usando el riego automático para mantener esta estabilidad.',
      'liters': 'litros',
      'healthy': 'Bueno',
      'attention': 'Atención',
      'critical': 'Crítico',
      'historyTitle': 'Historial de riego',
      'historySubtitle':
          'Ciclos ejecutados con duración y litros usados por la bomba.',
      'today': 'Hoy',
      'week': 'Semana',
      'month': 'Mes',
      'last7Days': 'Últimos 7 días',
      'last30Days': 'Últimos 30 días',
      'cycles': 'Ciclos',
      'consumed': 'Consumidos',
      'litersUsed': 'Litros usados',
      'waterUsageMeasuredByPump':
          'Consumo registrado por el caudal de la bomba del dispositivo.',
      'saved': 'Ahorrados',
      'manual': 'Manual',
      'automatic': 'Automático',
      'scheduled': 'Programado',
      'skipped': 'Omitido',
      'duration': 'Duración',
      'settingsTitle': 'Configuración',
      'settingsSubtitle': 'Umbrales, lluvia y horarios de riego automático.',
      'moistureThresholds': 'Umbrales de humedad',
      'minimum': 'Mínima',
      'optimal': 'Óptima',
      'maximum': 'Máxima',
      'temperatureAlert': 'Alerta de temperatura',
      'rainPauseThreshold': 'Pausa por lluvia',
      'automaticSchedule': 'Programación automática',
      'freeScheduleSubtitle':
          'Agrega todos los horarios que necesites. Cada horario puede activarse o pausarse de forma independiente.',
      'addSchedule': 'Agregar horario',
      'editSchedule': 'Editar horario',
      'removeSchedule': 'Quitar horario',
      'noSchedules': 'No hay horarios configurados.',
      'morningCycle': 'Ciclo de mañana',
      'eveningCycle': 'Ciclo de tarde',
      'scheduleTimeTitle': 'Hora de riego',
      'scheduleState': 'Estado del horario',
      'enabled': 'Activo',
      'disabled': 'Inactivo',
      'saveSettings': 'Guardar configuración',
      'settingsSaved': 'Configuración guardada',
      'premiumPlan': 'Plan Premium',
      'freePlan': 'Plan Gratis',
      'choosePlan': 'Cambiar plan',
      'selectedPlan': 'Seleccionado',
      'profileUpdated': 'Perfil actualizado',
      'passwordUpdated': 'Contraseña actualizada',
      'savePassword': 'Guardar contraseña',
      'freePlanBody':
          'Monitoreo en tiempo real, control manual y alertas básicas.',
      'premiumPlanBody':
          'Historial completo, reportes de consumo, alertas inteligentes y control remoto avanzado.',
      'activePlan': 'Plan activo',
      'planReports': 'Reportes de consumo',
      'planDevices': 'Múltiples dispositivos',
      'insufficientData':
          'Se necesitan más datos para calcular el ahorro estimado.',
      'healthyRange': 'Rango saludable 45-72%',
      'trendExplanation':
          'La franja verde muestra el rango recomendado; la linea indica como vario la humedad en la semana.',
      'pumpCycle': 'Ciclo de bomba',
      'pumpRunning': 'Bomba en riego',
      'completed': 'Completado',
      'time24Label': 'Hora en formato 24 horas',
      'time24Hint': 'HH:mm, ej. 06:30',
      'time24Helper': 'Formato 24 horas. Ejemplo: 06:30 o 18:45.',
      'invalidTime24': 'Usa formato 24 horas HH:mm',
      'passwordHelp':
          'Usa una clave segura. Puedes mostrarla temporalmente para revisar que este escrita correctamente.',
      'newPasswordHelp': 'Usa al menos 8 caracteres con letras y numeros.',
      'confirmPasswordHelp': 'Repite la nueva contrasena para confirmarla.',
      'passwordStrength': 'Seguridad',
      'passwordStrengthEmpty': 'Pendiente',
      'passwordStrengthWeak': 'Baja',
      'passwordStrengthMedium': 'Media',
      'passwordStrengthStrong': 'Alta',
      'showPassword': 'Mostrar contrasena',
      'hidePassword': 'Ocultar contrasena',
      'weatherClear': 'Despejado',
      'weatherPartlyCloudy': 'Parcialmente nublado',
      'weatherFog': 'Neblina',
      'weatherDrizzle': 'Llovizna',
      'weatherRain': 'Lluvia',
      'weatherSnow': 'Nieve',
      'weatherStorm': 'Tormenta',
      'weatherVariable': 'Clima variable',
    },
    'en': {
      'appName': 'AquaSave',
      'navHome': 'Home',
      'navDevices': 'Devices',
      'navAnalysis': 'Analytics',
      'navHistory': 'History',
      'navProfile': 'Profile',
      'navSettings': 'Settings',
      'username': 'Username',
      'password': 'Password',
      'confirmPassword': 'Confirm password',
      'email': 'EMAIL',
      'phone': 'PHONE',
      'userType': 'USER TYPE',
      'name': 'NAME',
      'login': 'Log in',
      'register': 'Sign up',
      'saveChanges': 'Save changes',
      'noAccount': 'No account? ',
      'hasAccount': 'Already have an account? ',
      'registerLink': 'Sign up',
      'loginLink': 'Log in',
      'welcomeBack': 'Welcome back',
      'userFallback': 'User',
      'personalData': 'Personal data',
      'passwordMismatch': 'Passwords do not match',
      'notifications': 'Notifications',
      'notificationCenter': 'Notification center',
      'noNotifications': 'No active alerts',
      'close': 'Close',
      'irrigationActiveNotice': 'Irrigation active',
      'irrigationActiveBody':
          'The manual cycle keeps running when you switch tabs.',
      'weatherPauseNotice': 'Pause recommended',
      'weatherPauseBody':
          'Rain or high precipitation probability was detected.',
      'heatWaterNotice': 'Irrigation recommended',
      'heatWaterBody':
          'High temperature and low moisture: check garden irrigation.',
      'batteryNotice': 'Low battery',
      'batteryBody': 'Check the device when you can.',
      'notificationsEnabled': 'Critical humidity and irrigation event alerts.',
      'homeSubtitle': 'Current garden status and irrigation decisions.',
      'noDevices': 'No devices',
      'irrigationStarted': 'Irrigation started',
      'irrigationStopped': 'Irrigation stopped',
      'activeDevice': 'Active device',
      'online': 'Online',
      'offline': 'Offline',
      'active': 'Active',
      'plantsLabel': 'Plants',
      'humidity': 'Humidity',
      'battery': 'Battery',
      'viewDetails': 'View details',
      'viewDeviceData': 'Show this device in the platform',
      'addDevice': 'Add device',
      'editDevice': 'Edit device',
      'registerDevice': 'Register device',
      'gardenName': 'Garden name',
      'country': 'Country',
      'city': 'City',
      'district': 'District / area',
      'postalCode': 'Postal code',
      'countryHint': 'Ex. Peru or PE',
      'cityHint': 'Ex. Lima',
      'districtHint': 'Ex. Miraflores',
      'postalCodeHint': 'Optional',
      'postalCodeHelper': 'Alternative when areas share the same name.',
      'locationLookupTitle': 'Precise location',
      'locationFieldsNotSaved':
          'Country, city, district and postal code are not saved separately; they are only used with the API to find the device weather zone.',
      'postalAlternativeHelp':
          'If your location is not found correctly, enter your country and postal code. AquaSave will query external APIs to identify the exact zone.',
      'resolveLocation': 'Verify zone',
      'resolvedLocation': 'Detected zone',
      'locationResolvedWithPostal': 'Zone detected by postal code',
      'locationNotFound':
          'No clear match was found. Check country, city or postal code.',
      'gardenLocation': 'Garden location',
      'gardenLocationHint': 'Ex. Miraflores, Lima',
      'plantCount': 'Plant count',
      'invalidName': 'Enter a valid name',
      'invalidLocation': 'Enter a valid location',
      'invalidPlantCount': 'Enter at least 1 plant',
      'locationHelp':
          'The location will be used to fetch current garden weather.',
      'cancel': 'Cancel',
      'weatherGarden': 'Garden weather',
      'rain': 'Rain',
      'wind': 'Wind',
      'waitingWeather': 'Waiting for real-time weather',
      'pauseIrrigation': 'Do not irrigate',
      'waterRecommended': 'Irrigation recommended',
      'continueIrrigation': 'Irrigation can continue',
      'averageHumidity': 'Average humidity',
      'humidityGoal': 'Target range to keep the crop healthy.',
      'quickControl': 'Quick control',
      'manualActions': 'Manual actions for the irrigation cycle.',
      'watering': 'Watering',
      'stopped': 'Stopped',
      'wateringSessionTime': 'Watering time in this session',
      'timerWillStart': 'The counter starts when irrigation is activated',
      'startIrrigation': 'Start irrigation',
      'stopIrrigation': 'Stop irrigation',
      'changePassword': 'Change password',
      'currentPassword': 'Current password',
      'newPassword': 'New password',
      'language': 'Language',
      'darkMode': 'Dark mode',
      'lightMode': 'Light mode',
      'spanish': 'Spanish',
      'english': 'English',
      'languageSubtitle': 'Change the interface language.',
      'analyticsTitle': 'Crop analytics',
      'analyticsSubtitle':
          'Avoided water stress, soil stability and substrate retention.',
      'waterSaved': 'Water saved',
      'savingRate': 'Estimated savings',
      'cropHealth': 'Crop health',
      'sustainability': 'Sustainability',
      'weeklyTrend': 'Weekly trend',
      'waterStressAvoided': 'Avoided water stress',
      'waterStressAvoidedShort': 'Stress avoided',
      'stressAvoidedHighCaption':
          'Timely irrigation reduced water stress risk.',
      'stressAvoidedMediumCaption':
          'Risk is partly controlled; watch the next cycles.',
      'stressAvoidedLowCaption':
          'Critical dryness risk is still present in the crop.',
      'soilStability': 'Soil stability',
      'stabilityResult': 'Result',
      'stabilityHighCaption': 'Moisture is steady in the healthy range.',
      'stabilityMediumCaption': 'Small variations need review.',
      'stabilityLowCaption': 'Moisture is changing too sharply.',
      'weeklyMoistureTrend': 'Weekly moisture trend',
      'weeklyMoistureSubtitle':
          'Recent sensor readings used to detect fluctuations.',
      'substrateRetention': 'Substrate retention',
      'pumpWaterTank': 'Pump water tank',
      'pumpTankShort': 'Tank',
      'pumpTankHighCaption': 'Enough water for the next cycles.',
      'pumpTankMediumCaption': 'Check the tank soon.',
      'pumpTankLowCaption': 'Refill the tank before the next irrigation.',
      'advancedDiagnosis': 'Advanced diagnosis',
      'enoughHistory': 'Enough history',
      'collectingHistory': 'Collecting history',
      'excellent': 'Excellent',
      'stable': 'Stable',
      'needsReview': 'Review',
      'unstable': 'Unstable',
      'regular': 'Regular',
      'poor': 'Poor',
      'retentionWaitingShort': 'Not enough data yet',
      'retentionWaitingBody':
          'AquaSave needs more moisture readings before and after irrigation to evaluate how the soil behaves.',
      'retentionWaitingRecommendation':
          'Keep the device active for a few cycles to enable this diagnosis.',
      'retentionPoorShort': 'Loses moisture too quickly',
      'retentionPoorBody':
          'Moisture drops quickly after irrigation. The substrate may be too sandy or low in organic matter.',
      'retentionPoorRecommendation':
          'Suggestion: add compost or mulch to improve retention capacity.',
      'retentionRegularShort': 'Acceptable retention',
      'retentionRegularBody':
          'The soil preserves some moisture, but still shows notable drops between readings.',
      'retentionRegularRecommendation':
          'Suggestion: review the irrigation schedule and improve the substrate if the drops repeat.',
      'retentionExcellentShort': 'Holds moisture well',
      'retentionExcellentBody':
          'Your soil keeps moisture gradually and avoids sharp changes.',
      'retentionExcellentRecommendation':
          'Keep using automatic irrigation to maintain this stability.',
      'liters': 'liters',
      'healthy': 'Good',
      'attention': 'Attention',
      'critical': 'Critical',
      'historyTitle': 'Irrigation history',
      'historySubtitle':
          'Executed cycles with duration and liters used by the pump.',
      'today': 'Today',
      'week': 'Week',
      'month': 'Month',
      'last7Days': 'Last 7 days',
      'last30Days': 'Last 30 days',
      'cycles': 'Cycles',
      'consumed': 'Consumed',
      'litersUsed': 'Liters used',
      'waterUsageMeasuredByPump':
          'Consumption registered through the device pump flow.',
      'saved': 'Saved',
      'manual': 'Manual',
      'automatic': 'Automatic',
      'scheduled': 'Scheduled',
      'skipped': 'Skipped',
      'duration': 'Duration',
      'settingsTitle': 'Settings',
      'settingsSubtitle': 'Thresholds, rain pause and automatic schedules.',
      'moistureThresholds': 'Moisture thresholds',
      'minimum': 'Minimum',
      'optimal': 'Optimal',
      'maximum': 'Maximum',
      'temperatureAlert': 'Temperature alert',
      'rainPauseThreshold': 'Rain pause',
      'automaticSchedule': 'Automatic schedule',
      'freeScheduleSubtitle':
          'Add as many schedules as you need. Each time can be enabled or paused independently.',
      'addSchedule': 'Add schedule',
      'editSchedule': 'Edit schedule',
      'removeSchedule': 'Remove schedule',
      'noSchedules': 'No schedules configured.',
      'morningCycle': 'Morning cycle',
      'eveningCycle': 'Evening cycle',
      'scheduleTimeTitle': 'Irrigation time',
      'scheduleState': 'Schedule state',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      'saveSettings': 'Save settings',
      'settingsSaved': 'Settings saved',
      'premiumPlan': 'Premium plan',
      'freePlan': 'Free plan',
      'choosePlan': 'Change plan',
      'selectedPlan': 'Selected',
      'profileUpdated': 'Profile updated',
      'passwordUpdated': 'Password updated',
      'savePassword': 'Save password',
      'freePlanBody': 'Real-time monitoring, manual control and basic alerts.',
      'premiumPlanBody':
          'Full history, consumption reports, smart alerts and advanced remote control.',
      'activePlan': 'Active plan',
      'planReports': 'Consumption reports',
      'planDevices': 'Multiple devices',
      'insufficientData': 'More data is needed to calculate estimated savings.',
      'healthyRange': 'Healthy range 45-72%',
      'trendExplanation':
          'The green band shows the recommended range; the line shows how moisture changed during the week.',
      'pumpCycle': 'Pump cycle',
      'pumpRunning': 'Pump watering',
      'completed': 'Completed',
      'time24Label': 'Time in 24-hour format',
      'time24Hint': 'HH:mm, e.g. 06:30',
      'time24Helper': '24-hour format. Example: 06:30 or 18:45.',
      'invalidTime24': 'Use 24-hour HH:mm format',
      'passwordHelp':
          'Use a secure password. You can show it temporarily to verify it was typed correctly.',
      'newPasswordHelp': 'Use at least 8 characters with letters and numbers.',
      'confirmPasswordHelp': 'Repeat the new password to confirm it.',
      'passwordStrength': 'Security',
      'passwordStrengthEmpty': 'Pending',
      'passwordStrengthWeak': 'Low',
      'passwordStrengthMedium': 'Medium',
      'passwordStrengthStrong': 'High',
      'showPassword': 'Show password',
      'hidePassword': 'Hide password',
      'weatherClear': 'Clear',
      'weatherPartlyCloudy': 'Partly cloudy',
      'weatherFog': 'Fog',
      'weatherDrizzle': 'Drizzle',
      'weatherRain': 'Rain',
      'weatherSnow': 'Snow',
      'weatherStorm': 'Storm',
      'weatherVariable': 'Variable weather',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
