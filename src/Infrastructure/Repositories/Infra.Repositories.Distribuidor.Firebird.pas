unit Infra.Repositories.Distribuidor.Firebird;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  Core.Repositories.Distribuidor,
  Domain.Distribuidor;

type
  TDistribuidorRepositoryFirebird = class(TInterfacedObject, IDistribuidorRepository)
  private
    FConnection: TFDConnection;

    function DataSetToDistribuidor(AQuery: TFDQuery): TDistribuidor;
  public
    constructor Create(AConnection: TFDConnection);

    procedure Inserir(ADistribuidor: TDistribuidor);
    procedure Atualizar(ADistribuidor: TDistribuidor);
    function BuscarPorId(AId: Integer): TDistribuidor;
    function ListarTodos: TObjectList<TDistribuidor>;
  end;

implementation

{ TDistribuidorRepositoryFirebird }

constructor TDistribuidorRepositoryFirebird.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TDistribuidorRepositoryFirebird.DataSetToDistribuidor(
  AQuery: TFDQuery): TDistribuidor;
begin
  Result := TDistribuidor.Create;
  Result.Id := AQuery.FieldByName('DISTRIBUIDOR_ID').AsInteger;
  Result.Nome := AQuery.FieldByName('NOME').AsString;
  Result.Cnpj := AQuery.FieldByName('CNPJ').AsString;
end;

procedure TDistribuidorRepositoryFirebird.Inserir(
  ADistribuidor: TDistribuidor);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO DISTRIBUIDOR ' +
      '(NOME, CNPJ) ' +
      'VALUES (:NOME, :CNPJ)';

    LQuery.ParamByName('NOME').AsString := ADistribuidor.Nome;
    LQuery.ParamByName('CNPJ').AsString := ADistribuidor.Cnpj;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TDistribuidorRepositoryFirebird.Atualizar(
  ADistribuidor: TDistribuidor);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE DISTRIBUIDOR SET ' +
      'NOME = :NOME, ' +
      'CNPJ = :CNPJ ' +
      'WHERE DISTRIBUIDOR_ID = :DISTRIBUIDOR_ID';

    LQuery.ParamByName('DISTRIBUIDOR_ID').AsInteger := ADistribuidor.Id;
    LQuery.ParamByName('NOME').AsString := ADistribuidor.Nome;
    LQuery.ParamByName('CNPJ').AsString := ADistribuidor.Cnpj;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TDistribuidorRepositoryFirebird.BuscarPorId(
  AId: Integer): TDistribuidor;
var
  LQuery: TFDQuery;
begin
  Result := nil;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT DISTRIBUIDOR_ID, NOME, CNPJ ' +
      'FROM DISTRIBUIDOR ' +
      'WHERE DISTRIBUIDOR_ID = :DISTRIBUIDOR_ID';

    LQuery.ParamByName('DISTRIBUIDOR_ID').AsInteger := AId;
    LQuery.Open;

    if not LQuery.IsEmpty then
      Result := DataSetToDistribuidor(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TDistribuidorRepositoryFirebird.ListarTodos: TObjectList<TDistribuidor>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TDistribuidor>.Create(True);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT DISTRIBUIDOR_ID, NOME, CNPJ ' +
      'FROM DISTRIBUIDOR ' +
      'ORDER BY NOME';

    LQuery.Open;

    while not LQuery.Eof do
    begin
      Result.Add(DataSetToDistribuidor(LQuery));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

end.

