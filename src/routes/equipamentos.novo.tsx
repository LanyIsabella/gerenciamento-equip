import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { toast } from "sonner";
import { AppShell } from "@/components/AppShell";
import { EquipamentoForm } from "@/components/EquipamentoForm";
import { useApp } from "@/lib/app-store";
import { podeGerenciarEquipamentos } from "@/lib/mock-data";
import { SemPermissao } from "@/components/SemPermissao";

export const Route = createFileRoute("/equipamentos/novo")({
  head: () => ({
    meta: [
      { title: "Novo Equipamento — EquipControl" },
      {
        name: "description",
        content:
          "Cadastre um novo equipamento informando nome, patrimônio, categoria, status e responsável.",
      },
      { property: "og:title", content: "Novo Equipamento — EquipControl" },
      {
        property: "og:description",
        content: "Formulário de cadastro de equipamentos do EquipControl.",
      },
    ],
  }),
  component: NovoEquipamento,
});

function NovoEquipamento() {
  const navigate = useNavigate();
  const { adicionarEquipamento, perfil } = useApp();

  if (!podeGerenciarEquipamentos(perfil)) {
    return <SemPermissao area="cadastrar equipamentos" />;
  }

  return (
    <AppShell titulo="Novo Equipamento" descricao="Preencha os dados do equipamento.">
      <EquipamentoForm
        rotuloEnvio="Cadastrar equipamento"
        onCancel={() => navigate({ to: "/equipamentos" })}
        onSubmit={(dados) => {
          adicionarEquipamento(dados);
          toast.success("Equipamento cadastrado com sucesso.");
          navigate({ to: "/equipamentos" });
        }}
      />
    </AppShell>
  );
}
