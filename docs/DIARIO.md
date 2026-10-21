# Diário de decisões — revisão do encontro de refatoração

## O que eu faria diferente hoje

### Validações de entrada

No início, a normalização do patrimônio foi colocada no service e o schema
importava essa função de lá. Hoje eu manteria regras de entrada próximas dos
validadores: o schema é o primeiro lugar que precisa delas e o service deve
coordenar o caso de uso. A decisão foi revista e registrada no commit
`refactor: centraliza validacoes de entrada`.

### Repositories

Eu teria extraído desde o começo o tratamento comum de `commit` e `rollback`.
Enquanto os repositories eram pequenos, a duplicação parecia aceitável, mas
ela faria qualquer ajuste transacional ser repetido em três arquivos. A nova
decisão foi criar uma base mínima, sem transformar o repository em uma camada
mais complexa do que o necessário.

### Dependências dos services

A injeção de `UsuarioRepository` nos services de equipamentos foi mantida por
inércia, mesmo sem uso. Hoje eu verificaria cada dependência antes de colocá-la
no construtor. A autorização já recebe o usuário atual e a política; portanto,
o repository de usuários não precisava ser carregado nesse fluxo.

## Limite mantido

Não ampliei o Factory Method, o Strategy ou o Facade durante este encontro.
Eles continuam aplicados nos pontos já documentados em `padroes/PADROES.md`.
O objetivo aqui foi pagar dívida técnica com passos pequenos e testes, sem
criar nova funcionalidade.

## Registro de adequação para Programação III

### Controller → Service → Repository

- **Problema:** o projeto precisava demonstrar que a API de equipamentos e manutenções não mistura HTTP, regra e persistência.
- **Decisão:** manter Controllers curtos, concentrar regras nos Services/políticas e deixar consultas nos Repositories.
- **Evidência:** `backend/app/equipamentos/controller.py`, `backend/app/manutencoes/controller.py`, Services e Repositories correspondentes.
- **Custo:** mais arquivos e dependências explícitas.
- **Consequência:** cada camada pode ser testada e alterada com menor impacto nas outras.

### Strategy nas políticas do domínio

- **Problema:** permissões de equipamentos e manutenções variam por cargo e não devem ficar espalhadas nos Controllers.
- **Decisão:** isolar as políticas em `PoliticaCriacaoEquipamento` e `PoliticaManutencao`.
- **Alternativas descartadas:** colocar `if` de cargo em cada endpoint ou Service.
- **Evidência:** `backend/app/equipamentos/policies.py`, `backend/app/manutencoes/policies.py` e `backend/tests/test_policies.py`.
- **Pendência:** registrar uma prova de extensão em que uma nova política seja adicionada sem editar o consumidor.

### Factory de regras de manutenção

- **Problema:** regras de preventiva e corretiva variam conforme o tipo da manutenção.
- **Decisão:** carregar regras de `manutencoes/regras.json` e selecionar a configuração por `FabricaPoliticaTipoManutencao`.
- **Alternativa descartada:** espalhar números e condições de cada tipo no Service.
- **Evidência:** `backend/app/manutencoes/policies.py` e `backend/app/manutencoes/regras.json`.
- **Evidência atualizada:** `FabricaPoliticaTipoManutencao` cria objetos concretos `RegrasManutencaoPreventiva` e `RegrasManutencaoCorretiva`; `backend/tests/test_manutencao_policies.py` verifica os tipos criados.

### Facade de encerramento

- **Problema:** encerrar uma manutenção altera a manutenção e o status do equipamento relacionado.
- **Decisão:** o Controller chama `EncerrarManutencaoFacade`, que coordena os Services sem receber regras HTTP.
- **Alternativa descartada:** fazer o Controller chamar diretamente dois Services.
- **Evidência:** `backend/app/manutencoes/facade.py`, `manutencoes/controller.py` e `manutencoes/dependencias.py`.
- **Consequência:** o fluxo de encerramento fica disponível por uma operação de domínio única.

### Padrões não aplicados

Observer foi aplicado ao evento real de encerramento de manutenção. O publicador notifica dois interessados: libera o equipamento relacionado e registra o encerramento no log. Adapter, Decorator, Composite e uma unidade transacional completa continuam não aplicados porque o projeto não possui, no momento, integração externa, comportamento transversal, hierarquia de equipamentos ou uma operação que exija essas abstrações.

### Evidência de testes

A suíte Python deve ser executada com `poetry run pytest -q`. A regra pura `validar_regras_manutencao` foi extraída para `backend/app/manutencoes/regras.py` e possui testes de limites em `backend/tests/test_manutencao_regras.py`. Ao trocar temporariamente `<` por `<=`, o teste do custo exatamente no limite produziu `1 failed, 4 passed`; após a restauração, a linha de base voltou a ser de 22 testes aprovados.
