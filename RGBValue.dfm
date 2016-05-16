object FormRGBValue: TFormRGBValue
  Left = 391
  Top = 322
  BorderStyle = bsDialog
  Caption = 'RGB Value'
  ClientHeight = 369
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
  object cmdOK: TButton
    Left = 8
    Top = 336
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 88
    Top = 336
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = cmdCancelClick
  end
  object PanelStartColor: TPanel
    Left = 8
    Top = 8
    Width = 393
    Height = 105
    TabOrder = 2
    object LabelStartR: TLabel
      Left = 8
      Top = 9
      Width = 40
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'R Value'
    end
    object LabelStartG: TLabel
      Left = 8
      Top = 33
      Width = 40
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'G Value'
    end
    object LabelStartB: TLabel
      Left = 8
      Top = 57
      Width = 40
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'B Value'
    end
    object LabelStartHex: TLabel
      Left = 8
      Top = 81
      Width = 40
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Hex'
    end
    object tbStartR: TTrackBar
      Left = 129
      Top = 6
      Width = 256
      Height = 21
      Max = 255
      Orientation = trHorizontal
      PageSize = 16
      Frequency = 16
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 4
      ThumbLength = 15
      TickMarks = tmBottomRight
      TickStyle = tsAuto
      OnChange = tbChange
    end
    object EditStartR: TEdit
      Left = 56
      Top = 6
      Width = 75
      Height = 21
      TabOrder = 0
      OnKeyPress = EditStartRKeyPress
      OnKeyUp = EditKeyUp
    end
    object EditStartG: TEdit
      Left = 56
      Top = 30
      Width = 75
      Height = 21
      TabOrder = 1
      OnKeyPress = EditStartGKeyPress
      OnKeyUp = EditKeyUp
    end
    object tbStartG: TTrackBar
      Left = 129
      Top = 30
      Width = 256
      Height = 21
      Max = 255
      Orientation = trHorizontal
      PageSize = 16
      Frequency = 16
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 5
      ThumbLength = 15
      TickMarks = tmBottomRight
      TickStyle = tsAuto
      OnChange = tbChange
    end
    object EditStartB: TEdit
      Left = 56
      Top = 54
      Width = 75
      Height = 21
      TabOrder = 2
      OnKeyUp = EditKeyUp
    end
    object tbStartB: TTrackBar
      Left = 129
      Top = 54
      Width = 256
      Height = 21
      Max = 255
      Orientation = trHorizontal
      PageSize = 16
      Frequency = 16
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 6
      ThumbLength = 15
      TickMarks = tmBottomRight
      TickStyle = tsAuto
      OnChange = tbChange
    end
    object EditStartHex: TEdit
      Left = 56
      Top = 78
      Width = 75
      Height = 21
      TabOrder = 3
      OnKeyPress = EditStartHexKeyPress
      OnKeyUp = EditStartHexKeyUp
    end
  end
  object PanelEndColor: TPanel
    Left = 8
    Top = 120
    Width = 393
    Height = 105
    TabOrder = 3
    object LabelEndR: TLabel
      Left = 8
      Top = 9
      Width = 40
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'R Value'
    end
    object LabelEndG: TLabel
      Left = 8
      Top = 33
      Width = 40
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'G Value'
    end
    object LabelEndB: TLabel
      Left = 8
      Top = 57
      Width = 40
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'B Value'
    end
    object LabelEndHex: TLabel
      Left = 8
      Top = 81
      Width = 40
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Hex'
    end
    object tbEndR: TTrackBar
      Left = 129
      Top = 6
      Width = 256
      Height = 21
      Max = 255
      Orientation = trHorizontal
      PageSize = 16
      Frequency = 16
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 4
      ThumbLength = 15
      TickMarks = tmBottomRight
      TickStyle = tsAuto
      OnChange = tbChange
    end
    object EditEndR: TEdit
      Left = 56
      Top = 6
      Width = 75
      Height = 21
      TabOrder = 0
      OnKeyPress = EditStartRKeyPress
      OnKeyUp = EditKeyUp
    end
    object EditEndG: TEdit
      Left = 56
      Top = 30
      Width = 75
      Height = 21
      TabOrder = 1
      OnKeyPress = EditStartGKeyPress
      OnKeyUp = EditKeyUp
    end
    object tbEndG: TTrackBar
      Left = 129
      Top = 30
      Width = 256
      Height = 21
      Max = 255
      Orientation = trHorizontal
      PageSize = 16
      Frequency = 16
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 5
      ThumbLength = 15
      TickMarks = tmBottomRight
      TickStyle = tsAuto
      OnChange = tbChange
    end
    object EditEndB: TEdit
      Left = 56
      Top = 54
      Width = 75
      Height = 21
      TabOrder = 2
      OnKeyUp = EditKeyUp
    end
    object tbEndB: TTrackBar
      Left = 129
      Top = 54
      Width = 256
      Height = 21
      Max = 255
      Orientation = trHorizontal
      PageSize = 16
      Frequency = 16
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 6
      ThumbLength = 15
      TickMarks = tmBottomRight
      TickStyle = tsAuto
      OnChange = tbChange
    end
    object EditEndHex: TEdit
      Left = 56
      Top = 78
      Width = 75
      Height = 21
      TabOrder = 3
      OnKeyPress = EditStartHexKeyPress
      OnKeyUp = EditEndHexKeyUp
    end
  end
  object PanelPreview: TPanel
    Left = 8
    Top = 232
    Width = 393
    Height = 97
    TabOrder = 4
    object ImagePreview: TImage
      Left = 8
      Top = 8
      Width = 377
      Height = 81
    end
  end
end
