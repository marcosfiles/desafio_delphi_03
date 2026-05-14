unit Core.Services.Credito;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Domain.CreditoProdutorDistribuidor,
  Core.Repositories.Credito,
  Core.Services.Credito.Intf;

type
  TCreditoService = class(TInterfacedObject, ICreditoService)
  private
    FCreditoRepository: ICreditoRepository;
  public
    constructor Create(ACreditoRepository: ICreditoRepository);

    procedure Salvar(ACredito: TCreditoProdutorDistribuidor);

    function BuscarPorId(AId: Integer): TCreditoProdutorDistribuidor;

    function BuscarPorProdutorDistribuidor(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer
    ): TCreditoProdutorDistribuidor;

    function ListarTodos: TObjectList<TCreditoProdutorDistribuidor>;
  end;

implementation

{ TCreditoService }

constructor TCreditoService.Create(ACreditoRepository: ICreditoRepository);
begin
  inherited Create;
  FCreditoRepository := ACreditoRepository;
end;

procedure TCreditoService.Salvar(ACredito: TCreditoProdutorDistribuidor);
var
  LCreditoExistente: TCreditoProdutorDistribuidor;
begin
  if not Assigned(ACredito) then
    raise Exception.Create('Limite de credito nao informado.');

  ACredito.Validar;

  LCreditoExistente := FCreditoRepository.BuscarPorProdutorDistribuidor(
    ACredito.IdProdutor,
    ACredito.IdDistribuidor
  );
  try
    if Assigned(LCreditoExistente) and (LCreditoExistente.Id <> ACredito.Id) then
      raise Exception.Create(
        'Ja existe limite de credito para este produtor e distribuidor.'
      );
  finally
    LCreditoExistente.Free;
  end;

  if ACredito.Id = 0 then
    FCreditoRepository.Inserir(ACredito)
  else
    FCreditoRepository.Atualizar(ACredito);
end;

function TCreditoService.BuscarPorId(
  AId: Integer): TCreditoProdutorDistribuidor;
begin
  if AId <= 0 then
    raise Exception.Create('Codigo do limite de credito invalido.');

  Result := FCreditoRepository.BuscarPorId(AId);
end;

function TCreditoService.BuscarPorProdutorDistribuidor(
  AIdProdutor: Integer;
  AIdDistribuidor: Integer): TCreditoProdutorDistribuidor;
begin
  if AIdProdutor <= 0 then
    raise Exception.Create('Produtor nao informado.');

  if AIdDistribuidor <= 0 then
    raise Exception.Create('Distribuidor nao informado.');

  Result := FCreditoRepository.BuscarPorProdutorDistribuidor(
    AIdProdutor,
    AIdDistribuidor
  );
end;

function TCreditoService.ListarTodos: TObjectList<TCreditoProdutorDistribuidor>;
begin
  Result := FCreditoRepository.ListarTodos;
end;

end.

