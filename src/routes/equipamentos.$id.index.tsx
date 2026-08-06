import { createFileRoute, Link, useNavigate, useParams } from "@tanstack/react-router";
import { ArrowLeft, Pencil } from "lucide-react";
import { AppShell, StatusBadge } from "@/components/AppShell";
import { Button } from "@/components/ui/button";
import { useApp } from "@/lib/app-store";
import {
  formatarData,
  formatarMoeda,
  nomeCategoria,
  podeGerenciarEquipamentos,
} from "@/lib/mock-data";

export const Route = createFileRoute("/equipamentos/$id/")({
  head: () => ({
    meta: [
      { title: "Detalhes do Equipamento — EquipControl" },
      {
        name: "description",
        content:
          "Ficha técnica completa do equipamento com dados de patrimônio, categoria, status, responsável e histórico de manutenções.",
      },
      { property: "og:title", content: "Detalhes do Equipamento — EquipControl" },
      {
        property: "og:description",
        content: "Ficha completa e histórico de manutenções do equipamento.",
      },
    ],
  }),
  component: DetalheEquipamento,
});

function DetalheEquipamento() {
  const { id } = useParams({ from: "/equipamentos/$id" });
  const navigate = useNavigate();
  const { equipamentos, manutencoes, usuarios, perfil } = useApp();

  const equipamento = equipamentos.find((e) => e.id_equipamento === Number(id));

  if (!equipamento) {
    return (
      <AppShell titulo="Equipamento não encontrado">
        <div className="rounded-lg border border-border bg-card p-8 shadow-panel">
          <p className="text-sm text-muted-foreground">
            O equipamento solicitado não existe ou foi removido.
          </p>
          <Button className="mt-4" variant="outline" onClick={() => navigate({ to: "/equipamentos" })}>
            <ArrowLeft className="h-4 w-4" aria-hidden="true" />
            Voltar para a lista
          </Button>
        </div>
      </AppShell>
    );
  }

  const responsavel = usuarios.find((u) => u.id === equipamento.id_responsavel);
  const historico = manutencoes.filter((m) => m.equipamento_id === equipamento.id_equipamento);

  const campos = [
    { rotulo: "ID do equipamento", valor: String(equipamento.id_equipamento) },
    { rotulo: "Nome", valor: equipamento.nome },
    { rotulo: "Patrimônio", valor: equipamento.patrimonio },
    { rotulo: "Data de aquisição", valor: formatarData(equipamento.data_aquisicao) },
    { rotulo: "Categoria", valor: nomeCategoria(equipamento.id_categoria) },
    { rotulo: "Responsável", valor: responsavel ? `${responsavel.nome} · ${responsavel.perfil}` : "—" },
  ];

  return (
    <AppShell
      titulo={equipamento.nome}
      descricao={`Patrimônio ${equipamento.patrimonio}`}
      acao={
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => navigate({ to: "/equipamentos" })}>
            <ArrowLeft className="h-4 w-4" aria-hidden="true" />
            Voltar
          </Button>
          {podeGerenciarEquipamentos(perfil) ? (
            <Button asChild>
              <Link to="/equipamentos/$id/editar" params={{ id }}>
                <Pencil className="h-4 w-4" aria-hidden="true" />
                Editar
              </Link>
            </Button>
          ) : null}
        </div>
      }
    >
      <div className="rounded-lg border border-border bg-card p-6 shadow-panel">
        <div className="mb-6 flex items-center gap-3">
          <span className="text-sm text-muted-foreground">Status atual:</span>
          <StatusBadge status={equipamento.status} />
        </div>
        <dl className="grid gap-5 sm:grid-cols-2">
          {campos.map((c) => (
            <div key={c.rotulo}>
              <dt className="text-xs uppercase tracking-wide text-muted-foreground">{c.rotulo}</dt>
              <dd className="mt-1 text-base text-foreground">{c.valor}</dd>
            </div>
          ))}
        </dl>
      </div>

      <div className="mt-6 rounded-lg border border-border bg-card p-6 shadow-panel">
        <h2 className="font-display text-xl uppercase tracking-wide text-foreground">
          Histórico de manutenções
        </h2>
        {historico.length === 0 ? (
          <p className="mt-3 text-sm text-muted-foreground">
            Nenhuma manutenção registrada para este equipamento.
          </p>
        ) : (
          <ul className="mt-4 divide-y divide-border">
            {historico.map((m) => (
              <li key={m.id} className="flex flex-wrap items-center justify-between gap-3 py-3">
                <div>
                  <Link
                    to="/manutencoes/$id"
                    params={{ id: String(m.id) }}
                    className="font-medium text-foreground hover:underline"
                  >
                    {m.descricao}
                  </Link>
                  <p className="text-sm text-muted-foreground">
                    {m.tipo} · abertura {formatarData(m.data_abertura)} · {formatarMoeda(m.custo)}
                  </p>
                </div>
                <StatusBadge status={m.status} />
              </li>
            ))}
          </ul>
        )}
      </div>
    </AppShell>
  );
}
