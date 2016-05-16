object FormMain: TFormMain
  Left = 315
  Top = 324
  Width = 725
  Height = 453
  HelpContext = 1000
  Caption = 'eXtendable Wad Editor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object BrowserSplitter: TSplitter
    Left = 217
    Top = 0
    Width = 6
    Height = 341
    Cursor = crHSplit
    AutoSnap = False
    ResizeStyle = rsLine
    OnMoved = BrowserSplitterMoved
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 16
    Height = 13
    AutoSize = False
    Caption = 'R:'
  end
  object Label20: TLabel
    Left = 8
    Top = 32
    Width = 16
    Height = 13
    AutoSize = False
    Caption = 'G:'
  end
  object Label21: TLabel
    Left = 8
    Top = 56
    Width = 16
    Height = 13
    AutoSize = False
    Caption = 'B:'
  end
  object PanelGrid: TPanel
    Left = 264
    Top = 40
    Width = 297
    Height = 257
    BorderWidth = 6
    TabOrder = 5
    Visible = False
    object GridEditorTotal: TLabel
      Left = 8
      Top = 235
      Width = 145
      Height = 13
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = '...'
    end
    object GridMain: TStringGrid
      Left = 8
      Top = 32
      Width = 279
      Height = 201
      Anchors = [akLeft, akTop, akRight, akBottom]
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing, goAlwaysShowEditor]
      TabOrder = 0
      OnKeyDown = GridMainKeyDown
      OnKeyPress = GridMainKeyPress
      OnSelectCell = GridMainSelectCell
      RowHeights = (
        24
        24
        24
        23
        24)
    end
    object GridEditHeader: TEdit
      Left = 8
      Top = 8
      Width = 169
      Height = 21
      TabOrder = 1
    end
  end
  object PanelTextScreen: TPanel
    Left = 328
    Top = 104
    Width = 297
    Height = 257
    TabOrder = 3
    Visible = False
    object ImageTextScreen: TImage
      Left = 8
      Top = 64
      Width = 281
      Height = 185
      Anchors = [akLeft, akTop, akRight, akBottom]
      OnMouseDown = ImageTextScreenMouseDown
      OnMouseMove = ImageTextScreenMouseMove
    end
    object ImageTextScreenColors: TImage
      Left = 8
      Top = 32
      Width = 281
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      OnMouseDown = ImageTextScreenColorsMouseDown
    end
    object chkTextScreenGrid: TCheckBox
      Left = 8
      Top = 8
      Width = 49
      Height = 17
      Caption = '&Grid'
      TabOrder = 0
      OnClick = chkTextScreenGridClick
    end
    object TextScreenEdit: TEdit
      Left = 64
      Top = 6
      Width = 81
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnKeyDown = TextScreenEditKeyDown
      OnKeyPress = TextScreenEditKeyPress
    end
  end
  object PanelBrowse: TPanel
    Left = 0
    Top = 0
    Width = 217
    Height = 341
    Align = alLeft
    DockSite = True
    TabOrder = 0
    object LabelQuickFind: TLabel
      Left = 8
      Top = 8
      Width = 50
      Height = 13
      Caption = '&QuickFind:'
      FocusControl = EditQuickFind
    end
    object EditQuickFind: TEdit
      Left = 8
      Top = 24
      Width = 200
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      OnChange = EditQuickFindChange
      OnKeyDown = EditQuickFindKeyDown
      OnKeyPress = EditQuickFindKeyPress
    end
    object ListWad: TListView
      Left = 8
      Top = 48
      Width = 200
      Height = 303
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <>
      ReadOnly = True
      PopupMenu = PopupListWad
      SmallImages = ilEntryType
      TabOrder = 0
      OnColumnClick = ListWadColumnClick
      OnCustomDrawItem = ListWadCustomDrawItem
      OnDblClick = ListWadDblClick
      OnDragDrop = ListWadDragDrop
      OnDragOver = ListWadDragOver
      OnKeyDown = ListWadKeyDown
      OnKeyPress = ListWadKeyPress
      OnMouseDown = ListWadMouseDown
      OnMouseUp = ListWadMouseUp
      OnSelectItem = ListWadSelectItem
    end
    object chkBrowsePanel: TCheckBox
      Left = 195
      Top = 7
      Width = 16
      Height = 17
      Anchors = [akTop, akRight]
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = chkBrowsePanelClick
    end
  end
  object StatusBrowse: TStatusBar
    Left = 0
    Top = 341
    Width = 717
    Height = 19
    Panels = <>
    SimplePanel = False
    SizeGrip = False
  end
  object PanelPatchNames: TPanel
    Left = 288
    Top = 64
    Width = 297
    Height = 257
    BorderWidth = 6
    TabOrder = 8
    Visible = False
    object PatchNamesList: TMemo
      Left = 7
      Top = 32
      Width = 283
      Height = 218
      Align = alBottom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Fixedsys'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
      OnChange = PatchNamesListChange
    end
    object PatchNamesCount: TEdit
      Left = 8
      Top = 8
      Width = 281
      Height = 21
      TabOrder = 1
    end
  end
  object PanelColorMap: TPanel
    Left = 320
    Top = 248
    Width = 169
    Height = 105
    BorderWidth = 6
    TabOrder = 13
    Visible = False
    object ImageColorMap: TImage
      Left = 7
      Top = 7
      Width = 155
      Height = 91
      Align = alClient
    end
  end
  object PanelMus: TPanel
    Left = 296
    Top = 72
    Width = 297
    Height = 257
    BorderWidth = 6
    TabOrder = 10
    Visible = False
    object MusSplitter: TSplitter
      Left = 7
      Top = 89
      Width = 283
      Height = 6
      Cursor = crVSplit
      Align = alTop
    end
    object PanelMus1: TPanel
      Left = 7
      Top = 7
      Width = 283
      Height = 82
      Align = alTop
      BevelOuter = bvLowered
      BorderWidth = 4
      TabOrder = 0
      object MusMemoIns: TMemo
        Left = 5
        Top = 5
        Width = 273
        Height = 72
        Align = alClient
        Lines.Strings = (
          'MusMemoIns')
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object mpMusic: TMediaPlayer
        Left = 16
        Top = 16
        Width = 253
        Height = 30
        Visible = False
        TabOrder = 1
        OnNotify = mpMusicNotify
      end
    end
    object PanelMus2: TPanel
      Left = 7
      Top = 95
      Width = 283
      Height = 155
      Align = alClient
      BevelOuter = bvLowered
      BorderWidth = 4
      TabOrder = 1
      object MusGrid: TStringGrid
        Left = 5
        Top = 5
        Width = 273
        Height = 145
        Align = alClient
        ColCount = 3
        DefaultRowHeight = 18
        FixedCols = 0
        RowCount = 4
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
        TabOrder = 0
      end
    end
  end
  object tbFilter: TToolBar
    Left = 0
    Top = 360
    Width = 717
    Height = 29
    Align = alBottom
    ButtonHeight = 21
    ButtonWidth = 50
    EdgeBorders = [ebTop, ebBottom]
    ShowCaptions = True
    TabOrder = 14
    object tbFilterAll: TToolButton
      Left = 0
      Top = 2
      Caption = 'All'
      ImageIndex = 0
      OnClick = tbFilterAllClick
    end
    object tbFilterLumps: TToolButton
      Left = 50
      Top = 2
      Hint = ' '
      Caption = 'Lumps'
      ImageIndex = 8
      OnClick = tbFilterClick
    end
    object tbFilterGfx: TToolButton
      Left = 100
      Top = 2
      Hint = 'GFX'
      Caption = 'Gfx'
      ImageIndex = 8
      OnClick = tbFilterClick
    end
    object tbFilterSprites: TToolButton
      Left = 150
      Top = 2
      Hint = 'SPRITE'
      Caption = 'Sprites'
      ImageIndex = 1
      OnClick = tbFilterClick
    end
    object tbFilterSounds: TToolButton
      Left = 200
      Top = 2
      Hint = 'WAVESOUND'
      Caption = 'Sounds'
      ImageIndex = 2
      OnClick = tbFilterClick
    end
    object tbFilterMusic: TToolButton
      Left = 250
      Top = 2
      Hint = 'MUS'
      Caption = 'Music'
      ImageIndex = 3
      OnClick = tbFilterClick
    end
    object tbFilterMaps: TToolButton
      Left = 300
      Top = 2
      Hint = 'MAP'
      Caption = 'Maps'
      ImageIndex = 4
      OnClick = tbFilterClick
    end
    object tbFilterTextures: TToolButton
      Left = 350
      Top = 2
      Hint = 'TEXTURE'
      Caption = 'Textures'
      ImageIndex = 5
      OnClick = tbFilterClick
    end
    object tbFilterPatches: TToolButton
      Left = 400
      Top = 2
      Hint = 'PATCH'
      Caption = 'Patches'
      ImageIndex = 6
      OnClick = tbFilterClick
    end
    object tbFilterFloors: TToolButton
      Left = 450
      Top = 2
      Hint = 'FLOOR'
      Caption = 'Floors'
      ImageIndex = 7
      OnClick = tbFilterClick
    end
  end
  object PanelWave: TPanel
    Left = 280
    Top = 56
    Width = 297
    Height = 257
    BorderWidth = 6
    TabOrder = 7
    Visible = False
    object PanelWaveImage: TImage
      Left = 8
      Top = 32
      Width = 279
      Height = 193
      Anchors = [akLeft, akTop, akRight, akBottom]
      OnMouseDown = PanelWaveImageMouseDown
      OnMouseMove = PanelWaveImageMouseMove
      OnMouseUp = PanelWaveImageMouseUp
    end
    object PanelWaveZoom: TLabel
      Left = 40
      Top = 11
      Width = 30
      Height = 13
      AutoSize = False
      Caption = 'Zoom:'
    end
    object WaveLabelSampleRate: TLabel
      Left = 176
      Top = 11
      Width = 70
      Height = 13
      AutoSize = False
      Caption = 'Sample Rate:'
    end
    object PanelWaveUpDownZoom: TUpDown
      Left = 137
      Top = 8
      Width = 34
      Height = 21
      Associate = PanelWaveEditZoom
      Min = 1
      Orientation = udHorizontal
      Position = 10
      TabOrder = 2
      Wrap = False
      OnClick = PanelWaveUpDownZoomClick
    end
    object PanelWaveEditZoom: TComboBox
      Left = 72
      Top = 8
      Width = 65
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      Text = '10'
    end
    object WaveScroll: TScrollBar
      Left = 8
      Top = 232
      Width = 281
      Height = 16
      Anchors = [akLeft, akRight, akBottom]
      PageSize = 0
      TabOrder = 4
      OnChange = WaveScrollChange
    end
    object WaveEditSampleRate: TEdit
      Left = 248
      Top = 8
      Width = 58
      Height = 21
      TabOrder = 3
      OnChange = WaveEditSampleRateChange
    end
    object WaveEdit: TEdit
      Left = 8
      Top = 8
      Width = 24
      Height = 21
      TabOrder = 0
      OnKeyDown = WaveEditKeyDown
      OnKeyPress = WaveEditKeyPress
    end
  end
  object PanelMap: TPanel
    Left = 256
    Top = 0
    Width = 570
    Height = 305
    BorderWidth = 6
    TabOrder = 9
    Visible = False
    object ImageMap: TImage
      Left = 7
      Top = 7
      Width = 474
      Height = 193
      Align = alClient
      IncrementalDisplay = True
      PopupMenu = PopupMap
      OnMouseDown = ImageMapMouseDown
      OnMouseMove = ImageMapMouseMove
      OnMouseUp = ImageMapMouseUp
    end
    object EditMapZoom: TEdit
      Left = 2
      Top = 2
      Width = 30
      Height = 16
      AutoSize = False
      TabOrder = 0
      OnKeyDown = EditMapZoomKeyDown
      OnKeyPress = EditMapZoomKeyPress
      OnKeyUp = EditMapZoomKeyUp
    end
    object MapListErrors: TListBox
      Left = 2
      Top = 18
      Width = 213
      Height = 97
      ItemHeight = 13
      TabOrder = 4
      Visible = False
      OnClick = MapListErrorsClick
    end
    object PanelMapVertex: TPanel
      Left = 32
      Top = 176
      Width = 65
      Height = 98
      TabOrder = 6
      Visible = False
    end
    object MapPanelList: TPanel
      Left = 128
      Top = 0
      Width = 169
      Height = 41
      TabOrder = 5
      Visible = False
      object MapListTypes: TListBox
        Left = 56
        Top = 8
        Width = 41
        Height = 97
        ItemHeight = 16
        Style = lbOwnerDrawFixed
        TabOrder = 0
        OnDrawItem = MapListTypesDrawItem
      end
      object MapListClasses: TListBox
        Left = 8
        Top = 8
        Width = 41
        Height = 97
        ItemHeight = 16
        Style = lbOwnerDrawFixed
        TabOrder = 1
        OnClick = MapListClassesClick
        OnDrawItem = MapListClassesDrawItem
      end
      object MapListOK: TButton
        Left = 24
        Top = 8
        Width = 75
        Height = 23
        Caption = 'OK'
        TabOrder = 2
        OnClick = MapListOKClick
      end
      object MapListCancel: TButton
        Left = 80
        Top = 8
        Width = 75
        Height = 23
        Caption = 'Cancel'
        TabOrder = 3
        OnClick = MapListCancelClick
      end
    end
    object PanelMapWaded: TPanel
      Left = 481
      Top = 7
      Width = 82
      Height = 193
      Align = alRight
      TabOrder = 7
      object MapGridButton2: TSpeedButton
        Left = 16
        Top = 160
        Width = 65
        Height = 22
        GroupIndex = 2
        Visible = False
      end
      object MapModeThings: TSpeedButton
        Left = 8
        Top = 56
        Width = 65
        Height = 22
        GroupIndex = 1
        Caption = 'Things'
        OnClick = MapModeThingsClick
      end
      object MapModeLineDefs: TSpeedButton
        Left = 8
        Top = 32
        Width = 65
        Height = 22
        GroupIndex = 1
        Caption = 'LineDefs'
        OnClick = MapModeLineDefsClick
      end
      object MapModeAll: TSpeedButton
        Left = 8
        Top = 8
        Width = 65
        Height = 22
        GroupIndex = 1
        Caption = 'All'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = MapModeAllClick
      end
      object MapModeSectors: TSpeedButton
        Left = 8
        Top = 80
        Width = 65
        Height = 22
        GroupIndex = 1
        Caption = 'Sectors'
        OnClick = MapModeSectorsClick
      end
      object MapModeDraw: TSpeedButton
        Left = 8
        Top = 104
        Width = 65
        Height = 22
        GroupIndex = 1
        Down = True
        Caption = 'Draw'
        OnClick = MapModeDrawClick
      end
      object MapGridButton: TSpeedButton
        Left = 8
        Top = 152
        Width = 65
        Height = 22
        GroupIndex = 2
        Caption = 'Grid'
        OnClick = MapGridButtonClick
      end
    end
    object PanelMapThings: TPanel
      Left = 8
      Top = 192
      Width = 585
      Height = 98
      TabOrder = 2
      Visible = False
      object Label9: TLabel
        Left = 8
        Top = 50
        Width = 49
        Height = 17
        AutoSize = False
        Caption = 'Angle'
      end
      object LabelMapThingXYZ: TLabel
        Left = 8
        Top = 78
        Width = 49
        Height = 17
        AutoSize = False
        Caption = 'X, Y, Z'
      end
      object Label8: TLabel
        Left = 56
        Top = 6
        Width = 49
        Height = 17
        AutoSize = False
        Caption = 'Type'
      end
      object lblThing: TLabel
        Left = 8
        Top = 24
        Width = 172
        Height = 13
        AutoSize = False
        Caption = '...'
        Color = 11577504
        ParentColor = False
      end
      object MapImageThing: TImage
        Left = 187
        Top = 2
        Width = 94
        Height = 94
      end
      object MapEditThingAngle: TEdit
        Left = 56
        Top = 48
        Width = 41
        Height = 16
        AutoSize = False
        BorderStyle = bsNone
        Color = 11577504
        TabOrder = 3
        OnChange = MapEditThingAngleChange
        OnKeyPress = MapEditThingAngleKeyPress
      end
      object MapEditThingX: TEdit
        Left = 56
        Top = 76
        Width = 40
        Height = 16
        AutoSize = False
        BorderStyle = bsNone
        Color = 11577504
        TabOrder = 12
      end
      object MapEditThingY: TEdit
        Left = 98
        Top = 76
        Width = 40
        Height = 16
        AutoSize = False
        BorderStyle = bsNone
        Color = 11577504
        TabOrder = 13
      end
      object MapEditType: TEdit
        Left = 104
        Top = 4
        Width = 40
        Height = 16
        AutoSize = False
        BorderStyle = bsNone
        Color = 11577504
        TabOrder = 1
        OnChange = MapEditTypeChange
        OnKeyPress = MapEditTypeKeyPress
      end
      object MapEditThingFlags1: TCheckBox
        Left = 288
        Top = 8
        Width = 90
        Height = 17
        Caption = 'Level 1, 2'
        TabOrder = 15
      end
      object MapEditThingFlags2: TCheckBox
        Left = 288
        Top = 24
        Width = 90
        Height = 17
        Caption = 'Level 3'
        TabOrder = 16
      end
      object MapEditThingFlags3: TCheckBox
        Left = 288
        Top = 40
        Width = 90
        Height = 17
        Caption = 'Level 4, 5'
        TabOrder = 17
      end
      object MapEditThingFlags4: TCheckBox
        Left = 288
        Top = 56
        Width = 90
        Height = 17
        Caption = 'Deaf'
        TabOrder = 18
      end
      object MapEditThingFlags5: TCheckBox
        Left = 288
        Top = 72
        Width = 90
        Height = 17
        Caption = 'Multi/Dormant'
        TabOrder = 19
      end
      object MapThingsApply: TButton
        Left = 3
        Top = 2
        Width = 41
        Height = 18
        Caption = 'Apply'
        TabOrder = 0
        OnClick = MapThingsApplyClick
      end
      object MapEditThingFlags9: TCheckBox
        Left = 384
        Top = 49
        Width = 82
        Height = 17
        Caption = 'Single'
        TabOrder = 23
      end
      object MapEditThingFlags10: TCheckBox
        Left = 384
        Top = 64
        Width = 82
        Height = 17
        Caption = 'Cooperative'
        TabOrder = 24
      end
      object MapEditThingFlags8: TCheckBox
        Left = 384
        Top = 33
        Width = 82
        Height = 17
        Caption = 'Mage'
        TabOrder = 22
      end
      object MapEditThingFlags7: TCheckBox
        Left = 384
        Top = 18
        Width = 82
        Height = 17
        Caption = 'Cleric'
        TabOrder = 21
      end
      object MapEditThingFlags11: TCheckBox
        Left = 384
        Top = 80
        Width = 82
        Height = 17
        Caption = 'Deathmatch'
        TabOrder = 25
      end
      object MapEditThingZ: TEdit
        Left = 140
        Top = 76
        Width = 40
        Height = 16
        AutoSize = False
        BorderStyle = bsNone
        Color = 11577504
        TabOrder = 14
      end
      object MapEditThingFlags6: TCheckBox
        Left = 384
        Top = 2
        Width = 82
        Height = 17
        Caption = 'Fighter'
        TabOrder = 20
      end
      object MapPickThing: TBitBtn
        Left = 144
        Top = 4
        Width = 16
        Height = 16
        TabOrder = 2
        OnClick = MapPickThingClick
        Glyph.Data = {
          6A010000424D6A0100000000000036000000280000000E000000070000000100
          18000000000034010000120B0000120B00000000000000000000008080008080
          0080800000000080800080800080800080800080800080800000000080800080
          8000808000000080800080800080800000000000000080800080800080800080
          8000808000000000000000808000808000000080800080800080800000000000
          0000000000808000808000808000808000000000808000000000808000000080
          8000808000808000000000000000000000000000808000808000808000000000
          8080008080000000000000808000808000808000000000000000000000808000
          8080008080008080000000008080000000008080000000808000808000808000
          0000000000008080008080008080008080008080000000000000008080008080
          0000008080008080008080000000008080008080008080008080008080008080
          0000000080800080800080800000}
        Layout = blGlyphRight
        NumGlyphs = 2
      end
      object MapThingAngleRad090: TRadioButton
        Left = 136
        Top = 38
        Width = 14
        Height = 14
        TabOrder = 5
        OnClick = MapThingAngleRad090Click
      end
      object MapThingAngleRad000: TRadioButton
        Left = 164
        Top = 50
        Width = 14
        Height = 14
        TabOrder = 11
        OnClick = MapThingAngleRad000Click
      end
      object MapThingAngleRad270: TRadioButton
        Left = 136
        Top = 62
        Width = 14
        Height = 14
        TabOrder = 9
        OnClick = MapThingAngleRad270Click
      end
      object MapThingAngleRad180: TRadioButton
        Left = 108
        Top = 50
        Width = 19
        Height = 15
        TabOrder = 7
        OnClick = MapThingAngleRad180Click
      end
      object MapThingAngleRad045: TRadioButton
        Left = 150
        Top = 41
        Width = 14
        Height = 14
        TabOrder = 4
        OnClick = MapThingAngleRad045Click
      end
      object MapThingAngleRad135: TRadioButton
        Left = 122
        Top = 41
        Width = 14
        Height = 14
        TabOrder = 6
        OnClick = MapThingAngleRad135Click
      end
      object MapThingAngleRad225: TRadioButton
        Left = 122
        Top = 59
        Width = 14
        Height = 14
        TabOrder = 8
        OnClick = MapThingAngleRad225Click
      end
      object MapThingAngleRad315: TRadioButton
        Left = 150
        Top = 59
        Width = 14
        Height = 14
        TabOrder = 10
        OnClick = MapThingAngleRad315Click
      end
      object MapEditThingSpecial: TEdit
        Left = 472
        Top = 40
        Width = 40
        Height = 16
        BorderStyle = bsNone
        Color = 11577504
        TabOrder = 27
      end
      object MapEditThingArg1: TEdit
        Left = 472
        Top = 58
        Width = 28
        Height = 16
        BorderStyle = bsNone
        Color = 11577504
        TabOrder = 28
      end
      object MapEditThingArg2: TEdit
        Left = 504
        Top = 58
        Width = 28
        Height = 16
        BorderStyle = bsNone
        Color = 11577504
        TabOrder = 29
      end
      object MapEditThingArg3: TEdit
        Left = 536
        Top = 58
        Width = 28
        Height = 16
        BorderStyle = bsNone
        Color = 11577504
        TabOrder = 30
      end
      object MapEditThingArg4: TEdit
        Left = 472
        Top = 76
        Width = 28
        Height = 16
        BorderStyle = bsNone
        Color = 11577504
        TabOrder = 31
      end
      object MapEditThingArg5: TEdit
        Left = 504
        Top = 76
        Width = 28
        Height = 16
        BorderStyle = bsNone
        Color = 11577504
        TabOrder = 32
      end
      object MapEditThingTag: TEdit
        Left = 472
        Top = 16
        Width = 40
        Height = 16
        BorderStyle = bsNone
        Color = 11577504
        TabOrder = 26
      end
    end
    object PanelMapSectors: TPanel
      Left = 24
      Top = 166
      Width = 449
      Height = 98
      TabOrder = 3
      Visible = False
      object Label11: TLabel
        Left = 296
        Top = 34
        Width = 32
        Height = 17
        AutoSize = False
        Caption = 'Ceiling'
      end
      object Label13: TLabel
        Left = 184
        Top = 34
        Width = 32
        Height = 17
        AutoSize = False
        Caption = 'Floor'
      end
      object Label12: TLabel
        Left = 10
        Top = 24
        Width = 30
        Height = 13
        AutoSize = False
        Caption = 'Light'
      end
      object Label14: TLabel
        Left = 10
        Top = 50
        Width = 30
        Height = 13
        AutoSize = False
        Caption = 'Type'
      end
      object Label15: TLabel
        Left = 10
        Top = 74
        Width = 30
        Height = 13
        AutoSize = False
        Caption = 'Tag'
      end
      object Label16: TLabel
        Left = 184
        Top = 2
        Width = 40
        Height = 13
        AutoSize = False
        Caption = 'Height'
      end
      object Label17: TLabel
        Left = 184
        Top = 17
        Width = 40
        Height = 13
        AutoSize = False
        Caption = 'Texture'
      end
      object LabelMapSectorSideDefs: TLabel
        Left = 112
        Top = 74
        Width = 118
        Height = 13
        AutoSize = False
        Caption = '...'
      end
      object MapImageCeiling: TImage
        Left = 336
        Top = 32
        Width = 64
        Height = 64
        OnDblClick = MapImageCeilingDblClick
      end
      object MapImageFloor: TImage
        Left = 224
        Top = 32
        Width = 64
        Height = 64
        OnDblClick = MapImageFloorDblClick
      end
      object MapEditSectorCeiling: TEdit
        Left = 336
        Top = 2
        Width = 64
        Height = 14
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 1
        OnKeyDown = MapEditSectorKeyDown
      end
      object MapEditSectorFloor: TEdit
        Left = 224
        Top = 2
        Width = 64
        Height = 14
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 0
        OnKeyDown = MapEditSectorKeyDown
      end
      object MapSectorApply: TButton
        Left = 3
        Top = 2
        Width = 41
        Height = 18
        Caption = 'Apply'
        TabOrder = 7
        OnClick = MapSectorApplyClick
      end
      object MapEditSectorFloorTex: TEdit
        Left = 224
        Top = 17
        Width = 64
        Height = 14
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 2
        OnChange = MapEditSectorFloorTexChange
        OnKeyDown = MapEditSectorTexKeyDown
        OnKeyPress = MapEditSectorFloorTexKeyPress
        OnKeyUp = MapEditSectorTexKeyUp
      end
      object MapEditSectorCeilingTex: TEdit
        Left = 336
        Top = 17
        Width = 64
        Height = 14
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 3
        OnChange = MapEditSectorTexChange
        OnKeyDown = MapEditSectorTexKeyDown
        OnKeyPress = MapEditSectorFloorTexKeyPress
        OnKeyUp = MapEditSectorTexKeyUp
      end
      object MapEditSectorLight: TEdit
        Left = 40
        Top = 24
        Width = 60
        Height = 16
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 4
        OnKeyDown = MapEditSectorKeyDown
      end
      object MapEditSectorType: TEdit
        Left = 40
        Top = 48
        Width = 60
        Height = 16
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 5
      end
      object MapEditSectorTag: TEdit
        Left = 40
        Top = 72
        Width = 60
        Height = 16
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 6
        OnKeyPress = MapEditSectorTagKeyPress
      end
      object MapSectorPrev: TButton
        Left = 48
        Top = 2
        Width = 20
        Height = 18
        Hint = 'Previous Sector'
        Caption = '<'
        TabOrder = 8
        OnClick = MapSectorPrevClick
      end
      object MapEditSector: TEdit
        Left = 70
        Top = 2
        Width = 38
        Height = 18
        AutoSize = False
        TabOrder = 9
        OnKeyPress = MapEditSectorKeyPress
      end
      object MapSectorNext: TButton
        Left = 110
        Top = 2
        Width = 20
        Height = 18
        Hint = 'Next Sector'
        Caption = '>'
        TabOrder = 10
        OnClick = MapSectorNextClick
      end
      object MapPickSector: TBitBtn
        Left = 100
        Top = 48
        Width = 16
        Height = 16
        TabOrder = 11
        OnClick = MapPickSectorClick
        Glyph.Data = {
          6A010000424D6A0100000000000036000000280000000E000000070000000100
          18000000000034010000120B0000120B00000000000000000000008080008080
          0080800000000080800080800080800080800080800080800000000080800080
          8000808000000080800080800080800000000000000080800080800080800080
          8000808000000000000000808000808000000080800080800080800000000000
          0000000000808000808000808000808000000000808000000000808000000080
          8000808000808000000000000000000000000000808000808000808000000000
          8080008080000000000000808000808000808000000000000000000000808000
          8080008080008080000000008080000000008080000000808000808000808000
          0000000000008080008080008080008080008080000000000000008080008080
          0000008080008080008080000000008080008080008080008080008080008080
          0000000080800080800080800000}
        Layout = blGlyphRight
        NumGlyphs = 2
      end
      object MapSectorDup: TButton
        Left = 132
        Top = 2
        Width = 30
        Height = 18
        Hint = 'Duplicate Sector'
        Caption = 'Dup'
        TabOrder = 12
        OnClick = MapSectorDupClick
      end
    end
    object PanelMapLineDefs: TPanel
      Left = 7
      Top = 200
      Width = 556
      Height = 98
      Align = alBottom
      TabOrder = 1
      object Label2: TLabel
        Left = 8
        Top = 19
        Width = 41
        Height = 13
        AutoSize = False
        Caption = 'Above'
      end
      object Label3: TLabel
        Left = 8
        Top = 35
        Width = 41
        Height = 13
        AutoSize = False
        Caption = 'Main'
      end
      object Label4: TLabel
        Left = 8
        Top = 51
        Width = 41
        Height = 13
        AutoSize = False
        Caption = 'Below'
      end
      object Label5: TLabel
        Left = 48
        Top = 3
        Width = 70
        Height = 13
        AutoSize = False
        Caption = 'Front Side'
      end
      object Label6: TLabel
        Left = 120
        Top = 3
        Width = 70
        Height = 13
        AutoSize = False
        Caption = 'Back Side'
      end
      object Label7: TLabel
        Left = 8
        Top = 67
        Width = 41
        Height = 13
        AutoSize = False
        Caption = 'X, Y'
      end
      object Label18: TLabel
        Left = 8
        Top = 83
        Width = 41
        Height = 13
        AutoSize = False
        Caption = 'Sector'
      end
      object Label10: TLabel
        Left = 288
        Top = 8
        Width = 30
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Tag'
      end
      object Label19: TLabel
        Left = 288
        Top = 32
        Width = 30
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Type'
      end
      object MapEditFrontAbove: TEdit
        Left = 48
        Top = 17
        Width = 70
        Height = 15
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 0
        OnEnter = MapEditFrontAboveEnter
        OnKeyDown = MapEditKeyDown
        OnKeyPress = MapEditTextureKeyPress
        OnKeyUp = MapEditKeyUp
      end
      object MapEditFrontMain: TEdit
        Left = 48
        Top = 33
        Width = 70
        Height = 15
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 1
        OnEnter = MapEditFrontMainEnter
        OnKeyDown = MapEditKeyDown
        OnKeyPress = MapEditTextureKeyPress
        OnKeyUp = MapEditKeyUp
      end
      object MapEditFrontBelow: TEdit
        Left = 48
        Top = 49
        Width = 70
        Height = 15
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 2
        OnEnter = MapEditFrontBelowEnter
        OnKeyDown = MapEditKeyDown
        OnKeyPress = MapEditTextureKeyPress
        OnKeyUp = MapEditKeyUp
      end
      object MapTextureApply: TButton
        Left = 3
        Top = 2
        Width = 41
        Height = 18
        Caption = 'Apply'
        TabOrder = 12
        OnClick = MapTextureApplyClick
      end
      object MapEditBackAbove: TEdit
        Left = 120
        Top = 17
        Width = 70
        Height = 15
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 6
        OnEnter = MapEditBackAboveEnter
        OnKeyDown = MapEditKeyDown
        OnKeyPress = MapEditTextureKeyPress
        OnKeyUp = MapEditKeyUp
      end
      object MapEditBackMain: TEdit
        Left = 120
        Top = 33
        Width = 70
        Height = 15
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 7
        OnEnter = MapEditBackMainEnter
        OnKeyDown = MapEditKeyDown
        OnKeyPress = MapEditTextureKeyPress
        OnKeyUp = MapEditKeyUp
      end
      object MapEditBackBelow: TEdit
        Left = 120
        Top = 49
        Width = 70
        Height = 15
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 8
        OnEnter = MapEditBackBelowEnter
        OnKeyDown = MapEditKeyDown
        OnKeyPress = MapEditTextureKeyPress
        OnKeyUp = MapEditKeyUp
      end
      object MapEditFrontX: TEdit
        Left = 48
        Top = 65
        Width = 34
        Height = 15
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 3
      end
      object MapEditFrontY: TEdit
        Left = 84
        Top = 65
        Width = 34
        Height = 15
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 4
      end
      object MapEditBackX: TEdit
        Left = 120
        Top = 65
        Width = 34
        Height = 15
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 9
      end
      object MapEditBackY: TEdit
        Left = 156
        Top = 65
        Width = 34
        Height = 15
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 10
      end
      object MapListTextures: TListBox
        Left = 192
        Top = 23
        Width = 90
        Height = 72
        ItemHeight = 13
        TabOrder = 14
        OnDblClick = MapListTexturesDblClick
        OnKeyPress = MapListTexturesKeyPress
      end
      object MapEditQuickFind: TEdit
        Left = 192
        Top = 3
        Width = 90
        Height = 18
        AutoSize = False
        TabOrder = 13
        OnChange = MapEditQuickFindChange
        OnKeyDown = MapEditQuickFindKeyDown
      end
      object MapEditLineDefArg1: TEdit
        Left = 288
        Top = 58
        Width = 30
        Height = 18
        Hint = 'Arg1'
        AutoSize = False
        TabOrder = 31
      end
      object MapEditLineDefArg2: TEdit
        Left = 320
        Top = 58
        Width = 30
        Height = 18
        Hint = 'Arg2'
        AutoSize = False
        TabOrder = 32
      end
      object MapEditLineDefArg3: TEdit
        Left = 352
        Top = 58
        Width = 30
        Height = 18
        Hint = 'Arg3'
        AutoSize = False
        TabOrder = 33
      end
      object MapEditLineDefArg4: TEdit
        Left = 288
        Top = 77
        Width = 30
        Height = 18
        Hint = 'Arg4'
        AutoSize = False
        TabOrder = 34
      end
      object MapEditLineDefArg5: TEdit
        Left = 320
        Top = 77
        Width = 30
        Height = 18
        Hint = 'Arg5'
        AutoSize = False
        TabOrder = 35
      end
      object MapEditLineDefTag: TEdit
        Left = 320
        Top = 8
        Width = 44
        Height = 16
        BorderStyle = bsNone
        Color = 12628128
        TabOrder = 15
        Text = 'Tag'
      end
      object MapEditLineDefType: TEdit
        Left = 320
        Top = 32
        Width = 44
        Height = 16
        BorderStyle = bsNone
        Color = 12628128
        TabOrder = 16
        Text = 'Type'
      end
      object MapEditFrontSector: TEdit
        Left = 48
        Top = 81
        Width = 34
        Height = 15
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 5
      end
      object MapEditBackSector: TEdit
        Left = 120
        Top = 81
        Width = 34
        Height = 15
        AutoSize = False
        BorderStyle = bsNone
        Color = 10531008
        TabOrder = 11
      end
      object MapPickLineDef: TBitBtn
        Left = 364
        Top = 32
        Width = 16
        Height = 16
        TabOrder = 17
        OnClick = MapPickLineDefClick
        Glyph.Data = {
          6A010000424D6A0100000000000036000000280000000E000000070000000100
          18000000000034010000120B0000120B00000000000000000000008080008080
          0080800000000080800080800080800080800080800080800000000080800080
          8000808000000080800080800080800000000000000080800080800080800080
          8000808000000000000000808000808000000080800080800080800000000000
          0000000000808000808000808000808000000000808000000000808000000080
          8000808000808000000000000000000000000000808000808000808000000000
          8080008080000000000000808000808000808000000000000000000000808000
          8080008080008080000000008080000000008080000000808000808000808000
          0000000000008080008080008080008080008080000000000000008080008080
          0000008080008080008080000000008080008080008080008080008080008080
          0000000080800080800080800000}
        Layout = blGlyphRight
        NumGlyphs = 2
      end
      object MapEditLDFlags1: TCheckBox
        Left = 384
        Top = 2
        Width = 96
        Height = 14
        Caption = 'Impassable'
        TabOrder = 18
      end
      object MapEditLDFlags2: TCheckBox
        Left = 384
        Top = 15
        Width = 96
        Height = 14
        Caption = 'Block monsters'
        TabOrder = 19
      end
      object MapEditLDFlags3: TCheckBox
        Left = 384
        Top = 28
        Width = 96
        Height = 14
        Caption = 'Two sided'
        TabOrder = 20
        OnClick = MapEditLDFlags3Click
      end
      object MapEditLDFlags4: TCheckBox
        Left = 384
        Top = 41
        Width = 96
        Height = 14
        Hint = 'Upper Texture Unpegged'
        Caption = 'Upper unpeg'#39'd'
        TabOrder = 21
      end
      object MapEditLDFlags5: TCheckBox
        Left = 384
        Top = 55
        Width = 96
        Height = 14
        Hint = 'Lower Texture Unpegged'
        Caption = 'Lower unpeg'#39'd'
        TabOrder = 22
      end
      object MapEditLDFlags6: TCheckBox
        Left = 384
        Top = 68
        Width = 78
        Height = 14
        Caption = 'Secret'
        TabOrder = 23
      end
      object MapEditLDFlags7: TCheckBox
        Left = 384
        Top = 81
        Width = 78
        Height = 14
        Caption = 'Block sound'
        TabOrder = 24
      end
      object MapEditLDFlags8: TCheckBox
        Left = 476
        Top = 2
        Width = 78
        Height = 14
        Caption = 'Never map'
        TabOrder = 25
      end
      object MapEditLDFlags9: TCheckBox
        Left = 476
        Top = 15
        Width = 78
        Height = 14
        Caption = 'Always map'
        TabOrder = 26
      end
      object MapEditLDFlags10: TCheckBox
        Left = 476
        Top = 28
        Width = 78
        Height = 14
        Caption = 'Repeatable'
        TabOrder = 27
      end
      object MapEditLDFlags11: TCheckBox
        Left = 476
        Top = 41
        Width = 78
        Height = 14
        Hint = 'Enemies can Activate'
        Caption = 'Enemy Actv'
        TabOrder = 28
      end
      object MapEditLDFlags12: TCheckBox
        Left = 476
        Top = 55
        Width = 78
        Height = 14
        Hint = 'Blocks Everything'
        Caption = 'Blocks All'
        TabOrder = 29
      end
      object MapEditLineDefsActivate: TComboBox
        Left = 464
        Top = 72
        Width = 90
        Height = 21
        ItemHeight = 13
        TabOrder = 30
      end
    end
  end
  object PanelHex: TPanel
    Left = 232
    Top = 24
    Width = 313
    Height = 257
    BorderWidth = 6
    TabOrder = 1
    Visible = False
    object MemoHex: TMemo
      Left = 7
      Top = 7
      Width = 299
      Height = 243
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Fixedsys'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
      OnChange = MemoHexChange
      OnKeyDown = MemoHexKeyDown
      OnKeyUp = MemoHexKeyUp
      OnMouseUp = MemoHexMouseUp
    end
  end
  object PanelTexture: TPanel
    Left = 240
    Top = 8
    Width = 361
    Height = 257
    BorderWidth = 6
    TabOrder = 2
    Visible = False
    object TextureSplitter1: TSplitter
      Left = 7
      Top = 186
      Width = 347
      Height = 6
      Cursor = crVSplit
      Align = alTop
      MinSize = 100
      OnMoved = TextureSplitter1Moved
    end
    object Panel1: TPanel
      Left = 7
      Top = 192
      Width = 347
      Height = 58
      Align = alClient
      BevelOuter = bvLowered
      BorderWidth = 6
      TabOrder = 0
      object ImageTexture: TImage
        Left = 7
        Top = 7
        Width = 333
        Height = 44
        Align = alClient
        OnMouseDown = ImageTextureMouseDown
        OnMouseMove = ImageTextureMouseMove
        OnMouseUp = ImageTextureMouseUp
      end
    end
    object PanelTexture2: TPanel
      Left = 7
      Top = 7
      Width = 347
      Height = 179
      Align = alTop
      BevelOuter = bvLowered
      BorderWidth = 6
      TabOrder = 1
      object TextureSplitter2: TSplitter
        Left = 307
        Top = 7
        Width = 6
        Height = 165
        Cursor = crHSplit
        MinSize = 100
        OnMoved = TextureSplitter2Moved
      end
      object GridTexturePatches: TStringGrid
        Left = 313
        Top = 7
        Width = 27
        Height = 165
        Align = alClient
        ColCount = 2
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing, goAlwaysShowEditor]
        TabOrder = 0
        OnKeyDown = GridTexturePatchesKeyDown
        OnKeyPress = GridTexturePatchesKeyPress
        OnSetEditText = GridTexturePatchesSetEditText
        RowHeights = (
          24
          24)
      end
      object PanelTexture3: TPanel
        Left = 7
        Top = 7
        Width = 300
        Height = 165
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
        object GridTextures: TStringGrid
          Left = 0
          Top = 26
          Width = 300
          Height = 139
          Align = alBottom
          Anchors = [akLeft, akTop, akRight, akBottom]
          Constraints.MinWidth = 180
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing, goAlwaysShowEditor]
          TabOrder = 0
          OnKeyDown = GridTexturesKeyDown
          OnKeyPress = GridTexturesKeyPress
          OnSelectCell = GridTexturesSelectCell
          OnSetEditText = GridTexturesSetEditText
          RowHeights = (
            24
            24
            24
            25
            24)
        end
        object TextureQuickFind: TEdit
          Left = 0
          Top = 0
          Width = 299
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
          OnKeyDown = TextureQuickFindKeyDown
          OnKeyPress = TextureQuickFindKeyPress
        end
      end
    end
  end
  object PanelImage: TPanel
    Left = 128
    Top = 32
    Width = 577
    Height = 257
    BorderWidth = 6
    TabOrder = 4
    Visible = False
    object ImageSplitter: TSplitter
      Left = 121
      Top = 7
      Width = 6
      Height = 243
      Cursor = crHSplit
      Visible = False
    end
    object ImageSplitterRemap: TSplitter
      Left = 241
      Top = 7
      Width = 6
      Height = 243
      Cursor = crHSplit
      Visible = False
      OnMoved = ImageSplitterRemapMoved
    end
    object PanelImageArt: TPanel
      Left = 7
      Top = 7
      Width = 114
      Height = 243
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      Visible = False
      object ImageArtGrid: TStringGrid
        Left = 0
        Top = 0
        Width = 114
        Height = 243
        Align = alClient
        FixedCols = 0
        TabOrder = 0
        OnSelectCell = ImageArtGridSelectCell
      end
    end
    object PanelImageEdit: TPanel
      Left = 247
      Top = 7
      Width = 323
      Height = 243
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object LabelImageSize: TLabel
        Left = 284
        Top = 3
        Width = 101
        Height = 15
        AutoSize = False
        Caption = '.'
      end
      object Image1: TImage
        Left = 4
        Top = 24
        Width = 319
        Height = 215
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnDblClick = Image1DblClick
        OnMouseDown = Image1MouseDown
        OnMouseMove = Image1MouseMove
        OnMouseUp = Image1MouseUp
      end
      object PanelImageEditY: TEdit
        Left = 240
        Top = 0
        Width = 41
        Height = 21
        TabOrder = 6
        OnChange = PanelImageEditYChange
        OnExit = PanelImageEditYExit
        OnKeyPress = PanelImageEditXKeyPress
        OnKeyUp = PanelImageEditXKeyUp
      end
      object PanelImageEditX: TEdit
        Left = 192
        Top = 0
        Width = 41
        Height = 21
        TabOrder = 5
        OnChange = PanelImageEditYChange
        OnExit = PanelImageEditXExit
        OnKeyPress = PanelImageEditXKeyPress
        OnKeyUp = PanelImageEditXKeyUp
      end
      object chkImageTile: TCheckBox
        Left = 96
        Top = 2
        Width = 39
        Height = 17
        Caption = '&Tile'
        TabOrder = 3
        OnClick = chkImageTileClick
      end
      object UpDownImageZoom: TUpDown
        Left = 57
        Top = 0
        Width = 36
        Height = 21
        Associate = EditImageZoom
        Min = 1
        Max = 10
        Orientation = udHorizontal
        Position = 2
        TabOrder = 2
        Wrap = False
        OnClick = UpDownImageZoomClick
      end
      object EditImageZoom: TEdit
        Left = 26
        Top = 0
        Width = 31
        Height = 21
        TabOrder = 1
        Text = '2'
        OnKeyDown = EditImageZoomKeyDown
        OnKeyPress = EditImageZoomKeyPress
      end
      object EditImageCursor: TEdit
        Left = 4
        Top = 0
        Width = 20
        Height = 21
        TabOrder = 0
        OnKeyDown = EditImageCursorKeyDown
        OnKeyPress = EditImageCursorKeyPress
      end
      object cmdImageWeapon: TButton
        Left = 135
        Top = 0
        Width = 55
        Height = 21
        Hint = 'Toggle Weapon Display'
        Caption = 'W: Auto'
        TabOrder = 4
        OnClick = cmdImageWeaponClick
      end
    end
    object PanelImageRemap: TPanel
      Left = 127
      Top = 7
      Width = 114
      Height = 243
      Align = alLeft
      BorderWidth = 6
      TabOrder = 2
      Visible = False
      object ImageRemapList: TListBox
        Left = 7
        Top = 7
        Width = 100
        Height = 229
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemHeight = 13
        ParentFont = False
        Style = lbOwnerDrawFixed
        TabOrder = 0
        OnDblClick = ImageRemapListDblClick
        OnDrawItem = ImageRemapListDrawItem
        OnKeyPress = ImageRemapListKeyPress
      end
    end
  end
  object PanelScript: TPanel
    Left = 312
    Top = 72
    Width = 289
    Height = 273
    BorderWidth = 6
    TabOrder = 12
    Visible = False
    object ScriptWordList: TListBox
      Left = 48
      Top = 48
      Width = 121
      Height = 97
      ItemHeight = 13
      TabOrder = 0
      Visible = False
      OnDblClick = ScriptWordListDblClick
      OnExit = ScriptWordListExit
      OnKeyPress = ScriptWordListKeyPress
    end
  end
  object PanelPalette: TPanel
    Left = 272
    Top = 48
    Width = 297
    Height = 257
    BorderWidth = 6
    TabOrder = 6
    Visible = False
    object ImagePalette: TImage
      Left = 8
      Top = 80
      Width = 263
      Height = 169
      Anchors = [akLeft, akTop, akRight, akBottom]
      OnDblClick = ImagePaletteDblClick
      OnMouseDown = ImagePaletteMouseDown
      OnMouseMove = ImagePaletteMouseMove
    end
    object PaletteLabelZoom: TLabel
      Left = 168
      Top = 32
      Width = 33
      Height = 17
      AutoSize = False
      Caption = 'Zoom:'
    end
    object PanelPaletteRGB: TLabel
      Left = 240
      Top = 11
      Width = 80
      Height = 13
      AutoSize = False
    end
    object PaletteLabelColor: TLabel
      Left = 168
      Top = 8
      Width = 200
      Height = 17
      AutoSize = False
      Caption = '...'
    end
    object LabelPaletteR: TLabel
      Left = 8
      Top = 8
      Width = 16
      Height = 13
      AutoSize = False
      Caption = 'R:'
    end
    object LabelPaletteG: TLabel
      Left = 8
      Top = 32
      Width = 16
      Height = 13
      AutoSize = False
      Caption = 'G:'
    end
    object LabelPaletteB: TLabel
      Left = 8
      Top = 56
      Width = 16
      Height = 13
      AutoSize = False
      Caption = 'B:'
    end
    object LabelPaletteH: TLabel
      Left = 88
      Top = 8
      Width = 16
      Height = 13
      AutoSize = False
      Caption = 'H:'
    end
    object LabelPaletteS: TLabel
      Left = 88
      Top = 32
      Width = 16
      Height = 13
      AutoSize = False
      Caption = 'S:'
    end
    object LabelPaletteL: TLabel
      Left = 88
      Top = 56
      Width = 16
      Height = 13
      AutoSize = False
      Caption = 'L:'
    end
    object EditPaletteZoom: TEdit
      Left = 200
      Top = 29
      Width = 49
      Height = 21
      TabOrder = 6
      Text = '4'
    end
    object UpDownPaletteZoom: TUpDown
      Left = 249
      Top = 29
      Width = 40
      Height = 21
      Associate = EditPaletteZoom
      Min = 1
      Max = 6
      Orientation = udHorizontal
      Position = 4
      TabOrder = 7
      Wrap = False
      OnClick = UpDownPaletteZoomClick
    end
    object chkPaletteGrid: TCheckBox
      Left = 200
      Top = 58
      Width = 73
      Height = 17
      Caption = 'Show Grid'
      TabOrder = 9
      OnClick = chkPaletteGridClick
    end
    object PaletteEdit: TEdit
      Left = 168
      Top = 53
      Width = 25
      Height = 21
      Color = 11976906
      TabOrder = 8
      OnKeyDown = PaletteEditKeyDown
      OnKeyPress = PaletteEditKeyPress
    end
    object PaletteEditR: TEdit
      Left = 24
      Top = 5
      Width = 49
      Height = 21
      Hint = 'R (Red)'
      TabOrder = 0
    end
    object PaletteEditG: TEdit
      Left = 24
      Top = 29
      Width = 49
      Height = 21
      Hint = 'G (Green)'
      TabOrder = 1
    end
    object PaletteEditB: TEdit
      Left = 24
      Top = 53
      Width = 49
      Height = 21
      Hint = 'B (Blue)'
      TabOrder = 2
    end
    object PaletteScroll: TScrollBar
      Left = 272
      Top = 80
      Width = 16
      Height = 169
      Anchors = [akTop, akRight, akBottom]
      Kind = sbVertical
      PageSize = 0
      TabOrder = 10
      OnChange = PaletteScrollChange
    end
    object PaletteEditH: TEdit
      Left = 104
      Top = 5
      Width = 49
      Height = 21
      Hint = 'H (Hue)'
      TabOrder = 3
    end
    object PaletteEditS: TEdit
      Left = 104
      Top = 29
      Width = 49
      Height = 21
      Hint = 'S (Saturation)'
      TabOrder = 4
    end
    object PaletteEditL: TEdit
      Left = 104
      Top = 53
      Width = 49
      Height = 21
      Hint = 'L (Lightness)'
      TabOrder = 5
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 48
    Top = 56
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 56
    object mnuFile: TMenuItem
      Caption = '&File'
      HelpContext = 1100
      Hint = 'List Unused Textures'
      object mnuFileNew: TMenuItem
        Caption = '&New'
        HelpContext = 1101
        ShortCut = 16462
        OnClick = mnuFileNewClick
      end
      object mnuFileOpen: TMenuItem
        Caption = '&Open'
        HelpContext = 1102
        ShortCut = 16463
        OnClick = mnuFileOpenClick
      end
      object mnuFileMerge: TMenuItem
        Caption = '&Merge'
        HelpContext = 1103
        OnClick = mnuFileMergeClick
      end
      object mnuFileJoin: TMenuItem
        Caption = '&Join (add lumps only)'
        OnClick = mnuFileJoinClick
      end
      object mnuFileClose: TMenuItem
        Caption = '&Close'
        HelpContext = 1104
        OnClick = mnuFileCloseClick
      end
      object mnuFile3: TMenuItem
        Caption = '-'
      end
      object mnuFileCleanUp: TMenuItem
        Caption = 'Clean &up'
        HelpContext = 1105
        OnClick = mnuFileCleanUpClick
      end
      object mnuFileTextures: TMenuItem
        Caption = 'List Unused Textures'
        OnClick = mnuFileTexturesClick
      end
      object mnuFile2: TMenuItem
        Caption = '-'
        Visible = False
      end
      object mnuFileMRU1: TMenuItem
        Visible = False
        OnClick = mnuFileMRUClick
      end
      object mnuFileMRU2: TMenuItem
        Tag = 1
        Visible = False
        OnClick = mnuFileMRUClick
      end
      object mnuFileMRU3: TMenuItem
        Tag = 2
        Visible = False
        OnClick = mnuFileMRUClick
      end
      object mnuFileMRU4: TMenuItem
        Tag = 3
        Visible = False
        OnClick = mnuFileMRUClick
      end
      object mnuFile1: TMenuItem
        Caption = '-'
      end
      object mnuFileExit: TMenuItem
        Caption = 'E&xit'
        HelpContext = 1111
        OnClick = mnuFileExitClick
      end
    end
    object mnuEdit: TMenuItem
      Caption = '&Edit'
      HelpContext = 1200
      object mnuEditUndo: TMenuItem
        Caption = 'Undo'
        Enabled = False
        HelpContext = 1200
        OnClick = mnuEditUndoClick
      end
      object mnuEdit0: TMenuItem
        Caption = '-'
      end
      object mnuEditCut: TMenuItem
        Caption = 'Cu&t'
        OnClick = mnuEditCutClick
      end
      object mnuEditCopy: TMenuItem
        Caption = '&Copy'
        HelpContext = 1202
        OnClick = mnuEditCopyClick
      end
      object mnuEditPaste: TMenuItem
        Caption = '&Paste'
        HelpContext = 1203
        OnClick = mnuEditPasteClick
      end
      object mnuEditEmptyClipboard: TMenuItem
        Caption = '&Empty Clipboard'
        HelpContext = 1204
        OnClick = mnuEditEmptyClipboardClick
      end
    end
    object mnuEntry: TMenuItem
      Caption = '&Entry'
      HelpContext = 1300
      object mnuEntryNew: TMenuItem
        Caption = '&New'
        HelpContext = 1301
        OnClick = mnuEntryNewClick
      end
      object mnuEntryDelete: TMenuItem
        Caption = '&Delete'
        HelpContext = 1302
        OnClick = mnuEntryDeleteClick
      end
      object mnuEntryRename: TMenuItem
        Caption = '&Rename'
        HelpContext = 1303
        OnClick = mnuEntryRenameClick
      end
      object mnuEntry0: TMenuItem
        Caption = '-'
      end
      object mnuEntryViewHex: TMenuItem
        Caption = '&View raw data'
        OnClick = mnuEntryViewHexClick
      end
      object mnuEntry2: TMenuItem
        Caption = '-'
      end
      object mnuEntryLoad: TMenuItem
        Caption = '&Load'
        HelpContext = 1304
        OnClick = mnuEntryLoadClick
      end
      object mnuEntryLoadRaw: TMenuItem
        Caption = 'Load (raw data)'
        HelpContext = 1305
        OnClick = mnuEntryLoadRawClick
      end
      object mnuEntryReplace: TMenuItem
        Caption = 'Re&place'
        HelpContext = 1306
        OnClick = mnuEntryReplaceClick
      end
      object mnuEntryReplaceRaw: TMenuItem
        Caption = 'Replace (raw data)'
        HelpContext = 1307
        OnClick = mnuEntryReplaceRawClick
      end
      object mnuEntrySaveAs: TMenuItem
        Caption = '&Save As...'
        HelpContext = 1308
        OnClick = mnuEntrySaveAsClick
      end
      object mnuEntrySaveAsRaw: TMenuItem
        Caption = 'Save As... (raw data)'
        OnClick = mnuEntrySaveAsRawClick
      end
      object mnuEntry1: TMenuItem
        Caption = '-'
      end
      object mnuEntryMoveUp: TMenuItem
        Caption = 'Move &Up'
        HelpContext = 1309
        ShortCut = 16469
        OnClick = mnuEntryMoveUpClick
      end
      object mnuEntryMoveDown: TMenuItem
        Caption = 'Move Do&wn'
        HelpContext = 1310
        ShortCut = 16452
        OnClick = mnuEntryMoveDownClick
      end
    end
    object mnuView: TMenuItem
      Caption = '&View'
      HelpContext = 1400
      object mnuViewEntryList: TMenuItem
        Caption = '&List of Entries'
        Checked = True
        HelpContext = 1401
        OnClick = mnuViewEntryListClick
      end
      object mnuViewMenuBar: TMenuItem
        Caption = '&Menu Bar'
        Checked = True
        HelpContext = 1402
        ShortCut = 122
        OnClick = mnuViewMenuBarClick
      end
      object mnuViewFilterToolbar: TMenuItem
        Caption = '&Filter Toolbar'
        Checked = True
        HelpContext = 1403
        OnClick = mnuViewFilterToolbarClick
      end
      object mnuViewStatusBar: TMenuItem
        Caption = '&Status Bar'
        Checked = True
        HelpContext = 1404
        OnClick = mnuViewStatusBarClick
      end
      object mnuView0: TMenuItem
        Caption = '-'
      end
      object mnuViewOptions: TMenuItem
        Caption = '&Options...'
        HelpContext = 1405
        OnClick = mnuViewOptionsClick
      end
    end
    object mnuImage: TMenuItem
      Caption = '&Image'
      object mnuImageEdit: TMenuItem
        Caption = '&Edit'
        OnClick = mnuImageEditClick
      end
      object mnuImageApply: TMenuItem
        Caption = '&Apply alignment'
        HelpContext = 1501
        OnClick = mnuImageApplyClick
      end
      object mnuImageAutoCrop: TMenuItem
        Caption = 'A&uto Crop'
        OnClick = mnuImageAutoCropClick
      end
      object mnuImageWeaponCrop: TMenuItem
        Caption = '&Weapon Crop'
        OnClick = mnuImageWeaponCropClick
      end
      object mnuImage0: TMenuItem
        Caption = '-'
        HelpContext = 1503
      end
      object mnuImageColorRemap: TMenuItem
        Caption = '&Color Remap'
        OnClick = mnuImageColorRemapClick
      end
      object mnuColorRemapReset: TMenuItem
        Caption = '&Reset Color Remap'
        OnClick = mnuColorRemapResetClick
      end
      object mnuImagePerformColorRemap: TMenuItem
        Caption = '&Perform Color Remap'
        OnClick = mnuImagePerformColorRemapClick
      end
      object mnuImageSave0: TMenuItem
        Caption = '-'
        Visible = False
      end
      object mnuImageSaveCurrent: TMenuItem
        Caption = 'Save Curren&t'
        Visible = False
        OnClick = mnuImageSaveCurrentClick
      end
      object mnuImageSaveAll: TMenuItem
        Caption = 'Sa&ve All'
        Visible = False
        OnClick = mnuImageSaveAllClick
      end
      object mnuImage1: TMenuItem
        Caption = '-'
      end
      object mnuImagePNGCheck: TMenuItem
        Caption = 'PNG Check'
        Visible = False
        OnClick = mnuImagePNGCheckClick
      end
      object mnuImageCompress: TMenuItem
        Caption = 'Test for Compression'
        HelpContext = 1504
        Visible = False
        OnClick = mnuImageCompressClick
      end
      object mnuImageSelectPalette: TMenuItem
        Caption = 'Se&lect Palette'
        OnClick = mnuImageSelectPaletteClick
      end
      object mnuImage3: TMenuItem
        Caption = '-'
      end
      object mnuImageSaveFlat: TMenuItem
        Caption = 'Save as Doom &Flat'
        OnClick = mnuImageSaveFlatClick
      end
      object mnuImageSave: TMenuItem
        Caption = '&Save'
        OnClick = mnuImageSaveClick
      end
    end
    object mnuHex: TMenuItem
      Caption = '&Hex'
      object mnuHexEditText: TMenuItem
        Caption = 'Edit as &Text'
        OnClick = mnuHexEditTextClick
      end
      object mnuHex1: TMenuItem
        Caption = '-'
      end
      object mnuHexViewBytes: TMenuItem
        Caption = 'View as &Bytes'
        HelpContext = 1601
        OnClick = mnuHexViewBytesClick
      end
      object mnuHexViewWords: TMenuItem
        Caption = 'View as &Words'
        Checked = True
        HelpContext = 1602
        OnClick = mnuHexViewWordsClick
      end
      object mnuHexViewAscii: TMenuItem
        Caption = 'View as &Ascii'
        OnClick = mnuHexViewAsciiClick
      end
      object mnuHex0: TMenuItem
        Caption = '-'
        HelpContext = 1603
      end
      object mnuHexSave: TMenuItem
        Caption = '&Save'
        HelpContext = 1604
        OnClick = mnuHexSaveClick
      end
    end
    object mnuPatchNames: TMenuItem
      Caption = '&PatchNames'
      object mnuPatchNamesSave: TMenuItem
        Caption = '&Save'
        HelpContext = 1701
        OnClick = mnuPatchNamesSaveClick
      end
    end
    object mnuPalette: TMenuItem
      Caption = '&Palette'
      object mnuPaletteGradient: TMenuItem
        Caption = 'Create &Gradient'
        OnClick = mnuPaletteGradientClick
      end
      object mnuPalette3: TMenuItem
        Caption = '-'
      end
      object mnuPaletteDamageEffect: TMenuItem
        Caption = '&Damage Effect'
        OnClick = mnuPaletteDamageEffectClick
      end
      object mnuPalettePickupEffect: TMenuItem
        Caption = '&Pickup Effect'
        OnClick = mnuPalettePickupEffectClick
      end
      object mnuPaletteRadSuitEffect: TMenuItem
        Caption = '&RadSuit Effect'
        OnClick = mnuPaletteRadSuitEffectClick
      end
      object mnuPalette2: TMenuItem
        Caption = '-'
      end
      object mnuPaletteArrange: TMenuItem
        Caption = '&Arrange (like Doom)'
        OnClick = mnuPaletteArrangeClick
      end
      object mnuPalette0: TMenuItem
        Caption = '-'
      end
      object mnuPaletteUse: TMenuItem
        Caption = '&Use Current'
        OnClick = mnuPaletteUseClick
      end
      object mnuPalette1: TMenuItem
        Caption = '-'
      end
      object mnuPaletteSave: TMenuItem
        Caption = '&Save'
        OnClick = mnuPaletteSaveClick
      end
      object mnuPaletteSaveAs: TMenuItem
        Caption = 'Sa&ve As...'
        OnClick = mnuPaletteSaveAsClick
      end
    end
    object mnuColorMap: TMenuItem
      Caption = '&ColorMap'
      object mnuColorMapRebuild: TMenuItem
        Caption = '&Rebuild'
        OnClick = mnuColorMapRebuildClick
      end
      object mnuColormapRebuildSp: TMenuItem
        Caption = 'Rebuild &Partial'
        OnClick = mnuColormapRebuildSpClick
      end
      object mnuColorMapInvulnerability: TMenuItem
        Caption = '&Build Invulnerability Map'
        OnClick = mnuColorMapInvulnerabilityClick
      end
      object mnuColorMap1: TMenuItem
        Caption = '-'
      end
      object mnuColorMapDisplayHorizontally: TMenuItem
        Caption = '&Display Horizontally'
        Checked = True
        OnClick = mnuColorMapDisplayHorizontallyClick
      end
      object mnuColorMapDisplayGrid: TMenuItem
        Caption = 'Display &Grid'
        OnClick = mnuColorMapDisplayGridClick
      end
      object mnuColorMap0: TMenuItem
        Caption = '-'
      end
      object mnuColorMapSave: TMenuItem
        Caption = '&Save'
        OnClick = mnuColorMapSaveClick
      end
    end
    object mnuTextures: TMenuItem
      Caption = '&Textures'
      HelpContext = 1500
      object mnuTextureNew: TMenuItem
        Caption = '&New'
        HelpContext = 1501
        OnClick = mnuTextureNewClick
      end
      object mnuTextureDuplicate: TMenuItem
        Caption = 'D&uplicate'
        HelpContext = 1502
        OnClick = mnuTextureDuplicateClick
      end
      object mnuTextureDelete: TMenuItem
        Caption = '&Delete'
        HelpContext = 1503
        OnClick = mnuTextureDeleteClick
      end
      object mnuTexture0: TMenuItem
        Caption = '-'
        HelpContext = 1903
      end
      object mnuTextureNewPatch: TMenuItem
        Caption = 'New Patch'
        HelpContext = 1504
        OnClick = mnuTextureNewPatchClick
      end
      object mnuTextureDeletePatch: TMenuItem
        Caption = 'Delete Patch'
        HelpContext = 1505
        OnClick = mnuTextureDeletePatchClick
      end
      object mnuTexturePatchMoveUp: TMenuItem
        Caption = 'Move Patch Up'
        HelpContext = 1506
        OnClick = mnuTexturePatchMoveUpClick
      end
      object mnuTexturePatchMoveDown: TMenuItem
        Caption = 'Move Patch Down'
        HelpContext = 1507
        OnClick = mnuTexturePatchMoveDownClick
      end
      object mnuTexture1: TMenuItem
        Caption = '-'
        HelpContext = 1906
      end
      object mnuTexturesSave: TMenuItem
        Caption = '&Save'
        HelpContext = 1508
        OnClick = mnuTexturesSaveClick
      end
      object mnuTexture2: TMenuItem
        Caption = '-'
        Visible = False
      end
      object mnuTexturesCheck: TMenuItem
        Caption = '&Check Textures'
        Visible = False
        OnClick = mnuTexturesCheckClick
      end
    end
    object mnuWave: TMenuItem
      Caption = '&Wave'
      object mnuWavePlay: TMenuItem
        Caption = '&Play'
        HelpContext = 2101
        OnClick = mnuWavePlayClick
      end
      object mnuWaveStop: TMenuItem
        Caption = 'S&top'
        OnClick = mnuWaveStopClick
      end
      object mnuWave0: TMenuItem
        Caption = '-'
        HelpContext = 2102
      end
      object mnuWaveLouder: TMenuItem
        Caption = '&Louder...'
        HelpContext = 2103
      end
      object mnuWaveSofter: TMenuItem
        Caption = 'Softer...'
        HelpContext = 2104
      end
      object mnuWave1: TMenuItem
        Caption = '-'
      end
      object mnuWaveSave: TMenuItem
        Caption = '&Save (as Doom Wave)'
        OnClick = mnuWaveSaveClick
      end
    end
    object mnuMusic: TMenuItem
      Caption = 'Music'
      object mnuMusicPlay: TMenuItem
        Caption = '&Play'
        OnClick = mnuMusicPlayClick
      end
      object mnuMusicStop: TMenuItem
        Caption = '&Stop'
        OnClick = mnuMusicStopClick
      end
      object mnuMusic0: TMenuItem
        Caption = '-'
      end
      object mnuMusicConvertMIDI2MUS: TMenuItem
        Caption = '&Convert MIDI to MUS'
        OnClick = mnuMusicConvertMIDI2MUSClick
      end
    end
    object mnuTextScreen: TMenuItem
      Caption = '&TextScreen'
      object mnuTextScreenFill: TMenuItem
        Caption = '&Fill'
        HelpContext = 2201
        OnClick = mnuTextScreenFillClick
      end
      object mnuTextScreenCopyArea: TMenuItem
        Caption = '&Copy Area'
        OnClick = mnuTextScreenCopyAreaClick
      end
      object mnuTextScreenPasteArea: TMenuItem
        Caption = '&Paste Area'
        OnClick = mnuTextScreenPasteAreaClick
      end
      object mnuTextScreen1: TMenuItem
        Caption = '-'
      end
      object mnuTextScreenCopy: TMenuItem
        Caption = 'Cop&y current character'
        OnClick = mnuTextScreenCopyClick
      end
      object mnuTextScreen0: TMenuItem
        Caption = '-'
        HelpContext = 2202
      end
      object mnuTextScreenSave: TMenuItem
        Caption = '&Save'
        HelpContext = 2203
        OnClick = mnuTextScreenSaveClick
      end
    end
    object mnuGrid: TMenuItem
      Caption = '&Grid'
      object mnuGridAddLine: TMenuItem
        Caption = '&Add Line'
        OnClick = mnuGridAddLineClick
      end
      object mnuGridDeleteLine: TMenuItem
        Caption = '&Delete Line'
        OnClick = mnuGridDeleteLineClick
      end
      object mnuGrid0: TMenuItem
        Caption = '-'
      end
      object mnuGridGotoLine: TMenuItem
        Caption = '&Go to Line...'
        OnClick = mnuGridGotoLineClick
      end
      object mnuGrid1: TMenuItem
        Caption = '-'
      end
      object mnuGridSave: TMenuItem
        Caption = '&Save'
        OnClick = mnuGridSaveClick
      end
    end
    object mnuScript: TMenuItem
      Caption = '&Script'
      object mnuScriptSave: TMenuItem
        Caption = '&Save'
        HelpContext = 2301
        OnClick = mnuScriptSaveClick
      end
      object mnuScriptCompile: TMenuItem
        Caption = '&Compile (ACS)'
        HelpContext = 2302
        OnClick = mnuScriptCompileClick
      end
      object mnuScript0: TMenuItem
        Caption = '-'
      end
      object mnuScriptGotoLine: TMenuItem
        Caption = 'Go to line...'
        ShortCut = 16455
        OnClick = mnuScriptGotoLineClick
      end
    end
    object mnuMap: TMenuItem
      Caption = '&Map'
      object mnuMapSave: TMenuItem
        Caption = '&Save'
        OnClick = mnuMapSaveClick
      end
      object mnuMapCompile: TMenuItem
        Caption = '&Compile'
        OnClick = mnuMapCompileClick
      end
      object mnuMap0: TMenuItem
        Caption = '-'
      end
      object mnuMapRun: TMenuItem
        Caption = '&Run Map'
        OnClick = mnuMapRunClick
      end
      object mnuMapCheck: TMenuItem
        Caption = 'Chec&k for Errors'
        OnClick = mnuMapCheckClick
      end
      object mnuMapFixAllErrors: TMenuItem
        Caption = 'Fix All &Errors'
        OnClick = mnuMapFixAllErrorsClick
      end
      object mnuMap1: TMenuItem
        Caption = '-'
      end
      object mnuMapTypeDoom: TMenuItem
        Caption = 'Doom Format'
        OnClick = mnuMapTypeDoomClick
      end
      object mnuMapTypeZDoom: TMenuItem
        Caption = 'ZDoom Format'
        OnClick = mnuMapTypeZDoomClick
      end
      object mnuMap3: TMenuItem
        Caption = '-'
      end
      object mnuMapConfig: TMenuItem
        Caption = 'C&onfiguration'
        OnClick = mnuMapConfigClick
      end
      object mnuMap4: TMenuItem
        Caption = '-'
      end
      object mnuMapUsedTextures: TMenuItem
        Caption = 'List Used Textures'
        OnClick = mnuMapUsedTexturesClick
      end
      object mnuMapImportRisen3D: TMenuItem
        Caption = 'Import Risen3D'#39's edit.out file'
        OnClick = mnuMapImportRisen3DClick
      end
    end
    object mnuMapView: TMenuItem
      Caption = '&View'
      object mnuMapViewPropertiesBar: TMenuItem
        Caption = 'Properties Bar'
        Checked = True
        OnClick = mnuMapViewPropertiesBarClick
      end
      object mnuMapViewWadedBar: TMenuItem
        Caption = 'Waded Bar'
        Checked = True
        OnClick = mnuMapViewWadedBarClick
      end
      object mnuMapView1: TMenuItem
        Caption = '-'
      end
      object mnuMapViewShowThings: TMenuItem
        Caption = 'Show Things'
        Checked = True
        OnClick = mnuMapViewShowThingsClick
      end
      object mnuMapViewGrid: TMenuItem
        Caption = 'Show Grid'
        Checked = True
        OnClick = mnuMapViewGridClick
      end
      object mnuMapGridInc: TMenuItem
        Caption = 'Increase Grid'
        OnClick = mnuMapGridIncClick
      end
      object mnuMapGridDec: TMenuItem
        Caption = 'Decrease Grid'
        OnClick = mnuMapGridDecClick
      end
      object mnuMapView2: TMenuItem
        Caption = '-'
      end
      object mnuMapZoomIn: TMenuItem
        Caption = 'Zoom &In'
        OnClick = mnuMapZoomInClick
      end
      object mnuMapZoomOut: TMenuItem
        Caption = 'Zoom &Out'
        OnClick = mnuMapZoomOutClick
      end
      object mnuMapZoomAll: TMenuItem
        Caption = 'Zoom &All'
        OnClick = mnuMapZoomAllClick
      end
      object mnuMapView3: TMenuItem
        Caption = '-'
      end
      object mnuMapView3D: TMenuItem
        Caption = '3D View'
        OnClick = mnuMapView3DClick
      end
      object mnuMapDisplayLinedefLengths: TMenuItem
        Caption = 'Show Line Lengths'
        OnClick = mnuMapDisplayLinedefLengthsClick
      end
    end
    object mnuSelection: TMenuItem
      Caption = '&Selection'
      object mnuSelectionDuplicate: TMenuItem
        Caption = '&Duplicate'
        OnClick = mnuSelectionDuplicateClick
      end
      object mnuSelectionRotate: TMenuItem
        Caption = '&Rotate'
      end
      object mnuSelectionDelete: TMenuItem
        Caption = 'D&elete'
        OnClick = mnuSelectionDeleteClick
      end
    end
    object mnuLineDefs: TMenuItem
      Caption = 'Draw'
      object mnuDrawAll: TMenuItem
        Caption = 'All Mode'
        OnClick = mnuDrawAllClick
      end
      object mnuDrawLineDefs: TMenuItem
        Caption = 'LineDefs Mode'
        OnClick = mnuDrawLineDefsClick
      end
      object mnuDrawThings: TMenuItem
        Caption = 'Things Mode'
        OnClick = mnuDrawThingsClick
      end
      object mnuDrawSectors: TMenuItem
        Caption = 'Sectors Mode'
        OnClick = mnuDrawSectorsClick
      end
      object mnuDrawVertex: TMenuItem
        Caption = 'Vertex Mode'
        OnClick = mnuDrawVertexClick
      end
      object mnuDraw1: TMenuItem
        Caption = '-'
      end
      object mnuDrawDraw: TMenuItem
        Caption = 'Draw Mode'
        OnClick = mnuDrawDrawClick
      end
      object mnuDrawNewSector: TMenuItem
        Caption = 'Draw New Sector'
        OnClick = mnuDrawNewSectorClick
      end
      object mnuDrawSplitSector: TMenuItem
        Caption = 'Split Sector'
        OnClick = mnuDrawSplitSectorClick
      end
      object mnuMakeSector: TMenuItem
        Caption = 'Make Sector'
        OnClick = mnuMakeSectorClick
      end
      object mnuDraw0: TMenuItem
        Caption = '-'
      end
      object mnuDrawLineDefsJoin: TMenuItem
        Caption = 'Join LineDefs'
        OnClick = mnuDrawLineDefsJoinClick
      end
      object mnuDrawLineDefsSplit: TMenuItem
        Caption = 'Split LineDefs'
        OnClick = mnuDrawLineDefsSplitClick
      end
      object mnuDrawLineDefsSplit3: TMenuItem
        Caption = 'Split in three'
      end
      object mnuDrawLineDefsFlip: TMenuItem
        Caption = 'Flip LineDefs'
        OnClick = mnuDrawLineDefsFlipClick
      end
    end
    object mnuHelp: TMenuItem
      Caption = '&Help'
      HelpContext = 1600
      object mnuHelpContents: TMenuItem
        Caption = '&Contents'
        HelpContext = 1601
        OnClick = mnuHelpContentsClick
      end
      object mnuHelpAbout: TMenuItem
        Caption = '&About...'
        HelpContext = 1602
        OnClick = mnuHelpAboutClick
      end
    end
  end
  object ilEntryType: TImageList
    Left = 80
    Top = 56
    Bitmap = {
      494C010101000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000084848400C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60000000000000000005252520052525200525252005252
      5200000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000525252005252
      5200525252005252520052525200525252005252520052525200525252005252
      5200525252005252520052525200525252000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000005252520052525200000000000000000084848400FFFF
      FF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFF
      FF00FFFFFF00C6C6C60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000525252005252
      5200525252005252520052525200525252005252520052525200525252005252
      5200525252005252520052525200525252000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000052525200525252005252520052525200525252005252
      520052525200525252005252520052525200000000000000000084848400FFFF
      FF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFF
      FF0000FFFF00C6C6C60000000000000000005252520000000000000000000000
      0000ADADAD00ADAD520052525200ADADAD00ADAD520052525200ADADAD00ADAD
      AD00ADADAD00ADADAD00ADADAD00ADADAD005252520052525200525252005252
      5200525252005252520052525200525252005252520052525200525252005252
      5200525252005252520052525200525252005252520052525200525252005252
      5200525252005252520052525200525252005252520052525200525252005252
      520052525200525252005252520052525200000000000000000084848400FFFF
      FF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFF
      FF00FFFFFF00C6C6C6000000000000000000FFFFFF00FFFF520052525200ADAD
      AD00ADAD52005252520052525200525252005252520000000000000052005252
      5200525252005252520052525200ADADAD00ADAD520052525200ADADAD0000EF
      520008007300EF18000008007300EF21000010007300EF9C000021007300EF08
      000021007300EF08000021007300EF6B000021007300EFAD080029007300EFE7
      000029007300EF18210042000800EFE70800C6008C00000029000010100000EF
      7B0029A5940029A51800298C100010298C00000000000000000084848400FFFF
      FF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFF
      FF0000FFFF00C6C6C600000000000000000084EF0000735A2900101810005242
      730084C6000039C673005284E7000852BD0000D6E70000C65A000084C6001084
      E700F7525200C6730000EF0010000821C6001021D600105A5A0029CE000029C6
      000010000000D6FF5A0000F72900EFCEFF00C6009400FFFF2900009C1000FF21
      C60000088400E7298C001010000029FFA50010522900102110008C420000FFFF
      7300EF5A21004208290000AD1000311852000818BD00108C7B00BD080000A55A
      5A00732121004200FF0029A5A500218C4200000000000000000084848400FFFF
      FF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFF
      FF00FFFFFF00C6C6C6000000000000000000A59C1000A5181000A59C1000A521
      1000C629A50010298C0021108C0021FF0800BD000000E75A840000F729000018
      10000084C6001029A50010298C002110290010211000218C420039FFFF005221
      8C00218CC600FF0852000000D6005A84E700F721000021730000C60010003939
      210073317300EF0829000018100021731000C6002100FFFF2900181029003921
      10008C182100EF0829002110210073002100420008004A21D60000210000EF94
      5A008C10210029A5180039FFFF000884FF00000000000000000084848400FFFF
      FF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFF
      FF0000FFFF00C6C6C6000000000000000000C6730000EF0010000821C6003121
      D600315A5A0029CE000029A5210021C6730029C600001010000000FF29000010
      10000029C6000810000029C6000010080000EFFF5A0000F72900EFE7FF00A521
      1000C6731000FFFF29009C1029009C10210042000800EFC6FF00298C18001021
      C60000088400EFB5FF008C39100000FF2900A5BD1000E7105200298C18001029
      A50010218C001029A50010218C001029A50010218C001821C60018000000C642
      18000021C60021000000C6420000FF29A500000000000000000084848400FFFF
      FF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFF
      FF00FFFFFF00C6C6C60000000000000000008CC621000852BD0000D6E70084E7
      00002900000010730000C6001000A51810008C391800218C420039FFFF001839
      FF007300EF0000218C001821C6001021C60000FFFF0008218C001821C60000EF
      9400218C7B008CC621000852BD0000D6E70084E7000021004200730084000010
      29003918100039736B003900180073317300218C7300218C5A00218C420039C6
      730021C642000000210042182900002110000029A50010210000217331008442
      210010EF2900C642000084EF2100C6218C00000000000000000084848400FFFF
      FF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFF
      FF0000FFFF00C6C6C600000000000000000010100000EF21FF0084398C000873
      10000821C60000088400C6008C002100000029CEEF00FF8C00004A298C008C10
      2900848C10001021C60000088400080029008C10EF00FF422900398C1000FF08
      7300EFDEFF00C600080000002900001010000029C60008102100EFC6FF000042
      4A00CE730800A5941000C60010002100EF00FF424A00A5941000C60010002100
      EF00FF8C00004A29A5001029C60010102100EF8CFF0000424A00CE730800A59C
      1000C60010002900EF00FF424A00A59C1000000000000000000084848400FFFF
      FF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFF
      FF00FFFFFF00C6C6C60000000000000000001000000021FF8C00424A29009C10
      2900001010000029C6000810000021CE7300EF08FF0029FF0000104A7300EFFF
      FF0029FF0000104A29000010100000EFEF008C004200730829009C1029000010
      100000EFD600424A29009C1029000010100000EFC6008C00420029A59C0029C6
      000010000000B5FF8C00424A730029A59C0029C6000010000000A5FF420029A5
      9C0029C600001000000094FF8C00424A29009C1029000010100000EF7B008C00
      420073082900A51029000010100000EF6B00000000000000000084848400FFFF
      FF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFF
      FF0000FFFF00C6C6C6000000000000000000008C10000000F700CEEF1800BD08
      00002900A50039CE730000080000A510290039A510000008A500F7A500000000
      EF00FF52000000BDA50029003900108CCE00A500290000A5100029CE29000010
      100000EFD6008C00420073082900AD1029000010100000EFC600424A2900AD10
      2900001010000029C60008100800EFADFF0000424A00A5AD1000C60010002100
      29000008100000EF94008C00420073082900AD1029000010100000EF7B00424A
      2900AD1029000010100000EF6B008C004200000000000000000084848400FFFF
      FF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF000000
      000000000000000000000000000000000000A59C1000A59C100021FF29009C10
      2100731029009C1021007308BD00FF29A5001029A50010EF00008C00420029A5
      B50029C6000010080000A59C100029A59C0021C67300BDFFFF00A59C1000A59C
      1000DEF729009C102100731029009C1021007308BD00FF29A5001029A50010EF
      BD008C00420073082900B51029000010100000EFA500424A2900B51029000010
      100000EF94008C00420029A5B50029C600001010000084F78C00424A730029A5
      B50029C600001010000073F7420029A5B500000000000000000084848400FFFF
      FF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00C6C6
      C600FFFFFF0084848400000000000000000010102100EF21F700C60018000000
      8C00424A2900B5102900B51029000010100000EF000029CE29000010100000EF
      FF005200520000BD1000BD000000A5081000390073004A73290042EFF7008C10
      290039CE7300290008001000F700CEEF21000010080000F7290029A5080029A5
      1000EF085A005A21C60000088400CEEF0000005AEF00F72984001010210000EF
      F7005A5A5A005A5A5A0018C60000000000000000000000000000848484008484
      840084848400848484008484000000000000000000000000000084848400FFFF
      FF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00C6C6
      C6008484840000000000000000000000000000840000000000000000C6008484
      A500848484008484840084840000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000000000000000000000000000FF000000000000000000000000000000
      FF00000000000000000000000000000000000000000000000000848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0010000000004A520039212100000000000000420042395A000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000004242
      100000FFFF00FFB56B000000C600C600000042395A0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00C0018000FFFFFF00C001E800E0E8E800
      C001E800E0E8E800C001E800E0E8E800C001800080808000C001800080808000
      C001800080808000C001800080808000C001800080808000C001E800E0E8E800
      C0010000FFFFFFFFC001000000000000C001000000000000C003000000000800
      C007000000000000C00F76200000000000000000000000000000000000000000
      000000000000}
  end
  object SaveDialog1: TSaveDialog
    Left = 48
    Top = 120
  end
  object PopupListWad: TPopupMenu
    Left = 16
    Top = 88
    object mnuPL_NoFilter: TMenuItem
      Caption = 'Show All Entries'
      HelpContext = 1400
      OnClick = mnuPL_NoFilterClick
    end
    object mnuPL_Filter: TMenuItem
      Caption = '...'
      HelpContext = 1500
      OnClick = mnuPL_FilterClick
    end
    object mnuPL_FilterSub: TMenuItem
      Caption = 'Show Only ...'
      HelpContext = 1600
      OnClick = mnuPL_FilterSubClick
    end
    object mnuPL_0: TMenuItem
      Caption = '-'
      HelpContext = 2000
    end
    object mnuPL_EditSize: TMenuItem
      Caption = 'Edit Si&ze'
      HelpContext = 1800
      OnClick = mnuPL_EditSizeClick
    end
    object mnuPL_EditPosition: TMenuItem
      Caption = '&Edit Position'
      HelpContext = 1900
      OnClick = mnuPL_EditPositionClick
    end
    object mnuPL_ChangeType: TMenuItem
      Caption = 'Change Type ...'
      OnClick = mnuPL_ChangeTypeClick
    end
    object mnuPL_1: TMenuItem
      Caption = '-'
      HelpContext = 1700
    end
    object mnuPL_Delete: TMenuItem
      Caption = '&Delete Entry'
      OnClick = mnuPL_DeleteClick
    end
    object mnuPL_Rename: TMenuItem
      Caption = '&Rename Entry'
      HelpContext = 2100
      OnClick = mnuPL_RenameClick
    end
    object mnuPL_Replace: TMenuItem
      Caption = 'Replace Entry'
      OnClick = mnuPL_ReplaceClick
    end
    object mnuPL_ReplaceRaw: TMenuItem
      Caption = 'Replace Entry (raw data)'
      OnClick = mnuPL_ReplaceRawClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mnuPL_FindSectors: TMenuItem
      Caption = 'Find in &Sectors'
      HelpContext = 2200
      OnClick = mnuPL_FindSectorsClick
    end
    object mnuPL_AddtoPNames: TMenuItem
      Caption = '&Add to Patch Names'
      HelpContext = 2300
      OnClick = mnuPL_AddtoPNamesClick
    end
    object mnuPL_AddtoTexture: TMenuItem
      Caption = 'Add to &Texture'
      OnClick = mnuPL_AddtoTextureClick
    end
  end
  object OpenDialogImport: TOpenDialog
    Filter = 
      'Any File (*.*)|*.*|Lumps (*.lmp)|*.lmp|Graphic Files (*.bmp,*.jp' +
      'g,*.pcx)|*.bmp;*.jpg;*.pcx|Wave Files (*.wav)|*.wav|Music Files ' +
      '(*.mus,*.mid,*.it,*.mp3)|*.mus;*.mid;*.it;*.mp3|'#39'out'#39' Files (*.o' +
      'ut)|*.out'
    Left = 48
    Top = 88
  end
  object zipM: TZipMaster
    Verbose = False
    Trace = False
    AddCompLevel = 9
    AddOptions = []
    ExtrOptions = []
    Unattended = True
    SFXPath = 'ZipSFX.bin'
    SFXOverWriteMode = OvrConfirm
    SFXCaption = 'Self-extracting Archive'
    KeepFreeOnDisk1 = 0
    VersionInfo = '1.52 M'
    Left = 80
    Top = 88
  end
  object PopupMap: TPopupMenu
    Left = 16
    Top = 120
    object mnuPopupMapNewSector: TMenuItem
      Caption = 'New Rectangular &Sector'
      OnClick = mnuPopupMapNewSectorClick
    end
    object mnuPopupMapNewPolygonalSector: TMenuItem
      Caption = 'New &Polygonal Sector'
      OnClick = mnuPopupMapNewPolygonalSectorClick
    end
    object mnuPopupMap0: TMenuItem
      Caption = '-'
    end
    object mnuPopupMapJoinLineDefs: TMenuItem
      Caption = '&Join LineDefs (J)'
      OnClick = mnuPopupMapJoinLineDefsClick
    end
    object mnuPopupMapSplitLineDefs: TMenuItem
      Caption = 'S&plit LineDefs (X)'
      OnClick = mnuPopupMapSplitLineDefsClick
    end
    object mnuPopupMapFlipLineDefs: TMenuItem
      Caption = '&Flip LineDefs (F)'
      OnClick = mnuPopupMapFlipLineDefsClick
    end
    object mnuPopupMapSelectFrontSector: TMenuItem
      Caption = 'Select Front Sector'
      OnClick = mnuPopupMapSelectFrontSectorClick
    end
    object mnuPopupMapSelectBackSector: TMenuItem
      Caption = 'Select Back Sector'
      OnClick = mnuPopupMapSelectBackSectorClick
    end
    object mnuPopupMap1: TMenuItem
      Caption = '-'
    end
    object mnuPopupMapNewThing: TMenuItem
      Caption = 'New &Thing'
      OnClick = mnuPopupMapNewThingClick
    end
  end
  object MainMenu2: TMainMenu
    Left = 16
    Top = 152
  end
end
