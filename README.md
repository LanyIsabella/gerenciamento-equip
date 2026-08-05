# Gestor de Equipamentos

Atue como um Engenheiro Front-End Especialista.

Objetivo: Desenvolver uma aplicação Web Front-End completa (sem integração com back-end real), utilizando dados simulados (mock data) e gerenciamento de estado local/em memória para um sistema de Gestão de Equipamentos e Manutenções.

1. Regras do Projeto & Diretrizes Gerais

Apenas Front-End: Toda a persistência e navegação devem ser simuladas (usando localStorage, Context API, Redux, ou estado local do framework).

Estrita Fidelidade aos Campos: NÃO invente ou adicione campos extras às entidades além dos explicitamente definidos neste prompt.

Idioma: Toda a interface, rótulos, botões, mensagens e código textual da UI devem estar rigorosamente em Português (Brasil).

Design & Experiência: Interface limpa, profissional, responsiva e focada no contexto corporativo (empresas de maquinário/hardware).

2. Estrutura de Dados (Mock Data)

Entidade: Equipamento

id_equipamento (Primary Key - identificador único)

nome (Texto - Obrigatório)

patrimonio (Texto - Obrigatório)

data_aquisicao (Data - Obrigatório)

id_categoria (Número / Relacionamento com Categoria - Obrigatório)

status (Texto - Obrigatório, ex: "Ativo", "Em Manutenção", "Inativo")

id_responsavel (Número / Relacionamento com Usuário - Obrigatório)

(Nota: Crie dados fictícios para as listas de seleção de Categoria e Usuário Responsável apenas para preencher os seletores dos formulários e relatórios, utilizando campos mínimos como id e nome).

3. Telas a Serem Desenvolvidas

Crie a navegação e o layout para as 5 telas abaixo:

Tela 1: Login de Usuário (TelaLogin)

Propósito: Autenticação simulada no sistema.

Elementos da Interface:

Campo para e-mail/usuário.

Campo para senha.

Botão de login que redireciona para a tela de Listagem de Equipamentos.

Link/botão para navegar até a Tela de Cadastro de Usuário.

Tela 2: Cadastro de Usuário (TelaCadastroUsuario)

Propósito: Registrar novos usuários no sistema.

Elementos da Interface:

Campos básicos para registro de usuário (Nome, E-mail e Senha).

Botão para salvar/cadastrar (com feedback visual de sucesso).

Link para voltar para a Tela de Login.

Tela 3: Listagem de Equipamentos (TelaListagemEquipamentos)

Propósito: Visualizar e filtrar todos os equipamentos cadastrados.

Área de Busca e Filtros:

Campo de busca textual por Nome do Equipamento.

Seletor (dropdown) para filtrar por Categoria do Equipamento.

Seletor (dropdown) para filtrar por Status.

Tabela / Lista de Exibição:

Colunas: id_equipamento, nome, patrimonio, data_aquisicao, id_categoria (ou nome da categoria), status, id_responsavel (ou nome do responsável).

Ação em cada item: Botão/ícone para Ver Detalhes (abre a Tela de Detalhamento).

Botão em destaque no topo: "Novo Equipamento" (navega para a Tela de Cadastro de Equipamentos).

Tela 4: Cadastro de Equipamentos (TelaCadastroEquipamento)

Propósito: Formulário para inserção de um novo equipamento.

Campos do Formulário (Restritos apenas aos especificados):

nome (Campo de Texto, Obrigatório)

patrimonio (Campo de Texto, Obrigatório)

data_aquisicao (Seletor de Data, Obrigatório)

id_categoria (Seletor/Dropdown com opções fictícias de Categoria, Obrigatório)

status (Seletor/Dropdown com os status disponíveis, Obrigatório)

id_responsavel (Seletor/Dropdown com opções fictícias de Usuários Responsáveis, Obrigatório)

Ações:

Botão "Salvar Equipamento" (adiciona o item ao estado local/mock e redireciona para a listagem).

Botão "Cancelar" (retorna para a listagem).

Tela 5: Detalhamento de Equipamento (TelaDetalhamentoEquipamento)

Propósito: Exibição expandida e detalhada de um equipamento selecionado.

Elementos da Interface:

Exibição organizada e legível de todos os campos da entidade (id_equipamento, nome, patrimonio, data_aquisicao, id_categoria, status, id_responsavel).

Botão para "Voltar para a Lista".

4. Comportamento e Navegação Esperados

A aplicação deve permitir a navegação fluida entre todas as 5 telas.

Ao cadastrar um novo equipamento na Tela 4, ele deve aparecer imediatamente na tabela da Tela 3.

Os filtros na Tela 3 devem redefinir a lista exibida em tempo real.

This project was built with [Lovable](https://lovable.dev).

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/a9454361-e8d7-4d1e-9a21-f9ece137f946).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```
