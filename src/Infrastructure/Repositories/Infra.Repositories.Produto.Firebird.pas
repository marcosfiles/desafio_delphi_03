unit Infra.Repositories.Produto.Firebird;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  Core.Repositories.Produto,
  Domain.Produto;

type
  TProdutoRepositoryFirebird = class(TInterfacedObject, IProdutoRepository)
  private
    FConnection: TFDConnection;

    function DataSetToProduto(AQuery: TFDQuery): TProduto;
  public
    constructor Create(AConnection: TFDConnection);

    procedure Inserir(AProduto: TProduto);
    procedure Atualizar(AProduto: TProduto);
    function BuscarPorId(AId: Integer): TProduto;
    function ListarTodos: TObjectList<TProduto>;
  end;

implementation

{ TProdutoRepositoryFirebird }

constructor TProdutoRepositoryFirebird.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TProdutoRepositoryFirebird.DataSetToProduto(
  AQuery: TFDQuery): TProduto;
begin
  Result := TProduto.Create;
  Result.Id := AQuery.FieldByName('PRODUTO_ID').AsInteger;
  Result.Nome := AQuery.FieldByName('NOME').AsString;
  Result.PrecoVenda := AQuery.FieldByName('PRECO_UNITARIO').AsCurrency;
end;

procedure TProdutoRepositoryFirebird.Inserir(AProduto: TProduto);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO PRODUTO ' +
      '(NOME, PRECO_UNITARIO) ' +
      'VALUES (:NOME, :PRECO_UNITARIO)';

    LQuery.ParamByName('NOME').AsString := AProduto.Nome;
    LQuery.ParamByName('PRECO_UNITARIO').AsCurrency := AProduto.PrecoVenda;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TProdutoRepositoryFirebird.Atualizar(AProduto: TProduto);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE PRODUTO SET ' +
      'NOME = :NOME, ' +
      'PRECO_UNITARIO = :PRECO_UNITARIO ' +
      'WHERE PRODUTO_ID = :PRODUTO_ID';

    LQuery.ParamByName('PRODUTO_ID').AsInteger := AProduto.Id;
    LQuery.ParamByName('NOME').AsString := AProduto.Nome;
    LQuery.ParamByName('PRECO_UNITARIO').AsCurrency := AProduto.PrecoVenda;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TProdutoRepositoryFirebird.BuscarPorId(AId: Integer): TProduto;
var
  LQuery: TFDQuery;
begin
  Result := nil;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT PRODUTO_ID, NOME, PRECO_UNITARIO ' +
      'FROM PRODUTO ' +
      'WHERE PRODUTO_ID = :PRODUTO_ID';

    LQuery.ParamByName('PRODUTO_ID').AsInteger := AId;
    LQuery.Open;

    if not LQuery.IsEmpty then
      Result := DataSetToProduto(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TProdutoRepositoryFirebird.ListarTodos: TObjectList<TProduto>;
var
  LQuery: TFDQuery;
begin
  Result := TObjectList<TProduto>.Create(True);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT PRODUTO_ID, NOME, PRECO_UNITARIO ' +
      'FROM PRODUTO ' +
      'ORDER BY NOME';

    LQuery.Open;

    while not LQuery.Eof do
    begin
      Result.Add(DataSetToProduto(LQuery));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

end.

