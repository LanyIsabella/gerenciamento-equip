import { createFileRoute, useNavigate, Link } from "@tanstack/react-router";
import { useState } from "react";
import { ArrowLeft, Save } from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/AppShell";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useEquipamentos } from "@/lib/equipamentos-store";
import { CATEGORIAS, STATUS_OPCOES, USUARIOS } from "@/lib/mock-data";

export const Route = createFileRoute("/equipamentos/novo")({
  head: () => ({
    meta: [
      { title: "Cadastro de Equipamento — MaqControl" },
      {
        name: "description",
        content:
          "Cadastre um novo equipamento informando nome, patrimônio, data de aquisição, categoria, status e responsável.",
      },
      { property: "og:title", content: "Cadastro de Equipamento — MaqControl" },
      {
        property: "og:description",
        content: "Formulário de inclusão de equipamentos no inventário.",
      },
    ],
  }),
  component: TelaCadastroEquipamento,
});

const selectClasse =
  "h-10 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring";

function TelaCadastroEquipamento() {
  const navigate = useNavigate();
  const { adicionarEquipamento } = useEquipamentos();

  const [nome, setNome] = useState("");
  const [patrimonio, setPatrimonio] = useState("");
  const [dataAquisicao, setDataAquisicao] = useState("");
  const [idCategoria, setIdCategoria] = useState("");
  const [status, setStatus] = useState("");
  const [idResponsavel, setIdResponsavel] = useState("");
  const [erros, setErros] = useState<Record<string, string>>({});

  const salvar = (evento: React.FormEvent) => {
    evento.preventDefault();
    const novosErros: Record<string, string> = {};
    if (!nome.trim()) novosErros.nome = "Informe o nome do equipamento.";
    if (!patrimonio.trim()) novosErros.patrimonio = "Informe o patrimônio.";
    if (!dataAquisicao) novosErros.data_aquisicao = "Informe a data de aquisição.";
    if (!idCategoria) novosErros.id_categoria = "Selecione a categoria.";
    if (!status) novosErros.status = "Selecione o status.";
    if (!idResponsavel) novosErros.id_responsavel = "Selecione o responsável.";

    setErros(novosErros);
    if (Object.keys(novosErros).length > 0) return;

    adicionarEquipamento({
      nome: nome.trim(),
      patrimonio: patrimonio.trim(),
      data_aquisicao: dataAquisicao,
      id_categoria: Number(idCategoria),
      status,
      id_responsavel: Number(idResponsavel),
    });

    toast.success("Equipamento salvo com sucesso!");
    navigate({ to: "/equipamentos" });
  };

  const mensagem = (campo: string) =>
    erros[campo] ? <p className="text-sm text-destructive">{erros[campo]}</p> : null;

  return (
    <AppShell
      titulo="Novo Equipamento"
      descricao="Preencha os dados do equipamento para incluí-lo no inventário"
      acao={
        <Button asChild variant="outline">
          <Link to="/equipamentos">
            <ArrowLeft className="h-4 w-4" aria-hidden="true" />
            Voltar para a lista
          </Link>
        </Button>
      }
    >
      <form
        onSubmit={salvar}
        className="max-w-3xl rounded-lg border border-border bg-card p-6 shadow-panel"
      >
        <div className="grid gap-5 sm:grid-cols-2">
          <div className="space-y-2 sm:col-span-2">
            <Label htmlFor="nome">Nome *</Label>
            <Input
              id="nome"
              value={nome}
              onChange={(e) => setNome(e.target.value)}
              placeholder="Ex.: Torno CNC Mazak QT-200"
            />
            {mensagem("nome")}
          </div>

          <div className="space-y-2">
            <Label htmlFor="patrimonio">Patrimônio *</Label>
            <Input
              id="patrimonio"
              value={patrimonio}
              onChange={(e) => setPatrimonio(e.target.value)}
              placeholder="Ex.: PAT-001500"
            />
            {mensagem("patrimonio")}
          </div>

          <div className="space-y-2">
            <Label htmlFor="data_aquisicao">Data de Aquisição *</Label>
            <Input
              id="data_aquisicao"
              type="date"
              value={dataAquisicao}
              onChange={(e) => setDataAquisicao(e.target.value)}
            />
            {mensagem("data_aquisicao")}
          </div>

          <div className="space-y-2">
            <Label htmlFor="id_categoria">Categoria *</Label>
            <select
              id="id_categoria"
              className={selectClasse}
              value={idCategoria}
              onChange={(e) => setIdCategoria(e.target.value)}
            >
              <option value="">Selecione a categoria</option>
              {CATEGORIAS.map((c) => (
                <option key={c.id} value={String(c.id)}>
                  {c.nome}
                </option>
              ))}
            </select>
            {mensagem("id_categoria")}
          </div>

          <div className="space-y-2">
            <Label htmlFor="status">Status *</Label>
            <select
              id="status"
              className={selectClasse}
              value={status}
              onChange={(e) => setStatus(e.target.value)}
            >
              <option value="">Selecione o status</option>
              {STATUS_OPCOES.map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
            {mensagem("status")}
          </div>

          <div className="space-y-2 sm:col-span-2">
            <Label htmlFor="id_responsavel">Responsável *</Label>
            <select
              id="id_responsavel"
              className={selectClasse}
              value={idResponsavel}
              onChange={(e) => setIdResponsavel(e.target.value)}
            >
              <option value="">Selecione o responsável</option>
              {USUARIOS.map((u) => (
                <option key={u.id} value={String(u.id)}>
                  {u.nome}
                </option>
              ))}
            </select>
            {mensagem("id_responsavel")}
          </div>
        </div>

        <div className="mt-8 flex flex-wrap gap-3">
          <Button type="submit">
            <Save className="h-4 w-4" aria-hidden="true" />
            Salvar Equipamento
          </Button>
          <Button
            type="button"
            variant="outline"
            onClick={() => navigate({ to: "/equipamentos" })}
          >
            Cancelar
          </Button>
        </div>
      </form>
    </AppShell>
  );
}
