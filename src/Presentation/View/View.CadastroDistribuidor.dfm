inherited frmDistribuidor: TfrmDistribuidor
  Caption = 'Cadastro de Distribuidor'
  StyleElements = [seFont, seClient, seBorder]
  TextHeight = 15
  object pnlCabecalho: TPanel [0]
    Left = 0
    Top = 0
    Width = 755
    Height = 81
    Align = alTop
    Caption = 'Cadastro de Distribuidor'
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
    Width = 755
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
    Width = 755
    Height = 340
    Align = alClient
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 2
    object GroupBox1: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 747
      Height = 133
      Align = alTop
      Caption = 'Dados do Distribuidor'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object Label1: TLabel
        Left = 10
        Top = 67
        Width = 118
        Height = 15
        Caption = 'Nome do distribuidor'
      end
      object Label2: TLabel
        Left = 10
        Top = 19
        Width = 38
        Height = 15
        Caption = 'Codigo'
        Visible = False
      end
      object Label3: TLabel
        Left = 506
        Top = 67
        Width = 27
        Height = 15
        Caption = 'CNPJ'
      end
      object edtCodigo: TEdit
        Left = 10
        Top = 40
        Width = 101
        Height = 23
        ReadOnly = True
        TabOrder = 0
        Text = '0'
        Visible = False
      end
      object edtNome: TEdit
        Left = 10
        Top = 88
        Width = 487
        Height = 23
        TabOrder = 1
      end
      object edtCnpj: TMaskEdit
        Left = 506
        Top = 88
        Width = 160
        Height = 23
        TabOrder = 2
        Text = ''
      end
    end
    object GroupBox2: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 143
      Width = 747
      Height = 193
      Align = alClient
      Caption = 'Distribuidores Cadastrados'
      TabOrder = 1
      object grdDistribuidores: TStringGrid
        Left = 2
        Top = 17
        Width = 743
        Height = 174
        Align = alClient
        ColCount = 3
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
