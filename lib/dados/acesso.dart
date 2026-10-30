class Acesso {
  static const String emailProvisorio = 'cris@nailsflow.app';
  static const String senhaProvisoria = 'nailsflow';

  static bool conferir(String email, String senha) {
    return email.trim().toLowerCase() == emailProvisorio &&
        senha == senhaProvisoria;
  }
}
