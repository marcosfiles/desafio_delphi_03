program NegociacaoTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  Test.Domain.NegociacaoItem in 'Domain\Test.Domain.NegociacaoItem.pas',
  Test.Domain.Negociacao in 'Domain\Test.Domain.Negociacao.pas',
  Test.Domain.NegociacaoEstado in 'Domain\Test.Domain.NegociacaoEstado.pas',
  Test.Domain.ValidadorCredito in 'Domain\Test.Domain.ValidadorCredito.pas',
  App.Types in '..\src\App\App.Types.pas',
  Core.Repositories.Credito in '..\src\Core\Repositories\Core.Repositories.Credito.pas',
  Core.Repositories.Negociacao in '..\src\Core\Repositories\Core.Repositories.Negociacao.pas',
  Domain.CreditoProdutorDistribuidor in '..\src\Domain\Domain.CreditoProdutorDistribuidor.pas',
  Domain.Negociacao in '..\src\Domain\Domain.Negociacao.pas',
  Domain.NegociacaoItem in '..\src\Domain\Domain.NegociacaoItem.pas',
  Domain.ValidadorCredito.Intf in '..\src\Domain\Strategies\Domain.ValidadorCredito.Intf.pas',
  Domain.ValidadorCredito.Padrao in '..\src\Domain\Strategies\Domain.ValidadorCredito.Padrao.pas',
  Domain.NegociacaoEstado.Intf in '..\src\Domain\States\Domain.NegociacaoEstado.Intf.pas',
  Domain.NegociacaoEstado.Pendente in '..\src\Domain\States\Domain.NegociacaoEstado.Pendente.pas',
  Domain.NegociacaoEstado.Aprovada in '..\src\Domain\States\Domain.NegociacaoEstado.Aprovada.pas',
  Domain.NegociacaoEstado.Concluida in '..\src\Domain\States\Domain.NegociacaoEstado.Concluida.pas',
  Domain.NegociacaoEstado.Cancelada in '..\src\Domain\States\Domain.NegociacaoEstado.Cancelada.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
  Logger: ITestLogger;

begin
  try
    TDUnitX.CheckCommandLine;

    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;

    Logger := TDUnitXConsoleLogger.Create(True);
    Runner.AddLogger(Logger);

    Results := Runner.Execute;

    if not Results.AllPassed then
      ExitCode := EXIT_ERRORS;

    Writeln;
    if Results.AllPassed then
      Writeln('Resultado: TODOS OS TESTES PASSARAM.')
    else
      Writeln('Resultado: EXISTEM TESTES COM FALHA.');

    Writeln;
    Writeln('Pressione ENTER para fechar...');
    Readln;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ExitCode := EXIT_ERRORS;

      Writeln;
      Writeln('Pressione ENTER para fechar...');
      Readln;
    end;
  end;
end.
