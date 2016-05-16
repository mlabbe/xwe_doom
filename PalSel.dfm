object FormPal: TFormPal
  Left = 212
  Top = 103
  BorderStyle = bsDialog
  Caption = 'Select Palette'
  ClientHeight = 321
  ClientWidth = 193
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
  object lstPalette: TListBox
    Left = 8
    Top = 8
    Width = 177
    Height = 273
    ItemHeight = 13
    TabOrder = 0
  end
  object cmdOK: TButton
    Left = 8
    Top = 288
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 88
    Top = 288
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = cmdCancelClick
  end
end
