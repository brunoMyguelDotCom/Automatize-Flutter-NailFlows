import '../modelos/agendamento.dart';
import '../modelos/cliente.dart';
import '../modelos/dados_do_agendamento.dart';
import '../modelos/servico.dart';

abstract class AgendaRepository {
  Future<List<Agendamento>> listarAgendamentos({
    DateTime? inicio,
    DateTime? fim,
  });

  Future<Agendamento> criarAgendamento(DadosDoAgendamento dados);

  Future<Agendamento> atualizarAgendamento(String id, DadosDoAgendamento dados);

  Future<void> excluirAgendamento(String id);

  Future<List<Servico>> listarServicos();

  Future<Servico> criarServico(Servico servico);

  Future<Servico> atualizarServico(String id, Servico servico);

  Future<void> excluirServico(String id);

  Future<List<Cliente>> listarClientes();

  Future<Cliente> criarCliente(Cliente cliente);

  Future<Cliente> atualizarCliente(String id, Cliente cliente);

  Future<void> excluirCliente(String id);
}
