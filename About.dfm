object FormAbout: TFormAbout
  Left = 259
  Top = 106
  BorderStyle = bsDialog
  Caption = 'About XWE'
  ClientHeight = 209
  ClientWidth = 313
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object l1: TLabel
    Left = 16
    Top = 8
    Width = 142
    Height = 13
    Caption = 'XWE - eXtendable Wad Editor'
  end
  object l2: TLabel
    Left = 16
    Top = 24
    Width = 99
    Height = 13
    Caption = 'Developed by Csabo'
  end
  object l3: TLabel
    Left = 16
    Top = 88
    Width = 281
    Height = 81
    AutoSize = False
  end
  object lv: TLabel
    Left = 168
    Top = 8
    Width = 89
    Height = 17
    AutoSize = False
  end
  object le: TLabel
    Left = 16
    Top = 48
    Width = 24
    Height = 13
    Caption = 'Email'
  end
  object lw: TLabel
    Left = 16
    Top = 64
    Width = 39
    Height = 13
    Caption = 'Website'
  end
  object cmdOK: TButton
    Left = 119
    Top = 181
    Width = 75
    Height = 23
    Caption = 'OK'
    TabOrder = 0
    OnClick = cmdOKClick
  end
  object editEmail: TEdit
    Left = 64
    Top = 48
    Width = 145
    Height = 15
    BorderStyle = bsNone
    Color = clBtnFace
    TabOrder = 1
    Text = 'wadedit@marchmail.com'
  end
  object editWebsite: TEdit
    Left = 64
    Top = 64
    Width = 145
    Height = 15
    BorderStyle = bsNone
    Color = clBtnFace
    TabOrder = 2
    Text = 'http://doomworld.com/xwe'
  end
end
