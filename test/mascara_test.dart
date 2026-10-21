import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nailsflow/util/telefone.dart';

String digitar(List<TextInputFormatter> formatadores, String digitos) {
  var atual = TextEditingValue.empty;
  for (final caractere in digitos.split('')) {
    var novo = TextEditingValue(
      text: atual.text + caractere,
      selection: TextSelection.collapsed(offset: atual.text.length + 1),
    );
    for (final formatador in formatadores) {
      novo = formatador.formatEditUpdate(atual, novo);
    }
    atual = novo;
  }
  return atual.text;
}

void main() {
  test('a ordem dos formatadores decide se a mascara funciona', () {
    const digitos = '44998124455';

    expect(
      digitar([
        FilteringTextInputFormatter.digitsOnly,
        TelefoneOuCelularInputFormatter(),
      ], digitos),
      '(44) 99812-4455',
    );

    expect(
      digitar([TelefoneOuCelularInputFormatter()], digitos),
      isNot('(44) 99812-4455'),
    );
  });

  test('compara o obterTelefone do pacote com o nosso formatador', () {
    for (final guardado in [
      '+55 44 99812-4455',
      '44998124455',
      '(44) 99812-4455',
      '4432221100',
      '',
    ]) {
      String pacote;
      try {
        pacote = '"${UtilBrasilFields.obterTelefone(guardado)}"';
      } catch (erro) {
        pacote = 'EXPLODE: ${erro.toString().split(':').last.trim()}';
      }
      final coluna1 = '"$guardado"'.padRight(22);
      final coluna2 = 'pacote: $pacote'.padRight(44);
      // ignore: avoid_print
      print('$coluna1 $coluna2 nosso: "${formatarTelefone(guardado)}"');
    }
  });

  test('formatarTelefone normaliza o que ja estava salvo', () {
    expect(formatarTelefone('+55 44 99812-4455'), '(44) 99812-4455');
    expect(formatarTelefone('44998124455'), '(44) 99812-4455');
    expect(formatarTelefone('(44) 99812-4455'), '(44) 99812-4455');
    expect(formatarTelefone('4432221100'), '(44) 3222-1100');
    expect(formatarTelefone(''), '');
    expect(telefoneCompleto('(44) 99812-4455'), isTrue);
    expect(telefoneCompleto('(44) 9981'), isFalse);
  });
}
