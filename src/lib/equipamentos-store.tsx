import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { EQUIPAMENTOS_INICIAIS, type Equipamento } from "./mock-data";

const CHAVE = "gestao-equipamentos:dados";

type NovoEquipamento = Omit<Equipamento, "id_equipamento">;

type Estado = {
  equipamentos: Equipamento[];
  adicionarEquipamento: (dados: NovoEquipamento) => Equipamento;
};

const EquipamentosContext = createContext<Estado | null>(null);

export function EquipamentosProvider({ children }: { children: ReactNode }) {
  const [equipamentos, setEquipamentos] = useState<Equipamento[]>(EQUIPAMENTOS_INICIAIS);

  useEffect(() => {
    try {
      const salvo = window.localStorage.getItem(CHAVE);
      if (salvo) setEquipamentos(JSON.parse(salvo) as Equipamento[]);
    } catch {
      /* ignora dados inválidos */
    }
  }, []);

  useEffect(() => {
    try {
      window.localStorage.setItem(CHAVE, JSON.stringify(equipamentos));
    } catch {
      /* armazenamento indisponível */
    }
  }, [equipamentos]);

  const adicionarEquipamento = (dados: NovoEquipamento) => {
    const proximoId =
      equipamentos.reduce((maior, e) => Math.max(maior, e.id_equipamento), 0) + 1;
    const novo: Equipamento = { id_equipamento: proximoId, ...dados };
    setEquipamentos((atual) => [...atual, novo]);
    return novo;
  };

  return (
    <EquipamentosContext.Provider value={{ equipamentos, adicionarEquipamento }}>
      {children}
    </EquipamentosContext.Provider>
  );
}

export function useEquipamentos() {
  const ctx = useContext(EquipamentosContext);
  if (!ctx) throw new Error("useEquipamentos precisa estar dentro de EquipamentosProvider");
  return ctx;
}
