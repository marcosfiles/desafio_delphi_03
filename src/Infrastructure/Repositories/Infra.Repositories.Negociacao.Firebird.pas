unit Infra.Repositories.Negociacao.Firebird;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  Core.Repositories.Negociacao,
  Domain.Negociacao;

type
  TNegociacaoRepositoryFirebird = class(TInterfacedObject, INegociacaoRepository)
  private
    FConnection: TFDConnection;

    function ProximoIdNegociacao: Integer;
    function DataSetToNegociacao(AQuery: TFDQuery): TNegociacao;

    procedure InserirItens(ANegociacao: TNegociacao);
    procedure ExcluirItens(AIdNegociacao: Integer);
    procedure CarregarItens(ANegociacao: TNegociacao);
  public
    constructor Create(AConnection: TFDConnection);

    procedure Inserir(ANegociacao: TNegociacao);
    procedure Atualizar(ANegociacao: TNegociacao);
    function BuscarPorId(AId: Integer): TNegociacao;
    function ListarTodos: TObjectList<TNegociacao>;

    function TotalAprovado(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer;
      AIdNegociacaoIgnorar: Integer = 0
    ): Currency;

    procedure Aprovar(AIdNegociacao: Integer);
    procedure Concluir(AIdNegociacao: Integer);
    procedure Cancelar(AIdNegociacao: Integer);
  end;

implementation

uses
  System.SysUtils,
  App.Types,
  Domain.NegociacaoItem;

{ TNegociacaoRepositoryFirebird }

constructor TNegociacaoRepositoryFirebird.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TNegociacaoRepositoryFirebird.ProximoIdNegociacao: Integer;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT GEN_ID(GEN_NEGOCIACAO_ID, 1) AS ID FROM RDB$DATABASE';
    LQuery.Open;
    Result := LQuery.FieldByName('ID').AsInteger;
  finally
    LQuery.Free;
  end;
end;

function TNegociacaoRepositoryFirebird.DataSetToNegociacao(
  AQuery: TFDQuery): TNegociacao;
begin
  Result := TNegociacao.Create;
  Result.Id := AQuery.FieldByName('NEGOCIACAO_ID').AsInteger;
  Result.IdProdutor := AQuery.FieldByName('PRODUTOR_ID').AsInteger;
  Result.IdDistribuidor := AQuery.FieldByName('DISTRIBUIDOR_ID').AsInteger;
  Result.Status := StringToStatusNegociacao(AQuery.FieldByName('STATUS').AsString);
  Result.ValorTotal := AQuery.FieldByName('VALOR_TOTAL').AsCurrency;

  Result.DataCadastro := AQuery.FieldByName('DATA_CADASTRO').AsDateTime;

  if AQuery.FindField('PRODUTOR') <> nil then
    Result.ProdutorNome := AQuery.FieldByName('PRODUTOR').AsString;

  if AQuery.FindField('DISTRIBUIDOR') <> nil then
    Result.DistribuidorNome := AQuery.FieldByName('DISTRIBUIDOR').AsString;

  if not AQuery.FieldByName('DATA_APROVACAO').IsNull then
    Result.DataAprovacao := AQuery.FieldByName('DATA_APROVACAO').AsDateTime;

  if not AQuery.FieldByName('DATA_CONCLUSAO').IsNull then
    Result.DataConclusao := AQuery.FieldByName('DATA_CONCLUSAO').AsDateTime;

  if not AQuery.FieldByName('DATA_CANCELAMENTO').IsNull then
    Result.DataCancelamento := AQuery.FieldByName('DATA_CANCELAMENTO').AsDateTime;
end;

procedure TNegociacaoRepositoryFirebird.Inserir(ANegociacao: TNegociacao);
var
  LQuery: TFDQuery;
  LIniciarTransacao: Boolean;
begin
  ANegociacao.Id := ProximoIdNegociacao;
  LIniciarTransacao := not FConnection.InTransaction;

  if LIniciarTransacao then
    FConnection.StartTransaction;

  try
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text :=
        'INSERT INTO NEGOCIACAO ' +
        '(NEGOCIACAO_ID, PRODUTOR_ID, DISTRIBUIDOR_ID, STATUS, VALOR_TOTAL, DATA_CADASTRO) ' +
        'VALUES (:NEGOCIACAO_ID, :PRODUTOR_ID, :DISTRIBUIDOR_ID, :STATUS, :VALOR_TOTAL, :DATA_CADASTRO)';

      LQuery.ParamByName('NEGOCIACAO_ID').AsInteger := ANegociacao.Id;
      LQuery.ParamByName('PRODUTOR_ID').AsInteger := ANegociacao.IdProdutor;
      LQuery.ParamByName('DISTRIBUIDOR_ID').AsInteger := ANegociacao.IdDistribuidor;
      LQuery.ParamByName('STATUS').AsString := StatusNegociacaoToString(ANegociacao.Status);
      LQuery.ParamByName('VALOR_TOTAL').AsCurrency := ANegociacao.ValorTotal;
      LQuery.ParamByName('DATA_CADASTRO').AsDateTime := ANegociacao.DataCadastro;

      LQuery.ExecSQL;

      InserirItens(ANegociacao);
    finally
      LQuery.Free;
    end;

    if LIniciarTransacao then
      FConnection.Commit;
  except
    if LIniciarTransacao and FConnection.InTransaction then
      FConnection.Rollback;
    raise;
  end;
end;

procedure TNegociacaoRepositoryFirebird.Atualizar(ANegociacao: TNegociacao);
var
  LQuery: TFDQuery;
  LIniciarTransacao: Boolean;
begin
  LIniciarTransacao := not FConnection.InTransaction;

  if LIniciarTransacao then
    FConnection.StartTransaction;

  try
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text :=
        'UPDATE NEGOCIACAO SET ' +
        'PRODUTOR_ID = :PRODUTOR_ID, ' +
        'DISTRIBUIDOR_ID = :DISTRIBUIDOR_ID, ' +
        'VALOR_TOTAL = :VALOR_TOTAL ' +
        'WHERE NEGOCIACAO_ID = :NEGOCIACAO_ID ' +
        'AND STATUS = ''PENDENTE''';

      LQuery.ParamByName('NEGOCIACAO_ID').AsInteger := ANegociacao.Id;
      LQuery.ParamByName('PRODUTOR_ID').AsInteger := ANegociacao.IdProdutor;
      LQuery.ParamByName('DISTRIBUIDOR_ID').AsInteger := ANegociacao.IdDistribuidor;
      LQuery.ParamByName('VALOR_TOTAL').AsCurrency := ANegociacao.ValorTotal;

      LQuery.ExecSQL;

      if LQuery.RowsAffected = 0 then
        raise Exception.Create('Somente negociacoes pendentes podem ser alteradas.');

      ExcluirItens(ANegociacao.Id);
      InserirItens(ANegociacao);
    finally
      LQuery.Free;
    end;

    if LIniciarTransacao then
      FConnection.Commit;
  except
    if LIniciarTransacao and FConnection.InTransaction then
      FConnection.Rollback;
    raise;
  end;
end;

procedure TNegociacaoRepositoryFirebird.InserirItens(ANegociacao: TNegociacao);
var
  LQuery: TFDQuery;
  LItem: TNegociacaoItem;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO NEGOCIACAO_ITEM ' +
      '(NEGOCIACAO_ID, PRODUTO_ID, QTD, PRECO_UNITARIO, VALOR_TOTAL) ' +
      'VALUES (:NEGOCIACAO_ID, :PRODUTO_ID, :QTD, :PRECO_UNITARIO, :VALOR_TOTAL)';

    for LItem in ANegociacao.Itens do
    begin
      LQuery.ParamByName('NEGOCIACAO_ID').AsInteger := ANegociacao.Id;
      LQuery.ParamByName('PRODUTO_ID').AsInteger := LItem.IdProduto;
      LQuery.ParamByName('QTD').AsCurrency := LItem.Quantidade;
      LQuery.ParamByName('PRECO_UNITARIO').AsCurrency := LItem.PrecoUnitario;
      LQuery.ParamByName('VALOR_TOTAL').AsCurrency := LItem.ValorTotal;

      LQuery.ExecSQL;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TNegociacaoRepositoryFirebird.ExcluirItens(AIdNegociacao: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'DELETE FROM NEGOCIACAO_ITEM ' +
      'WHERE NEGOCIACAO_ID = :NEGOCIACAO_ID';

    LQuery.ParamByName('NEGOCIACAO_ID').AsInteger := AIdNegociacao;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TNegociacaoRepositoryFirebird.BuscarPorId(AId: Integer): TNegociacao;
var
  LQuery: TFDQuery;
begin
  Result := nil;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT ' +
      'N.NEGOCIACAO_ID, N.PRODUTOR_ID, P.NOME AS PRODUTOR, ' +
      'N.DISTRIBUIDOR_ID, D.NOME AS DISTRIBUIDOR, ' +
      'N.STATUS, N.VALOR_TOTAL, N.DATA_CADASTRO, ' +
      'N.DATA_APROVACAO, N.DATA_CONCLUSAO, N.DATA_CANCELAMENTO ' +
      'FROM NEGOCIACAO N ' +
      'JOIN PRODUTOR P ON P.PRODUTOR_ID = N.PRODUTOR_ID ' +
      'JOIN DISTRIBUIDOR D ON D.DISTRIBUIDOR_ID = N.DISTRIBUIDOR_ID ' +
      'WHERE N.NEGOCIACAO_ID = :NEGOCIACAO_ID';

    LQuery.ParamByName('NEGOCIACAO_ID').AsInteger := AId;
    LQuery.Open;

    if not LQuery.IsEmpty then
    begin
      Result := DataSetToNegociacao(LQuery);
      CarregarItens(Result);
    end;
  finally
    LQuery.Free;
  end;
end;

function TNegociacaoRepositoryFirebird.ListarTodos: TObjectList<TNegociacao>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TNegociacao>.Create(True);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT ' +
      'N.NEGOCIACAO_ID, N.PRODUTOR_ID, P.NOME AS PRODUTOR, ' +
      'N.DISTRIBUIDOR_ID, D.NOME AS DISTRIBUIDOR, ' +
      'N.STATUS, N.VALOR_TOTAL, N.DATA_CADASTRO, ' +
      'N.DATA_APROVACAO, N.DATA_CONCLUSAO, N.DATA_CANCELAMENTO ' +
      'FROM NEGOCIACAO N ' +
      'JOIN PRODUTOR P ON P.PRODUTOR_ID = N.PRODUTOR_ID ' +
      'JOIN DISTRIBUIDOR D ON D.DISTRIBUIDOR_ID = N.DISTRIBUIDOR_ID ' +
      'ORDER BY N.NEGOCIACAO_ID DESC';

    LQuery.Open;

    while not LQuery.Eof do
    begin
      Result.Add(DataSetToNegociacao(LQuery));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TNegociacaoRepositoryFirebird.CarregarItens(ANegociacao: TNegociacao);
var
  LQuery: TFDQuery;
  LItem: TNegociacaoItem;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT ' +
      'I.NEGOCIACAO_ITEM_ID, I.NEGOCIACAO_ID, I.PRODUTO_ID, ' +
      'P.NOME AS PRODUTO, I.QTD, I.PRECO_UNITARIO, I.VALOR_TOTAL ' +
      'FROM NEGOCIACAO_ITEM I ' +
      'JOIN PRODUTO P ON P.PRODUTO_ID = I.PRODUTO_ID ' +
      'WHERE I.NEGOCIACAO_ID = :NEGOCIACAO_ID ' +
      'ORDER BY I.NEGOCIACAO_ITEM_ID';

    LQuery.ParamByName('NEGOCIACAO_ID').AsInteger := ANegociacao.Id;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      LItem := TNegociacaoItem.Create;
      LItem.Id := LQuery.FieldByName('NEGOCIACAO_ITEM_ID').AsInteger;
      LItem.IdNegociacao := LQuery.FieldByName('NEGOCIACAO_ID').AsInteger;
      LItem.IdProduto := LQuery.FieldByName('PRODUTO_ID').AsInteger;
      LItem.ProdutoNome := LQuery.FieldByName('PRODUTO').AsString;
      LItem.Quantidade := LQuery.FieldByName('QTD').AsCurrency;
      LItem.PrecoUnitario := LQuery.FieldByName('PRECO_UNITARIO').AsCurrency;

      ANegociacao.AdicionarItem(LItem);

      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TNegociacaoRepositoryFirebird.TotalAprovado(
  AIdProdutor: Integer;
  AIdDistribuidor: Integer;
  AIdNegociacaoIgnorar: Integer): Currency;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT COALESCE(SUM(I.QTD * I.PRECO_UNITARIO), 0) AS TOTAL_APROVADO ' +
      'FROM NEGOCIACAO N ' +
      'JOIN NEGOCIACAO_ITEM I ON I.NEGOCIACAO_ID = N.NEGOCIACAO_ID ' +
      'WHERE N.PRODUTOR_ID = :PRODUTOR_ID ' +
      'AND N.DISTRIBUIDOR_ID = :DISTRIBUIDOR_ID ' +
      'AND N.STATUS = ''APROVADA'' ' +
      'AND N.NEGOCIACAO_ID <> :NEGOCIACAO_ID';

    LQuery.ParamByName('PRODUTOR_ID').AsInteger := AIdProdutor;
    LQuery.ParamByName('DISTRIBUIDOR_ID').AsInteger := AIdDistribuidor;
    LQuery.ParamByName('NEGOCIACAO_ID').AsInteger := AIdNegociacaoIgnorar;

    LQuery.Open;
    Result := LQuery.FieldByName('TOTAL_APROVADO').AsCurrency;
  finally
    LQuery.Free;
  end;
end;

procedure TNegociacaoRepositoryFirebird.Aprovar(AIdNegociacao: Integer);
var
  LStoredProc: TFDStoredProc;
begin
  LStoredProc := TFDStoredProc.Create(nil);
  try
    LStoredProc.Connection := FConnection;
    LStoredProc.StoredProcName := 'SP_APROVAR_NEGOCIACAO';
    LStoredProc.Prepare;
    LStoredProc.ParamByName('P_NEGOCIACAO_ID').AsInteger := AIdNegociacao;
    LStoredProc.ExecProc;
  finally
    LStoredProc.Free;
  end;
end;

procedure TNegociacaoRepositoryFirebird.Concluir(AIdNegociacao: Integer);
var
  LStoredProc: TFDStoredProc;
begin
  LStoredProc := TFDStoredProc.Create(nil);
  try
    LStoredProc.Connection := FConnection;
    LStoredProc.StoredProcName := 'SP_CONCLUIR_NEGOCIACAO';
    LStoredProc.Prepare;
    LStoredProc.ParamByName('P_ID_NEGOCIACAO').AsInteger := AIdNegociacao;
    LStoredProc.ExecProc;
  finally
    LStoredProc.Free;
  end;
end;

procedure TNegociacaoRepositoryFirebird.Cancelar(AIdNegociacao: Integer);
var
  LStoredProc: TFDStoredProc;
begin
  LStoredProc := TFDStoredProc.Create(nil);
  try
    LStoredProc.Connection := FConnection;
    LStoredProc.StoredProcName := 'SP_CANCELAR_NEGOCIACAO';
    LStoredProc.Prepare;
    LStoredProc.ParamByName('P_ID_NEGOCIACAO').AsInteger := AIdNegociacao;
    LStoredProc.ExecProc;
  finally
    LStoredProc.Free;
  end;
end;

end.

