import 'package:firebase_auth/firebase_auth.dart';

class ErrorService {
  String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      return 'Il n\'y a pas d\'utilisateur correspondant à cet e-mail.';
    case 'wrong-password':
      return 'Le mot de passe fourni est incorrect.';
    case 'email-already-in-use':
      return 'L\'email est déjà utilisé.';
    case 'invalid-email':
      return 'Adresse e-mail invalide.';
    case 'network-request-failed':
      return 'Erreur réseau. Veuillez vérifier votre connexion.';
    default:
      return 'Erreur inattendue: ${e.code}${e.message != null ? ' - ${e.message}' : ''}';
    }
  }
}
