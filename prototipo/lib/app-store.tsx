import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import {
  EQUIPAMENTOS_INICIAIS,
  MANUTENCOES_INICIAIS,
  USUARIOS_INICIAIS,
  type Equipamento,
  type Manutencao,
  type Perfil,
  type Usuario,
} from "./mock-data";

const CHAVE = "equipcontrol:dados";
const CHAVE_TEMA = "equipcontrol:tema";

type NovoEquipamento = Omit<Equipamento, "id_equipamento">;
type NovaManutencao = Omit<Manutencao, "id">;
type NovoUsuario = Omit<Usuario, "id">;

type Tema = "light" | "dark";

type Estado = {
  equipamentos: Equipamento[];
  manutencoes: Manutencao[];
  usuarios: Usuario[];
  usuarioAtual: Usuario;
  perfil: Perfil;
  tema: Tema;
  alternarTema: () => void;
  definirUsuarioAtual: (id: number) => void;
  adicionarEquipamento: (dados: NovoEquipamento) => Equipamento;
  atualizarEquipamento: (id: number, dados: NovoEquipamento) => void;
  removerEquipamento: (id: number) => void;
  adicionarManutencao: (dados: NovaManutencao) => Manutencao;
  atualizarManutencao: (id: number, dados: NovaManutencao) => void;
  removerManutencao: (id: number) => void;
  adicionarUsuario: (dados: NovoUsuario) => Usuario;
};

const AppContext = createContext<Estado | null>(null);

type Persistido = {
  equipamentos: Equipamento[];
  manutencoes: Manutencao[];
  usuarios: Usuario[];
  usuarioAtualId: number;
};

export function AppProvider({ children }: { children: ReactNode }) {
  const [equipamentos, setEquipamentos] = useState<Equipamento[]>(EQUIPAMENTOS_INICIAIS);
  const [manutencoes, setManutencoes] = useState<Manutencao[]>(MANUTENCOES_INICIAIS);
  const [usuarios, setUsuarios] = useState<Usuario[]>(USUARIOS_INICIAIS);
  const [usuarioAtualId, setUsuarioAtualId] = useState<number>(1);
  const [tema, setTema] = useState<Tema>("light");
  const [carregado, setCarregado] = useState(false);

  useEffect(() => {
    try {
      const salvo = window.localStorage.getItem(CHAVE);
      if (salvo) {
        const dados = JSON.parse(salvo) as Partial<Persistido>;
        if (dados.equipamentos) setEquipamentos(dados.equipamentos);
        if (dados.manutencoes) setManutencoes(dados.manutencoes);
        if (dados.usuarios) setUsuarios(dados.usuarios);
        if (dados.usuarioAtualId) setUsuarioAtualId(dados.usuarioAtualId);
      }
      const temaSalvo = window.localStorage.getItem(CHAVE_TEMA) as Tema | null;
      if (temaSalvo === "dark" || temaSalvo === "light") setTema(temaSalvo);
    } catch {
      /* ignora dados inválidos */
    }
    setCarregado(true);
  }, []);

  useEffect(() => {
    if (!carregado) return;
    try {
      window.localStorage.setItem(
        CHAVE,
        JSON.stringify({ equipamentos, manutencoes, usuarios, usuarioAtualId }),
      );
    } catch {
      /* armazenamento indisponível */
    }
  }, [carregado, equipamentos, manutencoes, usuarios, usuarioAtualId]);

  useEffect(() => {
    document.documentElement.classList.toggle("dark", tema === "dark");
    try {
      window.localStorage.setItem(CHAVE_TEMA, tema);
    } catch {
      /* ignora */
    }
  }, [tema]);

  const usuarioAtual: Usuario =
    usuarios.find((u) => u.id === usuarioAtualId) ?? usuarios[0] ?? USUARIOS_INICIAIS[0]!;

  const valor: Estado = {
    equipamentos,
    manutencoes,
    usuarios,
    usuarioAtual,
    perfil: usuarioAtual.perfil,
    tema,
    alternarTema: () => setTema((t) => (t === "dark" ? "light" : "dark")),
    definirUsuarioAtual: (id) => setUsuarioAtualId(id),
    adicionarEquipamento: (dados) => {
      const proximoId =
        equipamentos.reduce((maior, e) => Math.max(maior, e.id_equipamento), 0) + 1;
      const novo: Equipamento = { id_equipamento: proximoId, ...dados };
      setEquipamentos((atual) => [...atual, novo]);
      return novo;
    },
    atualizarEquipamento: (id, dados) =>
      setEquipamentos((atual) =>
        atual.map((e) => (e.id_equipamento === id ? { id_equipamento: id, ...dados } : e)),
      ),
    removerEquipamento: (id) => {
      setEquipamentos((atual) => atual.filter((e) => e.id_equipamento !== id));
      setManutencoes((atual) => atual.filter((m) => m.equipamento_id !== id));
    },
    adicionarManutencao: (dados) => {
      const proximoId = manutencoes.reduce((maior, m) => Math.max(maior, m.id), 0) + 1;
      const nova: Manutencao = { id: proximoId, ...dados };
      setManutencoes((atual) => [...atual, nova]);
      return nova;
    },
    atualizarManutencao: (id, dados) =>
      setManutencoes((atual) => atual.map((m) => (m.id === id ? { id, ...dados } : m))),
    removerManutencao: (id) => setManutencoes((atual) => atual.filter((m) => m.id !== id)),
    adicionarUsuario: (dados) => {
      const proximoId = usuarios.reduce((maior, u) => Math.max(maior, u.id), 0) + 1;
      const novo: Usuario = { id: proximoId, ...dados };
      setUsuarios((atual) => [...atual, novo]);
      return novo;
    },
  };

  return <AppContext.Provider value={valor}>{children}</AppContext.Provider>;
}

export function useApp() {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error("useApp precisa estar dentro de AppProvider");
  return ctx;
}
