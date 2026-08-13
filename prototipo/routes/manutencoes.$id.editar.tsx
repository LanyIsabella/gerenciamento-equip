import { createFileRoute, useNavigate, useParams } from "@tanstack/react-router";
import { toast } from "sonner";
import { AppShell } from "@/components/AppShell";
import { ManutencaoForm } from "@/components/ManutencaoForm";
import { SemPermissao } from "@/components/SemPermissao";
import { Button } from "@/components/ui/button";
import { useApp } from "@/lib/app-store";
import { podeGerenciarManutencoes } from "@/lib/mock-data";

export const Route = createFileRoute("/manutencoes/$id/editar")({
  head: () => ({
    meta: [
      { title: "Editar Manutenção — EquipControl" },
      {
        name: "description",
        content: "Atualize os dados da ordem de manutenção, incluindo status, datas e custo.",
      },
      { property: "og:title", content: "Editar Manutenção — EquipControl" },
      {
        property: "og:description",
        content: "Formulário de edição de ordens de manutenção.",
      },
    ],
  }),
  component: EditarManutencao,
});

function EditarManutencao() {
  const { id } = useParams({ from: "/manutencoes/$id/editar" });
  const navigate = useNavigate();
  const { manutencoes, atualizarManutencao, perfil } = useApp();

  if (!podeGerenciarManutencoes(perfil)) {
    return <SemPermissao area="editar manutenções" />;
  }

  const manutencao = manutencoes.find((m) => m.id === Number(id));

  if (!manutencao) {
    return (
      <AppShell titulo="Manutenção não encontrada">
        <div className="rounded-lg border border-border bg-card p-8 shadow-panel">
          <p className="text-sm text-muted-foreground">
            A ordem de manutenção solicitada não existe ou foi removida.
          </p>
          <Button className="mt-4" variant="outline" onClick={() => navigate({ to: "/manutencoes" })}>
            Voltar para a lista
          </Button>
        </div>
      </AppShell>
    );
  }

  const { id: idAtual, ...dadosIniciais } = manutencao;

  return (
    <AppShell titulo={`Editar Manutenção #${idAtual}`} descricao="Atualize a ordem de serviço.">
      <ManutencaoForm
        inicial={dadosIniciais}
        rotuloEnvio="Salvar alterações"
        onCancel={() => navigate({ to: "/manutencoes/$id", params: { id } })}
        onSubmit={(dados) => {
          atualizarManutencao(idAtual, dados);
          toast.success("Manutenção atualizada com sucesso.");
          navigate({ to: "/manutencoes/$id", params: { id } });
        }}
      />
    </AppShell>
  );
}
