import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { Wrench } from "lucide-react";
import { toast } from "sonner";
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
import { PERFIS, type Perfil } from "@/lib/mock-data";

export const Route = createFileRoute("/cadastro-usuario")({
  head: () => ({
    meta: [
      { title: "Criar conta — EquipControl" },
      {
        name: "description",
        content:
          "Cadastre um novo usuário do EquipControl com e-mail válido, senha segura e perfil de acesso.",
      },
      { property: "og:title", content: "Criar conta — EquipControl" },
      {
        property: "og:description",
        content: "Registro de usuários do sistema de gestão de equipamentos.",
      },
    ],
  }),
  component: TelaCadastroUsuario,
});

function TelaCadastroUsuario() {
  const navigate = useNavigate();
  const { usuarios, adicionarUsuario, definirUsuarioAtual } = useApp();

  const [nome, setNome] = useState("");
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [confirmacao, setConfirmacao] = useState("");
  const [perfil, setPerfil] = useState<Perfil>("Operador");
  const [tocado, setTocado] = useState<Record<string, boolean>>({});
  const [enviado, setEnviado] = useState(false);

  const erros: Record<string, string> = {};
  if (!nome.trim()) erros['nome'] = "Informe o nome completo.";
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(email.trim()))
    erros['email'] = "Informe um e-mail válido (ex.: usuario@dominio.com).";
  else if (usuarios.some((u) => u.email.toLowerCase() === email.trim().toLowerCase()))
    erros['email'] = "Este e-mail já está cadastrado.";
  if (senha.length < 8) erros['senha'] = "A senha deve ter no mínimo 8 caracteres.";
  if (confirmacao !== senha) erros['confirmacao'] = "As senhas não coincidem.";

  const mostrar = (campo: string) =>
    (enviado || tocado[campo]) && erros[campo] ? erros[campo] : "";

  const cadastrar = (evento: React.FormEvent) => {
    evento.preventDefault();
    setEnviado(true);
    if (Object.keys(erros).length > 0) return;
    const novo = adicionarUsuario({ nome: nome.trim(), email: email.trim(), perfil });
    definirUsuarioAtual(novo.id);
    toast.success("Conta criada com sucesso. Sessão iniciada com o novo perfil.");
    navigate({ to: "/inicio" });
  };

  return (
    <div className="flex min-h-screen flex-col justify-center bg-secondary px-4 py-12">
      <div className="mx-auto w-full max-w-md">
        <div className="mb-8 flex flex-col items-center text-center">
          <span className="flex h-12 w-12 items-center justify-center rounded-md bg-primary text-primary-foreground">
            <Wrench className="h-7 w-7" aria-hidden="true" />
          </span>
          <h1 className="mt-4 font-display text-4xl uppercase tracking-wide text-foreground">
            Criar conta
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Cadastro de usuário do EquipControl
          </p>
        </div>

        <form
          onSubmit={cadastrar}
          className="space-y-5 rounded-lg border border-border bg-card p-6 shadow-panel sm:p-8"
        >
          <div className="space-y-2">
            <Label htmlFor="nome">Nome completo *</Label>
            <Input
              id="nome"
              value={nome}
              onBlur={() => setTocado((t) => ({ ...t, nome: true }))}
              onChange={(e) => setNome(e.target.value)}
              placeholder="Ex.: Ana Ribeiro"
            />
            {mostrar("nome") ? (
              <p className="text-sm text-destructive">{mostrar("nome")}</p>
            ) : null}
          </div>

          <div className="space-y-2">
            <Label htmlFor="email">E-mail *</Label>
            <Input
              id="email"
              value={email}
              onBlur={() => setTocado((t) => ({ ...t, email: true }))}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="usuario@dominio.com"
            />
            {mostrar("email") ? (
              <p className="text-sm text-destructive">{mostrar("email")}</p>
            ) : null}
          </div>

          <div className="space-y-2">
            <Label htmlFor="senha">Senha *</Label>
            <Input
              id="senha"
              type="password"
              value={senha}
              onBlur={() => setTocado((t) => ({ ...t, senha: true }))}
              onChange={(e) => setSenha(e.target.value)}
              placeholder="Mínimo de 8 caracteres"
            />
            {mostrar("senha") ? (
              <p className="text-sm text-destructive">{mostrar("senha")}</p>
            ) : null}
          </div>

          <div className="space-y-2">
            <Label htmlFor="confirmacao">Confirmar senha *</Label>
            <Input
              id="confirmacao"
              type="password"
              value={confirmacao}
              onBlur={() => setTocado((t) => ({ ...t, confirmacao: true }))}
              onChange={(e) => setConfirmacao(e.target.value)}
            />
            {mostrar("confirmacao") ? (
              <p className="text-sm text-destructive">{mostrar("confirmacao")}</p>
            ) : null}
          </div>

          <div className="space-y-2">
            <Label htmlFor="perfil">Perfil de acesso *</Label>
            <Select value={perfil} onValueChange={(v) => setPerfil(v as Perfil)}>
              <SelectTrigger id="perfil">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {PERFIS.map((p) => (
                  <SelectItem key={p} value={p}>
                    {p}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <Button type="submit" className="w-full">
            Cadastrar
          </Button>

          <p className="text-center text-sm text-muted-foreground">
            Já tem conta?{" "}
            <Link to="/" className="font-medium text-primary hover:underline">
              Entrar
            </Link>
          </p>
        </form>
      </div>
    </div>
  );
}
