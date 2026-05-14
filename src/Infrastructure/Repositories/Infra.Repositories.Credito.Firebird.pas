unit Infra.Repositories.Credito.Firebird;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  Core.Repositories.Credito,
  Domain.CreditoProdutorDistribuidor;

type
  TCreditoRepositoryFirebird = class(TInterfacedObject, ICreditoRepository)
  private
    FConnection: TFDConnection;

    function DataSetToCredito(AQuery: TFDQuery): TCreditoProdutorDistribuidor;
  public
    constructor Create(AConnection: TFDConnection);

    procedure Inserir(ACredito: TCreditoProdutorDistribuidor);
    procedure Atualizar(ACredito: TCreditoProdutorDistribuidor);
    function BuscarPorId(AId: Integer): TCreditoProdutorDistribuidor;

    function BuscarPorProdutorDistribuidor(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer
    ): TCreditoProdutorDistribuidor;

    function ListarTodos: TObjectList<TCreditoProdutorDistribuidor>;

    function ObterLimite(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer
    ): Currency;
  end;

implementation

uses
  System.SysUtils;

{ TCreditoRepositoryFirebird }

constructor TCreditoRepositoryFirebird.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TCreditoRepositoryFirebird.DataSetToCredito(
  AQuery: TFDQuery): TCreditoProdutorDistribuidor;
begin
  Result := TCreditoProdutorDistribuidor.Create;
  Result.Id := AQuery.FieldByName('CREDITO_ID').AsInteger;
  Result.IdProdutor := AQuery.FieldByName('PRODUTOR_ID').AsInteger;
  Result.IdDistribuidor := AQuery.FieldByName('DISTRIBUIDOR_ID').AsInteger;
  Result.LimiteCredito := AQuery.FieldByName('LIMITE_CREDITO').AsCurrency;
  Result.DataCadastro := AQuery.FieldByName('DATA_CADASTRO').AsDateTime;

  if not AQuery.FieldByName('DATA_ALTERACAO').IsNull then
    Result.DataAlteracao := AQuery.FieldByName('DATA_ALTERACAO').AsDateTime;
end;

procedure TCreditoRepositoryFirebird.Inserir(
  ACredito: TCreditoProdutorDistribuidor);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO PRODUTOR_DISTRIBUIDOR_CREDITO ' +
      '(PRODUTOR_ID, DISTRIBUIDOR_ID, LIMITE_CREDITO, DATA_CADASTRO) ' +
      'VALUES (:PRODUTOR_ID, :DISTRIBUIDOR_ID, :LIMITE_CREDITO, :DATA_CADASTRO)';

    LQuery.ParamByName('PRODUTOR_ID').AsInteger := ACredito.IdProdutor;
    LQuery.ParamByName('DISTRIBUIDOR_ID').AsInteger := ACredito.IdDistribuidor;
    LQuery.ParamByName('LIMITE_CREDITO').AsCurrency := ACredito.LimiteCredito;
    LQuery.ParamByName('DATA_CADASTRO').AsDateTime := ACredito.DataCadastro;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TCreditoRepositoryFirebird.Atualizar(
  ACredito: TCreditoProdutorDistribuidor);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE PRODUTOR_DISTRIBUIDOR_CREDITO SET ' +
      'PRODUTOR_ID = :PRODUTOR_ID, ' +
      'DISTRIBUIDOR_ID = :DISTRIBUIDOR_ID, ' +
      'LIMITE_CREDITO = :LIMITE_CREDITO, ' +
      'DATA_ALTERACAO = CURRENT_TIMESTAMP ' +
      'WHERE CREDITO_ID = :CREDITO_ID';

    LQuery.ParamByName('CREDITO_ID').AsInteger := ACredito.Id;
    LQuery.ParamByName('PRODUTOR_ID').AsInteger := ACredito.IdProdutor;
    LQuery.ParamByName('DISTRIBUIDOR_ID').AsInteger := ACredito.IdDistribuidor;
    LQuery.ParamByName('LIMITE_CREDITO').AsCurrency := ACredito.LimiteCredito;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TCreditoRepositoryFirebird.BuscarPorId(
  AId: Integer): TCreditoProdutorDistribuidor;
var
  LQuery: TFDQuery;
begin
  Result := nil;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT CREDITO_ID, PRODUTOR_ID, DISTRIBUIDOR_ID, LIMITE_CREDITO, ' +
      'DATA_CADASTRO, DATA_ALTERACAO ' +
      'FROM PRODUTOR_DISTRIBUIDOR_CREDITO ' +
      'WHERE CREDITO_ID = :CREDITO_ID';

    LQuery.ParamByName('CREDITO_ID').AsInteger := AId;
    LQuery.Open;

    if not LQuery.IsEmpty then
      Result := DataSetToCredito(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TCreditoRepositoryFirebird.BuscarPorProdutorDistribuidor(
  AIdProdutor: Integer;
  AIdDistribuidor: Integer): TCreditoProdutorDistribuidor;
var
  LQuery: TFDQuery;
begin
  Result := nil;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT CREDITO_ID, PRODUTOR_ID, DISTRIBUIDOR_ID, LIMITE_CREDITO, ' +
      'DATA_CADASTRO, DATA_ALTERACAO ' +
      'FROM PRODUTOR_DISTRIBUIDOR_CREDITO ' +
      'WHERE PRODUTOR_ID = :PRODUTOR_ID ' +
      'AND DISTRIBUIDOR_ID = :DISTRIBUIDOR_ID';

    LQuery.ParamByName('PRODUTOR_ID').AsInteger := AIdProdutor;
    LQuery.ParamByName('DISTRIBUIDOR_ID').AsInteger := AIdDistribuidor;

    LQuery.Open;

    if not LQuery.IsEmpty then
      Result := DataSetToCredito(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TCreditoRepositoryFirebird.ListarTodos:
  TObjectList<TCreditoProdutorDistribuidor>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TCreditoProdutorDistribuidor>.Create(True);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT C.CREDITO_ID, C.PRODUTOR_ID, C.DISTRIBUIDOR_ID, ' +
      'C.LIMITE_CREDITO, C.DATA_CADASTRO, C.DATA_ALTERACAO ' +
      'FROM PRODUTOR_DISTRIBUIDOR_CREDITO C ' +
      'INNER JOIN PRODUTOR P ON P.PRODUTOR_ID = C.PRODUTOR_ID ' +
      'INNER JOIN DISTRIBUIDOR D ON D.DISTRIBUIDOR_ID = C.DISTRIBUIDOR_ID ' +
      'ORDER BY P.NOME, D.NOME';

    LQuery.Open;

    while not LQuery.Eof do
    begin
      Result.Add(DataSetToCredito(LQuery));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TCreditoRepositoryFirebird.ObterLimite(
  AIdProdutor: Integer;
  AIdDistribuidor: Integer): Currency;
var
  LCredito: TCreditoProdutorDistribuidor;
begin
  LCredito := BuscarPorProdutorDistribuidor(AIdProdutor, AIdDistribuidor);
  try
    if not Assigned(LCredito) then
      raise Exception.Create('Produtor nao possui limite de credito para este distribuidor.');

    Result := LCredito.LimiteCredito;
  finally
    LCredito.Free;
  end;
end;

end.

