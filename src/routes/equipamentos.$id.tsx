import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowLeft } from "lucide-react";
import { AppShell, StatusBadge } from "@/components/AppShell";
import { Button } from "@/components/ui/button";
import { useEquipamentos } from "@/lib/equipamentos-store";
import { formatarData, nomeCategoria, nomeUsuario } from "@/lib/mock-data";

export const Route = createFileRoute("/equipamentos/$id")({
  head: () => ({
    meta: [
      { title: "Detalhes do Equipamento — MaqControl" },
      {
        name: "description",
        content:
          "Visualize todos os dados cadastrais do equipamento: patrimônio, aquisição, categoria, status e responsável.",
      },
      { property: "og:title", content: "Detalhes do Equipamento — MaqControl" },
      {
        property: "og:description",
        content: "Ficha completa do equipamento selecionado.",
      },
    ],
  }),
  component: TelaDetalhamentoEquipamento,
});

function Campo({ rotulo, children }: { rotulo: string; children: React.ReactNode }) {
  return (
    <div className="border-b border-border py-4 last:border-b-0">
      <dt className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
        {rotulo}
      </dt>
      <dd className="mt-1 text-base text-foreground">{children}</dd>
    </div>
  );
}

function TelaDetalhamentoEquipamento() {
  const { id } = Route.useParams();
  const { equipamentos } = useEquipamentos();
  const equipamento = equipamentos.find((e) => String(e.id_equipamento) === id);

  const voltar = (
    <Button asChild variant="outline">
      <Link to="/equipamentos">
        <ArrowLeft className="h-4 w-4" aria-hidden="true" />
        Voltar para a Lista
      </Link>
    </Button>
  );

  if (!equipamento) {
    return (
      <AppShell titulo="Equipamento não encontrado" acao={voltar}>
        <div className="rounded-lg border border-border bg-card p-8 text-center text-muted-foreground shadow-panel">
          O equipamento solicitado não existe no cadastro.
        </div>
      </AppShell>
    );
  }

  return (
    <AppShell
      titulo={equipamento.nome}
      descricao={`Detalhamento do equipamento #${equipamento.id_equipamento}`}
      acao={voltar}
    >
      <div className="max-w-3xl rounded-lg border border-border bg-card p-6 shadow-panel sm:p-8">
        <dl className="grid gap-x-10 sm:grid-cols-2">
          <Campo rotulo="ID do Equipamento">#{equipamento.id_equipamento}</Campo>
          <Campo rotulo="Nome">{equipamento.nome}</Campo>
          <Campo rotulo="Patrimônio">{equipamento.patrimonio}</Campo>
          <Campo rotulo="Data de Aquisição">{formatarData(equipamento.data_aquisicao)}</Campo>
          <Campo rotulo="Categoria">
            {nomeCategoria(equipamento.id_categoria)}{" "}
            <span className="text-sm text-muted-foreground">
              (ID {equipamento.id_categoria})
            </span>
          </Campo>
          <Campo rotulo="Status">
            <StatusBadge status={equipamento.status} />
          </Campo>
          <Campo rotulo="Responsável">
            {nomeUsuario(equipamento.id_responsavel)}{" "}
            <span className="text-sm text-muted-foreground">
              (ID {equipamento.id_responsavel})
            </span>
          </Campo>
        </dl>
      </div>
    </AppShell>
  );
}
