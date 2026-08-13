import { Link } from "@tanstack/react-router";
import { ShieldAlert } from "lucide-react";
import { AppShell } from "@/components/AppShell";
import { Button } from "@/components/ui/button";

export function SemPermissao({ area }: { area: string }) {
  return (
    <AppShell titulo="Acesso restrito">
      <div className="flex flex-col items-start gap-4 rounded-lg border border-border bg-card p-8 shadow-panel">
        <span className="flex h-12 w-12 items-center justify-center rounded-md bg-warning text-warning-foreground">
          <ShieldAlert className="h-6 w-6" aria-hidden="true" />
        </span>
        <div>
          <h2 className="font-display text-2xl uppercase tracking-wide text-foreground">
            Permissão insuficiente
          </h2>
          <p className="mt-1 text-sm text-muted-foreground">
            Seu perfil atual não permite {area}. Altere o perfil da sessão no topo da tela para
            testar outros níveis de acesso.
          </p>
        </div>
        <Button asChild variant="outline">
          <Link to="/inicio">Voltar ao painel</Link>
        </Button>
      </div>
    </AppShell>
  );
}
