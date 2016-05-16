object FormMain: TFormMain
  Left = 197
  Top = 103
  Width = 401
  Height = 180
  Caption = 'WadAuthor "WCF" File to XWE Converter'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PanelMain: TPanel
    Left = 8
    Top = 8
    Width = 377
    Height = 137
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 73
      Height = 13
      AutoSize = False
      Caption = '&Source File(s):'
    end
    object Label2: TLabel
      Left = 8
      Top = 56
      Width = 113
      Height = 17
      AutoSize = False
      Caption = '&Destination Folder:'
    end
    object txtIn: TEdit
      Left = 8
      Top = 24
      Width = 280
      Height = 21
      TabOrder = 0
      Text = 'txtIn'
    end
    object txtOut: TEdit
      Left = 8
      Top = 72
      Width = 280
      Height = 21
      TabOrder = 1
      Text = 'txtOut'
    end
    object cmdStart: TButton
      Left = 8
      Top = 104
      Width = 75
      Height = 23
      Caption = '&Convert Now'
      Default = True
      TabOrder = 2
      OnClick = cmdStartClick
    end
    object cmdBrowse1: TButton
      Left = 294
      Top = 24
      Width = 75
      Height = 23
      Caption = '&Browse'
      TabOrder = 3
      OnClick = cmdBrowse1Click
    end
    object cmdBrowse2: TButton
      Left = 294
      Top = 72
      Width = 75
      Height = 23
      Caption = 'B&rowse'
      TabOrder = 4
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 304
  end
end
