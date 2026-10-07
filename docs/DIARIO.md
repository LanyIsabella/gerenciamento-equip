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
