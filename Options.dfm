object FormOptions: TFormOptions
  Left = 439
  Top = 348
  BorderStyle = bsDialog
  Caption = 'Options'
  ClientHeight = 281
  ClientWidth = 393
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object cmdOK: TButton
    Left = 230
    Top = 250
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 310
    Top = 250
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = cmdCancelClick
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 377
    Height = 233
    ActivePage = TabSheet1
    MultiLine = True
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = '&General'
      object Label1: TLabel
        Left = 16
        Top = 147
        Width = 89
        Height = 13
        Caption = '&Temporary Folder:'
      end
      object chkOpenLast: TCheckBox
        Left = 16
        Top = 16
        Width = 337
        Height = 17
        Caption = '&Reopen last file on startup'
        TabOrder = 0
      end
      object chkOnlyOneBackup: TCheckBox
        Left = 16
        Top = 64
        Width = 337
        Height = 17
        Caption = '&Keep only one backup file'
        TabOrder = 2
      end
      object EditTempFolder: TEdit
        Left = 112
        Top = 144
        Width = 193
        Height = 21
        TabOrder = 5
      end
      object chkAutoCleanUp: TCheckBox
        Left = 16
        Top = 112
        Width = 337
        Height = 17
        Caption = '&Perform Clean Up on exit'
        TabOrder = 4
      end
      object chkDisableUndo: TCheckBox
        Left = 16
        Top = 88
        Width = 337
        Height = 17
        Caption = 'Disable &Undo (Better performance on large files)'
        TabOrder = 3
      end
      object chkAutoBackup: TCheckBox
        Left = 16
        Top = 40
        Width = 337
        Height = 17
        Caption = 'Automatically create a backup file when a WAD file is opened'
        TabOrder = 1
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Entry List'
      ImageIndex = 1
      object chkShowFullPath: TCheckBox
        Left = 16
        Top = 88
        Width = 337
        Height = 17
        Caption = '&Show full pathnames in entry list'
        TabOrder = 3
      end
      object chkShowSize: TCheckBox
        Left = 16
        Top = 40
        Width = 337
        Height = 17
        Caption = 'Show "Size" column'
        TabOrder = 1
        OnClick = chkShowSizeClick
      end
      object chkShowPosition: TCheckBox
        Left = 16
        Top = 64
        Width = 337
        Height = 17
        Caption = 'Show "Position" column'
        TabOrder = 2
      end
      object chkAutoPlaySounds: TCheckBox
        Left = 16
        Top = 16
        Width = 337
        Height = 17
        Caption = '&Auto play sounds'
        TabOrder = 0
      end
      object chkCutCopy: TCheckBox
        Left = 16
        Top = 112
        Width = 337
        Height = 17
        Caption = '&Cut and Copy commands empty clipboard first'
        TabOrder = 4
      end
      object chkDontAutoCapitalize: TCheckBox
        Left = 16
        Top = 136
        Width = 337
        Height = 17
        Caption = '&Don'#39't auto capitalize lump names'
        TabOrder = 5
      end
    end
    object TabSheet3: TTabSheet
      Caption = '&Special'
      ImageIndex = 2
      object chkRawPNG: TCheckBox
        Left = 16
        Top = 40
        Width = 337
        Height = 17
        Caption = 'Always load PNG files as Raw data'
        TabOrder = 0
      end
      object chkPreviewMaps: TCheckBox
        Left = 16
        Top = 16
        Width = 337
        Height = 17
        Caption = 'Open maps in pre&view mode first'
        TabOrder = 1
      end
      object chkAutoApplyOffset: TCheckBox
        Left = 16
        Top = 64
        Width = 337
        Height = 17
        Caption = 'Auto apply image offset changes'
        TabOrder = 2
      end
    end
    object TabSheet4: TTabSheet
      Caption = '&File types'
      ImageIndex = 3
      object Label2: TLabel
        Left = 32
        Top = 88
        Width = 329
        Height = 50
        AutoSize = False
        Caption = 
          'ART, B16, BLO, BND, BYT, CAN, CPS, CRF, DAS, DTI, DTX, GLB, GOB,' +
          ' GR, GRP, HOG, LAB, LFD, MTI, MTO, NWX, PAL, PIG, POD, PPM, RBX,' +
          ' REZ, RFF, RID, SNI, TLK, TR, UAX, UMX, UTX, XPR'
        WordWrap = True
      end
      object radFileTypes0: TRadioButton
        Left = 16
        Top = 16
        Width = 289
        Height = 17
        Caption = 'No file associations'
        TabOrder = 0
      end
      object radFileTypes1: TRadioButton
        Left = 16
        Top = 40
        Width = 289
        Height = 17
        Caption = 'WAD files only'
        TabOrder = 1
      end
      object radFileTypes2: TRadioButton
        Left = 16
        Top = 64
        Width = 289
        Height = 17
        Caption = 'WAD files and common game data file extensions'
        TabOrder = 2
      end
      object radFileTypes3: TRadioButton
        Left = 16
        Top = 136
        Width = 289
        Height = 17
        Caption = 'All extensions supported by XWE'
        TabOrder = 3
      end
    end
  end
end
