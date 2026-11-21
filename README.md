# LazProjectMenu

Pacote design-time para a IDE do Lazarus (Free Pascal / LCL) que adiciona um menu de contexto completo e produtivo de gerenciamento de projetos no Project Inspector e Project Groups.

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
2. Selecione o arquivo `LazProjectMenu.lpk`.
3. Na janela do gerenciador de pacotes, clique em **Use** > **Install** (ou em **Compile** se desejar compilar antes).
4. O Lazarus solicitara a confirmacao para reconstruir a IDE. Clique em **Yes / Sim**.
5. A IDE sera reconstruida e reiniciada automaticamente com o menu de contexto ativo no Project Inspector e no Project Groups!

> **Nota:** Este pacote e do tipo `RunAndDesignTime`. Ele deve ser instalado na IDE (via **Use > Install**) e nao adicionado como dependencia em projetos comuns.

### Metodo 2: Pela linha de comando (lazbuild)
```bash
lazbuild --add-package "caminho/para/LazProjectMenu.lpk"
lazbuild --build-ide=
```

## Estrutura dos Arquivos

- `LazProjectMenu.lpk`: Definicao do pacote Lazarus.
- `lazprojectmenu.pas`: Unidade principal de registro do pacote.
- `uprojectmenu.pas`: Implementacao dos comandos e hooks do menu de contexto.
