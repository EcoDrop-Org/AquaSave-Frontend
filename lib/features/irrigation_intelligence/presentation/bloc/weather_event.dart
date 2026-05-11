part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeatherForDevice extends WeatherEvent {
  final Device device;

  const LoadWeatherForDevice(this.device);

  @override
  List<Object?> get props => [device];
}
