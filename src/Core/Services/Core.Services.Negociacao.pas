unit Core.Services.Negociacao;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Domain.Negociacao,
  Domain.ValidadorCredito.Intf,
  Domain.NegociacaoEstado.Intf,
  Domain.NegociacaoEstado.Factory,
  Core.Repositories.Negociacao,
  Core.Services.Negociacao.Intf;

type
  TNegociacaoService = class(TInterfacedObject, INegociacaoService)
  private
    FNegociacaoRepository: INegociacaoRepository;
    FValidadorCredito: IValidadorCredito;
  public
    constructor Create(
      ANegociacaoRepository: INegociacaoRepository;
      AValidadorCredito: IValidadorCredito
    );

    procedure Salvar(ANegociacao: TNegociacao);
    function BuscarPorId(AId: Integer): TNegociacao;
    function ListarTodos: TObjectList<TNegociacao>;
    function ObterCreditoDisponivel(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer;
      AIdNegociacaoIgnorar: Integer = 0
    ): Currency;

    procedure Aprovar(AIdNegociacao: Integer);
    procedure Concluir(AIdNegociacao: Integer);
    procedure Cancelar(AIdNegociacao: Integer);
  end;

implementation

{ TNegociacaoService }

constructor TNegociacaoService.Create(
  ANegociacaoRepository: INegociacaoRepository;
  AValidadorCredito: IValidadorCredito);
begin
  inherited Create;
  FNegociacaoRepository := ANegociacaoRepository;
  FValidadorCredito := AValidadorCredito;
end;

procedure TNegociacaoService.Salvar(ANegociacao: TNegociacao);
begin
  if not Assigned(ANegociacao) then
    raise Exception.Create('Negociacao nao informada.');

  ANegociacao.Validar;

  FValidadorCredito.Validar(
    ANegociacao.IdProdutor,
    ANegociacao.IdDistribuidor,
    ANegociacao.ValorTotal,
    ANegociacao.Id
  );

  if ANegociacao.Id = 0 then
    FNegociacaoRepository.Inserir(ANegociacao)
  else
    FNegociacaoRepository.Atualizar(ANegociacao);
end;

function TNegociacaoService.BuscarPorId(AId: Integer): TNegociacao;
begin
  if AId <= 0 then
    raise Exception.Create('Codigo da negociacao invalido.');

  Result := FNegociacaoRepository.BuscarPorId(AId);
end;

function TNegociacaoService.ListarTodos: TObjectList<TNegociacao>;
begin
  Result := FNegociacaoRepository.ListarTodos;
end;

function TNegociacaoService.ObterCreditoDisponivel(
  AIdProdutor: Integer;
  AIdDistribuidor: Integer;
  AIdNegociacaoIgnorar: Integer): Currency;
begin
  Result := FValidadorCredito.ObterCreditoDisponivel(
    AIdProdutor,
    AIdDistribuidor,
    AIdNegociacaoIgnorar
  );
end;

procedure TNegociacaoService.Aprovar(AIdNegociacao: Integer);
var
  LNegociacao: TNegociacao;
  LEstado: INegociacaoEstado;
begin
  LNegociacao := BuscarPorId(AIdNegociacao);
  try
    LNegociacao.Validar;

    FValidadorCredito.Validar(
      LNegociacao.IdProdutor,
      LNegociacao.IdDistribuidor,
      LNegociacao.ValorTotal,
      LNegociacao.Id
    );

    LEstado := TNegociacaoEstadoFactory.Criar(LNegociacao.Status);
    LEstado.Aprovar(LNegociacao);

    FNegociacaoRepository.Aprovar(LNegociacao.Id);
  finally
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoService.Concluir(AIdNegociacao: Integer);
var
  LNegociacao: TNegociacao;
  LEstado: INegociacaoEstado;
begin
  LNegociacao := BuscarPorId(AIdNegociacao);
  try
    LEstado := TNegociacaoEstadoFactory.Criar(LNegociacao.Status);
    LEstado.Concluir(LNegociacao);

    FNegociacaoRepository.Concluir(LNegociacao.Id);
  finally
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoService.Cancelar(AIdNegociacao: Integer);
var
  LNegociacao: TNegociacao;
  LEstado: INegociacaoEstado;
begin
  LNegociacao := BuscarPorId(AIdNegociacao);
  try
    LEstado := TNegociacaoEstadoFactory.Criar(LNegociacao.Status);
    LEstado.Cancelar(LNegociacao);

    FNegociacaoRepository.Cancelar(LNegociacao.Id);
  finally
    LNegociacao.Free;
  end;
end;

end.

