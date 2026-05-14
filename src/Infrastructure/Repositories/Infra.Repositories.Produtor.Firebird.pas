unit Infra.Repositories.Produtor.Firebird;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  Core.Repositories.Produtor,
  Domain.Produtor;

type
  TProdutorRepositoryFirebird = class(TInterfacedObject, IProdutorRepository)
  private
    FConnection: TFDConnection;

    function DataSetToProdutor(AQuery: TFDQuery): TProdutor;
  public
    constructor Create(AConnection: TFDConnection);

    procedure Inserir(AProdutor: TProdutor);
    procedure Atualizar(AProdutor: TProdutor);
    function BuscarPorId(AId: Integer): TProdutor;
    function ListarTodos: TObjectList<TProdutor>;
  end;

implementation

uses
  System.SysUtils;

{ TProdutorRepositoryFirebird }

constructor TProdutorRepositoryFirebird.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TProdutorRepositoryFirebird.DataSetToProdutor(
  AQuery: TFDQuery): TProdutor;
begin
  Result := TProdutor.Create;
  Result.Id := AQuery.FieldByName('PRODUTOR_ID').AsInteger;
  Result.Nome := AQuery.FieldByName('NOME').AsString;
  Result.CpfCnpj := AQuery.FieldByName('CPF/CNPJ').AsString;
  Result.Ativo := SameText(AQuery.FieldByName('ATIVO').AsString, 'S');
end;

procedure TProdutorRepositoryFirebird.Inserir(AProdutor: TProdutor);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO PRODUTOR ' +
      '(NOME, "CPF/CNPJ", ATIVO) ' +
      'VALUES (:NOME, :CPFCNPJ, :ATIVO)';

    LQuery.ParamByName('NOME').AsString := AProdutor.Nome;
    LQuery.ParamByName('CPFCNPJ').AsString := AProdutor.CpfCnpj;
    if AProdutor.Ativo then
      LQuery.ParamByName('ATIVO').AsString := 'S'
    else
      LQuery.ParamByName('ATIVO').AsString := 'N';

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TProdutorRepositoryFirebird.Atualizar(AProdutor: TProdutor);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE PRODUTOR SET ' +
      'NOME = :NOME, ' +
      '"CPF/CNPJ" = :CPFCNPJ, ' +
      'ATIVO = :ATIVO ' +
      'WHERE PRODUTOR_ID = :PRODUTOR_ID';

    LQuery.ParamByName('PRODUTOR_ID').AsInteger := AProdutor.Id;
    LQuery.ParamByName('NOME').AsString := AProdutor.Nome;
    LQuery.ParamByName('CPFCNPJ').AsString := AProdutor.CpfCnpj;
    if AProdutor.Ativo then
      LQuery.ParamByName('ATIVO').AsString := 'S'
    else
      LQuery.ParamByName('ATIVO').AsString := 'N';

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TProdutorRepositoryFirebird.BuscarPorId(AId: Integer): TProdutor;
var
  LQuery: TFDQuery;
begin
  Result := nil;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT PRODUTOR_ID, NOME, "CPF/CNPJ", ATIVO ' +
      'FROM PRODUTOR ' +
      'WHERE PRODUTOR_ID = :PRODUTOR_ID';

    LQuery.ParamByName('PRODUTOR_ID').AsInteger := AId;
    LQuery.Open;

    if not LQuery.IsEmpty then
      Result := DataSetToProdutor(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TProdutorRepositoryFirebird.ListarTodos: TObjectList<TProdutor>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TProdutor>.Create(True);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT PRODUTOR_ID, NOME, "CPF/CNPJ", ATIVO ' +
      'FROM PRODUTOR ' +
      'ORDER BY NOME';

    LQuery.Open;

    while not LQuery.Eof do
    begin
      Result.Add(DataSetToProdutor(LQuery));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

end.

