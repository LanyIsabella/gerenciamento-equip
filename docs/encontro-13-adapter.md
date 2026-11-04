# Encontro 13 — Adapter: encaixar o que não encaixa

Fonte: [Aula P3 — Encontro 13](https://disciplinas.trinove.com.br/page/96/aula-p3)

Prazo informado na aula: **04/11, às 23h59**.

## O que a aula ensina

O encontro apresenta o padrão estrutural **Adapter**, usado quando duas peças precisam conversar, mas possuem interfaces, nomes ou formatos incompatíveis.

O Adapter é uma classe intermediária que:

- expõe, por fora, a interface que o sistema já conhece;
- chama, por dentro, a interface do código externo;
- traduz nomes, formatos, unidades ou estruturas de dados;
- evita alterações no código consumidor e no código externo;
- concentra o conhecimento da integração externa em um único lugar.

O exemplo da aula usa um painel que espera `temperatura()` em Celsius e um sensor importado que oferece `read_fahrenheit()` em Fahrenheit. O painel não deve receber `if` para cada tipo de sensor. O adaptador chama o método externo, converte Fahrenheit para Celsius e devolve o resultado no formato esperado pelo painel.

### O problema que deve ser evitado

Espalhar a integração pelo sistema, por exemplo:

```python
if isinstance(sensor, ImportedSensor):
    celsius = (sensor.read_fahrenheit() - 32) * 5 / 9
else:
    celsius = sensor.temperatura()
```

Esse caminho faz o painel conhecer o nome da classe externa, o método externo e a regra de conversão. Cada nova função precisaria repetir o mesmo `if`, e trocar o fornecedor exigiria alterar vários arquivos.

## O que deve ser criado no projeto

### 1. Criar uma branch da atividade

```bash
git switch -c atividade-13
```

Antes de começar, executar a suíte atual para registrar a situação inicial:

```bash
pytest
```

### 2. Escolher algo que venha de fora

Identificar uma integração externa real do projeto, como:

- uma API pública ou API de outro sistema;
- uma planilha ou arquivo produzido por outra pessoa/sistema;
- um pacote instalado com `pip`.

No `gerenciamento-equip`, a fronteira externa mais evidente é a comunicação do aplicativo Flutter com a API FastAPI: respostas JSON, nomes de campos, rotas HTTP, autenticação e códigos de erro vêm de outro componente. A implementação final deve escolher uma integração concreta e não apenas criar um exemplo artificial.

### 3. Criar o Adapter

Criar uma classe própria que encapsule o código externo.

Requisitos da classe:

- receber ou construir o objeto/cliente externo;
- expor os métodos e formatos que o restante do sistema já espera;
- fazer internamente a conversão necessária;
- manter nomes, formatos e detalhes do fornecedor fora das demais camadas;
- não exigir `if` espalhado para descobrir o tipo do fornecedor.

No projeto atual, uma aplicação possível é isolar a conversão das respostas externas da API em modelos usados pelo Flutter. Telas e serviços devem trabalhar com os modelos e contratos internos, sem conhecer JSON bruto, nomes externos de campos ou detalhes da chamada HTTP. A escolha exata do ponto de adaptação deve ser registrada no diário.

### 4. Integrar o restante do sistema ao Adapter

O código consumidor deve passar a usar o adaptador. O objetivo é que o restante do sistema continue falando sua própria linguagem, enquanto somente o Adapter conhece a linguagem externa.

Não é suficiente criar uma classe Adapter sem conectá-la ao fluxo real.

### 5. Criar o teste da tradução

Adicionar teste automatizado que prove a conversão entre os dois contratos.

O teste deve:

- exercitar o Adapter, não apenas o código externo isoladamente;
- verificar o resultado no formato interno esperado;
- cobrir um caso representativo da tradução;
- permanecer verde junto com a suíte existente.

No tutorial, a aula usa `pytest` e demonstra conversões como `212°F -> 100°C` e `32°F -> 0°C`. Para uma adaptação de arquivo, usa `tmp_path` para criar uma entrada temporária e conferir que campos externos como `name` e `price` viram `nome` e `preco`.

### 6. Registrar a decisão no diário

O diário deve responder, no mínimo:

- qual parte externa foi escolhida;
- qual incompatibilidade foi encontrada;
- qual classe/módulo passou a ser o Adapter;
- qual contrato interno ele oferece;
- qual tradução ele realiza;
- como o restante do sistema foi impedido de conhecer os detalhes externos;
- o que mudaria no sistema se o fornecedor ou a fonte externa fosse trocado.

## Evidências exigidas

A aula pede uma prova de que o código externo ficou isolado:

```bash
git grep -n "o_nome_de_fora"
```

Substitua `o_nome_de_fora` por um nome real da integração escolhida. O resultado deve mostrar o nome externo apenas no Adapter e no teste correspondente, além de eventuais arquivos de configuração/documentação que sejam inevitáveis.

Também devem ser verificáveis:

- os testes passando;
- o Adapter sendo usado no fluxo real;
- ausência de condicionais por tipo do fornecedor no código consumidor;
- nenhum espalhamento da conversão pela aplicação;
- o contrato interno do sistema preservado.

## Entrega

A entrega do Encontro 13 é composta por:

1. **um Adapter** isolando algo externo;
2. **um teste** que comprove a tradução;
3. **um diário** explicando a decisão e o impacto de trocar a fonte externa;
4. commits com a implementação e a documentação;
5. branch publicada e Pull Request aberto.

Comandos indicados pela aula:

```bash
git add .
git commit -m "um adaptador para ..."
git add .
git commit -m "docs: o diario do adaptador"
git push -u origin atividade-13
```

O Pull Request deve conter o Adapter, os testes e o diário. A referência de conclusão do tutorial é a suíte passando e a prova de que o consumidor não precisou ser alterado para conhecer o código externo.

## Checklist do Encontro 13

- [ ] Branch `atividade-13` criada.
- [ ] Suíte de testes executada antes da alteração.
- [ ] Dependência ou formato externo real identificado.
- [ ] Adapter criado no limite da integração.
- [ ] Código consumidor usando o Adapter.
- [ ] Nenhum `if` por tipo do fornecedor espalhado pelo sistema.
- [ ] Conversão coberta por teste automatizado.
- [ ] Testes antigos e novos passando.
- [ ] `git grep` comprovando o isolamento do nome/formato externo.
- [ ] Diário respondendo o que acontece se a fonte externa for trocada.
- [ ] Commits realizados.
- [ ] Branch publicada e Pull Request aberto até o prazo.
