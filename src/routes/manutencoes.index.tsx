import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { Eye, Pencil, Plus, Trash2 } from "lucide-react";
import { toast } from "sonner";
import { AppShell, StatusBadge } from "@/components/AppShell";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { useApp } from "@/lib/app-store";
import {
  STATUS_MANUTENCAO,
  TIPOS_MANUTENCAO,
  formatarData,
  formatarMoeda,
  podeGerenciarManutencoes,
} from "@/lib/mock-data";

export const Route = createFileRoute("/manutencoes/")({
  head: () => ({
    meta: [
      { title: "Manutenções — EquipControl" },
      {
        name: "description",
        content:
          "Controle de ordens de manutenção preventiva e corretiva com filtros por equipamento, tipo e status.",
      },
      { property: "og:title", content: "Manutenções — EquipControl" },
      {
        property: "og:description",
        content: "Abra, acompanhe e conclua manutenções dos equipamentos.",
      },
    ],
  }),
  component: GuiaManutencoes,
});

function GuiaManutencoes() {
  const navigate = useNavigate();
  const { manutencoes, equipamentos, usuarios, perfil, removerManutencao } = useApp();
  const gerencia = podeGerenciarManutencoes(perfil);

  const [equipamento, setEquipamento] = useState("todos");
  const [tipo, setTipo] = useState("todos");
  const [status, setStatus] = useState("todos");
  const [aExcluir, setAExcluir] = useState<number | null>(null);

  const lista = manutencoes.filter(
    (m) =>
      (equipamento === "todos" || m.equipamento_id === Number(equipamento)) &&
      (tipo === "todos" || m.tipo === tipo) &&
      (status === "todos" || m.status === status),
  );

  const nomeEquipamento = (id: number) =>
    equipamentos.find((e) => e.id_equipamento === id)?.nome ?? "Equipamento removido";
  const nomeUsuario = (id: number) => usuarios.find((u) => u.id === id)?.nome ?? "—";

  return (
    <AppShell
      titulo="Manutenções"
      descricao={`${lista.length} de ${manutencoes.length} ordens exibidas.`}
      acao={
        gerencia ? (
          <Button onClick={() => navigate({ to: "/manutencoes/nova" })}>
            <Plus className="h-4 w-4" aria-hidden="true" />
            Abrir Nova Manutenção
          </Button>
        ) : null
      }
    >
      <div className="mb-4 grid gap-3 rounded-lg border border-border bg-card p-4 shadow-panel sm:grid-cols-3">
        <Select value={equipamento} onValueChange={setEquipamento}>
          <SelectTrigger aria-label="Filtrar por equipamento">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="todos">Todos os equipamentos</SelectItem>
            {equipamentos.map((e) => (
              <SelectItem key={e.id_equipamento} value={String(e.id_equipamento)}>
                {e.nome}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Select value={tipo} onValueChange={setTipo}>
          <SelectTrigger aria-label="Filtrar por tipo">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="todos">Todos os tipos</SelectItem>
            {TIPOS_MANUTENCAO.map((t) => (
              <SelectItem key={t} value={t}>
                {t}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Select value={status} onValueChange={setStatus}>
          <SelectTrigger aria-label="Filtrar por status">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="todos">Todos os status</SelectItem>
            {STATUS_MANUTENCAO.map((s) => (
              <SelectItem key={s} value={s}>
                {s}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div className="overflow-x-auto rounded-lg border border-border bg-card shadow-panel">
        <table className="w-full min-w-[950px] text-left text-sm">
          <thead className="bg-muted text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-4 py-3">ID</th>
              <th className="px-4 py-3">Equipamento</th>
              <th className="px-4 py-3">Descrição</th>
              <th className="px-4 py-3">Tipo</th>
              <th className="px-4 py-3">Status</th>
              <th className="px-4 py-3">Abertura</th>
              <th className="px-4 py-3">Custo</th>
              <th className="px-4 py-3">Responsável</th>
              <th className="px-4 py-3 text-right">Ações</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {lista.map((m) => (
              <tr key={m.id} className="hover:bg-muted/50">
                <td className="px-4 py-3 text-muted-foreground">{m.id}</td>
                <td className="px-4 py-3 font-medium text-foreground">
                  {nomeEquipamento(m.equipamento_id)}
                </td>
                <td className="max-w-[240px] truncate px-4 py-3">{m.descricao}</td>
                <td className="px-4 py-3">{m.tipo}</td>
                <td className="px-4 py-3">
                  <StatusBadge status={m.status} />
                </td>
                <td className="px-4 py-3">{formatarData(m.data_abertura)}</td>
                <td className="px-4 py-3">{formatarMoeda(m.custo)}</td>
                <td className="px-4 py-3">{nomeUsuario(m.id_responsavel)}</td>
                <td className="px-4 py-3">
                  <div className="flex justify-end gap-1">
                    <Button asChild variant="ghost" size="icon" aria-label="Ver detalhes">
                      <Link to="/manutencoes/$id" params={{ id: String(m.id) }}>
                        <Eye className="h-4 w-4" aria-hidden="true" />
                      </Link>
                    </Button>
                    {gerencia ? (
                      <>
                        <Button asChild variant="ghost" size="icon" aria-label="Editar">
                          <Link to="/manutencoes/$id/editar" params={{ id: String(m.id) }}>
                            <Pencil className="h-4 w-4" aria-hidden="true" />
                          </Link>
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          aria-label="Excluir"
                          onClick={() => setAExcluir(m.id)}
                        >
                          <Trash2 className="h-4 w-4 text-destructive" aria-hidden="true" />
                        </Button>
                      </>
                    ) : null}
                  </div>
                </td>
              </tr>
            ))}
            {lista.length === 0 ? (
              <tr>
                <td colSpan={9} className="px-4 py-10 text-center text-muted-foreground">
                  Nenhuma manutenção encontrada com os filtros aplicados.
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>

      <AlertDialog open={aExcluir !== null} onOpenChange={(v) => !v && setAExcluir(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Excluir manutenção?</AlertDialogTitle>
            <AlertDialogDescription>
              Esta ordem de manutenção será removida permanentemente do sistema.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancelar</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => {
                if (aExcluir !== null) {
                  removerManutencao(aExcluir);
                  toast.success("Manutenção excluída com sucesso.");
                }
                setAExcluir(null);
              }}
            >
              Excluir
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </AppShell>
  );
}
