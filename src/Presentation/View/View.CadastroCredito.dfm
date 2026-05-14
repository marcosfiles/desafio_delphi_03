inherited frmCredito: TfrmCredito
  Caption = 'Limites de Credito'
  StyleElements = [seFont, seClient, seBorder]
  TextHeight = 15
  object pnlCabecalho: TPanel [0]
    Left = 0
    Top = 0
    Width = 755
    Height = 81
    Align = alTop
    Caption = 'Limites de Credito'
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
      Caption = 'Dados do Limite de Credito'
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
        Left = 330
        Top = 67
        Width = 66
        Height = 15
        Caption = 'Distribuidor'
      end
      object Label4: TLabel
        Left = 594
        Top = 67
        Width = 95
        Height = 15
        Caption = 'Limite de credito'
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
      object cmbProdutor: TComboBox
        Left = 10
        Top = 88
        Width = 311
        Height = 23
        Style = csDropDownList
        TabOrder = 1
      end
      object cmbDistribuidor: TComboBox
        Left = 330
        Top = 88
        Width = 255
        Height = 23
        Style = csDropDownList
        TabOrder = 2
      end
      object edtLimiteCredito: TEdit
        Left = 594
        Top = 88
        Width = 140
        Height = 23
        TabOrder = 3
        Text = '0,00'
      end
    end
    object GroupBox2: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 143
      Width = 747
      Height = 193
      Align = alClient
      Caption = 'Limites Cadastrados'
      TabOrder = 1
      object grdCreditos: TStringGrid
        Left = 2
        Top = 17
        Width = 743
        Height = 174
        Align = alClient
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
