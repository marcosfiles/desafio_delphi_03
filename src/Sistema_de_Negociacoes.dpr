program Sistema_de_Negociacoes;

uses
  Vcl.Forms,
  FireDAC.VCLUI.Wait,
  main in 'main.pas' {frmMain},
  App.Types in 'App\App.Types.pas',
  Domain.Produtor in 'Domain\Domain.Produtor.pas',
  Domain.Distribuidor in 'Domain\Domain.Distribuidor.pas',
  Domain.Produto in 'Domain\Domain.Produto.pas',
  Domain.NegociacaoItem in 'Domain\Domain.NegociacaoItem.pas',
  Domain.Negociacao in 'Domain\Domain.Negociacao.pas',
  Domain.CreditoProdutorDistribuidor in 'Domain\Domain.CreditoProdutorDistribuidor.pas',
  Core.Repositories.Produtor in 'Core\Repositories\Core.Repositories.Produtor.pas',
  Core.Repositories.Distribuidor in 'Core\Repositories\Core.Repositories.Distribuidor.pas',
  Core.Repositories.Produto in 'Core\Repositories\Core.Repositories.Produto.pas',
  Core.Repositories.Credito in 'Core\Repositories\Core.Repositories.Credito.pas',
  Core.Repositories.Negociacao in 'Core\Repositories\Core.Repositories.Negociacao.pas',
  Domain.ValidadorCredito.Intf in 'Domain\Strategies\Domain.ValidadorCredito.Intf.pas',
  Domain.ValidadorCredito.Padrao in 'Domain\Strategies\Domain.ValidadorCredito.Padrao.pas',
  Domain.NegociacaoEstado.Intf in 'Domain\States\Domain.NegociacaoEstado.Intf.pas',
  Domain.NegociacaoEstado.Pendente in 'Domain\States\Domain.NegociacaoEstado.Pendente.pas',
  Domain.NegociacaoEstado.Aprovada in 'Domain\States\Domain.NegociacaoEstado.Aprovada.pas',
  Domain.NegociacaoEstado.Concluida in 'Domain\States\Domain.NegociacaoEstado.Concluida.pas',
  Domain.NegociacaoEstado.Cancelada in 'Domain\States\Domain.NegociacaoEstado.Cancelada.pas',
  Domain.NegociacaoEstado.Factory in 'Domain\States\Domain.NegociacaoEstado.Factory.pas',
  Core.Services.Negociacao.Intf in 'Core\Services\Core.Services.Negociacao.Intf.pas',
  Core.Services.Negociacao in 'Core\Services\Core.Services.Negociacao.pas',
  Core.Services.Produtor.Intf in 'Core\Services\Core.Services.Produtor.Intf.pas',
  Core.Services.Produtor in 'Core\Services\Core.Services.Produtor.pas',
  Core.Services.Distribuidor.Intf in 'Core\Services\Core.Services.Distribuidor.Intf.pas',
  Core.Services.Distribuidor in 'Core\Services\Core.Services.Distribuidor.pas',
  Core.Services.Produto.Intf in 'Core\Services\Core.Services.Produto.Intf.pas',
  Core.Services.Produto in 'Core\Services\Core.Services.Produto.pas',
  Core.Services.Credito.Intf in 'Core\Services\Core.Services.Credito.Intf.pas',
  Core.Services.Credito in 'Core\Services\Core.Services.Credito.pas',
  App.Config in 'App\App.Config.pas',
  App.Container in 'App\App.Container.pas',
  Infra.Database.ConnectionFactory in 'Infrastructure\Database\Infra.Database.ConnectionFactory.pas',
  Infra.Repositories.Produtor.Firebird in 'Infrastructure\Repositories\Infra.Repositories.Produtor.Firebird.pas',
  Infra.Repositories.Distribuidor.Firebird in 'Infrastructure\Repositories\Infra.Repositories.Distribuidor.Firebird.pas',
  Infra.Repositories.Produto.Firebird in 'Infrastructure\Repositories\Infra.Repositories.Produto.Firebird.pas',
  Infra.Repositories.Credito.Firebird in 'Infrastructure\Repositories\Infra.Repositories.Credito.Firebird.pas',
  Infra.Repositories.Negociacao.Firebird in 'Infrastructure\Repositories\Infra.Repositories.Negociacao.Firebird.pas',
  View.CadastroBase in 'Presentation\View\View.CadastroBase.pas' {frmCadastroBase},
  View.CadastroProdutor in 'Presentation\View\View.CadastroProdutor.pas' {frmProdutor},
  View.CadastroDistribuidor in 'Presentation\View\View.CadastroDistribuidor.pas' {frmDistribuidor},
  View.CadastroProduto in 'Presentation\View\View.CadastroProduto.pas' {frmProduto},
  View.CadastroCredito in 'Presentation\View\View.CadastroCredito.pas' {frmCredito},
  View.Negociacao in 'Presentation\View\View.Negociacao.pas' {frmNegociacao},
  View.ManutencaoNegociacao in 'Presentation\View\View.ManutencaoNegociacao.pas' {frmManutencaoNegociacao},
  View.Relatorio in 'Presentation\View\View.Relatorio.pas' {frmRelatorio},
  View.Dashboard in 'Presentation\View\View.Dashboard.pas' {frmDashboard};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
