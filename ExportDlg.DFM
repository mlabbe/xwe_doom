object FormExport: TFormExport
  Left = 195
  Top = 103
  Width = 305
  Height = 204
  Caption = 'Export'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object radFolder1: TRadioButton
    Left = 8
    Top = 8
    Width = 129
    Height = 17
    Caption = 'All into same folder'
    TabOrder = 0
  end
  object radFolder2: TRadioButton
    Left = 8
    Top = 32
    Width = 129
    Height = 17
    Caption = 'Ask me for each file'
    TabOrder = 1
  end
end
