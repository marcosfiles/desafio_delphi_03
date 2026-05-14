unit Core.Services.Produtor;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Domain.Produtor,
  Core.Repositories.Produtor,
  Core.Services.Produtor.Intf;

type
  TProdutorService = class(TInterfacedObject, IProdutorService)
  private
    FProdutorRepository: IProdutorRepository;
  public
    constructor Create(AProdutorRepository: IProdutorRepository);

    procedure Salvar(AProdutor: TProdutor);
    function BuscarPorId(AId: Integer): TProdutor;
    function ListarTodos: TObjectList<TProdutor>;
  end;

implementation

constructor TProdutorService.Create(AProdutorRepository: IProdutorRepository);
begin
  inherited Create;
  FProdutorRepository := AProdutorRepository;
end;

procedure TProdutorService.Salvar(AProdutor: TProdutor);
begin
  if not Assigned(AProdutor) then
    raise Exception.Create('Produtor nao informado.');

  AProdutor.Validar;

  if AProdutor.Id = 0 then
    FProdutorRepository.Inserir(AProdutor)
  else
    FProdutorRepository.Atualizar(AProdutor);
end;

function TProdutorService.BuscarPorId(AId: Integer): TProdutor;
begin
  if AId <= 0 then
    raise Exception.Create('Codigo do produtor invalido.');

  Result := FProdutorRepository.BuscarPorId(AId);
end;

function TProdutorService.ListarTodos: TObjectList<TProdutor>;
begin
  Result := FProdutorRepository.ListarTodos;
end;

end.

