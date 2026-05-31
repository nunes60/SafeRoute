# SafeRoute

SafeRoute é um projeto, criado com o Flutter e Material Design 3, para to-do de tarefas.

Grupo formado por Murilo Souza, João Paulo Nunes e Victor de Castro.

**Linguagem de Programação Mobile**

# Aviso

_Em desenvolvimento._

## Como executar a versão web localmente

Não abra `web/index.html` diretamente pelo explorador de arquivos. O diretório `web/` é o código-fonte da casca web do Flutter; a versão executável precisa ser gerada e servida por HTTP.

No Windows, execute:

```bat
run_web_local.bat
```

O script gera uma nova build em `build/web` e então sobe um servidor HTTP local nessa pasta.

Também é possível rodar pelo Flutter:

```sh
flutter run -d chrome
```

## Configurar atualização de APK no Android

Para que um APK atualize por cima da versão já instalada, o Android exige:

- o mesmo `applicationId`
- a mesma assinatura entre versões
- um `versionCode` maior que o instalado

Este projeto agora lê a assinatura de release a partir de `android/key.properties`.
Sem esse arquivo, tarefas de release falham de propósito para evitar gerar APK com assinatura errada.

### 1. Gerar uma keystore de release

No terminal, execute algo como:

```sh
keytool -genkeypair -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Criar `android/key.properties`

Use `android/key.properties.example` como modelo e preencha os dados reais:

```properties
storePassword=sua_senha
keyPassword=sua_senha
keyAlias=upload
storeFile=upload-keystore.jks
```

O arquivo já está ignorado pelo Git, assim como arquivos `.jks`.

### 3. Manter o mesmo identificador do app

O `applicationId` atual está em `android/app/build.gradle.kts`. Se você já distribuiu o app, não troque esse valor, senão o Android trata como outro aplicativo e não como atualização.

### 4. Aumentar o build number a cada release

No Flutter, o `versionCode` do Android vem do campo `version` em `pubspec.yaml`.

Exemplo:

```yaml
version: 1.0.1+3
```

Nesse caso:

- `1.0.1` vira o `versionName`
- `3` vira o `versionCode`

Cada novo APK instalável precisa ter um número após o `+` maior que o anterior.

### 5. Gerar o APK de release

```sh
flutter build apk --release
```

Se `android/key.properties` não existir ou estiver incompleto, o build de release vai falhar com uma mensagem de configuração.

Se uma versão antiga foi assinada com outra chave, ela não poderá ser atualizada por cima. Nesse caso, só há duas opções: usar exatamente a mesma keystore antiga ou desinstalar a versão anterior antes de instalar a nova.

### 6. Configurar o GitHub Actions para build de release

O workflow de Android agora espera estes secrets no repositório do GitHub:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

No runner, o workflow recria `android/upload-keystore.jks` e `android/key.properties` antes do `flutter build apk --release`.

Para gerar o conteúdo de `ANDROID_KEYSTORE_BASE64` no Windows PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/upload-keystore.jks"))
```

Em pull requests, o CI faz apenas `flutter build apk --debug`, então não depende desses secrets.
