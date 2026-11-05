# Padrões utilizados — Gerenciador de Equipamentos

Este documento registra os padrões identificados ou aplicados no domínio de usuários, categorias, equipamentos e manutenções.

## Padrões aplicados

| Padrão | Família | Problema resolvido | Onde está aplicado | Evidência |
|---|---|---|---|---|
| Strategy | Comportamental | Permite trocar uma política sem editar o fluxo que a utiliza. | Políticas de autorização de equipamentos e manutenções. | `backend/app/equipamentos/policies.py`, `backend/app/manutencoes/policies.py` e testes de políticas. |
| Factory Method | Criacional | Cria a regra concreta de acordo com o tipo de manutenção sem espalhar condicionais. | Regras de manutenção preventiva e corretiva. | `FabricaPoliticaTipoManutencao`, `RegrasManutencaoPreventiva`, `RegrasManutencaoCorretiva` e `backend/tests/test_manutencao_policies.py`. |
| Facade | Estrutural | Esconde uma sequência de operações que envolve mais de uma entidade. | Encerramento de manutenção e liberação do equipamento relacionado. | `backend/app/manutencoes/facade.py` e `backend/tests/test_facade.py`. |
| Observer | Comportamental | Notifica interessados quando uma manutenção é encerrada sem acoplar o publicador aos tipos concretos. | Evento `ManutencaoEncerrada`. | `backend/app/observer/avisos.py` e testes da Facade/Observer. |
| Repository | Arquitetural | Isola consultas e persistência atrás de métodos orientados ao domínio. | Equipamentos, manutenções e usuários. | `backend/app/*/repository.py` e `backend/app/repository.py`. |
| Service Layer | Arquitetural | Mantém as regras de negócio fora dos Controllers e dos Repositories. | Casos de uso de equipamentos e manutenções. | `backend/app/equipamentos/service.py` e `backend/app/manutencoes/service.py`. |
| Injeção de Dependência | Idioma/framework | Entrega Services, Repositories e políticas prontas para cada fluxo. | Dependências do FastAPI com `Depends`. | `backend/app/*/dependencias.py`. |

## Como os padrões se relacionam

```text
Controller
  └── recebe a requisição e delega
      └── Service ou Facade
          ├── aplica regras e políticas
          ├── publica eventos quando necessário
          └── chama Repositories
              └── acessa SQLAlchemy/PostgreSQL
```

No encerramento de uma manutenção, a sequência é:

1. o Controller chama `EncerrarManutencaoFacade`;
2. a Facade atualiza a manutenção por meio do Service;
3. a Facade publica `ManutencaoEncerrada`;
4. `LiberarEquipamentoAoEncerrar` atualiza o equipamento;
5. `RegistrarEncerramentoNoLog` registra o evento.

## Padrões avaliados e não aplicados

| Padrão | Motivo da não aplicação atual |
|---|---|
| State | Os estados da manutenção ainda não possuem comportamentos complexos o suficiente para justificar classes separadas. |
| Corrente de Responsabilidade | As validações atuais são lineares e não formam uma cadeia de handlers independentes. |
| Composite | Equipamentos e categorias não formam uma hierarquia com operações uniformes para itens e grupos. |
| Unit of Work completo | A sessão do SQLAlchemy existe, mas os Repositories ainda confirmam suas próprias operações. |
| Adapter | Não há integração externa ou formato incompatível que precise de isolamento. |
| Decorator | Não há comportamento transversal necessário que justifique envolver os componentes atuais. |

Esses padrões não devem ser adicionados apenas para aumentar a lista. Qualquer aplicação futura deve responder a uma necessidade concreta do gerenciador.

## Critério de comprovação

Um padrão só é considerado aplicado quando há:

- problema concreto do domínio;
- localização no código;
- mudança ou comportamento observável;
- teste, diff ou histórico que comprove a decisão;
- justificativa do custo e do benefício.
