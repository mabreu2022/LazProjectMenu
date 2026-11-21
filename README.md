# LazProjectMenu

Pacote design-time para a IDE do Lazarus (Free Pascal / LCL) que adiciona um menu de contexto de alta produtividade inspirado no Project Manager / Project Group do Delphi.

O menu e integrado nativamente tanto no **Project Inspector** quanto no **Project Groups** (`lazprojectgroups`).

## Funcionalidades

O menu de contexto disponibiliza 18 acoes organizadas por grupos:

1. **Compile**: Compila os arquivos modificados do projeto selecionado.
2. **Build**: Reconstrutor completo do projeto.
3. **Clean**: Limpeza de binarios e reconstrucao limpa.
4. **Run**: Executa o projeto com depuracao.
5. **Run Without Debugging**: Executa a aplicacao diretamente sem depurador.
6. **Add...**: Abre dialogo para anexar arquivos existentes ao projeto.
7. **Add New > Form**: Cria e anexa instantaneamente um novo Form LCL (.pas e .lfm).
8. **Add New > Frame**: Cria e anexa um novo Frame LCL.
9. **Add New > Data Module**: Cria e anexa um novo DataModule.
10. **Add New > Unit**: Cria e anexa uma nova Unit Pascal limpa.
11. **Add New > Other...**: Abre a janela padrao "File > New...".
12. **Remove File...**: Remove arquivo selecionado do projeto.
13. **Remove Project**: Remove o projeto ativo do Project Group atual.
14. **Save**: Salva o projeto ativo (.lpi / .lpr).
15. **Save As...**: Salva copia do projeto com novo nome.
16. **Rename**: Renomeia arquivo ou projeto na IDE.
17. **Activate**: Define o projeto selecionado como o projeto ativo de compilacao e execucao no Project Group.

## Requisitos

- Lazarus 2.2, 3.x, 4.x ou superior
- Free Pascal (FPC) 3.2.0 ou superior
- Pacotes dependentes: `IDEIntf`, `LCL`, `FCL` (ja inclusos na instalacao padrao do Lazarus)

## Como Instalar

### Metodo 1: Pela interface grafica da IDE Lazarus
1. No menu superior da IDE, clique em **Package** > **Open Package File (.lpk)...**
2. Selecione o arquivo `LazProjectMenu.lpk` desta pasta.
3. Na janela do gerenciador de pacotes, clique em **Compile**.
4. Em seguida, clique em **Use** > **Install**.
5. Confirme a reconstrucao da IDE quando solicitado. O Lazarus sera reiniciado automaticamente com o novo menu ativo.

### Metodo 2: Pela linha de comando (lazbuild)
```bash
lazbuild --add-package "caminho/para/LazProjectMenu.lpk"
lazbuild --build-ide=
```

## Estrutura dos Arquivos

- `LazProjectMenu.lpk`: Definicao do pacote Lazarus.
- `lazprojectmenu.pas`: Unidade de registro do pacote.
- `udelphiprojectmenu.pas`: Implementacao dos hooks dinamicos e manipuladores do menu.
