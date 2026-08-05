import { createFileRoute, Link } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { Eye, Plus, Search } from "lucide-react";
import { AppShell, StatusBadge } from "@/components/AppShell";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useEquipamentos } from "@/lib/equipamentos-store";
import {
  CATEGORIAS,
  STATUS_OPCOES,
  formatarData,
  nomeCategoria,
  nomeUsuario,
} from "@/lib/mock-data";

export const Route = createFileRoute("/equipamentos/")({
  head: () => ({
    meta: [
      { title: "Listagem de Equipamentos — MaqControl" },
      {
        name: "description",
        content:
          "Consulte, busque e filtre todos os equipamentos por nome, categoria e status operacional.",
      },
      { property: "og:title", content: "Listagem de Equipamentos — MaqControl" },
      {
        property: "og:description",
        content: "Todos os equipamentos da operação com busca e filtros em tempo real.",
      },
    ],
  }),
  component: TelaListagemEquipamentos,
});

function TelaListagemEquipamentos() {
  const { equipamentos } = useEquipamentos();
  const [busca, setBusca] = useState("");
  const [categoria, setCategoria] = useState("todas");
  const [status, setStatus] = useState("todos");

  const lista = useMemo(
    () =>
      equipamentos.filter((e) => {
        const casaNome = e.nome.toLowerCase().includes(busca.trim().toLowerCase());
        const casaCategoria = categoria === "todas" || String(e.id_categoria) === categoria;
        const casaStatus = status === "todos" || e.status === status;
        return casaNome && casaCategoria && casaStatus;
      }),
    [equipamentos, busca, categoria, status],
  );

  const selectClasse =
    "h-10 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring";

  return (
    <AppShell
      titulo="Equipamentos"
      descricao={`${lista.length} de ${equipamentos.length} equipamento(s) exibido(s)`}
      acao={
        <Button asChild>
          <Link to="/equipamentos/novo">
            <Plus className="h-4 w-4" aria-hidden="true" />
            Novo Equipamento
          </Link>
        </Button>
      }
    >
      <section className="mb-6 rounded-lg border border-border bg-card p-4 shadow-panel">
        <div className="grid gap-4 md:grid-cols-3">
          <div className="space-y-2">
            <Label htmlFor="busca">Buscar por nome</Label>
            <div className="relative">
              <Search
                className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground"
                aria-hidden="true"
              />
              <Input
                id="busca"
                value={busca}
                onChange={(e) => setBusca(e.target.value)}
                placeholder="Ex.: Torno CNC"
                className="pl-9"
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="filtro-categoria">Categoria</Label>
            <select
              id="filtro-categoria"
              className={selectClasse}
              value={categoria}
              onChange={(e) => setCategoria(e.target.value)}
            >
              <option value="todas">Todas as categorias</option>
              {CATEGORIAS.map((c) => (
                <option key={c.id} value={String(c.id)}>
                  {c.nome}
                </option>
              ))}
            </select>
          </div>

          <div className="space-y-2">
            <Label htmlFor="filtro-status">Status</Label>
            <select
              id="filtro-status"
              className={selectClasse}
              value={status}
              onChange={(e) => setStatus(e.target.value)}
            >
              <option value="todos">Todos os status</option>
              {STATUS_OPCOES.map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
          </div>
        </div>
      </section>

      <section className="overflow-x-auto rounded-lg border border-border bg-card shadow-panel">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-16">ID</TableHead>
              <TableHead>Nome</TableHead>
              <TableHead>Patrimônio</TableHead>
              <TableHead>Data de Aquisição</TableHead>
              <TableHead>Categoria</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Responsável</TableHead>
              <TableHead className="text-right">Ações</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {lista.length === 0 ? (
              <TableRow>
                <TableCell colSpan={8} className="py-10 text-center text-muted-foreground">
                  Nenhum equipamento encontrado com os filtros aplicados.
                </TableCell>
              </TableRow>
            ) : (
              lista.map((e) => (
                <TableRow key={e.id_equipamento}>
                  <TableCell className="font-mono text-xs text-muted-foreground">
                    #{e.id_equipamento}
                  </TableCell>
                  <TableCell className="font-medium">{e.nome}</TableCell>
                  <TableCell className="font-mono text-xs">{e.patrimonio}</TableCell>
                  <TableCell>{formatarData(e.data_aquisicao)}</TableCell>
                  <TableCell>{nomeCategoria(e.id_categoria)}</TableCell>
                  <TableCell>
                    <StatusBadge status={e.status} />
                  </TableCell>
                  <TableCell>{nomeUsuario(e.id_responsavel)}</TableCell>
                  <TableCell className="text-right">
                    <Button asChild variant="outline" size="sm">
                      <Link
                        to="/equipamentos/$id"
                        params={{ id: String(e.id_equipamento) }}
                        aria-label={`Ver detalhes de ${e.nome}`}
                      >
                        <Eye className="h-4 w-4" aria-hidden="true" />
                        Ver detalhes
                      </Link>
                    </Button>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </section>
    </AppShell>
  );
}
