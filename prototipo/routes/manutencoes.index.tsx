import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { Fragment, useState } from "react";
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
  const [expandida, setExpandida] = useState<number | null>(null);

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

      <div className="grid gap-3 xl:hidden">
        {lista.map((m) => (
          <article key={m.id} className="rounded-lg border border-border bg-card p-4 shadow-panel">
            <div className="flex items-start justify-between gap-3">
              <div className="min-w-0">
                <p className="truncate font-medium text-foreground">
                  {nomeEquipamento(m.equipamento_id)}
                </p>
                <p className="mt-1 text-sm text-muted-foreground">
                  #{m.id} · {m.tipo} · {formatarData(m.data_abertura)}
                </p>
              </div>
              <StatusBadge status={m.status} />
            </div>

            <dl className="mt-4 grid grid-cols-2 gap-3 text-sm">
              <div className="min-w-0">
                <dt className="text-muted-foreground">Descrição</dt>
                <dd className="truncate text-foreground">{m.descricao}</dd>
              </div>
              <div>
                <dt className="text-muted-foreground">Custo</dt>
                <dd className="text-foreground">{formatarMoeda(m.custo)}</dd>
              </div>
              <div className="min-w-0">
                <dt className="text-muted-foreground">Responsável</dt>
                <dd className="truncate text-foreground">{nomeUsuario(m.id_responsavel)}</dd>
              </div>
            </dl>

            <div className="mt-4 flex flex-wrap gap-2">
              <Button asChild variant="outline" className="min-w-[150px] flex-1">
                <Link to="/manutencoes/$id" params={{ id: String(m.id) }}>
                  <Eye className="h-4 w-4" aria-hidden="true" />
                  Ver detalhes
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
          </article>
        ))}
        {lista.length === 0 ? (
          <div className="rounded-lg border border-border bg-card px-4 py-10 text-center text-muted-foreground shadow-panel">
            Nenhuma manutenÃ§Ã£o encontrada com os filtros aplicados.
          </div>
        ) : null}
      </div>

      <div className="hidden overflow-hidden rounded-lg border border-border bg-card shadow-panel xl:block">
        <table className="w-full table-fixed text-left text-sm">
          <colgroup>
            <col className="w-[5%]" />
            <col className="w-[27%]" />
            <col className="w-[13%]" />
            <col className="w-[13%]" />
            <col className="w-[15%]" />
            <col className="w-[27%]" />
          </colgroup>
          <thead className="bg-muted text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-4 py-3">ID</th>
              <th className="px-4 py-3">Equipamento</th>
              <th className="px-4 py-3">Tipo</th>
              <th className="px-4 py-3">Status</th>
              <th className="px-4 py-3">Abertura</th>
              <th className="px-4 py-3 text-right">Ações</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {lista.map((m) => {
              const estaExpandida = expandida === m.id;

              return (
                <Fragment key={m.id}>
                  <tr className={estaExpandida ? "bg-muted/50" : "hover:bg-muted/50"}>
                    <td className="px-4 py-3 text-muted-foreground">{m.id}</td>
                    <td className="truncate px-4 py-3 font-medium text-foreground">
                      {nomeEquipamento(m.equipamento_id)}
                    </td>
                    <td className="truncate px-4 py-3">{m.tipo}</td>
                    <td className="px-4 py-3">
                      <StatusBadge status={m.status} />
                    </td>
                    <td className="whitespace-nowrap px-4 py-3">
                      {formatarData(m.data_abertura)}
                    </td>
                    <td className="whitespace-nowrap px-2 py-3">
                      <div className="flex justify-end gap-1">
                        <Button
                          variant="outline"
                          size="sm"
                          aria-expanded={estaExpandida}
                          onClick={() => setExpandida(estaExpandida ? null : m.id)}
                        >
                          <Eye className="h-4 w-4" aria-hidden="true" />
                          {estaExpandida ? "Ocultar" : "Detalhes"}
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
                  {estaExpandida ? (
                    <tr className="bg-muted/30">
                      <td colSpan={6} className="border-t border-border px-4 py-4">
                        <dl className="grid gap-4 text-sm sm:grid-cols-2 lg:grid-cols-4">
                          <div className="sm:col-span-2 lg:col-span-2">
                            <dt className="text-muted-foreground">Descrição</dt>
                            <dd className="mt-1 break-words text-foreground">{m.descricao}</dd>
                          </div>
                          <div>
                            <dt className="text-muted-foreground">Custo</dt>
                            <dd className="mt-1 text-foreground">{formatarMoeda(m.custo)}</dd>
                          </div>
                          <div>
                            <dt className="text-muted-foreground">Responsável</dt>
                            <dd className="mt-1 truncate text-foreground">
                              {nomeUsuario(m.id_responsavel)}
                            </dd>
                          </div>
                          <div>
                            <dt className="text-muted-foreground">Conclusão</dt>
                            <dd className="mt-1 text-foreground">
                              {m.data_conclusao || "Em aberto"}
                            </dd>
                          </div>
                        </dl>
                      </td>
                    </tr>
                  ) : null}
                </Fragment>
              );
            })}
            {lista.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-4 py-10 text-center text-muted-foreground">
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
