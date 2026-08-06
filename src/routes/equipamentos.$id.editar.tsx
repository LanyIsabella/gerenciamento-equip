import { createFileRoute, useNavigate, useParams } from "@tanstack/react-router";
import { toast } from "sonner";
import { AppShell } from "@/components/AppShell";
import { EquipamentoForm } from "@/components/EquipamentoForm";
import { SemPermissao } from "@/components/SemPermissao";
import { Button } from "@/components/ui/button";
import { useApp } from "@/lib/app-store";
import { podeGerenciarEquipamentos } from "@/lib/mock-data";

export const Route = createFileRoute("/equipamentos/$id/editar")({
  head: () => ({
    meta: [
      { title: "Editar Equipamento — EquipControl" },
      {
        name: "description",
        content: "Atualize os dados cadastrais de um equipamento do EquipControl.",
      },
      { property: "og:title", content: "Editar Equipamento — EquipControl" },
      {
        property: "og:description",
        content: "Formulário de edição de equipamentos do EquipControl.",
      },
    ],
  }),
  component: EditarEquipamento,
});

function EditarEquipamento() {
  const { id } = useParams({ from: "/equipamentos/$id/editar" });
  const navigate = useNavigate();
  const { equipamentos, atualizarEquipamento, perfil } = useApp();

  if (!podeGerenciarEquipamentos(perfil)) {
    return <SemPermissao area="editar equipamentos" />;
  }

  const equipamento = equipamentos.find((e) => e.id_equipamento === Number(id));

  if (!equipamento) {
    return (
      <AppShell titulo="Equipamento não encontrado">
        <div className="rounded-lg border border-border bg-card p-8 shadow-panel">
          <p className="text-sm text-muted-foreground">
            O equipamento solicitado não existe ou foi removido.
          </p>
          <Button className="mt-4" variant="outline" onClick={() => navigate({ to: "/equipamentos" })}>
            Voltar para a lista
          </Button>
        </div>
      </AppShell>
    );
  }

  const { id_equipamento, ...dadosIniciais } = equipamento;

  return (
    <AppShell titulo="Editar Equipamento" descricao={equipamento.nome}>
      <EquipamentoForm
        inicial={dadosIniciais}
        idAtual={id_equipamento}
        rotuloEnvio="Salvar alterações"
        onCancel={() => navigate({ to: "/equipamentos/$id", params: { id } })}
        onSubmit={(dados) => {
          atualizarEquipamento(id_equipamento, dados);
          toast.success("Equipamento atualizado com sucesso.");
          navigate({ to: "/equipamentos/$id", params: { id } });
        }}
      />
    </AppShell>
  );
}
