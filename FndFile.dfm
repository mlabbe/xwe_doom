object FormFndFile: TFormFndFile
  Left = 607
  Top = 443
  BorderStyle = bsDialog
  Caption = 'File Location'
  ClientHeight = 169
  ClientWidth = 409
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
  object Label1: TLabel
    Left = 16
    Top = 59
    Width = 57
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Description'
  end
  object Label2: TLabel
    Left = 16
    Top = 83
    Width = 57
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Path'
  end
  object Label3: TLabel
    Left = 16
    Top = 107
    Width = 57
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'File Name'
  end
  object lblMessage: TLabel
    Left = 16
    Top = 16
    Width = 377
    Height = 33
    AutoSize = False
    WordWrap = True
  end
  object EditDescription: TEdit
    Left = 78
    Top = 56
    Width = 315
    Height = 21
    TabOrder = 0
  end
  object EditPath: TEdit
    Left = 78
    Top = 80
    Width = 315
    Height = 21
    TabOrder = 1
  end
  object EditFileName: TEdit
    Left = 78
    Top = 104
    Width = 315
    Height = 21
    TabOrder = 2
  end
  object cmdOK: TButton
    Left = 238
    Top = 130
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    TabOrder = 4
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 318
    Top = 130
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = cmdCancelClick
  end
  object cmdBrowse: TButton
    Left = 78
    Top = 130
    Width = 75
    Height = 23
    Caption = 'Browse...'
    TabOrder = 3
    OnClick = cmdBrowseClick
  end
  object cmdFindIt: TButton
    Left = 158
    Top = 130
    Width = 75
    Height = 23
    Caption = 'Find It!'
    TabOrder = 6
    OnClick = cmdFindItClick
  end
  object OpenDialog1: TOpenDialog
    Left = 360
    Top = 48
  end
end
