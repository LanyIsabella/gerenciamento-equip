import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { Boxes, ClipboardList, Plus, TriangleAlert, Wrench } from "lucide-react";
import { AppShell, StatusBadge } from "@/components/AppShell";
import { Button } from "@/components/ui/button";
import { useApp } from "@/lib/app-store";
import {
  formatarData,
  podeGerenciarEquipamentos,
  podeGerenciarManutencoes,
} from "@/lib/mock-data";

export const Route = createFileRoute("/inicio")({
  head: () => ({
    meta: [
      { title: "Painel — EquipControl | Equipamentos e Manutenções" },
      {
        name: "description",
        content:
          "Painel do EquipControl com métricas de equipamentos, manutenções abertas e atalhos rápidos por perfil.",
      },
      { property: "og:title", content: "Painel — EquipControl" },
      {
        property: "og:description",
        content: "Métricas e atalhos rápidos da gestão de equipamentos e manutenções.",
      },
    ],
  }),
  component: TelaInicial,
});

function TelaInicial() {
  const navigate = useNavigate();
  const { equipamentos, manutencoes, usuarioAtual, perfil } = useApp();

  const abertas = manutencoes.filter((m) => m.status !== "Concluída");
  const emManutencao = equipamentos.filter((e) => e.status === "Em Manutenção");
  const hoje = new Date().toISOString().slice(0, 10);
  const alertas = manutencoes.filter(
    (m) => m.status !== "Concluída" && m.data_abertura <= hoje,
  );

  const metricas = [
    { rotulo: "Total de Equipamentos", valor: equipamentos.length, icone: Boxes },
    { rotulo: "Manutenções Abertas", valor: abertas.length, icone: ClipboardList },
    { rotulo: "Equipamentos em Manutenção", valor: emManutencao.length, icone: Wrench },
    { rotulo: "Alertas do dia", valor: alertas.length, icone: TriangleAlert },
  ];

  return (
    <AppShell
      titulo={`Olá, ${usuarioAtual.nome.split(" ")[0]}`}
      descricao={`Sessão ativa com perfil ${perfil}. Veja o panorama da operação.`}
    >
      <section className="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {metricas.map(({ rotulo, valor, icone: Icone }) => (
          <div
            key={rotulo}
            className="rounded-lg border border-border bg-card p-5 shadow-panel"
          >
            <div className="flex items-center justify-between">
              <span className="text-sm text-muted-foreground">{rotulo}</span>
              <Icone className="h-5 w-5 text-primary" aria-hidden="true" />
            </div>
            <p className="mt-3 font-display text-4xl text-foreground">{valor}</p>
          </div>
        ))}
      </section>

      <section className="mb-8 rounded-lg border border-border bg-card p-6 shadow-panel">
        <h2 className="font-display text-xl uppercase tracking-wide text-foreground">
          Atalhos rápidos
        </h2>
        <div className="mt-4 flex flex-wrap gap-3">
          <Button variant="outline" onClick={() => navigate({ to: "/equipamentos" })}>
            <Boxes className="h-4 w-4" aria-hidden="true" />
            Ver equipamentos
          </Button>
          <Button variant="outline" onClick={() => navigate({ to: "/manutencoes" })}>
            <ClipboardList className="h-4 w-4" aria-hidden="true" />
            Ver manutenções
          </Button>
          {podeGerenciarEquipamentos(perfil) ? (
            <Button onClick={() => navigate({ to: "/equipamentos/novo" })}>
              <Plus className="h-4 w-4" aria-hidden="true" />
              Novo Equipamento
            </Button>
          ) : null}
          {podeGerenciarManutencoes(perfil) ? (
            <Button onClick={() => navigate({ to: "/manutencoes/nova" })}>
              <Plus className="h-4 w-4" aria-hidden="true" />
              Nova Manutenção
            </Button>
          ) : null}
        </div>
      </section>

      <section className="rounded-lg border border-border bg-card p-6 shadow-panel">
        <h2 className="font-display text-xl uppercase tracking-wide text-foreground">
          Manutenções em aberto
        </h2>
        {abertas.length === 0 ? (
          <p className="mt-4 text-sm text-muted-foreground">
            Nenhuma manutenção em aberto no momento.
          </p>
        ) : (
          <ul className="mt-4 divide-y divide-border">
            {abertas.slice(0, 5).map((m) => {
              const equipamento = equipamentos.find(
                (e) => e.id_equipamento === m.equipamento_id,
              );
              return (
                <li key={m.id} className="flex flex-wrap items-center justify-between gap-3 py-3">
                  <div>
                    <Link
                      to="/manutencoes/$id"
                      params={{ id: String(m.id) }}
                      className="font-medium text-foreground hover:underline"
                    >
                      {equipamento?.nome ?? "Equipamento removido"}
                    </Link>
                    <p className="text-sm text-muted-foreground">
                      {m.tipo} · aberta em {formatarData(m.data_abertura)}
                    </p>
                  </div>
                  <StatusBadge status={m.status} />
                </li>
              );
            })}
          </ul>
        )}
      </section>
    </AppShell>
  );
}
