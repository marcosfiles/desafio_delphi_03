object frmManutencaoNegociacao: TfrmManutencaoNegociacao
  Left = 0
  Top = 0
  Caption = 'Consulta'
  ClientHeight = 681
  ClientWidth = 860
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object pnlCabecalho: TPanel
    Left = 0
    Top = 0
    Width = 860
    Height = 73
    Align = alTop
    Caption = 'Status das Negocia'#231#245'es'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 73
    Width = 860
    Height = 608
    Align = alClient
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object grpLocalizar: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 852
      Height = 78
      Align = alTop
      Caption = 'Localizar Negocia'#231#227'o'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object Label1: TLabel
        Left = 10
        Top = 22
        Width = 38
        Height = 15
        Caption = 'Codigo'
      end
      object edtCodigo: TEdit
        Left = 10
        Top = 43
        Width = 110
        Height = 23
        TabOrder = 0
      end
      object btnBuscar: TButton
        Left = 132
        Top = 40
        Width = 86
        Height = 29
        Caption = 'Buscar'
        TabOrder = 1
        OnClick = btnBuscarClick
      end
      object btnLimpar: TButton
        Left = 224
        Top = 40
        Width = 86
        Height = 29
        Caption = 'Limpar'
        TabOrder = 2
        OnClick = btnLimparClick
      end
    end
    object grpDados: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 88
      Width = 852
      Height = 206
      Align = alTop
      Caption = 'Dados da Negocia'#231#227'o'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      object Label2: TLabel
        Left = 10
        Top = 24
        Width = 50
        Height = 15
        Caption = 'Produtor'
      end
      object Label3: TLabel
        Left = 302
        Top = 24
        Width = 66
        Height = 15
        Caption = 'Distribuidor'
      end
      object Label4: TLabel
        Left = 594
        Top = 24
        Width = 35
        Height = 15
        Caption = 'Status'
      end
      object Label5: TLabel
        Left = 702
        Top = 24
        Width = 27
        Height = 15
        Caption = 'Total'
      end
      object Label6: TLabel
        Left = 10
        Top = 88
        Width = 76
        Height = 15
        Caption = 'Data cadastro'
      end
      object Label7: TLabel
        Left = 190
        Top = 88
        Width = 86
        Height = 15
        Caption = 'Data aprova'#231#227'o'
      end
      object Label8: TLabel
        Left = 370
        Top = 88
        Width = 83
        Height = 15
        Caption = 'Data conclus'#227'o'
      end
      object Label9: TLabel
        Left = 550
        Top = 88
        Width = 107
        Height = 15
        Caption = 'Data cancelamento'
      end
      object Label10: TLabel
        Left = 10
        Top = 140
        Width = 100
        Height = 15
        Caption = 'Cr'#233'dito disponivel'
      end
      object edtProdutor: TEdit
        Left = 10
        Top = 45
        Width = 282
        Height = 23
        ReadOnly = True
        TabOrder = 0
      end
      object edtDistribuidor: TEdit
        Left = 302
        Top = 45
        Width = 282
        Height = 23
        ReadOnly = True
        TabOrder = 1
      end
      object edtStatus: TEdit
        Left = 594
        Top = 45
        Width = 98
        Height = 23
        ReadOnly = True
        TabOrder = 2
      end
      object edtTotal: TEdit
        Left = 702
        Top = 45
        Width = 132
        Height = 23
        ReadOnly = True
        TabOrder = 3
      end
      object edtDataCadastro: TEdit
        Left = 10
        Top = 109
        Width = 170
        Height = 23
        ReadOnly = True
        TabOrder = 4
      end
      object edtDataAprovacao: TEdit
        Left = 190
        Top = 109
        Width = 170
        Height = 23
        ReadOnly = True
        TabOrder = 5
      end
      object edtDataConclusao: TEdit
        Left = 370
        Top = 109
        Width = 170
        Height = 23
        ReadOnly = True
        TabOrder = 6
      end
      object edtDataCancelamento: TEdit
        Left = 550
        Top = 109
        Width = 170
        Height = 23
        ReadOnly = True
        TabOrder = 7
      end
      object edtCreditoDisponivel: TEdit
        Left = 10
        Top = 161
        Width = 170
        Height = 23
        ReadOnly = True
        TabOrder = 8
      end
    end
    object grpAcoes: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 300
      Width = 852
      Height = 72
      Align = alTop
      Caption = 'Acoes'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      object btnAprovar: TButton
        Left = 10
        Top = 28
        Width = 100
        Height = 29
        Caption = 'Aprovar'
        TabOrder = 0
        OnClick = btnAprovarClick
      end
      object btnConcluir: TButton
        Left = 120
        Top = 28
        Width = 100
        Height = 29
        Caption = 'Concluir'
        TabOrder = 1
        OnClick = btnConcluirClick
      end
      object btnCancelarNegociacao: TButton
        Left = 230
        Top = 28
        Width = 100
        Height = 29
        Caption = 'Cancelar'
        TabOrder = 2
        OnClick = btnCancelarNegociacaoClick
      end
    end
    object grpItens: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 378
      Width = 852
      Height = 134
      Align = alTop
      Caption = 'Itens da Negocia'#231#227'o'
      TabOrder = 3
      object grdItens: TStringGrid
        Left = 2
        Top = 17
        Width = 848
        Height = 115
        Align = alClient
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 0
      end
    end
    object grpNegociacoes: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 518
      Width = 852
      Height = 86
      Align = alClient
      Caption = 'Negocia'#231#245'es Cadastradas'
      TabOrder = 4
      object grdNegociacoes: TStringGrid
        Left = 2
        Top = 17
        Width = 848
        Height = 67
        Align = alClient
        ColCount = 6
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 0
      end
    end
  end
end
