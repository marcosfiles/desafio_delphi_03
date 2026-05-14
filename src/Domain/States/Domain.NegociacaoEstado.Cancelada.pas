unit Domain.NegociacaoEstado.Cancelada;

interface

uses
  System.SysUtils,
  Domain.Negociacao,
  Domain.NegociacaoEstado.Intf;

type
  TEstadoNegociacaoCancelada = class(TInterfacedObject, INegociacaoEstado)
  public
    procedure Aprovar(ANegociacao: TNegociacao);
    procedure Concluir(ANegociacao: TNegociacao);
    procedure Cancelar(ANegociacao: TNegociacao);
  end;

implementation

procedure TEstadoNegociacaoCancelada.Aprovar(ANegociacao: TNegociacao);
begin
  raise Exception.Create('Negociacao cancelada nao pode ser aprovada.');
end;

procedure TEstadoNegociacaoCancelada.Concluir(ANegociacao: TNegociacao);
begin
  raise Exception.Create('Negociacao cancelada nao pode ser concluida.');
end;

procedure TEstadoNegociacaoCancelada.Cancelar(ANegociacao: TNegociacao);
begin
  raise Exception.Create('Negociacao ja esta cancelada.');
end;

end.

