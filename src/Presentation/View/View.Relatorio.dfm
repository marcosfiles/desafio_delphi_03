object frmRelatorio: TfrmRelatorio
  Left = 0
  Top = 0
  Caption = 'Relatorio de Negociacoes'
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
    Caption = 'Relat'#243'rio de Negocia'#231#245'es'
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
    object grpFiltros: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 852
      Height = 86
      Align = alTop
      Caption = 'Filtros'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object Label1: TLabel
        Left = 10
        Top = 24
        Width = 50
        Height = 15
        Caption = 'Produtor'
      end
      object Label2: TLabel
        Left = 302
        Top = 24
        Width = 66
        Height = 15
        Caption = 'Distribuidor'
      end
      object cmbFiltroProdutor: TComboBox
        Left = 10
        Top = 45
        Width = 282
        Height = 23
        Style = csDropDownList
        TabOrder = 0
      end
      object cmbFiltroDistribuidor: TComboBox
        Left = 302
        Top = 45
        Width = 282
        Height = 23
        Style = csDropDownList
        TabOrder = 1
      end
      object btnFiltrar: TButton
        Left = 598
        Top = 42
        Width = 76
        Height = 29
        Caption = 'Filtrar'
        TabOrder = 2
        OnClick = btnFiltrarClick
      end
      object btnLimpar: TButton
        Left = 680
        Top = 42
        Width = 76
        Height = 29
        Caption = 'Limpar'
        TabOrder = 3
        OnClick = btnLimparClick
      end
      object btnImprimir: TButton
        Left = 762
        Top = 42
        Width = 76
        Height = 29
        Caption = 'Imprimir'
        TabOrder = 4
        OnClick = btnImprimirClick
      end
    end
    object grpNegociacoes: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 96
      Width = 852
      Height = 508
      Align = alClient
      Caption = 'Negociacoes filtradas'
      TabOrder = 1
      object grdNegociacoes: TStringGrid
        Left = 2
        Top = 17
        Width = 848
        Height = 489
        Align = alClient
        ColCount = 9
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 0
      end
    end
  end
  object dlgImpressao: TPrintDialog
    Left = 784
    Top = 24
  end
end
