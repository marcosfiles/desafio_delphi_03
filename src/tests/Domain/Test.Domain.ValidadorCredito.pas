unit Test.Domain.ValidadorCredito;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TValidadorCreditoTests = class
  public
    [Test]
    procedure Validar_DevePermitirQuandoAprovadoMaisNegociacaoForIgualAoLimite;

    [Test]
    procedure Validar_DeveBloquearQuandoAprovadoMaisNegociacaoUltrapassarLimite;

    [Test]
    procedure ObterCreditoDisponivel_DeveRetornarLimiteMenosTotalAprovado;

    [Test]
    procedure ObterCreditoDisponivel_DeveRepassarNegociacaoIgnoradaAoRepositorio;

    [Test]
    procedure Validar_DeveBloquearProdutorInvalido;

    [Test]
    procedure Validar_DeveBloquearDistribuidorInvalido;

    [Test]
    procedure Validar_DeveBloquearValorNegociacaoMenorOuIgualAZero;
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  Core.Repositories.Credito,
  Core.Repositories.Negociacao,
  Domain.CreditoProdutorDistribuidor,
  Domain.Negociacao,
  Domain.ValidadorCredito.Intf,
  Domain.ValidadorCredito.Padrao;

type
  TFakeCreditoRepository = class(TInterfacedObject, ICreditoRepository)
  public
    Limite: Currency;
    UltimoIdProdutor: Integer;
    UltimoIdDistribuidor: Integer;

    procedure Inserir(ACredito: TCreditoProdutorDistribuidor);
    procedure Atualizar(ACredito: TCreditoProdutorDistribuidor);
    function BuscarPorId(AId: Integer): TCreditoProdutorDistribuidor;
    function BuscarPorProdutorDistribuidor(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer
    ): TCreditoProdutorDistribuidor;
    function ListarTodos: TObjectList<TCreditoProdutorDistribuidor>;
    function ObterLimite(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer
    ): Currency;
  end;

  TFakeNegociacaoRepository = class(TInterfacedObject, INegociacaoRepository)
  public
    TotalAprovadoRetorno: Currency;
    UltimoIdProdutor: Integer;
    UltimoIdDistribuidor: Integer;
    UltimoIdNegociacaoIgnorar: Integer;

    procedure Inserir(ANegociacao: TNegociacao);
    procedure Atualizar(ANegociacao: TNegociacao);
    function BuscarPorId(AId: Integer): TNegociacao;
    function ListarTodos: TObjectList<TNegociacao>;
    function TotalAprovado(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer;
      AIdNegociacaoIgnorar: Integer = 0
    ): Currency;
    procedure Aprovar(AIdNegociacao: Integer);
    procedure Concluir(AIdNegociacao: Integer);
    procedure Cancelar(AIdNegociacao: Integer);
  end;

procedure AssertCurrencyEquals(const AExpected, AActual: Currency);
begin
  Assert.IsTrue(
    AExpected = AActual,
    Format('Valor esperado: %s. Valor atual: %s.', [CurrToStr(AExpected), CurrToStr(AActual)])
  );
end;

procedure CriarValidador(
  const ALimite: Currency;
  const ATotalAprovado: Currency;
  out ACreditoRepository: TFakeCreditoRepository;
  out ANegociacaoRepository: TFakeNegociacaoRepository;
  out AValidador: IValidadorCredito
);
begin
  ACreditoRepository := TFakeCreditoRepository.Create;
  ACreditoRepository.Limite := ALimite;

  ANegociacaoRepository := TFakeNegociacaoRepository.Create;
  ANegociacaoRepository.TotalAprovadoRetorno := ATotalAprovado;

  AValidador := TValidadorCreditoPadrao.Create(
    ACreditoRepository,
    ANegociacaoRepository
  );
end;

procedure TFakeCreditoRepository.Atualizar(ACredito: TCreditoProdutorDistribuidor);
begin
  raise Exception.Create('Metodo nao usado neste teste.');
end;

function TFakeCreditoRepository.BuscarPorId(AId: Integer): TCreditoProdutorDistribuidor;
begin
  raise Exception.Create('Metodo nao usado neste teste.');
end;

function TFakeCreditoRepository.BuscarPorProdutorDistribuidor(
  AIdProdutor, AIdDistribuidor: Integer): TCreditoProdutorDistribuidor;
begin
  raise Exception.Create('Metodo nao usado neste teste.');
end;

procedure TFakeCreditoRepository.Inserir(ACredito: TCreditoProdutorDistribuidor);
begin
  raise Exception.Create('Metodo nao usado neste teste.');
end;

function TFakeCreditoRepository.ListarTodos: TObjectList<TCreditoProdutorDistribuidor>;
begin
  raise Exception.Create('Metodo nao usado neste teste.');
end;

function TFakeCreditoRepository.ObterLimite(
  AIdProdutor, AIdDistribuidor: Integer): Currency;
begin
  UltimoIdProdutor := AIdProdutor;
  UltimoIdDistribuidor := AIdDistribuidor;
  Result := Limite;
end;

procedure TFakeNegociacaoRepository.Aprovar(AIdNegociacao: Integer);
begin
  raise Exception.Create('Metodo nao usado neste teste.');
end;

procedure TFakeNegociacaoRepository.Atualizar(ANegociacao: TNegociacao);
begin
  raise Exception.Create('Metodo nao usado neste teste.');
end;

function TFakeNegociacaoRepository.BuscarPorId(AId: Integer): TNegociacao;
begin
  raise Exception.Create('Metodo nao usado neste teste.');
end;

procedure TFakeNegociacaoRepository.Cancelar(AIdNegociacao: Integer);
begin
  raise Exception.Create('Metodo nao usado neste teste.');
end;

procedure TFakeNegociacaoRepository.Concluir(AIdNegociacao: Integer);
begin
  raise Exception.Create('Metodo nao usado neste teste.');
end;

procedure TFakeNegociacaoRepository.Inserir(ANegociacao: TNegociacao);
begin
  raise Exception.Create('Metodo nao usado neste teste.');
end;

function TFakeNegociacaoRepository.ListarTodos: TObjectList<TNegociacao>;
begin
  raise Exception.Create('Metodo nao usado neste teste.');
end;

function TFakeNegociacaoRepository.TotalAprovado(
  AIdProdutor, AIdDistribuidor, AIdNegociacaoIgnorar: Integer): Currency;
begin
  UltimoIdProdutor := AIdProdutor;
  UltimoIdDistribuidor := AIdDistribuidor;
  UltimoIdNegociacaoIgnorar := AIdNegociacaoIgnorar;
  Result := TotalAprovadoRetorno;
end;

procedure TValidadorCreditoTests.ObterCreditoDisponivel_DeveRepassarNegociacaoIgnoradaAoRepositorio;
var
  LCreditoRepository: TFakeCreditoRepository;
  LNegociacaoRepository: TFakeNegociacaoRepository;
  LValidador: IValidadorCredito;
begin
  CriarValidador(500, 100, LCreditoRepository, LNegociacaoRepository, LValidador);

  LValidador.ObterCreditoDisponivel(1, 2, 99);

  Assert.AreEqual(99, LNegociacaoRepository.UltimoIdNegociacaoIgnorar);
end;

procedure TValidadorCreditoTests.ObterCreditoDisponivel_DeveRetornarLimiteMenosTotalAprovado;
var
  LCreditoRepository: TFakeCreditoRepository;
  LNegociacaoRepository: TFakeNegociacaoRepository;
  LValidador: IValidadorCredito;
  LDisponivel: Currency;
begin
  CriarValidador(500, 490, LCreditoRepository, LNegociacaoRepository, LValidador);

  LDisponivel := LValidador.ObterCreditoDisponivel(1, 2);

  AssertCurrencyEquals(10, LDisponivel);
end;

procedure TValidadorCreditoTests.Validar_DeveBloquearDistribuidorInvalido;
var
  LCreditoRepository: TFakeCreditoRepository;
  LNegociacaoRepository: TFakeNegociacaoRepository;
  LValidador: IValidadorCredito;
begin
  CriarValidador(500, 0, LCreditoRepository, LNegociacaoRepository, LValidador);

  Assert.WillRaise(
    procedure
    begin
      LValidador.Validar(1, 0, 100);
    end,
    Exception
  );
end;

procedure TValidadorCreditoTests.Validar_DeveBloquearProdutorInvalido;
var
  LCreditoRepository: TFakeCreditoRepository;
  LNegociacaoRepository: TFakeNegociacaoRepository;
  LValidador: IValidadorCredito;
begin
  CriarValidador(500, 0, LCreditoRepository, LNegociacaoRepository, LValidador);

  Assert.WillRaise(
    procedure
    begin
      LValidador.Validar(0, 2, 100);
    end,
    Exception
  );
end;

procedure TValidadorCreditoTests.Validar_DeveBloquearQuandoAprovadoMaisNegociacaoUltrapassarLimite;
var
  LCreditoRepository: TFakeCreditoRepository;
  LNegociacaoRepository: TFakeNegociacaoRepository;
  LValidador: IValidadorCredito;
begin
  CriarValidador(500, 490, LCreditoRepository, LNegociacaoRepository, LValidador);

  Assert.WillRaise(
    procedure
    begin
      LValidador.Validar(1, 2, 150);
    end,
    Exception
  );
end;

procedure TValidadorCreditoTests.Validar_DeveBloquearValorNegociacaoMenorOuIgualAZero;
var
  LCreditoRepository: TFakeCreditoRepository;
  LNegociacaoRepository: TFakeNegociacaoRepository;
  LValidador: IValidadorCredito;
begin
  CriarValidador(500, 0, LCreditoRepository, LNegociacaoRepository, LValidador);

  Assert.WillRaise(
    procedure
    begin
      LValidador.Validar(1, 2, 0);
    end,
    Exception
  );

  Assert.WillRaise(
    procedure
    begin
      LValidador.Validar(1, 2, -1);
    end,
    Exception
  );
end;

procedure TValidadorCreditoTests.Validar_DevePermitirQuandoAprovadoMaisNegociacaoForIgualAoLimite;
var
  LCreditoRepository: TFakeCreditoRepository;
  LNegociacaoRepository: TFakeNegociacaoRepository;
  LValidador: IValidadorCredito;
begin
  CriarValidador(500, 450, LCreditoRepository, LNegociacaoRepository, LValidador);

  LValidador.Validar(1, 2, 50);

  Assert.AreEqual(1, LCreditoRepository.UltimoIdProdutor);
  Assert.AreEqual(2, LCreditoRepository.UltimoIdDistribuidor);
  Assert.AreEqual(1, LNegociacaoRepository.UltimoIdProdutor);
  Assert.AreEqual(2, LNegociacaoRepository.UltimoIdDistribuidor);
end;

initialization
  TDUnitX.RegisterTestFixture(TValidadorCreditoTests);

end.
