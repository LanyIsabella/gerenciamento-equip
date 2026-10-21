# Ficha do projeto — EquipControl

## Recorte

O EquipControl gerencia equipamentos de uma organização e registra as manutenções realizadas ou pendentes em cada equipamento.

O recorte acadêmico é:

- cadastrar e consultar equipamentos;
- relacionar cada equipamento a uma categoria e a um responsável;
- pesquisar e filtrar equipamentos;
- registrar manutenções preventivas e corretivas;
- acompanhar custo, status, datas e descrição da manutenção;
- encerrar uma manutenção e liberar o equipamento relacionado.

## Usuários e permissões

| Cargo | Responsabilidade no domínio |
|---|---|
| Administrador | Pode cadastrar e alterar equipamentos e manutenções. |
| Gerente | Pode administrar equipamentos conforme a política de equipamentos. |
| Técnico | Pode registrar e tratar manutenções conforme a política de manutenções. |
| Visualizador | Consulta o sistema quando autorizado. |

As permissões são verificadas no backend. O usuário autenticado também limita as listagens ao seu contexto.

## Entidades principais

### Equipamento

| Campo | Tipo | Obrigatório | Regra/responsabilidade |
|---|---|---:|---|
| `id` | inteiro | gerado | Identificador persistente. |
| `nome` | texto | sim | Nome do equipamento. |
| `descricao` | texto | sim | Características e identificação complementar. |
| `data_aquisicao` | data | sim | Data de aquisição. |
| `patrimonio` | texto | sim | Identificador patrimonial normalizado e único. |
| `status` | texto | sim | Estado operacional. |
| `id_categoria` | inteiro | sim | Categoria do equipamento. |
| `id_responsavel` | inteiro | relacionado | Usuário responsável pelo registro/contexto. |

### Manutenção

| Campo | Tipo | Obrigatório | Regra/responsabilidade |
|---|---|---:|---|
| `id` | inteiro | gerado | Identificador persistente. |
| `id_equipamento` | inteiro | sim | Equipamento atendido. |
| `id_responsavel` | inteiro | relacionado | Usuário responsável pela manutenção. |
| `descricao` | texto | sim | Serviço realizado ou problema identificado. |
| `status` | texto | sim | Estado da manutenção. |
| `tipo` | enum | sim | `Preventiva` ou `Corretiva`. |
| `custo` | número | sim | Custo registrado. |
| `data_abertura` | data | sim | Início do atendimento. |
| `data_conclusao` | data | não | Preenchida ao concluir, quando aplicável. |

## Relacionamentos

- Uma categoria pode possuir vários equipamentos.
- Um usuário pode ser responsável por vários equipamentos.
- Um usuário pode ser responsável por várias manutenções.
- Um equipamento pode possuir várias manutenções.
- Cada manutenção pertence a exatamente um equipamento.

## Cinco telas do recorte

| Tela mínima | Evidência no projeto |
|---|---|
| Login | `flutter_app/lib/screens/login_screen.dart`. |
| Cadastro | `flutter_app/lib/screens/register_screen.dart`. |
| Listagem com busca | `flutter_app/lib/screens/equipamentos_screen.dart`, `manutencoes_screen.dart` e filtros da API. |
| Formulário | `flutter_app/lib/widgets/equipamento_form_dialog.dart` e `manutencao_form_dialog.dart`. |
| Detalhe | Rotas e telas de equipamento/manutenção no Flutter e em `prototipo/routes/`. |

## Busca e fluxo principal

- Equipamentos: busca por nome/patrimônio e filtros por categoria/status.
- Manutenções: filtros por equipamento, tipo e status.
- Encerramento: a Facade atualiza a manutenção e libera o equipamento relacionado.

## Implementação arquitetural

```text
Flutter/protótipo → Controller FastAPI → Service/Facade → Repository → SQLAlchemy/PostgreSQL
```

As regras ficam nos Services e políticas; o banco fica nos Repositories; os Controllers recebem, delegam e respondem.
