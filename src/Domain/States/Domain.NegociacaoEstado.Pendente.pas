unit Domain.NegociacaoEstado.Pendente;

interface

uses
  System.SysUtils,
  App.Types,
  Domain.Negociacao,
  Domain.NegociacaoEstado.Intf;

type
  TEstadoNegociacaoPendente = class(TInterfacedObject, INegociacaoEstado)
  public
    procedure Aprovar(ANegociacao: TNegociacao);
    procedure Concluir(ANegociacao: TNegociacao);
    procedure Cancelar(ANegociacao: TNegociacao);
  end;

implementation

procedure TEstadoNegociacaoPendente.Aprovar(ANegociacao: TNegociacao);
begin
  ANegociacao.Status := snAprovada;
  ANegociacao.DataAprovacao := Now;
end;

procedure TEstadoNegociacaoPendente.Concluir(ANegociacao: TNegociacao);
begin
  raise Exception.Create('Negociacao pendente nao pode ser concluida.');
end;

procedure TEstadoNegociacaoPendente.Cancelar(ANegociacao: TNegociacao);
begin
  ANegociacao.Status := snCancelada;
  ANegociacao.DataCancelamento := Now;
end;

end.

