unit Test.Domain.NegociacaoEstado;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TNegociacaoEstadoTests = class
  public
    [Test]
    procedure Pendente_Aprovar_DeveAlterarParaAprovada;

    [Test]
    procedure Pendente_Cancelar_DeveAlterarParaCancelada;

    [Test]
    procedure Pendente_Concluir_DeveBloquear;

    [Test]
    procedure Aprovada_Concluir_DeveAlterarParaConcluida;

    [Test]
    procedure Aprovada_Cancelar_DeveAlterarParaCancelada;

    [Test]
    procedure Aprovada_Aprovar_DeveBloquear;

    [Test]
    procedure Concluida_Aprovar_DeveBloquear;

    [Test]
    procedure Concluida_Cancelar_DeveBloquear;

    [Test]
    procedure Cancelada_Aprovar_DeveBloquear;

    [Test]
    procedure Cancelada_Concluir_DeveBloquear;
  end;

implementation

uses
  System.SysUtils,
  App.Types,
  Domain.Negociacao,
  Domain.NegociacaoEstado.Pendente,
  Domain.NegociacaoEstado.Aprovada,
  Domain.NegociacaoEstado.Concluida,
  Domain.NegociacaoEstado.Cancelada;

procedure TNegociacaoEstadoTests.Aprovada_Aprovar_DeveBloquear;
var
  LNegociacao: TNegociacao;
  LEstado: TEstadoNegociacaoAprovada;
begin
  LNegociacao := TNegociacao.Create;
  LEstado := TEstadoNegociacaoAprovada.Create;
  try
    Assert.WillRaise(
      procedure
      begin
        LEstado.Aprovar(LNegociacao);
      end,
      Exception
    );
  finally
    LEstado.Free;
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoEstadoTests.Aprovada_Cancelar_DeveAlterarParaCancelada;
var
  LNegociacao: TNegociacao;
  LEstado: TEstadoNegociacaoAprovada;
begin
  LNegociacao := TNegociacao.Create;
  LEstado := TEstadoNegociacaoAprovada.Create;
  try
    LEstado.Cancelar(LNegociacao);

    Assert.IsTrue(LNegociacao.Status = snCancelada, 'A negociacao aprovada deve poder ser cancelada.');
    Assert.IsTrue(LNegociacao.DataCancelamento > 0, 'A data de cancelamento deve ser preenchida.');
  finally
    LEstado.Free;
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoEstadoTests.Aprovada_Concluir_DeveAlterarParaConcluida;
var
  LNegociacao: TNegociacao;
  LEstado: TEstadoNegociacaoAprovada;
begin
  LNegociacao := TNegociacao.Create;
  LEstado := TEstadoNegociacaoAprovada.Create;
  try
    LEstado.Concluir(LNegociacao);

    Assert.IsTrue(LNegociacao.Status = snConcluida, 'A negociacao aprovada deve poder ser concluida.');
    Assert.IsTrue(LNegociacao.DataConclusao > 0, 'A data de conclusao deve ser preenchida.');
  finally
    LEstado.Free;
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoEstadoTests.Cancelada_Aprovar_DeveBloquear;
var
  LNegociacao: TNegociacao;
  LEstado: TEstadoNegociacaoCancelada;
begin
  LNegociacao := TNegociacao.Create;
  LEstado := TEstadoNegociacaoCancelada.Create;
  try
    Assert.WillRaise(
      procedure
      begin
        LEstado.Aprovar(LNegociacao);
      end,
      Exception
    );
  finally
    LEstado.Free;
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoEstadoTests.Cancelada_Concluir_DeveBloquear;
var
  LNegociacao: TNegociacao;
  LEstado: TEstadoNegociacaoCancelada;
begin
  LNegociacao := TNegociacao.Create;
  LEstado := TEstadoNegociacaoCancelada.Create;
  try
    Assert.WillRaise(
      procedure
      begin
        LEstado.Concluir(LNegociacao);
      end,
      Exception
    );
  finally
    LEstado.Free;
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoEstadoTests.Concluida_Aprovar_DeveBloquear;
var
  LNegociacao: TNegociacao;
  LEstado: TEstadoNegociacaoConcluida;
begin
  LNegociacao := TNegociacao.Create;
  LEstado := TEstadoNegociacaoConcluida.Create;
  try
    Assert.WillRaise(
      procedure
      begin
        LEstado.Aprovar(LNegociacao);
      end,
      Exception
    );
  finally
    LEstado.Free;
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoEstadoTests.Concluida_Cancelar_DeveBloquear;
var
  LNegociacao: TNegociacao;
  LEstado: TEstadoNegociacaoConcluida;
begin
  LNegociacao := TNegociacao.Create;
  LEstado := TEstadoNegociacaoConcluida.Create;
  try
    Assert.WillRaise(
      procedure
      begin
        LEstado.Cancelar(LNegociacao);
      end,
      Exception
    );
  finally
    LEstado.Free;
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoEstadoTests.Pendente_Aprovar_DeveAlterarParaAprovada;
var
  LNegociacao: TNegociacao;
  LEstado: TEstadoNegociacaoPendente;
begin
  LNegociacao := TNegociacao.Create;
  LEstado := TEstadoNegociacaoPendente.Create;
  try
    LEstado.Aprovar(LNegociacao);

    Assert.IsTrue(LNegociacao.Status = snAprovada, 'A negociacao pendente deve poder ser aprovada.');
    Assert.IsTrue(LNegociacao.DataAprovacao > 0, 'A data de aprovacao deve ser preenchida.');
  finally
    LEstado.Free;
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoEstadoTests.Pendente_Cancelar_DeveAlterarParaCancelada;
var
  LNegociacao: TNegociacao;
  LEstado: TEstadoNegociacaoPendente;
begin
  LNegociacao := TNegociacao.Create;
  LEstado := TEstadoNegociacaoPendente.Create;
  try
    LEstado.Cancelar(LNegociacao);

    Assert.IsTrue(LNegociacao.Status = snCancelada, 'A negociacao pendente deve poder ser cancelada.');
    Assert.IsTrue(LNegociacao.DataCancelamento > 0, 'A data de cancelamento deve ser preenchida.');
  finally
    LEstado.Free;
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoEstadoTests.Pendente_Concluir_DeveBloquear;
var
  LNegociacao: TNegociacao;
  LEstado: TEstadoNegociacaoPendente;
begin
  LNegociacao := TNegociacao.Create;
  LEstado := TEstadoNegociacaoPendente.Create;
  try
    Assert.WillRaise(
      procedure
      begin
        LEstado.Concluir(LNegociacao);
      end,
      Exception
    );
  finally
    LEstado.Free;
    LNegociacao.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TNegociacaoEstadoTests);

end.
