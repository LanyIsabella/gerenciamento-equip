export type Equipamento = {
  id_equipamento: number;
  nome: string;
  patrimonio: string;
  data_aquisicao: string;
  id_categoria: number;
  status: string;
  id_responsavel: number;
};

export type Categoria = { id: number; nome: string };
export type Usuario = { id: number; nome: string };

export const CATEGORIAS: Categoria[] = [
  { id: 1, nome: "Máquinas Pesadas" },
  { id: 2, nome: "Ferramentas Elétricas" },
  { id: 3, nome: "Equipamentos de TI" },
  { id: 4, nome: "Veículos Industriais" },
  { id: 5, nome: "Instrumentos de Medição" },
];

export const USUARIOS: Usuario[] = [
  { id: 1, nome: "Carlos Almeida" },
  { id: 2, nome: "Fernanda Souza" },
  { id: 3, nome: "Ricardo Menezes" },
  { id: 4, nome: "Juliana Prado" },
];

export const STATUS_OPCOES = ["Ativo", "Em Manutenção", "Inativo"] as const;

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

export const nomeCategoria = (id: number) =>
  CATEGORIAS.find((c) => c.id === id)?.nome ?? "—";

export const nomeUsuario = (id: number) =>
  USUARIOS.find((u) => u.id === id)?.nome ?? "—";

export const formatarData = (iso: string) => {
  const [ano, mes, dia] = iso.split("-");
  return dia && mes && ano ? `${dia}/${mes}/${ano}` : iso;
};
