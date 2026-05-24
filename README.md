# SafeRoute

SafeRoute é um projeto Flutter criado para exibir a tela de login da aplicação.

## Objetivo

O foco inicial deste repositório é apenas a interface de autenticação, com a tela de login já estruturada e pronta para evolução futura.

## O que já está incluído

- Tela de login baseada no layout fornecido.
- Estrutura Flutter pronta para execução no navegador.
- Build web gerado para validação visual local.

## Como executar

Com o Flutter instalado no ambiente, rode:

```bash
flutter run -d chrome
```

Ou, se preferir servir o build web gerado:

```bash
flutter build web
```

## Estrutura principal

- `lib/main.dart`: ponto de entrada do app e tela de login.
- `pubspec.yaml`: dependências e configuração do Flutter.

## Observação

O nome do pacote Flutter precisa permanecer em minúsculas, então o projeto usa `saferoute` no `pubspec.yaml`, enquanto o repositório é identificado como `SafeRoute`.
