import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useApp } from "@/lib/app-store";
import { CATEGORIAS, STATUS_OPCOES, type Equipamento } from "@/lib/mock-data";

export type DadosEquipamento = Omit<Equipamento, "id_equipamento">;

type Erros = Partial<Record<keyof DadosEquipamento, string>>;

export function EquipamentoForm({
  inicial,
  idAtual,
  onSubmit,
  onCancel,
  rotuloEnvio,
}: {
  inicial?: DadosEquipamento;
  idAtual?: number;
  onSubmit: (dados: DadosEquipamento) => void;
  onCancel: () => void;
  rotuloEnvio: string;
}) {
  const { equipamentos, usuarios } = useApp();
  const responsaveis = usuarios.filter((u) => u.perfil !== "Operador");

  const [dados, setDados] = useState<DadosEquipamento>(
    inicial ?? {
      nome: "",
      patrimonio: "",
      data_aquisicao: "",
      id_categoria: 0,
      status: "Ativo",
      id_responsavel: responsaveis[0]?.id ?? 0,
    },
  );
  const [tocado, setTocado] = useState<Record<string, boolean>>({});
  const [enviado, setEnviado] = useState(false);

  const erros: Erros = {};
  if (!dados.nome.trim()) erros.nome = "Informe o nome do equipamento.";
  if (!dados.patrimonio.trim()) erros.patrimonio = "Informe o número de patrimônio.";
  else if (
    equipamentos.some(
      (e) =>
        e.patrimonio.trim().toLowerCase() === dados.patrimonio.trim().toLowerCase() &&
        e.id_equipamento !== idAtual,
    )
  )
    erros.patrimonio = "Já existe um equipamento com este patrimônio.";
  if (!dados.id_categoria) erros.id_categoria = "Selecione uma categoria.";
  if (!dados.data_aquisicao) erros.data_aquisicao = "Informe a data de aquisição.";
  if (!dados.id_responsavel) erros.id_responsavel = "Selecione um responsável.";

  const mostrar = (campo: keyof DadosEquipamento) =>
    (enviado || tocado[campo]) && erros[campo] ? erros[campo] : "";

  const enviar = (evento: React.FormEvent) => {
    evento.preventDefault();
    setEnviado(true);
    if (Object.keys(erros).length > 0) return;
    onSubmit({ ...dados, nome: dados.nome.trim(), patrimonio: dados.patrimonio.trim() });
  };

  return (
    <form
      onSubmit={enviar}
      className="space-y-6 rounded-lg border border-border bg-card p-6 shadow-panel"
    >
      <div className="grid gap-5 sm:grid-cols-2">
        <div className="space-y-2 sm:col-span-2">
          <Label htmlFor="nome">Nome *</Label>
          <Input
            id="nome"
            value={dados.nome}
            onBlur={() => setTocado((t) => ({ ...t, nome: true }))}
            onChange={(e) => setDados((d) => ({ ...d, nome: e.target.value }))}
            placeholder="Ex.: Torno CNC Mazak QT-200"
          />
          {mostrar("nome") ? (
            <p className="text-sm text-destructive">{mostrar("nome")}</p>
          ) : null}
        </div>

        <div className="space-y-2">
          <Label htmlFor="patrimonio">Patrimônio *</Label>
          <Input
            id="patrimonio"
            value={dados.patrimonio}
            onBlur={() => setTocado((t) => ({ ...t, patrimonio: true }))}
            onChange={(e) => setDados((d) => ({ ...d, patrimonio: e.target.value }))}
            placeholder="PAT-000000"
          />
          {mostrar("patrimonio") ? (
            <p className="text-sm text-destructive">{mostrar("patrimonio")}</p>
          ) : null}
        </div>

        <div className="space-y-2">
          <Label htmlFor="data_aquisicao">Data de aquisição *</Label>
          <Input
            id="data_aquisicao"
            type="date"
            value={dados.data_aquisicao}
            onBlur={() => setTocado((t) => ({ ...t, data_aquisicao: true }))}
            onChange={(e) => setDados((d) => ({ ...d, data_aquisicao: e.target.value }))}
          />
          {mostrar("data_aquisicao") ? (
            <p className="text-sm text-destructive">{mostrar("data_aquisicao")}</p>
          ) : null}
        </div>

        <div className="space-y-2">
          <Label htmlFor="categoria">Categoria *</Label>
          <Select
            value={dados.id_categoria ? String(dados.id_categoria) : ""}
            onValueChange={(v) => {
              setTocado((t) => ({ ...t, id_categoria: true }));
              setDados((d) => ({ ...d, id_categoria: Number(v) }));
            }}
          >
            <SelectTrigger id="categoria">
              <SelectValue placeholder="Selecione a categoria" />
            </SelectTrigger>
            <SelectContent>
              {CATEGORIAS.map((c) => (
                <SelectItem key={c.id} value={String(c.id)}>
                  {c.nome}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          {mostrar("id_categoria") ? (
            <p className="text-sm text-destructive">{mostrar("id_categoria")}</p>
          ) : null}
        </div>

        <div className="space-y-2">
          <Label htmlFor="status">Status *</Label>
          <Select
            value={dados.status}
            onValueChange={(v) => setDados((d) => ({ ...d, status: v }))}
          >
            <SelectTrigger id="status">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {STATUS_OPCOES.map((s) => (
                <SelectItem key={s} value={s}>
                  {s}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-2 sm:col-span-2">
          <Label htmlFor="responsavel">Responsável *</Label>
          <Select
            value={dados.id_responsavel ? String(dados.id_responsavel) : ""}
            onValueChange={(v) => setDados((d) => ({ ...d, id_responsavel: Number(v) }))}
          >
            <SelectTrigger id="responsavel">
              <SelectValue placeholder="Selecione o responsável" />
            </SelectTrigger>
            <SelectContent>
              {responsaveis.map((u) => (
                <SelectItem key={u.id} value={String(u.id)}>
                  {u.nome} · {u.perfil}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          {mostrar("id_responsavel") ? (
            <p className="text-sm text-destructive">{mostrar("id_responsavel")}</p>
          ) : null}
        </div>
      </div>

      <div className="flex flex-wrap gap-3">
        <Button type="submit">{rotuloEnvio}</Button>
        <Button type="button" variant="outline" onClick={onCancel}>
          Cancelar
        </Button>
      </div>
    </form>
  );
}
