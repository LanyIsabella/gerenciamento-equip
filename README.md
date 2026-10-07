# EquipControl

Sistema básico para gerenciamento de equipamentos, usuários e manutenções.

## Pré-requisitos

- Python 3.14 ou superior;
- Poetry;
- PostgreSQL;
- Flutter SDK para executar o aplicativo;
- Chrome, emulador Android ou dispositivo conectado para executar o Flutter.

## 1. Configurar o PostgreSQL e o ambiente

Crie um banco PostgreSQL:

```sql
CREATE USER equipcontrol WITH PASSWORD 'sua_senha';
CREATE DATABASE gerenciamento_equip OWNER equipcontrol;
```

Copie `.env.example` para `.env` e ajuste os valores:

```env
DATABASE_URL=postgresql+psycopg://equipcontrol:sua_senha@localhost:5432/gerenciamento_equip
AUTH_SECRET=uma-chave-secreta-de-desenvolvimento
```

O arquivo `.env` não deve ser commitado.

## 2. Instalar e migrar o backend

Na raiz do projeto:

```bash
poetry install
poetry run alembic -c backend/alembic.ini upgrade head
poetry run alembic -c backend/alembic.ini check
```

O Alembic usa a mesma `DATABASE_URL` do backend. O relacionamento entre equipamentos e manutenções já está mapeado no SQLAlchemy com `ForeignKey` e `relationship`, e sua estrutura está registrada na migração inicial.

Para criar uma nova migração depois de alterar um model:

```bash
poetry run alembic -c backend/alembic.ini revision --autogenerate -m "descreva a alteração"
poetry run alembic -c backend/alembic.ini upgrade head
```

## 3. Executar a API

```bash
poetry run uvicorn app.main:app --app-dir backend --reload
```

Endereços:

- API: http://localhost:8000
- Swagger: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

O CORS está liberado para as portas locais usadas pelo desenvolvimento web.

### Autenticação

Cadastre um usuário:

```http
POST /usuarios/
Content-Type: application/json

{
  "nome": "Usuário Teste",
  "email": "teste@exemplo.com",
  "senha": "senha123",
  "cargo": "administrador"
}
```

Faça login:

```http
POST /usuarios/login
Content-Type: application/json

{
  "email": "teste@exemplo.com",
  "senha": "senha123"
}
```

Use o `access_token` retornado como `Authorization: Bearer <token>`. O endpoint `GET /usuarios/eu` confirma o usuário autenticado.

Ao criar equipamentos ou manutenções, o responsável é definido automaticamente como o usuário logado. As listagens retornam somente os registros desse usuário.

### Equipamentos

```text
GET    /equipamentos/?busca=notebook&id_categoria=1&status=Ativo
POST   /equipamentos/
GET    /equipamentos/{id_equipamento}
PATCH  /equipamentos/{id_equipamento}
DELETE /equipamentos/{id_equipamento}
```

O parâmetro `busca` pesquisa por nome ou patrimônio. Também é possível filtrar por categoria e status.

### Manutenções

```text
GET    /manutencoes/?tipo=Preventiva&status=Pendente
POST   /manutencoes/
GET    /manutencoes/{id_manutencao}
PATCH  /manutencoes/{id_manutencao}
PATCH  /manutencoes/{id_manutencao}/encerrar
DELETE /manutencoes/{id_manutencao}
```

Os tipos aceitos são `Preventiva` e `Corretiva`. O encerramento usa o Facade, atualiza a manutenção e libera o equipamento relacionado.

## 4. Demonstrar a API pelo Swagger

1. Inicie a API com o comando acima.
2. Acesse http://localhost:8000/docs.
3. Execute `POST /usuarios/` para criar um usuário.
4. Execute `POST /usuarios/login` e copie o token.
5. Clique em **Authorize**, informe `Bearer <token>` e confirme.
6. Execute `GET /usuarios/eu`.
7. Teste os endpoints de equipamentos e manutenções.

## 5. Executar o aplicativo Flutter

O aplicativo fica em `flutter_app/` e está dividido em:

```text
flutter_app/lib/
├── models/
├── repositories/
├── screens/
├── services/
├── widgets/
└── routes.dart
```

As telas usam rotas nomeadas e as áreas protegidas passam pelo guarda de
rotas. A sessão fica no `Provider`, com o token somente em memória; ao
recarregar a página, o usuário precisa entrar novamente. O menu lateral
permite acessar início, perfil, livros e sair limpando a pilha de navegação.

Na primeira execução:

```bash
cd flutter_app
flutter pub get
flutter create .
flutter run -d chrome
```

O comando `flutter create .` apenas adiciona os arquivos de plataforma do projeto caso eles ainda não existam.

Para um emulador Android, use:

```bash
flutter devices
flutter run -d <id-do-dispositivo>
```

O aplicativo usa `http://localhost:8000` como endereço da API. Em um emulador Android, troque o endereço para `http://10.0.2.2:8000` em `flutter_app/lib/main.dart`.

## 6. Testar o aplicativo

```bash
cd flutter_app
flutter test
```

Os testes usam um `FakeAuthRepository`, portanto não dependem de uma API real. Eles verificam o login, o armazenamento do token, a chamada de `GET /usuarios/eu`, a mensagem de erro para senha incorreta, o guarda de rotas, o menu e o logout.

## Estrutura principal

```text
backend/       API FastAPI, models, services, repositories e Alembic
flutter_app/   aplicativo Flutter em camadas
prototipo/     protótipo React original
padroes/       catálogo dos padrões aplicados
```

## Encontro de refatoração

Usei estas seis perguntas na varredura do próprio código:

1. Qual é a responsabilidade principal deste trecho?
2. Existe lógica duplicada em outro lugar?
3. Há dependências ou parâmetros que não são usados?
4. O tamanho e a complexidade dificultam a leitura ou a mudança?
5. O nome e o contrato deixam o comportamento claro?
6. Existe um teste que protege o comportamento antes da mudança?

### Cheiro 1 — validação duplicada e regra na camada errada

O que doía: os schemas repetiam as mesmas validações de tamanho para criação
e atualização, e `normalizar_patrimonio` ficava no service mesmo sendo usada
durante a validação do schema.

Antes:

```python
if len(valor) > 50:
    raise ValueError("patrimonio deve ter no máximo 50 caracteres")
```

Depois:

```python
return validar_tamanho_maximo(valor, "patrimonio", 50)
```

`validar_tamanho_maximo` ficou em `backend/app/validacao.py`, e a normalização
foi para `backend/app/equipamentos/validadores.py`. A suíte de caracterização
foi executada antes e depois com `poetry run pytest -q` e permaneceu verde.

### Cheiro 2 — transação duplicada nos repositories

O que doía: equipamentos, manutenções e usuários repetiam o mesmo bloco de
`commit`, `rollback` e propagação da exceção. Uma mudança nessa política de
transação precisaria ser feita em três lugares.

Antes:

```python
try:
    self.session.commit()
except Exception:
    self.session.rollback()
    raise
```

Depois:

```python
self._confirmar()
```

O comportamento comum foi extraído para `RepositorioBase._confirmar`, usado
pelos três repositories. O teste de falha de commit passou com 3 testes verdes
antes e depois da alteração.
