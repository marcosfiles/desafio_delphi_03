unit Domain.NegociacaoEstado.Intf;

interface

uses
  Domain.Negociacao;

type
  INegociacaoEstado = interface
    ['{A96BA7BC-7B96-4D81-B3A6-FC71C9D5B25C}']

    procedure Aprovar(ANegociacao: TNegociacao);
    procedure Concluir(ANegociacao: TNegociacao);
    procedure Cancelar(ANegociacao: TNegociacao);
  end;

implementation

end.

