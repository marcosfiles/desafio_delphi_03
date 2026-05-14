unit Domain.NegociacaoEstado.Aprovada;

interface

uses
  System.SysUtils,
  App.Types,
  Domain.Negociacao,
  Domain.NegociacaoEstado.Intf;

type
  TEstadoNegociacaoAprovada = class(TInterfacedObject, INegociacaoEstado)
  public
    procedure Aprovar(ANegociacao: TNegociacao);
    procedure Concluir(ANegociacao: TNegociacao);
    procedure Cancelar(ANegociacao: TNegociacao);
  end;

implementation

procedure TEstadoNegociacaoAprovada.Aprovar(ANegociacao: TNegociacao);
begin
  raise Exception.Create('Negociacao ja esta aprovada.');
end;

procedure TEstadoNegociacaoAprovada.Concluir(ANegociacao: TNegociacao);
begin
  ANegociacao.Status := snConcluida;
  ANegociacao.DataConclusao := Now;
end;

procedure TEstadoNegociacaoAprovada.Cancelar(ANegociacao: TNegociacao);
begin
  ANegociacao.Status := snCancelada;
  ANegociacao.DataCancelamento := Now;
end;

end.

