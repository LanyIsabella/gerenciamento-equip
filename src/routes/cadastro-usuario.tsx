import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { CheckCircle2, Cog } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export const Route = createFileRoute("/cadastro-usuario")({
  head: () => ({
    meta: [
      { title: "Cadastro de Usuário — MaqControl" },
      {
        name: "description",
        content:
          "Crie sua conta no MaqControl e comece a gerenciar equipamentos e manutenções da sua empresa.",
      },
      { property: "og:title", content: "Cadastro de Usuário — MaqControl" },
      {
        property: "og:description",
        content: "Registre um novo usuário no sistema de gestão de equipamentos.",
      },
    ],
  }),
  component: TelaCadastroUsuario,
});

function TelaCadastroUsuario() {
  const navigate = useNavigate();
  const [nome, setNome] = useState("");
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [erro, setErro] = useState("");
  const [sucesso, setSucesso] = useState(false);

  const cadastrar = (evento: React.FormEvent) => {
    evento.preventDefault();
    if (!nome.trim() || !email.trim() || !senha.trim()) {
      setErro("Preencha todos os campos para concluir o cadastro.");
      return;
    }
    setErro("");
    setSucesso(true);
    toast.success("Usuário cadastrado com sucesso!");
    setTimeout(() => navigate({ to: "/" }), 1600);
  };

  return (
    <div className="flex min-h-screen flex-col justify-center bg-secondary px-4 py-12">
      <div className="mx-auto w-full max-w-md">
        <div className="mb-8 flex flex-col items-center text-center">
          <span className="flex h-12 w-12 items-center justify-center rounded bg-primary text-primary-foreground">
            <Cog className="h-7 w-7" aria-hidden="true" />
          </span>
          <h1 className="mt-4 font-display text-3xl uppercase tracking-wide text-foreground">
            Cadastro de Usuário
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Preencha os dados para criar seu acesso
          </p>
        </div>

        <form
          onSubmit={cadastrar}
          className="space-y-5 rounded-lg border border-border bg-card p-6 shadow-panel sm:p-8"
        >
          <div className="space-y-2">
            <Label htmlFor="nome">Nome</Label>
            <Input
              id="nome"
              value={nome}
              onChange={(e) => setNome(e.target.value)}
              placeholder="Nome completo"
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="email">E-mail</Label>
            <Input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="seu.nome@empresa.com.br"
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="senha">Senha</Label>
            <Input
              id="senha"
              type="password"
              value={senha}
              onChange={(e) => setSenha(e.target.value)}
              placeholder="••••••••"
            />
          </div>

          {erro ? <p className="text-sm text-destructive">{erro}</p> : null}

          {sucesso ? (
            <p className="flex items-center gap-2 rounded-md bg-success px-3 py-2 text-sm font-medium text-success-foreground">
              <CheckCircle2 className="h-4 w-4" aria-hidden="true" />
              Cadastro realizado! Redirecionando para o login...
            </p>
          ) : null}

          <Button type="submit" className="w-full">
            Cadastrar
          </Button>

          <p className="text-center text-sm text-muted-foreground">
            Já possui conta?{" "}
            <Link to="/" className="font-medium text-primary hover:underline">
              Voltar para o login
            </Link>
          </p>
        </form>
      </div>
    </div>
  );
}
