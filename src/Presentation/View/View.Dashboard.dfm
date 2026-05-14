object frmDashboard: TfrmDashboard
  Left = 0
  Top = 0
  Caption = 'Dashboard'
  ClientHeight = 539
  ClientWidth = 783
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
    Width = 783
    Height = 73
    Align = alTop
    Caption = 'Inicio'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object pnlResumo: TPanel
    Left = 0
    Top = 73
    Width = 783
    Height = 122
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    object pnlPendentes: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 8
      Width = 176
      Height = 106
      Margins.Left = 8
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alLeft
      TabOrder = 0
      object lblTituloPendentes: TLabel
        Left = 16
        Top = 14
        Width = 64
        Height = 17
        Caption = 'Pendentes'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTotalPendentes: TLabel
        Left = 16
        Top = 42
        Width = 19
        Height = 45
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -33
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlAprovadas: TPanel
      AlignWithMargins = True
      Left = 200
      Top = 8
      Width = 176
      Height = 106
      Margins.Left = 8
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alLeft
      TabOrder = 1
      object lblTituloAprovadas: TLabel
        Left = 16
        Top = 14
        Width = 65
        Height = 17
        Caption = 'Aprovadas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTotalAprovadas: TLabel
        Left = 16
        Top = 42
        Width = 19
        Height = 45
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -33
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlConcluidas: TPanel
      AlignWithMargins = True
      Left = 392
      Top = 8
      Width = 176
      Height = 106
      Margins.Left = 8
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alLeft
      TabOrder = 2
      object lblTituloConcluidas: TLabel
        Left = 16
        Top = 14
        Width = 67
        Height = 17
        Caption = 'Concluidas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTotalConcluidas: TLabel
        Left = 16
        Top = 42
        Width = 19
        Height = 45
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -33
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCanceladas: TPanel
      AlignWithMargins = True
      Left = 584
      Top = 8
      Width = 176
      Height = 106
      Margins.Left = 8
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alLeft
      TabOrder = 3
      object lblTituloCanceladas: TLabel
        Left = 16
        Top = 14
        Width = 68
        Height = 17
        Caption = 'Canceladas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTotalCanceladas: TLabel
        Left = 16
        Top = 42
        Width = 19
        Height = 45
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -33
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object grpNegociacoes: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 198
    Width = 777
    Height = 338
    Align = alClient
    Caption = 'Negocia'#231#245'es'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    object grdNegociacoes: TStringGrid
      Left = 2
      Top = 17
      Width = 773
      Height = 319
      Align = alClient
      ColCount = 6
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      TabOrder = 0
    end
  end
end
