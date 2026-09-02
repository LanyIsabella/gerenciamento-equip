# Regras de negócio

Este documento reúne as regras identificadas nos controllers e nos schemas de
equipamentos e manutenções. Os identificadores permitem referenciar cada
regra de forma objetiva.

## Equipamentos

### RN-EQ-001 — Listagem de equipamentos

O sistema deve permitir consultar todos os equipamentos cadastrados. Quando
não houver equipamentos, a consulta deve retornar uma lista vazia.

### RN-EQ-002 — Cadastro de equipamento

Para cadastrar um equipamento, o usuário deve informar:

- nome com pelo menos 40 caracteres;
- descrição com pelo menos 100 caracteres;
- data de aquisição no formato `AAAA-MM-DD`;
- número de patrimônio com pelo menos 10 caracteres;
- status com pelo menos 10 caracteres;
- identificador da categoria maior que zero;
- identificador do responsável maior que zero.

Se algum dado não atender a essas condições, o cadastro deve ser rejeitado.

### RN-EQ-003 — Identificação do equipamento

Ao cadastrar um equipamento, o sistema deve gerar seu identificador
automaticamente. O identificador é formado a partir da quantidade atual de
registros mais um; portanto, não é informado pelo usuário.

### RN-EQ-004 — Consulta de equipamento

O usuário deve conseguir consultar um equipamento pelo seu identificador.
Quando o identificador não existir, o sistema deve informar que o equipamento
não foi encontrado.

### RN-EQ-005 — Atualização de equipamento

O usuário pode atualizar apenas os dados que deseja alterar. Os campos não
enviados devem permanecer com os valores anteriores.

No estado atual do sistema, os campos da atualização são opcionais e não
repetem as validações de tamanho, formato de data e valor positivo aplicadas
no cadastro. Essa diferença deve ser confirmada como regra ou corrigida na
implementação.

### RN-EQ-006 — Exclusão de equipamento

O usuário pode excluir um equipamento existente pelo seu identificador. Se o
identificador não existir, o sistema deve informar que o equipamento não foi
encontrado.

### RN-EQ-007 — Dados apresentados nas respostas

As respostas de equipamento devem apresentar, além dos identificadores, o
nome da categoria e o nome do responsável. Esses nomes são exigidos pelo
modelo de resposta, mas não são preenchidos pelo controller de equipamentos;
essa integração ainda precisa ser definida ou implementada.

## Manutenções

### RN-MAN-001 — Listagem de manutenções

O sistema deve permitir consultar todas as manutenções cadastradas. Quando
não houver manutenções, a consulta deve retornar uma lista vazia.

### RN-MAN-002 — Cadastro de manutenção

Para cadastrar uma manutenção, o usuário deve informar:

- identificador do equipamento maior que zero;
- identificador do responsável maior que zero;
- descrição com pelo menos 100 caracteres;
- status com pelo menos 10 caracteres;
- tipo de manutenção com pelo menos 10 caracteres;
- custo maior que zero;
- data de abertura no formato `AAAA-MM-DD`;
- data de conclusão opcional, quando informada no formato `AAAA-MM-DD`.

Se algum dado não atender a essas condições, o cadastro deve ser rejeitado.

### RN-MAN-003 — Identificação da manutenção

Ao cadastrar uma manutenção, o sistema deve gerar seu identificador
automaticamente. O identificador é formado a partir da quantidade atual de
registros mais um; portanto, não é informado pelo usuário.

### RN-MAN-004 — Consulta de manutenção

O usuário deve conseguir consultar uma manutenção pelo seu identificador.
Quando o identificador não existir, o sistema deve informar que a manutenção
não foi encontrada.

### RN-MAN-005 — Atualização de manutenção

O usuário pode atualizar apenas os dados que deseja alterar. Os campos não
enviados devem permanecer com os valores anteriores.

No estado atual do sistema, os campos da atualização são opcionais e não
repetem as validações de descrição, status, tipo, custo positivo e formato de
data aplicadas no cadastro. A atualização também aceita o nome do equipamento
e o nome do responsável, embora esses nomes não façam parte dos dados de
entrada do cadastro. Essas diferenças devem ser confirmadas como regra ou
corrigidas na implementação.

### RN-MAN-006 — Exclusão de manutenção

O usuário pode excluir uma manutenção existente pelo seu identificador. Se o
identificador não existir, o sistema deve informar que a manutenção não foi
encontrada.

### RN-MAN-007 — Dados apresentados nas respostas

As respostas de manutenção devem apresentar o nome do equipamento e o nome do
responsável, além dos respectivos identificadores. Esses nomes são exigidos
pelo modelo de resposta, mas não são preenchidos pelo controller de
manutenções; essa integração ainda precisa ser definida ou implementada.

## Regras e decisões que podem ser definidas posteriormente

1. impedir o cadastro de uma manutenção quando o equipamento informado não
   existir;
2. impedir o cadastro ou a atualização quando o responsável ou a categoria
   não existirem;
3. definir se um equipamento com manutenções pode ser excluído;
4. definir valores permitidos para status e tipo, em vez de aceitar qualquer
   texto com o tamanho mínimo;
5. impedir que a data de conclusão seja anterior à data de abertura;
6. impedir custos inválidos ou definir regras para arredondamento e moeda;
7. garantir que os identificadores nunca sejam reutilizados após uma
   exclusão;
8. substituir o armazenamento em listas na memória por um banco de dados
   persistente.
