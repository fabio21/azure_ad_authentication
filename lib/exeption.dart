/// message error MsalException
class MsalException implements Exception {
  String errorMessage;
  MsalException(this.errorMessage);
}

/// message error  MsalChangedClientIdException
class MsalChangedClientIdException extends MsalException {
  MsalChangedClientIdException()
      : super(
            "Cannot create a client with a new client ID. Only 1 client id supported");
}

/// message error MsalUserCancelledException
class MsalUserCancelledException extends MsalException {
  MsalUserCancelledException() : super("User cancelled login request");
}

/// message error MsalNoAccountException
class MsalNoAccountException extends MsalException {
  MsalNoAccountException()
      : super("Cannot login silently. No account available");
}

/// message error MsalInvalidConfigurationException
class MsalInvalidConfigurationException extends MsalException {
  MsalInvalidConfigurationException(errorMessage) : super(errorMessage);
}

/// message error MsalInvalidScopeException
class MsalInvalidScopeException extends MsalException {
  MsalInvalidScopeException() : super("Invalid or no scope");
}

/// message error MsalInitializationException
class MsalInitializationException extends MsalException {
  MsalInitializationException()
      : super(
            "Error initializing client. Please ensure correctly configuration supplied");
}

/// message error MsalUninitializedException
class MsalUninitializedException extends MsalException {
  MsalUninitializedException()
      : super(
            "Client not initialized. Client must be initialized before attempting to use");
}
