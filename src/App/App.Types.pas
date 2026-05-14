unit App.Types;

interface

uses
  System.SysUtils;

type
  TStatusNegociacao = (
    snPendente,
    snAprovada,
    snConcluida,
    snCancelada
  );

function StatusNegociacaoToString(AStatus: TStatusNegociacao): string;
function StringToStatusNegociacao(const AStatus: string): TStatusNegociacao;

implementation

function StatusNegociacaoToString(AStatus: TStatusNegociacao): string;
begin
  case AStatus of
    snPendente:
      Result := 'PENDENTE';
    snAprovada:
      Result := 'APROVADA';
    snConcluida:
      Result := 'CONCLUIDA';
    snCancelada:
      Result := 'CANCELADA';
  else
    Result := 'PENDENTE';
  end;
end;

function StringToStatusNegociacao(const AStatus: string): TStatusNegociacao;
var
  LStatus: string;
begin
  LStatus := UpperCase(Trim(AStatus));

  if LStatus = 'PENDENTE' then
    Exit(snPendente);

  if LStatus = 'APROVADA' then
    Exit(snAprovada);

  if LStatus = 'CONCLUIDA' then
    Exit(snConcluida);

  if LStatus = 'CANCELADA' then
    Exit(snCancelada);

  raise Exception.CreateFmt('Status de negociacao invalido: %s', [AStatus]);
end;

end.

