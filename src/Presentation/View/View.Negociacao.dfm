inherited frmNegociacao: TfrmNegociacao
  Caption = 'Manutencao de Negociacao'
  ClientHeight = 681
  ClientWidth = 820
  StyleElements = [seFont, seClient, seBorder]
  ExplicitWidth = 836
  ExplicitHeight = 720
  TextHeight = 15
  object pnlCabecalho: TPanel [0]
    Left = 0
    Top = 0
    Width = 820
    Height = 81
    Align = alTop
    Caption = 'Manutencao de Negocia'#231#227'o'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object pnlBotoes: TFlowPanel [1]
    Left = 0
    Top = 81
    Width = 820
    Height = 80
    Align = alTop
    Caption = 'pnlBotoes'
    ShowCaption = False
    TabOrder = 1
    object btnNovo: TSpeedButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 72
      Height = 72
      Cursor = crHandPoint
      Caption = 'Novo'
      ImageIndex = 0
      ImageName = 'plus'
      Images = VirtualImageList1
      Layout = blGlyphTop
      StyleName = 'Windows'
      OnClick = btnNovoClick
    end
    object btnEditar: TSpeedButton
      AlignWithMargins = True
      Left = 82
      Top = 4
      Width = 72
      Height = 72
      Cursor = crHandPoint
      Caption = 'Editar'
      ImageIndex = 1
      ImageName = 'edit'
      Images = VirtualImageList1
      Layout = blGlyphTop
      StyleName = 'Windows'
      OnClick = btnEditarClick
    end
    object btnSalvar: TSpeedButton
      AlignWithMargins = True
      Left = 160
      Top = 4
      Width = 72
      Height = 72
      Cursor = crHandPoint
      Caption = 'Salvar'
      ImageIndex = 2
      ImageName = 'diskette'
      Images = VirtualImageList1
      Layout = blGlyphTop
      StyleName = 'Windows'
      OnClick = btnSalvarClick
    end
    object btnCancelar: TSpeedButton
      AlignWithMargins = True
      Left = 238
      Top = 4
      Width = 72
      Height = 72
      Cursor = crHandPoint
      Caption = 'Cancelar'
      ImageIndex = 3
      ImageName = 'cancel'
      Images = VirtualImageList1
      Layout = blGlyphTop
      StyleName = 'Windows'
      OnClick = btnCancelarClick
    end
  end
  object Panel1: TPanel [2]
    Left = 0
    Top = 161
    Width = 820
    Height = 520
    Align = alClient
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 2
    object GroupBox1: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 812
      Height = 133
      Align = alTop
      Caption = 'Dados da Negocia'#231#227'o'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object Label1: TLabel
        Left = 10
        Top = 19
        Width = 38
        Height = 15
        Caption = 'Codigo'
        Visible = False
      end
      object Label2: TLabel
        Left = 10
        Top = 67
        Width = 50
        Height = 15
        Caption = 'Produtor'
      end
      object Label3: TLabel
        Left = 284
        Top = 67
        Width = 66
        Height = 15
        Caption = 'Distribuidor'
      end
      object Label4: TLabel
        Left = 548
        Top = 67
        Width = 35
        Height = 15
        Caption = 'Status'
      end
      object Label5: TLabel
        Left = 650
        Top = 67
        Width = 27
        Height = 15
        Caption = 'Total'
      end
      object edtCodigo: TEdit
        Left = 10
        Top = 40
        Width = 101
        Height = 23
        TabOrder = 0
        Text = '0'
        Visible = False
      end
      object cmbProdutor: TComboBox
        Left = 10
        Top = 88
        Width = 264
        Height = 23
        Style = csDropDownList
        TabOrder = 1
      end
      object cmbDistribuidor: TComboBox
        Left = 284
        Top = 88
        Width = 254
        Height = 23
        Style = csDropDownList
        TabOrder = 2
      end
      object edtStatus: TEdit
        Left = 548
        Top = 88
        Width = 92
        Height = 23
        ReadOnly = True
        TabOrder = 3
        Text = 'PENDENTE'
      end
      object edtTotal: TEdit
        Left = 650
        Top = 88
        Width = 145
        Height = 23
        ReadOnly = True
        TabOrder = 4
        Text = 'R$ 0,00'
      end
    end
    object GroupBox2: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 143
      Width = 812
      Height = 94
      Align = alTop
      Caption = 'Item da Negocia'#231#227'o'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      object Label6: TLabel
        Left = 10
        Top = 20
        Width = 45
        Height = 15
        Caption = 'Produto'
      end
      object Label7: TLabel
        Left = 346
        Top = 20
        Width = 64
        Height = 15
        Caption = 'Quantidade'
      end
      object Label8: TLabel
        Left = 466
        Top = 20
        Width = 78
        Height = 15
        Caption = 'Preco unit'#225'rio'
      end
      object cmbProduto: TComboBox
        Left = 10
        Top = 41
        Width = 326
        Height = 23
        Style = csDropDownList
        TabOrder = 0
        OnChange = cmbProdutoChange
      end
      object edtQuantidade: TEdit
        Left = 346
        Top = 41
        Width = 110
        Height = 23
        TabOrder = 1
        Text = '0,000'
      end
      object edtPrecoUnitario: TEdit
        Left = 466
        Top = 41
        Width = 120
        Height = 23
        TabOrder = 2
        Text = '0,00'
      end
      object btnAdicionarItem: TButton
        Left = 600
        Top = 38
        Width = 91
        Height = 29
        Caption = 'Adicionar'
        TabOrder = 3
        OnClick = btnAdicionarItemClick
      end
      object btnRemoverItem: TButton
        Left = 700
        Top = 38
        Width = 91
        Height = 29
        Caption = 'Remover'
        TabOrder = 4
        OnClick = btnRemoverItemClick
      end
    end
    object GroupBox3: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 243
      Width = 812
      Height = 153
      Align = alTop
      Caption = 'Itens da Negocia'#231#227'o'
      TabOrder = 2
      object grdItens: TStringGrid
        Left = 2
        Top = 17
        Width = 808
        Height = 134
        Align = alClient
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 0
      end
    end
    object GroupBox4: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 402
      Width = 812
      Height = 114
      Align = alClient
      Caption = 'Negocia'#231#245'es Cadastradas'
      TabOrder = 3
      object grdNegociacoes: TStringGrid
        Left = 2
        Top = 17
        Width = 808
        Height = 95
        Align = alClient
        ColCount = 6
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 0
      end
    end
  end
  inherited VirtualImageList1: TVirtualImageList
    Width = 24
    Height = 24
  end
end
