abstract class ApiFailure {
  ApiFailure(this.message);
  final String message;
}

class ApiFailureImplimentation extends ApiFailure {
  ApiFailureImplimentation({String message = ''}) : super(message);

  @override
  String toString() => message;
}

class GenericApiFailure extends ApiFailure {
  GenericApiFailure({String message = ''}) : super(message);

  @override
  String toString() => message;
}

class DatabaseApiFailure extends ApiFailure {
  DatabaseApiFailure({String message = ''}) : super(message);

  @override
  String toString() => message;
}
