import { createFileRoute, Link, useNavigate, useParams } from "@tanstack/react-router";
import { ArrowLeft, Pencil } from "lucide-react";
import { AppShell, StatusBadge } from "@/components/AppShell";
import { Button } from "@/components/ui/button";
import { useApp } from "@/lib/app-store";
import { formatarData, formatarMoeda, podeGerenciarManutencoes } from "@/lib/mock-data";

export const Route = createFileRoute("/manutencoes/$id/")({
  head: () => ({
    meta: [
      { title: "Detalhes da Manutenção — EquipControl" },
      {
        name: "description",
        content:
          "Informações completas da ordem de manutenção: equipamento, tipo, status, datas, custo e responsável técnico.",
      },
      { property: "og:title", content: "Detalhes da Manutenção — EquipControl" },
      {
        property: "og:description",
        content: "Ficha completa da ordem de manutenção selecionada.",
      },
    ],
  }),
  component: DetalheManutencao,
});

function DetalheManutencao() {
  const { id } = useParams({ from: "/manutencoes/$id/" });
  const navigate = useNavigate();
  const { manutencoes, equipamentos, usuarios, perfil } = useApp();

  const manutencao = manutencoes.find((m) => m.id === Number(id));

  if (!manutencao) {
    return (
      <AppShell titulo="Manutenção não encontrada">
        <div className="rounded-lg border border-border bg-card p-8 shadow-panel">
          <p className="text-sm text-muted-foreground">
            A ordem de manutenção solicitada não existe ou foi removida.
          </p>
          <Button className="mt-4" variant="outline" onClick={() => navigate({ to: "/manutencoes" })}>
            <ArrowLeft className="h-4 w-4" aria-hidden="true" />
            Voltar para a lista
          </Button>
        </div>
      </AppShell>
    );
  }

  const equipamento = equipamentos.find((e) => e.id_equipamento === manutencao.equipamento_id);
  const responsavel = usuarios.find((u) => u.id === manutencao.id_responsavel);

  const campos = [
    { rotulo: "ID da manutenção", valor: String(manutencao.id) },
    {
      rotulo: "Equipamento",
      valor: equipamento ? `${equipamento.nome} · ${equipamento.patrimonio}` : "Equipamento removido",
    },
    { rotulo: "Tipo", valor: manutencao.tipo },
    { rotulo: "Data de abertura", valor: formatarData(manutencao.data_abertura) },
    { rotulo: "Data de conclusão", valor: formatarData(manutencao.data_conclusao) },
    { rotulo: "Custo", valor: formatarMoeda(manutencao.custo) },
    { rotulo: "Responsável técnico", valor: responsavel?.nome ?? "—" },
  ];

  return (
    <AppShell
      titulo={`Manutenção #${manutencao.id}`}
      descricao={equipamento?.nome ?? "Equipamento removido"}
      acao={
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => navigate({ to: "/manutencoes" })}>
            <ArrowLeft className="h-4 w-4" aria-hidden="true" />
            Voltar
          </Button>
          {podeGerenciarManutencoes(perfil) ? (
            <Button asChild>
              <Link to="/manutencoes/$id/editar" params={{ id }}>
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
          <StatusBadge status={manutencao.status} />
        </div>
        <dl className="grid gap-5 sm:grid-cols-2">
          {campos.map((c) => (
            <div key={c.rotulo}>
              <dt className="text-xs uppercase tracking-wide text-muted-foreground">{c.rotulo}</dt>
              <dd className="mt-1 text-base text-foreground">{c.valor}</dd>
            </div>
          ))}
          <div className="sm:col-span-2">
            <dt className="text-xs uppercase tracking-wide text-muted-foreground">Descrição</dt>
            <dd className="mt-1 text-base text-foreground">{manutencao.descricao}</dd>
          </div>
        </dl>
      </div>

      {equipamento ? (
        <div className="mt-6 rounded-lg border border-border bg-card p-6 shadow-panel">
          <h2 className="font-display text-xl uppercase tracking-wide text-foreground">
            Equipamento vinculado
          </h2>
          <p className="mt-2 text-sm text-muted-foreground">
            {equipamento.nome} — status {equipamento.status}
          </p>
          <Button asChild variant="outline" className="mt-4">
            <Link to="/equipamentos/$id" params={{ id: String(equipamento.id_equipamento) }}>
              Ver ficha do equipamento
            </Link>
          </Button>
        </div>
      ) : null}
    </AppShell>
  );
}
