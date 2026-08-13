import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { Eye, Pencil, Plus, Trash2 } from "lucide-react";
import { toast } from "sonner";
import { AppShell, StatusBadge } from "@/components/AppShell";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
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
  CATEGORIAS,
  STATUS_OPCOES,
  formatarData,
  nomeCategoria,
  podeGerenciarEquipamentos,
} from "@/lib/mock-data";

export const Route = createFileRoute("/equipamentos/")({
  head: () => ({
    meta: [
      { title: "Equipamentos — EquipControl" },
      {
        name: "description",
        content:
          "Listagem de equipamentos com busca, filtros por categoria e status, e ações de edição e exclusão.",
      },
      { property: "og:title", content: "Equipamentos — EquipControl" },
      {
        property: "og:description",
        content: "Consulte, cadastre e gerencie os equipamentos da operação.",
      },
    ],
  }),
  component: GuiaEquipamentos,
});

function GuiaEquipamentos() {
  const navigate = useNavigate();
  const { equipamentos, usuarios, perfil, removerEquipamento } = useApp();
  const gerencia = podeGerenciarEquipamentos(perfil);

  const [busca, setBusca] = useState("");
  const [categoria, setCategoria] = useState("todas");
  const [status, setStatus] = useState("todos");
  const [aExcluir, setAExcluir] = useState<number | null>(null);

  const lista = equipamentos.filter((e) => {
    const texto = `${e.nome} ${e.patrimonio}`.toLowerCase();
    return (
      texto.includes(busca.trim().toLowerCase()) &&
      (categoria === "todas" || e.id_categoria === Number(categoria)) &&
      (status === "todos" || e.status === status)
    );
  });

  const nomeUsuario = (id: number) => usuarios.find((u) => u.id === id)?.nome ?? "—";
  const alvo = equipamentos.find((e) => e.id_equipamento === aExcluir);

  return (
    <AppShell
      titulo="Equipamentos"
      descricao={`${lista.length} de ${equipamentos.length} equipamentos exibidos.`}
      acao={
        gerencia ? (
          <Button onClick={() => navigate({ to: "/equipamentos/novo" })}>
            <Plus className="h-4 w-4" aria-hidden="true" />
            Novo Equipamento
          </Button>
        ) : null
      }
    >
      <div className="mb-4 grid gap-3 rounded-lg border border-border bg-card p-4 shadow-panel sm:grid-cols-3">
        <Input
          value={busca}
          onChange={(e) => setBusca(e.target.value)}
          placeholder="Buscar por nome ou patrimônio"
          aria-label="Buscar equipamento"
        />
        <Select value={categoria} onValueChange={setCategoria}>
          <SelectTrigger aria-label="Filtrar por categoria">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="todas">Todas as categorias</SelectItem>
            {CATEGORIAS.map((c) => (
              <SelectItem key={c.id} value={String(c.id)}>
                {c.nome}
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
            {STATUS_OPCOES.map((s) => (
              <SelectItem key={s} value={s}>
                {s}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div className="overflow-x-auto rounded-lg border border-border bg-card shadow-panel">
        <table className="w-full min-w-[900px] text-left text-sm">
          <thead className="bg-muted text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-4 py-3">ID</th>
              <th className="px-4 py-3">Nome</th>
              <th className="px-4 py-3">Patrimônio</th>
              <th className="px-4 py-3">Aquisição</th>
              <th className="px-4 py-3">Categoria</th>
              <th className="px-4 py-3">Status</th>
              <th className="px-4 py-3">Responsável</th>
              <th className="px-4 py-3 text-right">Ações</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {lista.map((e) => (
              <tr key={e.id_equipamento} className="hover:bg-muted/50">
                <td className="px-4 py-3 text-muted-foreground">{e.id_equipamento}</td>
                <td className="px-4 py-3 font-medium text-foreground">{e.nome}</td>
                <td className="px-4 py-3">{e.patrimonio}</td>
                <td className="px-4 py-3">{formatarData(e.data_aquisicao)}</td>
                <td className="px-4 py-3">{nomeCategoria(e.id_categoria)}</td>
                <td className="px-4 py-3">
                  <StatusBadge status={e.status} />
                </td>
                <td className="px-4 py-3">{nomeUsuario(e.id_responsavel)}</td>
                <td className="px-4 py-3">
                  <div className="flex justify-end gap-1">
                    <Button asChild variant="ghost" size="icon" aria-label="Ver detalhes">
                      <Link to="/equipamentos/$id" params={{ id: String(e.id_equipamento) }}>
                        <Eye className="h-4 w-4" aria-hidden="true" />
                      </Link>
                    </Button>
                    {gerencia ? (
                      <>
                        <Button asChild variant="ghost" size="icon" aria-label="Editar">
                          <Link
                            to="/equipamentos/$id/editar"
                            params={{ id: String(e.id_equipamento) }}
                          >
                            <Pencil className="h-4 w-4" aria-hidden="true" />
                          </Link>
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          aria-label="Excluir"
                          onClick={() => setAExcluir(e.id_equipamento)}
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
                <td colSpan={8} className="px-4 py-10 text-center text-muted-foreground">
                  Nenhum equipamento encontrado com os filtros aplicados.
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>

      <AlertDialog open={aExcluir !== null} onOpenChange={(v) => !v && setAExcluir(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Excluir equipamento?</AlertDialogTitle>
            <AlertDialogDescription>
              {alvo
                ? `“${alvo.nome}” e suas manutenções vinculadas serão removidos permanentemente.`
                : ""}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancelar</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => {
                if (aExcluir !== null) {
                  removerEquipamento(aExcluir);
                  toast.success("Equipamento excluído com sucesso.");
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
