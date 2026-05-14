unit Test.Domain.Negociacao;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TNegociacaoTests = class
  public
    [Test]
    procedure Create_DeveIniciarStatusPendenteEValorZero;

    [Test]
    procedure SetNomes_DeveRemoverEspacosDasExtremidades;

    [Test]
    procedure AdicionarItem_DeveSomarValorTotal;

    [Test]
    procedure AdicionarItem_DeveBloquearItemNaoInformado;

    [Test]
    procedure AdicionarItem_DeveBloquearItemInvalido;

    [Test]
    procedure RemoverItem_DeveRecalcularValorTotal;

    [Test]
    procedure LimparItens_DeveZerarItensEValorTotal;

    [Test]
    procedure Validar_DeveBloquearProdutorNaoInformado;

    [Test]
    procedure Validar_DeveBloquearDistribuidorNaoInformado;

    [Test]
    procedure Validar_DeveBloquearNegociacaoSemItens;

    [Test]
    procedure Validar_DevePermitirNegociacaoValidaERecalcularTotal;
  end;

implementation

uses
  System.SysUtils,
  App.Types,
  Domain.Negociacao,
  Domain.NegociacaoItem;

procedure AssertCurrencyEquals(const AExpected, AActual: Currency);
begin
  Assert.IsTrue(
    AExpected = AActual,
    Format('Valor esperado: %s. Valor atual: %s.', [CurrToStr(AExpected), CurrToStr(AActual)])
  );
end;

function CriarItemValido(
  const AIdProduto: Integer;
  const AQuantidade: Currency;
  const APrecoUnitario: Currency
): TNegociacaoItem;
begin
  Result := TNegociacaoItem.Create;
  Result.IdProduto := AIdProduto;
  Result.Quantidade := AQuantidade;
  Result.PrecoUnitario := APrecoUnitario;
end;

procedure TNegociacaoTests.AdicionarItem_DeveBloquearItemInvalido;
var
  LNegociacao: TNegociacao;
  LItem: TNegociacaoItem;
begin
  LNegociacao := TNegociacao.Create;
  LItem := TNegociacaoItem.Create;
  try
    LItem.IdProduto := 0;
    LItem.Quantidade := 1;
    LItem.PrecoUnitario := 10;

    Assert.WillRaise(
      procedure
      begin
        LNegociacao.AdicionarItem(LItem);
      end,
      Exception
    );
  finally
    LItem.Free;
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoTests.AdicionarItem_DeveBloquearItemNaoInformado;
var
  LNegociacao: TNegociacao;
begin
  LNegociacao := TNegociacao.Create;
  try
    Assert.WillRaise(
      procedure
      begin
        LNegociacao.AdicionarItem(nil);
      end,
      Exception
    );
  finally
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoTests.AdicionarItem_DeveSomarValorTotal;
var
  LNegociacao: TNegociacao;
begin
  LNegociacao := TNegociacao.Create;
  try
    LNegociacao.AdicionarItem(CriarItemValido(1, 2, 10));
    LNegociacao.AdicionarItem(CriarItemValido(2, 3, 5));

    Assert.AreEqual(2, LNegociacao.Itens.Count);
    AssertCurrencyEquals(35, LNegociacao.ValorTotal);
  finally
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoTests.Create_DeveIniciarStatusPendenteEValorZero;
var
  LNegociacao: TNegociacao;
begin
  LNegociacao := TNegociacao.Create;
  try
    Assert.IsTrue(LNegociacao.Status = snPendente, 'A negociacao deve iniciar pendente.');
    AssertCurrencyEquals(0, LNegociacao.ValorTotal);
    Assert.AreEqual(0, LNegociacao.Itens.Count);
  finally
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoTests.LimparItens_DeveZerarItensEValorTotal;
var
  LNegociacao: TNegociacao;
begin
  LNegociacao := TNegociacao.Create;
  try
    LNegociacao.AdicionarItem(CriarItemValido(1, 2, 10));
    LNegociacao.AdicionarItem(CriarItemValido(2, 3, 5));

    LNegociacao.LimparItens;

    Assert.AreEqual(0, LNegociacao.Itens.Count);
    AssertCurrencyEquals(0, LNegociacao.ValorTotal);
  finally
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoTests.RemoverItem_DeveRecalcularValorTotal;
var
  LNegociacao: TNegociacao;
  LItemRemover: TNegociacaoItem;
begin
  LNegociacao := TNegociacao.Create;
  try
    LItemRemover := CriarItemValido(1, 2, 10);

    LNegociacao.AdicionarItem(LItemRemover);
    LNegociacao.AdicionarItem(CriarItemValido(2, 1, 15));

    LNegociacao.RemoverItem(LItemRemover);

    Assert.AreEqual(1, LNegociacao.Itens.Count);
    AssertCurrencyEquals(15, LNegociacao.ValorTotal);
  finally
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoTests.SetNomes_DeveRemoverEspacosDasExtremidades;
var
  LNegociacao: TNegociacao;
begin
  LNegociacao := TNegociacao.Create;
  try
    LNegociacao.ProdutorNome := '  Produtor Teste  ';
    LNegociacao.DistribuidorNome := '  Distribuidor Teste  ';

    Assert.IsTrue(LNegociacao.ProdutorNome = 'Produtor Teste', 'O nome do produtor deve ser gravado sem espacos nas extremidades.');
    Assert.IsTrue(LNegociacao.DistribuidorNome = 'Distribuidor Teste', 'O nome do distribuidor deve ser gravado sem espacos nas extremidades.');
  finally
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoTests.Validar_DeveBloquearDistribuidorNaoInformado;
var
  LNegociacao: TNegociacao;
begin
  LNegociacao := TNegociacao.Create;
  try
    LNegociacao.IdProdutor := 1;
    LNegociacao.IdDistribuidor := 0;

    Assert.WillRaise(
      procedure
      begin
        LNegociacao.Validar;
      end,
      Exception
    );
  finally
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoTests.Validar_DeveBloquearNegociacaoSemItens;
var
  LNegociacao: TNegociacao;
begin
  LNegociacao := TNegociacao.Create;
  try
    LNegociacao.IdProdutor := 1;
    LNegociacao.IdDistribuidor := 1;

    Assert.WillRaise(
      procedure
      begin
        LNegociacao.Validar;
      end,
      Exception
    );
  finally
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoTests.Validar_DeveBloquearProdutorNaoInformado;
var
  LNegociacao: TNegociacao;
begin
  LNegociacao := TNegociacao.Create;
  try
    LNegociacao.IdProdutor := 0;
    LNegociacao.IdDistribuidor := 1;

    Assert.WillRaise(
      procedure
      begin
        LNegociacao.Validar;
      end,
      Exception
    );
  finally
    LNegociacao.Free;
  end;
end;

procedure TNegociacaoTests.Validar_DevePermitirNegociacaoValidaERecalcularTotal;
var
  LNegociacao: TNegociacao;
begin
  LNegociacao := TNegociacao.Create;
  try
    LNegociacao.IdProdutor := 1;
    LNegociacao.IdDistribuidor := 2;
    LNegociacao.AdicionarItem(CriarItemValido(1, 2, 10));
    LNegociacao.AdicionarItem(CriarItemValido(2, 3, 5));

    LNegociacao.Validar;

    AssertCurrencyEquals(35, LNegociacao.ValorTotal);
  finally
    LNegociacao.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TNegociacaoTests);

end.
