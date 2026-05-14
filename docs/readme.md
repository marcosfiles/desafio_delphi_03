# Desenvolvido por Marcos Roberto de Melo Junior 
# em 14/05/2026

# Sistema de Negociacoes

Projeto Delphi VCL para cadastro de produtores, distribuidores, produtos, limites de credito e negociacoes comerciais.

O sistema permite cadastrar produtores e seus limites de credito por distribuidor, gerar negociacoes com itens, aprovar/concluir/cancelar negociacoes, consultar negociacoes filtradas e imprimir relatorio.

## Tecnologias

- Delphi VCL
- FireDAC
- Firebird
- DUnitX
- Componentes nativos do Delphi para telas, grid, impressao e dialogs

## Estrutura de Pastas

```text
src/
  App/
  Core/
  Domain/
  Infrastructure/
  Presentation/

tests/
  Domain/

docs/
  SQL/
```

## Arquitetura

O projeto foi organizado em camadas para separar regra de negocio, acesso a dados e interface visual.

### App

Pasta responsavel pela configuracao e montagem das dependencias da aplicacao.

Arquivos principais:

- `App.Config.pas`
- `App.Container.pas`
- `App.Types.pas`

O `App.Config` le as configuracoes do banco em `config.ini`. Caso o arquivo nao exista, ele cria uma configuracao padrao.

O `App.Container` centraliza a criacao dos services, repositories, conexao com o banco e validador de credito. Ele funciona como um container simples de dependencias da aplicacao.

O `App.Types` define tipos compartilhados, como o status da negociacao:

- `PENDENTE`
- `APROVADA`
- `CONCLUIDA`
- `CANCELADA`

### Domain

Camada onde ficam as entidades e as regras principais de negocio.

Entidades principais:

- `TProdutor`
- `TDistribuidor`
- `TProduto`
- `TCreditoProdutorDistribuidor`
- `TNegociacao`
- `TNegociacaoItem`

Regras importantes nessa camada:

- produtor precisa ter nome e CPF/CNPJ;
- distribuidor precisa ter nome e CNPJ;
- produto precisa ter nome e preco valido;
- limite de credito nao pode ser negativo;
- item de negociacao precisa ter produto, quantidade maior que zero e preco unitario nao negativo;
- valor total do item e calculado por `Quantidade * PrecoUnitario`;
- negociacao precisa ter produtor, distribuidor e pelo menos um item;
- valor total da negociacao e recalculado com base nos itens;
- credito disponivel considera limite cadastrado menos total ja aprovado.

### States da Negociacao

O fluxo de status da negociacao foi separado usando o padrao State.

Arquivos:

- `Domain.NegociacaoEstado.Pendente.pas`
- `Domain.NegociacaoEstado.Aprovada.pas`
- `Domain.NegociacaoEstado.Concluida.pas`
- `Domain.NegociacaoEstado.Cancelada.pas`
- `Domain.NegociacaoEstado.Factory.pas`

Fluxo permitido:

- negociacao `PENDENTE` pode ser aprovada;
- negociacao `PENDENTE` pode ser cancelada;
- negociacao `APROVADA` pode ser concluida;
- negociacao `APROVADA` pode ser cancelada;
- negociacao `CONCLUIDA` nao pode voltar para outros status;
- negociacao `CANCELADA` nao pode voltar para outros status.

Essa separacao evita concentrar varias regras de status em uma unica classe grande.

### Validador de Credito

O validador de credito fica em:

```text
src/Domain/Strategies/Domain.ValidadorCredito.Padrao.pas
```

Ele recebe dois repositorios:

- repositorio de credito;
- repositorio de negociacao.

A regra principal e:

```text
total aprovado + valor da nova negociacao <= limite de credito
```

Exemplo:

- limite do produtor com o distribuidor: `500`;
- total ja aprovado: `490`;
- nova negociacao: `150`;
- total considerado: `640`;
- resultado: deve bloquear.

Essa regra e importante porque o limite de credito nao pode considerar apenas a negociacao atual. Ele precisa considerar o que ja foi aprovado anteriormente.

### Core

Camada de aplicacao, onde ficam os services e os contratos dos repositories.

Pastas:

```text
src/Core/Services/
src/Core/Repositories/
```

Os services fazem a orquestracao entre tela, dominio e repositorio.

Exemplos:

- `TProdutorService`
- `TDistribuidorService`
- `TProdutoService`
- `TCreditoService`
- `TNegociacaoService`

Responsabilidades dos services:

- validar parametros basicos;
- chamar `Validar` das entidades;
- decidir se deve inserir ou atualizar;
- acionar repositories;
- aplicar validacao de credito na negociacao;
- controlar os comandos de aprovar, concluir e cancelar.

### Infrastructure

Camada de acesso a dados.

Pastas:

```text
src/Infrastructure/Database/
src/Infrastructure/Repositories/
```

O projeto usa FireDAC para conectar ao Firebird.

O arquivo `Infra.Database.ConnectionFactory.pas` cria a conexao com base no `config.ini`.

Os repositories Firebird implementam os contratos definidos em `Core/Repositories`.

Exemplos:

- `TProdutorRepositoryFirebird`
- `TDistribuidorRepositoryFirebird`
- `TProdutoRepositoryFirebird`
- `TCreditoRepositoryFirebird`
- `TNegociacaoRepositoryFirebird`

### Presentation

Camada visual feita em Delphi VCL.

Pasta:

```text
src/Presentation/View/
```

Telas principais:

- `main.pas`: tela principal com menu lateral e area central;
- `View.Dashboard`: resumo de negociacoes por status;
- `View.CadastroProdutor`: cadastro de produtor com limites de credito por distribuidor;
- `View.CadastroDistribuidor`: cadastro de distribuidores;
- `View.CadastroProduto`: cadastro de produtos;
- `View.Negociacao`: criacao de negociacoes;
- `View.ManutencaoNegociacao`: manutencao do status da negociacao;
- `View.Relatorio`: consulta e impressao de relatorio de negociacoes.

A tela principal carrega as telas dentro do painel central, usando forms sem borda e alinhados como conteudo interno:

```pascal
FTelaAtual := AFormClass.Create(Self);
FTelaAtual.BorderStyle := bsNone;
FTelaAtual.Parent := pnlConteudo;
FTelaAtual.Align := alClient;
FTelaAtual.Show;
```

Isso permite uma experiencia parecida com frames, sem precisar converter todas as telas para `TFrame`.

## Banco de Dados

Os scripts do banco estao em:

```text
docs/SQL/
```

Principais tabelas:

- `PRODUTOR`
- `DISTRIBUIDOR`
- `PRODUTO`
- `PRODUTOR_DISTRIBUIDOR_CREDITO`
- `NEGOCIACAO`
- `NEGOCIACAO_ITEM`

O banco tambem possui:

- generators;
- triggers;
- exceptions;
- stored procedures.

Procedures importantes:

- `SP_APROVAR_NEGOCIACAO`
- `SP_CONCLUIR_NEGOCIACAO`
- `SP_CANCELAR_NEGOCIACAO`

A procedure de aprovacao tambem valida o limite de credito no banco, considerando as negociacoes ja aprovadas. Isso cria uma segunda camada de protecao alem da validacao feita na aplicacao.

## Relatorio de Negociacoes

A tela de relatorio fica em:

```text
src/Presentation/View/View.Relatorio.pas
```

Ela permite:

- filtrar por produtor;
- filtrar por distribuidor;
- visualizar as negociacoes filtradas em grid;
- imprimir o relatorio usando componentes nativos do Delphi.

O relatorio exibe:

- nome do produtor;
- nome do distribuidor;
- codigo do contrato;
- data de cadastro;
- data de aprovacao;
- data de conclusao;
- data de cancelamento, quando existir;
- valor total do contrato.

## Testes Unitarios

O projeto de testes fica em:

```text
tests/Negociacao.Tests.dproj
```

Foi usado DUnitX.

Atualmente existem 38 testes unitarios cobrindo os pontos de maior prioridade:

- calculo de item de negociacao;
- validacao de quantidade;
- validacao de preco negativo;
- validacao de produto obrigatorio no item;
- calculo do valor total da negociacao;
- inclusao, remocao e limpeza de itens;
- validacoes obrigatorias da negociacao;
- fluxo de estados da negociacao;
- bloqueios de transicao invalida;
- calculo de credito disponivel;
- bloqueio quando total aprovado mais nova negociacao ultrapassa o limite.

Para executar:

1. abrir `tests/Negociacao.Tests.dproj` no Delphi;
2. compilar o projeto de testes;
3. executar;
4. conferir o resultado no console.

O runner foi configurado para pausar no final, assim os resultados ficam visiveis.

## Configuracao do Banco

O arquivo de configuracao esperado e `config.ini`, criado na mesma pasta do executavel.

Exemplo:

```ini
[Database]
DriverID=FB
Server=
Database=C:\Delphi\projeto\data\TESTE_CRIACAO.FDB
UserName=SYSDBA
Password=masterkey
CharacterSet=ISO8859_1
Protocol=Local
```



