unit App.Container;

interface

uses
  FireDAC.Comp.Client,
  Core.Services.Produtor.Intf,
  Core.Services.Distribuidor.Intf,
  Core.Services.Produto.Intf,
  Core.Services.Credito.Intf,
  Core.Services.Negociacao.Intf;

type
  TAppContainer = class
  private
    FConnection: TFDConnection;

    FProdutorService: IProdutorService;
    FDistribuidorService: IDistribuidorService;
    FProdutoService: IProdutoService;
    FCreditoService: ICreditoService;
    FNegociacaoService: INegociacaoService;
  public
    constructor Create;
    destructor Destroy; override;

    function ProdutorService: IProdutorService;
    function DistribuidorService: IDistribuidorService;
    function ProdutoService: IProdutoService;
    function CreditoService: ICreditoService;
    function NegociacaoService: INegociacaoService;
  end;

implementation

uses
  Infra.Database.ConnectionFactory,

  Core.Repositories.Produtor,
  Core.Repositories.Distribuidor,
  Core.Repositories.Produto,
  Core.Repositories.Credito,
  Core.Repositories.Negociacao,

  Infra.Repositories.Produtor.Firebird,
  Infra.Repositories.Distribuidor.Firebird,
  Infra.Repositories.Produto.Firebird,
  Infra.Repositories.Credito.Firebird,
  Infra.Repositories.Negociacao.Firebird,

  Domain.ValidadorCredito.Intf,
  Domain.ValidadorCredito.Padrao,

  Core.Services.Produtor,
  Core.Services.Distribuidor,
  Core.Services.Produto,
  Core.Services.Credito,
  Core.Services.Negociacao;

{ TAppContainer }

constructor TAppContainer.Create;
begin
  inherited Create;
  FConnection := TConnectionFactory.CriarConexao;
end;

destructor TAppContainer.Destroy;
begin
  FConnection.Free;
  inherited Destroy;
end;

function TAppContainer.ProdutorService: IProdutorService;
var
  LRepository: IProdutorRepository;
begin
  if not Assigned(FProdutorService) then
  begin
    LRepository := TProdutorRepositoryFirebird.Create(FConnection);
    FProdutorService := TProdutorService.Create(LRepository);
  end;

  Result := FProdutorService;
end;

function TAppContainer.DistribuidorService: IDistribuidorService;
var
  LRepository: IDistribuidorRepository;
begin
  if not Assigned(FDistribuidorService) then
  begin
    LRepository := TDistribuidorRepositoryFirebird.Create(FConnection);
    FDistribuidorService := TDistribuidorService.Create(LRepository);
  end;

  Result := FDistribuidorService;
end;

function TAppContainer.ProdutoService: IProdutoService;
var
  LRepository: IProdutoRepository;
begin
  if not Assigned(FProdutoService) then
  begin
    LRepository := TProdutoRepositoryFirebird.Create(FConnection);
    FProdutoService := TProdutoService.Create(LRepository);
  end;

  Result := FProdutoService;
end;

function TAppContainer.CreditoService: ICreditoService;
var
  LRepository: ICreditoRepository;
begin
  if not Assigned(FCreditoService) then
  begin
    LRepository := TCreditoRepositoryFirebird.Create(FConnection);
    FCreditoService := TCreditoService.Create(LRepository);
  end;

  Result := FCreditoService;
end;

function TAppContainer.NegociacaoService: INegociacaoService;
var
  LCreditoRepository: ICreditoRepository;
  LNegociacaoRepository: INegociacaoRepository;
  LValidadorCredito: IValidadorCredito;
begin
  if not Assigned(FNegociacaoService) then
  begin
    LCreditoRepository := TCreditoRepositoryFirebird.Create(FConnection);
    LNegociacaoRepository := TNegociacaoRepositoryFirebird.Create(FConnection);

    LValidadorCredito := TValidadorCreditoPadrao.Create(
      LCreditoRepository,
      LNegociacaoRepository
    );

    FNegociacaoService := TNegociacaoService.Create(
      LNegociacaoRepository,
      LValidadorCredito
    );
  end;

  Result := FNegociacaoService;
end;

end.

