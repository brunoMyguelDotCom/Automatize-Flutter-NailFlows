import '../modelos/agendamento.dart';
import '../modelos/cliente.dart';
import '../modelos/servico.dart';
import 'agenda_repository.dart';

class AgendaRepositoryFalso implements AgendaRepository {
  AgendaRepositoryFalso({this.atraso = const Duration(milliseconds: 400)});

  final Duration atraso;

  static final Servico moldeF1 = Servico(
    id: 'svc_molde_f1',
    nome: 'Molde F1',
    duracaoMinutos: 150,
    preco: 190.00,
  );

  static final Servico esmaltacaoGel = Servico(
    id: 'svc_esmaltacao_gel',
    nome: 'Esmaltação em gel',
    duracaoMinutos: 90,
    preco: 120.00,
  );

  static final Servico blindagem = Servico(
    id: 'svc_blindagem',
    nome: 'Blindagem',
    duracaoMinutos: 60,
    preco: 90.00,
  );

  static final Servico manutencao = Servico(
    id: 'svc_manutencao',
    nome: 'Manutenção de Molde F1',
    duracaoMinutos: 120,
    preco: 150.00,
  );

  static final List<Cliente> _clientes = [
    Cliente(
      id: 'cli_maria',
      nome: 'Maria Silva',
      email: 'maria.silva@email.com',
      telefone: '+55 44 99812-4455',
    ),
    Cliente(
      id: 'cli_juliana',
      nome: 'Juliana Prado',
      email: 'ju.prado@email.com',
      telefone: '+55 44 99731-0192',
      observacao: 'Prefere tons neutros',
    ),
    Cliente(
      id: 'cli_camila',
      nome: 'Camila Ferreira',
      email: 'camila.ferreira@email.com',
      telefone: '+55 44 99604-7788',
    ),
    Cliente(
      id: 'cli_patricia',
      nome: 'Patrícia Nunes',
      email: 'patricia.nunes@email.com',
      telefone: '+55 44 99188-2301',
      observacao: 'Alérgica a acetona',
    ),
    Cliente(
      id: 'cli_renata',
      nome: 'Renata Lima',
      email: 'renata.lima@email.com',
      telefone: '+55 44 99455-6620',
    ),
  ];

  late final List<Agendamento> _agendamentos = _montarSemana();

  List<Agendamento> _montarSemana() {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);

    DateTime em(int diasDepois, int hora, [int minuto = 0]) {
      return hoje
          .add(Duration(days: diasDepois))
          .add(Duration(hours: hora, minutes: minuto));
    }

    return [
      Agendamento(
        id: 'agd_001',
        cliente: _clientes[0],
        servico: moldeF1,
        inicio: em(0, 9),
        duracaoMinutos: moldeF1.duracaoMinutos,
        preco: moldeF1.preco,
        statusConvite: StatusConvite.confirmado,
        googleEventId: 'google_a1b2c3d4',
        ultimaSincronizacao: agora.subtract(const Duration(hours: 3)),
      ),
      Agendamento(
        id: 'agd_002',
        cliente: _clientes[1],
        servico: esmaltacaoGel,
        inicio: em(0, 12),
        duracaoMinutos: esmaltacaoGel.duracaoMinutos,
        preco: esmaltacaoGel.preco,
        observacao: 'Levar referência da cor',
        statusConvite: StatusConvite.confirmado,
        googleEventId: 'google_b2c3d4e5',
        ultimaSincronizacao: agora.subtract(const Duration(hours: 3)),
      ),
      Agendamento(
        id: 'agd_003',
        cliente: _clientes[2],
        servico: blindagem,
        inicio: em(0, 15),
        duracaoMinutos: blindagem.duracaoMinutos,
        preco: blindagem.preco,
        statusConvite: StatusConvite.pendente,
        googleEventId: 'google_c3d4e5f6',
      ),
      Agendamento(
        id: 'agd_004',
        cliente: _clientes[3],
        servico: manutencao,
        inicio: em(0, 16, 30),
        duracaoMinutos: manutencao.duracaoMinutos,
        preco: manutencao.preco,
        statusConvite: StatusConvite.recusado,
        googleEventId: 'google_d4e5f6a7',
      ),
      Agendamento(
        id: 'agd_005',
        cliente: _clientes[4],
        servico: moldeF1,
        inicio: em(1, 9, 30),
        duracaoMinutos: moldeF1.duracaoMinutos,
        preco: moldeF1.preco,
        statusConvite: StatusConvite.pendente,
        googleEventId: 'google_e5f6a7b8',
      ),
      Agendamento(
        id: 'agd_006',
        cliente: _clientes[0],
        servico: blindagem,
        inicio: em(1, 14),
        duracaoMinutos: blindagem.duracaoMinutos,
        preco: blindagem.preco,
        statusConvite: StatusConvite.confirmado,
        googleEventId: 'google_f6a7b8c9',
      ),
      Agendamento(
        id: 'agd_007',
        cliente: _clientes[1],
        servico: esmaltacaoGel,
        inicio: em(-1, 10),
        duracaoMinutos: esmaltacaoGel.duracaoMinutos,
        preco: esmaltacaoGel.preco,
        situacao: SituacaoAtendimento.concluido,
        statusConvite: StatusConvite.confirmado,
        googleEventId: 'google_a7b8c9d0',
      ),
      Agendamento(
        id: 'agd_008',
        cliente: _clientes[3],
        servico: manutencao,
        inicio: em(-1, 14),
        duracaoMinutos: manutencao.duracaoMinutos,
        preco: manutencao.preco,
        situacao: SituacaoAtendimento.faltou,
        statusConvite: StatusConvite.confirmado,
        googleEventId: 'google_b8c9d0e1',
      ),
      Agendamento(
        id: 'agd_009',
        cliente: _clientes[2],
        servico: moldeF1,
        inicio: em(3, 9),
        duracaoMinutos: moldeF1.duracaoMinutos,
        preco: moldeF1.preco,
        statusConvite: StatusConvite.pendente,
        googleEventId: 'google_c9d0e1f2',
      ),
    ];
  }

  @override
  Future<List<Agendamento>> listarAgendamentos({
    DateTime? inicio,
    DateTime? fim,
  }) async {
    await Future.delayed(atraso);

    final lista = _agendamentos.where((agendamento) {
      if (inicio != null && agendamento.inicio.isBefore(inicio)) return false;
      if (fim != null && agendamento.inicio.isAfter(fim)) return false;
      return true;
    }).toList();

    lista.sort((a, b) => a.inicio.compareTo(b.inicio));
    return lista;
  }

  @override
  Future<List<Servico>> listarServicos() async {
    await Future.delayed(atraso);
    return [moldeF1, manutencao, esmaltacaoGel, blindagem];
  }

  @override
  Future<List<Cliente>> listarClientes() async {
    await Future.delayed(atraso);
    final lista = [..._clientes];
    lista.sort((a, b) => a.nome.compareTo(b.nome));
    return lista;
  }
}
