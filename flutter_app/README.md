# EquipControl Flutter

Aplicativo Flutter do EquipControl, cliente do sistema de gerenciamento de
equipamentos e manutenções.

## Executar

Na pasta `flutter_app/`:

```bash
flutter pub get
flutter run -d chrome
```

Para executar no Edge ou Windows, use um dispositivo disponível em
`flutter devices`.

## Organização

- `screens/`: login, cadastro, painel, perfil, equipamentos e manutenções;
- `services/`: sessão, API e estado de equipamentos/manutenções;
- `repositories/`: autenticação, equipamentos, manutenções e persistência do token;
- `models/`: usuário, equipamento e manutenção;
- `widgets/`: shell visual, status e formulários das entidades;
- `routes.dart`: rotas nomeadas e áreas protegidas.

As telas de equipamentos e manutenções consomem a API pelos repositories,
enviando o token no cabeçalho `Authorization`. Os filtros são convertidos nos
parâmetros da API e as ações de criar, editar, excluir e encerrar usam os
endpoints correspondentes.

O token é persistido com `SharedPreferences`. A API precisa estar rodando em
`http://localhost:8000` e com o CORS habilitado para a origem do Flutter Web.

## Testes

```bash
 flutter test
```

Os testes cobrem o contrato HTTP, os services, a tela de equipamentos, a
restauração da sessão, o guarda de rotas e o logout.
