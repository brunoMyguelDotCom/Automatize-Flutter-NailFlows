const List<String> _diasDaSemana = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
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

String hora(DateTime data) {
  final h = data.hour.toString().padLeft(2, '0');
  final m = data.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String faixaDeHorario(DateTime inicio, DateTime fim) {
  return '${hora(inicio)} às ${hora(fim)}';
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
