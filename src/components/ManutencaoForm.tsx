import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useApp } from "@/lib/app-store";
import {
  STATUS_MANUTENCAO,
  TIPOS_MANUTENCAO,
  type Manutencao,
  type StatusManutencao,
  type TipoManutencao,
} from "@/lib/mock-data";

export type DadosManutencao = Omit<Manutencao, "id">;

type Erros = Partial<Record<keyof DadosManutencao, string>>;

export function ManutencaoForm({
  inicial,
  onSubmit,
  onCancel,
  rotuloEnvio,
}: {
  inicial?: DadosManutencao;
  onSubmit: (dados: DadosManutencao) => void;
  onCancel: () => void;
  rotuloEnvio: string;
}) {
  const { equipamentos, usuarios } = useApp();
  const tecnicos = usuarios.filter((u) => u.perfil === "Técnico");

  const [dados, setDados] = useState<DadosManutencao>(
    inicial ?? {
      equipamento_id: 0,
      descricao: "",
      tipo: "Preventiva",
      status: "Pendente",
      data_abertura: new Date().toISOString().slice(0, 10),
      data_conclusao: "",
      custo: 0,
      id_responsavel: tecnicos[0]?.id ?? 0,
    },
  );
  const [custoTexto, setCustoTexto] = useState(String(inicial?.custo ?? "0"));
  const [tocado, setTocado] = useState<Record<string, boolean>>({});
  const [enviado, setEnviado] = useState(false);

  const erros: Erros = {};
  if (!dados.equipamento_id) erros.equipamento_id = "Selecione um equipamento.";
  else if (!equipamentos.some((e) => e.id_equipamento === dados.equipamento_id))
    erros.equipamento_id = "O equipamento selecionado não existe mais na lista.";
  if (!dados.descricao.trim()) erros.descricao = "Informe a descrição do serviço.";
  if (!dados.data_abertura) erros.data_abertura = "Informe a data de abertura.";
  const custoNumero = Number(custoTexto.replace(",", "."));
  if (custoTexto.trim() === "" || Number.isNaN(custoNumero))
    erros.custo = "Informe um custo válido.";
  else if (custoNumero < 0) erros.custo = "O custo deve ser maior ou igual a zero.";
  if (dados.status === "Concluída" && !dados.data_conclusao)
    erros.data_conclusao = "Informe a data de conclusão para manutenções concluídas.";
  else if (
    dados.data_conclusao &&
    dados.data_abertura &&
    dados.data_conclusao < dados.data_abertura
  )
    erros.data_conclusao = "A data de conclusão não pode ser anterior à data de abertura.";
  if (!dados.id_responsavel) erros.id_responsavel = "Selecione um técnico responsável.";

  const mostrar = (campo: keyof DadosManutencao) =>
    (enviado || tocado[campo]) && erros[campo] ? erros[campo] : "";

  const enviar = (evento: React.FormEvent) => {
    evento.preventDefault();
    setEnviado(true);
    if (Object.keys(erros).length > 0) return;
    onSubmit({ ...dados, descricao: dados.descricao.trim(), custo: custoNumero });
  };

  return (
    <form
      onSubmit={enviar}
      className="space-y-6 rounded-lg border border-border bg-card p-6 shadow-panel"
    >
      <div className="grid gap-5 sm:grid-cols-2">
        <div className="space-y-2 sm:col-span-2">
          <Label htmlFor="equipamento">Equipamento *</Label>
          <Select
            value={dados.equipamento_id ? String(dados.equipamento_id) : ""}
            onValueChange={(v) => {
              setTocado((t) => ({ ...t, equipamento_id: true }));
              setDados((d) => ({ ...d, equipamento_id: Number(v) }));
            }}
          >
            <SelectTrigger id="equipamento">
              <SelectValue placeholder="Selecione o equipamento" />
            </SelectTrigger>
            <SelectContent>
              {equipamentos.map((e) => (
                <SelectItem key={e.id_equipamento} value={String(e.id_equipamento)}>
                  {e.nome} · {e.patrimonio}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          {mostrar("equipamento_id") ? (
            <p className="text-sm text-destructive">{mostrar("equipamento_id")}</p>
          ) : null}
        </div>

        <div className="space-y-2 sm:col-span-2">
          <Label htmlFor="descricao">Descrição *</Label>
          <Textarea
            id="descricao"
            rows={3}
            value={dados.descricao}
            onBlur={() => setTocado((t) => ({ ...t, descricao: true }))}
            onChange={(e) => setDados((d) => ({ ...d, descricao: e.target.value }))}
            placeholder="Descreva o serviço a ser executado"
          />
          {mostrar("descricao") ? (
            <p className="text-sm text-destructive">{mostrar("descricao")}</p>
          ) : null}
        </div>

        <div className="space-y-2">
          <Label htmlFor="tipo">Tipo *</Label>
          <Select
            value={dados.tipo}
            onValueChange={(v) => setDados((d) => ({ ...d, tipo: v as TipoManutencao }))}
          >
            <SelectTrigger id="tipo">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {TIPOS_MANUTENCAO.map((t) => (
                <SelectItem key={t} value={t}>
                  {t}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-2">
          <Label htmlFor="status-manutencao">Status *</Label>
          <Select
            value={dados.status}
            onValueChange={(v) => {
              setTocado((t) => ({ ...t, data_conclusao: true }));
              setDados((d) => ({ ...d, status: v as StatusManutencao }));
            }}
          >
            <SelectTrigger id="status-manutencao">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {STATUS_MANUTENCAO.map((s) => (
                <SelectItem key={s} value={s}>
                  {s}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-2">
          <Label htmlFor="data_abertura">Data de abertura *</Label>
          <Input
            id="data_abertura"
            type="date"
            value={dados.data_abertura}
            onBlur={() => setTocado((t) => ({ ...t, data_abertura: true }))}
            onChange={(e) => setDados((d) => ({ ...d, data_abertura: e.target.value }))}
          />
          {mostrar("data_abertura") ? (
            <p className="text-sm text-destructive">{mostrar("data_abertura")}</p>
          ) : null}
        </div>

        <div className="space-y-2">
          <Label htmlFor="data_conclusao">
            Data de conclusão {dados.status === "Concluída" ? "*" : "(opcional)"}
          </Label>
          <Input
            id="data_conclusao"
            type="date"
            value={dados.data_conclusao}
            onBlur={() => setTocado((t) => ({ ...t, data_conclusao: true }))}
            onChange={(e) => setDados((d) => ({ ...d, data_conclusao: e.target.value }))}
          />
          {mostrar("data_conclusao") ? (
            <p className="text-sm text-destructive">{mostrar("data_conclusao")}</p>
          ) : null}
        </div>

        <div className="space-y-2">
          <Label htmlFor="custo">Custo (R$) *</Label>
          <Input
            id="custo"
            type="number"
            min="0"
            step="0.01"
            value={custoTexto}
            onBlur={() => setTocado((t) => ({ ...t, custo: true }))}
            onChange={(e) => setCustoTexto(e.target.value)}
          />
          {mostrar("custo") ? (
            <p className="text-sm text-destructive">{mostrar("custo")}</p>
          ) : null}
        </div>

        <div className="space-y-2">
          <Label htmlFor="responsavel-manutencao">Responsável (Técnico) *</Label>
          <Select
            value={dados.id_responsavel ? String(dados.id_responsavel) : ""}
            onValueChange={(v) => setDados((d) => ({ ...d, id_responsavel: Number(v) }))}
          >
            <SelectTrigger id="responsavel-manutencao">
              <SelectValue placeholder="Selecione o técnico" />
            </SelectTrigger>
            <SelectContent>
              {tecnicos.map((u) => (
                <SelectItem key={u.id} value={String(u.id)}>
                  {u.nome}
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
