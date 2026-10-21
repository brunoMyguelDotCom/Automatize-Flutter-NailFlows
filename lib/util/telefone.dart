String somenteDigitos(String texto) {
  return texto.replaceAll(RegExp(r'\D'), '');
}

String formatarTelefone(String texto) {
  var digitos = somenteDigitos(texto);

  if (digitos.startsWith('55') && digitos.length > 11) {
    digitos = digitos.substring(2);
  }

  if (digitos.length > 11) {
    digitos = digitos.substring(0, 11);
  }

  if (digitos.length < 10) return digitos;

  final ddd = digitos.substring(0, 2);
  final corpo = digitos.substring(2);
  final meio = corpo.length == 9
      ? corpo.substring(0, 5)
      : corpo.substring(0, 4);
  final fim = corpo.substring(meio.length);

  return '($ddd) $meio-$fim';
}

bool telefoneCompleto(String texto) {
  final digitos = somenteDigitos(formatarTelefone(texto));
  return digitos.length == 10 || digitos.length == 11;
}
