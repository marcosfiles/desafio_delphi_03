inherited frmProdutor: TfrmProdutor
  Caption = 'Cadastro de Produtor'
  ClientHeight = 624
  ClientWidth = 1058
  StyleElements = [seFont, seClient, seBorder]
  ExplicitWidth = 1074
  ExplicitHeight = 663
  TextHeight = 15
  object pnlCabecalho: TPanel [0]
    Left = 0
    Top = 0
    Width = 1058
    Height = 81
    Align = alTop
    Caption = 'Cadastro de Produtor'
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
    Width = 1058
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
      Align = alLeft
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
    Width = 1058
    Height = 463
    Align = alClient
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 2
    object GroupBox1: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 1050
      Height = 133
      Align = alTop
      Caption = 'Dados do Produtor'
      Color = clBtnFace
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentColor = False
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      object Label1: TLabel
        AlignWithMargins = True
        Left = 10
        Top = 67
        Width = 104
        Height = 15
        Caption = 'Nome do produtor'
      end
      object Label2: TLabel
        AlignWithMargins = True
        Left = 10
        Top = 19
        Width = 38
        Height = 15
        Caption = 'Codigo'
        Visible = False
      end
      object Label3: TLabel
        AlignWithMargins = True
        Left = 506
        Top = 67
        Width = 52
        Height = 15
        Caption = 'CPF/CNPJ'
      end
      object Label4: TLabel
        AlignWithMargins = True
        Left = 650
        Top = 67
        Width = 30
        Height = 15
        Caption = 'Ativo'
      end
      object edtCodigo: TEdit
        AlignWithMargins = True
        Left = 10
        Top = 40
        Width = 101
        Height = 21
        ReadOnly = True
        TabOrder = 0
        Text = '0'
        Visible = False
      end
      object edtNome: TEdit
        AlignWithMargins = True
        Left = 10
        Top = 88
        Width = 487
        Height = 21
        TabOrder = 1
      end
      object edtCpfCnpj: TMaskEdit
        Left = 506
        Top = 88
        Width = 127
        Height = 21
        TabOrder = 2
        Text = ''
      end
      object chbAtivo: TCheckBox
        Left = 650
        Top = 90
        Width = 97
        Height = 17
        Caption = 'Sim'
        TabOrder = 3
      end
    end
    object GroupBox2: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 143
      Width = 700
      Height = 316
      Align = alLeft
      Caption = 'Produtores Cadastrados'
      TabOrder = 1
      object grdProdutores: TStringGrid
        Left = 2
        Top = 17
        Width = 696
        Height = 297
        Align = alClient
        ColCount = 4
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 0
      end
    end
    object GroupBox3: TGroupBox
      AlignWithMargins = True
      Left = 710
      Top = 143
      Width = 344
      Height = 316
      Align = alClient
      Caption = 'Limites de Credito do Produtor'
      TabOrder = 2
      object pnlLimiteCredito: TPanel
        Left = 2
        Top = 17
        Width = 340
        Height = 78
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label5: TLabel
          Left = 8
          Top = 8
          Width = 62
          Height = 15
          Caption = 'Distribuidor'
        end
        object Label6: TLabel
          Left = 204
          Top = 8
          Width = 89
          Height = 15
          Caption = 'Limite de credito'
        end
        object cmbDistribuidor: TComboBox
          Left = 8
          Top = 29
          Width = 188
          Height = 23
          Style = csDropDownList
          TabOrder = 0
        end
        object edtLimiteCredito: TEdit
          Left = 204
          Top = 29
          Width = 108
          Height = 23
          TabOrder = 1
          Text = '0,00'
        end
        object btnNovoLimite: TButton
          Left = 8
          Top = 55
          Width = 75
          Height = 21
          Caption = 'Novo'
          TabOrder = 2
          OnClick = btnNovoLimiteClick
        end
        object btnEditarLimite: TButton
          Left = 89
          Top = 55
          Width = 75
          Height = 21
          Caption = 'Editar'
          TabOrder = 3
          OnClick = btnEditarLimiteClick
        end
        object btnSalvarLimite: TButton
          Left = 170
          Top = 55
          Width = 75
          Height = 21
          Caption = 'Salvar'
          TabOrder = 4
          OnClick = btnSalvarLimiteClick
        end
        object btnCancelarLimite: TButton
          Left = 251
          Top = 55
          Width = 75
          Height = 21
          Caption = 'Cancelar'
          TabOrder = 5
          OnClick = btnCancelarLimiteClick
        end
      end
      object grdCreditos: TStringGrid
        Left = 2
        Top = 95
        Width = 340
        Height = 219
        Align = alClient
        ColCount = 4
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
        TabOrder = 1
      end
    end
  end
  inherited VirtualImageList1: TVirtualImageList
    Width = 24
    Height = 24
  end
end
