export type Perfil = "Administrador" | "Técnico" | "Gestor" | "Operador";

export const PERFIS: Perfil[] = ["Administrador", "Técnico", "Gestor", "Operador"];

export type Equipamento = {
  id_equipamento: number;
  nome: string;
  patrimonio: string;
  data_aquisicao: string;
  id_categoria: number;
  status: string;
  id_responsavel: number;
};

export type Manutencao = {
  id: number;
  equipamento_id: number;
  descricao: string;
  tipo: TipoManutencao;
  status: StatusManutencao;
  data_abertura: string;
  data_conclusao: string;
  custo: number;
  id_responsavel: number;
};

export type Categoria = { id: number; nome: string };
export type Usuario = { id: number; nome: string; email: string; perfil: Perfil };

export const CATEGORIAS: Categoria[] = [
  { id: 1, nome: "Máquinas Pesadas" },
  { id: 2, nome: "Ferramentas Elétricas" },
  { id: 3, nome: "Equipamentos de TI" },
  { id: 4, nome: "Veículos Industriais" },
  { id: 5, nome: "Instrumentos de Medição" },
];

export const USUARIOS_INICIAIS: Usuario[] = [
  { id: 1, nome: "Carlos Almeida", email: "carlos.almeida@empresa.com", perfil: "Administrador" },
  { id: 2, nome: "Fernanda Souza", email: "fernanda.souza@empresa.com", perfil: "Gestor" },
  { id: 3, nome: "Ricardo Menezes", email: "ricardo.menezes@empresa.com", perfil: "Técnico" },
  { id: 4, nome: "Juliana Prado", email: "juliana.prado@empresa.com", perfil: "Técnico" },
  { id: 5, nome: "Marcos Vieira", email: "marcos.vieira@empresa.com", perfil: "Operador" },
];

export const STATUS_OPCOES = ["Ativo", "Em Manutenção", "Inativo"] as const;

export const TIPOS_MANUTENCAO = ["Preventiva", "Corretiva"] as const;
export type TipoManutencao = (typeof TIPOS_MANUTENCAO)[number];

export const STATUS_MANUTENCAO = ["Pendente", "Em Andamento", "Concluída"] as const;
export type StatusManutencao = (typeof STATUS_MANUTENCAO)[number];

export const EQUIPAMENTOS_INICIAIS: Equipamento[] = [
  {
    id_equipamento: 1,
    nome: "Torno CNC Mazak QT-200",
    patrimonio: "PAT-000121",
    data_aquisicao: "2021-03-15",
    id_categoria: 1,
    status: "Ativo",
    id_responsavel: 1,
  },
  {
    id_equipamento: 2,
    nome: "Compressor de Ar Schulz 50HP",
    patrimonio: "PAT-000455",
    data_aquisicao: "2019-11-02",
    id_categoria: 1,
    status: "Em Manutenção",
    id_responsavel: 3,
  },
  {
    id_equipamento: 3,
    nome: "Furadeira de Bancada Bosch",
    patrimonio: "PAT-000788",
    data_aquisicao: "2022-06-27",
    id_categoria: 2,
    status: "Ativo",
    id_responsavel: 2,
  },
  {
    id_equipamento: 4,
    nome: "Servidor Dell PowerEdge R740",
    patrimonio: "PAT-001002",
    data_aquisicao: "2023-01-10",
    id_categoria: 3,
    status: "Ativo",
    id_responsavel: 4,
  },
  {
    id_equipamento: 5,
    nome: "Empilhadeira Hyster 2.5T",
    patrimonio: "PAT-001190",
    data_aquisicao: "2018-08-05",
    id_categoria: 4,
    status: "Inativo",
    id_responsavel: 1,
  },
  {
    id_equipamento: 6,
    nome: "Paquímetro Digital Mitutoyo",
    patrimonio: "PAT-001233",
    data_aquisicao: "2024-02-19",
    id_categoria: 5,
    status: "Ativo",
    id_responsavel: 2,
  },
  {
    id_equipamento: 7,
    nome: "Prensa Hidráulica 100T",
    patrimonio: "PAT-001470",
    data_aquisicao: "2020-09-30",
    id_categoria: 1,
    status: "Em Manutenção",
    id_responsavel: 3,
  },
];

export const MANUTENCOES_INICIAIS: Manutencao[] = [
  {
    id: 1,
    equipamento_id: 2,
    descricao: "Troca de filtros e revisão do sistema de pressão.",
    tipo: "Preventiva",
    status: "Em Andamento",
    data_abertura: "2026-07-28",
    data_conclusao: "",
    custo: 1250.5,
    id_responsavel: 3,
  },
  {
    id: 2,
    equipamento_id: 7,
    descricao: "Vazamento de óleo na unidade hidráulica.",
    tipo: "Corretiva",
    status: "Pendente",
    data_abertura: "2026-08-03",
    data_conclusao: "",
    custo: 0,
    id_responsavel: 4,
  },
  {
    id: 3,
    equipamento_id: 1,
    descricao: "Calibração do eixo Z e lubrificação das guias.",
    tipo: "Preventiva",
    status: "Concluída",
    data_abertura: "2026-06-10",
    data_conclusao: "2026-06-14",
    custo: 890,
    id_responsavel: 3,
  },
  {
    id: 4,
    equipamento_id: 4,
    descricao: "Substituição de fonte redundante com falha.",
    tipo: "Corretiva",
    status: "Concluída",
    data_abertura: "2026-05-02",
    data_conclusao: "2026-05-03",
    custo: 2400,
    id_responsavel: 4,
  },
];

export const nomeCategoria = (id: number) =>
  CATEGORIAS.find((c) => c.id === id)?.nome ?? "—";

export const formatarData = (iso: string) => {
  if (!iso) return "—";
  const [ano, mes, dia] = iso.split("-");
  return dia && mes && ano ? `${dia}/${mes}/${ano}` : iso;
};

export const formatarMoeda = (valor: number) =>
  valor.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

/** Permissões por perfil */
export const podeGerenciarEquipamentos = (perfil: Perfil) =>
  perfil === "Administrador" || perfil === "Gestor";

export const podeGerenciarManutencoes = (perfil: Perfil) =>
  perfil === "Administrador" || perfil === "Técnico";
