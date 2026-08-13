import { Link, useNavigate, useRouterState } from "@tanstack/react-router";
import type { ReactNode } from "react";
import { Boxes, LogOut, Moon, Sun, Wrench, LayoutDashboard } from "lucide-react";
import { useApp } from "@/lib/app-store";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";

const LINKS = [
  { to: "/inicio", rotulo: "Início", icone: LayoutDashboard },
  { to: "/equipamentos", rotulo: "Equipamentos", icone: Boxes },
  { to: "/manutencoes", rotulo: "Manutenções", icone: Wrench },
] as const;

export function AppShell({
  titulo,
  descricao,
  acao,
  children,
}: {
  titulo: string;
  descricao?: string;
  acao?: ReactNode;
  children: ReactNode;
}) {
  const navigate = useNavigate();
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const { usuarios, usuarioAtual, definirUsuarioAtual, tema, alternarTema } = useApp();

  return (
    <div className="min-h-screen bg-background">
      <header className="sticky top-0 z-30 border-b border-border bg-primary text-primary-foreground">
        <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 px-4 py-3 sm:px-6">
          <Link to="/inicio" className="flex items-center gap-2">
            <span className="flex h-9 w-9 items-center justify-center rounded-md bg-accent text-accent-foreground">
              <Wrench className="h-5 w-5" aria-hidden="true" />
            </span>
            <span className="font-display text-xl uppercase tracking-wide">EquipControl</span>
          </Link>

          <nav className="order-3 flex w-full items-center gap-1 text-sm sm:order-none sm:w-auto">
            {LINKS.map(({ to, rotulo, icone: Icone }) => (
              <Link
                key={to}
                to={to}
                className={`flex items-center gap-1.5 rounded-md px-3 py-1.5 transition-colors hover:bg-primary-foreground/10 ${
                  pathname.startsWith(to) ? "bg-primary-foreground/20 font-medium" : ""
                }`}
              >
                <Icone className="h-4 w-4" aria-hidden="true" />
                {rotulo}
              </Link>
            ))}
          </nav>

          <div className="flex items-center gap-2">
            <Select
              value={String(usuarioAtual.id)}
              onValueChange={(v) => definirUsuarioAtual(Number(v))}
            >
              <SelectTrigger
                aria-label="Perfil da sessão"
                className="h-9 w-[220px] border-primary-foreground/25 bg-primary-foreground/10 text-primary-foreground"
              >
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

            <Button
              type="button"
              variant="ghost"
              size="icon"
              aria-label={tema === "dark" ? "Ativar tema claro" : "Ativar tema escuro"}
              onClick={alternarTema}
              className="text-primary-foreground hover:bg-primary-foreground/10 hover:text-primary-foreground"
            >
              {tema === "dark" ? (
                <Sun className="h-4 w-4" aria-hidden="true" />
              ) : (
                <Moon className="h-4 w-4" aria-hidden="true" />
              )}
            </Button>

            <Button
              type="button"
              variant="ghost"
              size="icon"
              aria-label="Sair"
              onClick={() => navigate({ to: "/" })}
              className="text-primary-foreground hover:bg-primary-foreground/10 hover:text-primary-foreground"
            >
              <LogOut className="h-4 w-4" aria-hidden="true" />
            </Button>
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-4 py-8 sm:px-6">
        <div className="mb-6 flex flex-wrap items-end justify-between gap-4">
          <div>
            <h1 className="font-display text-3xl uppercase tracking-wide text-foreground">
              {titulo}
            </h1>
            {descricao ? (
              <p className="mt-1 text-sm text-muted-foreground">{descricao}</p>
            ) : null}
          </div>
          {acao}
        </div>
        {children}
      </main>
    </div>
  );
}

export function StatusBadge({ status }: { status: string }) {
  const estilo =
    status === "Ativo" || status === "Concluída"
      ? "bg-success text-success-foreground"
      : status === "Em Manutenção" || status === "Em Andamento" || status === "Pendente"
        ? "bg-warning text-warning-foreground"
        : "bg-neutral-state text-neutral-state-foreground";

  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${estilo}`}
    >
      {status}
    </span>
  );
}
