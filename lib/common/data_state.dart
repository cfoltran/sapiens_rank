import 'package:equatable/equatable.dart';

enum DataStatus { initial, success, loading, error }

sealed class DataState<T extends Object?> extends Equatable {
  const DataState._(this.status);

  const factory DataState.initial() = InitialDataState<T>;
  const factory DataState.success(T data) = SuccessDataState<T>;
  const factory DataState.loading([T? data]) = LoadingDataState<T>;
  const factory DataState.error(
    String type, {
    Object? error,
    StackTrace? stackTrace,
    List validationErrors,
  }) = ErrorDataState<T>;

  final DataStatus status;

  T? get data {
    return this is SuccessDataState<T>
        ? (this as SuccessDataState<T>).data
        : null;
  }

  String? get errorType =>
      this is ErrorDataState<T> ? (this as ErrorDataState<T>).type : null;

  R when<R>({
    required R Function(T data) success,
    required R Function() loading,
    required R Function(String error) error,
  }) {
    switch (status) {
      case DataStatus.initial:
      case DataStatus.success:
        return success((this as SuccessDataState<T>).data);
      case DataStatus.loading:
        return loading();
      case DataStatus.error:
        final errorState = this as ErrorDataState<T>;
        return error(errorState.type);
    }
  }

  R maybeWhen<R>({
    R Function(T data)? success,
    R Function()? loading,
    R Function(String error)? error,
    required R Function() orElse,
  }) {
    switch (status) {
      case DataStatus.initial:
      case DataStatus.success:
        return success != null
            ? success((this as SuccessDataState<T>).data)
            : orElse();
      case DataStatus.loading:
        return loading != null ? loading() : orElse();
      case DataStatus.error:
        final errorState = this as ErrorDataState<T>;
        return error != null ? error(errorState.type) : orElse();
    }
  }

  @override
  List<Object?> get props => [status];
}

class InitialDataState<T extends Object?> extends DataState<T> {
  const InitialDataState() : super._(DataStatus.initial);

  @override
  List<Object?> get props => [];
}

class SuccessDataState<T extends Object?> extends DataState<T> {
  const SuccessDataState(this.data) : super._(DataStatus.success);

  @override
  final T data;

  @override
  List<Object?> get props => [status, data];
}

class LoadingDataState<T extends Object?> extends DataState<T> {
  const LoadingDataState([this.data]) : super._(DataStatus.loading);

  @override
  final T? data;

  @override
  List<Object?> get props => [status, data];
}

class ErrorDataState<T extends Object?> extends DataState<T> {
  const ErrorDataState(
    this.type, {
    this.error,
    this.stackTrace,
    this.validationErrors = const [],
  }) : super._(DataStatus.error);

  final String type;
  final Object? error;
  final StackTrace? stackTrace;
  final List validationErrors;

  @override
  List<Object?> get props => [
    status,
    type,
    error,
    stackTrace,
    validationErrors,
  ];
}
