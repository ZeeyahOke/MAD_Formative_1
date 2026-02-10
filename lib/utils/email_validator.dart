/// Email validation utility for verifying student emails.
///
/// Ensures that only valid ALU student emails
/// are accepted during signup.
class EmailValidator {
  static const String requiredDomain = 'alustudent.com';
  /// Validates if the provided email is a valid ALU student email.
  static bool isValidAluStudentEmail(String email) {
    if (email.trim().isEmpty) {
      return false;
    }

    final trimmedEmail = email.trim().toLowerCase();

    // Check if email contains @ symbol
    if (!trimmedEmail.contains('@')) {
      return false;
    }

    // Check if email ends with the required domain
    if (!trimmedEmail.endsWith('@$requiredDomain')) {
      return false;
    }

    // Ensure there's a local part (before @)
    final parts = trimmedEmail.split('@');
    if (parts.length != 2 || parts[0].isEmpty) {
      return false;
    }

    return true;
  }

/// Returns the required email domain for ALU student emails.
  static String getRequiredEmailDomain() {
    return '@$requiredDomain';
  }
  /// Extracts the domain from the email address.
  static String extractDomain(String email) {
    final parts = email.trim().toLowerCase().split('@');
    return parts.length == 2 ? parts[1] : '';
  }
/// Provides specific error messages based on the email validation failure reason.
  static String getErrorMessage(String email) {
    if (email.trim().isEmpty) {
      return 'Email address is required';
    }

    if (!email.trim().toLowerCase().contains('@')) {
      return 'Please enter a valid email address';
    }

    final domain = extractDomain(email);
    if (domain.isEmpty) {
      return 'Please enter a valid email address';
    }

    if (domain != requiredDomain) {
      return 'Please use your ALU student email ending in @$requiredDomain';
    }

    return 'Invalid email address';
  }
}
