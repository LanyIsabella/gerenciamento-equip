import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { toast } from "sonner";
import { AppShell } from "@/components/AppShell";
import { ManutencaoForm } from "@/components/ManutencaoForm";
import { SemPermissao } from "@/components/SemPermissao";
import { useApp } from "@/lib/app-store";
import { podeGerenciarManutencoes } from "@/lib/mock-data";

export const Route = createFileRoute("/manutencoes/nova")({
  head: () => ({
    meta: [
      { title: "Nova Manutenção — EquipControl" },
      {
        name: "description",
        content:
          "Abra uma nova ordem de manutenção preventiva ou corretiva vinculada a um equipamento.",
      },
      { property: "og:title", content: "Nova Manutenção — EquipControl" },
      {
        property: "og:description",
        content: "Formulário de abertura de ordens de manutenção.",
      },
    ],
  }),
  component: NovaManutencao,
});

function NovaManutencao() {
  const navigate = useNavigate();
  const { adicionarManutencao, perfil } = useApp();

  if (!podeGerenciarManutencoes(perfil)) {
    return <SemPermissao area="abrir manutenções" />;
  }

  return (
    <AppShell titulo="Nova Manutenção" descricao="Registre uma nova ordem de serviço.">
      <ManutencaoForm
        rotuloEnvio="Abrir manutenção"
        onCancel={() => navigate({ to: "/manutencoes" })}
        onSubmit={(dados) => {
          adicionarManutencao(dados);
          toast.success("Manutenção aberta com sucesso.");
          navigate({ to: "/manutencoes" });
        }}
      />
    </AppShell>
  );
}
