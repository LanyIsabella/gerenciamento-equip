import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { Moon, Sun, Wrench } from "lucide-react";
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

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Entrar — EquipControl | Gestão de Equipamentos" },
      {
        name: "description",
        content:
          "Acesse o EquipControl para gerenciar equipamentos, manutenções, patrimônio e responsáveis por perfil de acesso.",
      },
      { property: "og:title", content: "Entrar — EquipControl" },
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
  const { usuarios, usuarioAtual, definirUsuarioAtual, tema, alternarTema } = useApp();
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [erros, setErros] = useState<{ email?: string; senha?: string }>({});

  const entrar = (evento: React.FormEvent) => {
    evento.preventDefault();
    const novos: { email?: string; senha?: string } = {};
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(email.trim()))
      novos.email = "Informe um e-mail válido (ex.: usuario@dominio.com).";
    if (senha.length < 8) novos.senha = "A senha deve ter no mínimo 8 caracteres.";
    setErros(novos);
    if (Object.keys(novos).length > 0) return;
    navigate({ to: "/inicio" });
  };

  return (
    <div className="relative flex min-h-screen flex-col justify-center bg-secondary px-4 py-12">
      <Button
        type="button"
        variant="ghost"
        size="icon"
        aria-label={tema === "dark" ? "Ativar tema claro" : "Ativar tema escuro"}
        onClick={alternarTema}
        className="absolute right-4 top-4"
      >
        {tema === "dark" ? (
          <Sun className="h-4 w-4" aria-hidden="true" />
        ) : (
          <Moon className="h-4 w-4" aria-hidden="true" />
        )}
      </Button>

      <div className="mx-auto w-full max-w-md">
        <div className="mb-8 flex flex-col items-center text-center">
          <span className="flex h-12 w-12 items-center justify-center rounded-md bg-primary text-primary-foreground">
            <Wrench className="h-7 w-7" aria-hidden="true" />
          </span>
          <h1 className="mt-4 font-display text-4xl uppercase tracking-wide text-foreground">
            EquipControl
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
            <Label htmlFor="email">E-mail</Label>
            <Input
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="seu.nome@empresa.com"
              autoComplete="username"
            />
            {erros.email ? <p className="text-sm text-destructive">{erros.email}</p> : null}
          </div>

          <div className="space-y-2">
            <Label htmlFor="senha">Senha</Label>
            <Input
              id="senha"
              type="password"
              value={senha}
              onChange={(e) => setSenha(e.target.value)}
              placeholder="Mínimo de 8 caracteres"
              autoComplete="current-password"
            />
            {erros.senha ? <p className="text-sm text-destructive">{erros.senha}</p> : null}
          </div>

          <div className="space-y-2">
            <Label htmlFor="perfil-sessao">Perfil de acesso (simulação)</Label>
            <Select
              value={String(usuarioAtual.id)}
              onValueChange={(v) => definirUsuarioAtual(Number(v))}
            >
              <SelectTrigger id="perfil-sessao">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {usuarios.map((u) => (
                  <SelectItem key={u.id} value={String(u.id)}>
                    {u.nome} · {u.perfil}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <p className="text-xs text-muted-foreground">
              O perfil selecionado define as permissões durante a navegação.
            </p>
          </div>

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
