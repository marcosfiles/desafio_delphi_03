unit Domain.NegociacaoEstado.Concluida;

interface

uses
  System.SysUtils,
  Domain.Negociacao,
  Domain.NegociacaoEstado.Intf;

type
  TEstadoNegociacaoConcluida = class(TInterfacedObject, INegociacaoEstado)
  public
    procedure Aprovar(ANegociacao: TNegociacao);
    procedure Concluir(ANegociacao: TNegociacao);
    procedure Cancelar(ANegociacao: TNegociacao);
  end;

implementation

procedure TEstadoNegociacaoConcluida.Aprovar(ANegociacao: TNegociacao);
begin
  raise Exception.Create('Negociacao concluida nao pode ser aprovada.');
end;

procedure TEstadoNegociacaoConcluida.Concluir(ANegociacao: TNegociacao);
begin
  raise Exception.Create('Negociacao ja esta concluida.');
end;

procedure TEstadoNegociacaoConcluida.Cancelar(ANegociacao: TNegociacao);
begin
  raise Exception.Create('Negociacao concluida nao pode ser cancelada.');
end;

end.

