unit Core.Services.Distribuidor;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Domain.Distribuidor,
  Core.Repositories.Distribuidor,
  Core.Services.Distribuidor.Intf;

type
  TDistribuidorService = class(TInterfacedObject, IDistribuidorService)
  private
    FDistribuidorRepository: IDistribuidorRepository;
  public
    constructor Create(ADistribuidorRepository: IDistribuidorRepository);

    procedure Salvar(ADistribuidor: TDistribuidor);
    function BuscarPorId(AId: Integer): TDistribuidor;
    function ListarTodos: TObjectList<TDistribuidor>;
  end;

implementation

{ TDistribuidorService }

constructor TDistribuidorService.Create(
  ADistribuidorRepository: IDistribuidorRepository);
begin
  inherited Create;
  FDistribuidorRepository := ADistribuidorRepository;
end;

procedure TDistribuidorService.Salvar(ADistribuidor: TDistribuidor);
begin
  if not Assigned(ADistribuidor) then
    raise Exception.Create('Distribuidor nao informado.');

  ADistribuidor.Validar;

  if ADistribuidor.Id = 0 then
    FDistribuidorRepository.Inserir(ADistribuidor)
  else
    FDistribuidorRepository.Atualizar(ADistribuidor);
end;

function TDistribuidorService.BuscarPorId(AId: Integer): TDistribuidor;
begin
  if AId <= 0 then
    raise Exception.Create('Codigo do distribuidor invalido.');

  Result := FDistribuidorRepository.BuscarPorId(AId);
end;

function TDistribuidorService.ListarTodos: TObjectList<TDistribuidor>;
begin
  Result := FDistribuidorRepository.ListarTodos;
end;

end.

