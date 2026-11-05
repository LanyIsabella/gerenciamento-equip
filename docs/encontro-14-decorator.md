# Encontro 14 — Decorator: acrescentar sem alterar

Fonte: [Aula P3 — Encontro 14](https://disciplinas.trinove.com.br/page/101/aula-p3)

Prazo informado na aula: **11/11, às 23h59**.

## O que a aula ensina

O encontro apresenta o padrão estrutural **Decorator**, usado para acrescentar comportamento a um objeto sem alterar a classe original.

Um Decorator:

- guarda o objeto original;
- oferece os mesmos métodos que o objeto embrulhado;
- repassa a chamada para o objeto guardado;
- acrescenta apenas o seu comportamento;
- pode ser combinado com outros Decorators em camadas;
- pode ser removido sem modificar a peça original.

O exemplo da aula usa empréstimos de uma biblioteca. O objeto `Emprestimo` conhece seu prazo e sua descrição. Decorators como `ComRenovacao` e `ComProfessor` guardam um empréstimo, chamam os mesmos métodos e somam apenas seus próprios efeitos.

Assim, o recibo continua chamando `prazo()` e `descricao()` sem saber quantas camadas existem.

## O problema que deve ser evitado

O caminho direto cria uma classe para cada combinação:

```python
class EmprestimoComRenovacaoParaProfessor:
    def prazo(self):
        return 28

    def descricao(self):
        return "Empréstimo com renovação para professor"
```

Essa abordagem faz as classes crescerem por combinação: um adicional dobra as classes, dois adicionais quadruplicam, e assim por diante. Além disso, um prazo repetido em várias classes pode ser alterado em algumas e esquecido em outras, produzindo resultado incorreto sem necessariamente gerar erro.

Também deve ser evitado colocar um `if` para cada adicional na classe original. Isso concentra todas as combinações em uma única classe e faz cada novo comportamento exigir alterações nela.

## Diferença entre Decorator e Adapter

- **Adapter:** traduz uma interface ou formato externo para o contrato que o sistema espera.
- **Decorator:** mantém o mesmo contrato e acrescenta comportamento por cima.

O `@` do Python é apenas um recurso da linguagem. Ele pode implementar uma ideia semelhante à de embrulhar uma função, mas nem todo uso de `@` é o padrão Decorator; por exemplo, `@router.get` registra uma rota.

## O que deve ser criado no projeto

### 1. Criar uma branch da atividade

```bash
git switch -c atividade-14
```

Antes de começar, executar a suíte existente:

```bash
pytest
```

### 2. Escolher algo que vá por cima

Escolher um comportamento transversal que não seja a regra principal do componente, como:

- log;
- cache;
- medição de tempo.

No projeto `gerenciamento-equip`, um candidato coerente é decorar um Repository para registrar consultas ou medir sua execução, mantendo o Repository original e os Services sem alteração. A escolha final deve respeitar o fluxo atual e ser justificada no código e no teste.

### 3. Criar o Decorator

Criar uma classe que:

- receba e guarde a peça original;
- tenha os mesmos métodos usados pelo sistema;
- acrescente o comportamento escolhido;
- repasse a chamada ao objeto original;
- devolva a mesma resposta ou preserve o mesmo contrato;
- possa ser colocada e retirada sem alterar a classe embrulhada.

Molde apresentado na aula:

```python
class RepositorioComLog:
    def __init__(self, repositorio):
        self.repositorio = repositorio

    def buscar(self, id):
        print("buscando", id)
        return self.repositorio.buscar(id)
```

### 4. Integrar o Decorator no fluxo real

Alterar somente o ponto que monta ou injeta o componente para usar o Decorator. O Service e a peça original devem continuar usando o mesmo contrato.

Não é suficiente criar uma classe Decorator solta. Ela precisa ser usada pelo sistema em um fluxo real.

### 5. Criar o teste

Adicionar um teste automatizado que prove o comportamento adicional e o repasse da chamada.

O teste apresentado usa:

- um repositório falso;
- `capsys` do `pytest` para capturar o log impresso;
- uma verificação de que a resposta original continua sendo devolvida.

O teste deve demonstrar, no mínimo:

- o comportamento novo foi executado;
- a peça original foi chamada;
- o resultado original foi preservado;
- o código da peça original não precisou ser alterado.

## Evidências exigidas

A prova do Git deve mostrar que o componente original não foi modificado:

```bash
git diff --stat main
```

O resultado deve listar o Decorator, o teste e o ponto de montagem, sem listar o arquivo da peça original.

Também devem ser verificáveis:

- o Decorator em uso no fluxo real;
- o comportamento adicional funcionando;
- o contrato original preservado;
- ausência de lógica duplicada nas classes embrulhadas;
- testes passando.

## Entrega

A entrega do Encontro 14 é composta por:

1. **um Decorator** acrescentando um comportamento;
2. **a integração** no ponto que monta a peça;
3. **um teste** que comprove o comportamento e o repasse;
4. **nenhuma alteração** no código da peça embrulhada;
5. branch publicada e Pull Request aberto.

Comandos indicados pela aula:

```bash
git add .
git commit -m "um decorator para ..."
git diff --stat main
git push -u origin atividade-14
```

## Rubrica apresentada no encontro

O projeto final será avaliado também por:

- camadas bem separadas: Controller → Service → Repository na API, e screens → services → repositories → models no app;
- validação no formulário e novamente na API;
- três padrões válidos em uso real, não apenas em arquivos soltos;
- `pytest` verde com casos dos dois lados de um limite;
- `flutter test` verde em uma tela do aplicativo;
- histórico do Git distribuído em pelo menos quatro dias;
- apresentação de até 15 minutos mostrando o antes, o depois e a justificativa dos três padrões.

Os padrões válidos destacados são três escolhidos entre Strategy, Factory Method, Facade, Observer, Adapter e Decorator.

## Checklist do Encontro 14

- [ ] Branch `atividade-14` criada.
- [ ] Suíte de testes executada antes da alteração.
- [ ] Comportamento transversal escolhido.
- [ ] Decorator criado no limite correto.
- [ ] Peça original mantida sem alteração.
- [ ] Ponto de montagem integrado ao Decorator.
- [ ] Teste verifica o comportamento adicional.
- [ ] Teste verifica o repasse e a resposta original.
- [ ] `git diff --stat main` comprova o isolamento.
- [ ] Commits realizados.
- [ ] Branch publicada e Pull Request aberto até o prazo.
