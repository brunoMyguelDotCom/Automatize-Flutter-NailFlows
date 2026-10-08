const List<String> _diasDaSemana = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
];

const List<String> _diasCurtos = [
  'seg',
  'ter',
  'qua',
  'qui',
  'sex',
  'sáb',
  'dom',
];

const List<String> _meses = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

String diaPorExtenso(DateTime data) {
  final diaSemana = _diasDaSemana[data.weekday - 1];
  final mes = _meses[data.month - 1];
  return '$diaSemana, ${data.day} de $mes';
}

String diaCurto(DateTime data) => _diasCurtos[data.weekday - 1];

String mesPorExtenso(DateTime data) => _meses[data.month - 1];

String hora(DateTime data) {
  final h = data.hour.toString().padLeft(2, '0');
  final m = data.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String faixaDeHorario(DateTime inicio, DateTime fim) {
  return '${hora(inicio)} às ${hora(fim)}';
}

String duracaoPorExtenso(int minutos) {
  final horas = minutos ~/ 60;
  final resto = minutos % 60;
  if (horas == 0) return '${resto}min';
  if (resto == 0) return '${horas}h';
  return '${horas}h$resto';
}

bool mesmoDia(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DateTime inicioDoDia(DateTime data) {
  return DateTime(data.year, data.month, data.day);
}

DateTime fimDoDia(DateTime data) {
  return DateTime(data.year, data.month, data.day, 23, 59, 59);
}

List<DateTime> semanaDe(DateTime dia) {
  final segunda = inicioDoDia(dia).subtract(Duration(days: dia.weekday - 1));
  return List.generate(7, (i) => segunda.add(Duration(days: i)));
}
