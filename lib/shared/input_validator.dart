class InputValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email est requis';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Entrez un email valide';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe est requis';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit avoir au moins 8 caractères';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une majuscule et une minuscule';
    }
    return null;
  }

  static String? validateOnlyNumbers(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un nombre';
    }
    final regex = RegExp(r'^[0-9]+$');
    if (!regex.hasMatch(value)) {
      return 'Seuls les chiffres sont autorisés';
    }
    return null;
  }
}