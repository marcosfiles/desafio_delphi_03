unit Core.Services.Produto;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Domain.Produto,
  Core.Repositories.Produto,
  Core.Services.Produto.Intf;

type
  TProdutoService = class(TInterfacedObject, IProdutoService)
  private
    FProdutoRepository: IProdutoRepository;
  public
    constructor Create(AProdutoRepository: IProdutoRepository);

    procedure Salvar(AProduto: TProduto);
    function BuscarPorId(AId: Integer): TProduto;
    function ListarTodos: TObjectList<TProduto>;
  end;

implementation

{ TProdutoService }

constructor TProdutoService.Create(AProdutoRepository: IProdutoRepository);
begin
  inherited Create;
  FProdutoRepository := AProdutoRepository;
end;

procedure TProdutoService.Salvar(AProduto: TProduto);
begin
  if not Assigned(AProduto) then
    raise Exception.Create('Produto nao informado.');

  AProduto.Validar;

  if AProduto.Id = 0 then
    FProdutoRepository.Inserir(AProduto)
  else
    FProdutoRepository.Atualizar(AProduto);
end;

function TProdutoService.BuscarPorId(AId: Integer): TProduto;
begin
  if AId <= 0 then
    raise Exception.Create('Codigo do produto invalido.');

  Result := FProdutoRepository.BuscarPorId(AId);
end;

function TProdutoService.ListarTodos: TObjectList<TProduto>;
begin
  Result := FProdutoRepository.ListarTodos;
end;

end.

