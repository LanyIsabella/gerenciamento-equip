# EquipControl

Sistema para gerenciamento de equipamentos, usuários e manutenções.

O projeto possui:

- API em FastAPI;
- PostgreSQL como banco de dados;
- SQLAlchemy 2 para persistência;
- Alembic para migrações;
- protótipo de interface em React, TanStack Router e Vite.

## Pré-requisitos

Instale:

- Python 3.14 ou superior;
- Poetry;
- PostgreSQL;
- Bun, para executar o protótipo da interface.

## Configuração do banco

Crie um banco PostgreSQL para o projeto. Exemplo usando `psql`:

```sql
CREATE USER equipcontrol WITH PASSWORD 'sua_senha';
CREATE DATABASE gerenciamento_equip OWNER equipcontrol;
```

Na raiz do projeto, crie o arquivo `.env`:

```env
DATABASE_URL=postgresql+psycopg://equipcontrol:sua_senha@localhost:5432/gerenciamento_equip
```

O arquivo `.env` não deve ser commitado.

## Instalação do back-end

Na raiz do projeto, instale as dependências Python:

```bash
poetry install
```

O comando instala FastAPI, Uvicorn, SQLAlchemy, Psycopg, Pydantic Settings e Alembic.

## Migrações do banco

Com o `.env` configurado, aplique as migrações:

```bash
poetry run alembic -c backend/alembic.ini upgrade head
```

Para verificar se os models e o banco estão sincronizados:

```bash
poetry run alembic -c backend/alembic.ini check
```

Para gerar uma nova revisão depois de alterar os models:

```bash
poetry run alembic -c backend/alembic.ini revision --autogenerate -m "descreva a alteração"
```

Revise a migration gerada antes de aplicá-la.

## Executar a API

Ainda na raiz do projeto:

```bash
poetry run uvicorn app.main:app --app-dir backend --reload
```

A API ficará disponível em:

- http://localhost:8000
- documentação Swagger: http://localhost:8000/docs
- documentação ReDoc: http://localhost:8000/redoc

## Principais endpoints

### Usuários

Cadastrar usuário:

```http
POST /usuarios/
```

Consultar usuários ativos por cargo para preencher listas suspensas:

```http
GET /usuarios/?cargo=gerente
GET /usuarios/?cargo=tecnico
```

Equipamentos aceitam responsáveis com cargo `gerente`. Manutenções aceitam responsáveis com cargo `tecnico`.

### Equipamentos

```http
GET    /equipamentos/
POST   /equipamentos/
GET    /equipamentos/{id_equipamento}
PATCH  /equipamentos/{id_equipamento}
DELETE /equipamentos/{id_equipamento}
```

Filtros da listagem:

```http
GET /equipamentos/?busca=notebook&id_categoria=1&status=Ativo
```

- `busca`: procura por nome ou patrimônio;
- `id_categoria`: filtra pela categoria;
- `status`: filtra pelo status.

### Manutenções

```http
GET    /manutencoes/
POST   /manutencoes/
GET    /manutencoes/{id_manutencao}
PATCH  /manutencoes/{id_manutencao}
DELETE /manutencoes/{id_manutencao}
```

Filtros da listagem:

```http
GET /manutencoes/?id_equipamento=1&tipo=Preventiva&status=Pendente
```

- `id_equipamento`: filtra pelo equipamento;
- `tipo`: filtra pelo tipo de manutenção;
- `status`: filtra pelo status.

## Executar o protótipo da interface

Em outro terminal, na raiz do projeto:

```bash
bun install
bun run dev
```

O endereço exibido pelo Vite será usado para acessar a interface.

Os arquivos da interface estão em `prototipo/`. Atualmente, o protótipo usa dados locais definidos em `prototipo/lib/mock-data.ts` e `prototipo/lib/app-store.tsx`; a API FastAPI e a interface podem ser executadas separadamente.

## Estrutura principal

```text
backend/
├── alembic/                 # migrações do banco
├── alembic.ini              # configuração do Alembic
└── app/
    ├── categoria/           # model e schemas de categorias
    ├── equipamentos/        # controller, service, repository e model
    ├── manutencoes/         # controller, service, repository e model
    ├── usuarios/            # cadastro e consulta por cargo
    ├── config.py            # configurações do ambiente
    ├── database.py          # engine e sessões SQLAlchemy
    └── main.py              # aplicação FastAPI

prototipo/                   # interface React/TanStack
```

## Desenvolvimento

Verificar a compilação do back-end:

```bash
poetry run python -m compileall -q backend/app
```

Verificar o código do front-end:

```bash
bun run lint
```

Antes de abrir um pull request, confirme que as migrações foram aplicadas e que `alembic check` não encontrou alterações pendentes.
