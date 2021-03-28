part of 'config_cubit.dart';



abstract class ConfigState {}

class ConfigInitial extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigFailure extends ConfigState {
  final String message;

  ConfigFailure(this.message);
}

class ConfigSuccess extends ConfigState {
  final List<Config> configs;

  ConfigSuccess(this.configs);
}
