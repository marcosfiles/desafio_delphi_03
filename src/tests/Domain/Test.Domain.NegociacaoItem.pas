unit Test.Domain.NegociacaoItem;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TNegociacaoItemTests = class
  public
    [Test]
    procedure Create_DeveIniciarValoresMonetariosComZero;

    [Test]
    procedure SetProdutoNome_DeveRemoverEspacosDasExtremidades;

    [Test]
    procedure ValorTotal_DeveCalcularQuantidadeVezesPreco;

    [Test]
    procedure ValorTotal_DeveCalcularComValoresDecimais;

    [Test]
    procedure SetQuantidade_DeveAtualizarValorTotalQuandoPrecoJaFoiInformado;

    [Test]
    procedure SetPrecoUnitario_DeveAtualizarValorTotalQuandoQuantidadeJaFoiInformada;

    [Test]
    procedure Validar_DeveBloquearQuantidadeMenorOuIgualAZero;

    [Test]
    procedure Validar_DeveBloquearPrecoUnitarioNegativo;

    [Test]
    procedure Validar_DeveBloquearProdutoNaoInformado;

    [Test]
    procedure Validar_DevePermitirItemValido;
  end;

implementation

uses
  System.SysUtils,
  Domain.NegociacaoItem;

procedure AssertCurrencyEquals(const AExpected, AActual: Currency);
begin
  Assert.IsTrue(
    AExpected = AActual,
    Format('Valor esperado: %s. Valor atual: %s.', [CurrToStr(AExpected), CurrToStr(AActual)])
  );
end;

procedure TNegociacaoItemTests.Create_DeveIniciarValoresMonetariosComZero;
var
  LItem: TNegociacaoItem;
begin
  LItem := TNegociacaoItem.Create;
  try
    AssertCurrencyEquals(0, LItem.Quantidade);
    AssertCurrencyEquals(0, LItem.PrecoUnitario);
    AssertCurrencyEquals(0, LItem.ValorTotal);
  finally
    LItem.Free;
  end;
end;

procedure TNegociacaoItemTests.SetPrecoUnitario_DeveAtualizarValorTotalQuandoQuantidadeJaFoiInformada;
var
  LItem: TNegociacaoItem;
begin
  LItem := TNegociacaoItem.Create;
  try
    LItem.Quantidade := 4;
    LItem.PrecoUnitario := 15;
    AssertCurrencyEquals(60, LItem.ValorTotal);

    LItem.PrecoUnitario := 20;
    AssertCurrencyEquals(80, LItem.ValorTotal);
  finally
    LItem.Free;
  end;
end;

procedure TNegociacaoItemTests.SetQuantidade_DeveAtualizarValorTotalQuandoPrecoJaFoiInformado;
var
  LItem: TNegociacaoItem;
begin
  LItem := TNegociacaoItem.Create;
  try
    LItem.PrecoUnitario := 10;
    LItem.Quantidade := 5;
    AssertCurrencyEquals(50, LItem.ValorTotal);

    LItem.Quantidade := 7;
    AssertCurrencyEquals(70, LItem.ValorTotal);
  finally
    LItem.Free;
  end;
end;

procedure TNegociacaoItemTests.SetProdutoNome_DeveRemoverEspacosDasExtremidades;
var
  LItem: TNegociacaoItem;
begin
  LItem := TNegociacaoItem.Create;
  try
    LItem.ProdutoNome := '  Produto Teste  ';

    Assert.IsTrue(LItem.ProdutoNome = 'Produto Teste', 'O nome do produto deve ser gravado sem espacos nas extremidades.');
  finally
    LItem.Free;
  end;
end;

procedure TNegociacaoItemTests.Validar_DeveBloquearPrecoUnitarioNegativo;
var
  LItem: TNegociacaoItem;
begin
  LItem := TNegociacaoItem.Create;
  try
    LItem.IdProduto := 1;
    LItem.Quantidade := 1;
    LItem.PrecoUnitario := -0.01;

    Assert.WillRaise(
      procedure
      begin
        LItem.Validar;
      end,
      Exception
    );
  finally
    LItem.Free;
  end;
end;

procedure TNegociacaoItemTests.Validar_DeveBloquearProdutoNaoInformado;
var
  LItem: TNegociacaoItem;
begin
  LItem := TNegociacaoItem.Create;
  try
    LItem.IdProduto := 0;
    LItem.Quantidade := 1;
    LItem.PrecoUnitario := 10;

    Assert.WillRaise(
      procedure
      begin
        LItem.Validar;
      end,
      Exception
    );
  finally
    LItem.Free;
  end;
end;

procedure TNegociacaoItemTests.Validar_DeveBloquearQuantidadeMenorOuIgualAZero;
var
  LItem: TNegociacaoItem;
begin
  LItem := TNegociacaoItem.Create;
  try
    LItem.IdProduto := 1;
    LItem.PrecoUnitario := 10;

    LItem.Quantidade := 0;
    Assert.WillRaise(
      procedure
      begin
        LItem.Validar;
      end,
      Exception
    );

    LItem.Quantidade := -1;
    Assert.WillRaise(
      procedure
      begin
        LItem.Validar;
      end,
      Exception
    );
  finally
    LItem.Free;
  end;
end;

procedure TNegociacaoItemTests.Validar_DevePermitirItemValido;
var
  LItem: TNegociacaoItem;
begin
  LItem := TNegociacaoItem.Create;
  try
    LItem.IdProduto := 1;
    LItem.Quantidade := 2;
    LItem.PrecoUnitario := 12.50;

    LItem.Validar;
  finally
    LItem.Free;
  end;
end;

procedure TNegociacaoItemTests.ValorTotal_DeveCalcularComValoresDecimais;
var
  LItem: TNegociacaoItem;
begin
  LItem := TNegociacaoItem.Create;
  try
    LItem.Quantidade := 2.5;
    LItem.PrecoUnitario := 20.40;

    AssertCurrencyEquals(51, LItem.ValorTotal);
  finally
    LItem.Free;
  end;
end;

procedure TNegociacaoItemTests.ValorTotal_DeveCalcularQuantidadeVezesPreco;
var
  LItem: TNegociacaoItem;
begin
  LItem := TNegociacaoItem.Create;
  try
    LItem.Quantidade := 3;
    LItem.PrecoUnitario := 25.50;

    AssertCurrencyEquals(76.50, LItem.ValorTotal);
  finally
    LItem.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TNegociacaoItemTests);

end.
