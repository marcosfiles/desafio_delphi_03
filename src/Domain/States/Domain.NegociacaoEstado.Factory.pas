unit Domain.NegociacaoEstado.Factory;

interface

uses
  App.Types,
  Domain.NegociacaoEstado.Intf;

type
  TNegociacaoEstadoFactory = class
  public
    class function Criar(AStatus: TStatusNegociacao): INegociacaoEstado;
  end;

implementation

uses
  Domain.NegociacaoEstado.Pendente,
  Domain.NegociacaoEstado.Aprovada,
  Domain.NegociacaoEstado.Concluida,
  Domain.NegociacaoEstado.Cancelada;

{ TNegociacaoEstadoFactory }

class function TNegociacaoEstadoFactory.Criar(
  AStatus: TStatusNegociacao): INegociacaoEstado;
begin
  case AStatus of
    snPendente:
      Result := TEstadoNegociacaoPendente.Create;
    snAprovada:
      Result := TEstadoNegociacaoAprovada.Create;
    snConcluida:
      Result := TEstadoNegociacaoConcluida.Create;
    snCancelada:
      Result := TEstadoNegociacaoCancelada.Create;
  else
    Result := TEstadoNegociacaoPendente.Create;
  end;
end;

end.

