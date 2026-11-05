# Catálogo de padrões — Gerenciador de Equipamentos

Este arquivo acompanha a aplicação dos padrões no domínio de equipamentos e manutenções. A coluna “Já usei? Onde?” só deve ser marcada quando houver código, teste, diff ou decisão documentada que comprove o uso.

| Padrão | Família | Que problema resolve | Onde caberia no meu projeto | Já usei? Onde? |
|---|---|---|---|---|
| Strategy | Comportamental | Permite trocar uma política/regra sem editar o fluxo que a utiliza. | Políticas de autorização para equipamentos/manutenções e regras por tipo de manutenção. | Parcial. `backend/app/equipamentos/policies.py` e `backend/app/manutencoes/policies.py`; falta registrar prova de extensão. |
| Factory Method | Criacional | Separa a escolha de uma implementação da forma de criação/configuração. | Criação das regras concretas de manutenção preventiva/corretiva a partir de `regras.json`. | Sim. `FabricaPoliticaTipoManutencao` cria `RegrasManutencaoPreventiva` ou `RegrasManutencaoCorretiva`; ver `backend/tests/test_manutencao_policies.py`. |
| Facade | Estrutural | Esconde uma sequência de operações envolvendo mais de uma entidade. | Encerramento de manutenção e liberação do equipamento relacionado. | Sim. `backend/app/manutencoes/facade.py`, `EncerrarManutencaoFacade`. |
| Adapter | Estrutural | Traduz um contrato externo para o contrato interno sem espalhar detalhes de integração. | Respostas, filtros e payloads da API de equipamentos no aplicativo Flutter. | Sim. `flutter_app/lib/adapters/equipamento_api_adapter.dart`, `flutter_app/lib/repositories/equipamentos_repository.dart` e `flutter_app/test/equipamento_api_adapter_test.dart`. |
| Decorator | Estrutural | Acrescenta logging sem alterar o Repository original ou os Services consumidores. | Operações dos Repositories montados pelas dependências do FastAPI. | Sim. `backend/app/repository_decorators.py` e `backend/tests/test_repository_decorator.py`. |
| Repository | Arquitetural | Isola persistência e oferece métodos orientados ao domínio. | CRUD e filtros de equipamentos, manutenções e usuários. | Sim. Repositories específicos do backend. |

## Padrões reconhecidos pelo stack

| Padrão | Onde aparece | Situação |
|---|---|---|
| Injeção de Dependência | `Depends` nos módulos `dependencias.py`. | Atendido e testável. |
| Unit of Work | Ciclo de vida da `Session` em `database.py`. | Parcial: não é uma unidade transacional completa para todo caso multi-entidade. |
| Corrente de Responsabilidade | Não há cadeia explícita de handlers no domínio. | Não declarar como aplicado. |
| Composite | Não há hierarquia uniforme de equipamentos/categorias. | Não aplicável ao recorte atual. |

## Padrões não aplicados

- **Observer:** o encerramento publica `ManutencaoEncerrada`; `LiberarEquipamentoAoEncerrar` e `RegistrarEncerramentoNoLog` assinam o mesmo contrato em `backend/app/observer/avisos.py`.

Não criar esses padrões apenas para preencher o catálogo. Uma aplicação futura precisa nascer de uma necessidade real de equipamentos, categorias, usuários ou manutenções.

O Adapter foi aplicado para isolar o contrato externo da API de equipamentos,
mantendo o restante do aplicativo dependente apenas dos modelos internos.
