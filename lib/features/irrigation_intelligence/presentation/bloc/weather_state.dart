part of 'weather_bloc.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherState {
  final String deviceId;

  const WeatherLoading(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class WeatherLoaded extends WeatherState {
  final WeatherForecast forecast;

  const WeatherLoaded(this.forecast);

  @override
  List<Object?> get props => [forecast];
}

class WeatherFailureState extends WeatherState {
  final String deviceId;
  final String message;

  const WeatherFailureState(this.deviceId, this.message);

  @override
  List<Object?> get props => [deviceId, message];
}
