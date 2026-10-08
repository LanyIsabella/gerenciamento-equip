import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../services/equipamentos_service.dart';
import '../services/manutencoes_service.dart';
import '../services/sessao_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/status_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EquipamentosService?>()?.carregar();
      context.read<ManutencoesService?>()?.carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessaoService>().usuario;
    final equipamentos =
        context.watch<EquipamentosService?>()?.itens ?? const [];
    final manutencoes = context.watch<ManutencoesService?>()?.itens ?? const [];
    final abertas =
        manutencoes.where((item) => item.status != 'Concluída').toList();
    final emManutencao =
        equipamentos.where((item) => item.status == 'Em Manutenção').length;

    return AppShell(
      title: 'Olá, ${usuario?.nome.split(' ').first ?? 'usuário'}',
      description:
          'Sessão ativa com perfil ${usuario?.cargo ?? 'usuário'}. Veja o panorama da operação.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 560
                      ? 2
                      : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 16) / columns;
              final metrics = [
                _MetricData('Total de Equipamentos',
                    equipamentos.length.toString(), Icons.inventory_2_outlined),
                _MetricData('Manutenções Abertas', abertas.length.toString(),
                    Icons.assignment_outlined),
                _MetricData('Em Manutenção', emManutencao.toString(),
                    Icons.build_outlined),
                _MetricData('Alertas do Dia', abertas.length.toString(),
                    Icons.warning_amber_outlined),
              ];
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: metrics
                    .map((metric) =>
                        SizedBox(width: width, child: _MetricCard(metric)))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 28),
          _SectionCard(
            title: 'Atalhos rápidos',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.equipamentos),
                  icon: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: const Text('Ver equipamentos'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.manutencoes),
                  icon: const Icon(Icons.assignment_outlined, size: 18),
                  label: const Text('Ver manutenções'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Manutenções em aberto',
            child: abertas.isEmpty
                ? const Text('Nenhuma manutenção em aberto no momento.')
                : Column(
                    children: abertas.take(5).map((item) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.equipamento.nome,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                            '${item.tipo} · aberta em ${item.dataAbertura}'),
                        trailing: StatusBadge(item.status),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final String title;
  final String value;
  final IconData icon;

  const _MetricData(this.title, this.value, this.icon);
}

class _MetricCard extends StatelessWidget {
  final _MetricData metric;

  const _MetricCard(this.metric);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(metric.title,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Text(metric.value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 34)),
                ],
              ),
            ),
            Icon(metric.icon, color: AppTheme.primary, size: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
