import { Link, useNavigate, useRouterState } from "@tanstack/react-router";
import type { ReactNode } from "react";
import { Cog, LogOut } from "lucide-react";

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

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b border-border bg-primary text-primary-foreground">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-3 sm:px-6">
          <Link to="/equipamentos" className="flex items-center gap-2">
            <span className="flex h-8 w-8 items-center justify-center rounded bg-accent text-accent-foreground">
              <Cog className="h-5 w-5" aria-hidden="true" />
            </span>
            <span className="font-display text-xl uppercase tracking-wide">MaqControl</span>
          </Link>
          <nav className="flex items-center gap-1 text-sm">
            <Link
              to="/equipamentos"
              className={`rounded px-3 py-1.5 transition-colors hover:bg-primary-foreground/10 ${
                pathname.startsWith("/equipamentos") ? "bg-primary-foreground/15" : ""
              }`}
            >
              Equipamentos
            </Link>
            <button
              type="button"
              onClick={() => navigate({ to: "/" })}
              className="flex items-center gap-1.5 rounded px-3 py-1.5 transition-colors hover:bg-primary-foreground/10"
            >
              <LogOut className="h-4 w-4" aria-hidden="true" />
              Sair
            </button>
          </nav>
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
    status === "Ativo"
      ? "bg-success text-success-foreground"
      : status === "Em Manutenção"
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
