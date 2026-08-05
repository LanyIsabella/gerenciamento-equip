import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { Cog } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Entrar — MaqControl | Gestão de Equipamentos" },
      {
        name: "description",
        content:
          "Acesse o MaqControl para gerenciar equipamentos, patrimônio, status e responsáveis da sua operação.",
      },
      { property: "og:title", content: "Entrar — MaqControl" },
      {
        property: "og:description",
        content: "Acesso ao sistema de gestão de equipamentos e manutenções.",
      },
    ],
  }),
  component: TelaLogin,
});

function TelaLogin() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [erro, setErro] = useState("");

  const entrar = (evento: React.FormEvent) => {
    evento.preventDefault();
    if (!email.trim() || !senha.trim()) {
      setErro("Informe o e-mail e a senha para continuar.");
      return;
    }
    setErro("");
    navigate({ to: "/equipamentos" });
  };

  return (
    <div className="flex min-h-screen flex-col justify-center bg-secondary px-4 py-12">
      <div className="mx-auto w-full max-w-md">
        <div className="mb-8 flex flex-col items-center text-center">
          <span className="flex h-12 w-12 items-center justify-center rounded bg-primary text-primary-foreground">
            <Cog className="h-7 w-7" aria-hidden="true" />
          </span>
          <h1 className="mt-4 font-display text-4xl uppercase tracking-wide text-foreground">
            MaqControl
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Gestão de Equipamentos e Manutenções
          </p>
        </div>

        <form
          onSubmit={entrar}
          className="space-y-5 rounded-lg border border-border bg-card p-6 shadow-panel sm:p-8"
        >
          <div className="space-y-2">
            <Label htmlFor="email">E-mail ou usuário</Label>
            <Input
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="seu.nome@empresa.com.br"
              autoComplete="username"
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
              autoComplete="current-password"
            />
          </div>

          {erro ? <p className="text-sm text-destructive">{erro}</p> : null}

          <Button type="submit" className="w-full">
            Entrar
          </Button>

          <p className="text-center text-sm text-muted-foreground">
            Ainda não tem conta?{" "}
            <Link to="/cadastro-usuario" className="font-medium text-primary hover:underline">
              Cadastre-se
            </Link>
          </p>
        </form>
      </div>
    </div>
  );
}
