import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erreur réseau']);
}

final class OcrFailure extends Failure {
  const OcrFailure([super.message = 'Échec de la reconnaissance OCR']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de cache local']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Clé API invalide ou manquante']);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Délai dépassé — réessayez']);
}
