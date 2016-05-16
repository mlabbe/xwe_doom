{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
unit Main;

{$DEFINE FULLVERSION} // also in Texture and WadFile
{$DEFINE USEDEBUG}   

(*
    Copyright 1999,2009 Csabo.
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*)

interface

Uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Stringz, MRUSupport, Buttons,
	MMSystem, ImgList, Registry, ClipBrd, Globals, FileCtrl, JPEG, ZipMstr,
	PNGImage,
	OleCtrls, CodeMax_TLB, FndFile, MPlayer, Math, ToolWin, ShellAPI,
	Options, About, PalSel, Evaluate, Texture, FileIO, WadFile, TBrowse, CRC,
	RGBValue;

{$R ZIPMSGUS.RES}

Const
	CMM_ISCOLORSYNTAXENABLED = ( WM_USER + 1620 );

Type
	TWadEntryCols = Record
		iLen : Integer;
		iType : String;
		Desc : String;
	End;

	// ---------------

	TConstants = Record
		Name : String;
		Fields : String;
		ValueStart : Integer;
		ValueCount : Integer;
	End;

	TConstantValues = Record
		Description : String;
		Value : Integer;
	End;

	// --------------

	// --- Scripts

Const
	MaxScripts = 1024;

Type
	TScript = Record
		sName : String;
		sClass : String;
		iStartLine : Integer;
		iEndLine : Integer;
	End;

	// ----------------

	TImgType = ( ImgOther, ImgDuke, ImgQuake, ImgWax );

	TImg = Record
		Name : String;
		xs, ys : Integer;
		xr, yr : Integer;
		Flags : Integer;
		Position : Integer;
	End;

Const
	MaxImg = 8192;

	// --------

Const
	WaveMax = $100000;

Type
	TWave = Record
		Case Byte Of
		0 :	( Bytes : Array [ 0 .. WaveMax - 1 ] Of Byte );
		1 : ( Words : Array [ 0 .. ( WaveMax Shr 1 ) - 1 ] Of Word );
	End;
	PWave = ^TWave;

	// ---

	TEditor = ( edNone, edImage, edHex, edPatchNames, edPalette, edColorMap,
		edTexture, edWave, edMus, edTextScreen, edGrid, edScript, edMap );

	TWaveFormat = ( wfmtNone, wfmtDOOM, wfmtWAV, wfmtVOC, wfmtRAW, wfmtOgg );

	TMusicFormat = ( mfmtNone, mfmtDOOM, mfmtMIDI, mfmtIMF, mfmtHM, mfmtIT, mfmtSCRM );

	// ---

Type
	TThing = Record
		x, y : Integer;
		Angle, iType, Flags : Integer;
		Tag : Integer;
		//
		// ZDoom
		//
		z : Integer;
		Special : Integer;
		Arg1, Arg2, Arg3, Arg4, Arg5 : Integer;
		//
		// Internal
		//
		Selected, Highlighted : Boolean;
	End;

Const
	thngLevel12    = $0001;
	thngLevel3     = $0002;
	thngLevel45    = $0004;
	thngDeaf       = $0008;
	thngMulti      = $0010;
	thngDormant    = $0010;
	thngFighter    = $0020;
	thngCleric     = $0040;
	thngMage       = $0080;
	thngSingle     = $0100;
	thngCoop       = $0200;
	thngDeathmatch = $0400;

Type
	TLineDef = Record
		VertexS, VertexE : Integer;
		Flags, iType, Tag : Integer;
		SideFront, SideBack : Integer;
		//
		// ZDoom
		//
		Arg1, Arg2, Arg3, Arg4, Arg5 : Integer;
		//
		// Internal
		//
		Ignore : Boolean; // ignore newly drawn lines while drawing
		Selected, Highlighted : Boolean;
	End;

Const
	ldefImpassable      = $0001;
	ldefBlockMonsters   = $0002;
	ldefTwoSided        = $0004;
	ldefUpperUnpegged   = $0008;
	ldefLowerUnpegged   = $0010;
	ldefSecret          = $0020;
	ldefBlockSound      = $0040;
	ldefNeverMap        = $0080;
	ldefAlwaysMap       = $0100;
	ldefRepeatable      = $0200; { zdoom }
	ldefEnemyActivate   = $2000; { zdoom }
	ldefBlockEverything = $8000; { zdoom }
	//
	ldefActivatePlayerCross     = $0000;
	ldefActivatePlayerUses      = $0400;
	ldefActivateEnemyCross      = $0800;
	ldefActivateProjectileHits  = $0C00;
	ldefActivatePlayerBumps     = $1000;
	ldefActivateProjectileCross = $1400;
	ldefActivateReserved1       = $1800;
	ldefActivateReserved2       = $1C00;

Type
	TSideDef = Record
		xOffset, yOffset : Integer;
		Above, Below, Main : String;
		Sector : Integer;
		//
		// Internal
		//
		Selected, Highlighted : Boolean;
	End;

	TVertex = Record
		x, y : Integer;
		//
		// Internal
		//
		Selected, Highlighted : Boolean;
	End;

	TSector = Record
		Floor, Ceiling : Integer;
		FloorTex, CeilingTex : String;
		Light, iType, Tag : Integer;
		//
		// Internal
		//
		iFL, iLL : Integer; // first and last linedef for this sector
		sx, sy, lx, ly : Integer; // sector boundaries
		Selected, Highlighted : Boolean;
	End;

Const
	PolyMax = 50000;

Type
	TPolygon = Array [ 0 .. PolyMax ] Of TPoint;

	// --- for multiple value support

	TValue = Record
		Value : Integer;
		Diff : Integer; // for inc/dec
		Kind : ( valDirect, valMultiple, valFirst, valAdd, valSub, valInc, valDec,
			valMultiply, valDivide );
	End;

	// ---

Const
	mapColorFirst = 0;
	mapColorGrid = 0;
	mapColorFloorGrid = 1;
	mapColorLines = 2;
	mapColorLinesTwoSided = 3;
	mapColorVertex = 4;
	mapColorHighlighted = 5;
	mapColorSelected = 6;
	mapColorLast = 6;

Type
	TMapType = ( mtDoom, mtZDoom, mtOldDoom );
	TMapMode = ( mmAll, mmLineDefs, mmThings, mmSectors, mmVertex,
		mmDraw, mmDrawNewSector,
		mmSelect, mmDrag, mmDuplicate );

	// ---
	// XWEScript
	// ---

Type
	TXSLoop = Record
		VariableName : String;
		FirstLine : Longint;
		Value : Longint;
		EndValue : Longint;
		StepValue : Longint;
	end;

	TXSCall = Record
		ReturnLine : Integer;
		SubName : String;
		CallParams : Array [ 1 .. 8 ] Of Variant;
	End;

Type
	TFormMain = class(TForm)
		MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
		mnuFileNew: TMenuItem;
		mnuFileOpen: TMenuItem;
		mnuFileMerge: TMenuItem;
		mnuFileClose: TMenuItem;
		mnuFileCleanUp: TMenuItem;
		mnuFile3: TMenuItem;
		mnuFile1: TMenuItem;
		mnuFileMRU1: TMenuItem;
		mnuFileMRU2: TMenuItem;
		mnuFileMRU3: TMenuItem;
		mnuFileMRU4: TMenuItem;
		mnuFile2: TMenuItem;
		mnuFileExit: TMenuItem;
		mnuEdit: TMenuItem;
		mnuEditUndo: TMenuItem;
		mnuEntry: TMenuItem;
		mnuEntryNew: TMenuItem;
		mnuEntryReplace: TMenuItem;
		mnuEntryLoad: TMenuItem;
		mnuEntryLoadRaw: TMenuItem;
    mnuEntryReplaceRaw: TMenuItem;
		mnuEntrySaveAs: TMenuItem;
		mnuEntrySaveAsRaw: TMenuItem;
		mnuEntryRename: TMenuItem;
		mnuEntryDelete: TMenuItem;
		mnuEntry0: TMenuItem;
		mnuEntry1: TMenuItem;
		mnuEntryMoveUp: TMenuItem;
		mnuEntryMoveDown: TMenuItem;
		mnuView: TMenuItem;
		mnuViewEntryList: TMenuItem;
		mnuView0: TMenuItem;
		mnuViewOptions: TMenuItem;
		mnuViewMenuBar: TMenuItem;
		mnuViewFilterToolbar: TMenuItem;
		mnuHelp: TMenuItem;
		mnuHelpAbout: TMenuItem;
		mnuHelpContents: TMenuItem;
		mnuPatchNames: TMenuItem;
		mnuPatchNamesSave: TMenuItem;
		mnuPalette: TMenuItem;
		mnuTextures: TMenuItem;
		mnuTextureNew: TMenuItem;
		mnuTextureDuplicate: TMenuItem;
		mnuTextureDelete: TMenuItem;
		mnuTexture0: TMenuItem;
		mnuTextureNewPatch: TMenuItem;
		mnuTextureDeletePatch: TMenuItem;
		mnuTexture1: TMenuItem;
		mnuTexturesSave: TMenuItem;
		mnuWave: TMenuItem;
		mnuWaveLouder: TMenuItem;
		mnuWaveSofter: TMenuItem;
		mnuWave0: TMenuItem;
		mnuWavePlay: TMenuItem;
		mnuHex: TMenuItem;
		mnuHex0: TMenuItem;
		mnuHexViewBytes: TMenuItem;
		mnuHexViewWords: TMenuItem;
		mnuHexSave: TMenuItem;
		mnuTextScreen: TMenuItem;
		mnuTextScreenSave: TMenuItem;
		mnuTextScreen0: TMenuItem;
		mnuTextScreenFill: TMenuItem;
		mnuImage: TMenuItem;
		mnuImageEdit: TMenuItem;
		mnuImageAutoCrop: TMenuItem;
		mnuImageWeaponCrop: TMenuItem;
		mnuImageApply: TMenuItem;
		mnuImage0: TMenuItem;
		mnuImageCompress: TMenuItem;
		mnuImageColorRemap: TMenuItem;
		mnuImagePerformColorRemap: TMenuItem;
		mnuImage1: TMenuItem;
		mnuImageSelectPalette: TMenuItem;
		mnuImageSaveCurrent: TMenuItem;
		mnuImageSave0: TMenuItem;
		mnuImageSaveAll: TMenuItem;
		mnuImageSaveFlat: TMenuItem;
		mnuImageSave: TMenuItem;
		mnuImage3: TMenuItem;
		mnuScript: TMenuItem;
		mnuScriptCompile: TMenuItem;
		mnuScriptSave: TMenuItem;
		mnuEdit0: TMenuItem;
		mnuEditCopy: TMenuItem;
		mnuEditPaste: TMenuItem;
		mnuEditEmptyClipboard: TMenuItem;
		mnuPalette0: TMenuItem;
		mnuPaletteSave: TMenuItem;
		mnuColorRemapReset: TMenuItem;
		mnuPaletteGradient: TMenuItem;
		mnuPaletteDamageEffect: TMenuItem;
		mnuMap: TMenuItem;
		mnuMapCompile: TMenuItem;
		mnuMapSave: TMenuItem;
		mnuMap0: TMenuItem;
		mnuMapZoomAll: TMenuItem;
		mnuMapZoomIn: TMenuItem;
		mnuMapZoomOut: TMenuItem;
		mnuMapUsedTextures: TMenuItem;
		mnuMap1: TMenuItem;
		mnuTexture2: TMenuItem;
		mnuTexturesCheck: TMenuItem;
		mnuTextScreenCopy: TMenuItem;
		mnuTextScreen1: TMenuItem;
		mnuTextScreenCopyArea: TMenuItem;
		mnuTextScreenPasteArea: TMenuItem;
		mnuGrid: TMenuItem;
		mnuGridSave: TMenuItem;
		mnuGrid0: TMenuItem;
		mnuGridDeleteLine: TMenuItem;
		mnuGridAddLine: TMenuItem;
		mnuColorMap: TMenuItem;
		mnuColorMapRebuild: TMenuItem;
		mnuColorMap0: TMenuItem;
		mnuColorMapSave: TMenuItem;
		mnuColorMap1: TMenuItem;
		mnuColorMapDisplayHorizontally: TMenuItem;
		mnuColorMapDisplayGrid: TMenuItem;
		mnuPopupMap0: TMenuItem;
		mnuPopupMapJoinLineDefs: TMenuItem;
		mnuPopupMapSplitLineDefs: TMenuItem;
		mnuPopupMapNewPolygonalSector: TMenuItem;
		mnuPopupMapNewSector: TMenuItem;
		mnuPopupMapSelectFrontSector: TMenuItem;
		mnuPopupMapSelectBackSector: TMenuItem;
		mnuGridGotoLine: TMenuItem;
		mnuGrid1: TMenuItem;
		mnuHexViewAscii: TMenuItem;
		mnuPaletteUse: TMenuItem;
		mnuPalette1: TMenuItem;
		mnuPaletteArrange: TMenuItem;
		mnuPalette2: TMenuItem;
		mnuPaletteSaveAs: TMenuItem;
		mnuHexEditText: TMenuItem;
		mnuHex1: TMenuItem;
		mnuMapRun: TMenuItem;
		mnuMapView2: TMenuItem;
		mnuEntryViewHex: TMenuItem;
		mnuEntry2: TMenuItem;
		mnuMapGridInc: TMenuItem;
		mnuMapGridDec: TMenuItem;
		mnuMapViewShowThings: TMenuItem;
		mnuMap3: TMenuItem;
		mnuLineDefs: TMenuItem;
		mnuDrawLineDefsJoin: TMenuItem;
		mnuDrawLineDefsSplit: TMenuItem;
		mnuDrawLineDefsFlip: TMenuItem;
		mnuTexturePatchMoveUp: TMenuItem;
		mnuTexturePatchMoveDown: TMenuItem;
		mnuWave1: TMenuItem;
		mnuWaveSave: TMenuItem;
		mnuPL_Delete: TMenuItem;
		mnuDraw0: TMenuItem;
		mnuDrawNewSector: TMenuItem;
		mnuMusic: TMenuItem;
		mnuMusicPlay: TMenuItem;
		mnuDrawLineDefsSplit3: TMenuItem;
		mnuDrawThings: TMenuItem;
		mnuDrawLineDefs: TMenuItem;
		mnuMapTypeDoom: TMenuItem;
		mnuMapTypeZDoom: TMenuItem;
		mnuPopupMap1: TMenuItem;
		mnuPopupMapFlipLineDefs: TMenuItem;
		mnuPopupMapNewThing: TMenuItem;
		mnuDraw1: TMenuItem;
		mnuDrawSectors: TMenuItem;
		mnuDrawSplitSector: TMenuItem;
		mnuMapCheck: TMenuItem;
		mnuMapView: TMenuItem;
		mnuMapView1: TMenuItem;
		mnuMapView3D: TMenuItem;
		mnuMapDisplayLinedefLengths: TMenuItem;
		mnuMakeSector: TMenuItem;
		mnuDrawDraw: TMenuItem;
		mnuMapViewPropertiesBar: TMenuItem;
		mnuMapView3: TMenuItem;
		mnuMapViewWadedBar: TMenuItem;
		mnuMapViewGrid: TMenuItem;
		mnuMap4: TMenuItem;
		mnuMapConfig: TMenuItem;
		mnuMapFixAllErrors: TMenuItem;
		mnuDrawVertex: TMenuItem;
		mnuDrawAll: TMenuItem;
		mnuSelection: TMenuItem;
		mnuSelectionDuplicate: TMenuItem;
		mnuSelectionDelete: TMenuItem;
		mnuSelectionRotate: TMenuItem;
		mnuMusicStop: TMenuItem;
		mnuColormapRebuildSp: TMenuItem;
		mnuViewStatusBar: TMenuItem;
		mnuEditCut: TMenuItem;
		mnuFileTextures: TMenuItem;
		mnuScript0: TMenuItem;
		mnuScriptGotoLine: TMenuItem;
		mnuImagePNGCheck: TMenuItem;

		PopupListWad: TPopupMenu;
		mnuPL_Rename: TMenuItem;
		mnuPL_FindSectors: TMenuItem;
		mnuPL_NoFilter: TMenuItem;
		mnuPL_0: TMenuItem;
		mnuPL_Filter: TMenuItem;
		mnuPL_FilterSub: TMenuItem;
		mnuPL_EditPosition: TMenuItem;
		mnuPL_1: TMenuItem;
		mnuPL_EditSize: TMenuItem;
		mnuPL_AddtoPNames: TMenuItem;
		mnuPL_AddtoTexture: TMenuItem;
		mnuPL_ChangeType: TMenuItem;

		OpenDialog1: TOpenDialog;

		PanelHex: TPanel;
		PanelBrowse: TPanel;
		PanelTexture: TPanel;
		PanelTextScreen: TPanel;
		PanelImage: TPanel;
		PanelGrid: TPanel;
		PanelPalette: TPanel;
		PanelWave: TPanel;
		PanelPatchNames: TPanel;
		PanelMap: TPanel;
		PanelMus: TPanel;
		PanelScript: TPanel;
		PanelColorMap: TPanel;

		LabelQuickFind: TLabel;
		EditQuickFind: TEdit;
		ListWad: TListView;
		chkBrowsePanel: TCheckBox;
		BrowserSplitter: TSplitter;
		MemoHex: TMemo;
		ilEntryType: TImageList;
		SaveDialog1: TSaveDialog;
		StatusBrowse: TStatusBar;
		chkTextScreenGrid: TCheckBox;
		ImageTextScreen: TImage;
		GridMain: TStringGrid;
		Panel1: TPanel;
		ImageTexture: TImage;
    TextureSplitter2: TSplitter;
		TextureSplitter1: TSplitter;
		PanelTexture2: TPanel;
		GridTexturePatches: TStringGrid;
		ImagePalette: TImage;
		EditPaletteZoom: TEdit;
		UpDownPaletteZoom: TUpDown;
		chkPaletteGrid: TCheckBox;
		PanelPaletteRGB: TLabel;
		PaletteLabelZoom: TLabel;
		PaletteEdit: TEdit;
		PaletteEditR: TEdit;
		PaletteEditG: TEdit;
		PaletteEditB: TEdit;
		PaletteEditH: TEdit;
		PaletteEditS: TEdit;
		PaletteEditL: TEdit;
		PaletteScroll: TScrollBar;
		PaletteLabelColor: TLabel;
		OpenDialogImport: TOpenDialog;
		PanelWaveImage: TImage;
		PanelWaveUpDownZoom: TUpDown;
		PanelWaveEditZoom: TComboBox;
		PanelWaveZoom: TLabel;
		PatchNamesList: TMemo;
		PatchNamesCount: TEdit;
		GridEditorTotal: TLabel;
		TextScreenEdit: TEdit;
		ImageTextScreenColors: TImage;
		PanelTexture3: TPanel;
		GridTextures: TStringGrid;
		TextureQuickFind: TEdit;

		PanelMus1: TPanel;
		PanelMus2: TPanel;
		MusSplitter: TSplitter;
		MusMemoIns: TMemo;
		MusGrid: TStringGrid;

		ImageSplitter: TSplitter;
		ImageSplitterRemap: TSplitter;
		Image1: TImage;
		ImageArtGrid: TStringGrid;
		ImageRemapList: TListBox;
		PanelImageArt: TPanel;
		PanelImageEdit: TPanel;
		PanelImageRemap: TPanel;
		LabelImageSize: TLabel;
		PanelImageEditY: TEdit;
		PanelImageEditX: TEdit;
		chkImageTile: TCheckBox;
		UpDownImageZoom: TUpDown;
		EditImageZoom: TEdit;
		WaveScroll: TScrollBar;
		zipM: TZipMaster;
		ScriptWordList: TListBox;
		ImageColorMap: TImage;
		PopupMap: TPopupMenu;
		WaveLabelSampleRate: TLabel;
		WaveEditSampleRate: TEdit;
		mpMusic: TMediaPlayer;

		PanelMapLineDefs: TPanel;
		PanelMapThings: TPanel;
		PanelMapSectors: TPanel;
		PanelMapVertex: TPanel;
		ImageMap: TImage;
		EditMapZoom: TEdit;
		MapEditFrontAbove: TEdit;
		MapEditFrontMain: TEdit;
		MapEditFrontBelow: TEdit;
		MapEditBackAbove: TEdit;
		MapEditBackMain: TEdit;
		MapEditBackBelow: TEdit;
		MapTextureApply: TButton;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Label6: TLabel;
		MapEditFrontX: TEdit;
		MapEditFrontY: TEdit;
		MapEditBackX: TEdit;
		MapEditBackY: TEdit;
		Label7: TLabel;
		MapListTextures: TListBox;
		MapEditQuickFind: TEdit;
		MapEditLDFlags1: TCheckBox;
		MapEditLDFlags2: TCheckBox;
		MapEditLDFlags3: TCheckBox;
		MapEditLDFlags4: TCheckBox;
		MapEditLDFlags5: TCheckBox;
		MapEditLDFlags6: TCheckBox;
		MapEditLDFlags7: TCheckBox;
		MapEditLDFlags8: TCheckBox;
		MapEditLDFlags9: TCheckBox;
		MapEditLDFlags10: TCheckBox;
		MapEditLDFlags11: TCheckBox;
		MapEditLDFlags12: TCheckBox;
		MapEditLineDefsActivate: TComboBox;
		MapEditThingAngle: TEdit;
		MapEditThingX: TEdit;
		MapEditThingY: TEdit;
		MapEditType: TEdit;
		MapEditThingFlags1: TCheckBox;
		MapEditThingFlags2: TCheckBox;
		MapEditThingFlags4: TCheckBox;
		MapEditThingFlags3: TCheckBox;
		MapEditThingFlags5: TCheckBox;
		MapThingsApply: TButton;
		MapEditThingFlags9: TCheckBox;
		MapEditThingFlags10: TCheckBox;
		MapEditThingFlags8: TCheckBox;
		MapEditThingFlags7: TCheckBox;
		MapEditThingFlags6: TCheckBox;
		MapEditThingFlags11: TCheckBox;
		MapEditLineDefArg1: TEdit;
		MapEditLineDefArg2: TEdit;
		MapEditLineDefArg3: TEdit;
		MapEditLineDefArg4: TEdit;
		MapEditLineDefArg5: TEdit;
		MapEditLineDefTag: TEdit;
		MapEditLineDefType: TEdit;
		MapEditThingZ: TEdit;
		MapEditSectorCeiling: TEdit;
		MapEditSectorFloor: TEdit;
		MapSectorApply: TButton;
		MapEditSectorFloorTex: TEdit;
		MapEditSectorCeilingTex: TEdit;
		MapEditSectorLight: TEdit;
		MapEditSectorType: TEdit;
		MapEditSectorTag: TEdit;
		MapSectorPrev: TButton;
		MapEditSector: TEdit;
		MapSectorNext: TButton;
		MapEditFrontSector: TEdit;
		MapEditBackSector: TEdit;
		Label8: TLabel;
		Label9: TLabel;
		LabelMapThingXYZ: TLabel;
		Label11: TLabel;
		Label12: TLabel;
		Label13: TLabel;
		Label14: TLabel;
		Label15: TLabel;
		Label16: TLabel;
		Label17: TLabel;
		Label18: TLabel;
		Label10: TLabel;
		Label19: TLabel;
		LabelMapSectorSideDefs: TLabel;
		MapImageCeiling: TImage;
		MapImageFloor: TImage;
		lblThing: TLabel;
		MapImageThing: TImage;
		MapListErrors: TListBox;
		MapPickThing: TBitBtn;
		MapPanelList: TPanel;
		MapListTypes: TListBox;
		MapListClasses: TListBox;
		MapListOK: TButton;
		MapListCancel: TButton;
		MapPickLineDef: TBitBtn;
		MapPickSector: TBitBtn;
		MapSectorDup: TButton;
		MapThingAngleRad000: TRadioButton;
		MapThingAngleRad045: TRadioButton;
		MapThingAngleRad090: TRadioButton;
		MapThingAngleRad135: TRadioButton;
		MapThingAngleRad180: TRadioButton;
		MapThingAngleRad225: TRadioButton;
		MapThingAngleRad270: TRadioButton;
		MapThingAngleRad315: TRadioButton;
		PanelMapWaded: TPanel;
		MapModeThings: TSpeedButton;
		MapModeLineDefs: TSpeedButton;
		MapModeAll: TSpeedButton;
		MapModeSectors: TSpeedButton;
		MapModeDraw: TSpeedButton;
		MapGridButton: TSpeedButton;
		MapGridButton2: TSpeedButton;
		MapEditThingSpecial: TEdit;
		MapEditThingArg1: TEdit;
		MapEditThingArg2: TEdit;
		MapEditThingArg3: TEdit;
		MapEditThingArg4: TEdit;
		MapEditThingArg5: TEdit;
		MapEditThingTag: TEdit;
		EditImageCursor: TEdit;
		MainMenu2: TMainMenu;
		tbFilter: TToolBar;
		tbFilterAll: TToolButton;
		tbFilterLumps: TToolButton;
		tbFilterGfx: TToolButton;
		tbFilterSprites: TToolButton;
		tbFilterSounds: TToolButton;
		tbFilterMusic: TToolButton;
		tbFilterMaps: TToolButton;
		tbFilterTextures: TToolButton;
		tbFilterPatches: TToolButton;
		tbFilterFloors: TToolButton;
		GridEditHeader: TEdit;
		WaveEdit: TEdit;
		LabelPaletteR: TLabel;
		LabelPaletteG: TLabel;
		LabelPaletteB: TLabel;
		Label1: TLabel;
		Label20: TLabel;
		Label21: TLabel;
		LabelPaletteH: TLabel;
		LabelPaletteS: TLabel;
		LabelPaletteL: TLabel;
		cmdImageWeapon: TButton;
    mnuWaveStop: TMenuItem;
		mnuMusic0: TMenuItem;
    mnuMusicConvertMIDI2MUS: TMenuItem;
    mnuPalettePickupEffect: TMenuItem;
    mnuFileJoin: TMenuItem;
    N1: TMenuItem;
    mnuPL_Replace: TMenuItem;
    mnuPL_ReplaceRaw: TMenuItem;
    mnuPaletteRadSuitEffect: TMenuItem;
    mnuColorMapInvulnerability: TMenuItem;
    mnuPalette3: TMenuItem;
    mnuMapImportRisen3D: TMenuItem;

		procedure FormCreate(Sender: TObject);

		procedure mnuFileOpenClick(Sender: TObject);
		procedure mnuFileMRUClick(Sender: TObject);
		procedure mnuFileExitClick(Sender: TObject);
		procedure mnuViewEntryListClick(Sender: TObject);
		procedure mnuTextScreenFillClick(Sender: TObject);
		procedure mnuImageApplyClick(Sender: TObject);
		procedure mnuHexViewBytesClick(Sender: TObject);
		procedure mnuHexViewWordsClick(Sender: TObject);
		procedure mnuFileNewClick(Sender: TObject);
		procedure mnuImageCompressClick(Sender: TObject);
		procedure mnuHelpAboutClick(Sender: TObject);
		procedure mnuFileCloseClick(Sender: TObject);
		procedure mnuEntrySaveAsClick(Sender: TObject);
		procedure mnuEntrySaveAsRawClick(Sender: TObject);
		procedure mnuPL_RenameClick(Sender: TObject);
		procedure mnuViewOptionsClick(Sender: TObject);
		procedure mnuTextureNewClick(Sender: TObject);
		procedure mnuTexturesSaveClick(Sender: TObject);
		procedure mnuTextureDeleteClick(Sender: TObject);
		procedure mnuTextureNewPatchClick(Sender: TObject);
		procedure mnuEntryNewClick(Sender: TObject);
		procedure mnuEntryReplaceClick(Sender: TObject);
		procedure mnuFileCleanUpClick(Sender: TObject);
		procedure mnuHelpContentsClick(Sender: TObject);
		procedure mnuEntryDeleteClick(Sender: TObject);
		procedure mnuFileMergeClick(Sender: TObject);
		procedure mnuPL_EditPositionClick(Sender: TObject);
		procedure mnuPL_EditSizeClick(Sender: TObject);
		procedure mnuTextureDuplicateClick(Sender: TObject);
		procedure mnuEditCopyClick(Sender: TObject);
		procedure mnuEditEmptyClipboardClick(Sender: TObject);
		procedure mnuEditPasteClick(Sender: TObject);
		procedure mnuPaletteDamageEffectClick(Sender: TObject);
		procedure mnuPaletteSaveClick(Sender: TObject);
		procedure mnuImageColorRemapClick(Sender: TObject);
		procedure mnuImagePerformColorRemapClick(Sender: TObject);
		procedure mnuColorRemapResetClick(Sender: TObject);
		procedure mnuPaletteGradientClick(Sender: TObject);
		procedure mnuPL_AddtoTextureClick(Sender: TObject);
		procedure mnuPL_NoFilterClick(Sender: TObject);
		procedure mnuPL_FilterClick(Sender: TObject);
		procedure mnuPL_FindSectorsClick(Sender: TObject);
		procedure mnuPatchNamesSaveClick(Sender: TObject);
		procedure mnuEntryRenameClick(Sender: TObject);
		procedure mnuEntryMoveUpClick(Sender: TObject);
		procedure mnuTextureDeletePatchClick(Sender: TObject);
		procedure mnuHexSaveClick(Sender: TObject);
		procedure mnuTextScreenSaveClick(Sender: TObject);
		procedure mnuEditUndoClick(Sender: TObject);
		procedure mnuEntryLoadClick(Sender: TObject);
		procedure mnuEntryMoveDownClick(Sender: TObject);
		procedure mnuWavePlayClick(Sender: TObject);
		procedure mnuPL_AddtoPNamesClick(Sender: TObject);
		procedure mnuScriptCompileClick(Sender: TObject);
		procedure mnuScriptSaveClick(Sender: TObject);

		procedure EditQuickFindChange(Sender: TObject);
		procedure ListWadSelectItem(Sender: TObject; Item: TListItem;
			Selected: Boolean);
		procedure EditQuickFindKeyPress(Sender: TObject; Var Key: Char);
		procedure FormResize(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure chkBrowsePanelClick(Sender: TObject);
		procedure UpDownImageZoomClick(Sender: TObject; Button: TUDBtnType);
		procedure GridTexturesSelectCell(Sender: TObject; ACol, ARow: Integer;
			Var CanSelect: Boolean);
		procedure GridTexturesKeyPress(Sender: TObject; Var Key: Char);
		procedure FormActivate(Sender: TObject);
		procedure chkTextScreenGridClick(Sender: TObject);
		procedure GridTexturePatchesKeyDown(Sender: TObject; Var Key: Word;
			Shift: TShiftState);
		procedure GridTexturesKeyDown(Sender: TObject; Var Key: Word;
			Shift: TShiftState);
		procedure GridTexturesSetEditText(Sender: TObject; ACol, ARow: Integer;
			const Value: String);
		procedure chkPaletteGridClick(Sender: TObject);
		procedure chkImageTileClick(Sender: TObject);
		procedure ImagePaletteMouseDown(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
		procedure GridTexturePatchesSetEditText(Sender: TObject; ACol,
			ARow: Integer; const Value: String);
		procedure PatchNamesListChange(Sender: TObject);
		procedure GridTexturePatchesKeyPress(Sender: TObject; Var Key: Char);
		procedure MemoHexChange(Sender: TObject);
		procedure ImagePaletteMouseMove(Sender: TObject; Shift: TShiftState; X,
			Y: Integer);
		procedure ImageTextScreenMouseDown(Sender: TObject;
			Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
		procedure TextScreenEditKeyDown(Sender: TObject; Var Key: Word;
			Shift: TShiftState);
		procedure ImageTextScreenMouseMove(Sender: TObject; Shift: TShiftState;
			X, Y: Integer);
		procedure ImageTextScreenColorsMouseDown(Sender: TObject;
			Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
		procedure ListWadKeyPress(Sender: TObject; Var Key: Char);
		procedure TextureQuickFindKeyPress(Sender: TObject; Var Key: Char);
		procedure EditMapZoomKeyPress(Sender: TObject; Var Key: Char);
		procedure EditMapZoomKeyDown(Sender: TObject; Var Key: Word;
			Shift: TShiftState);
		procedure ImageArtGridSelectCell(Sender: TObject; ACol, ARow: Integer;
			Var CanSelect: Boolean);
		procedure WaveScrollChange(Sender: TObject);
		procedure PanelWaveUpDownZoomClick(Sender: TObject;
			Button: TUDBtnType);
		procedure TextScreenEditKeyPress(Sender: TObject; Var Key: Char);
		procedure ScriptWordListKeyPress(Sender: TObject; Var Key: Char);
		procedure GridMainSelectCell(Sender: TObject; ACol, ARow: Integer;
			Var CanSelect: Boolean);
		procedure GridMainKeyDown(Sender: TObject; Var Key: Word;
			Shift: TShiftState);
		procedure ImageMapMouseMove(Sender: TObject; Shift: TShiftState; X,
			Y: Integer);
		procedure ImageMapMouseDown(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
		procedure UpDownPaletteZoomClick(Sender: TObject; Button: TUDBtnType);
		procedure PaletteEditKeyPress(Sender: TObject; Var Key: Char);
		procedure PaletteEditKeyDown(Sender: TObject; Var Key: Word;
			Shift: TShiftState);
		procedure PaletteScrollChange(Sender: TObject);
		procedure TextureSplitter1Moved(Sender: TObject);
		procedure BrowserSplitterMoved(Sender: TObject);
		procedure ImageRemapListDrawItem(Control: TWinControl; Index: Integer;
			Rect: TRect; State: TOwnerDrawState);
		procedure ImageRemapListDblClick(Sender: TObject);
		procedure ImageRemapListKeyPress(Sender: TObject; Var Key: Char);
		procedure ImageSplitterRemapMoved(Sender: TObject);
		procedure ImageMapMouseUp(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
		procedure mnuMapZoomInClick(Sender: TObject);
		procedure mnuMapZoomOutClick(Sender: TObject);
		procedure mnuMapZoomAllClick(Sender: TObject);
    procedure mnuMapSaveClick(Sender: TObject);
		procedure mnuMapCompileClick(Sender: TObject);
		procedure mnuMapUsedTexturesClick(Sender: TObject);
		procedure mnuTexturesCheckClick(Sender: TObject);
		procedure mnuGridSaveClick(Sender: TObject);
		procedure mnuGridAddLineClick(Sender: TObject);
		procedure mnuGridDeleteLineClick(Sender: TObject);
		procedure GridMainKeyPress(Sender: TObject; Var Key: Char);
		procedure mnuColorMapRebuildClick(Sender: TObject);
		procedure mnuColorMapSaveClick(Sender: TObject);
		procedure mnuTextScreenCopyClick(Sender: TObject);
    procedure mnuTextScreenCopyAreaClick(Sender: TObject);
    procedure mnuTextScreenPasteAreaClick(Sender: TObject);
		procedure mnuPopupMapNewSectorClick(Sender: TObject);
		procedure mnuColorMapDisplayGridClick(Sender: TObject);
		procedure mnuColorMapDisplayHorizontallyClick(Sender: TObject);
		procedure mnuPopupMapJoinLineDefsClick(Sender: TObject);
		procedure mnuPopupMapSplitLineDefsClick(Sender: TObject);
		procedure mnuPopupMapNewPolygonalSectorClick(Sender: TObject);
    procedure PanelImageEditYChange(Sender: TObject);
		procedure PanelImageEditXKeyPress(Sender: TObject; Var Key: Char);
		procedure mnuGridGotoLineClick(Sender: TObject);
		procedure mnuImageSelectPaletteClick(Sender: TObject);
    procedure mnuHexViewAsciiClick(Sender: TObject);
		procedure mnuPaletteUseClick(Sender: TObject);
		procedure mnuHexEditTextClick(Sender: TObject);
		procedure mnuMapRunClick(Sender: TObject);
    procedure mnuPaletteArrangeClick(Sender: TObject);
		procedure mnuImageSaveCurrentClick(Sender: TObject);
		procedure mnuEntryViewHexClick(Sender: TObject);
		procedure mnuImageSaveAllClick(Sender: TObject);
		procedure mnuMapGridIncClick(Sender: TObject);
		procedure mnuMapGridDecClick(Sender: TObject);
		procedure MapTextureApplyClick(Sender: TObject);
		procedure mnuDrawLineDefsJoinClick(Sender: TObject);
		procedure mnuDrawLineDefsSplitClick(Sender: TObject);
    procedure mnuDrawLineDefsFlipClick(Sender: TObject);
		procedure ImagePaletteDblClick(Sender: TObject);
    procedure mnuImageAutoCropClick(Sender: TObject);
    procedure mnuImageSaveClick(Sender: TObject);
		procedure mnuTexturePatchMoveUpClick(Sender: TObject);
		procedure mnuTexturePatchMoveDownClick(Sender: TObject);
		procedure ListWadDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListWadDragOver(Sender, Source: TObject; X, Y: Integer;
			State: TDragState; Var Accept: Boolean);
    procedure mnuWaveSaveClick(Sender: TObject);
		procedure WaveEditSampleRateChange(Sender: TObject);
		procedure ImageTextureMouseDown(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
    procedure ImageTextureMouseMove(Sender: TObject; Shift: TShiftState; X,
			Y: Integer);
    procedure ImageTextureMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
		procedure mnuPL_DeleteClick(Sender: TObject);
    procedure mnuDrawNewSectorClick(Sender: TObject);
		procedure EditImageZoomKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
		procedure mnuMusicPlayClick(Sender: TObject);
		procedure MapEditQuickFindChange(Sender: TObject);
    procedure MapEditQuickFindKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure mnuDrawThingsClick(Sender: TObject);
		procedure mnuDrawLineDefsClick(Sender: TObject);
		procedure mnuImageSaveFlatClick(Sender: TObject);
		procedure mnuMapTypeDoomClick(Sender: TObject);
		procedure mnuMapTypeZDoomClick(Sender: TObject);
		procedure mnuPopupMapNewThingClick(Sender: TObject);
		procedure MapThingsApplyClick(Sender: TObject);
		procedure mnuPopupMapFlipLineDefsClick(Sender: TObject);
		procedure mnuDrawSectorsClick(Sender: TObject);
		procedure MapSectorPrevClick(Sender: TObject);
		procedure MapSectorNextClick(Sender: TObject);
		procedure MapSectorApplyClick(Sender: TObject);
		procedure mnuDrawSplitSectorClick(Sender: TObject);
		procedure MapEditLDFlags3Click(Sender: TObject);
		procedure mnuPopupMapSelectFrontSectorClick(Sender: TObject);
		procedure mnuPopupMapSelectBackSectorClick(Sender: TObject);
    procedure mnuPaletteSaveAsClick(Sender: TObject);
    procedure MapEditThingAngleKeyPress(Sender: TObject; var Key: Char);
    procedure MapEditSectorTexKeyDown(Sender: TObject;
      var Key: Word; Shift: TShiftState);
    procedure MapEditSectorTexChange(Sender: TObject);
		procedure MapEditTypeChange(Sender: TObject);
    procedure MapEditTypeKeyPress(Sender: TObject; var Key: Char);
		procedure MapEditSectorTexKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
		procedure KeyPressUpperCase(Sender: TObject; var Key: Char);
    procedure MapEditSectorKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure MapEditSectorFloorTexChange(Sender: TObject);
		procedure MapEditKeyUp(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure MapEditKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure mnuMapCheckClick(Sender: TObject);
		procedure MapListErrorsClick(Sender: TObject);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mnuMapView3DClick(Sender: TObject);
		procedure mnuMapDisplayLinedefLengthsClick(Sender: TObject);
    procedure mnuMakeSectorClick(Sender: TObject);
		procedure ListWadKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mnuDrawDrawClick(Sender: TObject);
		procedure mnuMapViewGridClick(Sender: TObject);
		procedure MapPickThingClick(Sender: TObject);
		procedure MapListClassesClick(Sender: TObject);
		procedure MapListClassesDrawItem(Control: TWinControl; Index: Integer;
			Rect: TRect; State: TOwnerDrawState);
    procedure MapListTypesDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
		procedure MapListCancelClick(Sender: TObject);
    procedure MapListOKClick(Sender: TObject);
		procedure MapPickLineDefClick(Sender: TObject);
    procedure MapPickSectorClick(Sender: TObject);
		procedure mnuMapConfigClick(Sender: TObject);
		procedure mnuMapFixAllErrorsClick(Sender: TObject);
    procedure mnuDrawVertexClick(Sender: TObject);
    procedure mnuDrawAllClick(Sender: TObject);
    procedure MapSectorDupClick(Sender: TObject);
		procedure MapEditThingAngleChange(Sender: TObject);
		procedure MapThingAngleRad000Click(Sender: TObject);
		procedure MapThingAngleRad045Click(Sender: TObject);
    procedure MapThingAngleRad090Click(Sender: TObject);
    procedure MapThingAngleRad135Click(Sender: TObject);
		procedure MapThingAngleRad180Click(Sender: TObject);
    procedure MapThingAngleRad225Click(Sender: TObject);
    procedure MapThingAngleRad270Click(Sender: TObject);
    procedure MapThingAngleRad315Click(Sender: TObject);
    procedure mnuSelectionDeleteClick(Sender: TObject);
    procedure mnuSelectionDuplicateClick(Sender: TObject);
    procedure mnuMapViewWadedBarClick(Sender: TObject);
    procedure MapModeAllClick(Sender: TObject);
    procedure MapModeThingsClick(Sender: TObject);
		procedure MapModeLineDefsClick(Sender: TObject);
    procedure MapModeSectorsClick(Sender: TObject);
    procedure MapModeDrawClick(Sender: TObject);
    procedure MapGridButtonClick(Sender: TObject);
    procedure mnuMusicStopClick(Sender: TObject);
    procedure MapListTexturesKeyPress(Sender: TObject; var Key: Char);
		procedure mnuColormapRebuildSpClick(Sender: TObject);
		procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
    procedure EditImageCursorKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
    procedure mnuImageEditClick(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure EditImageCursorKeyPress(Sender: TObject; var Key: Char);
		procedure mnuViewMenuBarClick(Sender: TObject);
    procedure mnuMapViewPropertiesBarClick(Sender: TObject);
    procedure mnuPL_FilterSubClick(Sender: TObject);
		procedure tbFilterAllClick(Sender: TObject);
		procedure tbFilterClick(Sender: TObject);
    procedure mnuViewFilterToolbarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
		procedure EditQuickFindKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mnuViewStatusBarClick(Sender: TObject);
    procedure MapEditTextureKeyPress(Sender: TObject; var Key: Char);
    procedure MapEditFrontAboveEnter(Sender: TObject);
		procedure MapEditFrontMainEnter(Sender: TObject);
		procedure MapListTexturesDblClick(Sender: TObject);
    procedure MapEditFrontBelowEnter(Sender: TObject);
    procedure MapEditBackAboveEnter(Sender: TObject);
    procedure MapEditBackMainEnter(Sender: TObject);
    procedure MapEditBackBelowEnter(Sender: TObject);
    procedure PanelImageEditXKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WaveEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WaveEditKeyPress(Sender: TObject; var Key: Char);
    procedure PanelWaveImageMouseDown(Sender: TObject;
			Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PanelWaveImageMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure PanelWaveImageMouseUp(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
    procedure MapEditSectorKeyPress(Sender: TObject; var Key: Char);
		procedure ListWadCustomDrawItem(Sender: TCustomListView;
			Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
		procedure EditMapZoomKeyUp(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure ListWadColumnClick(Sender: TObject; Column: TListColumn);
		procedure mnuPL_ChangeTypeClick(Sender: TObject);
    procedure mnuEditCutClick(Sender: TObject);
    procedure ListWadDblClick(Sender: TObject);
		procedure MemoHexKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MapEditSectorTagKeyPress(Sender: TObject; var Key: Char);
    procedure mnuFileTexturesClick(Sender: TObject);
    procedure MapEditSectorFloorTexKeyPress(Sender: TObject;
      var Key: Char);
    procedure MapImageFloorDblClick(Sender: TObject);
    procedure MapImageCeilingDblClick(Sender: TObject);
    procedure TextureSplitter2Moved(Sender: TObject);
		procedure TextureQuickFindKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
    procedure mnuMapViewShowThingsClick(Sender: TObject);
    procedure mnuScriptGotoLineClick(Sender: TObject);
    procedure mnuEntryLoadRawClick(Sender: TObject);
    procedure mnuEntryReplaceRawClick(Sender: TObject);
    procedure mnuImagePNGCheckClick(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
		procedure cmdImageWeaponClick(Sender: TObject);
    procedure MemoHexMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MemoHexKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mnuWaveStopClick(Sender: TObject);
    procedure mnuMusicConvertMIDI2MUSClick(Sender: TObject);
    procedure mnuPalettePickupEffectClick(Sender: TObject);
    procedure mnuFileJoinClick(Sender: TObject);
    procedure mnuPL_ReplaceClick(Sender: TObject);
    procedure mnuPL_ReplaceRawClick(Sender: TObject);
    procedure ScriptWordListDblClick(Sender: TObject);
    procedure ScriptWordListExit(Sender: TObject);
    procedure ListWadMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListWadMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PanelImageEditXExit(Sender: TObject);
    procedure PanelImageEditYExit(Sender: TObject);
    procedure mnuPaletteRadSuitEffectClick(Sender: TObject);
		procedure mnuColorMapInvulnerabilityClick(Sender: TObject);
    procedure mpMusicNotify(Sender: TObject);
    procedure EditImageZoomKeyPress(Sender: TObject; var Key: Char);
    procedure mnuImageWeaponCropClick(Sender: TObject);
    procedure mnuMapImportRisen3DClick(Sender: TObject);
		//
	private
		//----------------------------------------------------------
		// Internal variables
		//
		// windows specific hacks
		bNoFileAssociations : Boolean; // if true, don't touch file associations
		bNoRegistry : Boolean; // if true, don't touch registry
		bNoMRU : Boolean; // if true, don't use MRU
		//
		isModified : Boolean; // is current entry modified
		isFileModified : Boolean; // is current file modified
		bSelectItemCancel : Boolean; // to prevent selectitem event
		iSelectItemCancel : Integer; // index of one to be skipped
		bBusy : Boolean; // to prevent move up/down bug?
		//
		DefaultWindowProc : TWndMethod;
		MutexHandle : THandle;
		//
		{$IFDEF FULLVERSION}
		LastEntryPos : Integer; // for GRP and EOB1 files
		{$ENDIF}

		// Filter
		sListWadFilter, sListWadNewFilter : String;
		iLastFilterClick : Cardinal;

		// For window position
		LastLeft, LastWidth, LastTop, LastHeight : Integer;

		// *** Undo, ClipBoard
		nUndo, nClipBoard : Integer;
		sLastUndo : String;
		sUniqueID : String;

		// ****************************
		iWadEntryCurrentPos : Longint; // currently showing entry position in list
		iWadEntryCurrentIndex : Longint; // currently showing entry index
		iWadEntryLastPos : Longint; // last showed entry position in list
		//
		{$IFDEF FULLVERSION}
		iDAS_N1, iDAS_N2 : Word; // ROTH DAS counter
		iDAS_Pos : Longint; // ROTH DAS position & length table pointer
		iREZ_Folders : Integer; // REZ Files: folder recursion
		nREZ_FolderPointers : Array [ 0 .. 255 ] Of Longint; // REZ Files
		nREZ_FolderLength : Array [ 0 .. 255 ] Of Longint; // REZ Files
		sREZ_FolderName : Array [ 0 .. 255 ] Of String; // REZ Files
		iRID_Pos : Longint; // Eradicate texture names pos
		iUnrealExportTable : Array [ 0 .. 511 ] Of Integer; // Unreal Export Table
		iLAB_FileNameTable : Integer; // LAB files - Outlaw
		iXPR_DirLen : Integer; // XPR directory length
		iAAR_EntriesAdded, iAAR_EntriesInc : Integer;
		iJFK_DirPos : Integer; // JFK second dir pos
		{$ENDIF}

		//
		ClipBoard : TClipboard;

		// ****************************
		iWadEntryType : Integer; // for section checks
		iWadEntryDetected : Integer; // for late detection

		// ****************************
		nWadEntryCols : Integer;
		WadEntryCols : Array [ 1 .. 1024 ] Of TWadEntryCols;

		// ****************************
		nConstants : Integer;
		Constants : Array [ 1 .. 1024 ] Of TConstants;

		// ****************************
		nConstantValues : Integer;
		ConstantValues : Array [ 1 .. 20000 ] Of TConstantValues;

		// *** Icons
		nIcons : Integer;
		Icons : Array [ 1 .. 255 ] Of String;

		// *** Palette used for rendering images
		PaletteReady : Boolean; // false at first

		// ***General
		CurrentEditor : TEditor;

		// ***Hex Editor
		iHexView : Integer; // 0=text (editable), 1=bytes, 2=words, 3=ascii

		// ***GridEditor
		GridType : Integer;
		GridRecSize : Integer;

		// ***Wave Editor
		bWaveExportable : Boolean; // if false, save lump as is
		iWaveDataSize : Integer; // data in bytes
		iWaveDataLength : Integer; // sample length
		iWaveLen : Integer; // length in samples
		iWaveSampleRate : Integer;
		iWaveChannels : Integer; // 1 = mono, 2 = stereo
		iWaveBits : Integer; // 1 = 8bits, 2 = 16bits
		sWaveFormat : String; // format string
		sWaveExtra : String; // extra wave data
		WaveData : PWave;
		//
		iWaveEditor_y : Integer; // where it's drawn
		iWaveLastX, iWaveLastY : Integer; // last position
		bWaveEditorDrawing : Boolean; // true when drawing with mouse

		// ***Music Editor
		MusicFormat : TMusicFormat;

		// *** Image Editor
		Image_xc, Image_yc : Integer; // center point
		Image_scroll_x, Image_scroll_y : Integer;
		//
		Image_Weapon : Boolean;
		//
		ImageCurX, ImageCurY : Integer;
		ImageCurColor : Integer; // 0 - 255
		ImageDragX, ImageDragY,
		ImageLastX, ImageLastY : Integer; // for dragging
		//
		ImageRemap : Array [ 0 .. 255 ] Of Integer;
		//
		ImageOnlyAlignmentModified : Boolean;

		// *** Texture Editor
		LastTexture : Integer;
		//
		iTexture_xc, iTexture_yc : Integer; // x,y pos of current texture
		TextureZoom : Double; // zoom value
		//
		iTextureDragX, iTextureDragY : Integer; // for dragging
		iTextureLastX, iTextureLastY : Integer;

		// *** Palette Editor
		PaletteSel : Array [ 0 .. 255 ] Of Boolean; // selection flag
		iPalette : Integer; // currently edited palette
		Palette_x, Palette_y : Integer; // cursor, 8 * 32
		Palette_xb, Palette_yb : Integer; // cursor anchor for selection
		Palette_xPos, Palette_yPos : Integer; // position of current palette

		// *** ColorMap Editor
		nColorMaps : Integer;
		ColorMaps : Array [ 0 .. 33, 0 .. 255 ] Of Byte;

		// *** Map Editor
		nThings : Integer;
		Things : Array [ 0 .. 10000 ] Of TThing;
		//
		nLineDefs : Integer;
		LineDefs : Array [ 0 .. 60000 ] Of TLineDef;
		//
		nSideDefs : Integer;
		SideDefs : Array [ 0 .. 60000 ] Of TSideDef;
		//
		nVertex : Integer; // zero indexed
		Vertex : Array [ 0 .. 60000 ] Of TVertex;
		Vertex_sx, Vertex_sy, Vertex_lx, Vertex_ly : Integer;
		//
		nSectors : Integer;
		Sectors : Array [ 0 .. 10000 ] Of TSector;
		//
		MapLoaded : Boolean; // if false, we're in "preview" mode
		//
		MapHighlight : Integer;
		MapGrid : Integer; // 64 is default
		MapX, MapY : Integer; // Map left/top position
		MapZoom : Double; // in percent
		Map3DX, Map3DY : Double; // for axonometric 3D view
		MapLastX, MapLastY : Integer; // "last" position on map (move)
		MapClickX, MapClickY : Integer; // mousedown position (map coords)
		MapClickXP, MapClickYP : Integer; // drag position difference
		MapDragX, MapDragY : Integer; // mousedown last drag position
		MapDownX, MapDownY : Integer; // mousedown position (screen coords)
		{
		MapDragging : Boolean; // if true, user is dragging
		MapSelecting : Boolean; // if true, user is selecting
		}
		MapQuickDraw : Boolean; // if true, draw map faster
		MapCanDrag : Boolean; // if true, mousemove will cause drag
		MapCanSelect : Boolean; // if true, mousemove will cause select
		MapRefreshed : Boolean; // for real-time drawn things
		MapColors : Array [ mapColorFirst .. mapColorLast ] Of Integer;
		MapModified : Boolean; // if true, we need to re-compile the map
		//
		MapType : TMapType;
		MapMode, MapPanelShowing : TMapMode;
		PrevMapMode : TMapMode;
		MapLastVertex : Integer; // for drawing
		MapLastSelectedLineDef : Integer; // for Join
		bMapConfigInit : Boolean; //
		//
		MapLastPolygonSides,
		MapLastPolygonRadius : Integer; // for new Poly sector
		//
		MapLastThingType : Integer; // for New Thing procedure
		MapLastThingAngle : Integer;
		//
		MapList : String; // which type of list is displayed
		//
		MapLineDefTextureBox : Integer; // 1 - 6 of texture boxes

		// *** XWEScript
		nXSLoops : Integer;
		XSLoops : Array [ 1 .. 16 ] Of TXSLoop;
		nXSCalls : Integer;
		XSCalls : Array [ 1 .. 16 ] Of TXSCall;

		// *** ScriptEditor
		ScriptMemo : TMemo;    // dynamic control (if codemax is not installed)
		ScriptCMax : TCodeMax; // dynamic control (if codemax is installed)
		bHasCodeMax : Boolean; // if true, user has CodeMax 2.0 Control
		bScriptInit : Boolean; // false until first script is opened
		ScriptKeyWordLine : String; // Original line before keyword lookup
		ScriptCurX,
		ScriptCurY : Integer; // Cursor position before keyword lookup
		ScriptKeyWordPos,
		ScriptKeyWordLen : Integer; // For Keyword lookups
		ScriptLanguage : String; // Current language in the script editor
		// CodeMax persistence
		CMaxFontString : String;
		bCodeMaxSyntaxHighlighting : Boolean;

		// global Patch and Texture index
		main_TIndex, main_PIndex, main_TextureAddCount : Integer;
		main_bSavePatch : Boolean;

		// ***TextScreen Editor
		TextScreen_sx, TextScreen_sy : Integer; // screen size (80x25)
		TextScreen_bsx, TextScreen_bsy : Integer; // buffer size (for copy/paste)
		TextScreen_px, TextScreen_py : Integer; // pixel size
		TextScreen_bx, TextScreen_by : Integer; // base position (for select)
		TextScreen_x, TextScreen_y : Integer; // cursor position
		TextScreen_bc, TextScreen_fc : Integer; // back and fore colors
		TextScreen_char : Integer; // for Drawing
		TextScreenColorWidth : Integer; // size of color selection boxes
		TextScreen, TextScreenBuffer : Array [ 0 .. 79, 0 .. 24, 0 .. 1 ] Of Byte; // text screen data

		// ***ArtEditor/BspEditor/WaxEditor
		{$IFDEF FULLVERSION}
		ImgType : TImgType;
		Imgs : Array [ 1 .. MaxImg ] Of TImg;
		{$ENDIF}

		// ***Scripts
		nScripts : Integer;
		Scripts : Array [ 1 .. MaxScripts ] Of TScript;
		ScriptLines : TStringList;

		sLastFolderXWEScript : String;

		// *** Importing
		sLastFolderImport : String;

		// *** Exporting
		sLastFolderExport : String;

		// Misc. Status Procedures
		crCount : Integer;
		crSave : TCursor;

		//
		bDontClick : Boolean;

		{$IFDEF FULLVERSION}
		// Zip
		ZipDllsLoaded : Boolean;
		{$ENDIF}

		{ Private declarations }
		{$IFDEF USEDEBUG}
		df : TextFile;
		bDebug : Boolean;
		procedure StartDebug;
		procedure EndDebug;
		procedure DoDebug ( s : String );
		procedure DoDebugLn ( s : String );
		{$ENDIF}

		procedure FormWindowProc ( var Message : TMessage );
		procedure HandleDroppedFiles ( var Msg : TMessage );

		function ExecuteFile(const FileName, Params, DefaultDir: string;
			ShowCmd: Integer): THandle;
		Function ExecAndWait ( const Filename, Params: string;
			WindowState: word): Boolean;

		Function IsFileOpen : Boolean;

		Function La ( s : String; d : Longint ) : String;
		Function TrimString ( s : String ) : String;
		Function MatchSignature ( iEntry : Integer; s : String ) : Boolean;

		Function IsMapFlag ( s : String ) : Boolean;
		Function IsMapResource ( s : String ) : Boolean;

		Procedure ShowPage ( iEditorPage : TEditor );
		Procedure UpdateSelection;

		//--- Undo and Clipboard functions
		Procedure DeleteTempFiles ( sFolder, sMask : String );
		Procedure ResetUndo;
		Procedure SaveUndo ( s : String );
		Function GetTempFileName ( n : Integer; bUndo : Boolean ) : String;
		Procedure ClipboardEmpty;

		//---
		{$IFDEF FULLVERSION}
		Procedure MenuModifyFunctions ( bEnable : Boolean );
		{$ENDIF}
		Procedure MenuFileFunctions ( bEnable : Boolean );

		//---
		Procedure GridEditor ( i : Integer; bFocus : Boolean );
		Function GridSave : Boolean;

		//---
		Procedure HexDump;
		procedure HexViewChange ( iNewMode : Integer );
		Function HexSave : Boolean;
		procedure MemoHexUpdateCursorPos;

		//---
		Procedure DrawRect ( c : TCanvas; x, y, xs, ys : Integer );
		Procedure TextScreenCursor ( Show : Boolean );
		Procedure TextScreenSelection ( Show : Boolean );
		Procedure TextScreenLoad;
		Procedure TextScreenRefreshColors;
		Procedure TextScreenRefresh;
		Procedure TextScreenRefreshChar ( x, y : Integer );
		Procedure TextScreenEditor ( bFocus : Boolean );
		Function TextScreenSave : Boolean;

		//---!MAPEDITOR
		Procedure MapEditor ( bFocus : Boolean );
		Procedure MapRenderThing ( iType, x, y, Angle : Integer );
		Procedure MapRenderVertex ( x, y : Integer );
		Procedure MapDrawSelection ( X, Y : Integer );
		Function MapZoomStep : Double;
		Procedure MapSetZoom ( Zoom : Double );
		Procedure MapZoomIn;
		Procedure MapZoomOut;
		Procedure MapZoomAll;
		Procedure MapCenter ( x0, y0, x1, y1 : Integer );
		Procedure MapGridInc;
		Procedure MapGridDec;
		Procedure MapRefresh;
		Procedure MapDeselectAll;
		Procedure MapDeHighlightAll;
		Function MapSelect ( x, y : Integer; bSelect, bMulti, bCheckHit : Boolean ) : Boolean;
		Procedure MapSelectSector ( iSector : Integer; bSelect, bHighlight : Boolean );
		Procedure MapSelectOneSector ( iSector : Integer );
		Procedure MapSelectArea ( x1, y1, x2, y2 : Integer );
		Procedure MapLoad ( iEntry : Integer; bFullLoad : Boolean );
		Procedure DoMapLoad;
		Function MapSave ( iEntry : Integer ) : Boolean;
		procedure MapCompile ( iEntry : Integer );
		Procedure MapCheckErrors;
		Procedure CoordsMapToScreen ( Var x, y : Integer );
		Procedure CoordsScreenToMap ( Var x, y : Integer );
		Procedure CoordsSnapToGrid ( Var x, y : Integer );
		Function MapVertexFind ( x, y : Integer ) : Integer;
		Function MapVertexAddNew ( x, y : Integer ) : Integer;
		Function MapVertexAdd ( x, y : Integer ) : Integer;
		procedure MapVertexDelete ( iVertex : Integer );
		Procedure MapVertexReplace ( iUseVertex, iDontUseVertex : Integer );
		Procedure MapSideDefAdd;
		Procedure MapSideDefAddSectorMain ( iSector : Integer; sMain : String );
		Function MapSideDefDuplicate ( iSideDef : Integer ) : Integer;
		Procedure MapSideDefDelete ( iSideDef : Integer );
		Procedure MapLineDefDuplicate ( iLineDef, VertexS, VertexE : Integer );
		procedure MapLineDefDelete ( i : Integer );
		Function MapLineDefGetAngle ( iLineDef : Integer ) : Integer;
		Function MapLineDefGetLength ( iLineDef : Integer ) : Integer;
		Function MapVertexDistance ( v1, v2 : Integer ) : Integer;
		Procedure MapJoinLineDefs;
		procedure MapSplitLineDef ( iLineDef : Integer );
		procedure MapSplitLineDefs;
		procedure MapSplitLineDef3 ( iLineDef, MiddleLength : Integer );
		procedure MapSplitLineDefs3;
		Procedure MapFlipLineDefs;
		Procedure MapFindSelectionExtent ( Var x0, y0, x1, y1 : Integer );
		Procedure MapFlip ( bHorizontal : Boolean );
		Procedure MapRotate ( bRight : Boolean );
		Procedure MapAutoAlignSelection;
		procedure MapDeleteThing ( i : Integer );
		procedure MapDeleteSelected;
		procedure MapDuplicateSelected ( x, y : Integer );
		procedure MapSectorAdd;
		procedure MapSectorDuplicate ( iSector : Integer );
		procedure MapSectorDelete ( iSector : Integer );
		procedure MapNewSector ( iSides, iRadius : Integer );
		procedure MapMakeSector ( x, y : Integer );
		Function MapFindNextUnusedSectorTag : Integer;
		procedure MapLineCheckIntersect ( iLineDef : Integer );
		Function MapLineIntersect ( Ax, Ay, Bx, By, Cx, Cy, Dx, Dy : Integer; Var Px, Py : Integer ) : Boolean;
		//
		Procedure MapCheckInt ( Var i : TValue; iValue : Integer );
		Procedure MapCheckString ( Var s : String; sValue : String );
		Procedure MapSetInt ( Var i : Integer; Var iValue : TValue );
		Function MapGetValue ( e : TEdit ) : TValue;
		Procedure MapSetValue ( e : TEdit; iValue : TValue );
		//
		Procedure MapSetString ( Var s : String; sValue : String );
		Procedure MapCheckFlag ( c : TCheckBox; i : Integer; Var FlagOr, FlagAnd : Integer );
		Procedure MapUpdateLineDefProperties ( b : Boolean );
		Procedure MapUpdateThingProperties;
		Procedure MapUpdateSectorProperties;
		Procedure MapShowPanel ( Panel : TMapMode );
		Procedure MapSetModeInit ( m : TMapMode );
		Procedure MapSetMode ( m : TMapMode );
		Procedure MapModeSave;
		Procedure MapModeRestore;
		procedure MapConfigSelect ( s : String );
		Function MapFindLineDefByVertex ( iVertex : Integer; bStart : Boolean; iStartLineDef : Integer ) : Integer;
		Function MapLineDefFrontSector ( iLineDef : Integer ) : Integer;
		Function MapLineDefBackSector ( iLineDef : Integer ) : Integer;
		Procedure MapTexturesRefresh;
		Procedure MapFlatsInit;
		Function MapTextureFind ( s : String ) : Integer;
		Procedure MapThingImageRender ( sSpriteName : String );
		procedure MapTypeRefresh;
		procedure MapListTypesUpdate ( iSelect : Integer );
		procedure MapListShow ( sObject, sID : String );
		//
		procedure MapViewPropertiesBarRefresh;
		procedure MapViewGridClick;
		//
		Procedure MapProcessSectors;
		Function MapPointInWhichSector ( x, y : Integer ) : Integer;
		Function MapPointInSector ( iSector, x, y : Integer ) : Boolean;
		Function PointInPolygon ( Polygon : TPolygon; n : Integer; p : TPoint ) : Boolean;
		//
		Procedure MapLineDefTextureDehighlight;
		Procedure MapLineDefTextureHighlight ( Index : Integer );
		Function MapListTextureEditBox ( Index : Integer ) : TEdit;
		//
		Procedure MapRunXWEScript ( sFileName : String );
		//
		procedure MapFloorBrowse(e: TEdit);
		//
		Procedure ThingsLoad ( iEntry : Integer );
		Procedure SideDefsLoad ( iEntry : Integer );
		//
		Procedure LineDefsLoad ( iEntry : Integer );
		Procedure LineDefsEditor;
		Procedure LineDefsRefresh;
		//
		Procedure VertexCalcRange;
		Procedure VertexCoords ( nV : Integer; Var x, y : Integer );
		Procedure VertexLoad ( iEntry : Integer );
		Procedure VertexEditor;
		//
		Procedure SectorLoad ( iEntry : Integer );

		//---
		Function ScriptSave : Boolean;
		Procedure ScriptEditor ( sEditorType : String; bFocus : Boolean );
		Function ScriptEditorCreateCodeMax : Boolean;
		Procedure ScriptEditorClear;
		Procedure ScriptEditorAddLine ( sLine : String );
		Function ScriptEditorGetLine ( iLine : Integer ) : String;
		Function ScriptEditorLineCount : Integer;
		Function ScriptEditorGetKeyWord ( s : String ) : String;
		Procedure ScriptShowWordList ( x, y : Integer );
		Procedure ScriptPickFromList ( i : Integer );
		Procedure ScriptFindKeyWord ( iStartPos : Integer );

		Function ScriptMemoUpdateCursorPos : Integer;
		Procedure ScriptMemoKeyDown ( Sender: TObject; Var Key : Word; Shift: TShiftState );
		Procedure ScriptMemoKeyUp ( Sender: TObject; Var Key : Word; Shift: TShiftState );
		Procedure ScriptMemoChange ( Sender : TObject );
		Procedure ScriptMemoOnEnter ( Sender : TObject );
		Procedure ScriptMemoMouseDown ( Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);

		Procedure ScriptCMaxChange ( Sender: TObject; const Control: ICodeMax );
		Procedure ScriptCMaxKeyDown ( Sender: TObject; const Control: ICodeMax;
			KeyCode, Shift: Integer; Var pbStop : WordBool );
		procedure ScriptCMaxKeyPress ( Sender: TObject; const Control: ICodeMax;
			KeyAscii, Shift: Integer; Var pbStop : WordBool );
		procedure ScriptCMaxSelChange ( Sender: TObject; const Control: ICodeMax );

		//---
		Procedure ImageShowMulti ( b : Boolean );
		{$IFDEF FULLVERSION}
		Procedure ArtEditor;
		Procedure ImgDisplayList;
		Procedure ArtImageLoad ( iIndex : Integer );
		Procedure ArtRenderImage ( iIndex : Integer );
		Procedure ArtRenderImageAt ( iIndex, xp, yp : Integer; Zoom : Double );
		Procedure ArtBrowse ( iStart : Integer );

		//---
		Procedure BspEditor;

		//---
		Procedure WaxEditor;

		//
		//Procedure RaptorDecode ( sFileName : String );
		{$ENDIF}

		// **********************

		//---
		Procedure PreparePalette;
		Procedure RGBtoHSL ( R, G, B : Double; Var H, S, L : Double );
		(*
		Procedure HSLtoRGB ( H, S, L : Double; Var R, G, B : Double );
		Function HuetoRGB ( m1, m2, h : Double ) : Double;
		*)

		//-----
		Procedure ImageEditor;
		Procedure ImageHideCursor;
		Procedure ImageDrawCursor;
		Procedure ImageDrawPalette;
		Procedure ImageUpdateSize;
		Procedure ImageUpdateAlignment;
		Procedure ImageCheckZoomSize;
		Function ImageGetDetails ( iEntry : Integer; Var x, y, xr, yr : Integer ) : Boolean;
		{Function ImageLoad_Old ( iEntry : Integer; c : TCanvas; xp, yp, Zoom : Integer ) : Boolean;}
		Function ImageConvertToDoom ( xs, ys, xr, yr : Integer ) : String;
		Function ImagePaletteMatch ( Color : Integer ) : Byte;
		Function ImagePaletteMatchRGB ( r, g, b : Byte ) : Byte;
		Function ImagePaletteMatchRGBRange ( r, g, b, iStart, iEnd : Byte ) : Byte;
		Function ImagePaletteMatchNew ( Color : Integer ) : Word;
		Function ImagePaletteMatchRGBNew ( r, g, b : Byte ) : Word;
		Function ImagePaletteMatchRGBRangeNew ( r, g, b, iStart, iEnd : Byte ) : Word;
		Function ImageGetZoom : Double;
		Procedure ImageRenderCurrent;
		Procedure ImageRenderCurrentPos ( xr, yr : Integer );
		Procedure ImageRenderCurrentAt ( c : TCanvas; xr, yr : Integer; Zoom : Double );
		Procedure ImageRefreshPanel;
		procedure ImageRemapReset;
		procedure ImageRemapCountColors;
		Function ImageSave : Boolean;
		Function ImageSaveFlat : Boolean;
		Procedure Image1DrawDragFrame ( x, y : Integer );

		//--
		Procedure SpeakerSound;

		//--
		Function MusicIdentifyFile ( sFN : String; iPos, iLen : Integer ) : TMusicFormat;
		Function MusicIdentify ( iPos, iLen : Integer ) : TMusicFormat;
		Procedure MusEditor;

		//--
		Function WaveSave : Boolean;
		Function WaveIdentifyFile ( sFN : String; iPos, iLen : Integer ) : TWaveFormat;
		Function WaveIdentify ( iLen : Integer ) : TWaveFormat;
		Procedure WaveEditor;
		Procedure WaveLoad ( sFileName : String; iEntry : Integer );
		Procedure WaveEditorRefresh;
		Procedure WaveEditorUpdateHeader;
		Procedure WaveGetMem ( DataSize : Integer );
		Procedure WaveFreeMem;
		procedure WaveReverseByteOrder;
		Procedure SetWaveDataHeader ( i : Integer; d : Cardinal );

		//--
		Procedure DemoEditor;
		Procedure MapDisplayDemo ( sEntry : String );

		//--
		Function PaletteSave : Boolean;
		Procedure PaletteRefresh;
		Procedure PaletteRefreshColor ( iPal, iCol : Integer );
		Procedure PaletteEditor ( bFocus : Boolean );
		Procedure PaletteCursor ( bShow : Boolean );
		Procedure PaletteGetCoords ( Var x, y : Integer );
		Function PaletteGetZoom : Integer;
		Function PaletteToRGB ( iPal, iCol : Integer ) : Integer;
		Function PaletteSelectionColor ( iPal, iCol : Integer ) : Integer;
		procedure PaletteSelectAll ( bSelect : Boolean );
		Procedure PaletteBeforeCursorMove ( Shift : TShiftState );
		Procedure PaletteCursorMoved ( Shift : TShiftState );

		//--
		Procedure ColorMapRefresh;
		Procedure ColorMapEditor;
		procedure ColormapRebuild ( iStart, iEnd, iUseStart, iUseEnd : Integer; r0,g0,b0 : Byte; Steps : Integer );
		Function ColorMapSave : Boolean;

		//--
		Procedure PatchNamesForceLoad; // creates new if needed, returns in main_PIndex
		Function PatchNamesSave : Boolean;
		Function PatchNamesSaveData : Boolean;
		Function PatchNamesSaveFromList : Boolean;
		Procedure PatchNamesEditor ( bFocus : Boolean );

		//--
		procedure TextureInit;
		procedure TextureLoadFromFile ( iPos : Integer );
		Procedure TextureForceLoad;
		Procedure TextureAdd ( Index : Integer );
		procedure TextureLoad ( iEntry : Integer );
		Procedure UpdateTexture ( iTexture : Integer );
		Function TextureSave : Boolean;
		Function TextureSaveData : Boolean;
		Procedure TextureEditor ( bFocus : Boolean );
		procedure TextureShow ( n : Integer );
		procedure TextureDraw ( n : Integer );
		procedure TextureDrawCanvas ( n : Integer; Zoom : Double; c : TCanvas );
		Procedure TexturePatchesSwap ( i1, i2 : Integer );
		Function PatchName ( n : Integer ) : String;
		Function PatchNameByID ( ID : Integer ) : String;
		Function PatchFind ( s : String ) : Integer;
		Function PatchCurrentID : Integer;
		Procedure TextureDrawDragFrame ( x, y : Integer );

		// Misc. Status Procedures
		procedure Starting;
		procedure Status ( s : String );
		procedure StatusMode ( s : String );
		procedure Finished;

		procedure Modified ( New_isModified : Boolean );
		procedure FileModified ( New_isModified : Boolean );
		Function CheckModified : Boolean;
		Function CheckFileExtModified : Boolean;
		Function isFileExtModified : Boolean;
		procedure WarnFileExtModified;
		procedure UpdateModifiedDate;

		function FileLastModified ( const TheFile: String ) : String;

		// Wad Entry Operations
		procedure InitMainWad;
		Procedure ResetAll;
		function ReadWadHeader ( Var f : File; Var i1, i2 : Integer ) : Boolean;
		Procedure WadEntryIdentify ( iEntry : Integer );
		Procedure WadEntryIdentify2 ( iEntry : Integer );
		Procedure IdentifyAllEntries;
		Procedure WadEntryLoad ( Var f : File );
		Function LoadWadEntries : Boolean;
		Procedure OpenWad ( sFile : String; bQuiet : Boolean );
		Procedure ShowWadEntries;
		Procedure ReWriteDirectory ( bWriteToEnd : Boolean );
		Procedure SendWadEntry ( Var f : File; iPos, iSize : Integer; sName : String );
		Procedure SendWadEntryFromArray ( Var f : File; iEntry : Integer );
		procedure SendWadSignature;
		Procedure WriteWadEntry ( iEntry : Integer );
		Procedure SaveWadEntryName ( iEntry : Integer );
		Procedure WadFileCleanUp ( bQuiet : Boolean );
		Procedure WadFileAutoCleanUp;
		Procedure UpdateWadEntry ( iListEntry, iEntry : Integer );
		procedure UpdateWadList;
		Function EntryGetIndex ( iListEntry : Integer ) : Integer;
		Function EntryFindListIndex ( iEntry : Integer ) : Integer;
		Function FindTypeIndex ( sType : String ) : Integer;
		Procedure AddWadEntry ( iEntry : Integer );
		//procedure AddNewWadEntry ( sName : String );
		procedure WadEntryNew ( sName : String );
		procedure WadEntryNewAtPos ( sName : String; iEntry, iListEntry : Integer; bDontUpdateDirectory : Boolean );
		procedure WadEntryNewGetPos ( Var iEntry, iListEntry : Integer );
		procedure ListWadUpdateFilter;
		procedure ShowEntry ( sEditor : String; bFocus : Boolean );
		Function SaveEntry : Boolean;
		procedure EntryRename;
		Procedure EntryRenameByIndex ( iEntry : Integer; sName : String );
		procedure EntryDeleteSelected;
		Procedure WadEntriesMoveTo ( iDestPos, iDest : Integer );
		Procedure WadEntriesSwap ( l1, l2 : Integer; sUndo : String );
		Procedure ImportEntryFile ( iEntry : Integer; sFile : String; bUndo, bForceRaw : Boolean );
		procedure ImportEntries ( Strings : TStrings; bForceRaw : Boolean );
		Procedure ImportEntry ( bForceRaw : Boolean );
		procedure ReplaceEntry ( bForceRaw : Boolean );
		Procedure CopyEntryFromMain ( iEntry : Integer );
		//
		Procedure EntryToClipBoard ( iEntry : Integer );

		Function FindIcon ( IconName : String ) : Integer;
		//
		Procedure RefreshColumnHeaders;
		// ini files
		Procedure RegisterFileTypes;
		Procedure ReadInfo ( sInfoFileName : String );
		// constants
		Function ConstantFind ( ConstantName : String ) : Integer;
		Function ConstantFindIndex ( ConstantName : String; Index : Integer ) : Integer;
		Function ConstantFindDescription ( ConstantName : String; Value : Integer ) : String;
		Function ConstantFindByDescription ( ConstantName, Description : String ) : Integer;
		Procedure ConstantDelete ( ConstantName : String );
		Function ConstantAdd ( ConstantName, Fields : String ) : Integer;
		Function ConstantAddValue ( ConstantIndex : Integer; Description : String; Value : Integer ) : Integer;
		//
		Procedure ToolsGet ( sTool, sDefault : String; Var sPath, sExec, sParam : String );
		Function FindPal ( sPal : String ) : Integer;
		procedure InitPals;

		//
		Procedure ReplaceFile ( iEntry : Integer; sFN : String; bUndo, bRefreshList : Boolean );
		Procedure ReplaceFilePart ( iEntry : Integer; Var fx : File; iPos, iSize : Integer; bUndo : Boolean );

		//
		Procedure ExtractEntry ( iEntry : Integer; sExt : String );
		procedure ExportEntries ( bRaw : Boolean );
		Procedure ExportEntry ( iEntry : Integer; sFN : String; bRaw : Boolean );
		Function ExportFileName ( iEntry : Integer; sExt : String; bForce : Boolean ) : String;
		Function ExportGetFileName ( sName, sFilter, sExt : String ) : String;
		Function ExportGetFolder : String;
		Function ExportGetArtFileName : String;
		Function ForceExtension ( s, sExt : String ) : String;
		procedure SaveBMP ( iEntry : Integer; sFN : String );
		procedure SaveWav ( iEntry : Integer; sFN : String );
		procedure SaveLmp ( iEntry : Integer; sFN, sExt : String );

		//--- misc
		Procedure PanelsReset;
		Procedure PanelReset ( Panel : TPanel; Image : TImage );
		{Procedure UnrealIndex;}

		// General
		Function RemoveQuotes ( s : String ) : String;
		Function TypedKey ( Key : Word ) : Boolean;
		procedure Delay ( i : Cardinal );

		{$IFDEF FULLVERSION}
		Procedure ZipLoadDlls;
		Procedure LoadEOB3Names;
		Function LoadWolfAudioHeader : Integer;
		Procedure UnrealLoadNameTable;
		{$ENDIF}

	public
		{ Public declarations }
	end;

Var
	FormMain: TFormMain;

implementation

{$R *.DFM}

procedure TFormMain.FormCreate(Sender: TObject);
Var
	lc : TListColumn;
	i : Integer;
	s : String;

procedure LoadIcon ( sIcon : String );
Var
	s : String;
	b : TPicture;
Begin
	//
	s := Application.ExeName;
	s := Copy ( s, 1, PosR ( '\', s ) ) + 'images\' + sIcon + '.bmp';
	//
	If FileExists ( s ) Then
	Begin
		// Load new icon
		Inc ( nIcons );
		Icons [ nIcons ] := UpperCase ( WadEntryTypes [ i ].Icon );
		//
		b := TPicture.Create;
		b.LoadFromFile ( s );
		ilEntryType.AddMasked ( b.Bitmap, clAqua );
		b.Free;
	End;
End;

(*
function GetAlign ( sValue : String ) : TAlign;
Var
	Align : Integer;
Begin
	Align := ConstantFindByDescription ( 'OPTIONS', sValue );
	If ( Align = 0 ) Then
		GetAlign := alBottom;
	Else
		( Align
End;
*)

Procedure DefaultMapColors;
Begin
	MapColors [ mapColorGrid ] := RGB ( 0, 0, 96 );
	MapColors [ mapColorFloorGrid ] := RGB ( 0, 0, 192 );
	MapColors [ mapColorLines ] := RGB ( 255, 255, 255 );
	MapColors [ mapColorLinesTwoSided ] := RGB ( 128, 128, 128 );
	MapColors [ mapColorVertex ] := RGB ( 128, 128, 128 );
	MapColors [ mapColorHighlighted ] := RGB ( 255, 192, 128 );
	MapColors [ mapColorSelected ] := RGB ( 255, 0, 0 );
End;

Procedure DefaultOptions;
Begin
	DefaultMapColors;
	//
	gOpenLast := True; // default
	sTempFolder := GetEnvVarValue ( 'TEMP' );
	gAutoCleanUp := True;
	gAutoBackup := True;
	gPreviewMaps := True;
	gAutoPlaySounds := True;
	gDisableUndo := False;
	gRawPNG := True;
	gAssociations := assoc_WAD;
End;

procedure LoadOptions;
Var
	r : TRegistry;
	i : Integer;
Begin
	r := TRegistry.Create;
	r.RootKey := HKEY_CURRENT_USER;
	Try
		If r.OpenKey ( 'Software\Csabo\XWE', True ) Then
		Begin
			r.WriteString ( 'Version', VersionMajor + '.' + VersionMinor );
			//
			If r.ValueExists ( 'OpenLast' ) Then
			Begin
				gOpenLast := r.ReadBool ( 'OpenLast' );
			End;
			//
			If r.ValueExists ( 'CutCopyEmpty' ) Then
			Begin
				gCutCopyEmpty := r.ReadBool ( 'CutCopyEmpty' );
			End;
			//---
			If r.ValueExists ( 'TempFolder' ) Then
			Begin
				sTempFolder := r.ReadString ( 'TempFolder' );
			End;
			If sTempFolder <> '' Then
			Begin
				If sTempFolder [ Length ( sTempFolder ) ] <> '\' Then
					sTempFolder := sTempFolder + '\';
			End;
			If Not DirectoryExists ( sTempFolder ) Then
			Begin
				sTempFolder := GetEnvVarValue ( 'TEMP' );
			End;
			//
			//---
			If r.ValueExists ( 'OnlyOneBackup' ) Then
			Begin
				gOnlyOneBack := r.ReadBool ( 'OnlyOneBackup' );
			End;
			//
			If r.ValueExists ( 'AutoCleanUp' ) Then
			Begin
				gAutoCleanUp := r.ReadBool ( 'AutoCleanUp' );
			End;
			//
			If r.ValueExists ( 'AutoBackup' ) Then
			Begin
				gAutoBackup := r.ReadBool ( 'AutoBackup' );
			End;
			//
			If r.ValueExists ( 'PreviewMaps' ) Then
			Begin
				gPreviewMaps := r.ReadBool ( 'PreviewMaps' );
			End;
			//
			If r.ValueExists ( 'AutoPlaySounds' ) Then
			Begin
				gAutoPlaySounds := r.ReadBool ( 'AutoPlaySounds' );
			End;
			//
			If r.ValueExists ( 'DisableUndo' ) Then
				gDisableUndo := r.ReadBool ( 'DisableUndo' );
			//
			If r.ValueExists ( 'RawPNG' ) Then
				gRawPNG := r.ReadBool ( 'RawPNG' );
			//
			If r.ValueExists ( 'AutoApplyOffsets' ) Then
				gAutoApplyOffsets := r.ReadBool ( 'AutoApplyOffsets' );
			//
			If r.ValueExists ( 'ShowFullPath' ) Then
				gShowFullPath := r.ReadBool ( 'ShowFullPath' );
			If r.ValueExists ( 'ShowSize' ) Then
				gShowSize := r.ReadBool ( 'ShowSize' );
			If r.ValueExists ( 'ShowPosition' ) Then
				gShowPosition := r.ReadBool ( 'ShowPosition' );
			If r.ValueExists ( 'DontAutoCapitalize' ) Then
				gDontAutoCapitalize := r.ReadBool ( 'DontAutoCapitalize' );
			//
			If Not gShowSize Then
				gShowPosition := False;
			//
			If r.ValueExists ( 'Associations' ) Then
			Begin
				Try
					gAssociations := TAssociations ( r.ReadInteger ( 'Associations' ) );
				Except
					gAssociations := assoc_WAD;
				End;
			End
			Else
			Begin
				gAssociations := assoc_WAD;
			End;
			//
			//---
			//
			If r.ValueExists ( 'LastFolderImport' ) Then
			Begin
				sLastFolderImport := r.ReadString ( 'LastFolderImport' );
			End;
			//---
			If r.ValueExists ( 'LastFolderExport' ) Then
			Begin
				sLastFolderExport := r.ReadString ( 'LastFolderExport' );
			End;
			//---
			If r.ValueExists ( 'LastFolderXWEScript' ) Then
			Begin
				sLastFolderXWEScript := r.ReadString ( 'LastFolderXWEScript' );
			End;
			//--
			If r.ValueExists ( 'MapEditorPropertiesBar' ) Then
				mnuMapViewPropertiesBar.Checked := r.ReadBool( 'MapEditorPropertiesBar' );
			If r.ValueExists ( 'MapEditorWadedBar' ) Then
				mnuMapViewWadedBar.Checked := r.ReadBool( 'MapEditorWadedBar' );
			If r.ValueExists ( 'MapEditorGrid' ) Then
				mnuMapViewGrid.Checked := r.ReadBool( 'MapEditorGrid' );
			//
			If r.ValueExists ( 'ViewEntryList' ) Then
				mnuViewEntryList.Checked := r.ReadBool( 'ViewEntryList' );
			If r.ValueExists ( 'ViewMenuBar' ) Then
				mnuViewMenuBar.Checked := r.ReadBool( 'ViewMenuBar' );
			If r.ValueExists ( 'ViewFilterToolbar' ) Then
				mnuViewFilterToolbar.Checked := r.ReadBool( 'ViewFilterToolbar' );
			If r.ValueExists ( 'ViewStatusBar' ) Then
				mnuViewStatusBar.Checked := r.ReadBool( 'ViewStatusBar' );
			//
			// CodeMax persistence
			//
			CMaxFontString := 'FIXEDSYS;-12';
			If r.ValueExists ( 'CodeMaxFont' ) Then
				CMaxFontString := r.ReadString ( 'CodeMaxFont' );
			bCodeMaxSyntaxHighlighting := True;
			If r.ValueExists ( 'CodeMaxSyntaxHighlighting' ) Then
				bCodeMaxSyntaxHighlighting := r.ReadBool( 'CodeMaxSyntaxHighlighting' );
			//
			If r.ValueExists ( 'MapColor00' ) Then
			Begin
				For i := mapColorFirst To mapColorLast Do
				Begin
					If r.ValueExists ( 'MapColor' + Zero ( i, 2 ) ) Then
					Begin
						MapColors [ i ] := r.ReadInteger ( 'MapColor' + Zero ( i, 2 ) );
					End;
				End;
			End;
		End;
	Finally
		r.Free;
	End;
End;

Var
	mi : TMenuItem;

Begin
	// **************************************************************************
	// Main Init
	// **************************************************************************

	Randomize;

	bDebug := False;

	// Init Scripts
	nScripts := 0;
	ScriptLines := TStringList.Create;

	//
	s := ParamStr ( 0 );
	s := Copy ( s, 1, PosR ( '\', s ) );
	sExePath := s;
	ReadInfo ( s + 'xwe.ini' );
	//
	bNoFileAssociations := ConstantFindByDescription ( 'OPTIONS', 'NOFILEASSOCIATIONS' ) = 1;
	bNoRegistry := ConstantFindByDescription ( 'OPTIONS', 'NOREGISTRY' ) = 1;
	bNoMRU := ConstantFindByDescription ( 'OPTIONS', 'NOMRU' ) = 1;

	// Help File
	Application.HelpFile := s + 'XWE.HLP';

	// Icons & Menu
	For i := 1 To nWadEntryTypes Do
	Begin
		//
		mi := TMenuItem.Create ( Self );
		//
		mi.Caption := '(' + Zero ( i, 2 ) + ') ' + WadEntryTypes [ i ].Description;
		mi.OnClick := mnuPL_FilterSubClick;
		//
		mnuPL_FilterSub.Add ( mi );
		//
		// ---
		//
		s := WadEntryTypes [ i ].Icon;
		If s <> '' Then
		Begin
			If FindIcon ( s ) = 0 Then
			Begin
				LoadIcon ( s );
			End;
		End;
	End;

	//
	DefaultOptions;
	If Not bNoRegistry Then
		LoadOptions;
	gCacheTextures := True;

	//
	If Not bNoRegistry And Not bNoFileAssociations Then
	Begin
		Try
			RegisterFileTypes;
		Finally
		End;
	End;

	// MRU
	If Not bNoMRU Then
	Begin
		Try
			InitMRU ( 'Software\Csabo\XWE', mnuFile, 9 ); // 9 = index of separator
			LoadMRU;
		Finally
		End;
	End;

	//
	crCount := 0;

	//WindowState := wsMaximized;
	//
	// *** List View ***
	//
	ListWad.ViewStyle := vsReport;
	ListWad.HideSelection := False;
	ListWad.MultiSelect := True;
	ListWad.RowSelect := True;
	ListWad.Height := PanelBrowse.Height - ListWad.Top - 10;
	//
	lc := ListWad.Columns.Add;
	lc.Caption := 'Name';
	lc.Width := 80;
	//
	lc := ListWad.Columns.Add;
	lc.Caption := 'Index';
	lc.Alignment := taRightJustify;
	//
	lc := ListWad.Columns.Add;
	lc.Caption := 'Type';
	//
	lc := ListWad.Columns.Add;
	lc.Alignment := taRightJustify;
	//
	lc := ListWad.Columns.Add;
	lc.Alignment := taRightJustify;
	//
	RefreshColumnHeaders;
	//
	If Not mnuViewEntryList.Checked Then
	Begin
		PanelBrowse.Visible := False;
		BrowserSplitter.Visible := False;
	End;
	//
	tbFilter.Height := tbFilterAll.Height + 8;
	If ( ConstantFindByDescription ( 'OPTIONS', 'FILTER_TOOLBAR_TOP' ) = 1 ) Then
		tbFilter.Align := alTop;
	//
	If Not mnuViewMenuBar.Checked Then
		Menu := MainMenu2;
	If Not mnuViewFilterToolbar.Checked Then
		tbFilter.Visible := False;
	If Not mnuViewStatusBar.Checked Then
		StatusBrowse.Visible := False;
	//
	// *** Status bar
	//
	StatusBrowse.Panels.Add;
	StatusBrowse.Panels[0].Width := 180;
	StatusBrowse.Panels.Add;
	StatusBrowse.Panels[1].Width := 20;
	StatusBrowse.Panels.Add;
	StatusBrowse.Panels[2].Width := 80;
	StatusBrowse.Panels.Add;
	StatusBrowse.Panels[3].Width := 350;
	StatusBrowse.Panels.Add;
	//
	PanelHex.Align := alClient;
	PanelImage.Align := alClient;
	PanelGrid.Align := alClient;
	PanelTexture.Align := alClient;
	PanelTextScreen.Align := alClient;
	PanelPalette.Align := alClient;
	PanelWave.Align := alClient;
	PanelPatchNames.Align := alClient;
	PanelMap.Align := alClient;
	PanelMus.Align := alClient;
	PanelScript.Align := alClient;
	PanelColorMap.Align := alClient;
	//
	mnuImage.Visible := False;
	mnuHex.Visible := False;
	mnuPatchNames.Visible := False;
	mnuPalette.Visible := False;
	mnuTextures.Visible := False;
	mnuWave.Visible := False;
	mnuTextScreen.Visible := False;
	mnuGrid.Visible := False;
	mnuScript.Visible := False;
	mnuMap.Visible := False;
	mnuMapView.Visible := False;
	mnuSelection.Visible := False;
	mnuLineDefs.Visible := False;
	mnuColorMap.Visible := False;
	//
	mnuEditCut.Caption := mnuEditCut.Caption + #9 + 'Ctrl+X';
	mnuEditCopy.Caption := mnuEditCopy.Caption + #9 + 'Ctrl+C';
	mnuEditPaste.Caption := mnuEditPaste.Caption + #9 + 'Ctrl+V';
	//
	mnuMapCompile.Caption := mnuMapCompile.Caption + #9 + 'C';
	mnuMapRun.Caption := mnuMapRun.Caption + #9 + 'R';
	mnuMapCheck.Caption := mnuMapCheck.Caption + #9 + 'K';
	mnuMapFixAllErrors.Caption := mnuMapFixAllErrors.Caption + #9 + 'E';
	//
	mnuMapZoomIn.Caption := mnuMapZoomIn.Caption + #9 + 'Plus';
	mnuMapZoomOut.Caption := mnuMapZoomOut.Caption + #9 + 'Minus';
	mnuMapZoomAll.Caption := mnuMapZoomAll.Caption + #9 + 'Home';
	//
	mnuMapViewGrid.Caption := mnuMapViewGrid.Caption + #9 + 'G';
	mnuMapViewShowThings.Caption := mnuMapViewShowThings.Caption + #9 + 'SHIFT T';
	mnuMapGridInc.Caption := mnuMapGridInc.Caption + #9 + 'Shift +';
	mnuMapGridDec.Caption := mnuMapGridDec.Caption + #9 + 'Shift -';
	//
	mnuDrawAll.Caption := mnuDrawAll.Caption + #9 + 'A';
	mnuDrawLineDefs.Caption := mnuDrawLineDefs.Caption + #9 + 'L';
	mnuDrawThings.Caption := mnuDrawThings.Caption + #9 + 'T';
	mnuDrawSectors.Caption := mnuDrawSectors.Caption + #9 + 'S';
	mnuDrawVertex.Caption := mnuDrawVertex.Caption + #9 + 'V';
	mnuDrawDraw.Caption := mnuDrawDraw.Caption + #9 + 'D';
	mnuDrawNewSector.Caption := mnuDrawNewSector.Caption + #9 + 'SHIFT D';
	mnuMakeSector.Caption := mnuMakeSector.Caption + #9 + 'M';
	//
	mnuDrawLineDefsJoin.Caption := mnuDrawLineDefsJoin.Caption + #9 + 'J';
	mnuDrawLineDefsSplit.Caption := mnuDrawLineDefsSplit.Caption + #9 + 'X';
	mnuDrawLineDefsSplit3.Caption := mnuDrawLineDefsSplit3.Caption + #9 + 'SHIFT X';
	mnuDrawLineDefsFlip.Caption := mnuDrawLineDefsFlip.Caption + #9 + 'F';
	//
	mnuMapView3D.Caption := mnuMapView3D.Caption + #9 + '3';
	mnuMapDisplayLinedefLengths.Caption := mnuMapDisplayLinedefLengths.Caption + #9 + 'SHIFT L';
	//
	mnuSelectionDelete.Caption := mnuSelectionDelete.Caption + #9 + 'DEL';
	//
	mnuTextureNew.Caption := mnuTextureNew.Caption + #9 + 'Ins';
	mnuTextureDelete.Caption := mnuTextureDelete.Caption + #9 + 'ALT Del';
	//
	// init filters
	sListWadFilter := '';
	sListWadNewFilter := '';
	//
	iHexView := 2;
	// *** Wave ***
	iWaveDataSize := 0;
	WaveData := Nil;
	//
	// *** Palette ***
	//
	PaletteReady := False;
	//
	{$IFDEF FULLVERSION}
	// *** zip
	ZipDllsLoaded := False;
	{$ENDIF}
	//
	// *** CodeMax & Script editor
	//
	If bHasCodeMax Then
	Begin
		//ShowMessage ( 'Have Codemax' )
	End
	Else
	Begin
		//ShowMessage ( 'no Codemax' );
	End;
	//
	// --- Map
	//
	MapGrid := 64;
	bMapConfigInit := False;
	//
	// --- Image
	//
	cImage := TBitmap.Create;
	cImage.PixelFormat := pf24bit;
	Image1.Canvas.Font.Name := 'TAHOMA';
	Image1.Canvas.Font.Style := [fsBold];
	ImageRemapReset;
	//
	// --- Texture
	//
	//
	TextureZoom := 1;
	//
	isg := ImageArtGrid;
	//
	// --- Palettes
	//
	InitPals;
	//
	InitMainWad;
	//
	// --- Drag
	//
	DefaultWindowProc := WindowProc;
	WindowProc := FormWindowProc;
	DragAcceptFiles ( Handle, True );
	//
	// --- Misc
	//
	MutexHandle := CreateMutex ( nil, False, 'XWErunning' );
	If GetLastError = 0 Then
	Begin
		// only instance
		DeleteTempFiles ( sTempFolder, '*' );
	End;
	//
	sUniqueID := IntToHex ( Random ( 65535 ), 4 );
	ClipBoard := TClipboard.Create;
	ClipboardEmpty;
	ResetAll;
	Status ( 'Welcome to XWE.' );
end;

Procedure TFormMain.RefreshColumnHeaders;
Begin
	If gShowSize Then
		ListWad.Columns[3].Caption := 'Size'
	Else
		ListWad.Columns[3].Caption := '';
	//
	If gShowPosition Then
		ListWad.Columns[4].Caption := 'Position'
	Else
		ListWad.Columns[4].Caption := '';
End;

procedure TFormMain.RegisterFileTypes;
Var
	r : TRegistry;
	//
	sType : String;

procedure RegType ( sExt : String );
Begin
	If r.OpenKey ( '.' + sExt, False ) Then
	Begin

		// Already exists
		sType := r.ReadString ( '' );

	End
	Else
	Begin

		// Create it now
		sType := sExt + 'File';

		r.CreateKey ( '.' + sExt );
		r.OpenKey ( '.' + sExt, True );
		r.WriteString ( '', sType );

	End;
	r.CloseKey;
	//
	If Not r.OpenKey ( sType, False ) Then
	Begin
		r.CreateKey ( sType );
		r.OpenKey ( sType, False );
		r.WriteString ( '', sExt + ' File' );
	End;
	r.CloseKey;
	//
	// --- Create default icon if file type doesn't have one yet.
	//     Only for WAD extension
	//
	If sExt = 'WAD' Then
	Begin
		If Not r.OpenKey ( sType + '\DefaultIcon', False ) Then
		Begin
			r.CreateKey ( sType + '\DefaultIcon' );
			r.OpenKey ( sType + '\DefaultIcon', False );
			r.WriteString ( '', ParamStr ( 0 ) + ',1' );
		End;
		r.CloseKey;
	End;
	//
	If Not r.OpenKey ( sType + '\shell', False ) Then
	Begin
		r.CreateKey ( sType + '\shell' );
	End;
	r.CloseKey;
	//
	If Not r.OpenKey ( sType + '\shell\EditXWE', False ) Then
	Begin
		r.CreateKey ( sType + '\shell\EditXWE' );
		r.OpenKey ( sType + '\shell\EditXWE', False );
		r.WriteString ( '', 'Edit with XWE' );
		r.CloseKey;
		//
		r.CreateKey ( sType + '\shell\EditXWE\command' );
		r.OpenKey ( sType + '\shell\EditXWE\command', False );
		r.WriteString ( '', ParamStr ( 0 ) + ' "%1"' );
	End
	Else
	Begin
		r.CloseKey;
		r.OpenKey ( sType + '\shell\EditXWE\command', True );
		r.WriteString ( '', ParamStr ( 0 ) + ' "%1"' );
	End;
	r.CloseKey;
End;

procedure UnRegType ( sExt : String );
Var
	s : String;
Begin
	If r.OpenKey ( '.' + sExt, False ) Then
	Begin
		// Extension exists
		sType := r.ReadString ( '' );
		r.CloseKey;
		//
		If r.OpenKey ( sType, False ) Then
		Begin
			// Type exists
			r.CloseKey;
			//
			If r.OpenKey ( sType + '\DefaultIcon', False ) Then
			Begin
				// defaulticon exists
				s := r.ReadString ( '' );
				r.CloseKey;
				If Pos ( 'XWE.EXE', UpperCase ( s ) ) > 0 Then
				Begin
					r.DeleteKey ( sType + '\DefaultIcon' );
				End;
			End;
			//
			If r.OpenKey ( sType + '\shell\EditXWE', False ) Then
			Begin
				r.CloseKey;
				If r.OpenKey ( sType + '\shell\EditXWE\command', False ) Then
				Begin
					r.CloseKey;
					r.DeleteKey ( sType + '\shell\EditXWE\command' );
				End;
				r.DeleteKey ( sType + '\shell\EditXWE' );
			End;
			//
			If r.OpenKey ( sType + '\shell\EditEXWE', False ) Then
			Begin
				r.CloseKey;
				If r.OpenKey ( sType + '\shell\EditEXWE\command', False ) Then
				Begin
					r.CloseKey;
					r.DeleteKey ( sType + '\shell\EditEXWE\command' );
				End;
				r.DeleteKey ( sType + '\shell\EditEXWE' );
			End;
		End;
	End;
End;

Procedure xt ( sExt : String; RegUnreg : Boolean );
Begin
	If RegUnreg Then
		RegType ( sExt )
	Else
		UnRegType ( sExt );
End;

Begin
	r := TRegistry.Create;
	Try
		r.RootKey := HKEY_CLASSES_ROOT;
		//
		xt ( 'WAD', gAssociations <> assoc_None );
		//
		xt ( 'ART', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Blood, Witchaven
		xt ( 'B16', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Alien Trilogy
		xt ( 'BLO', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Greed BLO file
		xt ( 'BND', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Alien Trilogy
		xt ( 'BYT', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Ultime Underworld I BYT file
		xt ( 'CAN', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Adrenix
		xt ( 'CPS', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // EOB2 image files
		xt ( 'CRF', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Thief
		xt ( 'DAS', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // ROTH files
		xt ( 'DTI', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // MDK sky texture?
		xt ( 'DTX', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Lith Rez DTX file: Shogo
		xt ( 'GLB', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // DemonStar GLB file
		xt ( 'GOB', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // DarkForces
		xt ( 'GR',  ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Ultime Underworld I GR file
		xt ( 'GRP', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Duke3D
		xt ( 'HOG', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Descent
		xt ( 'LAB', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Outlaws LAB file
		xt ( 'LFD', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // DarkForces
		xt ( 'MTI', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // MDK texture file
		xt ( 'MTO', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // MDK texture file
		xt ( 'NWX', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Outlaws NWX single file
		xt ( 'PAL', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // EOB2 (and general) PAL files
		xt ( 'PIG', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Descent
		xt ( 'POD', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // NecroDome
		xt ( 'PPM', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Foresaken
		xt ( 'RBX', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // CStorm RBX file
		xt ( 'REZ', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Lith Rez files: Shogo; KillTime data file
		xt ( 'RFF', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Blood RFF data files
		xt ( 'RID', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Eradicator
		xt ( 'SNI', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // MDK sound file
		xt ( 'TLK', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Lands of Lore (Talk)
		xt ( 'TR',  ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Ultima Underworld I TR file
		xt ( 'UAX', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Unreal Audio
		xt ( 'UMX', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Unreal Music
		xt ( 'UTX', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // Unreal Texture
		xt ( 'XPR', ( gAssociations = assoc_Common ) Or ( gAssociations = assoc_All ) ); // XPR file
		//
		xt ( 'DAT', gAssociations = assoc_All ); // PowerSlave, ROTH DBASE files
		xt ( 'PAK', gAssociations = assoc_All ); // EOB1, Lands of Lore
		xt ( 'PK3', gAssociations = assoc_All );
		xt ( 'RES', gAssociations = assoc_All ); // System shock RES file
		xt ( 'WAV', gAssociations = assoc_All ); // General WAV files
		xt ( 'VOC', gAssociations = assoc_All ); // General VOC files
		xt ( 'BMP', gAssociations = assoc_All ); // General BMP files
		xt ( 'JPG', gAssociations = assoc_All ); // General JPG files
		xt ( 'PCX', gAssociations = assoc_All ); // General PCX files
		xt ( 'ACT', gAssociations = assoc_All ); // General ACT (Adobe Color Table - palette) files
		//
		bHasCodeMax := r.KeyExists ( 'CodeMax.Control' );
		//bHasCodeMax := False;
	Finally
		r.Free;
	End;
end;

Procedure TFormMain.ReadInfo ( sInfoFileName : String );
Type
	TReadMode = ( rmNormal, rmConst, rmScript );
Var
	t : TextFile;
	i : Integer;
	s, s1, s2 : String;
	//
	ReadMode : TReadMode;
	LastConstValue : Integer;
	//
	lc : Integer;
Begin
	If Not FileExists ( sInfoFileName ) Then
	Begin
		MessageDlg ( 'Info file not found' + #13 + sInfoFileName, mtWarning, [mbOK], 0 );
	End
	Else
	Begin
		{$I-}
		AssignFile ( t, sInfoFileName ); // text file
		Reset ( t );
		{$I+}
		//
		ReadMode := rmNormal;
		LastConstValue := 0;
		//
		i := IOResult;
		If i = 0 Then
		Begin

			lc := 0;

			While Not Eof ( t ) Do
			Begin
				ReadLn ( t, s );
				//
				s := Trim ( s );
				//
				If ( s <> '' ) And ( s [ 1 ] <> ';' ) Then
				Begin
					//
					If s [ 1 ] = '[' Then
					Begin

						Inc ( nWadEntryTypes );
						s := Trim ( Copy ( s, 2, Length ( s ) - 2 ) );
						WadEntryTypes [ nWadEntryTypes ].Description := s;
						WadEntryTypes [ nWadEntryTypes ].Icon := '';
						WadEntryTypes [ nWadEntryTypes ].ColStart := 0;
						WadEntryTypes [ nWadEntryTypes ].Cols := 0;
						WadEntryTypes [ nWadEntryTypes ].Size := -1;
						//
						WadEntryTypes [ nWadEntryTypes ].FileType := ftAll;
						WadEntryTypes [ nWadEntryTypes ].Entry := '';
						WadEntryTypes [ nWadEntryTypes ].Signature := '';
						WadEntryTypes [ nWadEntryTypes ].SectionStart := '';
						WadEntryTypes [ nWadEntryTypes ].SectionEnd := '';
						//
						lc := 0;

						ReadMode := rmNormal;

					End
					Else
					Begin

						If s [ 1 ] = '(' Then
						Begin
							s := Trim ( Copy ( s, 2, Length ( s ) - 2 ) );
							SplitAtMark ( s, s1, ':' );
							//
							ConstantAdd ( Trim ( s ), Trim ( s1 ) );
							//
							lc := 0;
							LastConstValue := 0;
							ReadMode := rmConst;
						End
						Else
						Begin

							If s [ 1 ] = '<' Then
							Begin

								If Length ( s ) > 1 Then
								Begin

									// Add new script
									Inc ( nScripts );

									//
									s := RemoveFromLeft ( s, 1 );
									If s [ Length ( s ) ] = '>' Then
										s := Copy ( s, 1, Length ( s ) - 1 );

									//
									Scripts [ nScripts ].sName := s;

									// script
									ReadMode := rmScript;

								End;

							End
							Else
							Begin

								Case ReadMode Of

									rmScript :
									Begin
										//
										ScriptLines.Add ( s );
									End;

									rmConst:
									Begin

										Inc ( nConstantValues );

										If lc = 1 Then
										Begin
											// first one, store count index
											Constants [ nConstants ].ValueStart := nConstantValues;
										End;
										Inc ( Constants [ nConstants ].ValueCount ); // count them

										// ---
										Inc ( LastConstValue );

										// Check for = nnn in string (simple constants)
										// but exclude ":" lines
										If ( Pos ( '=', s ) > 0 )
										And ( Pos ( ':', s ) = 0 ) Then
										Begin
											SplitAtMark ( s, s1, '=' );
											//
											s1 := Trim ( s1 );
											LastConstValue := SafeVal ( s1 );
										End;

										If s [ 1 ] = '''' Then
											s := RemoveFromLeft ( s, 1 );
										If s [ Length ( s ) ] = '''' Then
											s := RemoveFromRight ( s, 1 );

										ConstantValues [ nConstantValues ].Description := s; // store desc
										ConstantValues [ nConstantValues ].Value := LastConstValue;

									End;

									rmNormal:
									Begin

										If Pos ( ':', s ) > 0 Then
										Begin
											SplitAtMark ( s, s1, ':' );
											s := UpperCase ( Trim ( s ) );
											s1 := Trim ( s1 );
											//
											If s = 'ICON' Then
											Begin
												WadEntryTypes [ nWadEntryTypes ].Icon := s1;
											End
											Else If s = 'ENTRY' Then
											Begin
												WadEntryTypes [ nWadEntryTypes ].Entry :=
													WadEntryTypes [ nWadEntryTypes ].Entry + TrimString ( s1 );
											End
											Else If s = 'SIZE' Then
											Begin
												WadEntryTypes [ nWadEntryTypes ].Size := StrToInt ( TrimString ( s1 ) );
											End
											Else If s = 'SIGNATURE' Then
											Begin
												WadEntryTypes [ nWadEntryTypes ].Signature := TrimString ( s1 );
											End
											Else If s = 'EDITOR' Then
											Begin
												SplitAtMark ( s1, s, ',' );
												WadEntryTypes [ nWadEntryTypes ].Editor := UpperCase ( s1 );
												WadEntryTypes [ nWadEntryTypes ].EditorSubCat := UpperCase ( s );
											End
											Else If s = 'EXPORTMETHOD' Then
											Begin
												WadEntryTypes [ nWadEntryTypes ].ExportMethod := UpperCase ( s1 );
											End
											Else If s = 'SECTIONSTART' Then
											Begin
												WadEntryTypes [ nWadEntryTypes ].SectionStart := TrimString ( UpperCase ( s1 ) );
											End
											Else If s = 'SECTIONEND' Then
											Begin
												WadEntryTypes [ nWadEntryTypes ].SectionEnd := TrimString ( UpperCase ( s1 ) );
											End
											Else IF s = 'HEADER' Then
											Begin
												WadEntryTypes [ nWadEntryTypes ].Header := SafeVal ( TrimString ( s1 ) );
											End;
										End
										Else
										Begin

											Inc ( nWadEntryCols );

											If WadEntryTypes [ nWadEntryTypes ].ColStart = 0 Then
											Begin
												// first column...
												WadEntryTypes [ nWadEntryTypes ].ColStart := nWadEntryCols;
											End;

											Inc ( WadEntryTypes [ nWadEntryTypes ].Cols );

											//

											SplitAtMark ( s, s1, ' ' );
											SplitAtMark ( s1, s2, ' ' );
											If IsNumbers ( s ) Then
												WadEntryCols [ nWadEntryCols ].iLen := StrToInt ( s );
											WadEntryCols [ nWadEntryCols ].iType := s1;

											WadEntryCols [ nWadEntryCols ].Desc := RemoveQuotes ( s2 );

										End;
									End;
								End;
							End;
						End;

					End;
					//
					Inc ( lc ); // increment line counter, relative from new enrty
				End;
			End;
			CloseFile ( t );
		End;
	End;
End;

Function TFormMain.RemoveQuotes ( s : String ) : String;
Begin
	If s <> '' Then
	Begin
		If s [ 1 ] = '"' Then
			s := RemoveFromLeft ( s, 1 );
		If s [ Length ( s ) ] = '"' Then
			s := RemoveFromRight ( s, 1 );
	End;
	//
	RemoveQuotes := s;
End;

{$IFDEF USEDEBUG}
procedure TFormMain.StartDebug;
begin
	AssignFile ( df, 'c:\xwedebug.txt' );
	ReWrite ( df );
	bDebug := True;
end;

procedure TFormMain.DoDebug ( s : String );
begin
	If bDebug Then
	Begin
		Write ( df, s );
	End;
end;

procedure TFormMain.DoDebugLn ( s : String );
begin
	If bDebug Then
	Begin
		WriteLn ( df, s );
	End;
end;

procedure TFormMain.EndDebug;
begin
	If bDebug Then
	Begin
		CloseFile ( df );
		bDebug := False;
	End;
end;
{$ENDIF}

procedure TFormMain.ListWadDblClick(Sender: TObject);
begin
	ShowEntry ( '', True );
end;

procedure TFormMain.InitMainWad;
Var
	s, sParam : String;
	i, iDirPos : Integer;
Begin
	ToolsGet ( 'MainWAD', 'DOOM2.WAD', sMainWad, s, sParam );
	sMainWad := sMainWad + s;
	//
	nMainWadEntries := 0;
	//
	If FileExists ( sMainWad ) Then
	Begin
		//
		{$I-}
		AssignFile ( f, sMainWad );
		FileMode := fmOpenReadWrite;
		Reset ( f, 1 );
		{$I+}
		i := IOResult;
		If i = 5 Then
		Begin
			//
			// - retry Main WAD as read-only
			//
			{$I-}
			AssignFile ( f, sMainWad );
			FileMode := fmOpenRead;
			Reset ( f, 1 );
			{$I+}
			i := IOResult;
		End;
		//
		If i = 0 Then
		Begin
			If ReadWadHeader ( f, nMainWadEntries, iDirPos ) Then
			Begin
				Seek ( f, iDirPos );
				For i := 1 To nMainWadEntries Do
				Begin
					MainWadEntries [ i ].Position := GetLong ( f );
					MainWadEntries [ i ].Size := GetLong ( f );
					MainWadEntries [ i ].Name := Trim ( GetString ( f, 8 ) );
				End;
			End
			Else
			Begin
				nMainWadEntries := 0;
			End;
			//
			CloseFile ( f );
		End;
	End;
End;

procedure TFormMain.WadEntryLoad ( Var f : File );
Var
	iPos, iLen : Longint;
	s : String;
	{$IFDEF FULLVERSION}
	ZipEntry : pZipDirEntry;
	w : Word; // wolf audio files
	DasEntryPos : Word; // DAS Files
	//
	b : Byte;
	i : Integer;
	{$ENDIF}

{$IFDEF FULLVERSION}
Procedure AAR_EntryLoad ( sBeg : String; iXPos : Integer );
Var
	iAAR_Pos, iAAR_Entries : Integer;
	j : Integer;
Begin
	fSeek ( f, iXPos );
	If GetLong ( f ) = $21736552 Then
	Begin
		// sub entries
		iAAR_Pos := GetLong ( f );
		iAAR_Entries := GetLong ( f ) Div 39;
		//
		For j := 0 To iAAR_Entries - 1 Do
		Begin
			fSeek ( f, iAAR_Pos + j * 39 );
			//
			GetLong ( f ); // ReS marker
			s := GetString ( f, 14 );
			iPos := GetLong ( f );
			iLen := GetLong ( f );
			//
			AAR_EntryLoad ( Trim ( sBeg + '\' + s ), iPos );
			//
			WadEntries [ nWadEntries ].Name := sBeg + '\' + s;
			WadEntries [ nWadEntries ].Position := iPos;
			WadEntries [ nWadEntries ].Size := iLen;
			WadEntries [ nWadEntries ].EntryType := 0;
			//
			Inc ( nWadEntries );
			Inc ( iAAR_EntriesInc );
		End;
		//
		s := '';
		iPos := 0;
		iLen := 0;
	End;
End;
{$ENDIF}

Begin
	Inc ( nWadEntries );
	//
	s := '';
	//
	{$IFDEF FULLVERSION}
	iPos := 0;
	iLen := 0;
	//
	Case FileType Of

		ftWadFile :
		Begin
			{$ENDIF}
			iPos := GetLong ( f );
			iLen := GetLong ( f );
			s := GetString8 ( f );
			{$IFDEF FULLVERSION}
		End;

		Wad2File, Wad3File :
		Begin
			iPos := GetLong ( f );
			iLen := GetLong ( f );
			GetLong ( f );
			b := GetByte ( f ); // type
			GetByte ( f );
			GetByte ( f );
			GetByte ( f );
			s := Trim ( GetString ( f, 16 ) );
			//
			If b = 68 Then // D = texture
			Begin
				Inc ( iPos, $10 ); // skip first 16 bytes (texture name)
				Dec ( iLen, $10 );
				s := s + '.bmp';
			End;
		End;

		DukeFile :
		Begin
			s := GetString ( f, 12 );
			iLen := GetLong ( f );
			iPos := LastEntryPos;
			//
			Inc ( LastEntryPos, iLen );
		End;

		Duke2File :
		Begin
			s := GetString ( f, 12 );
			iPos := GetLong ( f );
			iLen := GetLong ( f );
		End;

		QuakeFile :
		Begin
			s := Trim ( GetString ( f, 56 ) );
			//
			// remove extra stuff after #0
			// (which was converted to a space)
			//
			If Pos ( ' ', s ) > 0 Then
			Begin
				s := Copy ( s, 1, Pos ( ' ', s ) - 1 );
			End;
			//
			iPos := GetLong ( f );
			iLen := GetLong ( f );
		End;

		UnrealFile :
		Begin
			iPos := GetLongUnreal ( f ); // class
			GetLongUnreal ( f ); // super
			//
			GetLong ( f ); // Package
			//
			iLen := GetLongUnreal ( f ); // name index
			s := sUnrealNameTable [ iLen ];
			//
			If iPos < 0 Then
			Begin
				iPos := iUnrealExportTable [ Abs ( iPos ) - 1 ];
				If sUnrealNameTable [ iPos ] = 'Texture' Then
				Begin
					s := s + '.BMP';
				End
				Else
				Begin
					If sUnrealNameTable [ iPos ] = 'Palette' Then
					Begin
						s := s + '.PAL';
					End
					Else
					Begin
						s := s + '.' + sUnrealNameTable [ iPos ];
					End;
				End;
			End;
			//
			GetLong ( f ); // Flags
			//
			iLen := GetLongUnreal ( f );
			iPos := GetLongUnreal ( f );
			//
			// --- special crap ---
			//
			If iLen = 1027 Then
			Begin
				iPos := iPos + 3;
				iLen := iLen - 3;
			End;
			If iLen = 1031 Then
			Begin
				iPos := iPos + 3;
				iLen := iLen - 7;
			End;
			//
			LastEntryPos := FilePos ( f );
			//
		End;

		RFFFile :
		Begin
			GetLong ( f ); // 4 unknown longs
			GetLong ( f );
			GetLong ( f );
			GetLong ( f );
			//
			iPos := GetLong ( f ); // positions
			iLen := GetLong ( f ); // length
			GetLong ( f );
			GetLong ( f );
			//
			GetByte ( f );
			s := GetString ( f, 3 );
			s := s + GetString ( f, 8 );
			//
			// --- Check for compression after first entry
			//
			If nWadEntries = 1 Then
			Begin
				If ( iLen > $FFFFFF ) Or ( iLen < 0 ) Or ( iPos < 0 ) Then
				Begin
					LastEntryPos := 1; // flag compression
				End;
			End;
			//
			//
			//
			If LastEntryPos = 1 Then
			Begin
				b := ( iPos Shr 24 ) - 1;
				//
				iPos := iPos Xor ( ( b ) Or ( ( b ) Shl 8 )
					Or ( ( b + 1 ) Shl 16 ) Or ( ( b + 1 ) Shl 24 ) );
				//
				b := b + 2;
				iLen := iLen Xor ( ( b ) Or ( ( b ) Shl 8 )
					Or ( ( b + 1 ) Shl 16 ) Or ( ( b + 1 ) Shl 24 ) );
				//
				b := b + 6;
				//
				For i := 1 To 11 Do
				Begin
					s [ i ] := Chr ( Ord ( s [ i ] ) Xor b );
					If ( i And 1 ) = 1 Then
						b := b + 1;
				End;
			End;
			//
			s := Trim ( RemoveFromLeft ( s, 3 ) ) + '.' + Copy ( s, 1, 3 );
		End;

		PKFile :
		Begin
			ZipEntry := zipM.ZipContents.Items[nWadEntries-1];
			s := ZipEntry.FileName;
			iLen := ZipEntry.UncompressedSize;
		End;

		WolfFile :
		Begin
			// Pos dir is fixed at 6
			//
			Seek ( f, 6 + ( nWadEntries - 1 ) * 4 );
			iPos := GetLong ( f );
			Seek ( f, iWadDirPos + ( nWadEntries - 1 ) * 2 );
			iLen := GetWord ( f );
			//
			If iLen = 4096 Then
				s := 'Wall' + Zero ( nWadEntries, 4 )
			Else
				s := 'Sprite' + Zero ( nWadEntries, 4 );
		End;

		WolfAudioFile :
		Begin
			s := Zero ( nWadEntries, 4 );
			// keep pos and len - already loaded
			iPos := WadEntries [ nWadEntries ].Position;
			iLen := WadEntries [ nWadEntries ].Size;
			//
			Seek ( f, WadEntries [ nWadEntries ].Position );
			w := GetWord ( f );
			If w = iLen - 90 Then
			Begin
				// IMF song
				Seek ( f, WadEntries [ nWadEntries ].Position + w + 20 );
				s := GetZString ( f );
			End;
		End;

		AdrenixFile :
		Begin
			s := Trim ( GetString ( f, 20 ) );
			iPos := GetLong ( f );
			//
			If nWadEntries > 1 Then
			Begin
				WadEntries [ nWadEntries - 1 ].Size := iPos - WadEntries [ nWadEntries - 1 ].Position;
			End;
			iLen := 1;
		End;

		DarkForcesFile :
		Begin
			iPos := GetLong ( f );
			iLen := GetLong ( f );
			s := GetString ( f, 13 );
		End;

		DarkForcesLFDFile :
		Begin
			s := GetString ( f, 4 );
			//
			iPos := 0;
			//
			If Length ( s ) = 4 Then
			Begin
				//
				iPos := 1;
				For iLen := 1 To 4 Do
				Begin
					If ( s [ iLen ] < 'A' ) Or ( s [ iLen ] > 'Z' ) Then
					Begin
						iPos := 0;
					End;
				End;
				iLen := 1;
				//
				If iPos > 0 Then
				Begin
					s := Trim ( GetString ( f, 8 ) ) + '.' + s;
					iLen := GetLong ( f );
					//
				End;
			End;
		End;

		PIGFile, PIG2File :
		Begin
			If nWadEntries <= iDP_TextureEntries Then
			Begin
				s := GetString ( f, 8 );
				//
				If Pos ( ' ', s ) > 0 Then
				Begin
					s := Copy ( s, 1, Pos ( ' ', s ) - 1 );
				End;
				s := s + '.BMP'; // add BMP extension to recognise graphic
				//
				GetByte ( f );
				GetByte ( f );
				GetByte ( f );
				GetByte ( f );
				GetByte ( f );
				//
				If FileType = PIG2File Then
				Begin
					GetByte ( f );
				End;
				//
				iPos := GetLong ( f );
				iPos := iDP_DataStart + iPos;
				//
				iLen := 1; // will be done later
			End
			Else
			Begin
				s := GetString ( f, 8 );
				//
				If Pos ( ' ', s ) > 0 Then
				Begin
					s := Copy ( s, 1, Pos ( ' ', s ) - 1 );
				End;
				s := s + '.RAW'; // add RAW extension to recognise WAVE
				//
				iLen := GetLong ( f );
				GetLong ( f );
				//
				iPos := GetLong ( f );
				iPos := iDP_DataStart + iPos;
				//
			End;
		End;

		TLKFile : // Lands of Lore Talk file
		Begin
			iPos := GetLong ( f );
			s := GetZString ( f );
			//
			If s = '' Then
			Begin
				iPos := 0;
				iLen := 0;
			End
			Else
			Begin
				If UpperCase ( KeepFromRight ( s, 3 ) ) <> 'VOC' Then
				Begin
					s := s + '.VOC';
				End;
				//
				LastEntryPos := FilePos ( f );
				//
				iLen := GetLong ( f );
				iLen := iLen - iPos;
			End;
		End;

		HOGFile : // Descent
		Begin
			s := GetString ( f, 13 );
			//
			If Pos ( ' ', s ) > 0 Then
			Begin
				s := Copy ( s, 1, Pos ( ' ', s ) - 1 );
			End;
			//
			iLen := GetLong ( f );
			iPos := FilePos ( f );
			//
			LastEntryPos := iPos + iLen;
		End;

		PODFile : // Necrodome
		Begin
			iPos := GetLong ( f );
			iLen := GetLong ( f );
			//
		End;

		LGRESFile : // System shock LG Res file
		Begin
			//
			GetWord ( f ); // ID?
			//
			iLen := Byte ( GetByte ( f ) );
			iLen := iLen Or ( ( Byte ( GetByte ( f ) ) ) Shl 8 );
			iLen := iLen Or ( ( Byte ( GetByte ( f ) ) ) Shl 16 );
			GetByte ( f ); // ?
			//
			If nWadEntries = 1 Then
			Begin
				iPos := LastEntryPos;
			End
			Else
			Begin
				iPos := WadEntries [ nWadEntries - 1 ].Position + WadEntries [ nWadEntries - 1 ].Size;
				// find next 4 byte boundary
				While ( iPos And 3 ) <> 0 Do
					Inc ( iPos );
			End;
			//
			GetByte ( f );
			GetByte ( f );
			GetByte ( f );
			//
			b := GetByte ( f );
			//
			s := Zero ( nWadEntries, 4 ) + '.';
			//
			Case b Of

				0 :
				Begin
					If iLen = 768 Then
						s := s + 'PAL'
					Else
						s := s + 'DAT';
				End;

				1 :
				Begin
					s := s + 'TXT';
				End;

				2 :
				Begin
					s := s + 'BMP';
				End;

				7 :
				Begin
					s := s + 'VOC';
				End;

				17 :
				Begin
					s := s + 'AUDLOG';
				End;

				Else
				Begin
					s := s + Zero ( b, 3 )
				End;

			End;
			//
		End;

		TRFile, GRFile :
		Begin
			iPos := GetLong ( f );
			iLen := GetLong ( f );
			iLen := iLen - iPos;
			s := Zero ( nWadEntries, 4 );
			If iLen > 0 Then
				s := s + '.BMP';
		End;

		EOB1File :
		Begin
			Seek ( f, LastEntryPos );
			//
			iPos := GetLong ( f );
			//
			If ( iPos > FileSize ( f ) ) Or ( iPos < 0 ) Then
			Begin
				iPos := 0;
			End
			Else
			Begin
				//
				s := GetZString ( f );
				//
				If ( Length ( s ) = 0 ) Or ( s [ 1 ] < 'A' ) Or ( s [ 1 ] > 'Z' ) Then
				Begin
					iPos := 0;
				End
				Else
				Begin
					LastEntryPos := FilePos ( f );
					//
					iLen := GetLong ( f );
					//
					If ( iLen > FileSize ( f ) ) Or ( iLen < 0 ) Then
					Begin
						iLen := FileSize ( f ) - iPos;
					End
					Else
					Begin
						iLen := ( iLen And $FFFFFF ) - iPos; // sometimes top byte is not zero
					End;
				End;
			End;
		End;

		EOB3File :
		Begin
			//
			// At every 128 entries
			//
			If ( ( nWadEntries - 1 ) And 127 ) = 0 Then
			Begin
				//
				// Search for base
				//
				If nWadEntries > 1 Then
				Begin
					// from last entry
					Seek ( f, WadEntries [ nWadEntries - 1 ].Position +
						WadEntries [ nWadEntries - 1 ].Size + 4 );
				End
				Else
				Begin
					// from beginning
					Seek ( f, iWadDirPos );
				End;
				//
				While ( iPos = 0 ) Or ( iPos = $01010101 ) Do
				Begin
					iPos := GetLong ( f );
				End;
				iWadDirPos := FilePos ( f ) - 4;
			End;
			//
			// Get Entry Position
			//
			Seek ( f, iWadDirPos + ( ( nWadEntries - 1 ) And 127 ) * 4 );
			iLen := 0;
			iPos := GetLong ( f );
			s := Zero ( nWadEntries, 4 );
			//
			If iPos <> 0 Then
			Begin
				//
				// Get Entry Size
				//
				Seek ( f, iPos + 8 );
				iLen := GetLong ( f );
				Inc ( iPos, 12 );
			End;
		End;

		ROTH2File :
		Begin
			//
			iLen := GetLong ( f );
			iPos := LastEntryPos + 4;
			//
			If iPos + iLen > FileSize ( f ) Then
			Begin
				iLen := FileSize ( f ) - iPos; // for DBASE100?
			End;
			//
			s := Zero ( nWadEntries, 4 ); // + '.BMP';
			Seek ( f, iPos );
			s := s + '.' + IntToHex ( GetWord ( f ), 4 );
			//
			// ---
			//
			LastEntryPos := iPos + iLen;
			//
			// --- Next entry on 8 byte boundary
			//
			While ( LastEntryPos And 7 ) <> 0 Do
				Inc ( LastEntryPos );
		End;

		ROTH5File :
		Begin
			iPos := LastEntryPos;
			//
			GetLong ( f );
			iLen := GetLong ( f );
			Inc ( iLen, 8 );
			//
			s := Zero ( nWadEntries, 4 ) + '.WAV';
			//
			// ---
			//
			LastEntryPos := iPos + iLen;
			//
			// --- Next entry on 8 byte boundary
			//
			While ( LastEntryPos And 7 ) <> 0 Do
				Inc ( LastEntryPos );
		End;

		DASFile :
		Begin
			//
			//s := IntToHex ( GetWord ( f ), 4 ) + '.';
			GetWord ( f );
			//
			DasEntryPos := GetWord ( f ); // get position index
			//
			s := GetZString ( f );
			s := s + '.' + GetZString ( f );
			If KeepFromRight ( s, 1 ) = '.' Then
				s := RemoveFromRight ( s, 1 );
			//
			s := Trim ( s ) + '.BMP';
			//
			LastEntryPos := FilePos ( f );
			//
			// go to right index in position table
			Seek ( f, iDAS_Pos + DasEntryPos * 8 );
			iPos := GetLong ( f );
			iLen := Word ( GetWord ( f ) );
			iLen := iLen * 2;
		End;

		FORMFile :
		Begin
			iPos := FilePos ( f ) + 8;
			//
			s := GetString ( f, 4 );
			iLen := GetLong2 ( f );
			//
			If iLen = 256 * 256 Then
			Begin
				s := s + '.BMP';
			End;
			//
			fSeek ( f, iPos + iLen );
			//Inc ( LastEntryPos, iLen + 8 );
		End;

		RIDFile :
		Begin
			iPos := GetLong ( f );
			iLen := GetLong ( f );
			GetLong ( f ); // date/time
			//
			iLen := iLen * iPos + 12;
			iPos := LastEntryPos;
			//
			Seek ( f, iRID_Pos + 12 + ( nWadEntries - 1 ) * 20 );
			s := GetString ( f, 8 ) + '.bmp';
			//
			Inc ( LastEntryPos, iLen );
		End;

		MTIFile :
		Begin
			s := Trim ( GetString ( f, 8 ) );
			GetLong ( f );
			GetLong ( f );
			GetLong ( f );
			iPos := GetLong ( f ) + iWadDirPos - $14;
			If iPos < iWadDirPos Then iPos := 0;
			//
			If iPos > 0 Then
			Begin
				s := s + '.bmp';
			End;
			//
			If ( nWadEntries > 1 ) And ( iPos > WadEntries [ nWadEntries - 1 ].Position ) Then
			Begin
				With WadEntries [ nWadEntries - 1 ] Do
				Begin
					Size := iPos - Position;
					//Name := Name + '.bmp';
				End;
			End;
			//
			iLen := 4;
		End;

		DTIFile :
		Begin
			iPos := GetLong ( f ) + 8; // ?!
			fSeek ( f, $4C ); // ?! image dimensions seems to be there
			iLen := GetLong ( f ) * GetLong ( f ) + $300; // plus palette
			//
			s := RemoveFromLeft ( sFileName, PosR ( '\', sFileName ) ) + '.bmp';
		End;

		SNIFile :
		Begin
			s := Trim ( GetString ( f, 8 ) );
			GetLong ( f );
			GetLong ( f );
			iPos := GetLong ( f ) + 4;
			iLen := GetLong ( f );
			//
			fSeek ( f, iPos );
			if GetLong ( f ) = $46464952 Then
			Begin
				s := s + '.wav';
			End;
		End;

		REZFile :
		Begin
			//
			// --- Get 4 byte indentifier
			//
			If GetLong ( f ) = 1 Then
			Begin
				//
				// *** directory **
				//
				iPos := GetLong ( f );
				iLen := GetLong ( f );
				GetLong ( f ); // date/time
				s := GetZString ( f );
				//
				If iREZ_Folders > 0 Then
				Begin
					i := 3 * 4 + Length ( s ) + 1;
					Dec ( nREZ_FolderLength [ iREZ_Folders ], i );
				End;
				//
				Inc ( iREZ_Folders );
				nREZ_FolderPointers [ iREZ_Folders ] := FilePos ( f );
				nREZ_FolderLength [ iREZ_Folders ] := iLen;
				sREZ_FolderName [ iREZ_Folders ] := s;
				//
				If iLen > 0 Then
				Begin
					//
					// --- Continue with sub-folder
					//
					LastEntryPos := iPos;
				End
				Else
				Begin
					LastEntryPos := FilePos ( f );
				End;
				//
				s := '';
			End
			Else
			Begin
				//
				// *** file ***
				//
				iPos := GetLong ( f ); // 4
				iLen := GetLong ( f ); // 4
				//
				GetLong ( f ); // 4 date/time
				GetLong ( f ); // 4 ???
				s := Trim ( GetString ( f, 4 ) ); // 4 ext
				//
				For i := Length ( s ) DownTo 1 Do
				Begin
					s := Copy ( s, Length ( s ) + 1 - i, 1 ) + s;
				End;
				s := Copy ( s, 1, Length ( s ) Div 2 );
				//
				GetLong ( f ); // 4 "0"
				//
				s := Trim ( GetZString ( f ) + '.' + s ); // n
				GetByte ( f ); // 1 "0"
				//
				If iREZ_Folders > 0 Then
				Begin
					i := 7 * 4 + Length ( s ) + 2;
					Dec ( nREZ_FolderLength [ iREZ_Folders ], i );
					If ( nREZ_FolderLength [ iREZ_Folders ] <= 0 ) Then
					Begin
						LastEntryPos := nREZ_FolderPointers [ iREZ_Folders ];
						Dec ( iREZ_Folders );
					End
					Else
					Begin
						LastEntryPos := FilePos ( f );
					End;
				End
				Else
				Begin
					//
					// --- continue here
					//
					LastEntryPos := FilePos ( f );
				End;
				//
			End;
			//
			For i := iREZ_Folders DownTo 1 Do
				s := sREZ_FolderName [ i ] + '\' + s;
			//
		End;

		GLBFile : // DemonStar
		Begin
			GetLong ( f ); // zeros
			iPos := GetLong ( f );
			iLen := GetLong ( f );
			s := GetString ( f, 16 );
		End;

		LABFile : // Outlaws
		Begin
			iPos := GetLong ( f ); // position of filename
			i := FilePos ( f );
			//
			fSeek ( f, iLAB_FileNameTable + iPos );
			s := GetZString ( f );
			//
			Seek ( f, i );
			iPos := GetLong ( f );
			iLen := GetLong ( f );
			{
			i := GetLong ( f );
			s := s + '.';  // extension
			s := s + Chr ( ( i Shr 24 ) And 255 );
			s := s + Chr ( ( i Shr 16 ) And 255 );
			s := s + Chr ( ( i Shr 8 ) And 255 );
			s := s + Chr ( i And 255 );
			}
			//
		End;

		CSFile : // Chasm : The rift
		Begin
			i := Byte ( GetByte ( f ) ); // length of filename
			s := GetString ( f, i );
			While i < 12 Do
			Begin
				GetByte ( f ); // padding zeros
				Inc ( i );
			End;
			//
			If UpperCase ( KeepFromRight ( s, 3 ) ) = 'CEL' Then
			Begin
				s := s + '.BMP';
			End;
			//
			iLen := GetLong ( f );
			iPos := GetLong ( f );
			//
			LastEntryPos := FilePos ( f );
		End;

		RBXFile : // CStorm
		Begin
			s := GetString ( f, 12 );
			if KeepFromRight ( s, 4 ) = '.WAX' Then
				s := RemoveFromRight ( s, 4 ) + '.RAW';
			//
			iPos := GetLong ( f );
			//
			fSeek ( f, iPos );
			iLen := GetLong ( f );
			Inc ( iPos, 4 );
		End;

    XPRFile : // XPR
		Begin
      //
			s := '';
      i := 0;
			While i <> Ord ( ';' ) Do
			Begin
        i := GetByte ( f ); //
        Dec ( iXPR_DirLen );
        If i <> Ord ( ';' ) Then
  	  		s := s + Chr ( i );
			End;
			//
			LastEntryPos := FilePos ( f );
			//
			Seek ( f, 12 - 16 + nWadEntries * 20 );
      iPos := GetLong ( f ) + $2000;
			Seek ( f, 12 - 06 + nWadEntries * 20 );
      iLen := GetWord ( f );
      iLen := ( iLen And 255 ) - ( iLen Shr 8 );
      iLen := iLen * iLen;
		End;

		BLOFile : // Greed
		Begin
			iPos := GetLong ( f );
			iLen := GetLong ( f );
			//
			LastEntryPos := GetLong ( f );
			//
			If LastEntryPos > 0 Then
			Begin
				fSeek ( f, iWadDirPos + LastEntryPos );
				s := GetZString ( f );
			End
			Else
			Begin
				s := Zero ( nWadEntries, 4 );
				fSeek ( f, iPos );
				If GetLong ( f ) = $46464952 Then
				Begin
					s := s + '.WAV';
				End
				Else
				Begin
					If iLen = 768 Then
					Begin
						s := WadEntries [ nWadEntries - 1 ].Name + '.PAL';
					End;
				End;
			End;
		End;

		WRSFile : // Skaphander - doesn't work
		Begin
			iPos := FilePos ( f ) + 13 + 4 + 4 + 1;
			s := GetString ( f, 13 );
			//
			If Pos ( ' ', s ) > 0 Then
			Begin
				s := Copy ( s, 1, Pos ( ' ', s ) - 1 );
			End;
			//
			iLen := GetLong2 ( f ) - 1;
			//
			LastEntryPos := iPos + iLen;
		End;

		KTREZFile : // KillTime Rez data file
		Begin
			iPos := GetLong ( f );
			i := ( iPos Shr 24 And $FE );
			s := Zero ( nWadEntries, 4 ) + '.' + IntToHex ( i, 2 );
			iPos := iPos And $1FFFFFF;
			//
			iLen := GetLong ( f );
			//
			GetLong ( f ); // almost always zeroes, except once
			//
			If iLen = 768 Then
			Begin
				s := s + '.PAL';
			End
			Else
			Begin
				If iLen = 4 Then
				Begin
					iLen := 0;
				End
				Else
				Begin
					s := s + '.BMP';
				End;
			End;
		End;

		PoziFile : // Pozi : Scrapland packed files
		Begin
			i := GetLong ( f );
			s := GetString ( f, i );
			//
			iLen := GetLong ( f );
			iPos := GetLong ( f );
			//
			LastEntryPos := FilePos ( f );
		End;

		QNFile : // QN: Outcast .PAK files
		Begin
			i := GetLong ( f );
			s := GetString ( f, i );
			//
			iPos := GetLong ( f );
			iLen := GetLong ( f );
			//
			GetLong ( f );
			//
			LastEntryPos := FilePos ( f );
		End;

		AARESFile : // Amulets and Armor
		Begin
			GetLong ( f ); // ReS marker
			s := GetString ( f, 14 );
			//
			If UpperCase ( Copy ( s, 1, 3 ) ) = 'SND' Then
			Begin
				s := s + '.raw';
			End;
			//
			iPos := GetLong ( f );
			iLen := GetLong ( f );
			//
			If UpperCase ( Trim ( s ) ) <> 'OBJS' Then
			Begin
				AAR_EntryLoad ( Trim ( s ), iPos );
			End;
		End;

		JFKWadFile : // JFK Reloaded WAD file
		Begin
			s := GetZString ( f );
			iPos := 0;
			iLen := 0;
			//
			LastEntryPos := FilePos ( f );
			//
			Seek ( f, iJFK_DirPos );
			GetLong ( f );
			iLen := GetLong ( f );
			iPos := GetLong ( f );
			GetLong ( f );
			iJFK_DirPos := FilePos ( f );

			// 2 5b b5 e0 list
			// 2 5b ba cf colours
			// 2 5b bd 37 controls
		End;

		FShockFile : // Future Shock TEXTURE.### file
		Begin
			If LastEntryPos = 0 Then
			Begin
				fSeek ( f, 0 );
				iPos := GetWord ( f );
				fSeek ( f, 2 + 4 );
				s := GetZString ( f );
				//
				// after pos 26, there is ipos * 20 bytes, skip it
				iPos := 26 + iPos * 20;
			End
			Else
			Begin
				//
				s := WadEntries [ 1 ].Name + ' ' + IntToStr ( nWadEntries );
				//
				iPos := LastEntryPos;
			End;
			//
			Repeat
				// always ends with "$47 $00 $00 $00 $00 $00"
				fSeek ( f, iPos + 22 );
				i := Word ( GetWord ( f ) );
				If i <> $47 Then
					Inc ( iPos, 256 );
			Until ( i = $47 ) Or ( iPos + 22 >= FileSize ( f ) );
			//
			If i = $47 Then
			Begin
				fSeek ( f, iPos + 6 );
				iLen := Word ( GetWord ( f ) );	// image height!
			End;
			If ( iLen > 512 ) Or ( iLen = 0 ) Then
			begin
				iLen := 0;
				iPos := 0;
			End
			Else
			Begin
				//
				iLen := 256 * iLen;
				//
				fSeek ( f, iPos + 6 + 8 );
				i := Word ( GetWord ( f ) ); // "header" size
				iPos := iPos + i;
				//
				{
				Repeat
					// (unknown) * 28 bytes, need to be skipped
					// always ends with "$47 $00 $00 $00 $00 $00"
					fSeek ( f, iPos + 22 );
					i := Word ( GetWord ( f ) );
					If i = $47 Then
						Inc ( iPos, 28 );
				Until i <> $47;
				}
			End;
			//
			LastEntryPos := iPos + iLen;
		End;

	End;
	{$ENDIF}
	//
	WadEntries [ nWadEntries ].Name := s;
	WadEntries [ nWadEntries ].Position := iPos;
	WadEntries [ nWadEntries ].Size := iLen;
	WadEntries [ nWadEntries ].EntryType := 0;
	//
	//WadEntryIdentify ( nWadEntries );
End;

Procedure TFormMain.IdentifyAllEntries;
Var
	i : Integer;
Begin
	For i := 1 To nWadEntries Do
	Begin
		WadEntryIdentify ( i );
		If ( i And 255 ) = 0 Then
		Begin
			Status ( 'Processed ' + Comma ( i ) + ' entries' );
		End;
	End;
End;

Function TFormMain.LoadWadEntries : Boolean;
Var
	Entries : Longint;
	i : Integer;

Function EndOfFile : Boolean;
Begin
	{$IFDEF FULLVERSION}
	If FileType <> PKFile Then
	Begin
	{$ENDIF}
		EndOfFile := EOF ( f );
		{$IFDEF FULLVERSION}
	End
	Else
		EndOfFile := False;
	{$ENDIF}
End;

Begin
	If fOpenCount > 0 Then
	Begin
		Status ( 'WARNING: The file was still open (usually means last operation failed)' );
		//ShowMessage ( 'The file was still open.' );
		While fOpenCount > 0 Do
		Begin
			fClose;
		End;
	End;

	If Not fOpen ( sFileName ) Then
	Begin
		LoadWadEntries := False;
	End
	Else
	Begin
		//
		gFileReadOnly := LastFileReadOnly; // store read-only flag only here
		//
		If Not ReadWadHeader ( f, Entries, iWadDirPos ) Then
		Begin
			fClose;
			LoadWadEntries := False;
		End
		Else
		Begin

			//
			Starting;

			nWadEntries := 0;
			iWadEntryType := 0; // clear section type

			//
			{$IFDEF FULLVERSION}
			If FileType <> PKFile Then
			Begin
				//
				// initial seek
				//
				Seek ( f, iWadDirPos );
			End;
			{$ENDIF}

			While Not EndOfFile And ( nWadEntries < Entries ) Do
			Begin
				Try
					{$IFDEF FULLVERSION}
					Case FileType Of

						ftWadFile :
						Begin
							{$ENDIF}
							//Seek ( f, iWadDirPos + ( 8 + 4 + 4 ) * nWadEntries );
							WadEntryLoad ( f );
							{$IFDEF FULLVERSION}
						End;

						Wad2File, Wad3File :
						Begin
							Seek ( f, iWadDirPos + ( 4 + 4 + 8 + 16 ) * nWadEntries );
							WadEntryLoad ( f );
						End;

						DukeFile :
						Begin
							Seek ( f, iWadDirPos + ( 12 + 4 ) * nWadEntries );
							WadEntryLoad ( f );
						End;

						Duke2File :
						Begin
							Seek ( f, iWadDirPos + ( 12 + 4 + 4 ) * nWadEntries );
							WadEntryLoad ( f );
						End;

						QuakeFile :
						Begin
							Seek ( f, iWadDirPos + ( 56 + 4 + 4 ) * nWadEntries );
							WadEntryLoad ( f );
						End;

						UnrealFile :
						Begin
							// seek only for first entry
							If nWadEntries = 0 Then
							Begin
								UnrealLoadNameTable;
								fSeek ( f, iWadDirPos );
							End
							Else
							Begin
								fSeek ( f, LastEntryPos );
							End;
							WadEntryLoad ( f );
						End;

						RFFFile :
						Begin
							Seek ( f, iWadDirPos + ( 48 ) * nWadEntries );
							WadEntryLoad ( f );
						End;

						PKFile :
						Begin
							WadEntryLoad ( f );
						End;

						SingleFile :
						Begin
							Inc ( nWadEntries );
							WadEntries [ nWadEntries ].Name := UpperCase ( RemoveFolder ( sFileName ) );
							WadEntries [ nWadEntries ].Position := 0;
							WadEntries [ nWadEntries ].Size := FileSize ( f );
							WadEntryIdentify ( nWadEntries );
						End;

						SingleLumpFile :
						Begin
							Inc ( nWadEntries );
							WadEntries [ nWadEntries ].Name := UpperCase ( RemoveFolder ( sFileName ) );
							If UpperCase ( KeepFromRight ( WadEntries [ nWadEntries ].Name, 4 ) ) = '.LMP' Then
							Begin
								WadEntries [ nWadEntries ].Name := RemoveFromRight ( WadEntries [ nWadEntries ].Name, 4 ); 
							End;
							WadEntries [ nWadEntries ].Position := 0;
							WadEntries [ nWadEntries ].Size := FileSize ( f );
							WadEntryIdentify ( nWadEntries );
						End;

						WolfFile :
						Begin
							WadEntryLoad ( f );
						End;

						WolfAudioFile :
						Begin
							If nWadEntries = 0 Then
							Begin
								LoadWolfAudioHeader;
							End;
							//
							WadEntryLoad ( f );
							//
						End;

						AdrenixFile :
						Begin
							Seek ( f, iWadDirPos + nWadEntries * ( 20 + 4 ) );
							WadEntryLoad ( f );
						End;

						DarkForcesFile :
						Begin
							Seek ( f, iWadDirPos + 4 + nWadEntries * ( 4 + 4 + 13 ) );
							WadEntryLoad ( f );
						End;

						DarkForcesLFDFile :
						Begin
							Seek ( f, iWadDirPos + nWadEntries * ( 4 + 8 + 4 ) );
							WadEntryLoad ( f );
							//
							If WadEntries [ nWadEntries ].Position = 0 Then
							Begin
								// Exit from loop
								Dec ( nWadEntries );
								Entries := nWadEntries;
								//
								WadEntries [ 1 ].Position := nWadEntries * ( 4 + 8 + 4 );
								//
								For i := 2 To nWadEntries Do
								Begin
									WadEntries [ i ].Position :=
										WadEntries [ i - 1 ].Position +
										WadEntries [ i - 1 ].Size;
								End;
							End;
						End;

						PIGFile, PIG2File :
						Begin
							If nWadEntries <= iDP_TextureEntries Then
							Begin
								If FileType = PIG2File Then
									Seek ( f, iWadDirPos + nWadEntries * 18 )
								Else
									Seek ( f, iWadDirPos + nWadEntries * 17 );
							End
							Else
							Begin
								Seek ( f, iWadDirPos + iDP_TextureEntries * 17 +
									( nWadEntries - iDP_TextureEntries ) * 20 );
								//
							End;
							//
							WadEntryLoad ( f );
							//
							If nWadEntries = iDP_TextureEntries Then
							Begin
								For i := 1 To nWadEntries Do
								Begin
									WadEntries [ i ].Size := WadEntries [ i + 1 ].Position - WadEntries [ i ].Position;
								End;
							End;
						End;

						TLKFile :
						Begin
							Seek ( f, LastEntryPos );
							WadEntryLoad ( f );
							//
							If WadEntries [ nWadEntries ].Name = '' Then
							Begin
								Dec ( nWadEntries );
								Entries := nWadEntries;
							End;
						End;

						HOGFile :
						Begin
							Seek ( f, LastEntryPos );
							WadEntryLoad ( f );
							//
							If LastEntryPos >= FileSize ( f ) Then
							Begin
								// Exit from loop
								Entries := nWadEntries;
							End;
						End;

						PODFile :
						Begin
							Seek ( f, iWadDirPos + nWadEntries * 32 );
							WadEntryLoad ( f );
							//
							If Entries = nWadEntries Then
							Begin
								//
								// --- After last entry, read names
								//
								Seek ( f, iWadDirPos + nWadEntries * 32 );
								//
								For i := 1 To nWadEntries Do
								Begin
									WadEntries [ i ].Name := GetZString ( f );
									WadEntryIdentify ( i );
									//
									If ( i And 31 ) = 0 Then
									Begin
										Status ( 'Loaded ' + Comma ( i ) + ' entry names' );
									End;
								End;
							End;
						End;

						LGRESFile :
						Begin
							fSeek ( f, iWadDirPos + nWadEntries * 10 );
							WadEntryLoad ( f );
						End;

						TRFile, GRFile :
						Begin
							fSeek ( f, iWadDirPos + nWadEntries * 4 );
							WadEntryLoad ( f );
						End;

						EOB1File :
						Begin
							WadEntryLoad ( f );
							//
							If WadEntries [ nWadEntries ].Position = 0 Then
							Begin
								// Exit from loop
								Dec ( nWadEntries );
								Entries := nWadEntries;
							End;
						End;

						EOB3File :
						Begin
							WadEntryLoad ( f );
							//
							If WadEntries [ nWadEntries ].Position = 0 Then
							Begin
								// Exit from loop
								Dec ( nWadEntries );
								Entries := nWadEntries;
								//
								LoadEOB3Names;
							End;
						End;

						ROTH2File :
						Begin
							Seek ( f, LastEntryPos );
							WadEntryLoad ( f );
							//
							If ( LastEntryPos >= FileSize ( f ) ) Or ( LastEntryPos < 0 ) Then
							Begin
								//Dec ( nWadEntries );
								Entries := nWadEntries;
							End;
						End;

						ROTH5File :
						Begin
							If ( LastEntryPos + 8 > FileSize ( f ) ) Or ( nWadEntries = 5000 ) Then
							Begin
								Dec ( nWadEntries );
								Entries := nWadEntries;
							End
							Else
							Begin
								Seek ( f, LastEntryPos );
								WadEntryLoad ( f );
							End;
						End;

						DASFile :
						Begin
							Seek ( f, LastEntryPos );
							WadEntryLoad ( f );
						End;

						FORMFile :
						Begin
							If ( LastEntryPos >= FileSize ( f ) ) Or ( nWadEntries = 5000 ) Then
							Begin
								//Dec ( nWadEntries );
								Entries := nWadEntries;
							End
							Else
							Begin
								// Seek ( f, LastEntryPos );
								WadEntryLoad ( f );
							End;
						End;

						RIDFile :
						Begin
							If ( LastEntryPos >= FileSize ( f ) )
							Or ( LastEntryPos <= 0 ) Then
								Entries := nWadEntries
							Else
							Begin
								//
								Seek ( f, LastEntryPos );
								WadEntryLoad ( f );
								//
								If ( LastEntryPos >= FileSize ( f ) ) Then
									Entries := nWadEntries;
								//
								If WadEntries [ nWadEntries ].Position = 0 Then
								Begin
									// Exit from loop
									Dec ( nWadEntries );
									Entries := nWadEntries;
								End;
							End;
						End;

						MTIFile, DTIFile, SNIFile :
						Begin
							fSeek ( f, iWadDirPos + nWadEntries * 24 );
							WadEntryLoad ( f );
						End;

						REZFile :
						Begin
							Seek ( f, LastEntryPos );
							WadEntryLoad ( f );
							//
							If ( LastEntryPos = FileSize ( f ) ) Then
								Entries := nWadEntries;
						End;

						GLBFile :
						Begin
							fSeek ( f, iWadDirPos + nWadEntries * ( 20 + 4 + 4 ) );
							WadEntryLoad ( f );
						End;

						LABFile :
						Begin
							fSeek ( f, iWadDirPos + nWadEntries * 16 );
							WadEntryLoad ( f );
						End;

						CSFile :
						Begin
							Seek ( f, LastEntryPos );
							WadEntryLoad ( f );
						End;

						RBXFile :
						Begin
							fSeek ( f, iWadDirPos + nWadEntries * 16 );
							WadEntryLoad ( f );
						End;

						XPRFile :
						Begin
							Seek ( f, LastEntryPos );
							WadEntryLoad ( f );
							//
							If iXPR_DirLen <= 0 Then
							Begin
								Entries := nWadEntries;
							End;
						End;

						BLOFile, KTREZFile :
						Begin
							fSeek ( f, iWadDirPos + nWadEntries * 12 );
							WadEntryLoad ( f );
						End;

						WRSFile : // doesn't work - entries are compressed
						Begin
							fSeek ( f, LastEntryPos );
							WadEntryLoad ( f );
							//
							If LastEntryPos >= FileSize ( f ) Then
								Entries := nWadEntries;
						End;

						PoziFile, QNFile : // Pozi : Scrapland packed files, QN: Outcast.PAK
						Begin
							fSeek ( f, LastEntryPos );
							WadEntryLoad ( f );
						End;

						AARESFile : // Amulets and Armor RES files
						Begin
							iAAR_EntriesInc := 0;
							//
							fSeek ( f, iWadDirPos + ( nWadEntries - iAAR_EntriesAdded ) * 39 );
							WadEntryLoad ( f );
							//
							Inc ( Entries, iAAR_EntriesInc );
							Inc ( iAAR_EntriesAdded, iAAR_EntriesInc );
						End;

						JFKWadFile :
						Begin
							Seek ( f, LastEntryPos );
							WadEntryLoad ( f );
						End;

						FShockFile : // Future Shock TEXTURE.###
						Begin
							WadEntryLoad ( f );
							//
							If ( LastEntryPos >= FileSize ( f ) ) Or ( LastEntryPos = 0 ) Then
								Entries := nWadEntries;
						End;

					End;
					{$ENDIF}
					//
					// --- Update counter
					//
					If ( nWadEntries And 255 ) = 0 Then
					Begin
						Status ( 'Loaded ' + IntToStr ( nWadEntries ) + ' entries' );
					End;
					//
					If nWadEntries = MaxWadEntries Then
					Begin
						Entries := MaxWadEntries;
					End;
					//
				Except
				End;
			End;
			//
			IdentifyAllEntries;
			//
			fClose;
			//
			ShowWadEntries;
			//
			Finished;
			//
			LoadWadEntries := True;
		End;
	End;
End;

function TFormMain.FileLastModified ( const TheFile: String ) : String;
Var
	FileH : THandle;
	LocalFT : TFileTime;
	DosFT : DWORD;
	LastAccessedTime : TDateTime;
	FindData : TWin32FindData;
  sResult : String;
Begin
	sResult := '';
	FileH := FindFirstFile(PChar(TheFile), FindData);
	if FileH <> INVALID_HANDLE_VALUE then
	begin
		Windows.FindClose(Handle);
		if (FindData.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY) = 0 then
		begin
			FileTimeToLocalFileTime ( FindData.ftLastWriteTime,LocalFT );
			FileTimeToDosDateTime ( LocalFT,LongRec(DosFT).Hi,LongRec(DosFT).Lo);
			LastAccessedTime := FileDateToDateTime(DosFT);
			sResult := DateTimeToStr(LastAccessedTime);
		end;
	end;
  FileLastModified := sResult;
End;

procedure TFormMain.UpdateModifiedDate;
Begin
	sLastModifiedDate := FileLastModified ( sFileName );
	{$IFDEF USEDEBUG}
	DoDebugLn ( 'LastModDate "' + sLastModifiedDate + '"' );
	{$ENDIF}
End;

procedure TFormMain.OpenWad ( sFile : String; bQuiet : Boolean );
Var
	t0 : Cardinal;
	s : String;
	bSuccess : Boolean;
Begin
	t0 := GetTickCount;
	//
	{$IFDEF USEDEBUG}
	DoDebugLn ( 'Load "' + sFile + '"' );
	{$ENDIF}
	//
	sFileName := sFile;
	UpdateModifiedDate;
	//
	ResetAll;
	//
	s := sFileName;
	If Pos ( '\', s ) > 0 Then
	Begin
		s := RemoveFromLeft ( s, PosR ( '\', s ) );
	End;
	//
	// *** try to open file first
	//
	bSuccess := False;
	While fOpenCount > 0 Do
	Begin
		fClose;
	End;
	If fOpen_ ( sFileName, bQuiet ) Then
	Begin
		fClose;
		//
		If LoadWadEntries Then
		Begin
			//
			MenuFileFunctions ( True );
			//
			{$IFDEF FULLVERSION}
			MenuModifyFunctions ( IsFileEditable And Not gFileReadOnly );
			{$ENDIF}
			//
			If ( ListWad.Visible ) And ( PanelBrowse.Visible ) Then
				ListWad.SetFocus;
			//
			If ListWad.Items.Count > 0 Then
			Begin
				ListWad.Items [ 0 ].Focused := True;
				ListWad.Items [ 0 ].Selected := True; // triggers ShowEntry
			End;
			//
			// Set Window Title
			If gFileReadOnly Then
			Begin
				s := s + ' (Read only)';
			End;
			Caption := s + ' - eXtendable Wad Editor';
			Application.Title := Caption;
			//
			// MRU
			If Not bNoMRU Then
			Begin
				Try
					InsertMRU ( sFileName );
				Finally
				End;
			End;
			//
			bSuccess := True;
		End;
	End;
	//
	Modified ( False ); // to flag read-only files
	//
	If Not bSuccess Then
	Begin
		//
		MenuFileFunctions ( False );
		//
		{$IFDEF FULLVERSION}
		MenuModifyFunctions ( False );
		{$ENDIF}
		//
		Status ( 'Could not open ' + s );
	End
	Else
	Begin
		If gAutoBackup And Not gFileReadOnly Then
		Begin
			WadFileCleanUp ( True );
		End;
		Status ( 'Opened ' + s + ' (' + Comma ( nWadEntries ) + ' entries; ' + Comma ( GetTickCount - t0 ) + ' ms) (File type: ' + IntToStr ( Ord ( FileType ) ) + ')' );
	End;
End;

procedure TFormMain.FormActivate(Sender: TObject);

Var
	bFileOpened : Boolean;

procedure RestoreWindowPos;
Var
	r : TRegistry;
	n, w : Integer;

function GetInt ( s : String ) : Integer;
Begin
	if r.ValueExists ( s ) Then
		GetInt := r.ReadInteger ( s )
	Else
		GetInt := 0;
end;

Begin
	//
	If Not bNoRegistry Then
	Begin
		r := TRegistry.Create;
		Try
			r.OpenKey ( 'Software\Csabo\XWE', True );
			//
			// -- Screen Position
			//
			If Not r.ValueExists ( 'WindowLeft' ) Then
			Begin
				// first time
				Left := 50;
				Top := 50;
				Width := Screen.Width - 100;
				Height := Screen.Height - 100;
			End
			Else
			Begin
				//
				n := GetInt ( 'WindowLeft' );
				If ( n < 0 ) Or ( n > Screen.Width ) Then n := 0;
				Left := n;

				n := GetInt ( 'WindowWidth' );
				If n < 120 Then n := 120;
				Width := n;

				n := GetInt ( 'WindowTop' );
				If ( n < 0 ) Or ( n > Screen.Height ) Then n := 0;
				Top := n;

				n := GetInt ( 'WindowHeight' );
				If n < 90 Then n := 90;
				Height := n;
				//
				n := GetInt ( 'WindowState' );
				WindowState := TWindowState ( n );
			End;
			//
			// ---
			//
			If r.ValueExists ( 'ColWidth0' ) Then
			Begin
				For n := 0 To ListWad.Columns.Count - 1 Do
				Begin
					w := GetInt ( 'ColWidth' + IntToStr ( n ) );
					If ( w < 0 ) Then w := 0;
					If ( w > 300 ) Then w := 300;
					ListWad.Columns.Items [ n ].Width := w;
				End;
			End
			Else
			Begin
				ListWad.Columns.Items [ 0 ].Width := 80;
				ListWad.Columns.Items [ 1 ].Width := 0;
				ListWad.Columns.Items [ 2 ].Width := 50;
				ListWad.Columns.Items [ 3 ].Width := 50;
				ListWad.Columns.Items [ 4 ].Width := 0;
			End;
			//
			If r.ValueExists ( 'PanelBrowseWidth' ) Then
				PanelBrowse.Width := GetInt ( 'PanelBrowseWidth' );
			//
			// ---
			//
			r.CloseKey;
		Finally
			r.Free;
		End;
	End;
end;

Begin
	If Tag = 0 Then
	Begin
		RestoreWindowPos;
		//
		bFileOpened := False;
		//
		If ParamCount > 0 Then
		Begin
			Application.ProcessMessages;
			//
			if LowerCase ( ParamStr ( 1 ) ) = '-debug' Then
			Begin
				{$IFDEF USEDEBUG}
				StartDebug;
				DoDebugLn ( 'Session Start ' + DateTimeToStr ( Now ) );
				{$ENDIF}
			End
			Else
			Begin
				bFileOpened := True;
				OpenWad ( ParamStr ( 1 ), True ); // be quiet
			End;
		End;
		//
		If Not bFileOpened Then
		Begin
			//
			If gOpenLast Then
			Begin
				If MRU [ 0 ] <> '' Then
				Begin
					Application.ProcessMessages;
					OpenWad ( MRU [ 0 ], True ); // be quiet
				End;
			End;
			//
		End;
		Tag := 1;
	End;
	Caption := Caption + '!';
end;

procedure TFormMain.FormDestroy(Sender: TObject);
Var
	r : TRegistry;
	i : Integer;
	hCMaxFont : HFONT;
	CMaxFont : TLogFont;
	s : String;

Function IsOnlyInstance : Boolean;
var
	aClassName  : array[0..255] of char;
	aHandle    : HWND;
begin
	CreateMutex(nil, false, 'MyApp');
 {if it failed then there is another instance}
	if GetLastError = ERROR_ALREADY_EXISTS then begin
	 {Send all windows our custom message - only our other}
	 {instance will recognise it, and restore itself}
		SendMessage(HWND_BROADCAST,
								RegisterWindowMessage('MyApp'),
								0,
								0);
	 {Lets quit}
		Halt(0);
	end;

	GetClassName(Application.Handle, aClassName, SizeOf(aClassName));
	aHandle := FindWindow(aClassName, Nil);
	IsOnlyInstance := aHandle = 0;
end;

Begin
	{$IFDEF USEDEBUG}
	DoDebugLn ( 'Session End ' + DateTimeToStr ( Now ) );
	EndDebug;
	{$ENDIF}
	//
	If Not bNoRegistry Then
	Begin
		r := TRegistry.Create;
		Try
			If r.OpenKey ( 'Software\Csabo\XWE', True ) Then
			Begin
				//
				// -- Window position -------------
				//
				r.WriteInteger ( 'WindowState', Ord ( WindowState ) );
				//
				If WindowState = wsNormal Then
				Begin
					LastLeft := Left;
					LastTop := Top;
				End;
				r.WriteInteger ( 'WindowLeft', LastLeft );
				r.WriteInteger ( 'WindowTop', LastTop );
				//
				r.WriteInteger ( 'WindowWidth', LastWidth );
				r.WriteInteger ( 'WindowHeight', LastHeight );
				//
				// -- Columns --------------------
				//
				For i := 0 To ListWad.Columns.Count - 1 Do
				Begin
					r.WriteInteger ( 'ColWidth' + IntToStr ( i ), ListWad.Columns.Items [ i ].Width );
				end;
				r.WriteInteger ( 'PanelBrowseWidth', PanelBrowse.Width );
				//
				// -- Options ---------------------
				//
				r.WriteString ( 'LastFolderImport', sLastFolderImport );
				r.WriteString ( 'LastFolderExport', sLastFolderExport );
				r.WriteString ( 'LastFolderXWEScript', sLastFolderXWEScript );
				r.WriteString ( 'TempFolder', sTempFolder );
				r.WriteBool ( 'OpenLast', gOpenLast );
				r.WriteBool ( 'CutCopyEmpty', gCutCopyEmpty );
				r.WriteBool ( 'OnlyOneBackup', gOnlyOneBack );
				r.WriteBool ( 'AutoCleanUp', gAutoCleanUp );
				r.WriteBool ( 'AutoBackup', gAutoBackup );
				r.WriteBool ( 'PreviewMaps', gPreviewMaps );
				r.WriteBool ( 'AutoPlaySounds', gAutoPlaySounds );
				r.WriteBool ( 'DisableUndo', gDisableUndo );
				r.WriteBool ( 'RawPNG', gRawPNG );
				r.WriteBool ( 'AutoApplyOffsets', gAutoApplyOffsets );
				//
				r.WriteBool ( 'ShowFullPath', gShowFullPath );
				r.WriteBool ( 'ShowSize', gShowSize );
				r.WriteBool ( 'ShowPosition', gShowPosition );
				r.WriteBool ( 'DontAutoCapitalize', gDontAutoCapitalize );
				//
				r.WriteInteger ( 'Associations', Ord ( gAssociations ) );
				//
				r.WriteBool ( 'MapEditorPropertiesBar', mnuMapViewPropertiesBar.Checked );
				r.WriteBool ( 'MapEditorWadedBar', mnuMapViewWadedBar.Checked );
				r.WriteBool ( 'MapEditorGrid', mnuMapViewGrid.Checked );
				//
				r.WriteBool ( 'ViewEntryList', mnuViewEntryList.Checked );
				r.WriteBool ( 'ViewMenuBar', mnuViewMenuBar.Checked );
				r.WriteBool ( 'ViewFilterToolbar', mnuViewFilterToolbar.Checked );
				r.WriteBool ( 'ViewStatusBar', mnuViewStatusBar.Checked );
				//
				// -- CodeMax -----
				//
				if bHasCodeMax And ( ScriptCMax <> nil ) Then
				Begin
					Try
						hCmaxFont := SendMessage( ScriptCMax.Handle, WM_GETFONT, 0, 0 );
						If GetObject ( hCmaxFont, SizeOf ( CMaxFont ), Addr ( CMaxFont ) ) > 0 Then
						Begin
							r.WriteString ( 'CodeMaxFont', CMaxFont.lfFaceName + ';' + IntToStr ( CMaxFont.lfHeight ) );
						End;
						r.WriteBool ( 'CodeMaxSyntaxHighlighting', ( SendMessage ( ScriptCMax.Handle, CMM_ISCOLORSYNTAXENABLED, 0, 0) ) > 0 );
					Except
						Application.ProcessMessages;
					End;
				End;
				//
				r.CloseKey;
			End;
		Finally
			r.Free;
		End;
	End;
	//
	If Not bNoMRU Then
	Begin
		SaveMRU;
	End;
	//
	// --- Scripts
	ScriptLines.Free;
	//
	// --- Wave
	WaveFreeMem;
	//
	// --- Zip
	{$IFDEF FULLVERSION}
	If ZipDllsLoaded Then
	Begin
		zipM.Unload_Zip_Dll;
		zipM.Unload_Unz_Dll;
	End;
	{$ENDIF}
	//
	s := '*';
	If Not IsOnlyInstance Then
		s := '(' + sUniqueID + ')*';
	//
	Try
		DeleteTempFiles ( sTempFolder, s );
	Except
	End;
	//
	// --- ScriptEditor
	If bScriptInit Then
	Begin
		If bHasCodeMax Then
		Begin
			ScriptCMax.Free;
		End;
	End;
end;

// returns True, if externally modified
Function TFormMain.isFileExtModified : Boolean;
Var
	sDate : String;
Begin
	If sFileName = '' Then
	Begin
		isFileExtModified := False;
	End
	Else
	Begin
		sDate := FileLastModified ( sFileName );
		If sDate <> sLastModifiedDate Then
		Begin
			isFileExtModified := True;
			{$IFDEF USEDEBUG}
			DoDebug ( 'LastModDate of "' + sFileName + '" is "' + sDate + '"' );
			DoDebugLn ( ', different from "' + sLastModifiedDate + '"' );
			{$ENDIF}
		End
		Else
		Begin
			isFileExtModified := False;
		End;
	End;
End;

// returns True, if it's okay to continue
Function TFormMain.CheckFileExtModified : Boolean;
Var
	iAnswer : Integer;
	b : Boolean;
Begin
	b := True;
	If isFileExtModified Then
	Begin
		b := False;
		Application.ProcessMessages;
		iAnswer := MessageDlg ( 'The currently open file was modified by an external program.' +
			#13 + #13 + 'Performing this action may corrupt the file.' +
			#13 + #13 + 'To avoid file corruption, you should cancel this action, then close and re-open this file.', mtWarning, [mbOK]+[mbCancel], 0 );
		If iAnswer = mrOk Then
			b := True;
	End;
	CheckFileExtModified := b;
End;

Procedure TFormMain.WarnFileExtModified;
Begin
	If isFileExtModified Then
	Begin
		{$IFDEF USEDEBUG}
		DoDebugLn('WarnFileExtModified');
		{$ENDIF}
		Application.ProcessMessages;
		MessageDlg ( 'The currently open file was modified by an external program.' +
			#13 + #13 + 'To avoid file corruption, you should then close and re-open this file.', mtWarning, [mbOK], 0 );
	End;
End;

Function TFormMain.CheckModified : Boolean;
Var
	iAnswer : Integer;
Begin
	If IsModified Then
	Begin
		//
		Application.ProcessMessages;
		iAnswer := MessageDlg ( 'This entry ("' +
			Trim ( WadEntries [ iWadEntryCurrentIndex ].Name ) +
			'") has been modified.' +
			#13 + #13 + 'Save changes?', mtConfirmation, mbYesNoCancel, 0 );
		//
		If iAnswer = mrYes Then
		Begin
			If Not SaveEntry Then
			Begin
				ShowMessage ( 'Could not save entry,' + #13 +
					'please try manual save from current editor.' );
				iAnswer := mrCancel;
			End;
		End;
		//
		If iAnswer = mrNo Then
		Begin
			Modified ( False );
		End;
	End
	Else
	Begin
		iAnswer := mrYes;
	End;
	//
	CheckModified := iAnswer <> mrCancel;
End;

procedure TFormMain.mnuFileMRUClick(Sender: TObject);
Begin
	If CheckModified Then
	Begin
		WadFileAutoCleanUp;
		OpenWad ( MRU [ TMenuItem(Sender).Tag ], False );
	End;
end;

procedure TFormMain.mnuFileOpenClick(Sender: TObject);
Var
	s : String;
Begin
	If CheckModified Then
	Begin
		With OpenDialog1 Do
		Begin
			//
			InitialDir := Copy ( sFileName, 1, PosR ( '\', sFileName ) - 1 );
			//
			Title := 'Open Wad File';
			//
			If Filter = '' Then
			Begin
				{$IFDEF FULLVERSION}
				s := '*.wa?;*.lmp;*.grp;*.dat;*.pak;*.re?;' +
					'*.u?x;*.crf;*.pk3;' +
					'*.art;*.ppm;*.can;*.hog;*.pig;*.pod;*.cps;*.tlk;' +
					'*.tr;*.gr;*.byt;*.das;*.bnd;*.b16;*.dtx;*.rid;*.mt?;' +
					'*.g?b;*.lab;*.nwx;*.blo;*.rbx;*.xpr;' +
					'*.col;*.pal;*.act;*.voc;' +
					'*.bmp;*.jpg;*.pcx;*.tga;' +
					'*.rff;*.lfd;*.dti;*.sni;';
				Filter := 'XWE Files|' + s + '|More XWE Files|' +
					'*.vgr;*.vga;texture.*;vswap.*;audiot.*;gfxtiles.*;eye.res' +
					'|All Files|*.*';
				{$ELSE}
				Filter := 'XWE Files|*.wad|All Files|*.*';
				{$ENDIF}
			End;
			//
			FilterIndex := 1;
			//
			If Execute Then
			Begin
				s := FileName;
				Application.ProcessMessages;
				//
				ResetUndo;
				//
				OpenWad ( s, False );
			End;
		End;
	End;
end;

procedure TFormMain.ShowPage ( iEditorPage : TEditor );
Begin
	CurrentEditor := iEditorPage;
	If ( iEditorPage <> edMap ) Then
		StatusMode ( '' ); // clear status box used only for map editor

	// 1 : Hex
	PanelHex.Visible := iEditorPage = edHex;
	mnuHex.Visible := iEditorPage = edHex;

	// 2 : Image
	PanelImage.Visible := iEditorPage = edImage;
	mnuImage.Visible := iEditorPage = edImage;

	// 3 : Grid
	PanelGrid.Visible := iEditorPage = edGrid;
	mnuGrid.Visible := iEditorPage = edGrid;

	// 4 : Texture
	PanelTexture.Visible := iEditorPage = edTexture;
	mnuTextures.Visible := iEditorPage = edTexture;

	// 5 : TextScreen
	PanelTextScreen.Visible := iEditorPage = edTextScreen;
	mnuTextScreen.Visible := iEditorPage = edTextScreen;

	// 6 : Palette
	PanelPalette.Visible := iEditorPage = edPalette;
	mnuPalette.Visible := iEditorPage = edPalette;

	// 7 : Wave
	PanelWave.Visible := iEditorPage = edWave;
	mnuWave.Visible := iEditorPage = edWave;

	// 8 : PatchNames
	PanelPatchNames.Visible := iEditorPage = edPatchNames;
	mnuPatchNames.Visible := iEditorPage = edPatchNames;

	// 9 : Map
	PanelMap.Visible := iEditorPage = edMap;
	mnuMap.Visible := iEditorPage = edMap;
	mnuMapView.Visible := iEditorPage = edMap;
	mnuSelection.Visible := iEditorPage = edMap;
	mnuLineDefs.Visible := iEditorPage = edMap;

	// 10 : Mus
	PanelMus.Visible := iEditorPage = edMus;
	mnuMusic.Visible := iEditorPage = edMus;

	// 11 : Script
	PanelScript.Visible := iEditorPage = edScript;
	mnuScript.Visible := iEditorPage = edScript;

	// 12 : ColorMap
	PanelColorMap.Visible := iEditorPage = edColorMap;
	mnuColorMap.Visible := iEditorPage = edColorMap;
End;

procedure TFormMain.mnuFileCloseClick(Sender: TObject);
Begin
	If CheckModified Then
	Begin
		WadFileAutoCleanUp;
		//
		sFileName := '';
		//
		ResetAll; // includes resetundo
	End;
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	If Not CheckModified Then
		CanClose := False
	Else
	Begin
		WadFileAutoCleanUp;
	End;
end;

procedure TFormMain.mnuFileExitClick(Sender: TObject);
Begin
	If CheckModified Then
	Begin
		WadFileAutoCleanUp;
		//
		Close;
	End;
end;

Function TFormMain.IsFileOpen : Boolean;
Begin
  IsFileOpen := sFileName <> '';
End;

Procedure TFormMain.ResetAll;
Begin
	Starting;
	//
	nWadEntries := 0;
	ListWad.Visible := False;
	ListWad.Items.Clear;
	EditQuickFind.Text := '';
	//
	StatusBrowse.Panels.Items [ 0 ].Text := 'No file.';
	//
	ResetUndo;
	//
	Modified ( False );
	//
	ShowPage ( edNone );
	//
	MenuFileFunctions ( False );
	//
	Caption := 'eXtendable Wad Editor';
	Application.Title := Caption;
	//
	// ---
	//
	nTextures := 0;
	nTexturePatches := 0;
	nPatches := 0;
	//
	iWadEntryLastPos := -1;
	//
	If iPreferredPal <> -2 Then
		PaletteReady := False;
	//
	Finished;
	//
End;

// ############################################################################
// UNDO functions

Procedure TFormMain.DeleteTempFiles ( sFolder, sMask : String );
Var
	f : File;
	s : String;
	sr : TSearchRec;
	Error : Integer;
Begin
	s := sFolder + '(xwe)' + sMask;
	//
	Try
		mpMusic.Close;
	Except
	End;
	//
	Error := FindFirst ( s, faAnyFile, sr );
	While ( Error = 0 ) Do
	Begin
		Try
			{$I-}
			AssignFile ( f, sFolder + sr.Name );
			Erase ( f );
			{$I+}
		Except
		End;
		Error := FindNext ( sr );
	End;
End;

Procedure TFormMain.ResetUndo;
Begin
	nUndo := 0;
	mnuEditUndo.Caption := '&Undo';
	mnuEditUndo.Enabled := False;
End;

Procedure TFormMain.SaveUndo ( s : String );
Var
	sNewFile : String;
Begin
	If Not gDisableUndo And Not gFileReadOnly Then
	Begin
		Inc ( nUndo );
		//
		sNewFile := sTempFolder + '(xwe)(' + sUniqueID + ')(Undo)' + IntToStr ( nUndo ) + '-' + s;
		//
		CopyFile ( PChar ( sFileName ), PChar ( sNewFile ), False );
		//
		mnuEditUndo.Caption := '&Undo ' + s;
		mnuEditUndo.Enabled := True;
		//
		sLastUndo := s;
	End;
	//
	FileModified ( True );
End;

Function TFormMain.GetTempFileName ( n : Integer; bUndo : Boolean ) : String;
Var
	s : String;
	sr : TSearchRec;
	Error : Integer;
Begin
	If bUndo Then
		s := 'Undo'
	Else
		s := 'Clip';
	//
	s := sTempFolder + '(xwe)(' + sUniqueID + ')(' + s + ')' + IntToStr ( n ) + '-*';
	//
	Error := FindFirst ( s, faAnyFile, sr );
	If Error = 0 Then
	Begin
		GetTempFileName := sTempFolder + sr.Name;
	End
	Else
	Begin
		GetTempFileName := '';
	End;
End;

procedure TFormMain.mnuEditUndoClick(Sender: TObject);
Var
	f : File;
	s : String;
Begin
	s := GetTempFileName ( nUndo, True );
	If s = '' Then
	Begin
		MessageDlg ( 'Could not perform undo.', mtError, [mbOK], 0 );
	End
	Else
	Begin
		CopyFile ( PChar ( s ), PChar ( sFileName ), False );
		//
		UpdateModifiedDate;
		LoadWadEntries;
		//
		ShowPage ( edNone );
		//
		AssignFile ( f, s );
		Erase ( f );
	End;
	//
	Dec ( nUndo );
	//
	If nUndo <= 0 Then
	Begin
		ResetUndo;
	End
	Else
	Begin
		s := GetTempFileName ( nUndo, True );
		s := RemoveFromLeft ( s, Pos ( '-', s ) );
		mnuEditUndo.Caption := '&Undo ' + s;
		mnuEditUndo.Enabled := True;
	End;
end;

//***************
//
//
Procedure TFormMain.UpdateWadEntry ( iListEntry, iEntry : Integer );
Var
	s : String;
	iEntryType : Integer;
Begin
	If ( iListEntry < 0 ) Or ( iListEntry >= ListWad.Items.Count ) Then
	Begin
		// - error, invalid list entry
	End
	Else
	Begin
		//
		// --- Get original name
		//
		s := WadEntries [ iEntry ].Name;
		//
		// --- Remove path if necessary
		//     WAD files never have paths
		//
		If Not gShowFullPath {$IFDEF FULLVERSION} And Not IsFileEditable {$ENDIF} Then
		Begin
			s := RemoveFolder ( s );
		End;
		//
		// --- Update list
		//
		With ListWad.Items [ iListEntry ] Do
		Begin
			Caption := s;
			SubItems.Clear;
			SubItems.Add ( IntToStr ( iEntry ) );
			//
			iEntryType := WadEntries [ iEntry ].EntryType;
			//
			If ( iEntryType < 1 ) Or ( iEntryType > nWadEntryTypes ) Then
				SubItems.Add ( '' )
			Else
				SubItems.Add ( WadEntryTypes [ iEntryType ].Description );
			//
			If gShowSize Then
			Begin
				SubItems.Add ( Comma ( WadEntries [ iEntry ].Size ) );
			End;
			//
			If gShowPosition Then
			Begin
				SubItems.Add ( IntToHex ( WadEntries [ iEntry ].Position, 8 ) );
			End;
			//
			If ( iEntryType >= 1 ) And ( iEntryType <= nWadEntryTypes ) Then
				ImageIndex := FindIcon ( WadEntryTypes [ iEntryType ].Icon )
			Else
				ImageIndex := 0;
		End;
	End;
End;

//**************
// Replace file
//**************

procedure TFormMain.ReplaceFile ( iEntry : Integer; sFN : String; bUndo, bRefreshList : Boolean );
Var
	fn : File;
	i : Integer;
	//
	iFileSize : Integer;
Begin
	If Not FileExists ( sFN ) Then
	Begin
		MessageDlg ( 'Cannot find file: ' + sFN, mtError, [mbOk], 0 );
	End
	Else
	Begin
		//
		{$I-}
		AssignFile ( fn, sFN );
		FileMode := fmOpenReadWrite;
		Reset ( fn, 1 );
		{$I+}
		i := IOResult;
		If i <> 0 Then
		Begin
			MessageDlg ( 'Could not open file: ' + sFN + #13 +
				'Error ' + IntToStr ( i ), mtError, [mbOk], 0 );
		End
		Else
		Begin
			//
			If Not fOpen ( sFileName ) Then
			Begin
				MessageDlg ( 'Could not open wad file!', mtError, [mbOk], 0 );
			End
			Else
			Begin
				iFileSize := FileSize ( fn );
				//
				ReplaceFilePart ( iEntry, fn, 0, iFileSize, bUndo );
				//
				fClose;
				//
				If bRefreshList Then
				Begin
					UpdateWadEntry ( EntryFindListIndex ( iEntry ), iEntry );
				End;
			End;
			CloseFile ( fn );
			//
			UpdateModifiedDate;
		End;
	End;
End;

procedure TFormMain.ReplaceFilePart ( iEntry : Integer; Var fx : File; iPos, iSize : Integer; bUndo : Boolean );
Var
	iPosition : Integer;
Begin
	If bUndo Then
	Begin
		SaveUndo ( 'Replace Entry ' + WadEntries [ iEntry ].Name );
	End;
	//
	// *** Check new file size with entry size ***
	// *** also check for null entry ***
	//
	If ( ( iSize <= WadEntries [ iEntry ].Size ) And ( WadEntries [ iEntry ].Position <> 0 ) )
	Or ( FileType = SingleLumpFile ) Then
	Begin
		//
		// *** Smaller, or equal, we can directly overwrite entry ***
		//
		iPosition := WadEntries [ iEntry ].Position;
	End
	Else
	Begin
		//
		// *** Too large, write it to the end of the file ***
		// *** or entry had no position, so put it to the end ***
		//
		iPosition := FileSize ( f );
	End;
	//
	Seek ( f, iPosition );
	//
	// ### COPY THE DATA ###
	//
	Seek ( fx, iPos );
	CopyData ( fx, f, iSize );
	//
	WadEntries [ iEntry ].Size := iSize;
	WadEntries [ iEntry ].Position := iPosition;
	//
	If ( FileType <> SingleLumpFile ) Then
	Begin
		// entry is 1 based, 16 bytes per record
		Seek ( f, iWadDirPos + ( iEntry - 1 ) * ( 4 + 4 + 8 ) );
		BlockWrite ( f, iPosition, 4 );
		BlockWrite ( f, iSize, 4 );
	End;
End;

// ###################
// Copy to Clipboard

Procedure TFormMain.EntryToClipBoard ( iEntry : Integer );
Var
	sNewFile : String;
Begin
	Inc ( nClipBoard );
	//
	sNewFile := sTempFolder + '(xwe)(' + sUniqueID + ')(Clip)' + IntToStr ( nClipBoard ) + '-' +
		Replace ( Trim ( WadEntries [ iEntry ].Name ), '\', '_' );
	//
	// --- Open new file
	//
	AssignFile ( fo, sNewFile );
	FileMode := fmOpenReadWrite;
	ReWrite ( fo, 1 );
	//
	// --- Open our file
	//
	fOpen ( sEditFile );
	Seek ( f, WadEntries [ iEntry ].Position );
	//
	// --- Copy the data
	//
	CopyData ( f, fo, WadEntries [ iEntry ].Size );
	//
	// --- Close the files
	//
	CloseFile ( fo );
	fClose;
	//
	// --- Paste is now enabled
	//
	mnuEditPaste.Enabled := Not gFileReadOnly;
	mnuEditEmptyClipboard.Enabled := True;
End;

procedure TFormMain.mnuEditCutClick(Sender: TObject);
Var
	t0 : Cardinal;
	i : Integer;
Begin
	t0 := GetTickCount;
	i := ListWad.SelCount;
	If i > 0 Then
	Begin
		mnuEditCopyClick ( Sender );
		//
		Status ( 'Working...' );
		//
		SaveUndo ( 'Cut ' + IntToStr ( i ) + ' entries' );
		//
		EntryDeleteSelected;
		UpdateModifiedDate;
		//
		ShowPage ( edNone );
		//
		Status ( IntToStr ( i ) + ' entries cut (' + Comma ( GetTickCount - t0 ) + ' milliseconds)' );
	End;
end;

procedure TFormMain.mnuEditCopyClick(Sender: TObject);
Var
	i, c : Integer;
	s : String;
Begin
	c := ListWad.SelCount;
	If c > 0 Then
	Begin
		//
		If gCutCopyEmpty Then
		Begin
			ClipboardEmpty;
		End;
		//
		// Go through the whole list
		For i := 0 To ListWad.Items.Count - 1 Do
		Begin
			// The selected ones...
			If ListWad.Items [ i ].Selected Then
			Begin
				// ... are copied
				EntryToClipBoard ( EntryGetIndex ( i ) );
			End;
		End;
		//
		s := IntToStr ( c ) + ' entr';
		If c = 1 Then
			s := s + 'y'
		Else
			s := s + 'ies';
		Status ( s + ' copied.' );
	End;
end;

Procedure TFormMain.ClipboardEmpty;
Begin
	DeleteTempFiles ( sTempFolder, '(' + sUniqueID + ')(Clip)*' );
	//
	nClipBoard := 0;
	//
	mnuEditPaste.Enabled := False;
	mnuEditEmptyClipboard.Enabled := False;
	//
	Status ( 'Clipboard emptied.' );
End;

procedure TFormMain.mnuEditEmptyClipboardClick(Sender: TObject);
Begin
	ClipboardEmpty;
end;

procedure TFormMain.mnuEditPasteClick(Sender: TObject);
Var
	t0 : Cardinal;
	//
	i, j, iPasteCount : Integer;
	s, s0 : String;
	//
	iEntryPos, iListEntry : Integer;
Begin
	t0 := GetTickCount;
	//
	Starting;
	//
	iPasteCount := 0;
	//
	For i := 1 To nClipBoard Do
	Begin
		s := GetTempFileName ( i, False );
		//
		If s <> '' Then
		Begin
			Inc ( iPasteCount );
			//
			If iPasteCount = 1 Then
			Begin
				SaveUndo ( 'Paste ' + IntToStr ( nClipBoard ) + ' entries' );
				//
				WadEntryNewGetPos ( iEntryPos, iListEntry );
				//
				// Add empty entries to the array
				//
				Inc ( nWadEntries, nClipBoard );
				For j := nWadEntries - nClipBoard DownTo iEntryPos Do
				Begin
					WadEntries [ j + nClipBoard ] := WadEntries [ j ];
				End;
				For j := iEntryPos To iEntryPos + nClipBoard - 1 Do
				Begin
					WadEntries [ j ].Name := '';
					WadEntries [ j ].Position := 0;
					WadEntries [ j ].Size := 0;
					WadEntries [ j ].EntryType := 0;
				End;
				//
				ReWriteDirectory ( True );
			End;
			//
			If ( i And 15 ) = 0 Then
			Begin
				Status ( IntToStr ( Round ( i / nClipBoard * 100 ) ) + '%' );
			End;
			//
			s0 := RemoveFromLeft ( s, PosR ( '(xwe)(' + sUniqueID + ')(Clip)', s ) + 10 );
			s0 := RemoveFromLeft ( s0, Pos ( '-', s0 ) );
			WadEntries [ iEntryPos ].Name := s0;
			//
			ReplaceFile ( iEntryPos, s, False, False );
			SaveWadEntryName ( iEntryPos );
			//
			ListWad.Items.Insert ( iListEntry );
			WadEntryIdentify ( iEntryPos );
			UpdateWadEntry ( iListEntry, iEntryPos );
			//
			Inc ( iEntryPos );
			Inc ( iListEntry );
		End;
	End;
	//
	If iPasteCount > 0 Then
	Begin
		For i := iListEntry To ListWad.Items.Count - 1 Do
		Begin
			ListWad.Items [ i ].SubItems [ 0 ] := IntToStr ( StrToInt ( ListWad.Items [ i ].SubItems [ 0 ] ) + iPasteCount );
		End;
	End;
	//
	mnuEditEmptyClipboardClick ( Sender );
	//
	Finished;
	//
	If iPasteCount > 0 Then
	Begin
		FileModified ( True );
		UpdateModifiedDate;
		Status ( 'Pasted ' + Comma ( iPasteCount ) + ' entries. (' + Comma ( GetTickCount - t0 ) + ' milliseconds)' );
	End
	Else
	Begin
		Status ( 'No entries were pasted.' );
	End;
	//
end;

// -----------------------
// This enables or disables all the functions that
// are not available for non-WAD files.
//

Procedure TFormMain.MenuModifyFunctions ( bEnable : Boolean );
Begin
	mnuFileMerge.Enabled := bEnable;
	mnuFileJoin.Enabled := bEnable;
	mnuFileCleanUp.Enabled := bEnable;
	//
	mnuEditPaste.Enabled := bEnable And ( nClipBoard > 0 ) And Not gFileReadOnly;
	//
	mnuEntryNew.Enabled := bEnable And Not gFileReadOnly;
	//mnuEntryRename.Enabled := bEnable;
	mnuEntryDelete.Enabled := bEnable And Not gFileReadOnly;
	mnuEntryLoad.Enabled := bEnable And Not gFileReadOnly;
	mnuEntryLoadRaw.Enabled := bEnable And Not gFileReadOnly;
	mnuEntryReplace.Enabled := bEnable And Not gFileReadOnly;
	mnuEntryReplaceRaw.Enabled := bEnable And Not gFileReadOnly;
	mnuEntryMoveUp.Enabled := bEnable And Not gFileReadOnly;
	mnuEntryMoveDown.Enabled := bEnable And Not gFileReadOnly;
	//
	mnuImageApply.Enabled := bEnable And Not gFileReadOnly;
	mnuImageSaveFlat.Enabled := bEnable And Not gFileReadOnly;
	mnuImageSave.Enabled := bEnable And Not gFileReadOnly;
	//
	mnuHexSave.Enabled := bEnable And Not gFileReadOnly;
	mnuPaletteSave.Enabled := bEnable And Not gFileReadOnly;
	mnuColorMapSave.Enabled := bEnable And Not gFileReadOnly;
	mnuMapSave.Enabled := bEnable And Not gFileReadOnly;
	mnuMapCompile.Enabled := bEnable And Not gFileReadOnly;
	mnuTexturesSave.Enabled := bEnable And Not gFileReadOnly;
	mnuPatchNamesSave.Enabled := bEnable And Not gFileReadOnly;
	mnuWaveSave.Enabled := bEnable And Not gFileReadOnly;
	mnuTextScreenSave.Enabled := bEnable And Not gFileReadOnly;
	//
	//mnuPL_EditPosition.Enabled := bEnable;
	//mnuPL_EditSize.Enabled := bEnable;
	//mnuPL_Rename.Enabled := bEnable;
	mnuPL_Delete.Enabled := bEnable;
	mnuPL_FindSectors.Enabled := bEnable;
	mnuPL_AddtoPNames.Enabled := bEnable;
	mnuPL_AddtoTexture.Enabled := bEnable;
	mnuPL_Replace.Enabled := bEnable And Not gFileReadOnly;
	mnuPL_ReplaceRaw.Enabled := bEnable And Not gFileReadOnly;
End;

// ---------
// This enables/disables functions that
// are only available when a file is open
//
Procedure TFormMain.MenuFileFunctions ( bEnable : Boolean );
Begin
	mnuFileMerge.Enabled := bEnable And Not gFileReadOnly;
	mnuFileJoin.Enabled := bEnable And Not gFileReadOnly;
	mnuFileClose.Enabled := bEnable;
	mnuFileCleanUp.Enabled := bEnable And Not gFileReadOnly;
	//
	mnuEditCut.Enabled := bEnable And Not gFileReadOnly;
	mnuEditCopy.Enabled := bEnable;
	mnuEditPaste.Enabled := bEnable And ( nClipBoard > 0 ) And Not gFileReadOnly;
	mnuEditEmptyClipboard.Enabled := bEnable And ( nClipBoard > 0 );
	//
	mnuEntryNew.Enabled := bEnable And Not gFileReadOnly;
	mnuEntryRename.Enabled := bEnable;
	mnuEntryDelete.Enabled := bEnable And Not gFileReadOnly;
	mnuEntryViewHex.Enabled := bEnable;
	mnuEntryLoad.Enabled := bEnable And Not gFileReadOnly;
	mnuEntryLoadRaw.Enabled := bEnable And Not gFileReadOnly;
	mnuEntryReplace.Enabled := bEnable And Not gFileReadOnly;
	mnuEntryReplaceRaw.Enabled := bEnable And Not gFileReadOnly;
	mnuEntrySaveAs.Enabled := bEnable;
	mnuEntrySaveAsRaw.Enabled := bEnable;
	mnuEntryMoveUp.Enabled := bEnable And Not gFileReadOnly;
	mnuEntryMoveDown.Enabled := bEnable And Not gFileReadOnly;
	//
	mnuPL_Filter.Enabled := bEnable;
	mnuPL_NoFilter.Enabled := bEnable;
	mnuPL_FilterSub.Enabled := bEnable;
	mnuPL_EditPosition.Enabled := bEnable;
	mnuPL_EditSize.Enabled := bEnable;
	mnuPL_Rename.Enabled := bEnable;
	mnuPL_Delete.Enabled := bEnable;
	mnuPL_FindSectors.Enabled := bEnable;
	mnuPL_AddtoPNames.Enabled := bEnable And Not gFileReadOnly;
	mnuPL_AddtoTexture.Enabled := bEnable And Not gFileReadOnly;
	//
End;

// ---

Function TFormMain.IsMapFlag ( s : String ) : Boolean;
Begin
	If Length ( s ) < 3 Then
		IsMapFlag := False
	Else
		IsMapFlag := ( Copy ( s, 1, 3 ) = 'MAP' ) Or
			( ( s [ 1 ] = 'E' ) And ( s [ 3 ] = 'M' ) );
end;

Function TFormMain.IsMapResource ( s : String ) : Boolean;
Begin
	IsMapResource :=
		( s = 'THINGS' ) Or
		( s = 'LINEDEFS' ) Or
		( s = 'SIDEDEFS' ) Or
		( s = 'NODES' ) Or
		( s = 'SECTORS' ) Or
		( s = 'SEGS' ) Or
		( s = 'VERTEXES' ) Or
		( s = 'SSECTORS' ) Or
		( s = 'REJECT' ) Or
		( s = 'BLOCKMAP' );
end;

procedure TFormMain.chkBrowsePanelClick(Sender: TObject);
Begin
	If bDontClick Then
		bDontClick := False
	Else
		mnuViewEntryListClick ( Self );
end;

procedure TFormMain.mnuViewEntryListClick(Sender: TObject);
Begin
	mnuViewEntryList.Checked := Not mnuViewEntryList.Checked;
	//
	If mnuViewEntryList.Checked Then
	Begin
		BrowserSplitter.Visible := True;
		PanelBrowse.Visible := True;
	End
	Else
	Begin
		PanelBrowse.Visible := False;
		BrowserSplitter.Visible := False;
	End;
	//
	PanelsReset;
	//
	bDontClick := True;
	chkBrowsePanel.Checked := mnuViewEntryList.Checked;
end;

procedure TFormMain.mnuViewOptionsClick(Sender: TObject);
Var
	o : TFormOptions;
Begin
	o := TFormOptions.Create ( Self );
	o.ShowModal;
	//
	If o.ColumnsChanged Then
	Begin
		RefreshColumnHeaders;
		ShowWadEntries;
	End;
	//
	If o.AssociationsChanged Then
		RegisterFileTypes;
	//
	o.Free;
end;

procedure TFormMain.PanelsReset;
Begin
	PanelHex.Tag := 0;
	PanelImage.Tag := 0;
	PanelGrid.Tag := 0;
	PanelTexture.Tag := 0;
	PanelTextScreen.Tag := 0;
	PanelPalette.Tag := 0;
	PanelWave.Tag := 0;
	PanelPatchNames.Tag := 0;
	PanelMap.Tag := 0;
	PanelMus.Tag := 0;
	PanelColorMap.Tag := 0;
End;

procedure TFormMain.FormResize(Sender: TObject);
Begin
	If ( WindowState = wsNormal ) And ( Width < Screen.Width ) Then
	Begin
		// Save window positon
		LastLeft := Left;
		LastWidth := Width;
		LastTop := Top;
		LastHeight := Height;
		//
	End;
	//
	PanelsReset;
end;

procedure TFormMain.BrowserSplitterMoved(Sender: TObject);
Begin
	PanelsReset;
end;

procedure TFormMain.mnuHelpContentsClick(Sender: TObject);
Begin
	Application.HelpCommand ( HELP_FINDER, 0 );
end;

procedure TFormMain.mnuHelpAboutClick(Sender: TObject);
Var
	A : TFormAbout;
Begin
	sCredits := 'Credits/Thanks:' + #13 +
		'ReX (Gurkha Boy), Espi, Nigel Rowand (Enjay), Russell^,' + #13 +
		'Doom_Dude, Fredrik, Angst, CacodemonLeader,' + #13 +
		'Nick Baker, YicklePigeon for comments and ideas';
	{$IFDEF FULLVERSION}
	sCredits := sCredits + #13 + 'TZipMaster VCL by Chris Vleghert and Eric W. Engler';
	{$ENDIF}
	{$IFDEF SUPPORTGIF}
	sCredits := sCredits + #13 + 'GIFImage Copyright (c) 1997-99 Anders Melander';
	{$ENDIF}
	sCredits := sCredits + #13 + 'PNG Delphi by Gustavo Daud';
	//
	A := TFormAbout.Create ( Self );
	A.ShowModal;
	A.Free;
end;

procedure TFormMain.Starting;
Begin
	If crCount = 0 Then
	Begin
		crSave := Screen.Cursor;
	End;
	Screen.Cursor := crHourGlass;
	Status ( 'Working...' );
	Inc ( crCount );
end;

procedure TFormMain.Status ( s : String );
Begin
	StatusBrowse.Panels [ 3 ].Text := s;
	StatusBrowse.Refresh;
end;

procedure TFormMain.StatusMode ( s : String );
Begin
	StatusBrowse.Panels [ 2 ].Text := s;
	StatusBrowse.Refresh;
end;

procedure TFormMain.Finished;
Begin
	Dec ( crCount );
	If crCount = 0 Then
		Screen.Cursor := crSave;
	Status ( 'Ready.' );
end;

procedure TFormMain.Modified ( New_isModified : Boolean );
Begin
	If Not gFileReadOnly Then
	Begin
		//Caption := '';
		//
		isModified := New_isModified;
		If isModified Then
		Begin
			StatusBrowse.Panels [ 1 ].Text := '*';
		End
		Else
		Begin
			StatusBrowse.Panels [ 1 ].Text := '';
		End;
	End
	Else
	Begin
		StatusBrowse.Panels [ 1 ].Text := 'R';
	End;
End;

procedure TFormMain.FileModified ( New_isModified : Boolean );
Begin
	isFileModified := New_isModified;
	//ShowMessage ( 'MOD' );
End;

Function TFormMain.ExecAndWait ( const Filename, Params: string; WindowState: word): Boolean;
var
	SUInfo: TStartupInfo;
	ProcInfo: TProcessInformation;
	CmdLine: string;
begin
	CmdLine := '"' + Filename + '"' + Params;
	FillChar ( SUInfo, SizeOf ( SUInfo ), #0 );
	With SUInfo do
	begin
		cb := SizeOf(SUInfo);
		dwFlags := STARTF_USESHOWWINDOW;
		wShowWindow := WindowState;
	end;
	Result := CreateProcess ( NIL, PChar(CmdLine), NIL, NIL, FALSE,
		CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, NIL,
		PChar(ExtractFilePath(Filename)),
		SUInfo, ProcInfo);
	//
	if Result then
		WaitForSingleObject(ProcInfo.hProcess, INFINITE);
End;

function TFormMain.ExecuteFile(const FileName, Params, DefaultDir: string;
	ShowCmd: Integer): THandle;
Var
	zFileName, zParams, zDir: array[0..79] of Char;
Begin
	Result := ShellExecute(Application.MainForm.Handle, nil,
		StrPCopy(zFileName, FileName), StrPCopy(zParams, Params),
		StrPCopy(zDir, DefaultDir), ShowCmd);
end;

Function TFormMain.La ( s : String; d : Longint ) : String;
Begin
	While Length ( s ) < d Do
	Begin
		s := ' ' + s;
	End;
	La := s;
End;

Function TFormMain.TrimString ( s : String ) : String;
Begin
	If s <> '' Then
	Begin
		If ( s [ 1 ] = '''' ) Or ( s [ 1 ] = '"' ) Then
			s := RemoveFromLeft ( s, 1 );
		If ( s [ Length ( s ) ] = '''' ) Or ( s [ Length ( s ) ] = '"' ) Then
			s := RemoveFromRight ( s, 1 );
		s := Trim ( s );
	End;
	TrimString := s;
End;

Function TFormMain.ConstantFind ( ConstantName : String ) : Integer;
Var
	i : Integer;
	b : Boolean;
Begin
	i := nConstants;
	b := False;
	While Not b And ( i >= 0 ) Do
	Begin
		If Constants [ i ].Name = ConstantName Then
			b := True
		Else
			Dec ( i );
	End;
	//
	If b Then
		ConstantFind := i
	Else
		ConstantFind := -1;
End;

Function TFormMain.ConstantFindIndex ( ConstantName : String; Index : Integer ) : Integer;
Var
	i : Integer;
Begin
	i := ConstantFind ( ConstantName );
	If i >= 0 Then
	Begin
		//
		If Index <= Constants [ i ].ValueCount Then
		Begin
			ConstantFindIndex := ConstantValues [ Constants [ i ].ValueStart + Index ].Value;
		End
		Else
		Begin
			ConstantFindIndex := 0;
		End;
	End
	Else
	Begin
		ConstantFindIndex := 0;
	End;
End;

Function TFormMain.ConstantFindDescription ( ConstantName : String; Value : Integer ) : String;
Var
	i, c : Integer;
	b : Boolean;
Begin
	i := ConstantFind ( ConstantName );
	//
	If i >= 0 Then
	Begin
		c := Constants [ i ].ValueStart;
		b := False;
		While Not b And ( c < Constants [ i ].ValueStart + Constants [ i ].ValueCount ) Do
		Begin
			If ConstantValues [ c ].Value = Value Then
				b := True
			Else
				Inc ( c );
		End;
		//
		If b Then
			ConstantFindDescription := ConstantValues [ c ].Description
		Else
			ConstantFindDescription := IntToStr ( Value );
	End
	Else
	Begin
		ConstantFindDescription := IntToStr ( Value );
	End;
End;

Function TFormMain.ConstantFindByDescription ( ConstantName, Description : String ) : Integer;
Var
	i, c : Integer;
	b : Boolean;
Begin
	i := ConstantFind ( ConstantName );
	//
	If i >= 0 Then
	Begin
		//
		Description := UpperCase ( Trim ( Description ) );
		//
		c := Constants [ i ].ValueStart;
		b := False;
		While Not b And ( c < Constants [ i ].ValueStart + Constants [ i ].ValueCount ) Do
		Begin
			If UpperCase ( Trim ( ConstantValues [ c ].Description ) ) = Description Then
				b := True
			Else
				Inc ( c );
		End;
		//
		If b Then
			ConstantFindByDescription := ConstantValues [ c ].Value
		Else
			ConstantFindByDescription := -1;
	End
	Else
	Begin
		ConstantFindByDescription := -1;
	End;
End;

Procedure TFormMain.ConstantDelete ( ConstantName : String );
Var
	i : Integer;
Begin
	//
	i := 1;
	While ( i <= nConstants ) Do
	Begin
		If Constants [ i ].Name = ConstantName Then
		Begin
			Constants [ i ].Name := ''; // clear name
			//
			// remove values if last
			//
			If Constants [ i ].ValueStart + Constants [ i ].ValueCount - 1 = nConstantValues Then
			Begin
				nConstantValues := nConstantValues - Constants [ i ].ValueCount;
			End;
			//
			Constants [ i ].ValueStart := 0;
			Constants [ i ].ValueCount := 0;
			//
			If i = nConstants Then
				Dec ( nConstants ); // remove from "Constants" array if last
			//
			i := nConstants; // exit from loop
		End
		Else
		Begin
			Inc ( i );
		End;
	End;
	//
End;

Function TFormMain.ConstantAdd ( ConstantName, Fields : String ) : Integer;
Begin
	Inc ( nConstants );
	//
	Constants [ nConstants ].Name := ConstantName;
	Constants [ nConstants ].Fields := Fields;
	//
	Constants [ nConstants ].ValueStart := 0;
	Constants [ nConstants ].ValueCount := 0;
	//
	ConstantAdd := nConstants;
End;

Function TFormMain.ConstantAddValue ( ConstantIndex : Integer; Description : String; Value : Integer ) : Integer;
Var
	i : Integer;
Begin
	If Constants [ ConstantIndex ].ValueStart = 0 Then
	Begin
		// first value, go to end
		Constants [ ConstantIndex ].ValueStart := nConstantValues + 1;
	End
	Else
	Begin
		// shift start values for all constants after ConstantIndex
		For i := 1 To nConstants Do
		Begin
			If Constants [ i ].ValueStart > Constants [ ConstantIndex ].ValueStart Then
			Begin
				Inc ( Constants [ i ].ValueStart );
			End;
		End;
		// shift down actual values
		For i := nConstantValues DownTo Constants [ ConstantIndex ].ValueStart +
			Constants [ ConstantIndex ].ValueCount Do
		Begin
			ConstantValues [ i + 1 ] := ConstantValues [ i ];
		End;
	End;
	// one more value
	Inc ( Constants [ ConstantIndex ].ValueCount );
	Inc ( nConstantValues );
	//
	// save new value
	i := Constants [ ConstantIndex ].ValueStart + Constants [ ConstantIndex ].ValueCount - 1;
	ConstantValues [ i ].Description := Description;
	ConstantValues [ i ].Value := Value;
	//
	ConstantAddValue := i;
End;

Procedure TFormMain.ToolsGet ( sTool, sDefault : String; Var sPath, sExec, sParam : String );
Var
	ToolsIndex : Integer;
	b, bUpdate : Boolean;
	s : String;
	c : Integer;
	//
	ff : TFormFndFile;
Begin
	ToolsIndex := ConstantFind ( 'TOOLS' );
	//
	b := False;
	bUpdate := False;
	c := 0;
	//
	sPath := '';
	sExec := '';
	sParam := '';
	//
	If ToolsIndex > 0 Then
	Begin
		c := Constants [ ToolsIndex ].ValueStart;
		While Not b And Not bUpdate And ( c < Constants [ ToolsIndex ].ValueStart + Constants [ ToolsIndex ].ValueCount ) Do
		Begin
			If BeginsWith ( UpperCase ( ConstantValues [ c ].Description ), UpperCase ( sTool ) ) Then
			Begin
				s := ConstantValues [ c ].Description;
				Split2 ( s, sTool, s, ',' );
				Split2 ( s, sPath, s, ',' );
				Split2 ( s, sExec, s, ',' );
				sParam := s;
				//
				If FileExists ( sPath + sExec ) Then
				Begin
					b := True;
				End
				Else
				Begin
					bUpdate := True;
				End;
			End
			Else
				Inc ( c );
		End;
	End;
	//
	If Not B Then
	Begin
		//
		If sExec = '' Then
		Begin
			sExec := sDefault;
		End;
		//
		ff := TFormFndFile.Create ( Self );
		//
		ff.EditDescription.Text := sTool;
		ff.EditPath.Text := sPath;
		ff.EditFileName.Text := sExec;
		//
		ff.ShowModal;
		//
		sPath := ff.Path;
		sExec := ff.Exec;
		//
		ff.Free;
		//
		If ToolsIndex < 0 Then
		Begin
			ToolsIndex := ConstantAdd ( 'TOOLS', '' );
		End;
		//
		If Not bUpdate Then
		Begin
			c := ConstantAddValue ( ToolsIndex, sTool + ',' + sPath + ',' + sExec, 0 );
		End;
		//
		ConstantValues [ c ].Description := sTool + ',' + sPath + ',' + sExec;
	End;
End;

Function TFormMain.FindIcon ( IconName : String ) : Integer;
Var
	i : Integer;
	b : Boolean;
Begin
	IconName := UpperCase ( IconName );
	//
	i := 1;
	b := False;
	While Not b And ( i <= nIcons ) Do
	Begin
		If IconName = Icons [ i ] Then
		Begin
			b := True;
		End
		Else
		Begin
			Inc ( i );
		End;
	End;
	If Not b then i := 0;
	FindIcon := i;

End;

(*
Procedure TFormMain.RaptorDecode ( sFileName : String );
Const
	Scramble : Array [ 0 .. 5 ] Of Byte = ( 67, 65, 83, 84, 76, 69 ); { CASTLE }

Var
	i : Word;
	b, eb : Byte;
Begin
	//fOpen ( sFileName );
	fSeek ( f, 0 );
	AssignFile ( fo, sFileName + '~' );
	ReWrite ( fo, 1 );
	eb := 65;
	While Not Eof ( f ) Do Begin
		b := Byte ( GetByte ( f ) );
		SendByte ( fo, b - eb - Scramble [ ( i + 1 ) Mod 6 ] );
		eb := b;
	End;
	CloseFile ( fo );
	CloseFile ( f );
End;
*)

// ********************************************************************

function TFormMain.ReadWadHeader ( Var f : File; Var i1, i2 : Integer ) : Boolean;
Var
	HeaderID : Cardinal;

Function FileNameBegins ( s : String ) : Boolean;
Begin
	FileNameBegins := UpperCase ( Copy ( RemoveFromLeft ( sFileName,
		PosR ( '\', sFileName ) ), 1, Length ( s ) ) ) = s;
End;

Function FileNameEnds ( s : String ) : Boolean;
Begin
	FileNameEnds := UpperCase ( KeepFromRight ( sFileName, Length ( s ) ) ) = s;
End;

Begin
	{$IFDEF FULLVERSION}
	FileType := ftWadFile;
	{$ENDIF}

  If FileSize ( f ) = 0 Then
  Begin
    // special case, empty file
    FileType := ftWadFile;
    i1 := 0; // entries
    i2 := 0; // directory position
    //
    Seek ( f, 0 );
    SendLong ( f, $44415750 ); // PWAD
    SendLong ( f, 0 );
    SendLong ( f, 0 );
    //
    ReadWadHeader := True;
  End
  Else
  Begin

    If ( FileSize ( f ) < 12 ) Then
    Begin
      MessageDlg ( 'Too small to be a valid WAD file.', mtWarning, [mbOK], 0 );
      ReadWadHeader := False;
    End
    Else
    Begin

      {$IFDEF FULLVERSION}
      //*******************

			If FileNameEnds ( '.LMP' )
			Or FileNameEnds ( '.ART' ) Or FileNameEnds ( '.PPM' )
			Or FileNameEnds ( '.CPS' ) Or FileNameEnds ( '.PAL' )
			Or FileNameEnds ( '.WAV' ) Or FileNameEnds ( '.VOC' )
			Or FileNameEnds ( '.BMP' ) Or FileNameEnds ( '.PCX' )
			Or FileNameEnds ( '.JPG' ) Or FileNameEnds ( '.TGA' )
			Or FileNameEnds ( '.ACT' ) Or FileNameEnds ( '.BYT' )
			Or FileNameEnds ( '.DTX' ) Or FileNameEnds ( '.NWX' )
			Or FileNameEnds ( '.PNG' ) Or FileNameEnds ( '.VGR' ) Then
			Begin
				//
				ImgType := ImgOther;
				If ( FileNameEnds ( '.LMP' ) )
				Or ( FileNameEnds ( '.PNG' ) ) Then
					FileType := SingleLumpFile
				Else
					FileType := SingleFile;
				//
				i1 := 1; // Force one entry
				i2 := 0; // No directory
				//
				ReadWadHeader := True;
				//
			End
			Else
			Begin
				//
				If ( FileNameBegins ( 'VSWAP' ) ) Or ( FileNameBegins ( 'GFXTILES' ) ) Then
				Begin
					//
					FileType := WolfFile;
					//
					i2 := GetWord ( f ); // image count
					GetWord ( f ); // object start
					i1 := GetWord ( f ); // other start
					//
          i2 := 6 + i2 * 4; // Size directory
          //
          ReadWadHeader := True;
          //
        End
        Else
        Begin
          //
          If ( FileNameBegins ( 'AUDIOT' ) ) Then
          Begin
						//
            FileType := WolfAudioFile;
            //
            i1 := LoadWolfAudioHeader;
            i2 := 0; // dir pos
            //
            ReadWadHeader := True;
            //
          End
          Else
          Begin

            //*******************
            {$ENDIF}

						HeaderID := Cardinal ( GetLong ( f ) );
						//
						Case HeaderID Of

							$44415749,
							$44415750 : { IWAD, PWAD }
							Begin
								{$IFDEF FULLVERSION}
								FileType := ftWadFile;
                {$ENDIF}
                //
                i1 := GetLong ( f ); // entries
                i2 := GetLong ( f ); // directory position
                //
                If i1 > 0 Then
                Begin
                  If i2 >= FileSize ( F ) Then
                  Begin
                    MessageDlg ( 'Not a valid WAD file.', mtWarning, [mbOK], 0 );
                    ReadWadHeader := False;
                  End
									Else
                  Begin
                    ReadWadHeader := True;
                  End;
                End
                Else
                Begin
                  ReadWadHeader := True;
                End;
              End;

              {$IFDEF FULLVERSION}

              $32444157 : { WAD2 }
              Begin
								FileType := Wad2File;
                //
                i1 := GetLong ( f ); // entries
                i2 := GetLong ( f ); // directory position
                //
                ReadWadHeader := True;
              End;

              $33444157 : { WAD3 }
              Begin
                FileType := Wad3File;
                //
                i1 := GetLong ( f ); // entries
                i2 := GetLong ( f ); // directory position
                //
                ReadWadHeader := True;
              End;

              $536E654B : { Kens }
              Begin
                FileType := DukeFile;
								//
                Seek ( f, 12 );
                i1 := GetLong ( f ); // entries
                i2 := 16; // fixed directory position
                ReadWadHeader := True;
                //
                LastEntryPos := ( i1 + 1 ) * 16;
              End;

              $4B434150 : { PACK }
              Begin
                FileType := QuakeFile;
                //
                i2 := GetLong ( f ); // directory position
                i1 := GetLong ( f ) Div 64; // entries
								//
                ReadWadHeader := True;
              End;

              $9E2A83C1 : { Unreal Signature }
              Begin
                FileType := UnrealFile;
                //
                Seek ( f, $14 );
                i1 := GetLong ( f ); // Export Table: Number of Entries
                i2 := GetLong ( f ); // Export Table: Directory Position
                ReadWadHeader := True;
              End;

              $1A464652 : { "RFF" $1A }
              Begin
                FileType := RFFFile;
                //
                Seek ( f, 8 );
                i2 := GetLong ( f ); // directory position
                i1 := GetLong ( f ); // Entries
								//
                LastEntryPos := 0; // flag no compression
                //
                ReadWadHeader := True;
              End;

              $04034B50 : { PK }
              Begin
                FileType := PKFile;
                //
                fClose;
                //
                ZipLoadDlls;
                zipM.ZipFilename := UpperCase ( sFileName );
                //
								i1 := zipM.ZipContents.Count; // Entries
                i2 := 0; // directory position : does not exist
                //
                ReadWadHeader := True;
              End;

              $4F534541 : { AESO - P (eob3) }
              Begin
                FileType := EOB3File;
                //
                i1 := $7FFFFFFF; // number of entries is not known
                i2 := $A0; // fixed dir position ~ roughly...
                //
                ReadWadHeader := True;
              End;

              $00000067 : { Adrenix .CAN files }
              Begin
                FileType := AdrenixFile;
                //
                Seek ( f, FileSize ( f ) - 4 );
								i1 := GetLong ( f );
                i2 := FileSize ( f ) - 4 - i1 * ( 20 + 4 );
                //
                ReadWadHeader := True;
              End;

              $0A424F47 : { GOB #$0A : Dark Forces GOB File }
              Begin
                FileType := DarkForcesFile;
                //
                i2 := GetLong ( f ); // Dir position
                Seek ( f, i2 );
                i1 := GetLong ( f ); // Number of entries
                //
                ReadWadHeader := True;
							End;

              $46444F50 : { "PODF"ILE : Necrodome }
              Begin
                FileType := PODFile;
                //
                Seek ( f, 12 );
                i1 := GetLong ( f ); // Number of entries
                i2 := GetLong ( f ); // Directory position
                //
                ReadWadHeader := True;
              End;

              $5220474C : { "LG R"es }
              Begin
                FileType := LGRESFile;
                //
                Seek ( f, $7C );
                i2 := GetLong ( f ); // Directory position
                Seek ( f, i2 );
                i1 := GetWord ( f ); // Number of entries
								LastEntryPos := GetLong ( f ); // Start of first entry, $80
                //
                Inc ( i2, 6 ); // skip 6 bytes of directory header
                //
                ReadWadHeader := True;
              End;

              $47495050 : { "PPIG" : Descent 2 }
              Begin
                FileType := PIG2File;
                //
                Seek ( f, 8 );
                iDP_TextureEntries := GetLong ( f ); // number of textures
                iDP_SoundEntries := 0; // no sounds
                //
								i1 := iDP_TextureEntries;
                i2 := 12; // Directory pos
                //
                // --- calc data pos
                //
                iDP_DataStart := i2 + iDP_TextureEntries * 18;
                //
                ReadWadHeader := True;
              End;

              $53414244 : { "DBAS"Ennn }
              Begin
                //
                HeaderID := Cardinal ( GetLong ( f ) );
                //
                Case HeaderID Of

                  $30303145, $30303245, $30303345: // E200 : ROTH graphic file
                  Begin
                    //
                    FileType := ROTH2File;
										//
                    i2 := 8; // Directory
                    i1 := $7FFFFFFF; // number of entries is not known
                    //
                    LastEntryPos := i2;
                    //
                    ReadWadHeader := True;
                  End;

                  $30303545 : // E500 : ROTH sound file
                  Begin
                    //
                    FileType := ROTH5File;
                    //
                    i2 := 8; // Directory
										i1 := $7FFFFFFF; // number of entries is not known
                    //
                    LastEntryPos := i2;
                    //
                    ReadWadHeader := True;
                  End;

                  Else
                  Begin
                    MessageDlg ( 'This file is not supported by XWE.',
                      mtError, [mbOK], 0 );
                    ReadWadHeader := False;
                  End;
                End;
              End;

              $50534144 : // DASP : ROTH data file
							Begin
                //
                FileType := DASFile;
                //
								Seek ( f, $8 );
                iDAS_Pos := GetWord ( f ); // position & length table pointer ($44)
                //
                Seek ( f, $14 );
                i2 := GetLong ( f ); // Directory
                //
                Seek ( f, i2 ); // read directory header
                iDAS_N1 := GetWord ( f ); // type 1 entries?
                iDAS_N2 := GetWord ( f ); // type 2 entries?
                i1 := iDAS_N1 + iDAS_N2; // number of entries
                //
                LastEntryPos := i2 + 4; // directory start
                //
                ReadWadHeader := True;
              End;

              $4D524F46 : // FORM : Alien Trilogy File
              Begin
                //
                FileType := FORMFile;
                //
								i1 := $7FFFFFFF; // number of entries is not known
								i2 := $0C; // first entry
								//
                ReadWadHeader := True;
              End;

							$65520A0D : // #d#a "Re"zMgr etc. : Lith Rez file (Shogo)
							Begin
                //
								FileType := REZFile;
                //
                Seek ( f, $83 );
                i2 := GetLong ( f ); // directory position
                i1 := $7FFFFFFF; // number of entries is not known
                //
								iREZ_Folders := 0;
                LastEntryPos := i2;
                //
                ReadWadHeader := True;
              End;

              $42444952 : // RIDB : eradicator
              Begin
                //
                FileType := RIDFile;
                //
                i2 := $18; // directory position
                Seek ( f, $10 );
                i1 := GetLong ( f ); // number of entries
                iRID_Pos := GetLong ( f ); // texture names position
								//
                LastEntryPos := i2;
                //
                ReadWadHeader := True;
							End;

							$09D19B64 : // GLB - Raptor (DemonStar???)
							Begin
								//RaptorDecode ( sFileName );
								FileType := GLBFile;
								//
								i2 := $0C; // dir pos
								Seek ( f, 8 );
								i1 := GetLong ( f ); // # of entries
								//
								ReadWadHeader := True;
							End;

							$32424C47 : // GLB - DemonStar
							Begin
                FileType := GLBFile;
                //
                i2 := $0C; // dir pos
                Seek ( f, 8 );
                i1 := GetLong ( f ); // # of entries
								//
                ReadWadHeader := True;
              End;

              $4E42414C : // LABN - Outlaws
              Begin
                FileType := LABFile;
                //
								i2 := $10; // dir pos
                Seek ( f, 8 );
                i1 := GetLong ( f ); // # of entries
                //
                iLAB_FileNameTable := i1 * 16 + 16;
                //
                ReadWadHeader := True;
              End;

              $64695343 : // CSid - Chasm: the rift
              Begin
                FileType := CSFile;
                //
                i2 := $6; // dir pos
                LastEntryPos := i2;
								Seek ( f, 4 );
                i1 := GetWord ( f ); // # of entries
								//
                ReadWadHeader := True;
              End;

              $0BA99A9E : // CStorm RBX files
              Begin
                FileType := RBXFile;
                i2 := 8;
                Seek ( f, 4 );
                i1 := GetWord ( f ); // # of entries
                //
								ReadWadHeader := True;
							End;

							$30525058 : // XPR0 : XPR files
							Begin
								FileType := XPRFile;
								//
								Seek ( f, 4 );
								i2 := GetLong ( f );
								//
								Seek ( f, i2 );
								iXPR_DirLen := GetLong ( f );
								Inc ( i2, 8 );
								//
								LastEntryPos := i2;
								//
								i1 := $7FFFFFFF; // number of entries is not known
								//
								ReadWadHeader := True;
							End;

							$52475242 : // BRGR : KillTime.REZ data file
							Begin
								FileType := KTREZFile;
								//
								Seek ( f, $14 );
								i1 := GetLong ( f ); // number of entries
								//
								i2 := $18; // fixed dir start
								LastEntryPos := i2;
								//
								ReadWadHeader := True;
							End;

							$697A6F50 : // Pozi : Scrapland packed files
							Begin
								FileType := PoziFile;
								//
								Seek ( f, 8 );
								i1 := GetLong ( f ); // number of entries
								//
								i2 := $0C; // fixed dir start
								LastEntryPos := i2;
								//
								ReadWadHeader := True;
							End;

							$00006E71 : // QN : Outcast PAK files
							Begin
								FileType := QNFile;
								//
								Seek ( f, $10 );
								i1 := GetLong ( f ); // number of entries
								//
								i2 := $14; // fixed dir start
								LastEntryPos := i2;
								//
								ReadWadHeader := True;
							End;

							$21736552 : // RES $21 : Amulets and Armor RES files
							Begin
								FileType := AARESFile;
								//
								Seek ( f, 4 );
								i2 := GetLong ( f ); // dir start
								i1 := GetLong ( f ) Div 39; // number of entries
								//
								iAAR_EntriesAdded := 0;
								//
								ReadWadHeader := True;
							End;

							$00000308 :
							Begin
								If FileSize ( f ) = 768 + 8 Then
								Begin
									// Future Shock COL files
									FileType := SingleFile;
									//
									i1 := 1; // Force one entry
									i2 := 0; // No directory
									//
									ReadWadHeader := True;
								End
								Else
								Begin
									ReadWadHeader := False;
								End;
							End;

							$01011234 :
							Begin
								FileType := JFKWadFile;
								//
								Seek ( f, $8 );
								iJFK_DirPos := GetLong ( f ) + $14;
								i1 := GetLong ( f ); // entries
								//
								i2 := $14; // fixed dir pos
								LastEntryPos := i2;
								//
								ReadWadHeader := True;
							End;

							{$ENDIF}

							Else
							Begin

								{$IFDEF FULLVERSION}
								If ( ( ( HeaderID Shr 16 ) And $FFFF ) = $2020 ) And ( ( HeaderID And $FFFF ) < 32 )  Then
								Begin
									FileType := FShockFile;
									//
									i1 := $7FFFFFFF; // number of entries is not known
									i2 := 0; // Directory pos
									LastEntryPos := 0;
									//
									ReadWadHeader := True;
								End
								Else
								Begin
									If FileNameEnds ( 'PAK' ) Then
									Begin
										// If the PK header was not found
										// and it's a .PAK file, then it's EOB1
										FileType := EOB1File;
										//
										i1 := $7FFFFFFF; // number of entries is not known
										i2 := 0; // Directory pos
										LastEntryPos := 0; // Directory pos #2
										//
										ReadWadHeader := True;
									End
									Else
									Begin

										If FileNameEnds ( 'LFD' ) Then
										Begin
											FileType := DarkForcesLFDFile;
											i1 := $7FFFFFFF; // number of entries is not known
											i2 := 0; // Directory pos
											LastEntryPos := 0; // Directory pos #2
											ReadWadHeader := True;
										End
										Else
										Begin

											If FileNameEnds ( 'TLK' ) Then
											Begin
												FileType := TLKFile; // Lands of Lore Talk file
												//
												i1 := $7FFFFFFF; // number of entries is not known
												i2 := 0; // Directory pos
												LastEntryPos := 0;
												//
												ReadWadHeader := True;
											End
											Else
											Begin

												If FileNameEnds ( 'PIG' ) Then
												Begin
													FileType := PIGFile;
													//
													Seek ( f, 0 );
													iDP_TextureEntries := GetLong ( f ); // number of textures
													iDP_SoundEntries := GetWord ( f ); // number of sounds
													//
													i1 := iDP_TextureEntries + iDP_SoundEntries;
													i2 := 8; // Directory pos
													//
													// --- calc data pos
													//
													iDP_DataStart := i2 + iDP_TextureEntries * 17 + iDP_SoundEntries * 20;
													//
													ReadWadHeader := True;
												End
												Else
												Begin

													If ( HeaderID And $FFFFFF ) = $464844 Then
													Begin
														FileType := HOGFile;
														//
														i1 := $7FFFFFFF; // number of entries is not known
														i2 := 3; // Directory pos
														//
														LastEntryPos := 3; // Directory pos #2
														ReadWadHeader := True;
													End
													Else
													Begin

														If FileNameEnds ( 'TR' ) Then
														Begin
															FileType := TRFile;
															//
															Seek ( f, 1 );
															iTR_Size := Byte ( GetByte ( f ) );
															//
															i1 := Byte ( GetByte ( f ) ); // number of entries
															i2 := 4; // Directory pos
															//
															ReadWadHeader := True;
														End
														Else
														Begin

															If FileNameEnds ( 'GR' ) Then
															Begin
																FileType := GRFile;
																//
																Seek ( f, 1 );
																i1 := Byte ( GetByte ( f ) ); // number of entries
																i2 := 3; // Directory pos
																//
																ReadWadHeader := True;
															End
															Else
															Begin

																If ( FileNameEnds ( 'MTI' ) ) Or ( FileNameEnds ( 'MTO' ) ) Then
																Begin
																	FileType := MTIFile;
																	//
																	If FileNameEnds ( 'MTI' ) Then
																		i2 := $18 // Directory pos
																	Else
																		i2 := $64; // Directory pos
																	//
																	Seek ( f, i2 - 4 );
																	i1 := GetLong ( f ); // number of entries
																	//
																	ReadWadHeader := True;
																End
																Else
																Begin

																	If FileNameEnds ( 'DTI' ) Then
																	Begin
																		FileType := DTIFile;
																		//
																		i1 := 1; // number of entries?
																		i2 := $20; // Directory pos?
																		//
																		ReadWadHeader := True;
																	End
																	Else
																	Begin

																		If FileNameEnds ( 'SNI' ) Then
																		Begin
																			FileType := SNIFile;
																			//
																			Seek ( f, $14 );
																			i1 := GetLong ( f ); // number of entries
																			i2 := $18; // Directory pos
																			//
																			ReadWadHeader := True;
																		End
																		Else
																		Begin

																			If FileNameEnds ( 'BLO' ) Then
																			Begin
																				FileType := BLOFile;
																				//
																				Seek ( f, 0 );
																				i1 := GetWord ( f ); // number of entries
																				i2 := GetLong ( f ); // Directory pos
																				//
																				ReadWadHeader := True;
																			End
																			Else
																			Begin

																				If FileNameEnds ( 'WRS' ) Then
																				Begin
																					// the entries are compressed :-(
																					FileType := WRSFile;
																					//
																					i1 := $7FFFFFFF; // number of entries
																					i2 := 0; // Directory pos
																					LastEntryPos := 0;
																					//
																					ReadWadHeader := True;
																				End
																				Else
																				Begin

																					If FileNameEnds ( 'CMP' ) Then
																					Begin
																						// Duke Nukem II
																						FileType := Duke2File;
																						//
																						i1 := 200; // number of entries
																						i2 := 0; // Directory pos
																						LastEntryPos := 0;
																						//
																						ReadWadHeader := True;
																					End
																					Else
																					Begin

																						{$ENDIF}

																						MessageDlg ( 'Not a valid WAD file.' + #13 +
																							'(Unknown header signature or file format)', mtWarning, [mbOK], 0 );
																						ReadWadHeader := False;

																						{$IFDEF FULLVERSION}
																					End;
																				End;
																			End;
																		End;
																	End;
																End;
															End;
														End;
													End;
												End;
											End;
										End;
									End;
								End;
                {$ENDIF}

              End;

            End;
            {$IFDEF FULLVERSION}
          End;
        End;
      End;
      {$ENDIF}
		End;
	End;
end;

Function TFormMain.FindTypeIndex ( sType : String ) : Integer;
Var
	i : Integer;
	b : Boolean;
Begin
	i := 0;
	b := False;
	While Not b And ( i < nWadEntryTypes ) Do
	Begin
		If UpperCase ( WadEntryTypes [ i ].Description ) = UpperCase ( sType ) Then
		Begin
			b := True;
		End
		Else
		Begin
			Inc ( i );
		End;
	End;
	//
	If b Then
		FindTypeIndex := i
	Else
		FindTypeIndex := 0;
End;

function TFormMain.MatchSignature ( iEntry : Integer; s : String ) : Boolean;
Const
	MaxLen = 100;
Type
	TbType = ( bt_Direct, bt_Any );
	TByteSpecial = Record
		bType : TbType;
		b : Byte;
	End;
Var
	ok : Boolean;
	Len : Integer;
	ValueLen, iLen : Integer; // value length: 1=byte, 2=word, etc.
	Value : Integer;
	d1 : Array [ 1 .. MaxLen ] Of TByteSpecial;
	d2 : Array [ 1 .. MaxLen ] Of Byte;
	p : Integer;
	bType : TbType;
Begin
	ok := False;
	//
	If fOpenCount > 0 Then
	Begin
		//
		If ( s <> '' ) And ( WadEntries [ iEntry ].Size > 0 )
		And ( WadEntries [ iEntry ].Position <= FileSize ( f ) )
		And ( WadEntries [ iEntry ].Position >= 0 ) Then
		Begin
			Len := 0;
			//
			//Caption := IntToStr ( SafeVal ( Caption ) + 1 );
			//
			SetVariable ( 'LUMPLENGTH', WadEntries [ iEntry ].Size );
			//
			While ( s <> '' ) Do
			Begin
				p := Pos ( ' ', s );
				If p = 0 Then
					p := Length ( s ) + 1;
				//
				// --- check prefix
				//
				ValueLen := 1;
				bType := bt_Direct;
				//
				If UpperCase ( Copy ( s, 1, 2 ) ) = 'W:' Then
				Begin
					ValueLen := 2;
					s := Copy ( s, 3, Length ( s ) - 2 );
					Dec ( p, 2 );
				End;
				//
				//
				If UpperCase ( Copy ( s, 1, 2 ) ) = 'L:' Then
				Begin
					ValueLen := 4;
					s := Copy ( s, 3, Length ( s ) - 2 );
					Dec ( p, 2 );
				End;
				//
				If Copy ( s, 1, 1 ) = '?' Then
				Begin
					bType := bt_Any;
					Value := 0;
				End
				Else
				Begin
					If Copy ( s, 1, 1 ) <> '$' Then
					Begin
						Value := Eval ( Copy ( s, 1, p - 1 ) );
						//ShowMessage ( Copy ( s, 1, p - 1 ) + ' --> ' + IntToStr ( Value ) );
						End
					Else
					Begin
						Value := SafeVal ( Copy ( s, 1, p - 1 ) );
					End;
				End;
				//
				For iLen := 1 To ValueLen Do
				Begin
					Inc ( Len );
					d1 [ Len ].bType := bType;
					d1 [ Len ].b := Value And 255;
					Value := Value Shr 8;
				End;
				//
				If Len = MaxLen Then
					s := ''
				Else
					s := Trim ( RemoveFromLeft ( s, p ) );
			End;
			//
			If Len > WadEntries [ iEntry ].Size Then
				Len := WadEntries [ iEntry ].Size;
			//
			Seek ( f, WadEntries [ iEntry ].Position );
			BlockRead ( f, d2 [ 1 ], Len );
			//
			ok := True;
			While ok And ( Len > 0 ) Do
			Begin
				Case d1 [ Len ].bType Of

					bt_Direct :
					Begin
						If d1 [ Len ].b <> d2 [ Len ] Then
						Begin
							ok := False;
						End;
					End;

					bt_Any :
					Begin
						// always match
					End;

				End;
				//
				Dec ( Len );
			End;
		End;
		//
		MatchSignature := ok;
	End
	Else
	Begin
		MatchSignature := False;
	End;
End;

procedure TFormMain.WadEntryIdentify ( iEntry : Integer );
Var
	i : Integer;
	bMatch, bDirectMatch : Boolean;
Begin
	//
	// --- Identify Type
	//
	i := 1;
	bDirectMatch := False;
	While Not bDirectMatch And ( i <= nWadEntryTypes ) Do
	Begin
		// --- Check by name
		If MatchName ( UpperCase ( Trim ( WadEntries [ iEntry ].Name ) ), UpperCase ( Trim ( WadEntryTypes [ i ].Entry ) ) ) Then
		Begin
			// Found!
			WadEntries [ iEntry ].EntryType := i;
			bDirectMatch := True;
		End
		Else
		Begin
			// --- Check by size
			If ( WadEntryTypes [ i ].Size >= 0 )
			And ( WadEntries [ iEntry ].Size = WadEntryTypes [ i ].Size ) Then
			Begin
				// Found!
				WadEntries [ iEntry ].EntryType := i;
				bDirectMatch := True;
			End
			Else
			Begin
				// --- Check by data header (signature)
				If ( WadEntryTypes [ i ].Signature <> '' ) Then
				Begin
					If MatchSignature ( iEntry, WadEntryTypes [ i ].Signature ) Then
					Begin
						// Found!
						WadEntries [ iEntry ].EntryType := i;
						bDirectMatch := True;
					End;
				End;
			End;
		End;
		Inc ( i );
	End;
	//
	// --- Section Types
	//
	i := 1;
	bMatch := False;
	While Not bMatch And ( i <= nWadEntryTypes ) Do
	Begin
		If MatchName ( Trim ( WadEntries [ iEntry ].Name ), WadEntryTypes [ i ].SectionStart ) Then
		Begin
			iWadEntryType := i; // following items are this type.
			bMatch := True;
			i := 0;
		End
		Else
		Begin
			If MatchName ( Trim ( WadEntries [ iEntry ].Name ), WadEntryTypes [ i ].SectionEnd ) Then
			Begin
				iWadEntryType := 0; // clear section type
				bMatch := True;
				i := 0;
			End;
		End;
		Inc ( i );
	End;
	//
	If Not bDirectMatch And ( iWadEntryType <> 0 ) Then
	Begin
		// section match
		WadEntries [ iEntry ].EntryType := iWadEntryType;
	End;
	//
	If WadEntries [ iEntry ].EntryType = 1 Then
		WadEntries [ iEntry ].EntryType := 0; // clear LUMPs
End;

//
// Go back and possibly find any SECTION START type
//
procedure TFormMain.WadEntryIdentify2 ( iEntry : Integer );
Var
	j : Integer;
	i : Integer;
	bFound : Boolean;
Begin
	iWadEntryType := 0; // clear section type
	bFound := False;
	//
	i := iEntry - 1;
	While ( i > 0 ) And Not bFound Do
	Begin
		//
		// --- Look for Section Types
		//
		j := nWadEntryTypes;
		While ( j > 0 ) And Not bFound Do
		Begin
			If MatchName ( Trim ( WadEntries [ i ].Name ), WadEntryTypes [ j ].SectionStart ) Then
			Begin
				iWadEntryType := j; // following items are this type!
				bFound := True;
			End
			Else
			Begin
				If MatchName ( Trim ( WadEntries [ i ].Name ), WadEntryTypes [ j ].SectionEnd ) Then
				Begin
					// we encountered an END, so we're not inside a section.
					bFound := True;
				End;
			End;
			Dec ( j );
		End;
		Dec ( i );
	End;
End;

{$IFDEF FULLVERSION}
Function TFormMain.LoadWolfAudioHeader : Integer;
Var
	fh : File;
	iEntries : Integer;
	iPos : Integer;
	s : String;
Begin
	//
	iEntries := 0;
	//
	s := Copy ( sFileName, 1, PosR ( '\', sFileName ) ) + 'AUDIOHED' +
		Copy ( sFileName, PosR ( '.', sFileName ), 4 );
	//
	If Not FileExists ( s ) Then
	Begin
		ShowMessage ( 'Could not load header file.' + #13 + '(' + s + ')' );
	End
	Else
	Begin
		AssignFile ( fh, s );
		FileMode := fmOpenReadWrite;
		Reset ( fh, 1 );
		//
		While Not Eof ( fh ) Do
		Begin
			Inc ( iEntries );
			//
			If ( iEntries And 31 ) = 0 Then
			Begin
				Status ( 'Loaded ' + Comma ( iEntries ) + ' entry headers' );
			End;
			//
			iPos := GetLong ( fh );
			//
			WadEntries [ iEntries ].Position := iPos;
			//
			If iEntries > 1 Then
			Begin
				WadEntries [ iEntries - 1 ].Size := iPos - WadEntries [ iEntries - 1 ].Position;
			End;
		End;
		//
		Dec ( iEntries );
		//
		CloseFile ( fh );
	End;
	//
	LoadWolfAudioHeader := iEntries;
End;

Procedure TFormMain.LoadEOB3Names;
Var
	iEntries, iEntry : Word;
	w : Word;
	i : Integer;
	s, n : String;
	iPos, n1 : Longint;
Begin
	//
	// Names are in the first entry
	//
	Seek ( f, WadEntries [ 1 ].Position );
	iEntries := GetWord ( f ); // get number of entries
	//
	For iEntry := 0 To iEntries - 1 Do
	Begin
		//
		If ( iEntry And 127 ) = 0 Then
		Begin
			Status ( 'Loaded ' + Comma ( iEntry ) + ' entry names' );
		End;
		//
		Seek ( f, WadEntries [ 1 ].Position + 2 + iEntry * 4 );
		iPos := GetLong ( f );
		//
		If iPos <> 0 Then
		Begin
			Seek ( f, WadEntries [ 1 ].Position + iPos );
			w := 1;
			While w <> 0 Do
			Begin
				w := GetWord ( f );
				If w <> 0 Then
				Begin
					s := '';
					For i := 1 To w - 1 Do
					Begin
						s := s + Chr ( GetByte ( f ) );
					End;
					GetByte ( f ); // zero
					//
					w := GetWord ( f );
					n := '';
					For i := 1 To w - 1 Do
					Begin
						n := n + Chr ( GetByte ( f ) );
					End;
					GetByte ( f ); // zero
					//
					n1 := SafeVal ( n );
					If n1 < nWadEntries Then
					Begin
						// set the name
						WadEntries [ n1 + 1 ].Name := s;
					End;
				End;
			End;
		End;
	End;
End;

Procedure TFormMain.UnrealLoadNameTable;
Var
	s : String;
	n, i, j : Integer;
	iPos : Integer;
Begin
	Seek ( f, 12 );
	n := GetLong ( f );
	iPos := GetLong ( f );
	//
	If n > 511 Then
	Begin
		ShowMessage ( 'Name table has ' + Comma ( n ) + ' entries,' + #13 +
			'truncated to 512.' );
		n := 512;
	End;
	//
	Seek ( f, iPos );
	i := 0;
	While i < n Do
	Begin
		//
		// Get name az Zero Terminated string
		s := GetZString ( f );
		{
		s0 [ 0 ] := Chr ( Byte ( GetByte ( f ) ) );
		BlockRead ( f, s0 [ 1 ], Ord ( s0 [ 0 ] ) );
		}
		//
		GetLong ( f );
		//
		// remove last zero if present
		If Length ( s ) > 0 Then
		Begin
			If s [ Length ( s ) ] = #0 Then
			Begin
				s := RemoveFromRight ( s, 1 );
			End;
			//
			// newer versions have 'Length' as first byte
			If Ord ( s [ 1 ] ) = Length ( s ) Then
			Begin
				s := RemoveFromLeft ( s, 1 );
			End;
		End;
		//
		sUnrealNameTable [ i ] := s;
		//
		Inc ( i );
	End;
	//
	// #########################################################################
	//
	Seek ( f, 28 );
	//
	n := GetLong ( f );
	iPos := GetLong ( f );
	//
	If n > 511 Then
	Begin
		ShowMessage ( 'Export table has ' + Comma ( n ) + ' entries,' + #13 +
			'truncated to 512.' );
		n := 512;
	End;
	//
	Seek ( f, iPos );
	i := 0;
	While i < n Do
	Begin
		//
		GetLongUnreal ( f ); // class package
		GetLongUnreal ( f ); // class name
		GetLong ( f ); // package
		j := GetLongUnreal ( f ); // object name
		//
		iUnrealExportTable [ i ] := j;
		//
		Inc ( i );
	End;
End;
{$ENDIF}

Procedure TFormMain.ShowWadEntries;
Var
	i, iIndex, iNewListIndex : Integer;
	s, sPrev : String;
Begin
	If sFileName <> '' Then
	Begin
		//
		Starting;
		//
		iIndex := -1;
		iNewListIndex := -1;
		If ListWad.ItemFocused <> NIL Then
		Begin
			// remember old entry index
			iIndex := EntryGetIndex ( ListWad.ItemFocused.Index );
		End;
		//
		ListWad.Visible := False;
		ListWad.Items.Clear;
		//
		// --
		//
		sPrev := '';
		//
		For i := 1 To nWadEntries Do
		Begin
			//
			If ( sListWadFilter = '' )
			Or ( WadEntryTypes [ WadEntries [ i ].EntryType ].Description = sListWadFilter )
			Or ( ( WadEntries [ i ].EntryType = 0 ) And ( sListWadFilter = ' ' ) ) Then
			Begin
				// ALL
				AddWadEntry ( i );
				//
				If i = iIndex Then
				Begin
					iNewListIndex := ListWad.Items.Count - 1;
				End;
			End
			Else
			Begin
				If i = iIndex Then
				Begin
					iIndex := -1; // entry not visible in newly filtered list
				End;
			End;
			//
			If ( i And 255 ) = 0 Then
				Status ( 'Processed ' + IntToStr ( i ) + ' entries' );
			//
			sPrev := s;
		End;
		//
		ListWad.Visible := True;
		//
		If ( iNewListIndex = -1 ) And ( ListWad.Items.Count > 0 ) Then
		Begin
			iNewListIndex := 0;
		End;
		//
		If iNewListIndex <> -1 Then
		Begin
			// Focus back to old entry
			ListWad.Items [ iNewListIndex ].Focused := True;
			ListWad.Items [ iNewListIndex ].Selected := True;
		End
		Else
		Begin
			ShowPage ( edNone )
		End;
		//
		UpdateSelection;
		//
		Finished;
	End;
end;

Procedure TFormMain.SendWadEntry ( Var f : File; iPos, iSize : Integer; sName : String );
Begin
	SendLong ( f, iPos );
	SendLong ( f, iSize );
	SendString8 ( f, sName );
end;

Procedure TFormMain.SendWadEntryFromArray ( Var f : File; iEntry : Integer );
Begin
	With WadEntries [ iEntry ] Do
	Begin
		SendWadEntry ( f, Position, Size, Name );
	End;
end;

Procedure TFormMain.WriteWadEntry ( iEntry : Integer );
Begin
	If fOpen ( sFileName ) Then
	Begin
		Seek ( f, iWadDirPos + ( iEntry - 1 ) * 16 );
		SendWadEntryFromArray ( f, iEntry );
		fClose;
	End;
End;

Procedure TFormMain.SaveWadEntryName ( iEntry : Integer );
Begin
	If fOpen ( sFileName ) Then
	Begin
		Seek ( f, iWadDirPos + ( iEntry - 1 ) * 16 + 8 );
		SendString8 ( f, WadEntries [ iEntry ].Name );
		fClose;
	End;
End;

Function TFormMain.EntryFindListIndex ( iEntry : Integer ) : Integer;
Var
	i : Integer;
	bFound : Boolean;
Begin
	i := 0;
	bFound := False;
	While Not bFound And ( i < ListWad.Items.Count ) Do
	Begin
		If StrToInt ( ListWad.Items [ i ].SubItems [ 0 ] ) = iEntry Then
		Begin
			bFound := True;
		End
		Else
		Begin
			Inc ( i );
		End;
	End;
	//
	If bFound Then
		EntryFindListIndex := i
	Else
		EntryFindListIndex := -1;
End;

Function TFormMain.EntryGetIndex ( iListEntry : Integer ) : Integer;
Var
	s : String;
Begin
	s := ListWad.Items [ iListEntry ].SubItems [ 0 ];
	EntryGetIndex := StrToInt ( s );
End;

Procedure TFormMain.AddWadEntry ( iEntry : Integer );
Begin
	ListWad.Items.Add;
	UpdateWadEntry ( ListWad.Items.Count - 1, iEntry );
end;

procedure TFormMain.mnuEntryViewHexClick(Sender: TObject);
Begin
	mnuEntryViewHex.Checked := Not mnuEntryViewHex.Checked;
	ShowEntry ( '', False );
end;

Function TFormMain.SaveEntry : Boolean;
Begin
	Case CurrentEditor Of

		edImage :
		Begin
			SaveEntry := ImageSave;
		End;

		edHex :
		Begin
			SaveEntry := HexSave;
		End;

		edGrid :
		Begin
			SaveEntry := GridSave;
		End;

		edMap :
		Begin
			SaveEntry := MapSave ( iSel );
		End;

		edTexture :
		Begin
			SaveEntry := TextureSave;
		End;

		edPalette :
		Begin
			SaveEntry := PaletteSave;
		End;

		edColorMap :
		Begin
			SaveEntry := ColorMapSave;
		End;

		edWave :
		Begin
			SaveEntry := WaveSave;
		End;

		edScript :
		Begin
			SaveEntry := ScriptSave;
		End;

		edTextScreen :
		Begin
			SaveEntry := TextScreenSave;
		End;

		edPatchNames :
		Begin
			SaveEntry := PatchNamesSave;
		End;

		Else
		Begin
			SaveEntry := False;
		End;

	End;
End;

procedure TFormMain.ShowEntry ( sEditor : String; bFocus : Boolean );

Var
	i : Longint;
	s : String;
	iPos, iLen : Longint;
	iEntryType : Integer;

Begin
	//
	If CheckModified Then
	Begin
		//
		UpdateSelection;
		//
		If ListWad.SelCount > 1 Then
		Begin
			ShowPage ( edNone );
			Status ( 'Multiple selection (' + Comma ( ListWad.SelCount ) + ' entries)' );
			Exit;
		End;
		//
		If ListWad.ItemFocused = NIL Then
		Begin
			// no selection?
			ShowPage ( edNone );
			Status ( 'No focused item.' );
			Exit;
		End;
		//
		i := EntryGetIndex ( ListWad.ItemFocused.Index );
		//
		If ( i < 1 ) Or ( i > nWadEntries ) Then
		Begin
			// ???
			ShowPage ( edNone );
			Status ( 'Internal error: ' + Comma ( i ) + ' entry index is invalid.' );
			Exit;
		End;
		//
		// --- Save for later
		//
		iWadEntryCurrentPos := ListWad.ItemFocused.Index;
		iWadEntryCurrentIndex := i;
		//
		s := WadEntries [ i ].Name;
		iPos := WadEntries [ i ].Position;
		iLen := WadEntries [ i ].Size;
		//
		iSel := i;
		cPos := iPos;
		cLen := iLen;

		{$IFDEF FULLVERSION}
		If ( iLen = 0 ) And ( FileType = PKFile ) Then
		Begin
			//
			ShowPage ( edNone );
			//
		End
		Else
		Begin
			{$ENDIF}
			//
			//
			//
			iWadEntryDetected := 0;
			//
			OpenEntry ( i );
			//
			If ( iLen >= 0 ) And ( iPos >= 0 ) Then
			Begin
				//
				// *** Open appropriate editor
				//
				If sEditor <> '' Then
				Begin
					s := sEditor;
				End
				Else
				Begin
					If mnuEntryViewHex.Checked Then
					Begin
						//
						s := 'HEXEDITOR';
						//
					End
					Else
					Begin
						iEntryType := WadEntries [ i ].EntryType;
						//
						If ( iEntryType < 1 ) Or ( iEntryType > nWadEntryTypes ) Then
							s := ''
						Else
							s := WadEntryTypes [ WadEntries [ i ].EntryType ].Editor;
					End;
				End;
				//
				If s = 'GRIDEDITOR' Then
				Begin
					GridEditor ( WadEntries [ i ].EntryType, bFocus );
				End
				Else If s = 'HEXEDITOR' Then
				Begin
					HexDump;
				End
				Else If s = 'MAPEDITOR' Then
				Begin
					MapEditor ( bFocus );
				End
				Else If s = 'VERTEXEDITOR' Then
				Begin
					VertexEditor;
				End
				Else If s = 'LINEDEFSEDITOR' Then
				Begin
					LineDefsEditor;
				End
				Else If s = 'SCRIPTEDITOR' Then
				Begin
					ScriptEditor ( WadEntryTypes [ WadEntries [ i ].EntryType ].EditorSubCat, bFocus );
				End
				Else If s = 'TEXTSCREENEDITOR' Then
				Begin
					TextScreenEditor ( bFocus );
				End
				Else If s = 'TEXTUREEDITOR' Then
				Begin
					TextureEditor ( bFocus );
				End
				Else If s = 'PATCHNAMESEDITOR' Then
				Begin
					PatchNamesEditor ( bFocus );
				End
				Else If s = 'SPEAKERSOUNDEDITOR' Then
				Begin
					SpeakerSound;
				End
				Else If s = 'WAVEEDITOR' Then
				Begin
					WaveEditor;
				End
				Else If s = 'MUSEDITOR' Then
				Begin
					MusEditor;
				End
				Else If s = 'DEMOEDITOR' Then
				Begin
					DemoEditor;
				End
				Else If s = 'PALETTEEDITOR' Then
				Begin
					PaletteEditor ( bFocus );
				End
				Else If s = 'COLORMAPEDITOR' Then
				Begin
					ColorMapEditor;
				End
				{$IFDEF FULLVERSION}
				Else If s = 'ARTEDITOR' Then
				Begin
					ArtEditor;
				End
				Else If s = 'BSPEDITOR' Then
				Begin
					BspEditor;
				End
				Else If s = 'WAXEDITOR' Then
				Begin
					WaxEditor;
				End
				{$ENDIF}
				Else ImageEditor;
				//
				If ( iWadEntryDetected <> 0 ) And ( WadEntries [ i ].EntryType = 0 ) Then
				Begin
					WadEntries [ i ].EntryType := iWadEntryDetected;
					UpdateWadEntry ( iWadEntryCurrentPos, iWadEntryCurrentIndex );
				End;
			End
			Else
			Begin
				// invalid entry
				ShowPage ( edNone );
				Status ( 'Invalid entry.' );
			End;

		{$IFDEF FULLVERSION}
		End;
		{$ENDIF}
		//
		iWadEntryLastPos := iWadEntryCurrentPos;
	End;
End;

Procedure TFormMain.UpdateSelection;
Var
	s : String;
Begin
	s := Comma ( ListWad.SelCount ) + ' selected';
	If ( ListWad.Items.Count <> nWadEntries ) Then
	Begin
		s := s + ' (' + Comma ( ListWad.Items.Count ) + ' showing, ' + Comma ( nWadEntries ) + ' total)';
	End
	Else
	Begin
		s := s + ' (' + Comma ( nWadEntries ) + ' total)';
	End;
	//
	StatusBrowse.Panels.Items [ 0 ].Text := s;
End;

Function TFormMain.ImageGetDetails ( iEntry : Integer; Var x, y, xr, yr : Integer ) : Boolean;
Var
	b : Boolean;
Begin
	b := False;
	If fOpen ( sEditFile ) Then
	Begin
		Seek ( F, WadEntries [ iEntry ].Position );

		x := Integer ( GetWord ( f ) );
		y := Integer ( GetWord ( f ) );
		//
		If ( x = $4D49 ) And ( y = $5A47 ) Then
		Begin
			//
			// ZDoom image format
			//
			x := Integer ( GetWord ( f ) );
			y := Integer ( GetWord ( f ) );
			//
			xr := Integer ( GetWord ( f ) );
			yr := Integer ( GetWord ( f ) );
			//
			b := True;
		End
		Else
		Begin
			//
			If y = 0 Then
			Begin
				//
				// Quake style image
				//
				y := GetLong ( f );
				//
				xr := 0;
				yr := 0;
				//
				b := ( ( x * y + 8 ) = WadEntries [ iEntry ].Size )
					Or ( ( x * y + 8 + 4 + 3 * 256 ) = WadEntries [ iEntry ].Size );
			End
			Else
			Begin
				If ( x = 0 ) And ( y = 2 ) Then
				Begin
					// TGA format
					GetLong ( f );
					GetLong ( f );
					x := Integer ( GetWord ( f ) );
					y := Integer ( GetWord ( f ) );
					//
					b := Not ( ( x <= 0 ) Or ( y <= 0 ) );
				End
				Else
				Begin
					If ( ( x And $FFFF ) = $D8FF ) And ( ( y And $FFFF ) = $E0FF ) Then
					Begin
						//
						// JPEG
						//
						x := 64;
						y := 64;
						//
						b := True;
					End
					Else
					Begin
						//
						// Doom style images 8 byte header?
						//
						xr := Integer ( GetWord ( f ) ); // offsets
						yr := Integer ( GetWord ( f ) );
						//
						b := Not ( ( x <= 0 ) Or ( y <= 0 ) ); //And ( x * y <= WadEntries [ iEntry ].Size );
						//
						//
						//
						If Not b Then
						Begin
							GetLong ( f );
							GetLong ( f );
							x := GetLong ( f );
							y := GetLong ( f );
						End;
					End;
				End;
			End;
		End;
		//
		fClose;
	End;
	//
	If b Then
	Begin
		ImageGetDetails := True;
	End
	Else
	Begin
		x := 0;
		y := 0;
		xr := 0;
		yr := 0;
		//
		ImageGetDetails := False;
	End;
End;

Procedure TFormMain.ImageRenderCurrent;
Begin
	If mnuImageEdit.Checked Then
	Begin
		ImageRenderCurrentPos ( Round ( Image_scroll_x * ImageGetZoom ), Round ( Image_scroll_y * ImageGetZoom ) );
		ImageDrawPalette;
		ImageDrawCursor;
		//
		With Image1.Canvas Do
		Begin
			Pen.Color := clDkGray;
			MoveTo ( Round ( ( Image_xs + Image_scroll_x ) * ImageGetZoom ), Round ( Image_scroll_y * ImageGetZoom ) - 1 );
			LineTo ( Round ( ( Image_xs + Image_scroll_x ) * ImageGetZoom ), Round ( ( Image_ys + Image_scroll_y ) * ImageGetZoom ) );
			LineTo ( Round ( Image_scroll_x * ImageGetZoom ) - 1, Round ( ( Image_ys + Image_scroll_y ) * ImageGetZoom ) );
			LineTo ( Round ( Image_scroll_x * ImageGetZoom ) - 1, Round ( Image_scroll_y * ImageGetZoom ) - 1 );
			LineTo ( Round ( ( Image_xs + Image_scroll_x ) * ImageGetZoom ), Round ( Image_scroll_y * ImageGetZoom ) - 1 );
		End;
	End
	Else
	Begin
		ImageRenderCurrentPos ( Image_xr, Image_yr );
	End;
End;

Procedure TFormMain.ImageRenderCurrentPos ( xr, yr : Integer );
Var
	Zoom : Double;
	xz, yz : Integer;
	x, y : Integer;
Begin
	Zoom := ImageGetZoom;
	//
	ImageRefreshPanel;
	//
	With Image1.Canvas Do
	Begin
		Brush.Color := clAqua;
		FillRect ( ClipRect );
	End;
	//
	If ImageFormat = fmtROTT Then
	Begin
		Image_xc := Image1.Width Div 4;
		Image_yc := Image1.Height Div 4;
	End
	Else
	Begin
		If ( xr = 0 ) And ( yr = 0 ) Then
		Begin
			Image_xc := 0;
			Image_yc := 0;
		End
		Else
		Begin
			Image_xc := Image1.Width Div 2;
			Image_yc := Image1.Height Div 4 * 3;
		End;
	End;
	//
	Image_Weapon := cmdImageWeapon.Caption = 'W: On';
	//
	If Not mnuImageEdit.Checked Then
	Begin
		If ( ImageFormat = fmtDoom ) Then
		Begin
			If ( ( xr <= 0 ) And ( yr < 0 ) Or Image_Weapon )
			And ( cmdImageWeapon.Caption <> 'W: Off' ) Then
			Begin
				//
				xr := Image_xc - Round ( ( xr + 160 ) * Zoom );
				yr := Image_yc - Round ( ( yr + 200 ) * Zoom );
				//
				Image_Weapon := True;
				//
				With Image1.Canvas Do
				Begin
					Pen.Color := clDkGray;
					MoveTo ( Image_xc, 0 );
					LineTo ( Image_xc, Image1.Height - 1 );
					MoveTo ( 0, Image_yc );
					LineTo ( Image1.Width - 1, Image_yc );
					//
				End;
				//
			End
			Else
			Begin
				If ( xr <> 0 ) Or ( yr <> 0 ) Then
				Begin
					xr := Image_xc - Round ( xr * Zoom );
					yr := Image_yc - Round ( yr * Zoom );
					//
					With Image1.Canvas Do
					Begin
						Pen.Color := clDkGray;
						MoveTo ( Image_xc, 0 );
						LineTo ( Image_xc, Image1.Height - 1 );
						MoveTo ( 0, Image_yc );
						LineTo ( Image1.Width - 1, Image_yc );
					End;
					//
				End;
			End;
		End
		Else
		Begin
			// other formats
			xr := Image_xc - Round ( xr * Zoom );
			yr := Image_yc - Round ( yr * Zoom );
			//
			With Image1.Canvas Do
			Begin
				Pen.Color := clDkGray;
				MoveTo ( Image_xc, 0 );
				LineTo ( Image_xc, Image1.Height - 1 );
				MoveTo ( 0, Image_yc );
				LineTo ( Image1.Width - 1, Image_yc );
			End;
		End;
	End;
	//
	ImageRenderCurrentAt ( Image1.Canvas, xr, yr, Zoom );
	//
	If chkImageTile.Checked Then
	Begin
		xz := Round ( Image_xs * Zoom );
		yz := Round ( Image_ys * Zoom );
		//
		If ( xz <> 0 ) And ( yz <> 0 ) Then
		Begin
			//
			y := yr;
			While y > 0 Do
				Dec ( y, yz );
			//
			While y < Image1.Height Do
			Begin
				x := xr;
				While x > 0 Do
					Dec ( x, xz );
				//
				While x < Image1.Width Do
				Begin
					Image1.Canvas.CopyRect ( Classes.Rect ( x, y, x + xz, y + yz ), Image1.Canvas,
						Classes.Rect ( xr, yr, xr + xz, yr + yz ) );
					//
					Inc ( x, xz );
				End;
				Inc ( y, yz );
			End;
		End;
	End
	Else
	Begin
		//
		If Image_Weapon Then
		Begin
			With Image1.Canvas Do
			Begin
				Pen.Mode := pmXor;
				//
				MoveTo ( Image_xc - Round ( 160 * Zoom ), Image_yc - Round ( 200 * Zoom ) );
				LineTo ( Image_xc + Round ( 160 * Zoom ), Image_yc - Round ( 200 * Zoom ) );
				LineTo ( Image_xc + Round ( 160 * Zoom ), Image_yc );
				LineTo ( Image_xc - Round ( 160 * Zoom ), Image_yc );
				LineTo ( Image_xc - Round ( 160 * Zoom ), Image_yc - Round ( 200 * Zoom ) );
				//
				MoveTo ( Image_xc - Round ( 159 * Zoom ), Image_yc - Round ( 32 * Zoom ) );
				LineTo ( Image_xc + Round ( 160 * Zoom ), Image_yc - Round ( 32 * Zoom ) );
				//
				Pen.Mode := pmCopy;
			End;
		End;
	End;
	//
	Image1.Refresh;
End;

Procedure TFormMain.ImageRenderCurrentAt ( c : TCanvas; xr, yr : Integer; Zoom : Double );
Begin
	PreparePalette;
	//
	ImageCheckZoomSize;
	//
	{
	c.CopyRect (
		Classes.Rect ( xr, yr, xr + Image_xs * Zoom, yr + Image_ys * Zoom ),
		cImage.Canvas, Classes.Rect ( 0, 0, Image_xs, Image_ys ) );
	}
	c.Brush.Style := bsClear;
	c.BrushCopy (
		Classes.Rect ( xr, yr, xr + Round ( Image_xs * Zoom ), yr + Round ( Image_ys * Zoom ) ),
		cImage, Classes.Rect ( 0, 0, Image_xs, Image_ys ), RGB ( 0, 255, 255 ) );
End;

(*
Function TFormMain.ImageLoad_Old ( iEntry : Integer; c : TCanvas; xp, yp, Zoom : Integer ) : Boolean;
Var
	r, g, b : Byte;
	fp : Longint;
	i, n, iSkippedBytes : Longint;
	iPos, iLen : Longint;
	xs_, ys_ : SmallInt; // 16 bit
	xs, ys : Integer; // 32 bit

	x, y, xz, yz : Integer;

	SeekTab : Array [ 0 .. 8192 - 1 ] Of Longint;
Type
	TPicData = Array [ 0 .. $100000 ] Of Byte;

Var
	PicData : ^TPicData;

Function gb : Byte;
Begin
	If fp > iLen Then
	Begin
		gb := $FF;
	End
	Else
	Begin
		gb := PicData^ [ fp ];
		Inc ( fp );
	End;
End;

Begin
	PreparePalette;
	//
	iPos := WadEntries [ iEntry ].Position;
	iLen := WadEntries [ iEntry ].Size;

	If Not fOpen ( sEditFile ) Then
	Begin
		ImageLoad_Old := False;
	End
	Else
	Begin

		If iLen < 8 Then
		Begin
			// file to small to be an image
			fClose;
			ImageLoad_Old := False;
		End
		Else
		Begin

			Seek ( F, iPos );

			If Zoom < 1 Then Zoom := 1;
			If Zoom > 10 Then Zoom := 10;

			xs_ := GetWord ( f );
			ys_ := GetWord ( f );
			//
			If ( xs_ = $4D49 ) And ( ys_ = $5A47 ) Then
			Begin
				//
				// ZDoom Image format
				//
				xs_ := GetWord ( f );
				ys_ := GetWord ( f );
				xs := xs_;
				ys := ys_;
				GetWord ( f );
				GetWord ( f );
				//
				If GetLong ( f ) = 1 Then
				Begin
					// Compressed image
					fClose;
					ImageLoad_Old := False;
				End
				Else
				Begin
					GetLong ( f );
					GetLong ( f );
					//
					For y := 0 To ys - 1 Do
					Begin
						For x := 0 To xs - 1 Do
						Begin
							b := GetByte ( f );
							For yz := 0 To Zoom - 1 Do
							Begin
								For xz := 0 To Zoom - 1 Do
								Begin
									SetPixel ( C.Handle, xp + x * Zoom + xz, yp + y * Zoom + yz, Pal [ b ] );
								End;
							End;
						End;
					End;
					//
					fClose;
					ImageLoad_Old := True;
				End;
			End
			Else
			Begin
				If ys_ = 0 Then
				Begin
					//
					// Quake image
					//
					xs := xs_;
					ys := GetLong ( f );
					//
					ImageResetCurrent ( xs, ys );
					//
					For y := 0 To ys - 1 Do
					Begin
						For x := 0 To xs - 1 Do
						Begin
							b := GetByte ( f );
							SetPixel ( cImage.Canvas.Handle, x, y, Pal [ b ] );
						End;
					End;
					//
					fClose;
					//
					ImageRenderCurrent;
					//
					ImageLoad_Old := True;
				End
				Else
				Begin
					//
					If ( xs_ = 0 ) And ( ys_ = 2 ) Then
					Begin
						// TGA format?
						GetLong ( f );
						GetLong ( f );
						xs := GetWord ( f );
						ys := GetWord ( f );
						GetWord ( f );
						//
						ImageResetCurrent ( xs, ys );
						//
						For y := ys - 1 DownTo 0 Do
						Begin
							For x := 0 To xs - 1 Do
							Begin
								b := GetByte ( f );
								g := GetByte ( f );
								r := GetByte ( f );
								GetByte ( f );
								SetPixel ( cImage.Canvas.Handle, x, y, RGB ( r, g, b ) );
							End;
						End;
						//
						fClose;
						//
						ImageRenderCurrent;
						//
						ImageLoad_Old := True;
					End
					Else
					Begin
						If ( ( xs_ And $FFFF ) = $D8FF ) And ( ( ys_ And $FFFF ) = $E0FF ) Then
						Begin
							//
							// JPEG
							//
							fClose;
							//
							Image1.Picture.LoadFromFile ( sEditFile );
							//
							xs := Image1.Picture.Width;
							ys := Image1.Picture.Height;
							ImageResetCurrent ( xs, ys );
							cImage.Assign ( Image1.Picture.Graphic );
							//
							ImageRenderCurrent;
							ImageLoad_Old := True;
						End
						Else
						Begin
							//
							xs := xs_;
							ys := ys_;

							GetWord ( f );
							GetWord ( f );

							iSkippedBytes := 8;

							If ( ( iSkippedBytes + xs * 4 ) > iLen )
							Or ( xs <= 0 ) Or ( ys <= 0 ) Or ( xs >= 8192 ) Then
							Begin

								fClose;
								ImageLoad_Old := False;

							End
							Else
							Begin

								BlockRead ( F, SeekTab, xs * 4 );
								Inc ( iSkippedBytes, xs * 4 );

								// ---

								y := 0;
								For x := 0 To xs - 1 Do
								Begin
									If ( SeekTab [ x ] > iLen ) Or ( SeekTab [ x ] < 8 ) Then
									Begin
										y := 1;
									End;
								End;

								//

								If y <> 0 Then
								Begin

									fClose;
									ImageLoad_Old := False;

								End
								Else
								Begin

									Starting;

									//
									ImageResetCurrent ( xs, ys );

									Image_xr := xp;
									Image_yr := yp;

									// --- --- ---

									iLen := iLen - iSkippedBytes;

									GetMem ( PicData, iLen );
									BlockRead ( F, PicData^, iLen );

									For x := 0 To xs - 1 Do
									Begin
										//Seek ( F, iPos + SeekTab [ x ] );
										fp := SeekTab [ x ] - iSkippedBytes;

										//Status ( 'Processing Line ' + Comma ( x + 1 ) + ' of ' + Comma ( xs ) );

										b := gb;

										While b <> $FF Do
										Begin

											y := b - 1;

											// ---
											b := gb;

											n := b;
											For i := 0 To n + 1 Do
											Begin
												// ---
												b := gb;

												If ( i <> 0 ) And ( i <> n + 1 ) Then
												Begin

													//c := RGB ( Pal [ b * 3 ], Pal [ b * 3 + 1 ], Pal [ b * 3 + 2 ] );

													SetPixel ( cImage.Canvas.Handle, x, y, Pal [ b ] );
													{
													For yz := 0 To Zoom - 1 Do
													Begin
														For xz := 0 To Zoom - 1 Do
														Begin
															SetPixel ( C.Handle, xp + x * Zoom + xz, yp + y * Zoom + yz, Pal [ b ] );
														End;
													End;
													}

												End;

												Inc ( y );
											End;

											// ---
											b := gb;
										End;
									End;

									FreeMem ( PicData, iLen );

									fClose;

									If c = Nil Then
										ImageRenderCurrent
									Else
										ImageRenderCurrentAt ( c, xp, yp, Zoom );

									Finished;

									ImageLoad_Old := True;
								End;
							end;
						End;
					End;
				End;
			end;
		End;
	End;
End;
*)

procedure TFormMain.mnuImageCompressClick(Sender: TObject);
Var
	xa, ya : Integer; // anchor for getting pixels
	xs, ys : Integer; // image size
	xo, yo,
	xc, yc : Integer; // original and compared
	xr, yr : Integer; // result

Procedure Compare ( x1, y1, x2, y2 : Integer; Var xe, ye : Integer );
Var
	xp, yp : Integer; // compare pointer
	xm, ym : Integer; // max value
	Done : Boolean;
Begin
	//
	//---
	//
	xm := xs - x2;
	ym := ys - y2;
	//
	If ( x2 - x1 ) < xm Then
		xm := x2 - x1;
	{ !!!!!!
	If ( y2 - y1 ) < ym Then
		ym := y2 - y1;
	}
	//
	//---
	//
	xp := 0;
	yp := 0;
	//
	Done := False;
	While Not Done Do
	Begin
		If ( Image1.Canvas.Pixels [ xa + x1 + xp, ya + y1 + yp ] =
			Image1.Canvas.Pixels [ xa + x2 + xp, ya + y2 + yp ] ) Then
		Begin
			Inc ( xp );
			If ( xp = xm ) Then
			Begin
				xe := xp - 1;
				xp := 0;
				Inc ( yp );
				ye := yp - 1;
				//
				If yp = ym Then
				Begin
					Done := True;
				End;
			End;
		End
		Else
		Begin
			If yp > 0 Then
			Begin
				Done := True;
			End
			Else
			Begin
				xe := xp - 1;
				xp := 0;
				Inc ( yp );
				ye := yp - 1;
				//
				If yp = ym Then
				Begin
					Done := True;
				End;
			End;
		End;
	End;
	//
end;

Begin
	xa := ( Image1.Width Div 2 ) - ( SafeVal ( PanelImageEditX.Text ) );
	ya := ( Image1.Height Div 4 * 3 ) - ( SafeVal ( PanelImageEditY.Text ) );
	//
	xs := 64; // cheat!
	ys := 64;
	//
	xo := 0;
	yo := 0;
	//
	xc := 16;
	yc := 0;
	//
	xr := 0;
	yr := 0;
	//
	While ( xo < 64 ) Do
	Begin
		Compare ( xo, yo, xc, yc, xr, yr );
		ShowMessage ( Comma ( xr ) + ',' + Comma ( yr ) );
		//
		xo := 100;
	End;
end;

function TFormMain.ImageSaveFlat : Boolean;
Var
	x, y, Size : Integer;
Begin
	//
	// --- Save as floor format
	//
	fOpenTemp;
	//
	If ( Image_xs >= 512 ) And ( Image_ys >= 512 ) Then
		Size := 512
	Else
		If ( Image_xs >= 256 ) And ( Image_ys >= 256 ) Then
			Size := 256
		Else
			If ( Image_xs >= 128 ) And ( Image_ys >= 128 ) Then
				Size := 128
			Else
				Size := 64;
	//
	// Save as is, image is already properly oriented
	//
	For y := 0 To Size - 1 Do
	Begin
		For x := 0 To Size - 1 Do
		Begin
			SendByte ( fo, ImagePaletteMatch ( cImage.Canvas.Pixels [ x, y ] ) );
		End;
	End;
	//
	CloseFile ( fo );
	//
	ReplaceFile ( iSel, sTempFile, True, True );
	//
	ImageSaveFlat := True;
End;

function TFormMain.ImageSave : Boolean;
Var
	bSaved : Boolean;
	s : String;
	t : Boolean;
Begin
	bSaved := False;
	If mnuImageSave.Enabled Then
	Begin
		If ImageOnlyAlignmentModified Then
		Begin
			If gAutoApplyOffsets Or CheckFileExtModified Then
			Begin
				// only save alignment
				mnuImageApplyClick ( Self );
				//
				bSaved := True;
			End;
		End
		Else
		Begin
			If CheckFileExtModified Then
			Begin
				t := Image_KeepAlignment;
				Image_KeepAlignment := True;
				s := ImageConvertToDoom ( Image_xs, Image_ys, Image_xr, Image_yr );
				Image_KeepAlignment := t;
				ReplaceFile ( iSel, s, True, True );
				//
				Modified ( False );
				UpdateModifiedDate;
				ImageOnlyAlignmentModified := True;
				//
				bSaved := True;
			End;
		End;
	End;
	ImageSave := bSaved;
end;

procedure TFormMain.mnuImageSaveClick(Sender: TObject);
Begin
	ImageSave;
End;

procedure TFormMain.mnuImageSaveFlatClick(Sender: TObject);
begin
	ImageSaveFlat;
	//
	Image_xr := 0;
	Image_yr := 0;
	ImageUpdateAlignment;
	//
	ImageRenderCurrent;
	//
	Modified ( False );
end;

procedure TFormMain.mnuImageWeaponCropClick(Sender: TObject);
Var
	ye : Integer;
begin
	If ( Image_xs >= 0 ) Or ( Image_ys >= 0 ) Then
	Begin
		ye := - ( 200 - 32 - Image_ys + Image_yr );
		If ( ye > 0 ) Then
		Begin
			Dec ( Image_ys, ye );
			//
			ImageUpdateSize;
			ImageUpdateAlignment;
			//
			ImageRenderCurrent;
			//
			Modified ( True );
			ImageOnlyAlignmentModified := False;
			//
			Status ( 'Cropped ' + Comma ( ye ) + ' lines.' );
		End
		Else
		Begin
			Status ( 'This sprite does not need to be cropped.' );
		End;
	End
	Else
	Begin
		Status ( 'This sprite is not aligned as a weapon.' );
	End;
end;

procedure TFormMain.mnuImageAutoCropClick(Sender: TObject);

Var
	CutColor : Integer;
	xb, yb, xe, ye : Integer;

function ColEmpty ( iXCol : Integer ) : Boolean;
Var
	y : Integer;
	bEmpty : Boolean;
Begin
	y := 0;
	bEmpty := True;
	//
	While bEmpty And ( y < Image_ys ) Do
	Begin
		If cImage.Canvas.Pixels [ iXCol, y ] <> CutColor Then
			bEmpty := False
		Else
			Inc ( y );
	End;
	//
	ColEmpty := bEmpty;
End;

function RowEmpty ( iYRow : Integer ) : Boolean;
Var
	x : Integer;
	bEmpty : Boolean;
Begin
	x := 0;
	bEmpty := True;
	//
	While bEmpty And ( x < Image_xs ) Do
	Begin
		If cImage.Canvas.Pixels [ x, iYRow ] <> CutColor Then
			bEmpty := False
		Else
			Inc ( x );
	End;
	//
	RowEmpty := bEmpty;
End;

Begin
	//
	// ---
	//
	CutColor := RGB ( 0, 255, 255 );
	//
	xb := 0;
	While ( ColEmpty ( xb ) ) Do
		Inc ( xb );
	//
	xe := Image_xs - 1;
	While ( ColEmpty ( xe ) ) Do
		Dec ( xe );
	//
	yb := 0;
	While ( RowEmpty ( yb ) ) Do
		Inc ( yb );
	//
	ye := Image_ys - 1;
	While ( RowEmpty ( ye ) ) Do
		Dec ( ye );
	//
	//
	//
	If ( xb = 0 ) And ( yb = 0 ) And ( xe = Image_xs - 1 ) And ( ye = Image_ys - 1 ) Then
	Begin
		MessageDlg ( 'This image cannot be cropped.', mtInformation, [mbOK], 0 );
	End
	Else
	Begin
		cImage.Canvas.CopyRect (
			Classes.Rect ( 0, 0, xe - xb + 1, ye - yb + 1 ),
			cImage.Canvas, Classes.Rect ( xb, yb, xe + 1, ye + 1 ) );
		//
		Image_xs := xe - xb + 1;
		Image_ys := ye - yb + 1;
		//
		If ( Image_xr <> 0 ) Or ( Image_yr <> 0 ) Then
		Begin
			Image_xr := Image_xr - xb;
			Image_yr := Image_yr - yb;
		End;
		//
		ImageUpdateSize;
		ImageUpdateAlignment;
		//
		ImageRenderCurrent;
		//
		Modified ( True );
		ImageOnlyAlignmentModified := False;
	End;
end;

procedure TFormMain.mnuImageApplyClick(Sender: TObject);
Var
	BytesRead : Integer;
	ChunkLen : Integer;
	ChunkID : Integer;
	ChunkCRC32, CRC32 : DWORD;
	GrabChunkDone : Boolean;
	//
	PicData_Count : Integer;

Procedure SetPicData_Send ( i : Integer );
Begin
	PicData^ [ PicData_Count + 0 ] := i Shr 24 And 255;
	PicData^ [ PicData_Count + 1 ] := i Shr 16 And 255;
	PicData^ [ PicData_Count + 2 ] := i Shr 8 And 255;
	PicData^ [ PicData_Count + 3 ] := i And 255;
	//
	SendLong2 ( fo, i );
	//
	Inc ( PicData_Count, 4 );
End;

Procedure SaveGrabChunk;
Begin
	//
	// *** add grAb chunk
	//
	SendLong2 ( fo, 8 ); // length: 8 bytes
	//
	GetMem ( PicData, 8 + 4 );
	PicData_Count := 0;
	//
	// $67724162
	SetPicData_Send ( Ord('g') Shl 24 + Ord('r') Shl 16 + Ord('A') Shl 8 + Ord('b') );
	SetPicData_Send ( SafeVal ( PanelImageEditX.Text ) );
	SetPicData_Send ( SafeVal ( PanelImageEditY.Text ) );
	//
	CRC32 := $FFFFFFFF; // To match PKZIP
	CalcCRC32 ( PicData, 8 + 4, CRC32 );
	CRC32 := not CRC32;
	//
	SendLong2 ( fo, CRC32 );
	//
	FreeMem ( PicData, 8 + 4 );
End;

Begin
	If Not fOpen ( sEditFile ) Then Exit;
	//
	SaveUndo ( 'Apply Image Offset' );
	//
	// [PNG]
	If ImageFormat = fmtPNG Then
	Begin
		//
		GrabChunkDone := False;
		//
		fOpenTemp;
		//
		Seek ( f, cPos );
		SendLong2 ( fo, GetLong2 ( f ) ); // PNG
		SendLong2 ( fo, GetLong2 ( f ) ); // second part of header
		//
		BytesRead := 8;
		//
		(*
		1. The grAb chunk.

			[DWORD]        8 (This chunk is always eight bytes long)
			[DWORD]        grAb
			[Signed DWORD] X Offset
			[Signed DWORD] Y Offset
			[DWORD]        CRC32

			Like PNG files in general, the offsets are big-endian.
			Aside from that, they have the same meaning as a Doom graphic's.

	2. The alPh chunk.

			[DWORD]        0 (This chunk has no content)
			[DWORD]        alPh
			[DWORD]        CRC32

			This chunk is only valid for an 8-bit grayscale image.
			If it is present, then the image is treated as an alpha channel.
	*)
		//
		ChunkID := 1;
		// stop at IEND or end of file
		While ( ChunkID <> $49454E44 ) And ( BytesRead <= cLen ) Do
		Begin
			ChunkLen := GetLong2 ( f ); // get length
			ChunkID := GetLong2 ( f ); // get chunk id
			Inc ( BytesRead, 8 );
			//
			// look for IDAT
			//
			If ChunkID = $49444154 Then
			Begin
				If Not GrabChunkDone Then
				Begin
					// save grab chunk into this PNG for the first time
					SaveGrabChunk;
					GrabChunkDone := True;
				End;
			End;
			//
			// look for existing grab
			//
			If ChunkID = $67724162 Then
			Begin
				ChunkID := 0; // flag to skip it
				//
				If Not GrabChunkDone Then
				Begin
					// we need to replace this one
					SaveGrabChunk;
					GrabChunkDone := True;
				End;
			End;
			//
			If ChunkID <> 0 Then
			Begin
				//
				// normal chunk copy
				//
				SendLong2 ( fo, ChunkLen );
				SendLong2 ( fo, ChunkID );
				CopyData ( f, fo, ChunkLen );
				Inc ( BytesRead, ChunkLen );
				//
				ChunkCRC32 := GetLong2 ( f ); // CRC32
				Inc ( BytesRead, 4 );
				SendLong2 ( fo, ChunkCRC32 );
			End
			Else
			Begin
				// skip this chunk
				Seek ( f, FilePos ( f ) + ChunkLen );
				Inc ( BytesRead, ChunkLen );
				//
				GetLong ( f ); // skip CRC
				Inc ( BytesRead, 4 );
			End;
			//
		End;
		//
		CloseFile ( fo );
		fClose;
		//
		ReplaceFile ( iSel, sTempFile, True, True );
		//
		Modified ( False );
		//
	End
	Else
	Begin
		//
		Seek ( f, cPos + 4 );
		SendWord ( f, SafeVal ( PanelImageEditX.Text ) );
		SendWord ( f, SafeVal ( PanelImageEditY.Text ) );
		fClose;
		//
	End;
	//
	Modified ( False );
	UpdateModifiedDate;
end;

function TFormMain.ExportGetArtFileName : String;
Var
	sFN : String;
Begin
	sFN := RemoveFolder ( Trim ( WadEntries [ iSel ].Name ) );
	//
	If Pos ( '.', sFN ) > 0 Then
	Begin
		sFN := Copy ( sFN, 1, Pos ( '.', sFN ) -1 );
	End;
	//
	sFN := sFN + '_' + ImageArtGrid.Cells [ 1, ImageArtGrid.Row ] + '.bmp';
	//
	ExportGetArtFileName := sFN;
End;

procedure TFormMain.mnuImageSaveAllClick(Sender: TObject);
Var
	s : String;
	i : Integer;
	b : Boolean;
Begin
	//
	s := ExportGetFolder;
	//
	If s <> '' Then
	Begin
		//
		Application.ProcessMessages;
		//
		For i := 1 To ImageArtGrid.RowCount - 1 Do
		Begin
			ImageArtGrid.Row := i;
			ImageArtGridSelectCell ( Sender, 1, i, b );
			//
			s := ExportGetArtFileName;
			//
			cImage.SaveToFile ( s );
		End;
		//
	End;
end;

procedure TFormMain.mnuImageSaveCurrentClick(Sender: TObject);
Var
	sFN : String;
Begin
	sFN := RemoveFolder ( Trim ( WadEntries [ iSel ].Name ) );
	//
	If Pos ( '.', sFN ) > 0 Then
	Begin
		sFN := Copy ( sFN, 1, Pos ( '.', sFN ) -1 );
	End;
	//
	sFN := sFN + '_' + ImageArtGrid.Cells [ 1, ImageArtGrid.Row ] + '.bmp';
	//
	sFN := ExportGetFileName ( sFN, 'Bmp Files (*.bmp)|*.BMP', 'bmp' );
	//
	If sFN <> '' Then
	Begin
		//
		Starting;
		//
		// 24 or 32 bit...
		cImage.SaveToFile ( sFN );
		//
		Finished;
		//
	End;
end;

procedure TFormMain.ImageRemapReset;
Var
	i : Integer;
Begin
	For i := 0 To 255 Do
	Begin
		ImageRemap [ i ] := i;
	End;
End;

procedure TFormMain.mnuColorRemapResetClick(Sender: TObject);
Begin
	ImageRemapReset;
	//
	If ImageRemapList.Visible Then
		ImageRemapList.Refresh;
end;

procedure TFormMain.mnuImagePerformColorRemapClick(Sender: TObject);
Var
	i, x, y : Integer;
	s : String;
	Color, Code : Integer;
Begin
	For i := 0 To ImageRemapList.Items.Count - 1 Do
	Begin
		s := ImageRemapList.Items [ i ];
		//
		If Pos ( '=', s ) > 0 Then
		Begin
			Color := SafeVal ( Copy ( s, 1, Pos ( ' ', s ) - 1 ) );
			Code := SafeVal ( RemoveFromLeft ( s, Pos ( '=', s ) ) );
			ImageRemap [ Color ] := Code;
		End;
	End;
	//
	If ImageFormat = fmtFloor Then
	Begin
		fOpenTemp;
	End;
	//
	For y := 0 To cImage.Height - 1 Do
	Begin
		For x := 0 To cImage.Width - 1 Do
		Begin
			Color := cImage.Canvas.Pixels [ x, y ];
			Code := ImagePaletteMatch ( Color );
			//
			Code := ImageRemap [ Code ];
			//
			If Code = 247 Then
			Begin
				Color := clAqua;
			End
			Else
			Begin
				Color := Pal [ Code ];
			End;
			//
			cImage.Canvas.Pixels [ x, y ] := Color;
			//
			If ImageFormat = fmtFloor Then
			Begin
				SendByte ( fo, Code );
			End;
		End;
	End;
	//
	Modified ( True );
	ImageOnlyAlignmentModified := False;
	//
	If ImageFormat = fmtFloor Then
	Begin
		CloseFile ( fo );
		ReplaceFile ( iSel, sTempFile, True, True );
	End;
	//
	ImageRenderCurrent;
	//
	ImageRemapCountColors;
end;

procedure TFormMain.ImageRemapListDrawItem(Control: TWinControl;
	Index: Integer; Rect: TRect; State: TOwnerDrawState);
Var
	Offset: Integer;      { text offset width }
	Color, MappedColor : Integer;
	s : String;
	x, y, xs : Integer;
Begin
	with (Control as TListBox).Canvas do  { draw on control canvas, not on the form }
	Begin
		If Brush.Color = clWindow Then
			Brush.Color := RGB ( 255 - Index Div 4, 255 - Index Div 4, 255 - Index Div 4 );
		//
		FillRect ( Rect ); { clear the rectangle }
		//
		s := (Control as TListBox).Items[Index];
		//
		x := Rect.Left + 1;
		y := Rect.Top + 1;
		xs := Rect.Bottom - Rect.Top - 2;
		//
		Offset := 2 + xs;       { provide default offset }
		//
		Color := SafeVal ( Copy ( s, 1, Pos ( ' ', s ) - 1 ) );
		MappedColor := ImageRemap [ Color ];
		//
		TextOut ( Rect.Left + Offset, Rect.Top, s );  { display the text }
		TextOut ( Rect.Left + Offset + 100, Rect.Top, IntToStr ( MappedColor ) );
		//
		Brush.Color := Pal [ Color ];
		FillRect ( Classes.Rect ( x, y, x + xs, y + xs ) );
		//
		Brush.Color := Pal [ MappedColor ];
		FillRect ( Classes.Rect ( x + 100, y, x + 100 + xs, y + xs ) );
	end;
end;

procedure TFormMain.ImageRemapListDblClick(Sender: TObject);
Var
	Color, Code : Integer;
	s : String;
Begin
	s := ImageRemapList.Items [ ImageRemapList.ItemIndex ];
	//
	Color := SafeVal ( Copy ( s, 1, Pos ( ' ', s ) - 1 ) );
	Code := ImageRemap [ Color ];
	Code := SafeVal ( InputBox ( 'New Color Code', 'Remap ' + IntToStr ( Color ) + ' to:', IntToStr ( Code ) ) );
	If ( Code >= 0 ) And ( Code <= 255 ) Then
	Begin
		ImageRemap [ Color ] := Code;
		ImageRemapList.Refresh;
	End;
end;

procedure TFormMain.ImageRemapListKeyPress(Sender: TObject; Var Key: Char);
Var
	s : String;
	Color : Integer;
Begin
	Case Key Of

		#13 : // enter, same as double click
		Begin
			Key := #0;
			ImageRemapListDblClick ( Sender );
		End;

		#43 : // plus, increase "map to" value
		Begin
			s := ImageRemapList.Items [ ImageRemapList.ItemIndex ];
			//
			Color := SafeVal ( Copy ( s, 1, Pos ( ' ', s ) - 1 ) );
			ImageRemap [ Color ] := ( ImageRemap [ Color ] + 1 ) And 255;
			ImageRemapList.Refresh;
		End;

		#45 : // minus, decrease "map to" value
		Begin
			s := ImageRemapList.Items [ ImageRemapList.ItemIndex ];
			//
			Color := SafeVal ( Copy ( s, 1, Pos ( ' ', s ) - 1 ) );
			ImageRemap [ Color ] := ( ImageRemap [ Color ] + 254 ) And 255;
			ImageRemapList.Refresh;
		End;

		#100 : // d?
		Begin
			s := ImageRemapList.Items [ ImageRemapList.ItemIndex ];
			Color := SafeVal ( Copy ( s, 1, Pos ( ' ', s ) - 1 ) );
			ImageRemap [ Color ] := ImageRemap [ Color - 1 ] + 1;
			ImageRemapList.ItemIndex := ImageRemapList.ItemIndex + 1;
			ImageRemapList.Refresh;
		End;

		Else
		Begin
			Caption := IntToStr ( Ord ( Key ) );
		End;
	End;
end;

procedure TFormMain.ImageSplitterRemapMoved(Sender: TObject);
Begin
	//
	PanelImage.Tag := 0;
	ImageRefreshPanel;
	ImageRenderCurrent;
	//
end;

procedure TFormMain.ImageRemapCountColors;
Var
	x, y : Integer;
	Color, Code : Integer;
	ColorUsed : Array [ 0 .. 255 ] Of Integer;
Begin
	For x := 0 To 255 Do
	Begin
		ColorUsed [ x ] := 0;
	End;
	//
	For y := 0 To cImage.Height - 1 Do
	Begin
		For x := 0 To cImage.Width - 1 Do
		Begin
			Color := cImage.Canvas.Pixels [ x, y ];
			Code := ImagePaletteMatch ( Color );
			Inc ( ColorUsed [ Code ] );
		End;
	End;
	//
	ImageRemapList.Items.Clear;
	For x := 0 To 255 Do
	Begin
		If ColorUsed [ x ] > 0 Then
		Begin
			ImageRemapList.Items.Add ( Zero ( x , 3 ) + ' [' +
				Zero ( ColorUsed [ x ], 6 ) + ']' );
		End;
	End;
	//
	//ImageRemapList.Refresh;
End;

procedure TFormMain.mnuImageColorRemapClick(Sender: TObject);

Begin
	mnuImageColorRemap.Checked := Not mnuImageColorRemap.Checked;
	If mnuImageColorRemap.Checked Then
	Begin
		PanelImageRemap.Visible := True;
		PanelImageRemap.Width := 200;
		//
		ImageSplitterRemap.Visible := True;
		//
		ImageRemapCountColors;
	End
	Else
	Begin
		ImageSplitterRemap.Visible := False;
		PanelImageRemap.Visible := False;
	End;
	//
	PanelImage.Tag := 0;
	ImageRefreshPanel;
	ImageRenderCurrent;
	//
end;

procedure TFormMain.PanelImageEditXExit(Sender: TObject);
begin
	If isModified And gAutoApplyOffsets Then
	Begin
		mnuImageApplyClick ( Sender );
	End;
end;

procedure TFormMain.PanelImageEditYExit(Sender: TObject);
begin
	If isModified And gAutoApplyOffsets Then
	Begin
		mnuImageApplyClick ( Sender );
	End;
end;

procedure TFormMain.PanelImageEditYChange(Sender: TObject);
Begin
	If PanelImageEditY.Tag = 1 Then
	Begin
		PanelImageEditY.Tag := 0;
	End
	Else
	Begin
		If PanelImageEditX.Tag = 1 Then
		Begin
			PanelImageEditX.Tag := 0;
		End
		Else
		Begin
			//
			Image_xr := SafeVal ( PanelImageEditX.Text );
			Image_yr := SafeVal ( PanelImageEditY.Text );
			//
			ImageRenderCurrentPos ( Image_xr, Image_yr );
			//
			Modified ( True );
		End;
	End;
end;

procedure TFormMain.PanelImageEditXKeyPress(Sender: TObject;
	Var Key: Char);
Begin
	If Key = #43 Then
	Begin
		Key := #0;
		TEdit ( Sender ).Text := IntToStr ( SafeVal ( TEdit ( Sender ).Text ) + 1 );
		TEdit ( Sender ).SelStart := Length ( TEdit ( Sender ).Text );
	End
	Else
	Begin
		If Key = #45 Then
		Begin
			If ( Pos ( '-', TEdit ( Sender ).Text ) <> 0 )
			Or ( TEdit ( Sender ).SelStart <> 0 ) Then
			Begin
				Key := #0;
				TEdit ( Sender ).Text := IntToStr ( SafeVal ( TEdit ( Sender ).Text ) - 1 );
				TEdit ( Sender ).SelStart := Length ( TEdit ( Sender ).Text );
			End;
		End;
	End;
end;

// --------------------------------------------------------------------------

procedure TFormMain.mnuImageSelectPaletteClick(Sender: TObject);
Var
	fp : TFormPal;
Begin
	fp := TFormPal.Create ( Self );
	fp.ShowModal;
	fp.Free;
	//
	PaletteReady := False;
	//
	ShowEntry ( '', False ); // re-draw current
end;

procedure TFormMain.InitPals;
Var
	s : String;
	sr : TSearchRec;
	Error : Integer;
Begin
	//
	iPreferredPal := -1; // -1 = auto; -2 = custom
	//
	s := Application.ExeName;
	s := Copy ( s, 1, PosR ( '\', s ) ) + 'palettes\';
	//
	nPals := 0;
	Error := FindFirst ( s + '*.act', faAnyFile, sr );
	//
	While Error = 0 Do
	Begin
		// Load new palette
		Pals [ nPals ].Name := RemoveFromRight ( sr.Name, 4 ); // cut .ACT extension
		//
		AssignFile ( f, s + sr.Name );
		FileMode := fmOpenReadWrite;
		Reset ( f, 1 );
		BlockRead ( f, Pals [ nPals ].Pal, 768 );
		CloseFile ( f );
		//
		Error := FindNext ( sr );
		//
		Inc ( nPals );
	End;
End;

Function TFormMain.FindPal ( sPal : String ) : Integer;
Var
	i : Integer;
	bFound : Boolean;
Begin
	i := 0;
	bFound := False;
	//
	While ( i < nPals ) And Not bFound Do
	Begin
		If UpperCase ( Pals [ i ].Name ) = UpperCase ( sPal ) Then
		Begin
			bFound := True;
		End
		Else
		Begin
			Inc ( i );
		End;
	End;
	//
	If Not bFound Then
		FindPal := -1
	Else
		FindPal := i;
End;

Procedure TFormMain.PreparePalette;
Var
	iPal : Integer;
	i, r, g, b : Integer;
	bLighten : Boolean;
	{$DEFINE _RevPal}
	{$IFDEF RevPal}
	t : File;
	{$ENDIF}

Procedure GetPal ( iPalette : Integer );
Var
	i : Integer;
Begin
	For i := 0 To 255 Do
	Begin
		Pal [ i ] :=
			Pals [ iPalette ].Pal [ i, 0 ] +
			Pals [ iPalette ].Pal [ i, 1 ] Shl 8 +
			Pals [ iPalette ].Pal [ i, 2 ] Shl 16;
	End;
End;

Begin
	//
	If Not PaletteReady Then
	Begin
		If iPreferredPal <> -1 Then
		Begin
			GetPal ( iPreferredPal );
		End
		Else
		Begin
			//
			i := FindEntryType ( 'PALETTE' );
			If i > 0 Then
			Begin
				i := FindEntryByType ( i );
				If i > 0 Then
				Begin
					//
					// Check for 'real' palette entry (dividable by 768)
					//
					If ( ( WadEntries [ i ].Size Mod 768 ) = 0 )
					{$IFDEF FULLVERSION}
					Or ( FileType = DukeFile ) Or ( FileType = Duke2File )
					{$ENDIF}
					Then
					Begin
						//
						fOpen ( sFileName );
						Seek ( f, WadEntries [ i ].Position );
						For i := 0 To 255 Do
						Begin
							r := Byte ( GetByte ( f ) );
							g := Byte ( GetByte ( f ) );
							b := Byte ( GetByte ( f ) );
							Pal [ i ] := RGB ( r, g, b );
						End;
						fClose;
						//
						bLighten := True;
						//
						For i := 0 To 255 Do
						Begin
							If ( ( Pal [ i ] Shr 16 ) And 255 >= 64 )
							And ( ( Pal [ i ] Shr 8 ) And 255 >= 64 )
							And ( ( Pal [ i ] Shr 0 ) And 255 >= 64 ) Then
							Begin
								bLighten := False;
							End;
						End;
						//
						{$IFDEF FULLVERSION}
						If FileType = AARESFile Then
						Begin
							bLighten := True;
						End;
						{$ENDIF}
						//
						If bLighten Then
						Begin
							For i := 0 To 255 Do
							Begin
								Pal [ i ] := Pal [ i ] Shl 2;
							End;
						End;
						//
						i := 1; // flag palette found
					End
					Else
					Begin
						i := 0; // not a real palette
					End;
				End;
			End;
			//
			// *** No local palette?
			//
			If i = 0 Then
			Begin
				//
				{$IFDEF FULLVERSION}
				Case FileType Of

					QuakeFile, Wad2File :
					Begin
						iPal := FindPal ( 'QUAKE' );
					End;

					RFFFile :
					Begin
						iPal := FindPal ( 'BLOOD' );
					End;

					WolfFile :
					Begin
						iPal := FindPal ( 'WOLF' );
					End;

					EOB1File :
					Begin
						iPal := FindPal ( 'EOB1' );
					End;

					EOB3File :
					Begin
						iPal := FindPal ( 'EOB3' );
					End;

					DarkForcesFile :
					Begin
						iPal := FindPal ( 'DARKFORC' );
					End;

					PIGFile :
					Begin
						iPal := FindPal ( 'DESCENT' );
					End;

					PIG2File :
					Begin
						iPal := FindPal ( 'DESCENT2' );
					End;

					AdrenixFile :
					Begin
						iPal := FindPal ( 'ADRENIX' );
					End;

					ROTH2File, DASFile :
					Begin
						iPal := FindPal ( 'ROTH' );
					End;

					RIDFile :
					Begin
						iPal := FindPal ( 'ERAD' );
					End;

					MTIFile :
					Begin
						iPal := FindPal ( 'MDK' );
					End;

					TRFile, GRFile :
					Begin
						iPal := FindPal ( 'ULTIMA1' );
					End;

					LABFile :
					Begin
						iPal := FindPal ( 'OUTLAWS' );
					End;

					Else
					Begin
						{$ENDIF}
						//
						// look in Main WAD
						i := FindEntryInMain ( 'PLAYPAL' );
						//
						If i > 0 Then
						Begin
							//
							// found, load it from Main WAD
							AssignFile ( f, sMainWAD );
							FileMode := fmOpenRead; // read-only by default
							Reset ( f, 1 );
							//
							fSeek ( f, MainWadEntries [ i ].Position );
							//
							For i := 0 To 255 Do
							Begin
								r := Byte ( GetByte ( f ) );
								g := Byte ( GetByte ( f ) );
								b := Byte ( GetByte ( f ) );
								Pal [ i ] := RGB ( r, g, b );
							End;
							fClose;
							//
							iPal := -1; // flag "done"
						End
						Else
						Begin
							// default to regular doom palette
							iPal := FindPal ( 'DOOM' );
						End;
						//
						{$IFDEF FULLVERSION}
					End;
				End;
				{$ENDIF}
				//
				If iPal >= 0 Then
					GetPal ( iPal );
				//
			End;
		End;
		//
		PaletteReady := True;
		//
		//***temp code
		{$IFDEF RevPal}
		AssignFile ( t, 'c:\new.act' );
		FileMode := fmOpenReadWrite;
		ReWrite ( t, 1 );
		For i := 0 To 255 Do
		Begin
			{
			SendByte ( t, ( Pal [ i ] And 255 ) Shl 2 );
			SendByte ( t, ( Pal [ i ] Shr 8 And 255 ) Shl 2 );
			SendByte ( t, ( Pal [ i ] Shr 16 And 255 ) Shl 2 );
			}
			BlockWrite ( t, Pal [ 255 - i ], 3 );
		End;
		CloseFile ( t );
		ShowMessage ( 'done!' );
		{$ENDIF}
	End;
End;

Procedure TFormMain.ImageRefreshPanel;
Begin
	If PanelImage.Tag = 0 Then
	Begin
		PanelImage.Visible := True;
		Image1.Refresh;
		//
		Image1.Picture.Bitmap.Width := Image1.Width;
		Image1.Picture.Bitmap.Height := Image1.Height;
		//
		PanelImage.Tag := 1;
	End;
End;

Procedure TFormMain.ImageUpdateAlignment;
Begin
	PanelImageEditX.Tag := 1;
	PanelImageEditX.Text := Comma ( Image_xr );
	PanelImageEditY.Tag := 1;
	PanelImageEditY.Text := Comma ( Image_yr );
End;

Procedure TFormMain.ImageUpdateSize;
Var
	s : String;
Begin
	s := Comma ( Image_xs ) + ' x ' + Comma ( Image_ys );
	If ImageFormat = fmtPNG Then
	Begin
		s := s + ' [PNG]';
	End;
	LabelImageSize.Caption := s;
End;

Procedure TFormMain.ImageCheckZoomSize;
Begin
	If ( Image_xs < 100 ) And ( Image_ys < 100 ) Then
	Begin
		If ( Image_xs < 30 ) And ( Image_ys < 30 ) Then
		Begin
			UpDownImageZoom.Max := 32;
		End
		Else
			UpDownImageZoom.Max := 16;
	End
	Else
	Begin
		UpDownImageZoom.Max := 10;
	End;
	//
	If UpDownImageZoom.Position > UpDownImageZoom.Max Then
	Begin
		UpDownImageZoom.Position := UpDownImageZoom.Max;
		EditImageZoom.Text := IntToStr ( UpDownImageZoom.Position );
	End;
End;

Function TFormMain.ImageGetZoom : Double;
Var
	Zoom : Double;
Begin
	If mnuImageEdit.Checked Then
	Begin
		Zoom := UpDownImageZoom.Position;
	End
	Else
	Begin
		Zoom := UpDownImageZoom.Position / 2;
		If Zoom <= 0 Then Zoom := 1;
		//If Zoom > 10 Then Zoom := 10;
	End;
	//
	ImageGetZoom := Zoom;
End;

Procedure TFormMain.ImageHideCursor;
Var
	x, y : Integer;
	z : Double;
Begin
	z := ImageGetZoom;
	//
	x := Round ( ImageCurX * z );
	y := Round ( ImageCurY * z );
	//
	With Image1.Canvas Do
	Begin
		Brush.Style := bsSolid;
		Brush.Color := cImage.Canvas.Pixels [ ImageCurX - Image_scroll_x, ImageCurY - Image_scroll_y ];
		//
		FrameRect ( Classes.Rect ( x, y, Round ( x + z ), Round ( y + z ) ) );
	End;
End;

Procedure TFormMain.ImageDrawCursor;
Var
	x, y : Integer;
	z : Double;
	s : String;
Begin
	z := ImageGetZoom;
	//
	x := Round ( ImageCurX * z );
	y := Round ( ImageCurY * z );
	//
	With Image1.Canvas Do
	Begin
		Brush.Style := bsSolid;
		Brush.Color := RGB ( $80, $A0, $C0 );
    FillRect ( Classes.Rect ( Image1.Width - 60, 0, Image1.Width, 100 ) );
    Rectangle ( Image1.Width - 60, 0, Image1.Width, 100 );
		//
    TextOut ( Image1.Width - 50, 2, 'X,Y:' );
		s := IntToStr ( ImageCurX ) + ',' + IntToStr ( ImageCurY );
		TextOut ( Image1.Width - 50, 18, s );
		TextOut ( Image1.Width - 50, 34, IntToStr ( ImagePaletteMatch ( cImage.Canvas.Pixels [ ImageCurX - Image_scroll_x, ImageCurY - Image_scroll_y ] ) ) );
    TextOut ( Image1.Width - 50, 82, IntToStr ( ImageCurColor ) );
		//
		Brush.Color := cImage.Canvas.Pixels [ ImageCurX - Image_scroll_x, ImageCurY - Image_scroll_y ];
		FillRect ( Classes.Rect ( x, y, Round ( x + z ), Round ( y + z ) ) );
		If ( ( Brush.Color And 255 ) < 128 )
		And ( ( Brush.Color Shr 8 And 255 ) < 128 )
		And ( ( Brush.Color Shr 16 And 255 ) < 128 ) Then
		Begin
			Brush.Color := RGB ( 255, 255, 255 );
		End
		Else
		Begin
			Brush.Color := RGB ( 0, 0, 0 );
		End;
		FrameRect ( Classes.Rect ( x, y, Round ( x + z ), Round ( y + z ) ) );
		//
		Brush.Color := PAL [ ImageCurColor ];
		FillRect ( Classes.Rect ( Image1.Width - 50, 50, Image1.Width - 10, 80 ) );
	End;
End;

Procedure TFormMain.ImageDrawPalette;
Var
	x, y : Integer;
	z : Integer;
Begin
	z := Image1.Width Div 32;
	//
	// Erase area on right side
	Image1.Canvas.Brush.Color := RGB ( 0, 0, 0 );
  Image1.Canvas.FillRect ( Classes.Rect ( 32 * z, Image1.Height - 8 * z, Image1.Width, Image1.Height ) );
  //
  For y := 0 To 7 Do
	Begin
		For x := 0 To 31 Do
		Begin
			Image1.Canvas.Brush.Color := PAL [ y * 32 + x ];
			Image1.Canvas.FillRect ( Classes.Rect (
				x * z, Image1.Height - ( 8 - y ) * z,
				x * z + z, Image1.Height - ( 7 - y ) * z ) );
		End;
	End;
End;

procedure TFormMain.mnuImagePNGCheckClick(Sender: TObject);
Var
	i : Integer;
	BytesRead : Integer;
	ChunkLen : Integer;
	ChunkID : Integer;
	ChunkCRC32, CRC32 : DWORD;
	s : String;
begin
	If Not fOpen ( sEditFile ) Then Exit;
	//
	Seek ( f, cPos );
	GetLong2 ( f ); // PNG
	GetLong2 ( f ); // second part of header
	//
	BytesRead := 8;
	//
	(*
	1. The grAb chunk.

		[DWORD]        8 (This chunk is always eight bytes long)
		[DWORD]        grAb
		[Signed DWORD] X Offset
		[Signed DWORD] Y Offset
		[DWORD]        CRC32

		Like PNG files in general, the offsets are big-endian.
		Aside from that, they have the same meaning as a Doom graphic's.

2. The alPh chunk.

		[DWORD]        0 (This chunk has no content)
		[DWORD]        alPh
		[DWORD]        CRC32

		This chunk is only valid for an 8-bit grayscale image.
		If it is present, then the image is treated as an alpha channel.
*)
	//
	ChunkID := 1;
	While ( ChunkID <> $49454E44 ) And ( BytesRead <= cLen ) Do
	Begin
		ChunkLen := GetLong2 ( f );
		//
		GetMem ( PicData, ChunkLen + 4 );
		ChunkID := GetLong2 ( f );
		//
		Inc ( BytesRead, 8 );
		//
		PicData^ [ 0 ] := ChunkID Shr 24 And 255;
		PicData^ [ 1 ] := ChunkID Shr 16 And 255;
		PicData^ [ 2 ] := ChunkID Shr 8 And 255;
		PicData^ [ 3 ] := ChunkID And 255;
		//
		For i := 1 To ChunkLen Do
		Begin
			PicData^ [ i + 3 ] := GetByte ( f );
			Inc ( BytesRead );
		End;
		//
		ChunkCRC32 := GetLong2 ( f ); // CRC32
		Inc ( BytesRead, 4 );
		//
		CRC32 := $FFFFFFFF; // To match PKZIP
		CalcCRC32 ( PicData, ChunkLen + 4, CRC32 );
		CRC32 := not CRC32;
		//
		s := s +
			Chr ( ChunkID Shr 24 And 255 ) +
			Chr ( ChunkID Shr 16 And 255 ) +
			Chr ( ChunkID Shr 8 And 255 ) +
			Chr ( ChunkID And 255 ) + ' - ' +
			IntToHex ( ChunkID, 8 ) + ' - ' +
			IntToHex ( ChunkCRC32, 8 ) + '-' + IntToHex ( CRC32, 8 ) + #13;
		//
		FreeMem ( PicData, ChunkLen + 4 );
		//
	End;
	//
	ShowMessage ( s );
	fClose;
end;

Procedure TFormMain.ImageEditor;

Var
	iPos, iLen : Longint;
	iFS, iFE : Integer;
	xs, ys, xr, yr : Integer; // 32 bit
	Format : TImageFormat;
	WFormat : TWaveFormat;
	MFormat : TMusicFormat;

Begin
	iPos := cPos;
	iLen := cLen;
	//
	Format := ImageIdentifyFile ( sEditFile, iPos, iLen, xs, ys, xr, yr );
	//
	If Format = fmtNone Then
	Begin
		//
		WFormat := WaveIdentifyFile ( sEditFile, iPos, iLen );
		//
		If WFormat = wfmtNone Then
		Begin
			//
			MFormat := MusicIdentifyFile ( sEditFile, iPos, iLen );
			//
			If MFormat = mfmtNone Then
			Begin
				//
				HexDump;
				//
			End
			Else
			Begin
				iWadEntryDetected := FindTypeIndex ( 'MUS' );
				MusEditor;
			End;
		End
		Else
		Begin
			iWadEntryDetected := FindTypeIndex ( 'WAVESOUND' );
			WaveEditor;
		End;
		//
	End
	Else
	Begin
		//
		mnuImagePNGCheck.Visible := ( Format = fmtPNG );
		ImageOnlyAlignmentModified := True;
		//
		ImageCurX := 0;
		ImageCurY := 0;
		Image_scroll_x := 0;
		Image_scroll_y := 0;
		ImageCurColor := 0;
		//
		// --- Hide image browser
		//
		If PanelImageArt.Visible Then
		Begin
			ImageShowMulti ( False );
			//
			PanelImage.Tag := 0;
		End;
		//
		// --- Hide remap panel
		//
		If PanelImageRemap.Visible Then
		Begin
			ImageSplitterRemap.Visible := False;
			PanelImageRemap.Visible := False;
			//
			PanelImage.Tag := 0;
			//
			mnuImageColorRemap.Checked := False;
		End;
		//
		PreparePalette;
		ImageRefreshPanel;
		//
		{$IFDEF FULLVERSION}
		If FileType = LGRESFile Then
		Begin
			// Go to first image.
			Image_SubIndex := 1;
			ImageArtGrid.Row := 1;
		End;
		{$ENDIF}
		//
		ImageLoad ( sEditFile, iPos, iLen, xs, ys, xr, yr, Format );
		//
		If nImgs > 1 Then
			ImageShowMulti ( True );
		//
		If Format = fmtFloor Then
		Begin
			iWadEntryDetected := FindTypeIndex ( 'FLOOR' );
		End
		Else
		Begin
			If sListWadFilter = 'PATCH' Then
				iWadEntryDetected := FindTypeIndex ( 'PATCH' )
			Else
			Begin
				iFS := 0;
				iFE := 0;
				If ( WadEntries [ iSel ].EntryType = 0 ) Then
				Begin
					iFS := FindEntry ( 'S*_START' );
					iFE := 0;
					//
					If iFS <> 0 Then
						iFE := FindEntry ( 'S*_END' );
				End;
				//
				If ( iSel > iFS ) And ( iSel < iFE ) Then
				Begin
					iWadEntryDetected := FindTypeIndex ( 'SPRITE' );
				End
				Else
				Begin
					iWadEntryDetected := FindTypeIndex ( 'IMAGE' );
				End;
			End;
		End;
		//
		ImageUpdateSize;
		//
		ImageUpdateAlignment;
		//
		ImageRenderCurrent;
		//
		ShowPage ( edImage );
		//
		Modified ( False );
	End;

	{

	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( F, iPos );

	//

	If iLen = 4096 Then
	Begin

		xs := 64;
		ys := 64;

		ImageResetCurrent ( xs, ys );
		Image_xr := 0;
		Image_yr := 0;

		LabelImageSize.Caption := Comma ( xs ) + ' x ' + Comma ( ys );

		// Load Data

		GetMem ( PicData, iLen );
		BlockRead ( F, PicData^, iLen );
		fClose;

		// extract floor image

		For y := 0 To ys - 1 Do
		Begin
			For x := 0 To xs - 1 Do
			Begin
				b := PicData^ [ y * ys + x ];
				SetPixel ( cImage.Canvas.Handle, x, y, Pal [ b ] );
			End;
		End;

		FreeMem ( PicData, iLen );

		ImageRenderCurrent;

		//
		ShowPage ( 2 );
		Finished;

	End
	Else
	Begin

		fClose;

		If Not ImageGetDetails ( iSel, xs, ys, xr, yr ) Then
		Begin
			Finished;
			HexDump;
		End
		Else
		Begin

			PanelImageEditX.Text := Comma ( xr );
			PanelImageEditY.Text := Comma ( yr );

			LabelImageSize.Caption := Comma ( xs ) + ' x ' + Comma ( ys );

			If Not ImageLoad_Old ( iSel, Nil, xr, yr, Zoom ) Then
			Begin
				Finished;
				HexDump;
			End
			Else
			Begin
				ShowPage ( 2 );
				Finished;
			End;
		End;
	End;
	}
End;

// returns the index and list position index of the new entry
// if we have a selection, it goes after it
// otherwise after the last in the current (possibly filtered) list
procedure TFormMain.WadEntryNewGetPos ( Var iEntry, iListEntry : Integer );
Var
	sStart : String;
Begin
	sStart := '';
	//
	If ListWad.Selected = Nil Then
	Begin
		iListEntry := ListWad.Items.Count;
		If iListEntry = 0 Then
		Begin
			If sListWadFilter = 'PATCH' Then
			Begin
				sStart := 'P*_START';
			End;
			//
			If sListWadFilter = 'FLOOR' Then
			Begin
				sStart := 'F*_START';
			End;
			//
			If sListWadFilter = 'SPRITE' Then
			Begin
				sStart := 'S*_START';
			End;
			//
			If sStart <> '' Then
			Begin
				iEntry := FindEntry ( sStart );
				If iEntry = 0 Then
					iEntry := nWadEntries + 1
				Else
					Inc ( iEntry );
			End
			Else
			Begin
				iEntry := nWadEntries + 1;
			End;
		End
		Else
		Begin
			iEntry := EntryGetIndex ( iListEntry - 1 ) + 1;
		End;
	End
	Else
	Begin
		iEntry := EntryGetIndex ( ListWad.Selected.Index ) + 1;
		iListEntry := ListWad.Selected.Index + 1;
	End;
End;

procedure TFormMain.WadEntryNew ( sName : String );
Begin
	WadEntryNewAtPos ( sName, nWadEntries + 1, ListWad.Items.Count, False );
End;

Procedure TFormMain.ReWriteDirectory ( bWriteToEnd : Boolean );
Var
	i, iFS : Integer;
	bRewriteDirectory : Boolean;
Begin
	If iWadDirPos = 0 Then
	Begin
		// file was empty, this is the first entry
		bRewriteDirectory := True;
	End
	Else
	Begin
		i := 1;
		bRewriteDirectory := bWriteToEnd;
		While Not bRewriteDirectory and ( i <= nWadEntries ) Do
		Begin
			If WadEntries [ i ].Position > iWadDirPos Then
			Begin
				bRewriteDirectory := True; // Directory is not at the end.
			End
			Else
			Begin
				Inc ( i );
			End;
		End;
	End;
	//
	If fOpen ( sFileName ) Then
	Begin
		iFS := FileSize ( f );
		//
		If iWadDirPos + ( nWadEntries - 1 ) * ( 4 + 4 + 8 ) <> iFS Then
		Begin
			bRewriteDirectory := True; // re-write at end
		End;
		//
		Seek ( f, FileSize ( f ) );
		//
		if bRewriteDirectory then
		Begin
			iWadDirPos := FileSize ( f );
			For i := 1 To nWadEntries Do
			Begin
				SendWadEntryFromArray ( f, i );
			End;
			Seek ( f, 8 );
			SendLong ( f, iWadDirPos ); // Write New Directory position
		End
		else
		Begin
			SendWadEntryFromArray ( f, nWadEntries );
		End;
		//
		Seek ( f, 4 );
		SendLong ( f, nWadEntries ); // Write New number of entries
		//
		fClose;
	End
	Else
	Begin
		ShowMessage ( 'Internal error: Could not write new entry to file.' );
	End;
End;

procedure TFormMain.WadEntryNewAtPos ( sName : String; iEntry, iListEntry : Integer; bDontUpdateDirectory : Boolean );
Var
	i : Integer;
	bRefreshFullList : Boolean;
Begin
	//
	// *** Create New Entry in our array ***
	//
	Inc ( nWadEntries );
	//
	bRefreshFullList := iEntry <> nWadEntries;
	//
	If bRefreshFullList Then
	Begin
		// push down rest of the entries
		For i := nWadEntries - 1 DownTo iEntry Do
		Begin
			WadEntries [ i + 1 ] := WadEntries [ i ];
		End;
	End;
	//
	If sName = '' Then sName := 'UNTITLED';
	If Not gDontAutoCapitalize Then
	Begin
		sName := UpperCase ( sName );
	End;
	WadEntries [ iEntry ].Name := Copy ( sName, 1, 8 );
	WadEntries [ iEntry ].Position := 0;
	WadEntries [ iEntry ].Size := 0;
	WadEntries [ iEntry ].EntryType := 0;
	//
	WadEntryIdentify ( iEntry );
	//
	// *** Write to the file ***
	//
	If Not bDontUpdateDirectory Then
	Begin
		ReWriteDirectory ( bRefreshFullList );
		UpdateModifiedDate;
	End;
	//
	// *** Display on screen ***
	//
	If iListEntry > -1 Then
	Begin
		ListWad.Items.Insert ( iListEntry );
		UpdateWadEntry ( iListEntry, iEntry );
		//
		If bRefreshFullList Then
		Begin
			For i := iListEntry + 1 To ListWad.Items.Count - 1 Do
			Begin
				If EntryGetIndex ( i ) >= iEntry Then
				Begin
					UpdateWadEntry ( i, EntryGetIndex ( i ) + 1 );
				End;
			End;
		End;
	End;
End;

{
Procedure TFormMain.AddNewWadEntry ( sName : String );
Begin
	WadEntryNew ( sName );
	//
	If ListWad.Selected <> Nil Then
	Begin
		ListWad.Selected.Selected := False;
	End;
	//
	With ListWad.Items [ ListWad.Items.Count - 1 ] Do
	Begin
		MakeVisible ( False );
		Focused := True;
		Selected := True;
	End;
	ListWad.SetFocus;
End;
}

// ###########################################################################
//
//

Procedure TFormMain.PatchNamesForceLoad;
Var
	PatchIndex : Integer;
Begin
	//
	// load
	//
	nPatches := 0;
	//
	PatchIndex := FindEntry ( 'PNAMES' );
	If PatchIndex > 0 Then
	Begin
		PatchNamesLoad ( PatchIndex );
	End
	Else
	Begin
		//
		PatchIndex := FindEntryInMain ( 'PNAMES' );
		//
		If PatchIndex > 0 Then
		Begin
			//
			CopyEntryFromMain ( PatchIndex );
			UpdateWadEntry ( ListWad.Items.Count - 1, nWadEntries );
			WadEntryIdentify ( nWadEntries );
			//
			PatchIndex := nWadEntries;
			PatchNamesLoad ( PatchIndex );
		End
		Else
		Begin
			// Create New PNAMES entry
			WadEntryNew ( 'PNAMES' );
			PatchIndex := nWadEntries;
		End;
	End;
	//
	main_PIndex := PatchIndex;
end;

procedure TFormMain.mnuPL_AddtoPNamesClick(Sender: TObject);
Var
	i, Index, iCount : Integer;
	s : String;
Begin
	Starting;
	//
	SaveUndo ( 'Add Patch Names' );
	//
	PatchNamesForceLoad;
	//
	// --- Add them
	//
	iCount := 0;
	For i := 0 To ListWad.Items.Count - 1 Do
	Begin
		If ListWad.Items [ i ].Selected Then
		Begin
			Index := EntryGetIndex ( i );
			s := WadEntries [ Index ].Name;
			//
			If PatchFind ( s ) < 0 Then
			Begin
				//
				// --- Add PatchName
				//
				Inc ( nPatches );
				Inc ( iCount );
				Patches [ nPatches - 1 ].Name := s;
				Patches [ nPatches - 1 ].Loaded := False;
			End;
		End;
	End;
	//
	PatchNamesSaveData;
	ReplaceFile ( main_PIndex, sTempFile, False, True );
	//
	Finished;
	Status ( 'Added ' + Comma ( iCount ) + ' Patch Names' );
end;

procedure TFormMain.PatchNamesListChange(Sender: TObject);
Begin
	Modified ( True );
end;

procedure TFormMain.mnuPatchNamesSaveClick(Sender: TObject);
Begin
	PatchNamesSave;
end;

Function TFormMain.PatchNamesSave : Boolean;
Begin
	If PatchNamesSaveFromList Then
	Begin
		//
		ReplaceFile ( iSel, sTempFile, True, True );
		//
		PatchNamesLoad ( iSel );
		//
		Modified ( False );
		UpdateModifiedDate;
		//
		PatchNamesSave := True;
	End
	Else
	Begin
		PatchNamesSave := False;
	End;
End;

Function TFormMain.PatchNamesSaveData : Boolean;
Var
	i : Longint;
Begin
	fOpenTemp;
	//
	SendLong ( fo, nPatches );
	//
	For i := 0 To nPatches - 1 Do
	Begin
		SendString8 ( fo, Patches [ i ]. Name );
	End;
	//
	CloseFile ( fo );
	//
	PatchNamesSaveData := True;
End;

Function TFormMain.PatchNamesSaveFromList : Boolean;
Var
	i : Longint;
	s : String;
Begin
	fOpenTemp;
	//
	nPatches := 0;
	For i := 0 To PatchNamesList.Lines.Count Do
	Begin
		If Trim ( Copy ( PatchNamesList.Lines.Strings [ i ], 1, 8 ) ) <> '' Then
			Inc ( nPatches );
	End;
	//
	SendLong ( fo, nPatches );
	//
	For i := 0 To nPatches - 1 Do
	Begin
		s := Trim ( Copy ( PatchNamesList.Lines.Strings [ i ], 1, 8 ) );
		If s <> '' Then
		Begin
			SendString8 ( fo, s );
		End;
	End;
	//
	CloseFile ( fo );
	//
	PatchNamesSaveFromList := True;
End;

procedure TFormMain.PatchNamesEditor ( bFocus : Boolean );
Var
	i : Longint;
Begin
	Starting;
	PatchNamesLoad ( iSel );
	//
	PatchNamesList.Visible := False;
	PatchNamesList.Lines.Clear;
	//
	For i := 0 To nPatches - 1 Do
	Begin
		PatchNamesList.Lines.Add ( Patches [ i ].Name + ' : ' + Comma ( i ) );
	End;
	//
	PatchNamesCount.Text := Comma ( nPatches ) + ' patches';
	//
	PatchNamesList.Visible := True;
	//
	ShowPage ( edPatchNames );
	Finished;
	//
	Modified ( False );
	//
	If bFocus Then
	Begin
		PatchNamesList.SetFocus;
	End;
End;

procedure TFormMain.EditQuickFindChange(Sender: TObject);
Var
	s, s2 : String;
	l : Integer;
	i : Longint;
Begin
	s := UpperCase ( EditQuickFind.Text ); // Get the user's string from screen
	l := Length ( s ); // get Length

	// check for empty string
	If l > 0 Then
	Begin

		i := -1; // start at beginning of the listbox
		s2 := '';

		// exit from loop if found
		While s <> Copy ( s2, 1, l ) Do
		Begin

			Inc ( i );
			If ( i >= nWadEntries ) Or ( i >= ListWad.Items.Count ) Then
			Begin
				i := 0; // not found, go to top
				s2 := s;
			End
			Else
			Begin
				s2 := UpperCase ( ListWad.Items.Item [ i ].Caption );
			end;

		end;

		// did we find it?
		If ( i < nWadEntries ) And ( i < ListWad.Items.Count ) Then
		Begin
			ListWad.Items.Item [ i ].MakeVisible ( True ); // yes, select the item
			ListWad.Items.Item [ i ].Focused := True;
		End;
	End;
end;

Procedure TFormMain.HexDump;
Var
	I, iLines, iZeros : Integer;
	s : String;
	b, pb : Byte;
	bStop : Boolean;

	xLen : Integer;
	x : Array [ 0 .. 1023 ] Of Char;

Function IsAscii : Boolean;

Var
	cnt : Integer;
	ok : boolean;

Function IsAsciiChar ( c : Char ) : Boolean;
Begin
	IsAsciiChar :=
		( c = #9 ) Or
		( c = #10 ) Or
		( c = #13 ) Or
		( ( c >= #32 ) And ( c <= #127 ) );
End;

Begin
	// check first 256 bytes only
	xLen := 256;
	If cLen < xLen Then xLen := cLen;
	BlockRead ( F, x [ 0 ], xLen );
	//
	// go back to beginning
	Seek ( F, cPos );
	//
	cnt := 0;
	ok := True;
	//
	While Ok and ( Cnt < xLen ) Do
	Begin
		Ok := IsAsciiChar ( x [ cnt ] );
		Inc ( cnt );
	End;
	//
	IsAscii := ok;
End;

Begin
	//
	If Not fOpen ( sEditFile ) Then Exit;
	//
	Starting;
	//
	MemoHex.Clear;
	ShowPage ( edNone );
	//
	If fSeek ( F, cPos ) Then
	Begin
		//
		iLines := 0; // count lines
		//
		If iWadEntryCurrentPos <> iWadEntryLastPos Then
		Begin
			// auto detect ascii files
			If IsAscii Then
			Begin
				If iHexView <> 0 Then
				Begin
					HexViewChange ( 0 ); // switch to ascii
				End;
			End
			Else
			Begin
				If iHexView = 0 Then
				Begin
					HexViewChange ( 1 ); // switch to data
				End;
			End;
		End;
		//
		If cLen > 0 Then
		Begin
			//
			If ( iHexView = 0 ) Then
			Begin
				//
				// *** Ascii Text Dump ***
				//     (save possible)
				//
				MemoHex.ScrollBars := ssBoth;
				//
				s := '';
				i := 0;
				//
				pb := 0;
				//
				While i < cLen Do
				Begin
					b := GetByte ( f );
					//
					If ( ( b = 10 ) And ( pb <> 13 ) )
					Or ( b = 13 ) Then
					Begin
						MemoHex.Lines.Add ( s );
						Inc ( iLines );
						s := '';
					End
					Else
					Begin
						If ( b <> 10 ) And ( b <> 13 ) Then
							s := s + Chr ( b );
					End;
					//
					pb := b;
					//
					Inc ( i, 1 );
				End;
				//
				If s <> '' Then
				Begin
					MemoHex.Lines.Add ( s );
					Inc ( iLines );
				End;
				//
			End
			Else
			Begin
				//
				// *** DATA DUMP ***
				//     (can't save)
				//
				If cLen > $2000 Then cLen := $2000;
				//
				MemoHex.ScrollBars := ssVertical;
				//
				iZeros := 2;
				If cLen > $FF Then
				Begin
					iZeros := 4;
					If cLen > $FFFF Then
					Begin
						iZeros := 6;
					End;
				End;
				//
				i := 0;
				bStop := False;
				//
				While ( i < cLen ) And Not bStop Do
				Begin
					//
					If ( i Mod 16 ) = 0 Then
					Begin
						s := IntToHex ( FilePos ( f ) - cPos, iZeros ) + ': ';
					End;
					//
					Case iHexView Of
						1 :
						Begin
							s := s + IntToHex ( Byte ( GetByte ( f ) ), 2 ) + ' ';
							Inc ( i );
						End;
						//
						2 :
						Begin
							//
							if ( i + 1 ) = cLen Then
								s := s + IntToHex ( Byte ( GetByte ( f ) ), 2 )
							Else
								s := s + IntToHex ( Word ( GetWord ( f ) ), 4 );
							//
							Inc ( i, 2 );
							//
							If ( i Mod 16 ) <> 0 Then
							Begin
								s := s + ' ';
							End;
						End;
						//
						3 :
						Begin
							b := Byte ( GetByte ( f ) );
							If b < 32 Then
								s := s + '.'
							Else
								s := s + Chr ( b );
							Inc ( i );
						End;
						//
					End;
					//
					If ( i Mod 16 ) = 0 Then
					Begin
						MemoHex.Lines.Add ( s );
						Inc ( iLines );
						s := '';
					End;
					//
					If MemoHex.Lines.Count < iLines Then
					Begin
						bStop := True; // already truncated
					End;
				End;
				//
				If s <> '' Then
				Begin
					MemoHex.Lines.Add ( s );
					Inc ( iLines );
				End;
				//
			End;
		End;
		//
		If MemoHex.Lines.Count < iLines Then
		Begin
			Status ( 'Truncated ' + Comma ( MemoHex.Lines.Count ) + ' out of ' + Comma ( iLines ) + ' lines.' );
			//
			mnuHexSave.Enabled := False;
			//
		End
		Else
		Begin
			mnuHexSave.Enabled := iHexView = 0;
		End;
	End;
	//
	fClose;
	//
	ShowPage ( edHex );
	//
	Finished;
	//
	Modified ( False );
End;

procedure TFormMain.mnuPL_NoFilterClick(Sender: TObject);
Begin
	// Clear the filter string
	sListWadFilter := '';
	// Refresh view - all entries will be shown
	ShowWadEntries;
end;

procedure TFormMain.mnuPL_FilterClick(Sender: TObject);
Begin
	// Use the latest filter string
	// (updated at right-clicking)
	sListWadFilter := sListWadNewFilter;
	// Refresh
	ShowWadEntries;
end;

procedure TFormMain.mnuPL_FilterSubClick(Sender: TObject);
Var
	s : String;
begin
	s := Replace ( TMenuItem(Sender).Caption, '&', '' );
	if UpperCase ( Copy ( s, 1, 9 ) ) <> 'SHOW ONLY' Then
	Begin
		//
		If Pos ( ')', s ) > 0 Then
			s := Trim ( RemoveFromLeft ( s, Pos ( ')', s ) ) );
		//
		// apply filter
		sListWadFilter := s;
		// Refresh view
		ShowWadEntries;
	End;
end;

procedure TFormMain.ListWadUpdateFilter;
Var
	i, iEntryType : Integer;
	s : String;
Begin
	If ListWad.Selected = NIL Then
	Begin
		mnuPL_Filter.Visible := False;
	End
	Else
	Begin
		i := ListWad.Selected.Index;
		i := EntryGetIndex ( i );
		//
		iEntryType := WadEntries [ i ].EntryType;
		//
		If ( iEntryType < 1 ) Or ( iEntryType > nWadEntryTypes ) Then
			s := ''
		Else
			s := WadEntryTypes [ iEntryType ].Description;
		//
		If s = '' Then
		Begin
			sListWadNewFilter := ' '; // special
			mnuPL_Filter.Caption := 'Show only unidentified';
			mnuPL_Filter.Visible := True;
		End
		Else
		Begin
			sListWadNewFilter := s;
			mnuPL_Filter.Caption := 'Show only ' + s;
			mnuPL_Filter.Visible := True;
		End;
	End;
End;

procedure TFormMain.ListWadKeyPress(Sender: TObject; Var Key: Char);
Begin
	If Key = #13 Then
	Begin
		Key := #0;
		ShowEntry ( '', True );
	End;
end;

procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	Case Key Of

  	88 : // shift + x
		Begin
			(*
			If ( ssShift in Shift ) Then
			Begin
				ShowMessage (  IntToStr ( WadEntries [ EntryGetIndex ( ListWad.ItemFocused.Index ) ].Position ) );
			End;
			*)
		End;

		34 : // PageDown
		Begin
			If ( ssAlt in Shift ) Then
			Begin
				If ListWad.ItemFocused <> NIL Then
				Begin
					ListWad.Items [ ListWad.ItemFocused.Index + 1 ].Focused := True;
				End;
			End;
		End;

		48 :
		Begin
			If ( ssCtrl in Shift ) Then
				tbFilterAllClick ( Sender );
		End;

		49 : Begin If ( ssCtrl in Shift ) Then tbFilterClick ( tbFilterLumps ); End;
		50 : Begin If ( ssCtrl in Shift ) Then tbFilterClick ( tbFilterGfx ); End;
		51 : Begin If ( ssCtrl in Shift ) Then tbFilterClick ( tbFilterSprites ); End;
		52 : Begin If ( ssCtrl in Shift ) Then tbFilterClick ( tbFilterSounds ); End;
		53 : Begin If ( ssCtrl in Shift ) Then tbFilterClick ( tbFilterMusic ); End;
		54 : Begin If ( ssCtrl in Shift ) Then tbFilterClick ( tbFilterMaps ); End;
		55 : Begin If ( ssCtrl in Shift ) Then tbFilterClick ( tbFilterTextures ); End;
		56 : Begin If ( ssCtrl in Shift ) Then tbFilterClick ( tbFilterPatches ); End;
		57 : Begin If ( ssCtrl in Shift ) Then tbFilterClick ( tbFilterFloors ); End;

		122 : // F11
		Begin
			mnuViewMenuBarClick ( Sender );
		End;

		Else
			Caption := Comma ( Key );

	End;
end;

procedure TFormMain.ListWadKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
Var
	i : Integer;
	s, s1, s0 : String;
begin
	Case Key Of

		27 : { ESC }
		Begin
			mnuWaveStopClick ( Sender );
		End;

		46 : { DEL }
		Begin
			mnuEntryDeleteClick ( Sender );
		End;

		65 : // A
		Begin
			If ( ssCtrl in Shift ) And Not ( ssShift in Shift ) Then
			Begin
				// CTRL + A
				// Select All
				For i := 0 To ListWad.Items.Count - 1 Do
				Begin
					ListWad.Items [ i ].Selected := True;
				End;
			End;
		End;

		67 : // C
		Begin
			If ( ssCtrl in Shift ) Then
			Begin
				If Not ( ssShift in Shift ) Then
				Begin
					// CTRL + C
					mnuEditCopyClick ( Sender );
				End
				Else
				Begin
					// List all entries in one line
					// removing duplicates
					s := 'Entry: "';
					For i := 0 To ListWad.Items.Count - 1 Do
					Begin
						s1 := Trim ( ListWad.Items [ i ].Caption );
						If s1 <> s0 Then
						Begin
							If s <> '' Then s := s + ';';
							s := s + s1;
						End;
						s0 := s1;
					End;
					s := s + '"';
					InputBox ( '', '', s );
				End;
			End;
		End;

		86 : // V
		Begin
			If ( ssCtrl in Shift ) And Not ( ssShift in Shift ) Then
			Begin
				// CTRL + V
				mnuEditPasteClick ( Sender );
			End;
		End;

		88 : // X
		Begin
			If ( ssCtrl in Shift ) And Not ( ssShift in Shift ) Then
			Begin
				// CTRL + X
				mnuEditCutClick ( Sender );
			End;
		End;

		113 : { F2 }
		Begin
			mnuEntryRenameClick ( Sender );
		End;

		114 : { F3 }
		Begin
			EditQuickFind.SetFocus;
		End;

	End;
	FormKeyDown ( Sender, Key, Shift );
end;

procedure TFormMain.ListWadMouseUp(Sender: TObject; Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
begin
	//Caption := Caption + ' ^';
end;

procedure TFormMain.ListWadMouseDown(Sender: TObject; Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
begin
	//Caption := Caption + ' V';
end;

procedure TFormMain.ListWadSelectItem(Sender: TObject; Item: TListItem;
	Selected: Boolean);
Begin
	WarnFileExtModified;
	{
	Caption := Caption + ' |' + IntToStr ( Item.Index );
	Caption := Caption + '-' + IntToStr ( iWadEntryCurrentPos );
	If bSelectItemCancel Then
	Begin
		Caption := Caption + '/' + IntToStr ( iSelectItemCancel );
	End;
	If Selected Then
		Caption := Caption + 's'
	Else
		Caption := Caption + 'u';
	If Selected And Not Item.Selected Then
		Caption := Caption + '!';
	}
	//
	If Selected Then
	Begin
		If bSelectItemCancel Then
		Begin
			If Item.Index = iSelectItemCancel Then
			Begin
				//ListWad.Items [ iWadEntryCurrentPos ].Focused := True;
				Item.Selected := False;
				//
				bSelectItemCancel := False;
				iSelectItemCancel := 0;
				//Caption := Caption + ' |uns';
			End
			Else
			Begin
				ListWad.Items [ iSelectItemCancel ].Selected := False;
				ListWad.Items [ Item.Index ].Selected := False;
				//
				ListWad.Items [ iWadEntryCurrentPos ].Focused := True;
			End;
		End
		Else
		Begin
			//
			ListWad.Perform ( WM_LBUTTONUP, 0, 0 );
			Application.ProcessMessages;
			//
			If Not CheckModified Then
			Begin
				//
				If iWadEntryCurrentPos <> Item.Index Then
				Begin
					//
					//  Cancel selection change
					//
					bSelectItemCancel := True;
					iSelectItemCancel := Item.Index; // remember the one we need to unselect
					//
					// click back on original, will trigger another SelectItem
					ListWad.Items [ iWadEntryCurrentPos ].Selected := True;
				End;
			End
			Else
			Begin
				ListWadUpdateFilter;
				UpdateSelection;
				//
				ShowEntry ( '', False );
			End;
		End;
	End;
end;

procedure TFormMain.EditQuickFindKeyPress(Sender: TObject; Var Key: Char);
Begin
	If Key = #13 Then
	Begin
		Key := #0;
		If mnuViewEntryList.Checked And ListWad.Visible Then
		Begin
			ListWad.SetFocus;
			If ( ListWad.Selected <> NIL ) Then
			Begin
				ListWad.Selected.Selected := False;
			End;
			If ( ListWad.ItemFocused <> NIL ) Then
			Begin
				ListWad.ItemFocused.Selected := True;
			End;
		End;
	End;
end;

// ############################################################################

Function TFormMain.PointInPolygon ( Polygon : TPolygon; n : Integer; p : TPoint ) : Boolean;
Var
	Counter, i : Integer;
	xIntersection : Double;
	p1, p2 : TPoint;
Begin
	//
	Counter := 0;
	p1 := Polygon [ 0 ];
	//
	For i := 1 To n Do
	Begin
		//
		p2 := Polygon [ i Mod n ];
		//
		If ( p.y > MIN ( p1.y, p2.y ) ) Then
		Begin
			If ( p.y <= MAX ( p1.y, p2.y ) ) Then
			Begin
				If ( p.x <= MAX ( p1.x, p2.x ) ) Then
				Begin
					If ( p1.y <> p2.y ) Then
					Begin
						xIntersection := ( p.y - p1.y ) * ( p2.x - p1.x ) / ( p2.y - p1.y ) + p1.x;
						If ( ( p1.x = p2.x ) Or ( p.x <= xIntersection ) ) Then
							Inc ( counter );
					End;
				End;
			End;
		End;
		//
		p1 := p2;
		//
	End;
	//
	PointInPolygon := ( Counter Mod 2 <> 0 );
End;

// ############################################################################
// MAP EDITOR
//

Procedure TFormMain.MapTexturesRefresh;
Var
	i : Integer;
Begin
	TextureInit;
	//
	MapListTextures.Items.Clear;
	//
	For i := 1 To nTextures Do
	Begin
		MapListTextures.Items.Add ( Textures [ i ].Name );
	End;
End;

procedure TFormMain.MapListTexturesKeyPress(Sender: TObject;
	var Key: Char);
Var
	xs, ys : Integer;
begin
	If Key = #13 Then
	Begin
		Key := #0;
		//
		iTexture_xc := 20;
		iTexture_yc := 20;
		//
		xs := Textures [ MapListTextures.ItemIndex + 1 ].xs;
		ys := Textures [ MapListTextures.ItemIndex + 1 ].ys;
		//
		ImageMap.Canvas.Brush.Color := RGB ( 80, 100, 120 );
		ImageMap.Canvas.FillRect ( Classes.Rect ( 10, 10, 20 + xs * 2 + 10, 20 + ys * 2 + 10 ) );
		TextureDrawCanvas ( MapListTextures.ItemIndex + 1, 2, ImageMap.Canvas );
		//
		ImageMap.Canvas.TextOut ( 20, 10-2, IntToStr ( xs ) + ' * ' + IntToStr ( ys ) );
	End;
end;

//
// --- perform a lookup on the texture list
//

procedure TFormMain.MapEditQuickFindChange(Sender: TObject);
var
	i : Integer;
	b : Boolean;
	s : String;
begin
	i := 0;
	b := False;
	//
	s := UpperCase ( Trim ( MapEditQuickFind.Text ) );
	//
	With MapListTextures.Items Do
	Begin
		// go through all
		While ( i < Count - 1 ) And Not b Do
		Begin
			// match?
			If BeginsWith ( UpperCase ( Strings [ i ] ), s ) Then
			Begin
				// yes, stop here
				b := True;
				MapListTextures.ItemIndex := i;
			End
			Else
				Inc ( i );
		End;
	End;
end;

procedure TFormMain.MapEditQuickFindKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	Case Key Of

		38, 40 :
		Begin
			MapListTextures.SetFocus;
		End;

	End;
end;

Procedure TFormMain.MapFlatsInit;

Var
	iEntry : Integer;
	bStop : Boolean;
	i1, i2, b : Integer;
	x : TFlat;

Procedure AddFlat ( sFlat : String; bLocal : Boolean );
Var
	i : Integer;
	bDuplicate : Boolean;
Begin
	bDuplicate := False;
	i := 0;
	While i < nFlats Do
	Begin
		If Flats [ i ].Name = sFlat Then
		Begin
			bDuplicate := True;
			i := nFlats;
		End;
		Inc ( i );
	End;
	//
	If Not bDuplicate Then
	Begin
		Inc ( nFlats );
		Flats [ nFlats ].Name := sFlat;
		Flats [ nFlats ].Local := bLocal;
	End;
End;

Begin
	//
	nFlats := 0;
	//
	iEntry := FindEntryInMain ( 'F_START' );
	//
	If iEntry > 0 Then
	Begin
		//
		// Find all textures in Main WAD
		//
		bStop := False;
		While Not bStop Do
		Begin
			If Trim ( MainWadEntries [ iEntry ].Name ) = 'F_END' Then
			Begin
				bStop := True;
			End
			Else
			Begin
				If MainWadEntries [ iEntry ].Size = 64 * 64 Then
				Begin
					AddFlat ( UpperCase ( Trim ( MainWadEntries [ iEntry ].Name ) ), False );
				End;
				//
				Inc ( iEntry );
				If iEntry > nMainWadEntries Then
					bStop := True;
			End;
		End;
	End;
	//
	// ---
	//
	iEntry := FindEntry ( 'F*_START' );
	//
	If iEntry > 0 Then
	Begin
		//
		// Find all textures in Main WAD
		//
		bStop := False;
		While Not bStop Do
		Begin
			If MatchName ( Trim ( WadEntries [ iEntry ].Name ), 'F*_END' ) Then
			Begin
				bStop := True;
			End
			Else
			Begin
				If ( WadEntries [ iEntry ].Size = 64 * 64 )
				Or ( WadEntries [ iEntry ].Size = 128 * 128 )
				Or ( WadEntries [ iEntry ].Size = 256 * 256 ) Then
				Begin
					AddFlat ( UpperCase ( Trim ( WadEntries [ iEntry ].Name ) ), True );
				End;
				//
				Inc ( iEntry );
				If iEntry > nWadEntries Then
					bStop := True;
			End;
		End;
	End;
	//
	// --- Sort Flats
	//
	For i1 := nFlats DownTo 2 Do
	Begin
		b := 1;
		For i2 := 2 To i1 Do
		Begin
			If Flats [ b ].Name < Flats [ i2 ].Name Then
				b := i2;
		End;
		//
		x := Flats [ i1 ];
		Flats [ i1 ] := Flats [ b ];
		Flats [ b ] := x;
	End;
	//
End;

Procedure TFormMain.MapRenderVertex ( x, y : Integer );
Begin
	ImageMap.Canvas.Rectangle ( x - 1, y - 1, x + 2, y + 2 );
End;

// ###########################################################################
//
// Map Refresh - paints the current view of the map
//
// ###########################################################################

Procedure TFormMain.MapRefresh;
Var
	i, iLen : Integer;
	x, y, x0, x2, y2 : Integer;
	xc, yc : Integer;
	xp, yp : Integer;
	mx, my : Integer;
	Grid, iFGrid : Integer;
	s : String;
	//
	iBotF, iTopF, iBotB, iTopB : Integer;
	//

{
PROCEDURE DrawLine(X1, Y1, X2, Y2: Integer);
VAR
	Error, DXtimes2, DYtimes2: Integer;
	Count: Integer;
BEGIN
	DYtimes2 := (Y2 - Y1) SHL 1;
	DXtimes2 := (X2 - X1) SHL 1;
	Error := X1 - X2;
	FOR Count := X1 TO X2 DO
	BEGIN
		PutPixel(Count, Y1, White);
		Error := Error + DYtimes2;
		IF Error > 0 THEN
		BEGIN
			Y1 := Y1 + 1;
			Error := Error - DXtimes2
		END
	END
END;
}

Procedure RenderVertex ( iVertex : Integer );
Begin
	x := Vertex [ iVertex ]. x;
	y := Vertex [ iVertex ]. y;
	//
	CoordsMapToScreen ( x, y );
	//
	If ( ( x > 0 ) And ( x < mx ) And ( y > 0 ) And ( y < my ) ) Then
	Begin
		//
		If Vertex [ iVertex ].Highlighted Then
		Begin
			ImageMap.Canvas.Pen.Color := MapColors [ mapColorHighlighted ];
		End
		Else
		Begin
			If Vertex [ iVertex ].Selected Then
			Begin
				ImageMap.Canvas.Pen.Color := MapColors [ mapColorSelected ];
			End
			Else
			Begin
				ImageMap.Canvas.Pen.Color := MapColors [ mapColorVertex ];
			End;
		End;
		//
		MapRenderVertex ( x, y );
	End;
End;

Begin
	//
	If PanelMap.Tag = 0 Then
	Begin
		PanelReset ( PanelMap, ImageMap );
	End;
	//
	If MapZoom = 0 Then
	Begin
		MapZoomAll;
	End;
	//
	With ImageMap Do
	Begin
		Canvas.Brush.Color := clBlack;
		Canvas.FillRect ( Canvas.ClipRect );
	End;
	//
	mx := ImageMap.Width;
	my := ImageMap.Height;
	//
	If ( mnuMapViewGrid.Checked ) And Not MapQuickDraw Then
	Begin
		//
		// --- Grid
		//
		x := -1;
		y := -1;
		//
		If MapZoom < 0.1 Then
		Begin
			Grid := 256;
		End
		Else
		Begin
			Grid := MapGrid;
		End;
		//
		// ---
		//
		CoordsScreenToMap ( x, y );
		x2 := ( x Or ( Grid - 1 ) ) - ( Grid - 1 );
		y2 := ( y Or ( Grid - 1 ) ) - ( Grid - 1 );
		ImageMap.Canvas.Pen.Color := MapColors [ mapColorGrid ];
		//
		x := 1;
		While ( x < ImageMap.Width ) Do
		Begin
			x := x2;
			y := y2;
			CoordsMapToScreen ( x, y );
			ImageMap.Canvas.MoveTo ( x, 0 );
			ImageMap.Canvas.LineTo ( x, my );
			//
			Inc ( x2, Grid );
		End;
		//
		y := 1;
		While ( y < ImageMap.Height ) Do
		Begin
			x := x2;
			y := y2;
			CoordsMapToScreen ( x, y );
			ImageMap.Canvas.MoveTo ( 0, y );
			ImageMap.Canvas.LineTo ( mx, y );
			//
			Dec ( y2, Grid );
		End;
		//
		//
		//
		If MapZoom > 0.25 Then
		Begin
			//
			// --- Floor Grid
			//
			// determine length
			iFGrid := Round ( MapZoom * 4 );
			If iFGrid > 10 Then iFGrid := 10;
			//
			x := -1;
			y := -1;
			//
			Grid := 64; // step 64
			//
			CoordsScreenToMap ( x, y );
			x2 := ( x Or ( Grid - 1 ) ) - ( Grid - 1 );
			y2 := ( y Or ( Grid - 1 ) ) - ( Grid - 1 );
			ImageMap.Canvas.Pen.Color := MapColors [ mapColorFloorGrid ];
			//
			x0 := x2;
			//
			y := 1;
			While ( y < ImageMap.Height ) Do
			Begin
				x2 := x0;
				x := 1;
				While ( x < ImageMap.Width ) Do
				Begin
					x := x2;
					y := y2;
					CoordsMapToScreen ( x, y );
					ImageMap.Canvas.MoveTo ( x, y - iFGrid );
					ImageMap.Canvas.LineTo ( x, y + iFGrid + 1 );
					ImageMap.Canvas.MoveTo ( x - iFGrid, y );
					ImageMap.Canvas.LineTo ( x + iFGrid + 1, y );
					//
					Inc ( x2, Grid );
				End;
				Dec ( y2, Grid );
			End;
		End;
		//
		// --- big cross at 0
		//
		ImageMap.Canvas.Pen.Color := clDkGray;
		x := 32;
		y := 0;
		CoordsMapToScreen ( x, y );
		ImageMap.Canvas.MoveTo ( x, y );
		x := -32;
		y := 0;
		CoordsMapToScreen ( x, y );
		ImageMap.Canvas.LineTo ( x, y );
		//
		x := 0;
		y := 32;
		CoordsMapToScreen ( x, y );
		ImageMap.Canvas.MoveTo ( x, y );
		x := 0;
		y := -32;
		CoordsMapToScreen ( x, y );
		ImageMap.Canvas.LineTo ( x, y );
		//
	End;
	//
	// --- LineDefs
	//
	ImageMap.Canvas.Brush.Style := bsClear;
	//
	For i := 0 To nLineDefs Do
	Begin
		{
		MessageDlgPos ( IntToStr ( i ) + '/' + IntToStr ( nLineDefs ) + #13 +
			IntToStr ( LineDefs [ i ].VertexS ) + '-' +
			IntToStr ( LineDefs [ i ].VertexE ), mtInformation, [mbOK], 0, 10, 10 );
		}
		//
		x := Vertex [ LineDefs [ i ].VertexS ]. x;
		y := Vertex [ LineDefs [ i ].VertexS ]. y;
		x2 := Vertex [ LineDefs [ i ].VertexE ]. x;
		y2 := Vertex [ LineDefs [ i ].VertexE ]. y;
		//
		CoordsMapToScreen ( x, y );
		CoordsMapToScreen ( x2, y2 );
		//
		If Not ( ( ( x < 0 ) And ( x2 < 0 ) ) Or
		( ( x > mx ) And ( x2 > mx ) ) Or
		( ( y < 0 ) And ( y2 < 0 ) ) Or
		( ( y > my ) And ( y2 > my ) ) ) Then
		Begin
			//
			If LineDefs [ i ].Highlighted Then
			Begin
				ImageMap.Canvas.Pen.Color := MapColors [ mapColorHighlighted ];
				//ImageMap.Canvas.Brush.Color := MapColors [ mapColorHighlighted ];
			End
			Else
			Begin
				If LineDefs [ i ].Selected Then
				Begin
					ImageMap.Canvas.Pen.Color := MapColors [ mapColorSelected ];
					//ImageMap.Canvas.Brush.Color := MapColors [ mapColorSelected ];
				End
				Else
				Begin
					If ( LineDefs [ i ].Flags And ldefTwoSided ) <> 0 Then
					Begin
						ImageMap.Canvas.Pen.Color := MapColors [ mapColorLinesTwoSided ];
						//ImageMap.Canvas.Brush.Color := MapColors [ mapColorLinesTwoSided ];
					End
					Else
					Begin
						ImageMap.Canvas.Pen.Color := MapColors [ mapColorLines ];
						//ImageMap.Canvas.Brush.Color := MapColors [ mapColorLines ];
					End;
				End;
			End;
			//
			// Draw Line
			//
			If mnuMapView3D.Checked Then
			Begin
				//
				iBotF := Round ( Sectors [ MapLineDefFrontSector ( i ) ].Floor * MapZoom );
				iTopF := Round ( Sectors [ MapLineDefFrontSector ( i ) ].Ceiling * MapZoom );
				//
				If ( LineDefs [ i ].Flags And ldefTwoSided ) <> 0 Then
				Begin
					//
					iBotB := Round ( Sectors [ MapLineDefBackSector ( i ) ].Floor * MapZoom );
					iTopB := Round ( Sectors [ MapLineDefBackSector ( i ) ].Ceiling * MapZoom );
					//
					If iBotB <> iBotF Then
					Begin
						ImageMap.Canvas.MoveTo ( x + Round ( iBotF * Map3DX ), y + Round ( iBotF * Map3DY ) );
						ImageMap.Canvas.LineTo ( x2 + Round ( iBotF * Map3DX ), y2 + Round ( iBotF * Map3DY ) );
						ImageMap.Canvas.LineTo ( x2 + Round ( iBotB * Map3DX ), y2 + Round ( iBotB * Map3DY ) );
						ImageMap.Canvas.LineTo ( x + Round ( iBotB * Map3DX ), y + Round ( iBotB * Map3DY ) );
						ImageMap.Canvas.LineTo ( x2 + Round ( iBotB * Map3DX ), y2 + Round ( iBotB * Map3DY ) );
					End;
					//
					If iTopB <> iTopF Then
					Begin
						ImageMap.Canvas.MoveTo ( x + Round ( iTopF * Map3DX ), y + Round ( iTopF * Map3DY ) );
						ImageMap.Canvas.LineTo ( x2 + Round ( iTopF * Map3DX ), y2 + Round ( iTopF * Map3DY ) );
						ImageMap.Canvas.LineTo ( x2 + Round ( iTopB * Map3DX ), y2 + Round ( iTopB * Map3DY ) );
						ImageMap.Canvas.LineTo ( x + Round ( iTopB * Map3DX ), y + Round ( iTopB * Map3DY ) );
						ImageMap.Canvas.LineTo ( x2 + Round ( iTopB * Map3DX ), y2 + Round ( iTopB * Map3DY ) );
					End;
				End
				Else
				Begin
					//
					ImageMap.Canvas.MoveTo ( x + Round ( iBotF * Map3DX ), y + Round ( iBotF * Map3DY ) );
					ImageMap.Canvas.LineTo ( x2 + Round ( iBotF * Map3DX ), y2 + Round ( iBotF * Map3DY ) );
					ImageMap.Canvas.LineTo ( x2 + Round ( iTopF * Map3DX ), y2 + Round ( iTopF * Map3DY ) );
					ImageMap.Canvas.LineTo ( x + Round ( iTopF * Map3DX ), y + Round ( iTopF * Map3DY ) );
					ImageMap.Canvas.LineTo ( x + Round ( iBotF * Map3DX ), y + Round ( iBotF * Map3DY ) );
					//
				End;
			End
			Else
			Begin
				ImageMap.Canvas.MoveTo ( x, y );
				ImageMap.Canvas.LineTo ( x2, y2 );
			End;
			//
			If Not mnuMapView3D.Checked And Not MapQuickDraw Then
			Begin
				If MapZoom > 0.25 Then
				Begin
					If ( MapMode = mmLineDefs ) Or ( MapMode = mmAll ) Then
					Begin
						//
						// Draw Line direction
						//
						xc := x + ( x2 - x ) Div 2;
						yc := y + ( y2 - y ) Div 2;
						iLen := Trunc ( Sqrt ( ( x - x2 ) * ( x - x2 ) + ( y - y2 ) * ( y - y2 ) ) );
						//
						If iLen = 0 Then iLen := 1;
						yp := Round ( ( y - yc ) * 16 / iLen * MapZoom );
						xp := Round ( ( xc - x ) * 16 / iLen * MapZoom );
						//
						ImageMap.Canvas.MoveTo ( xc, yc );
						ImageMap.Canvas.LineTo ( xc + yp, yc + xp );
						//
						If MapZoom > 0.5 Then
						Begin
							If mnuMapDisplayLinedefLengths.Checked Then
							Begin
								//
								yp := Round ( ( y - yc ) * 16 / iLen );
								xp := Round ( ( xc - x ) * 16 / iLen );
								//
								s := Comma ( MapLineDefGetLength ( i ) );
								//
								With ImageMap.Canvas Do
									TextOut ( xc - yp - ( TextWidth ( s ) + 2 ) Div 2, yc - xp - ( TextHeight ( s ) - 2 ) Div 2, s );
							End;
						End;
					End;
				End;
				//
				// Render line start and end vertex
				//
				If MapZoom > 0.5 Then
				Begin
					If ( MapMode = mmLineDefs ) Or ( MapMode = mmAll )
					Or ( MapMode = mmVertex ) Or ( MapMode = mmDraw )
					or ( MapMode = mmDrawNewSector ) Then
					Begin
						If Not LineDefs [ i ].Selected
						And Not LineDefs [ i ].Highlighted Then
						Begin
							ImageMap.Canvas.Pen.Color := MapColors [ mapColorVertex ];
						End;
						//
						RenderVertex ( LineDefs [ i ].VertexS );
						RenderVertex ( LineDefs [ i ].VertexE );
					End;
				End;
			End;
		End;
	End;
	//
	{
	If MapZoom > 0.5 Then
	Begin
		//
		// --- Draw Vertexes
		//
		For i := 0 To nVertex Do
		Begin
			x := Vertex [ i ]. x;
			y := Vertex [ i ]. y;
			//
			CoordsMapToScreen ( x, y );
			//
			If ( ( x > 0 ) And ( x < mx ) And ( y > 0 ) And ( y < my ) ) Then
			Begin
				//
				If Vertex [ i ].Highlighted Then
				Begin
					ImageMap.Canvas.Pen.Color := clYellow;
				End
				Else
				Begin
					If Vertex [ i ].Selected Then
					Begin
						ImageMap.Canvas.Pen.Color := clRed;
					End
					Else
					Begin
						ImageMap.Canvas.Pen.Color := clGray;
					End;
				End;
				//
				MapRenderVertex ( x, y );
			End;
		End;
	End;
	}
	//
	If Not MapQuickDraw And ( mnuMapViewShowThings.Checked ) Then
	Begin
		//
		// --- things
		//
		For i := 0 To nThings Do
		Begin
			x := Things [ i ]. x;
			y := Things [ i ]. y;
			CoordsMapToScreen ( x, y );
			//
			If ( x > 0 ) And ( x < mx ) And ( y > 0 ) And ( y < my ) Then
			Begin
				If Things [ i ]. Highlighted Then
				Begin
					ImageMap.Canvas.Pen.Color := clYellow;
				End
				Else
				Begin
					If Things [ i ]. Selected Then
					Begin
						ImageMap.Canvas.Pen.Color := clRed;
					End
					Else
					Begin
						ImageMap.Canvas.Pen.Color := clOlive;
					End;
				End;
				MapRenderThing ( Things [ i ].iType, x, y, Things [ i ].Angle );
			End;
		End;
	End;
	//
	//
	//
	{
	ImageMap.Canvas.Pen.Color := clMaroon;
	ImageMap.Canvas.MoveTo ( ImageMap.Width Div 2, 0 );
	ImageMap.Canvas.LineTo ( ImageMap.Width Div 2, ImageMap.Height );
	ImageMap.Canvas.MoveTo ( 0, ImageMap.Height Div 2 );
	ImageMap.Canvas.LineTo ( ImageMap.Width, ImageMap.Height Div 2 );
	}
	//
	//
	//
	ShowPage ( edMap );
	//
	{
	Status ( 'Zoom : ' + FloatToStrF ( Int ( MapZoom * 100 ) / 100, ffGeneral, 10, 2 ) +
		' MapX : ' + Comma ( MapX ) + ' MapY : ' + Comma ( MapY ) +
		' W : ' + Comma ( ImageMap.Width ) + ' H : ' + Comma ( ImageMap.Height ) );
	}
	//
	MapRefreshed := True; // flag for real-time drawn things
End;

Procedure TFormMain.MapSetModeInit ( m : TMapMode );
Begin
	MapMode := m;
	//
	mnuDrawAll.Checked := m = mmAll;
	mnuDrawLineDefs.Checked := m = mmLineDefs;
	mnuDrawThings.Checked := m = mmThings;
	mnuDrawSectors.Checked := m = mmSectors;
	mnuDrawVertex.Checked := m = mmVertex;
	mnuDrawDraw.Checked := m = mmDraw;
	mnuDrawNewSector.Checked := m = mmDrawNewSector;
	//
	MapDeHighlightAll;
End;

Procedure TFormMain.MapSetMode ( m : TMapMode );
Var
	PrevMode : TMapMode;
Begin
	PrevMode := MapMode;
	MapSetModeInit ( m );
	//
	Case m Of

		mmDraw :
		Begin
			// --- Any Sectors?
			If nSectors >= 0 Then
			Begin
				// --- First time?
				If PrevMode <> mmDraw Then
				Begin
					MapLastVertex := -1;
					StatusMode ( '**Draw**' );
				End;
			End
			Else
			Begin
				MapSetMode ( mmAll );
				Status ( 'No sectors' );
			End;
		End;

		mmDrawNewSector :
		Begin
			// --- First time?
			If PrevMode <> mmDrawNewSector Then
			Begin
				MapLastVertex := -1;
				Status ( 'Drawing New Sector mode' );
				StatusMode ( '*Draw New*' );
			End;
		End;

		mmAll :
		Begin
			Status ( 'All mode' );
			StatusMode ( 'All mode' );
			MapModeAll.Down := True;
			MapRefresh;
			EditMapZoom.SetFocus;
		End;

		mmLineDefs :
		Begin
			If mnuMapViewPropertiesBar.Checked Then
				MapShowPanel ( mmLineDefs );
			Status ( 'LineDefs mode' );
			StatusMode ( 'LineDefs mode' );
			MapModeLineDefs.Down := True;
			MapRefresh;
			EditMapZoom.SetFocus;
		End;

		mmThings :
		Begin
			If mnuMapViewPropertiesBar.Checked Then
				MapShowPanel ( mmThings );
			Status ( 'Things mode' );
			StatusMode ( 'Things mode' );
			MapModeThings.Down := True;
			MapRefresh;
			EditMapZoom.SetFocus;
		End;

		mmSectors :
		Begin
			If mnuMapViewPropertiesBar.Checked Then
				MapShowPanel ( mmSectors );
			Status ( 'Sectors mode' );
			StatusMode ( 'Sectors mode' );
			MapModeSectors.Down := True;
			MapRefresh;
			EditMapZoom.SetFocus;
		End;

		mmVertex :
		Begin
			If mnuMapViewPropertiesBar.Checked Then
				MapShowPanel ( mmVertex );
			Status ( 'Vertex mode' );
			StatusMode ( 'Vertex mode' );
			MapRefresh;
			EditMapZoom.SetFocus;
		End;

		mmDrag :
		Begin
			StatusMode ( 'DRAGGING' );
		End;

		mmSelect :
		Begin
			StatusMode ( 'SELECTING' );
		End;

		mmDuplicate :
		Begin
			StatusMode ( 'PASTE' );
		End;

	End;
End;

Procedure TFormMain.MapModeSave;
Begin
	If ( MapMode <> mmDrag )
	And ( MapMode <> mmSelect )
	And ( MapMode <> mmDuplicate ) Then
		PrevMapMode := MapMode;
End;

Procedure TFormMain.MapModeRestore;
Begin
	MapSetMode ( PrevMapMode );
End;

Procedure TFormMain.MapEditor ( bFocus : Boolean );
Var
	t0 : Cardinal;
	mi : TMenuItem;
	sr : TSearchRec;
	iError : Integer;
	s : String;
Begin
	//
	// config
	//
	t0 := GetTickCount;
	//
	If Not bMapConfigInit Then
	Begin
		bMapConfigInit := True;
		//
		iError := FindFirst ( sExePath + 'xwe-config-*.ini', faAnyFile, sr );
		While iError = 0 Do
		Begin
			mi := TMenuItem.Create ( Self );
			//
			s := sr.Name;
			s := RemoveFromLeft ( RemoveFromRight ( s, 4 ), 11 );
			mi.Caption := s;
			//
			mi.OnClick := mnuMapConfigClick;
			mi.RadioItem := True;
			//
			mnuMapConfig.Add ( mi );
			//
			iError := FindNext ( sr );
		End;
	End;
	//
	// ---
	//
	PreparePalette;
	//
	ImageMap.Canvas.Font.Name := 'TAHOMA';
	ImageMap.Canvas.Font.Color := $40E0FF;
	//
	MapZoom := 0;
	//
	Map3DX := 0.4;
	Map3DY := -0.6;
	//
	If mnuMapConfig.Count > 0 Then
	Begin
		mnuMapConfigClick ( mnuMapConfig.Items [ 0 ] );
	End
	Else
	Begin
		MessageDlg ( 'Warning: you don''t have any map configuration files.' + #13 +
			'These files should be in your XWE folder, named "xwe-config-<name>.ini"' + #13 +
			'Without these, XWE will not be able to display things and linedefs properly.',
			mtWarning, [mbOK], 0 );
	End;
	//
	MapLoad ( iSel, Not gPreviewMaps );
	//
	With MapEditLineDefsActivate Do
	Begin
		Items.Clear;
		Items.Add ( 'Player Cross' ); // 000
		Items.Add ( 'Player Uses' ); // 001
		Items.Add ( 'Enemy Cross' ); // 010
		Items.Add ( 'Proj''tl Hits' ); // 011
		Items.Add ( 'Player Bumps' ); // 100
		Items.Add ( 'Proj''tl Cross' ); // 101
		Items.Add ( 'Reserved 1' ); // 110
		Items.Add ( 'Reserved 2' ); // 111
		Items.Add ( '(multiple)' );
	End;
	//
	PanelMapWaded.Visible := mnuMapViewWadedBar.Checked;
	MapViewPropertiesBarRefresh;
	MapTexturesRefresh;
	MapFlatsInit;
	//
	{
	mnuMapViewGrid.Checked := False;
	MapViewGridClick; // call this instead of click event so that we don't cause
										// map refresh
	}
	//
	MapSetModeInit ( mmAll );
	MapModeAll.Down := True;
	MapRefresh;
	//
	If bFocus Then
	Begin
		EditMapZoom.SetFocus;
	End;
	//
	Status ( 'Loaded map in ' + Comma ( GetTickCount - t0 ) + ' milliseconds.' );
End;

Procedure TFormMain.MapLoad ( iEntry : Integer; bFullLoad : Boolean );
Var
	i, iMaxEntries : Integer;
	s : String;
Begin
	//
	nThings := -1;
	nLineDefs := -1;
	nSideDefs := -1;
	nVertex := -1;
	nSectors := -1;
	//
	MapType := mtDoom;
	If nWadEntries >= iEntry + 11 Then
	Begin
		If UpperCase ( WadEntries [ iEntry + 11 ].Name ) = 'BEHAVIOR' Then
		Begin
			MapType := mtZDoom;
			//
			MapConfigSelect ( 'zdoom' );
		End;
	End;
	//
	MapTypeRefresh;
	//
	iMaxEntries := 10;
	i := 1;
	While ( i <= iMaxEntries ) Do
	Begin
		If nWadEntries >= iEntry + i Then
		Begin
			s := UpperCase ( Trim ( WadEntries [ iEntry + i ].Name ) );
			//
			If ( s = 'FLATNAME' ) Then
			Begin
				MapType := mtOldDoom;
				iMaxEntries := 5;
			End;
			//
			If ( s = 'THINGS' ) And bFullLoad Then
				ThingsLoad ( iEntry + i )
			Else If ( s = 'LINEDEFS' ) Or ( s = 'LINES' ) Then
				LineDefsLoad ( iEntry + i )
			Else If ( s = 'SIDEDEFS' ) And bFullLoad Then
				SideDefsLoad ( iEntry + i )
			Else If ( s = 'VERTEXES' ) Or ( s = 'POINTS' ) Then
				VertexLoad ( iEntry + i )
			Else If ( s = 'SECTORS' ) And bFullLoad Then
				SectorLoad ( iEntry + i );
		End;
		Inc ( i );
	End;
	//
	If mnuMapCheck.Checked Then
	Begin
		MapCheckErrors;
	End;
	//
	MapDeselectAll;
	//
	Modified ( False );
	MapModified := False;
	//
	MapLoaded := bFullLoad;
End;

Procedure TFormMain.DoMapLoad;
Begin
	If Not MapLoaded Then
	Begin
		MapLoad ( iWadEntryCurrentIndex, True );
		MapRefresh;
	End;
End;

Procedure TFormMain.ThingsLoad ( iEntry : Integer );
Var                                        
	i : Integer;
Begin
	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( f, WadEntries [ iEntry ]. Position );
	//
	i := 0;
	nThings := -1;
	//
	If MapType = mtOldDoom Then
	Begin
		GetLong ( f );
	End;
	//
	While ( i < WadEntries [ iEntry ]. Size ) Do
	Begin
		//
		Inc ( nThings );
		//
		Case MapType Of

			mtDoom :
			Begin
				Things [ nThings ].x := GetWord ( f );
				Things [ nThings ].y := GetWord ( f );
				Things [ nThings ].Angle := GetWord ( f );
				Things [ nThings ].iType := GetWord ( f );
				Things [ nThings ].Flags := GetWord ( f );
				//
				Inc ( i, 10 );
			End;

			mtZDoom :
			Begin
				Things [ nThings ].Tag := GetWord ( f );
				Things [ nThings ].x := GetWord ( f );
				Things [ nThings ].y := GetWord ( f );
				Things [ nThings ].z := GetWord ( f );
				Things [ nThings ].Angle := GetWord ( f );
				Things [ nThings ].iType := GetWord ( f );
				Things [ nThings ].Flags := GetWord ( f );
				//
				Things [ nThings ].Special := GetByte ( f );
				Things [ nThings ].Arg1 := GetByte ( f );
				Things [ nThings ].Arg2 := GetByte ( f );
				Things [ nThings ].Arg3 := GetByte ( f );
				Things [ nThings ].Arg4 := GetByte ( f );
				Things [ nThings ].Arg5 := GetByte ( f );
				//
				Inc ( i, 20 );
			End;

			mtOldDoom :
			Begin
				Things [ nThings ].x := GetWord ( f );
				Things [ nThings ].y := GetWord ( f );
				Things [ nThings ].Angle := GetWord ( f );
				Things [ nThings ].iType := GetWord ( f );
				Things [ nThings ].Flags := GetWord ( f );
				GetWord ( f );
				//
				Inc ( i, 12 );
			End;

		End;
		//
	End;
	//
	fClose;
End;

Procedure TFormMain.LineDefsLoad ( iEntry : Integer );
Var
	i : Integer;
Begin
	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( f, WadEntries [ iEntry ]. Position );
	//
	i := 0;
	nLineDefs := -1;
	//
	If MapType = mtOldDoom Then
	Begin
		GetLong ( f ); // number of entries?
	End;
	//
	While ( i < WadEntries [ iEntry ]. Size ) Do
	Begin
		//
		Inc ( nLineDefs );
		//
		Case MapType Of

			mtDoom:
			Begin
				If ( i + 14 <= WadEntries [ iEntry ]. Size ) Then
				Begin
					//
					LineDefs [ nLineDefs ].VertexS := GetWord ( f );
					LineDefs [ nLineDefs ].VertexE := GetWord ( f );
					LineDefs [ nLineDefs ].Flags := GetWord ( f );
					LineDefs [ nLineDefs ].iType := GetWord ( f );
					LineDefs [ nLineDefs ].Tag := GetWord ( f );
					LineDefs [ nLineDefs ].SideFront := GetWord ( f );
					LineDefs [ nLineDefs ].SideBack := GetWord ( f );
					//
				End;
				Inc ( i, 14 );
			End;

			mtZDoom:
			Begin
				If ( i + 16 <= WadEntries [ iEntry ]. Size ) Then
				Begin
					LineDefs [ nLineDefs ].VertexS := GetWord ( f );
					LineDefs [ nLineDefs ].VertexE := GetWord ( f );
					LineDefs [ nLineDefs ].Flags := GetWord ( f );
					//
					LineDefs [ nLineDefs ].iType := Byte ( GetByte ( f ) );
					LineDefs [ nLineDefs ].Arg1 := Byte ( GetByte ( f ) );
					LineDefs [ nLineDefs ].Arg2 := Byte ( GetByte ( f ) );
					LineDefs [ nLineDefs ].Arg3 := Byte ( GetByte ( f ) );
					LineDefs [ nLineDefs ].Arg4 := Byte ( GetByte ( f ) );
					LineDefs [ nLineDefs ].Arg5 := Byte ( GetByte ( f ) );
					//
					LineDefs [ nLineDefs ].SideFront := GetWord ( f );
					LineDefs [ nLineDefs ].SideBack := GetWord ( f );
				End;
				//
				Inc ( i, 16 );
			End;

			mtOldDoom:
			Begin
				If ( i + 18 <= WadEntries [ iEntry ]. Size ) Then
				Begin
					//
					LineDefs [ nLineDefs ].VertexS := GetWord ( f );
					LineDefs [ nLineDefs ].VertexE := GetWord ( f );
					LineDefs [ nLineDefs ].Flags := GetWord ( f );
					LineDefs [ nLineDefs ].iType := GetWord ( f );
					LineDefs [ nLineDefs ].Tag := GetWord ( f );
					LineDefs [ nLineDefs ].SideFront := GetWord ( f );
					LineDefs [ nLineDefs ].SideBack := GetWord ( f );
					GetLong ( f );
					//
					// get rid of 'weird' linedefs???
					If ( LineDefs [ nLineDefs ].VertexS = -1 )
					Or ( LineDefs [ nLineDefs ].VertexE = -1 ) Then
					Begin
						LineDefs [ nLineDefs ].VertexS := -1;
						LineDefs [ nLineDefs ].VertexE := -1;
					End;
					//
				End;
				Inc ( i, 18 );
			End;

		End;
	End;
	//
	fClose;
End;

Procedure TFormMain.SideDefsLoad ( iEntry : Integer );
Var
	i : Integer;
Begin
	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( f, WadEntries [ iEntry ]. Position );
	//
	i := 0;
	nSideDefs := -1;
	//
	While ( i < WadEntries [ iEntry ]. Size ) Do
	Begin
		//
		Inc ( nSideDefs );
		SideDefs [ nSideDefs ].xOffset := GetWord ( f );
		SideDefs [ nSideDefs ].yOffset := GetWord ( f );
		SideDefs [ nSideDefs ].Above := GetString8 ( f );
		SideDefs [ nSideDefs ].Below := GetString8 ( f );
		SideDefs [ nSideDefs ].Main := GetString8 ( f );
		SideDefs [ nSideDefs ].Sector := GetWord ( f );
		//
		Inc ( i, 30 );
	End;
	//
	fClose;
End;

Procedure TFormMain.VertexCalcRange;
Var
	x, y : Integer;
	i : Integer;
Begin
	If nVertex < 0 Then
	Begin
		Vertex_sx := -128;
		Vertex_sy := -128;
		Vertex_lx := 128;
		Vertex_ly := 128;
	End
	Else
	Begin
		Vertex_sx := 32767;
		Vertex_sy := 32767;
		Vertex_lx := -32768;
		Vertex_ly := -32768;
		//
		For i := 0 To nVertex Do
		Begin
			x := Vertex [ i ]. x;
			y := Vertex [ i ]. y;
			//
			If x < Vertex_sx Then
				Vertex_sx := x;
			If y < Vertex_sy Then
				Vertex_sy := y;
			//
			If x > Vertex_lx Then
				Vertex_lx := x;
			If y > Vertex_ly Then
				Vertex_ly := y;
		End;
	End;
End;

Procedure TFormMain.VertexLoad ( iEntry : Integer );
Var
	x, y : Integer;
	i : Integer;
Begin
	Vertex_sx := 0;
	Vertex_sy := 0;
	Vertex_lx := 64;
	Vertex_ly := 64;
	//
	If iEntry <= nWadEntries Then
	Begin
		If ( WadEntries [ iEntry ].Size > 0 ) Then
		Begin
			If fOpen ( sFileName ) Then
			Begin
				//
				Starting;
				//
				Seek ( F, WadEntries [ iEntry ].Position );
				//
				// *** get highest lowest
				//
				Vertex_sx := 32767;
				Vertex_sy := 32767;
				Vertex_lx := -32768;
				Vertex_ly := -32768;
				nVertex := -1;
				//
				If MapType = mtOldDoom Then
				Begin
					GetLong ( f ); // number of entries
				End;
				//
				i := 0;
				While i < WadEntries [ iEntry ].Size Do
				Begin
					x := GetWord ( f );
					y := GetWord ( f );
					//
					Inc ( nVertex );
					If ( nVertex And 255 ) = 0 Then
					Begin
						Status ( Comma ( nVertex ) + ' vertexes loaded.' );
					End;
					//
					Vertex [ nVertex ]. x := x;
					Vertex [ nVertex ]. y := y;
					Vertex [ nVertex ]. Selected := False;
					//
					If x < Vertex_sx Then
						Vertex_sx := x;
					If y < Vertex_sy Then
						Vertex_sy := y;
					//
					If x > Vertex_lx Then
						Vertex_lx := x;
					If y > Vertex_ly Then
						Vertex_ly := y;
					//
					Inc ( i, 4 );
				End;
				//
				{
				Caption := Comma ( Vertex_sx ) + ',' + Comma ( Vertex_sy ) + ' - ' + Comma ( Vertex_lx ) + ',' + Comma ( Vertex_ly );
				}
				//
				fClose;
				Finished;
			End;
		End;
	End;
end;

Procedure TFormMain.SectorLoad ( iEntry : Integer );
Var
	i : Integer;
Begin
	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( f, WadEntries [ iEntry ]. Position );
	//
	i := 0;
	nSectors := -1;
	//
	While ( i < WadEntries [ iEntry ]. Size ) Do
	Begin
		//
		Inc ( nSectors );
		Sectors [ nSectors ].Floor := GetWord ( f );
		Sectors [ nSectors ].Ceiling := GetWord ( f );
		Sectors [ nSectors ].FloorTex := GetString ( f, 8 );
		Sectors [ nSectors ].CeilingTex := GetString ( f, 8 );
		Sectors [ nSectors ].Light := GetWord ( f );
		Sectors [ nSectors ].iType := GetWord ( f );
		Sectors [ nSectors ].Tag := GetWord ( f );
		//
		Inc ( i, 26 );
	End;
	//
	fClose;
End;

// ############################################################################

procedure TFormMain.mnuMapSaveClick(Sender: TObject);
Begin
	MapSave ( iSel );
end;

Function TFormMain.MapSave ( iEntry : Integer ) : Boolean;
Var
	i : Integer;
	bFullRefresh : Boolean;

Procedure AddN ( sName : String; iNewEntry : Integer );
Begin
	//
	// Add New Entry if needed
	//
	If nWadEntries < iNewEntry Then
	Begin
		//
		// add to end of list
		//
		WadEntryNew ( sName );
	End
	Else
	Begin
		If UpperCase ( Trim ( WadEntries [ iNewEntry ].Name ) ) <> sName Then
		Begin
			WadEntryNewAtPos ( sName, iNewEntry, -1, False );
			bFullRefresh := True;
		End;
	End;
End;

Procedure Repl ( sName : String; iNewEntry : Integer );
Begin
	AddN ( sName, iNewEntry );
	ReplaceFile ( iNewEntry, sTempFile, False, True );
End;

Begin
	If MapLoaded Then
	Begin
		Starting;
		//
		SaveUndo ( 'Save Map' );
		//
		bFullRefresh := False;
		//
		// --- Things
		//
		Status ( 'Saving Things' );
		fOpenTemp;
		For i := 0 To nThings Do
		Begin
			//
			Case MapType Of
				//
				mtDoom :
				Begin
					SendWord ( fo, Things [ i ].x );
					SendWord ( fo, Things [ i ].y );
					SendWord ( fo, Things [ i ].Angle );
					SendWord ( fo, Things [ i ].iType );
					SendWord ( fo, Things [ i ].Flags );
				End;
				//
				mtZDoom :
				Begin
					SendWord ( fo, Things [ i ].Tag );
					SendWord ( fo, Things [ i ].x );
					SendWord ( fo, Things [ i ].y );
					SendWord ( fo, Things [ i ].z );
					SendWord ( fo, Things [ i ].Angle );
					SendWord ( fo, Things [ i ].iType );
					SendWord ( fo, Things [ i ].Flags );
					//
					SendByte ( fo, Things [ i ].Special );
					SendByte ( fo, Things [ i ].Arg1 );
					SendByte ( fo, Things [ i ].Arg2 );
					SendByte ( fo, Things [ i ].Arg3 );
					SendByte ( fo, Things [ i ].Arg4 );
					SendByte ( fo, Things [ i ].Arg5 );
				End;
				//
			End;
		End;
		CloseFile ( fo );
		Repl ( 'THINGS', iEntry + 1 );
		//
		// --- LineDefs
		//
		Status ( 'Saving LineDefs' );
		fOpenTemp;
		For i := 0 To nLineDefs Do
		Begin
			//
			Case MapType Of
				//
				mtDoom :
				Begin
					SendWord ( fo, LineDefs [ i ].VertexS );
					SendWord ( fo, LineDefs [ i ].VertexE );
					SendWord ( fo, LineDefs [ i ].Flags );
					SendWord ( fo, LineDefs [ i ].iType );
					SendWord ( fo, LineDefs [ i ].Tag );
					SendWord ( fo, LineDefs [ i ].SideFront );
					SendWord ( fo, LineDefs [ i ].SideBack );
				End;
				//
				mtZDoom :
				Begin
					SendWord ( fo, LineDefs [ i ].VertexS );
					SendWord ( fo, LineDefs [ i ].VertexE );
					SendWord ( fo, LineDefs [ i ].Flags );
					//
					SendByte ( fo, LineDefs [ i ].iType );
					SendByte ( fo, LineDefs [ i ].Arg1 );
					SendByte ( fo, LineDefs [ i ].Arg2 );
					SendByte ( fo, LineDefs [ i ].Arg3 );
					SendByte ( fo, LineDefs [ i ].Arg4 );
					SendByte ( fo, LineDefs [ i ].Arg5 );
					//
					SendWord ( fo, LineDefs [ i ].SideFront );
					SendWord ( fo, LineDefs [ i ].SideBack );
				End;
			End;
		End;
		CloseFile ( fo );
		Repl ( 'LINEDEFS', iEntry + 2 );
		//
		// --- SideDefs
		//
		Status ( 'Saving SideDefs' );
		fOpenTemp;
		For i := 0 To nSideDefs Do
		Begin
			SendWord ( fo, SideDefs [ i ].xOffset );
			SendWord ( fo, SideDefs [ i ].yOffset );
			SendString8 ( fo, SideDefs [ i ].Above );
			SendString8 ( fo, SideDefs [ i ].Below );
			SendString8 ( fo, SideDefs [ i ].Main );
			SendWord ( fo, SideDefs [ i ].Sector );
		End;
		CloseFile ( fo );
		Repl ( 'SIDEDEFS', iEntry + 3 );
		//
		// --- Vertex
		//
		Status ( 'Saving Vertexes' );
		fOpenTemp;
		For i := 0 To nVertex Do
		Begin
			SendWord ( fo, Vertex [ i ].x );
			SendWord ( fo, Vertex [ i ].y );
		End;
		CloseFile ( fo );
		Repl ( 'VERTEXES', iEntry + 4 );
		//
		// --- Add map entries if necessary
		//
		AddN ( 'SEGS', iEntry + 5 );
		AddN ( 'SSECTORS', iEntry + 6 );
		AddN ( 'NODES', iEntry + 7 );
		//
		// --- Sectors
		//
		Status ( 'Saving Sectors' );
		fOpenTemp;
		For i := 0 To nSectors Do
		Begin
			SendWord ( fo, Sectors [ i ].Floor );
			SendWord ( fo, Sectors [ i ].Ceiling );
			SendString8 ( fo, Sectors [ i ].FloorTex );
			SendString8 ( fo, Sectors [ i ].CeilingTex );
			SendWord ( fo, Sectors [ i ].Light );
			SendWord ( fo, Sectors [ i ].iType );
			SendWord ( fo, Sectors [ i ].Tag );
		End;
		CloseFile ( fo );
		Repl ( 'SECTORS', iEntry + 8 );
		//
		// --- Add map entries if necessary
		//
		AddN ( 'REJECT', iEntry + 9 );
		AddN ( 'BLOCKMAP', iEntry + 10 );
		//
		// --- ZDoom special
		//
		If MapType = mtZDoom Then
		Begin
			AddN ( 'BEHAVIOR', iEntry + 11 );
			//
			If WadEntries [ iEntry + 11 ].Name = 'BEHAVIO_' Then
			Begin
				EntryRenameByIndex ( iEntry + 11, 'BEHAVIOR' );
			End;
		End;
		//
		If MapType = mtDoom Then
		Begin
			If nWadEntries >= iEntry + 11 Then
			Begin
				If WadEntries [ iEntry + 11 ].Name = 'BEHAVIOR' Then
				Begin
					EntryRenameByIndex ( iEntry + 11, 'BEHAVIO_' );
				End;
			End;
		End;
		//
		// ---
		//
		If bFullRefresh Then
		Begin
			ShowWadEntries;
		End;
		//
		Modified ( False );
		UpdateModifiedDate;
		Finished;
		//
		MapSave := True;
	End
	Else
	Begin
		MapSave := False;
	End;
End;

// ############################################################################

procedure TFormMain.mnuMapRunClick(Sender: TObject);
Var
	sPath, sExec, sParam, s : String;
	sMap : String;
	iMap : Integer;
Begin
	If Not MapLoaded Then
	Begin
		DoMapLoad;
	End;
	//
	If MapLoaded Then
	Begin
		//
		// --- Compile/Save current map if necessary
		//
		If MapModified Then
			MapCompile ( iSel );
		//
		If isModified Then
			MapSave ( iSel );
		//
		ToolsGet ( 'Run Map', 'ZDOOM.EXE', sPath, sExec, sParam );
		//
		If Not FileExists ( sPath + sExec ) Then
		Begin
			ShowMessage ( 'File not found:' + #13 + sPath + sExec );
		End
		Else
		Begin
			//
			// --- Try to get map number
			//     (only works for MAPnn format)
			//
			sMap := WadEntries [ iSel ].Name;
			If Length ( Trim ( sMap ) ) = 5 Then
			Begin
				iMap := SafeVal ( Copy ( sMap, 4, 2 ) );
				If iMap = 0 Then
					iMap := 1;
			End
			Else
			Begin
				iMap := 1;
			End;
			//
			s := '-file ' + sFileName + ' -skill 4 -warp ' + IntToStr ( iMap );
			//
			If sMainWAD <> '' Then
			Begin
				s := s + ' -iwad ' + sMainWAD;
			End;
			//ChDir ( sPath );
			ExecuteFile ( sPath + sExec, s, sPath, SW_SHOWMAXIMIZED );
		End;
	End;
end;

// ############################################################################

procedure TFormMain.mnuMapCompileClick(Sender: TObject);
Begin
	MapCompile ( iSel );
	MapModified := False;
end;

procedure TFormMain.MapCompile ( iEntry : Integer );
Var
	sPath, sExec, sParam : String;
	sOutFile : String;
	i, iPos, iEntries : Integer;
	iNewWadDirPos, iNewEntryPos, iNewEntrySize : Integer;
	//
	//iTimer : Cardinal;
Begin
	If MapLoaded Then
	Begin
		//
		// --- Save current map
		//
		If isModified Then
			MapSave ( iEntry );
		//
		// ---
		//
		ToolsGet ( 'Nodes Builder', 'ZENNODE.EXE', sPath, sExec, sParam );
		//
		If Not FileExists ( sPath + sExec ) Then
		Begin
			ShowMessage ( 'File not found:' + #13 + sPath + sExec );
		End
		Else
		Begin
			//
			// --- Build temp WAD file with current map
			//
			fOpenTemp;
			//
			If MapType = mtDoom Then
				iEntries := 10
			Else
				iEntries := 11;
			//
			// --- Calculate directory position
			//
			iPos := 12; // header
			For i := 1 To iEntries Do
			Begin
				If nWadEntries >= iEntry + i Then
				Begin
					// add each entry's size
					Inc ( iPos, WadEntries [ iEntry + i ].Size );
				End;
			End;
			//
			// --- Write header
			//
			SendWadSignature;
			SendLong ( fo, iEntries + 1 ); // num entries + MAP marker
			SendLong ( fo, iPos ); // dir pos
			//
			fOpen ( sEditFile );
			//
			For i := 1 To iEntries Do
			Begin
				// --- copy each entry
				If iEntry + i <= nWadEntries Then
				Begin
					Seek ( f, WadEntries [ iEntry + i ].Position );
					CopyData ( f, fo, WadEntries [ iEntry + i ].Size );
				End;
			End;
			//
			// --- Write directory
			//
			iPos := 12; // keep track of position
			//
			SendWadEntry ( fo, iPos, 0, WadEntries [ iEntry ].Name );
			//
			For i := 1 To iEntries Do
			Begin
				If iEntry + i <= nWadEntries Then
				Begin
					With WadEntries [ iEntry + i ] Do
					Begin
						SendWadEntry ( fo, iPos, Size, Name );
						Inc ( iPos, WadEntries [ iEntry + i ].Size );
					End;
				End
				Else
				Begin
					// null entry, iPos doesn't increase
					SendWadEntry ( fo, iPos, 0, '' );
				End;
			End;
			//
			fClose;
			CloseFile ( fo );
			//
			AssignFile ( fo, sTempFile );
			sTempFile := RemoveFromRight ( sTempFile, 4 ) + '.WAD';
			Rename ( fo, sTempFile );
			//
			// === Compile it
			//
			sOutFile := RemoveFromRight ( sTempFile, 4 ) + '~.WAD';
			//
			ExecAndWait ( sPath + sExec, '-nq "' + sTempFile + '" -x "' + sOutFile + '"', SW_NORMAL );
			//
			{
			ExecuteFile ( '"' + sPath + sExec + '"',
				'-nq "' + sTempFile + '" -x "' + sOutFile + '"',
				'"' + sPath + '"', SW_NORMAL );
			//
			iTimer := GetTickCount;
			While Not FileExists ( sOutFile ) And ( ( GetTickCount - iTimer ) < 20000 ) Do
			Begin
				//
			End;
			//
			Delay ( 1500 );
			}
			//
			If Not FileExists ( sOutFile ) Then
			Begin
				ShowMessage ( 'Compile error!' );
			End
			Else
			Begin
				fOpen ( sEditFile );
				//
				AssignFile ( fo, sOutFile );
				FileMode := fmOpenReadWrite;
				Reset ( fo, 1 );
				//
				Seek ( fo, $4 );
				iPos := GetLong ( fo ) - 1;
				If iPos < iEntries Then
					iEntries := iPos;
				//
				iNewWadDirPos := GetLong ( fo );
				//
				If ( iNewWadDirPos >= 12 ) And ( iNewWadDirPos < FileSize ( fo ) ) Then
				Begin
					//
					For i := 1 To iEntries Do
					Begin
						Seek ( fo, iNewWadDirPos + ( 4 + 4 + 8 ) * i );
						iNewEntryPos := GetLong ( fo );
						iNewEntrySize := GetLong ( fo );
						//
						ReplaceFilePart ( iEntry + i, fo, iNewEntryPos, iNewEntrySize, False );
					End;
					//
					UpdateWadList;
					//
					MapLoad ( iEntry, True );
					//
				End
				Else
				Begin
					// --- Compile unsuccessful?
					Status ( 'Compile unsuccessful' );
				End;
				//
				CloseFile ( fo );
				fClose;
				//
        UpdateModifiedDate;
				//
			End;
		End;
	End;
End;

// ###

procedure TFormMain.MapListErrorsClick(Sender: TObject);
Var
	s : String;
	i : Integer;
begin
	s := MapListErrors.Items.Strings [ MapListErrors.ItemIndex ];
	//
	If BeginsWith ( s, 'LineDef' ) Then
	Begin
		s := RemoveFromLeft ( s, Pos ( '#', s ) );
		s := Trim ( Copy ( s, 1, Pos ( ' ', s ) ) );
		i := SafeVal ( s );
		//
		MapDeselectAll;
		MapDeHighlightAll;
		//
		LineDefs [ i ].Selected := True;
		//
		MapCenter (
			Vertex [ LineDefs [ i ].VertexS ].x, Vertex [ LineDefs [ i ].VertexS ].y,
			Vertex [ LineDefs [ i ].VertexE ].x, Vertex [ LineDefs [ i ].VertexE ].y );
		//
		MapRefresh;
	End
	Else
	Begin
		If BeginsWith ( s, 'Thing' ) Then
		Begin
			s := RemoveFromLeft ( s, Pos ( '#', s ) );
			s := Trim ( Copy ( s, 1, Pos ( ' ', s ) ) );
			//
			MapDeselectAll;
			Things [ SafeVal ( s ) ].Selected := True;
			MapRefresh;
		End;
	End;
	//
	EditMapZoom.SetFocus;
end;

procedure TFormMain.mnuMapCheckClick(Sender: TObject);
Begin
	mnuMapCheck.Checked := Not mnuMapCheck.Checked;
	If mnuMapCheck.Checked Then
	Begin
		MapCheckErrors;
	End;
	MapListErrors.Visible := mnuMapCheck.Checked;
End;

procedure TFormMain.mnuMapFixAllErrorsClick(Sender: TObject);
Var
	Count : Integer;
	i : Integer;
	iError : Integer;
	s : String;
	//
	n : Integer;
	n2 : Integer;
	//
	b, r : Boolean;
	//
begin
	b := False;
	r := True;
	i := 0;
	Count := 0;
	//
	// -- hide the list to avoid flashing
	MapListErrors.Visible := False;
	//
	While i < MapListErrors.Items.Count Do
	Begin
		//
		Count := Count + 1;
		If ( Count And 15 ) = 0 Then
		Begin
			Status ( 'Checked ' + Comma ( Count ) + ' errors' );
		End;
		//
		If r Then
		Begin
			MapCheckErrors;
			i := 0;
		End;
		r := True;
		//
		s := MapListErrors.Items.Strings[i];
		//
		n := -1;
		n2 := -1;
		If Pos ( '#', s ) > 0 Then
		Begin
			s := RemoveFromLeft ( s, Pos ( '#', s ) );
			n := SafeVal ( Copy ( s, 1, Pos ( ' ', s ) - 1 ) );
			//
			If Pos ( '#', s ) > 0 Then
			Begin
				s := RemoveFromLeft ( s, Pos ( '#', s ) );
				n2 := Pos ( ' ', s ) - 1;
				n2 := SafeVal ( Copy ( s, 1, n2 ) );
				//
			End;
		End;
		//
		iError := SafeVal ( Copy ( KeepFromRight ( s, 6 ), 1, 5 ) );
		//
		Case iError Of

			13 : // zero length linedef
			Begin
				If ( n >= 0 ) Then
				Begin
					MapLineDefDelete ( n );
				End;
			End;

			14 : // extra back sidedef
			Begin
				If ( n >= 0 ) Then
				Begin
					LineDefs [ n ].SideBack := -1;
					b := True;
				End;
			End;

			100 : // duplicate vertex
			Begin
				If ( n >= 0 ) And ( n2 >= 0 ) Then
				Begin
					MapVertexReplace ( n2, n );
					MapVertexDelete ( n );
					b := True;
				End;
			End;

			200 : // unused sidedef
			Begin
				If n >= 0 Then
				Begin
					MapSideDefDelete ( n );
					r := False; // no need to refresh
					b := True;
				End;
			End;

			301 : // unused sector
			Begin
				If n >= 0 Then
				Begin
					MapSectorDelete ( n );
					r := False; // no need to refresh
					b := True;
				End;
			End;

			Else
			Begin
				//ShowMessage ( Comma ( iError ) );
				r := False;
				//
			End;

		End;
		//
		i := i + 1;
	End;
	//
	// -- show list again (if it's on)
	MapListErrors.Visible := mnuMapCheck.Checked;
	//
	If b Then
	Begin
		Modified ( True );
		MapModified := True;
		MapRefresh;
		EditMapZoom.SetFocus;
		//
		If mnuMapCheck.Checked Then
		Begin
			MapCheckErrors;
		End;
	End;
end;

procedure TFormMain.MapCheckErrors;

Var
	i, i2 : Integer;
	bUsed, bFront, bBack : Boolean;
	nErrors : Integer;
	s : String;
	ThingPlayerStarts : Array [ 1 .. 8 ] Of Boolean;
	//
	iFS, iBS : Integer; // front/back sectors
	iFrontC, iFrontF,
	iBackC, iBackF : Integer; // front/back ceiling/floor

Procedure AddError ( s : String; iErrorNumber : Integer );
Begin
	If iErrorNumber > 0 Then
		s := s + ' ($' + IntToHex(iErrorNumber,4) + ')';
	MapListErrors.Items.Add ( s );
	Inc ( nErrors );
End;

begin
	//
	// Check Map
	//
	MapListErrors.Items.Clear;
	Status ( 'Checking errors... (Things)' );
	//
	nErrors := 0;
	//
	If nThings < 0 Then
	Begin
		AddError ( 'Map has no Things', 1 );
	End
	Else
	Begin
		//
		For i := 1 To 8 Do
			ThingPlayerStarts [ i ] := False;
		//
		For i := 0 To nThings Do
		Begin
			//
			s := 'Thing ' + Comma ( i ) + ' ';
			//
			If ( ( Things [ i ].Flags And ( thngLevel12 Or thngLevel3 Or thngLevel45 ) ) = 0 )
			And ( ( Things [ i ].Flags And ( thngMulti ) ) = 0 ) Then
			Begin
				AddError ( s + 'never appears', 2 );
			End;
			//
			If ( ( Things [ i ].iType >= 1 ) And ( Things [ i ].iType <= 4 ) )
			Or ( ( Things [ i ].iType >= 4001 ) And ( Things [ i ].iType <= 4004 ) ) Then
			Begin
				i2 := Things [ i ].iType;
				If i2 > 4000 Then i2 := i2 - 4000 + 4;
				//
				If ThingPlayerStarts [ i2 ] Then
				Begin
					AddError ( s + 'is a duplicate Player ' + IntToStr ( i2 ) + ' start', 3 );
				End
				Else
				Begin
					ThingPlayerStarts [ i2 ] := True;
				End;
			End;
		End;
		//
		If Not ThingPlayerStarts [ 1 ] Then
		Begin
			AddError ( 'No Player 1 start', 4 );
		End;
	End;
	//
	Status ( 'Checking errors... (Linedefs)' );
	//
	If nLineDefs = 0 Then
	Begin
		AddError ( 'Map has no LineDefs', 10 );
	End
	Else
	Begin
		For i := 0 To nLineDefs Do
		Begin
			//
			s := 'LineDef #' + Comma ( i ) + ' ';
			//
			bFront := False;
			If LineDefs [ i ].SideFront = -1 Then
			Begin
				AddError ( s + 'has no front SideDef', 11 );
			End
			Else
			Begin
				If LineDefs [ i ].SideFront > nSideDefs Then
				Begin
					AddError ( s + 'references an invalid front SideDef', 12 );
				End
				Else
				Begin
					If LineDefs [ i ].VertexS = LineDefs [ i ].VertexE Then
					Begin
						AddError ( s + 'is zero length', 13 );
					End
					Else
					Begin
						bFront := True;
					End;
				End;
			End;
			//
			bBack := False;
			If ( LineDefs [ i ].Flags And ldefTwoSided ) = 0 Then
			Begin
				If LineDefs [ i ].SideBack <> -1 Then
				Begin
					AddError ( s + 'has back SideDef but is not Two Sided', 14 );
				End;
			End
			Else
			Begin
				If LineDefs [ i ].SideBack = -1 Then
				Begin
					AddError ( s + 'has no back SideDef', 15 );
				End
				Else
				Begin
					If LineDefs [ i ].SideFront > nSideDefs Then
					Begin
						AddError ( s + 'references an invalid back SideDef', 16 );
					End
					Else
					Begin
						bBack := True;
					End;
				End;
			End;
			//
			If bFront And bBack Then
			Begin
				//
				iFS := MapLineDefFrontSector ( i );
				iBS := MapLineDefBackSector ( i );
				//
				If ( iFS >= 0 ) And ( iFS <= nSectors )
				And ( iBS >= 0 ) And ( iBS <= nSectors ) Then
				Begin
					//
					iFrontF := Sectors [ iFS ].Floor;
					iFrontC := Sectors [ iFS ].Ceiling;
					//
					iBackF := Sectors [ iBS ].Floor;
					iBackC := Sectors [ iBS ].Ceiling;
					//
					If Not BeginsWith ( Sectors [ iFS ].FloorTex, 'F_SKY' )
					Or Not BeginsWith ( Sectors [ iBS ].FloorTex, 'F_SKY' ) Then
					Begin
						//
						If iFrontF > iBackF Then
						Begin
							If Trim ( SideDefs [ LineDefs [ i ].SideBack ].Below ) = '-' Then
							Begin
								AddError ( s + 'needs back below Texture', 17 );
							End;
						End
						Else
							If iFrontF < iBackF Then
							Begin
								If Trim ( SideDefs [ LineDefs [ i ].SideFront ].Below ) = '-' Then
								Begin
									AddError ( s + 'needs front below Texture', 18 );
								End;
							End;
						//
					End;
					//
					If Not BeginsWith ( Sectors [ iFS ].CeilingTex, 'F_SKY' )
					Or Not BeginsWith ( Sectors [ iBS ].CeilingTex, 'F_SKY' ) Then
					Begin
						If iFrontC > iBackC Then
						Begin
							If Trim ( SideDefs [ LineDefs [ i ].SideFront ].Above ) = '-' Then
							Begin
								AddError ( s + 'needs front above Texture', 19 );
							End;
						End
						Else
							If iFrontC < iBackC Then
							Begin
								If Trim ( SideDefs [ LineDefs [ i ].SideBack ].Above ) = '-' Then
								Begin
									AddError ( s + 'needs back above Texture', 20 );
								End;
							End;
						//
					End;
				End;
			End;
		End;
	End;
	//
	Status ( 'Checking errors... (Vertexes)' );
	//
	For i := 1 To nVertex Do
	Begin
		For i2 := 0 To i - 1 Do
		Begin
			If ( Vertex [ i ].x = Vertex [ i2 ].x )
			And ( Vertex [ i ].y = Vertex [ i2 ].y ) Then
			Begin
				AddError ( 'Vertex #' + Comma ( i ) + ' is a duplicate (same as #' + Comma ( i2 ) + ' )', 100 );
			End;
		End;
	End;
	//
	Status ( 'Checking errors... (Sidedefs)' );
	//
	For i := nSideDefs DownTo 0 Do
	Begin
		//
		If ( SideDefs [ i ].Sector < 0 )
		Or ( SideDefs [ i ].Sector > nSectors ) Then
		Begin
			s := 'SideDef #' + Comma ( i ) + ' ';
			AddError ( s + 'references an in valid sector', 201 );
		End;
		//
		bUsed := False;
		i2 := 0;
		While ( i2 <= nLineDefs ) And Not bUsed Do
		Begin
			If LineDefs [ i2 ].SideFront = i Then
				bUsed := True;
			If LineDefs [ i2 ].SideBack = i Then
				bUsed := True;
			//
			Inc ( i2 );
		End;
		//
		If Not bUsed Then
		Begin
			s := 'SideDef #' + Comma ( i ) + ' ';
			AddError ( s + 'is not used', 200 );
		End;
	End;
	//
	Status ( 'Checking errors... (Sectors)' );
	//
	For i := nSectors DownTo 0 Do
	Begin
		s := 'Sector #' + Comma ( i ) + ' ';
		//
		If Sectors [ i ].Ceiling < Sectors [ i ].Floor Then
		Begin
			AddError ( s + 'has invalid ceiling/floor heights', 300 );
		End;
		//
		bUsed := False;
		i2 := 0;
		While ( i2 <= nLineDefs ) And Not bUsed Do
		Begin
			If MapLineDefFrontSector ( i2 ) = i Then
				bUsed := True;
			If MapLineDefBackSector ( i2 ) = i Then
				bUsed := True;
			//
			Inc ( i2 );
		End;
		//
		If Not bUsed Then
		Begin
			AddError ( s + 'is not used', 301 );
		End;
	End;
	//
	Status ( Comma ( nErrors ) + ' error(s).' );
	AddError ( Comma ( nErrors ) + ' error(s).', 0 );
	//
	MapListErrors.Height := ImageMap.Height - ( MapListErrors.Top - ImageMap.Top );
end;

// ###

procedure TFormMain.MapTypeRefresh;
Begin
	mnuMapTypeDoom.Checked := ( MapType = mtDoom );
	mnuMapTypeZDoom.Checked := ( MapType = mtZDoom );
	//
	MapEditLineDefArg1.Visible := MapType = mtZDoom;
	MapEditLineDefArg2.Visible := MapType = mtZDoom;
	MapEditLineDefArg3.Visible := MapType = mtZDoom;
	MapEditLineDefArg4.Visible := MapType = mtZDoom;
	MapEditLineDefArg5.Visible := MapType = mtZDoom;
	//
	MapEditLDFlags10.Visible := MapType = mtZDoom;
	MapEditLDFlags11.Visible := MapType = mtZDoom;
	MapEditLDFlags12.Visible := MapType = mtZDoom;
	MapEditLineDefsActivate.Visible := MapType = mtZDoom;
	//
	Case MapType Of

		mtDoom :
		Begin
			LabelMapThingXYZ.Caption := 'X, Y';
			MapEditThingFlags5.Caption := 'Multi';
		End;

		mtZDoom :
		Begin
			LabelMapThingXYZ.Caption := 'X, Y, Z';
			MapEditThingFlags5.Caption := 'Dormant';
		End;

	End;
	//
	MapEditThingZ.Visible := MapType = mtZDoom;
	//
	MapEditThingFlags6.Visible := MapType = mtZDoom;
	MapEditThingFlags7.Visible := MapType = mtZDoom;
	MapEditThingFlags8.Visible := MapType = mtZDoom;
	MapEditThingFlags9.Visible := MapType = mtZDoom;
	MapEditThingFlags10.Visible := MapType = mtZDoom;
	MapEditThingFlags11.Visible := MapType = mtZDoom;
	//
	MapEditThingTag.Visible := MapType = mtZDoom;
	MapEditThingSpecial.Visible := MapType = mtZDoom;
	MapEditThingArg1.Visible := MapType = mtZDoom;
	MapEditThingArg2.Visible := MapType = mtZDoom;
	MapEditThingArg3.Visible := MapType = mtZDoom;
	MapEditThingArg4.Visible := MapType = mtZDoom;
	MapEditThingArg5.Visible := MapType = mtZDoom;
End;

procedure TFormMain.mnuMapTypeDoomClick(Sender: TObject);
begin
	MapType := mtDoom;
	MapTypeRefresh;
end;

procedure TFormMain.mnuMapTypeZDoomClick(Sender: TObject);
begin
	MapType := mtZDoom;
	MapTypeRefresh;
	//
end;

// ---

Procedure TFormMain.VertexCoords ( nV : Integer; Var x, y : Integer );
Begin
	x := MapX + Round ( ( Vertex [ nV ]. x - Vertex_sx ) / MapZoom );
	y := MapY - Round ( ( Vertex [ nV ]. y - Vertex_sy ) / MapZoom );
End;

Procedure TFormMain.VertexEditor;
Var
	i : Integer;
	x, y : Integer;
Begin
	VertexLoad ( iSel );
	//
	If PanelMap.Tag = 0 Then
	Begin
		PanelMap.Visible := True;
		ImageMap.Refresh;
		PanelMap.Tag := 1;
	End;

	With ImageMap Do
	Begin
		Picture.Bitmap.Width := Width;
		Picture.Bitmap.Height := Height;
		Canvas.Brush.Color := clAqua;
		Canvas.FillRect ( Canvas.ClipRect );
	End;
	//
	// *** Draw them
	//
	ImageMap.Canvas.Pen.Width := 3;
	//
	i := 0;
	While i <= nVertex Do
	Begin
		VertexCoords ( i, x, y );
		//
		ImageMap.Canvas.MoveTo ( x, y );
		ImageMap.Canvas.LineTo ( x, y );
		//
		Inc ( i );
	End;
	//
	ImageMap.Canvas.Pen.Width := 1;
	//
	ShowPage ( edMap );
	EditMapZoom.SetFocus;
end;

Procedure TFormMain.LineDefsEditor;
Begin
	If PanelMap.Tag = 0 Then
	Begin
		PanelMap.Visible := True;
		ImageMap.Refresh;
		PanelMap.Tag := 1;
	End;
	//
	With ImageMap Do
	Begin
		Picture.Bitmap.Width := Width;
		Picture.Bitmap.Height := Height;
	End;
	//
	VertexLoad ( iSel + 2 );
	//
	LineDefsRefresh;
End;

Procedure TFormMain.CoordsMapToScreen ( Var x, y : Integer );
Begin
	x := MapX + Round ( x * MapZoom );
	y := MapY - Round ( y * MapZoom );
End;

Procedure TFormMain.CoordsScreenToMap ( Var x, y : Integer );
Begin
	x := Round ( ( x - MapX ) / MapZoom );
	y := Round ( ( MapY - y ) / MapZoom );
End;

Procedure TFormMain.CoordsSnapToGrid ( Var x, y : Integer );
Begin
	X := ( ( X + MapGrid Shr 1 ) Or ( MapGrid - 1 ) ) - ( MapGrid - 1 );
	Y := ( ( Y + MapGrid Shr 1 ) Or ( MapGrid - 1 ) ) - ( MapGrid - 1 );
End;

Procedure TFormMain.MapSetZoom ( Zoom : Double );
Begin
	If ( Zoom < 500 ) Then
		MapZoom := Zoom
	Else
		MapZoom := 500;
	Status ( 'Zoom: ' + Comma ( Round ( MapZoom * 100 ) ) + '%' );
End;

Function TFormMain.MapZoomStep : Double;
Var
	d : Double;
Begin
	d := MapZoom / 5;
	If d < 0.05 Then
		d := 0.05;
	MapZoomStep := d;
	{
	If MapZoom >= 10 Then
		MapZoomStep := 1
	Else
		If MapZoom >= 5 Then
			MapZoomStep := 0.5
		Else
			If MapZoom >= 1 Then
				MapZoomStep := 0.1
			Else
				MapZoomStep := 0.05;
	}
End;

Procedure TFormMain.MapZoomIn;
Var
	x, y : Integer;
Begin
	If MapZoom < 500 Then
	Begin
		//
		// Save Center Coordinates
		//
		x := ImageMap.Width Div 2;
		y := ImageMap.Height Div 2;
		CoordsScreenToMap ( x, y );
		//
		MapSetZoom ( Round ( MapZoom * 20 ) / 20 + MapZoomStep );
		//
		// Re-center Map
		//
		MapX := Round ( x * -MapZoom + ( ImageMap.Width Div 2 ) );
		MapY := Round ( y * MapZoom + ( ImageMap.Height Div 2 ) );
		//
		MapRefresh;
		EditMapZoom.SetFocus;
	End;
End;

Procedure TFormMain.MapZoomOut;
Var
	x, y : Integer;
Begin
	If MapZoom > 0.1 Then
	Begin
		//
		// Save Center Coordinates
		//
		x := ImageMap.Width Div 2;
		y := ImageMap.Height Div 2;
		CoordsScreenToMap ( x, y );
		//
		MapSetZoom ( Round ( MapZoom * 20 ) / 20 - MapZoomStep );
		//
		// Re-center Map
		//
		MapX := Round ( x * -MapZoom + ( ImageMap.Width Div 2 ) );
		MapY := Round ( y * MapZoom + ( ImageMap.Height Div 2 ) );
		//
		MapRefresh;
		EditMapZoom.SetFocus;
	End;
End;

Procedure TFormMain.MapZoomAll;
Begin
	VertexCalcRange;
	//
	MapCenter ( Vertex_sx, Vertex_sy, Vertex_lx, Vertex_ly );
End;

Procedure TFormMain.MapCenter ( x0, y0, x1, y1 : Integer );
Var
	xr, yr : Double;
	xd, yd : Integer;
Begin
	If x0 > x1 Then
	Begin
		xd := x0;
		x0 := x1;
		x1 := xd;
	End;
	//
	If y0 > y1 Then
	Begin
		yd := y0;
		y0 := y1;
		y1 := yd;
	End;
	//
	xd := x1 - x0; // x difference between farthest vertexes
	yd := y1 - y0; // y difference between farthest vertexes
	//
	If ( xd = 0 )
	Or ( yd = 0 ) Then
	Begin
		xr := 1; // no vertexes yet
		yr := 1;
	End
	Else
	Begin
		xr := ( ( ImageMap.Width - 20 ) / xd ); // calc zoom
		yr := ( ( ImageMap.Height - 20 ) / yd );
	End;
	//
	If ( xr > yr ) Then
		xr := yr;
	MapSetZoom ( xr );
	//
	// --- Center map
	//
	MapX := Round ( -x0 * MapZoom +
		( ( ImageMap.Width - 20 ) - ( xd * MapZoom ) ) / 2 ) + 10;
	MapY := Round ( y1 * MapZoom +
		( ( ImageMap.Height - 20 ) - ( yd * MapZoom ) ) / 2 ) + 10;
End;

Procedure TFormMain.MapGridInc;
Begin
	If MapGrid < 65535 Then
	Begin
		MapGrid := MapGrid Shl 1;
		MapRefresh;
		EditMapZoom.SetFocus;
	End;
End;

Procedure TFormMain.MapGridDec;
Begin
	If MapGrid > 1 Then
	Begin
		MapGrid := MapGrid Shr 1;
		MapRefresh;
		EditMapZoom.SetFocus;
	End;
End;

Procedure TFormMain.mnuMapZoomInClick(Sender: TObject);
Begin
	MapZoomIn;
end;

procedure TFormMain.mnuMapZoomOutClick(Sender: TObject);
Begin
	MapZoomOut;
end;

procedure TFormMain.mnuMapZoomAllClick(Sender: TObject);
Begin
	MapZoomAll;
end;

procedure TFormMain.MapViewGridClick;
Begin
	mnuMapViewGrid.Checked := Not mnuMapViewGrid.Checked;
	//
	If mnuMapViewGrid.Checked Then
		MapGridButton.Down := True
	Else
		MapGridButton2.Down := True;
End;

procedure TFormMain.mnuMapViewGridClick(Sender: TObject);
begin
	MapViewGridClick;
	//
	MapRefresh;
	EditMapZoom.SetFocus;
end;

procedure TFormMain.mnuMapViewShowThingsClick(Sender: TObject);
begin
	mnuMapViewShowThings.Checked := Not mnuMapViewShowThings.Checked;
	// 
	MapRefresh;
	EditMapZoom.SetFocus;
end;

procedure TFormMain.MapGridButtonClick(Sender: TObject);
begin
	mnuMapViewGridClick(Sender);
end;

procedure TFormMain.mnuMapGridIncClick(Sender: TObject);
Begin
	MapGridInc;
end;

procedure TFormMain.mnuMapGridDecClick(Sender: TObject);
Begin
	MapGridDec;
end;

procedure TFormMain.mnuMapView3DClick(Sender: TObject);
begin
	mnuMapView3D.Checked := Not mnuMapView3D.Checked;
	MapRefresh;
	EditMapZoom.SetFocus;
end;

procedure TFormMain.mnuMapDisplayLinedefLengthsClick(Sender: TObject);
begin
	mnuMapDisplayLinedefLengths.Checked := Not mnuMapDisplayLinedefLengths.Checked;
	MapRefresh;
	EditMapZoom.SetFocus;
end;

// *** Toolbars ***
procedure TFormMain.mnuMapViewPropertiesBarClick(Sender: TObject);
begin
	mnuMapViewPropertiesBar.Checked := Not mnuMapViewPropertiesBar.Checked;
	//
	MapViewPropertiesBarRefresh;
	//
	PanelMap.Tag := 0;
	//
	MapRefresh;
	EditMapZoom.SetFocus;
end;

Procedure TFormMain.MapViewPropertiesBarRefresh;
Begin
	If mnuMapViewPropertiesBar.Checked Then
	Begin
		Case MapMode Of
			mmThings : MapShowPanel ( mmThings );
			mmSectors : MapShowPanel ( mmSectors );
			mmVertex : MapShowPanel ( mmVertex );
			Else MapShowPanel ( mmLineDefs );
		End;
	End
	Else
	Begin
		PanelMapLineDefs.Visible := False;
		PanelMapSectors.Visible := False;
		PanelMapThings.Visible := False;
		PanelMapVertex.Visible := False;
	End;
End;

procedure TFormMain.mnuMapViewWadedBarClick(Sender: TObject);
begin
	mnuMapViewWadedBar.Checked := Not mnuMapViewWadedBar.Checked;
	PanelMapWaded.Visible := mnuMapViewWadedBar.Checked;
	//
	PanelMap.Tag := 0;
	//
	MapRefresh;
	EditMapZoom.SetFocus;
end;

procedure TFormMain.MapModeAllClick(Sender: TObject);
begin
	MapSetMode ( mmAll );
end;

procedure TFormMain.MapModeThingsClick(Sender: TObject);
begin
	MapSetMode ( mmThings );
end;

procedure TFormMain.MapModeLineDefsClick(Sender: TObject);
begin
	MapSetMode ( mmLineDefs );
end;

procedure TFormMain.MapModeSectorsClick(Sender: TObject);
begin
	MapSetMode ( mmSectors );
end;

procedure TFormMain.MapModeDrawClick(Sender: TObject);
begin
	MapSetMode ( mmDraw );
end;

Procedure TFormMain.MapRenderThing ( iType, x, y, Angle : Integer );
Var
	i : Integer;
	s, st : String;
Begin
	With ImageMap.Canvas Do
	Begin
		//
		s := ConstantFindDescription ( 'THINGTYPES', iType );
		i := SafeVal ( Copy ( s, 1, Pos ( ',', s ) ) );
		//
		If i = 0 Then
		Begin
			//
			Brush.Color := clSilver;
			i := 16;
			//
		End
		Else
		Begin
			//
			st := ConstantFindDescription ( 'THINGCLASSES', i );
			st := RemoveFromLeft ( st, Pos ( ',', st ) );
			Brush.Color := SafeVal ( Copy ( st, 1, Pos ( ',', st ) ) ); // color
			//
			s := RemoveFromLeft ( s, Pos ( ',', s ) );
			i := SafeVal ( Copy ( s, 1, Pos ( ',', s ) ) ); // size
			//
		End;
		//
		// convert size to map coords
		i := Round ( i * MapZoom / 2 );
		//
		Rectangle ( Classes.Rect ( x - i, y - i, x + i + 1, y + i + 1 ) );
		Pen.Color := clBlack;
		//
		If i > 2 Then
		Begin
			i := i * 3 Div 4;
		End;
		//
		If i > 1 Then
		Begin
			//
			Angle := ( Angle Mod 360 ) Div 45 * 45;
			//
			Case Angle Of

				0 : // east
				Begin
					MoveTo ( x, y - i );
					LineTo ( x + i, y );
					LineTo ( x, y + i );
					LineTo ( x, y - i );
				End;

				45 : // ne
				Begin
					MoveTo ( x - i, y - i );
					LineTo ( x + i, y - i );
					LineTo ( x + i, y + i );
					LineTo ( x - i, y - i );
				End;

				90 : // north
				Begin
					MoveTo ( x - i, y );
					LineTo ( x + i, y );
					LineTo ( x, y - i );
					LineTo ( x - i, y );
				End;

				135 : // nw
				Begin
					MoveTo ( x + i, y - i );
					LineTo ( x - i, y - i );
					LineTo ( x - i, y + i );
					LineTo ( x + i, y - i );
				End;

				180 : // west
				Begin
					MoveTo ( x, y - i );
					LineTo ( x - i, y );
					LineTo ( x, y + i );
					LineTo ( x, y - i );
				End;

				225 : // sw
				Begin
					MoveTo ( x + i, y + i );
					LineTo ( x - i, y + i );
					LineTo ( x - i, y - i );
					LineTo ( x + i, y + i );
				End;

				270 : // south
				Begin
					MoveTo ( x - i, y );
					LineTo ( x + i, y );
					LineTo ( x, y + i );
					LineTo ( x - i, y );
				End;

				315 : // se
				Begin
					MoveTo ( x - i, y + i );
					LineTo ( x + i, y + i );
					LineTo ( x + i, y - i );
					LineTo ( x - i, y + i );
				End;
			End;
		End;
		//
		If i > 8 Then
		Begin
			MoveTo ( x - 2, y - 2 );
			LineTo ( x + 3, y + 3 );
			MoveTo ( x - 2, y + 2 );
			LineTo ( x + 3, y - 3 );
		End;
	End;
End;

Procedure TFormMain.MapDeselectAll;
Var
	i : Integer;
Begin
	For i := 0 To nThings Do
		Things [ i ].Selected := False;
	For i := 0 To nLineDefs Do
		LineDefs [ i ].Selected := False;
	For i := 0 To nSideDefs Do
		SideDefs [ i ].Selected := False;
	For i := 0 To nVertex Do
		Vertex [ i ].Selected := False;
	For i := 0 To nSectors Do
		Sectors [ i ].Selected := False;
End;

Procedure TFormMain.MapDeHighlightAll;
Var
	i : Integer;
Begin
	For i := 0 To nThings Do
		Things [ i ].Highlighted := False;
	For i := 0 To nLineDefs Do
		LineDefs [ i ].Highlighted := False;
	For i := 0 To nSideDefs Do
		SideDefs [ i ].Highlighted := False;
	For i := 0 To nVertex Do
		Vertex [ i ].Highlighted := False;
	For i := 0 To nSectors Do
		Sectors [ i ].Highlighted := False;
	//
	MapHighlight := 0;
End;

Function TFormMain.MapGetValue ( e : TEdit ) : TValue;
Var
	v : TValue;
	s : String;
Begin
	If e.Text = '(mul)' Then
	Begin
		v.Value := 0;
		v.Diff := 0;
		v.Kind := valMultiple;
	End
	Else
	Begin
		s := Trim ( e.Text );
		//
		If Copy ( s, 1, 2 ) = '++' Then
		Begin
			v.Kind := valAdd; // simple add
			v.Diff := 0;
			s := RemoveFromLeft ( s, 2 ); // cut ++ from string
		End
		Else
		Begin
			If Copy ( s, 1, 2 ) = '--' Then
			Begin
				v.Kind := valSub;
				v.Diff := 0;
				s := RemoveFromLeft ( s, 2 );
			End
			Else
			Begin
				If Copy ( s, 1, 2 ) = '#+' Then
				Begin
					v.Kind := valInc; // increment add
					s := RemoveFromLeft ( s, 2 ); // cut #+
					v.Diff := SafeVal ( s ); // store the increment
				End
				Else
				Begin
					If Copy ( s, 1, 2 ) = '#-' Then
					Begin
						v.Kind := valDec;
						s := RemoveFromLeft ( s, 2 );
						v.Diff := SafeVal ( s );
					End
					Else
					Begin
						If Copy ( s, 1, 1 ) = '*' Then
						Begin
							v.Kind := valMultiply;
							s := RemoveFromLeft ( s, 1 );
							v.Diff := SafeVal ( s );
						End
						Else
						Begin
							If Copy ( s, 1, 1 ) = '/' Then
							Begin
								v.Kind := valDivide;
								s := RemoveFromLeft ( s, 1 );
								v.Diff := SafeVal ( s );
							End
							Else
							Begin
								v.Kind := valDirect;
							End;
						End;
					End;
				End;
			End;
		End;
		//
		v.Value := SafeVal ( s );
	End;
	//
	MapGetValue := v;
End;

Procedure TFormMain.MapCheckFlag ( c : TCheckBox; i : Integer; Var FlagOr, FlagAnd : Integer );
Begin
	If c.State = cbChecked Then
	Begin
		FlagOr := FlagOr Or i;
	End
	Else
	Begin
		If c.State = cbUnchecked Then
		Begin
			FlagAnd := FlagAnd Xor i;
		End
	End;
End;

Procedure TFormMain.MapSetInt ( Var i : Integer; Var iValue : TValue );
Begin
	Case iValue.Kind Of

		valDirect :
		Begin
			i := iValue.Value;
		End;

		valAdd :
		Begin
			i := i + iValue.Value;
		End;

		valSub :
		Begin
			i := i - iValue.Value;
		End;

		valInc :
		Begin
			i := i + iValue.Value;
			iValue.Value := iValue.Value + iValue.Diff;
		End;

		valDec :
		Begin
			i := i - iValue.Value;
			iValue.Value := iValue.Value + iValue.Diff;
		End;

		valMultiply :
		Begin
			i := i * iValue.Value;
		End;

		valDivide :
		Begin
			i := i Div iValue.Value;
		End;

	End;
End;

Procedure TFormMain.MapSetString ( Var s : String; sValue : String );
Begin
	If sValue <> '(multiple)' Then
	Begin
		s := sValue;
	End;
End;

procedure TFormMain.MapEditThingAngleChange(Sender: TObject);
Var
	iAngle : Integer;
begin
	iAngle := SafeVal ( MapEditThingAngle.Text );
	Case iAngle Of
		000 : MapThingAngleRad000.Checked := True;
		045 : MapThingAngleRad045.Checked := True;
		090 : MapThingAngleRad090.Checked := True;
		135 : MapThingAngleRad135.Checked := True;
		180 : MapThingAngleRad180.Checked := True;
		225 : MapThingAngleRad225.Checked := True;
		270 : MapThingAngleRad270.Checked := True;
		315 : MapThingAngleRad315.Checked := True;
	End;
end;

procedure TFormMain.MapThingAngleRad000Click(Sender: TObject);
begin
	MapEditThingAngle.Text := '0';
end;

procedure TFormMain.MapThingAngleRad045Click(Sender: TObject);
begin
	MapEditThingAngle.Text := '45';
end;

procedure TFormMain.MapThingAngleRad090Click(Sender: TObject);
begin
	MapEditThingAngle.Text := '90';
end;

procedure TFormMain.MapThingAngleRad135Click(Sender: TObject);
begin
	MapEditThingAngle.Text := '135';
end;

procedure TFormMain.MapThingAngleRad180Click(Sender: TObject);
begin
	MapEditThingAngle.Text := '180';
end;

procedure TFormMain.MapThingAngleRad225Click(Sender: TObject);
begin
	MapEditThingAngle.Text := '225';
end;

procedure TFormMain.MapThingAngleRad270Click(Sender: TObject);
begin
	MapEditThingAngle.Text := '270';
end;

procedure TFormMain.MapThingAngleRad315Click(Sender: TObject);
begin
	MapEditThingAngle.Text := '315';
end;

procedure TFormMain.MapEditThingAngleKeyPress(Sender: TObject;
	var Key: Char);
Var
	i : Integer;
begin
	Case Key Of

		#43 : { plus }
		Begin
			i := SafeVal ( MapEditThingAngle.Text );
			i := ( ( i Div 45 ) * 45 + 45 ) Mod 360;
			MapEditThingAngle.Text := IntToStr ( i );
			//
			Key := #0;
		End;

		#45 : { minus }
		Begin
			i := SafeVal ( MapEditThingAngle.Text );
			i := ( ( i Div 45 ) * 45 + 315 ) Mod 360;
			MapEditThingAngle.Text := IntToStr ( i );
			//
			Key := #0;
		End;

	End;
end;

Procedure TFormMain.MapThingImageRender ( sSpriteName : String );
Var
	ID : Integer;
	xs, ys, xr, yr : Integer;
	i1, i2 : Integer;
	Zoom : Double;
	f : TImageFormat;
Begin
	sSpriteName := Trim ( UpperCase ( sSpriteName ) );
	//
	ID := FindEntry ( sSpriteName );
	//
	xs := 0;
	If ID > 0 Then
	Begin
		f := ImageIdentifyFile ( sFileName, WadEntries [ ID ].Position, WadEntries [ ID ].Size, xs, ys, xr, yr );
		ImageLoad ( sFileName, WadEntries [ ID ].Position, WadEntries [ ID ].Size, xs, ys, xr, yr, f );
	End
	Else
	Begin
		ID := FindEntryInMain ( sSpriteName );
		If ID > 0 Then
		Begin
			f := ImageIdentifyFile ( sMainWAD, MainWadEntries [ ID ].Position, MainWadEntries [ ID ].Size, xs, ys, xr, yr );
			ImageLoad ( sMainWAD, MainWadEntries [ ID ].Position, MainWadEntries [ ID ].Size, xs, ys, xr, yr, f );
		End;
	End;
	//
	If xs > 0 Then
	Begin
		If xs > ys Then
		Begin
			i1 := xs;
			i2 := MapImageThing.Width;
		End
		Else
		Begin
			i1 := ys;
			i2 := MapImageThing.Height;
		End;
		//
		If i1 * 3 < i2 Then
			Zoom := 3
		Else
			If i1 * 2 < i2 Then
				Zoom := 2
			Else
				If i1 * 3 Div 2 < i2 Then
					Zoom := 1.5
				Else
					If i1 >= i2 Then
						Zoom := i2 / i1
					Else
						Zoom := 1;
		//
		ImageRenderCurrentAt ( MapImageThing.Canvas,
			Round ( ( MapImageThing.Width - xs * Zoom ) / 2 ),
			Round ( ( MapImageThing.Height - ys * Zoom ) / 2 ), Zoom );
	End;
End;

procedure TFormMain.MapEditTypeChange(Sender: TObject);
Var
	ID : Integer;
	s, sp : String;
begin
	//
	MapImageThing.Canvas.Brush.Color := RGB ( 128, 96, 64 );
	MapImageThing.Canvas.FillRect ( MapImageThing.Canvas.ClipRect );
	//
	If TEdit ( Sender ).Text = '(mul)' Then
	Begin
		MapImageThing.Canvas.Font.Name := 'TAHOMA';
		MapImageThing.Canvas.TextOut ( 6, 6, 'multiple' );
		MapImageThing.Canvas.TextOut ( 6, 20, 'selection' );
		//
		lblThing.Caption := '';
	End
	Else
	Begin
		ID := SafeVal ( TEdit ( Sender ).Text );
		//
		If ID > 0 Then
		Begin
			s := ConstantFindDescription ( 'THINGTYPES', ID );
			//
			SplitAtMark ( s, sp, ',' );
			SplitAtMark ( sp, s, ',' );
			SplitAtMark ( s, sp, ',' );
			lblThing.Caption := RemoveQuotes ( sp );
			//
			MapThingImageRender ( s );
		End
		Else
		Begin
			//
			lblThing.Caption := '';
		End;
	End;
end;

procedure TFormMain.MapEditTypeKeyPress(Sender: TObject; var Key: Char);
begin
	Case Key Of

		#43 :
		Begin
			TEdit ( Sender ).Text := Comma ( SafeVal ( TEdit ( Sender ).Text ) + 1 );
			Key := #0;
		End;

		#45 :
		Begin
			TEdit ( Sender ).Text := Comma ( SafeVal ( TEdit ( Sender ).Text ) - 1 );
			Key := #0;
		End;

	End;
end;

procedure TFormMain.MapPickThingClick(Sender: TObject);
Begin
	MapListShow ( 'THING', MapEditType.Text );
End;

procedure TFormMain.MapPickLineDefClick(Sender: TObject);
begin
	MapListShow ( 'LINEDEF', MapEditLineDefType.Text );
end;

procedure TFormMain.MapPickSectorClick(Sender: TObject);
begin
	MapListShow ( 'SECTOR', MapEditSectorType.Text );
end;

procedure TFormMain.MapListShow ( sObject, sID : String );
Var
	i : Integer;
	c, ID : Integer;
	s : String;
begin
	MapList := sObject;
	MapListClasses.Items.Clear;
	//
	c := ConstantFind ( sObject + 'CLASSES' );
	For i := 0 To Constants [ c ]. ValueCount - 1 Do
	Begin
		s := ConstantValues [ Constants [ c ]. ValueStart + i ].Description;
		MapListClasses.Items.Add ( s );
	End;
	//
	With MapPanelList Do
	Begin
		Left := ImageMap.Left + 10;
		Top := ImageMap.Top + 10;
		Width := ImageMap.Width - 20;
		Height := ImageMap.Height - 20;
	End;
	//
	With MapListClasses Do
	Begin
		Left := 10;
		Top := 10;
		Width := 120;
		Height := MapPanelList.Height - 10 * 3 - MapListOK.Height;
	End;
	MapListOK.Left := 10;
	MapListOK.Top := MapPanelList.Height - 10 - MapListOK.Height;
	MapListCancel.Left := 10 * 2 + 75;
	MapListCancel.Top := MapListOK.Top;
	//
	ID := SafeVal ( sID );
	//
	s := ConstantFindDescription ( sObject + 'TYPES', ID );
	c := SafeVal ( Copy ( s, 1, Pos ( ',', s ) - 1 ) );
	//
	If c = 0 Then c := 1;
	//
	MapListClasses.ItemIndex := c - 1;
	MapListTypesUpdate ( ID );
	//
	MapPanelList.Visible := True;
end;

procedure TFormMain.MapListClassesClick ( Sender: TObject );
Begin
	MapListTypesUpdate ( -1 );
End;

procedure TFormMain.MapListTypesUpdate ( iSelect : Integer );
Var
	i, iValue : Integer;
	iClass : Integer;
	c, cl : Integer;
	s : String;
begin
	MapListTypes.Items.Clear;
	//
	iClass := MapListClasses.ItemIndex + 1;
	//
	c := ConstantFind ( MapList + 'TYPES' );
	For i := 0 To Constants [ c ]. ValueCount - 1 Do
	Begin
		s := ConstantValues [ Constants [ c ]. ValueStart + i ].Description;
		//
		cl := SafeVal ( Copy ( s, 1, Pos ( ',', s ) ) );
		//
		If cl = iClass Then
		Begin
			iValue := ConstantValues [ Constants [ c ]. ValueStart + i ].Value;
			MapListTypes.Items.Add ( s + ',' + IntToStr ( iValue ) );
			//
			If iSelect >= 0 Then
			Begin
				If iSelect = iValue Then
				Begin
					MapListTypes.ItemIndex := MapListTypes.Items.Count - 1;
				End;
			End;
		End;
	End;
	//
	With MapListTypes Do
	Begin
		Left := MapListClasses.Left + MapListClasses.Width + 10;
		Top := MapListClasses.Top;
		Width := MapPanelList.Width - Left - 10;
		Height := MapListClasses.Height;
	End;
	//
end;

procedure TFormMain.MapListCancelClick(Sender: TObject);
begin
	// Cancel : hide panel, no change
	MapPanelList.Visible := False;
end;

procedure TFormMain.MapListOKClick(Sender: TObject);
var
	s : String;
	ID : Integer;
begin
	// OK : hide panel, update thing number
	MapPanelList.Visible := False;
	//
	If MapListTypes.ItemIndex >= 0 Then
	Begin
		s := MapListTypes.Items [ MapListTypes.ItemIndex ];
		s := RemoveFromLeft ( s, PosR ( ',', s ) );
		//
		ID := SafeVal ( s );
		//
		If ID > 0 Then
		Begin
			//
			If MapList = 'THING' Then
				MapEditType.Text := IntToStr ( ID )
			Else If MapList = 'LINEDEF' Then
				MapEditLineDefType.Text := IntToStr ( ID )
			Else If MapList = 'SECTOR' Then
				MapEditSectorType.Text := IntToStr ( ID );
		End;
	End;
end;

// *********

procedure TFormMain.MapListClassesDrawItem(Control: TWinControl;
	Index: Integer; Rect: TRect; State: TOwnerDrawState);
Var
	Offset: Integer;      { text offset width }
	s : String;
	x, y, xs : Integer;
Begin
	With (Control as TListBox).Canvas Do  { draw on control canvas, not on the form }
	Begin
		//
		FillRect ( Rect ); { clear the rectangle }
		x := Rect.Left + 1;
		y := Rect.Top + 1;
		xs := Rect.Bottom - Rect.Top - 2;
		Offset := 2;       { provide default offset }
		//
		s := (Control as TListBox).Items[Index];
		//
		If MapList = 'THING' Then
		Begin
			//
			Inc ( Offset, xs );
			//
			s := RemoveFromLeft ( s, Pos ( ',', s ) );
			Brush.Color := SafeVal ( Copy ( s, 1, Pos ( ',', s ) - 1 ) );
			FillRect ( Classes.Rect ( x + 1, y + 1, x + xs - 1, y + xs - 1 ) );
			//
			s := RemoveQuotes ( RemoveFromLeft ( s, Pos ( ',', s ) ) );
			Brush.Style := bsClear;
			//
		End
		Else
		Begin
			If MapList = 'LINEDEF' Then
			Begin
				s := RemoveQuotes ( RemoveFromLeft ( s, Pos ( ',', s ) ) );
			End
			Else
			Begin
				If MapList = 'SECTOR' Then
				Begin
					s := RemoveQuotes ( RemoveFromLeft ( s, Pos ( ',', s ) ) );
				End;
			End;
		End;
		//
		TextOut ( Rect.Left + Offset, Rect.Top, s );  { display the text }
		//
	end;
end;

procedure TFormMain.MapListTypesDrawItem(Control: TWinControl;
	Index: Integer; Rect: TRect; State: TOwnerDrawState);
Var
	Offset: Integer;      { text offset width }
	s : String;
Begin
	With (Control as TListBox).Canvas Do  { draw on control canvas, not on the form }
	Begin
		//
		FillRect ( Rect ); { clear the rectangle }
		Offset := 2;       { provide default offset }
		//
		s := (Control as TListBox).Items[Index];
		//
		If MapList = 'THING' Then
		Begin
			s := RemoveFromLeft ( s, Pos ( ',', s ) );
			s := RemoveFromLeft ( s, Pos ( ',', s ) );
			s := RemoveFromLeft ( s, Pos ( ',', s ) );
		End
		Else
		Begin
			If MapList = 'LINEDEF' Then
			Begin
				s := RemoveFromLeft ( s, Pos ( ',', s ) );
			End
			Else
			Begin
				If MapList = 'SECTOR' Then
				Begin
					s := RemoveFromLeft ( s, Pos ( ',', s ) );
				End;
			End;
		End;
		//
		s := RemoveFromLeft ( s, 1 );
		TextOut ( Rect.Left + Offset, Rect.Top, Copy ( s, 1, Pos ( '"', s ) - 1 ) );  { display the text }
		//
		s := RemoveFromLeft ( s, Pos ( '"', s ) + 1 );
		TextOut ( Rect.Left + Rect.Right - Offset - TextWidth ( s ), Rect.Top, s );  { display id }
		//
	end;
end;

procedure TFormMain.MapThingsApplyClick(Sender: TObject);
var
	iThing : Integer;
	//
	iThingType : TValue;
	iThingX : TValue;
	iThingY : TValue;
	iThingZ : TValue;
	iAngle : TValue;
	//
	iSpecial : TValue;
	iArg1,
	iArg2,
	iArg3,
	iArg4,
	iArg5 : TValue;
	//
	iTag : TValue;
	//
	iFlagsAnd, iFlagsOr : Integer;
	//
	bChanged : Boolean;
	//
begin
	bChanged := False;
	//
	iThingType := MapGetValue ( MapEditType );
	iThingX := MapGetValue ( MapEditThingX );
	iThingY := MapGetValue ( MapEditThingY );
	iThingZ := MapGetValue ( MapEditThingZ );
	iAngle := MapGetValue ( MapEditThingAngle );
	//
	iSpecial := MapGetValue ( MapEditThingSpecial );
	iArg1 := MapGetValue ( MapEditThingArg1 );
	iArg2 := MapGetValue ( MapEditThingArg2 );
	iArg3 := MapGetValue ( MapEditThingArg3 );
	iArg4 := MapGetValue ( MapEditThingArg4 );
	iArg5 := MapGetValue ( MapEditThingArg5 );
	//
	iTag := MapGetValue ( MapEditThingTag );
	//
	// --- Save for later
	//
	If iThingType.Kind = valDirect Then
		MapLastThingType := iThingType.Value;
	If iAngle.Kind = valDirect Then
		MapLastThingAngle := iAngle.Value;
	//
	iFlagsAnd := $FFFF;
	iFlagsOr := 0;
	//
	MapCheckFlag ( MapEditThingFlags1, thngLevel12, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditThingFlags2, thngLevel3, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditThingFlags3, thngLevel45, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditThingFlags4, thngDeaf, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditThingFlags5, thngMulti, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditThingFlags6, thngFighter, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditThingFlags7, thngCleric, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditThingFlags8, thngMage, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditThingFlags9, thngSingle, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditThingFlags10, thngCoop, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditThingFlags11, thngDeathmatch, iFlagsOr, iFlagsAnd );
	//
	For iThing := 0 To nThings Do
	Begin
		If Things [ iThing ].Selected Then
		Begin
			//
			MapSetInt ( Things [ iThing ].iType, iThingType );
			MapSetInt ( Things [ iThing ].x, iThingX );
			MapSetInt ( Things [ iThing ].y, iThingY );
			MapSetInt ( Things [ iThing ].z, iThingZ );
			MapSetInt ( Things [ iThing ].Angle, iAngle );
			//
			MapSetInt ( Things [ iThing ].Special, iSpecial );
			MapSetInt ( Things [ iThing ].Arg1, iArg1 );
			MapSetInt ( Things [ iThing ].Arg2, iArg2 );
			MapSetInt ( Things [ iThing ].Arg3, iArg3 );
			MapSetInt ( Things [ iThing ].Arg4, iArg4 );
			MapSetInt ( Things [ iThing ].Arg5, iArg5 );
			//
			MapSetInt ( Things [ iThing ].Tag, iTag );
			//
			Things [ iThing ].Flags := ( Things [ iThing ].Flags And iFlagsAnd ) Or iFlagsOr;
			//
			bChanged := True;
		End;
	End;
	//
	If bChanged Then
	Begin
		Modified ( True );
		MapRefresh;
	End;
	//
	EditMapZoom.SetFocus;
end;

procedure TFormMain.MapTextureApplyClick(Sender: TObject);
Var
	iSideDef : Integer;
	iLineDef : Integer;
	//
	sFrontAbove : String;
	sFrontMain : String;
	sFrontBelow : String;
	sBackAbove : String;
	sBackMain : String;
	sBackBelow : String;
	//
	iTag, iType : TValue;
	//
	iArg1, iArg2, iArg3, iArg4, iArg5 : TValue;
	//
	iFrontX : TValue;
	iFrontY : TValue;
	iBackX : TValue;
	iBackY : TValue;
	iFrontSector, iBackSector : TValue;
	//
	iFlagsAnd, iFlagsOr : Integer;

Function GetTexture ( iSideDef : Integer; sTexture : String ) : String;
Begin
	If sTexture = '*A' Then
	Begin
		GetTexture := SideDefs [ iSideDef ].Above;
	End
	Else
	Begin
		If sTexture = '*M' Then
		Begin
			GetTexture := SideDefs [ iSideDef ].Main;
		End
		Else
		Begin
			If sTexture = '*B' Then
			Begin
				GetTexture := SideDefs [ iSideDef ].Below;
			End
			Else
			Begin
				GetTexture := sTexture;
			End;
		End;
	End;
End;

Begin
	//
	// --- Get all values from the screen (editboxes)
	//
	sFrontAbove := MapEditFrontAbove.Text;
	sFrontMain := MapEditFrontMain.Text;
	sFrontBelow := MapEditFrontBelow.Text;
	//
	sBackAbove := MapEditBackAbove.Text;
	sBackMain := MapEditBackMain.Text;
	sBackBelow := MapEditBackBelow.Text;
	//
	iFrontX := MapGetValue ( MapEditFrontX );
	iFrontY := MapGetValue ( MapEditFrontY );
	iBackX := MapGetValue ( MapEditBackX );
	iBackY := MapGetValue ( MapEditBackY );
	iFrontSector := MapGetValue ( MapEditFrontSector );
	iBackSector := MapGetValue ( MapEditBackSector );
	//
	iTag := MapGetValue ( MapEditLineDefTag );
	iType := MapGetValue ( MapEditLineDefType );
	//
	iArg1 := MapGetValue ( MapEditLineDefArg1 );
	iArg2 := MapGetValue ( MapEditLineDefArg2 );
	iArg3 := MapGetValue ( MapEditLineDefArg3 );
	iArg4 := MapGetValue ( MapEditLineDefArg4 );
	iArg5 := MapGetValue ( MapEditLineDefArg5 );
	//
	// --- Get flags
	//
	iFlagsAnd := $FFFF;
	iFlagsOr := 0;
	//
	MapCheckFlag ( MapEditLDFlags1, ldefImpassable, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditLDFlags2, ldefBlockMonsters, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditLDFlags3, ldefTwoSided, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditLDFlags4, ldefUpperUnpegged, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditLDFlags5, ldefLowerUnpegged, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditLDFlags6, ldefSecret, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditLDFlags7, ldefBlockSound, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditLDFlags8, ldefNeverMap, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditLDFlags9, ldefAlwaysMap, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditLDFlags10, ldefRepeatable, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditLDFlags11, ldefEnemyActivate, iFlagsOr, iFlagsAnd );
	MapCheckFlag ( MapEditLDFlags12, ldefBlockEverything, iFlagsOr, iFlagsAnd );
	//
	// --- Activate flags
	//
	If MapEditLineDefsActivate.ItemIndex <> 8 Then
	Begin
		// not multiple
		//
		// "and" out bits 10,11,12
		iFlagsAnd := iFlagsAnd And $E3FF;
		//
		// "or" in the necessary bits
		iFlagsOr := iFlagsOr Or ( MapEditLineDefsActivate.ItemIndex ) Shl 10;
	End;
	//
	// ----------------------------
	//
	For iLineDef := 0 To nLineDefs Do
	Begin
		If LineDefs [ iLineDef ].Selected Then
		Begin
			//
			LineDefs [ iLineDef ].Flags := ( LineDefs [ iLineDef ].Flags And iFlagsAnd ) Or iFlagsOr;
			//
			MapSetInt ( LineDefs [ iLineDef ].Tag, iTag );
			MapSetInt ( LineDefs [ iLineDef ].iType, iType );
			//
			MapSetInt ( LineDefs [ iLineDef ].Arg1, iArg1 );
			MapSetInt ( LineDefs [ iLineDef ].Arg2, iArg2 );
			MapSetInt ( LineDefs [ iLineDef ].Arg3, iArg3 );
			MapSetInt ( LineDefs [ iLineDef ].Arg4, iArg4 );
			MapSetInt ( LineDefs [ iLineDef ].Arg5, iArg5 );
			//
			iSideDef := LineDefs [ iLineDef ].SideFront;
			If iSideDef >= 0 Then
			Begin
				MapSetString ( SideDefs [ iSideDef ].Above, GetTexture ( iSideDef, sFrontAbove ) );
				MapSetString ( SideDefs [ iSideDef ].Main, GetTexture ( iSideDef, sFrontMain ) );
				MapSetString ( SideDefs [ iSideDef ].Below, GetTexture ( iSideDef, sFrontBelow ) );
				//
				MapSetInt ( SideDefs [ iSideDef ].xOffset, iFrontX );
				MapSetInt ( SideDefs [ iSideDef ].yOffset, iFrontY );
				MapSetInt ( SideDefs [ iSideDef ].Sector, iFrontSector );
			End;
			//
			// --- Check for two sided being turned on
			//
			If ( iFlagsOr And ldefTwoSided ) <> 0 Then
			Begin
				// Yes, check if linedef has back side
				If LineDefs [ iLineDef ].SideBack < 0 Then
				Begin
					// No, add a new sidedef
					MapSideDefAddSectorMain ( -1, '-' );
					LineDefs [ iLineDef ].SideBack := nSideDefs;
				End;
			End;
			//
			iSideDef := LineDefs [ iLineDef ].SideBack;
			If iSideDef >= 0 Then
			Begin
				MapSetString ( SideDefs [ iSideDef ].Above, GetTexture ( iSideDef, sBackAbove ) );
				MapSetString ( SideDefs [ iSideDef ].Main, GetTexture ( iSideDef, sBackMain ) );
				MapSetString ( SideDefs [ iSideDef ].Below, GetTexture ( iSideDef, sBackBelow ) );
				//
				MapSetInt ( SideDefs [ iSideDef ].xOffset, iBackX );
				MapSetInt ( SideDefs [ iSideDef ].yOffset, iBackY );
				MapSetInt ( SideDefs [ iSideDef ].Sector, iBackSector );
			End;
			//
			Modified ( True );
		End;
	End;
	//
	MapUpdateLineDefProperties ( True );
	//
	EditMapZoom.SetFocus;
end;

Procedure TFormMain.MapSetValue ( e : TEdit; iValue : TValue );
Begin
	Case iValue.Kind Of

		valFirst :
		Begin
			e.Text := '';
		End;

		valMultiple :
		Begin
			e.Text := '(mul)';
		End;

		valDirect :
		Begin
			e.Text := IntToStr ( iValue.Value );
		End;

	End;
End;

Procedure TFormMain.MapCheckInt ( Var i : TValue; iValue : Integer );
Begin
	If i.Kind = valFirst Then
	Begin
		i.Kind := valDirect;
		i.Value := iValue;
	End
	Else
	Begin
		If i.Kind = valDirect Then
		Begin
			If i.Value <> iValue Then
			Begin
				i.Kind := valMultiple;
			End;
		End;
	End;
End;

Procedure TFormMain.MapCheckString ( Var s : String; sValue : String );
Begin
	If s = '' Then
	Begin
		s := Trim ( sValue );
	End
	Else
	Begin
		If UpperCase ( s ) <> UpperCase ( Trim ( sValue ) ) Then
		Begin
			s := '(multiple)';
		End;
	End;
End;

Procedure TFormMain.MapUpdateSectorProperties;
Var
	iSector : Integer;
	//
	iSectorID : TValue;
	sFloor, sCeil : String;
	iFloor, iCeil : TValue;
	iType, iLight, iTag : TValue;
	//
	iSideDef, iSideDefs : Integer;
Begin
	//
	iSectorID.Kind := valFirst;
	iFloor.Kind := valFirst;
	iCeil.Kind := valFirst;
	iType.Kind := valFirst;
	iLight.Kind := valFirst;
	iTag.Kind := valFirst;
	sFloor := '';
	sCeil := '';
	//
	For iSector := 0 To nSectors Do
	Begin
		//
		If Sectors [ iSector ].Selected Then
		Begin
			//
			MapCheckInt ( iSectorID, iSector );
			//
			MapCheckInt ( iFloor, Sectors [ iSector ].Floor );
			MapCheckInt ( iCeil, Sectors [ iSector ].Ceiling );
			MapCheckInt ( iType, Sectors [ iSector ].iType );
			MapCheckInt ( iLight, Sectors [ iSector ].Light );
			MapCheckInt ( iTag, Sectors [ iSector ].Tag );
			//
			MapCheckString ( sFloor, Sectors [ iSector ].FloorTex );
			MapCheckString ( sCeil, Sectors [ iSector ].CeilingTex );
		End;
		//
	End;
	//
	MapSetValue ( MapEditSector, iSectorID );
	MapSetValue ( MapEditSectorFloor, iFloor );
	MapSetValue ( MapEditSectorCeiling, iCeil );
	MapSetValue ( MapEditSectorType, iType );
	MapSetValue ( MapEditSectorLight, iLight );
	MapSetValue ( MapEditSectorTag, iTag );
	//
	MapEditSectorFloorTex.Text := sFloor;
	MapEditSectorCeilingTex.Text := sCeil;
	//
	If ( iSectorID.Kind <> valDirect ) Then
	Begin
		LabelMapSectorSideDefs.Caption := '';
	End
	Else
	Begin
		//
		iSideDefs := 0;
		For iSideDef := 0 To nSideDefs Do
		Begin
			If SideDefs [ iSideDef ].Sector = iSectorID.Value Then
			Begin
				Inc ( iSideDefs );
			End;
		End;
		//
		LabelMapSectorSideDefs.Caption := Comma ( iSideDefs ) + ' sidedefs';
	End;
End;

procedure TFormMain.MapSectorApplyClick(Sender: TObject);
Var
	iSector : Integer;
	//
	sFloor, sCeil : String;
	iFloor, iCeil : TValue;
	iType1, iLight, iTag : TValue;
	//
begin
	//
	iFloor := MapGetValue ( MapEditSectorFloor );
	iCeil := MapGetValue ( MapEditSectorCeiling );
	iType1 := MapGetValue ( MapEditSectorType );
	iLight := MapGetValue ( MapEditSectorLight );
	iTag := MapGetValue ( MapEditSectorTag );
	//
	sFloor := MapEditSectorFloorTex.Text;
	sCeil := MapEditSectorCeilingTex.Text;
	//
	For iSector := 0 To nSectors Do
	Begin
		With Sectors [ iSector ] Do
		Begin
			If Selected Then
			Begin
				MapSetInt ( Floor, iFloor );
				MapSetInt ( Ceiling, iCeil );
				//
				MapSetInt ( iType, iType1 );
				MapSetInt ( Light, iLight );
				MapSetInt ( Tag, iTag );
				//
				MapSetString ( FloorTex, sFloor );
				MapSetString ( CeilingTex, sCeil );
			End;
		End;
		//
		Modified ( True );
	End;
	//
	EditMapZoom.SetFocus;
	//
end;

Procedure TFormMain.MapUpdateLineDefProperties ( b : Boolean );
Var
	iSideDef, iLineDef : Integer;
	sFrontAbove : String;
	sFrontMain : String;
	sFrontBelow : String;
	sBackAbove : String;
	sBackMain : String;
	sBackBelow : String;
	//
	iFrontX : TValue;
	iFrontY : TValue;
	iBackX : TValue;
	iBackY : TValue;
	iFrontSector, iBackSector : TValue;
	//
	iTag, iType : TValue;
	//
	iArg1, iArg2, iArg3, iArg4, iArg5 : TValue;
	//
	iFlag : Integer;
	bBit : Integer;
	Flags : Array [ 0 .. 15 ] Of Integer;
	ActivateFlags : Integer;

Procedure SetFlag ( i : Integer; c : TCheckBox );
Begin
	Case i Of
		0 : c.State := cbUnchecked;
		1 : c.State := cbChecked;
		Else c.State := cbGrayed;
	End;
End;

Begin
	If b Then
	Begin
		//
		// --- Init
		//
		sFrontAbove := '';
		sFrontMain := '';
		sFrontBelow := '';
		//
		sBackAbove := '';
		sBackMain := '';
		sBackBelow := '';
		//
		iFrontX.Kind := valFirst;
		iFrontY.Kind := valFirst;
		iBackX.Kind := valFirst;
		iBackY.Kind := valFirst;
		iFrontSector.Kind := valFirst;
		iBackSector.Kind := valFirst;
		//
		iTag.Kind := valFirst;
		iType.Kind := valFirst;
		//
		iArg1.Kind := valFirst;
		iArg2.Kind := valFirst;
		iArg3.Kind := valFirst;
		iArg4.Kind := valFirst;
		iArg5.Kind := valFirst;
		//
		For iFlag := 0 To 15 Do
		Begin
			Flags [ iFlag ] := 3; // undetermined
		End;
		//
		// --- Go through all linedefs
		//
		For iLineDef := 0 To nLineDefs Do
		Begin
			//
			// --- Check only selected ones
			//
			If LineDefs [ iLineDef ].Selected Then
			Begin
				//
				For iFlag := 0 To 15 Do
				Begin
					If ( ( LineDefs [ iLineDef ].Flags ) And ( 1 Shl iFlag ) ) <> 0 Then
						bBit := 1
					Else
						bBit := 0;
					//
					If Flags [ iFlag ] = 3 Then
					Begin
						Flags [ iFlag ] := bBit;
					End
					Else
					Begin
						If Flags [ iFlag ] <> bBit Then
							Flags [ iFlag ] := 2;
					End;
				End;
				//
				MapCheckInt ( iTag, LineDefs [ iLineDef ].Tag );
				MapCheckInt ( iType, LineDefs [ iLineDef ].iType );
				//
				MapCheckInt ( iArg1, LineDefs [ iLineDef ].Arg1 );
				MapCheckInt ( iArg2, LineDefs [ iLineDef ].Arg2 );
				MapCheckInt ( iArg3, LineDefs [ iLineDef ].Arg3 );
				MapCheckInt ( iArg4, LineDefs [ iLineDef ].Arg4 );
				MapCheckInt ( iArg5, LineDefs [ iLineDef ].Arg5 );
				//
				iSideDef := LineDefs [ iLineDef ].SideFront;
				//
				If iSideDef >= 0 Then
				Begin
					//
					MapCheckString ( sFrontAbove, SideDefs [ iSideDef ].Above );
					MapCheckString ( sFrontMain, SideDefs [ iSideDef ].Main );
					MapCheckString ( sFrontBelow, SideDefs [ iSideDef ].Below );
					//
					MapCheckInt ( iFrontX, SideDefs [ iSideDef ].xOffset );
					MapCheckInt ( iFrontY, SideDefs [ iSideDef ].yOffset );
					MapCheckInt ( iFrontSector, SideDefs [ iSideDef ].Sector );
					//
				End;
				//
				iSideDef := LineDefs [ iLineDef ].SideBack;
				//
				If iSideDef >= 0 Then
				Begin
					//
					MapCheckString ( sBackAbove, SideDefs [ iSideDef ].Above );
					MapCheckString ( sBackMain, SideDefs [ iSideDef ].Main );
					MapCheckString ( sBackBelow, SideDefs [ iSideDef ].Below );
					//
					MapCheckInt ( iBackX, SideDefs [ iSideDef ].xOffset );
					MapCheckInt ( iBackY, SideDefs [ iSideDef ].yOffset );
					MapCheckInt ( iBackSector, SideDefs [ iSideDef ].Sector );
					//
				End;
			End;
		End;
		//
		MapEditFrontAbove.Text := sFrontAbove;
		MapEditFrontMain.Text := sFrontMain;
		MapEditFrontBelow.Text := sFrontBelow;
		//
		MapEditBackAbove.Text := sBackAbove;
		MapEditBackMain.Text := sBackMain;
		MapEditBackBelow.Text := sBackBelow;
		//
		MapSetValue ( MapEditFrontX, iFrontX );
		MapSetValue ( MapEditFrontY, iFrontY );
		MapSetValue ( MapEditFrontSector, iFrontSector );
		MapSetValue ( MapEditBackX, iBackX );
		MapSetValue ( MapEditBackY, iBackY );
		MapSetValue ( MapEditBackSector, iBackSector );
		//
		SetFlag ( Flags [ 0 ], MapEditLDFlags1 );
		SetFlag ( Flags [ 1 ], MapEditLDFlags2 );
		SetFlag ( Flags [ 2 ], MapEditLDFlags3 );
		SetFlag ( Flags [ 3 ], MapEditLDFlags4 );
		SetFlag ( Flags [ 4 ], MapEditLDFlags5 );
		SetFlag ( Flags [ 5 ], MapEditLDFlags6 );
		SetFlag ( Flags [ 6 ], MapEditLDFlags7 );
		SetFlag ( Flags [ 7 ], MapEditLDFlags8 );
		SetFlag ( Flags [ 8 ], MapEditLDFlags9 );
		SetFlag ( Flags [ 9 ], MapEditLDFlags10 );
		SetFlag ( Flags [ 13 ], MapEditLDFlags11 );
		SetFlag ( Flags [ 15 ], MapEditLDFlags12 );
		//
		ActivateFlags := Flags [ 10 ] + Flags [ 11 ] * 10 + Flags [ 12 ] * 100;
		Case ActivateFlags Of
			000 : MapEditLineDefsActivate.ItemIndex := 0;
			001 : MapEditLineDefsActivate.ItemIndex := 1;
			010 : MapEditLineDefsActivate.ItemIndex := 2;
			011 : MapEditLineDefsActivate.ItemIndex := 3;
			100 : MapEditLineDefsActivate.ItemIndex := 4;
			101 : MapEditLineDefsActivate.ItemIndex := 5;
			110 : MapEditLineDefsActivate.ItemIndex := 6;
			111 : MapEditLineDefsActivate.ItemIndex := 7;
			Else MapEditLineDefsActivate.ItemIndex := 8; // (multiple)
		End;
		//
		MapSetValue ( MapEditLineDefTag, iTag );
		MapSetValue ( MapEditLineDefType, iType );
		//
		MapSetValue ( MapEditLineDefArg1, iArg1 );
		MapSetValue ( MapEditLineDefArg2, iArg2 );
		MapSetValue ( MapEditLineDefArg3, iArg3 );
		MapSetValue ( MapEditLineDefArg4, iArg4 );
		MapSetValue ( MapEditLineDefArg5, iArg5 );
		//
	End
	Else
	Begin
		MapEditFrontAbove.Text := '';
		MapEditFrontMain.Text := '';
		MapEditFrontBelow.Text := '';
		//
		MapEditBackAbove.Text := '';
		MapEditBackMain.Text := '';
		MapEditBackBelow.Text := '';
		//
		MapEditFrontX.Text := '';
		MapEditFrontY.Text := '';
		MapEditFrontSector.Text := '';
		MapEditBackX.Text := '';
		MapEditBackY.Text := '';
		MapEditBackSector.Text := '';
	End;
End;

Procedure TFormMain.MapUpdateThingProperties;
Var
	iThing : Integer;
	//
	iThingID : TValue;
	iThingX : TValue;
	iThingY : TValue;
	iThingZ : TValue;
	iAngle : TValue;
	//
	iSpecial : TValue;
	iArg1,
	iArg2,
	iArg3,
	iArg4,
	iArg5 : TValue;
	//
	iTag : TValue;
	//
	iFlag : Integer;
	bBit : Integer;
	Flags : Array [ 0 .. 15 ] Of Integer;

{
Procedure MapSetValue ( i : Integer; t : TEdit );
Begin
	If i = iFirst Then
	Begin
		t.Text := ''
	End
	Else
	Begin
		If ( i = iMul ) Then
		Begin
			t.Text := '(mul)';
		End
		Else
		Begin
			t.Text := IntToStr ( i );
		End;
	End;
End;
}

Procedure SetFlag ( i : Integer; c : TCheckBox );
Begin
	Case i Of
		0 : c.State := cbUnchecked;
		1 : c.State := cbChecked;
		Else c.State := cbGrayed;
	End;
End;

Begin
	//
	// --- Init
	//
	iAngle.Kind := valFirst;
	iThingID.Kind := valFirst;
	iThingX.Kind := valFirst;
	iThingY.Kind := valFirst;
	iThingZ.Kind := valFirst;
	//
	iSpecial.Kind := valFirst;
	iArg1.Kind := valFirst;
	iArg2.Kind := valFirst;
	iArg3.Kind := valFirst;
	iArg4.Kind := valFirst;
	iArg5.Kind := valFirst;
	//
	iTag.Kind := valFirst;
	//
	For iFlag := 0 To 15 Do
	Begin
		Flags [ iFlag ] := 3; // undetermined
	End;
	//
	// --- Go through all things
	//
	For iThing := 0 To nThings Do
	Begin
		//
		// --- Check only selected ones
		//
		If Things [ iThing ].Selected Then
		Begin
			//
			// --- Check Flags
			//
			For iFlag := 0 To 15 Do
			Begin
				If ( ( Things [ iThing ].Flags ) And ( 1 Shl iFlag ) ) <> 0 Then
					bBit := 1
				Else
					bBit := 0;
				//
				If Flags [ iFlag ] = 3 Then
				Begin
					Flags [ iFlag ] := bBit;
				End
				Else
				Begin
					If Flags [ iFlag ] <> bBit Then
						Flags [ iFlag ] := 2;
				End;
			End;
			//
			MapCheckInt ( iThingX, Things [ iThing ].x );
			MapCheckInt ( iThingY, Things [ iThing ].y );
			MapCheckInt ( iThingZ, Things [ iThing ].z );
			MapCheckInt ( iThingID, Things [ iThing ].iType );
			MapCheckInt ( iAngle, Things [ iThing ].Angle );
			//
			MapCheckInt ( iSpecial, Things [ iThing ].Special );
			MapCheckInt ( iArg1, Things [ iThing ].Arg1 );
			MapCheckInt ( iArg2, Things [ iThing ].Arg2 );
			MapCheckInt ( iArg3, Things [ iThing ].Arg3 );
			MapCheckInt ( iArg4, Things [ iThing ].Arg4 );
			MapCheckInt ( iArg5, Things [ iThing ].Arg5 );
			//
			MapCheckInt ( iTag, Things [ iThing ].Tag );
		End;
	End;
	//
	MapSetValue ( MapEditType, iThingID );
	MapSetValue ( MapEditThingAngle, iAngle );
	MapSetValue ( MapEditThingX, iThingX );
	MapSetValue ( MapEditThingY, iThingY );
	MapSetValue ( MapEditThingZ, iThingZ );
	//
	MapSetValue ( MapEditThingSpecial, iSpecial );
	MapSetValue ( MapEditThingArg1, iArg1 );
	MapSetValue ( MapEditThingArg2, iArg2 );
	MapSetValue ( MapEditThingArg3, iArg3 );
	MapSetValue ( MapEditThingArg4, iArg4 );
	MapSetValue ( MapEditThingArg5, iArg5 );
	//
	MapSetValue ( MapEditThingTag, iTag );
	//
	SetFlag ( Flags [ 0 ], MapEditThingFlags1 );
	SetFlag ( Flags [ 1 ], MapEditThingFlags2 );
	SetFlag ( Flags [ 2 ], MapEditThingFlags3 );
	SetFlag ( Flags [ 3 ], MapEditThingFlags4 );
	SetFlag ( Flags [ 4 ], MapEditThingFlags5 );
	SetFlag ( Flags [ 5 ], MapEditThingFlags6 );
	SetFlag ( Flags [ 6 ], MapEditThingFlags7 );
	SetFlag ( Flags [ 7 ], MapEditThingFlags8 );
	SetFlag ( Flags [ 8 ], MapEditThingFlags9 );
	SetFlag ( Flags [ 9 ], MapEditThingFlags10 );
	SetFlag ( Flags [ 10 ], MapEditThingFlags11 );
End;

// ***

Function TFormMain.MapLineIntersect ( Ax, Ay, Bx, By, Cx, Cy, Dx, Dy : Integer; Var Px, Py : Integer ) : Boolean;
Var
	r, s : Double;
	r1, s1 : Integer;
Begin
	r1 := ((Bx-Ax)*(Dy-Cy)-(By-Ay)*(Dx-Cx));
	s1 := ((Bx-Ax)*(Dy-Cy)-(By-Ay)*(Dx-Cx));
	//
	If r1 = 0 Then
		r := -1
	Else
		r := ((Ay-Cy)*(Dx-Cx)-(Ax-Cx)*(Dy-Cy)) / r1;
	//
	If s1 = 0 Then
		s := -1
	Else
		s := ((Ay-Cy)*(Bx-Ax)-(Ax-Cx)*(By-Ay)) / s1;
	//
	If ( r >= 0 ) And ( r <= 1 ) And ( s >= 0 ) And ( s <= 1 ) Then
	Begin
		Px := Round ( Ax + r * ( Bx - Ax ) );
		Py := Round ( Ay + r * ( By - Ay ) );
		MapLineIntersect := True;
	End
	Else
	Begin
		MapLineIntersect := False;
	End;
End;

procedure TFormMain.MapLineCheckIntersect ( iLineDef : Integer );
var
	i, iCheck, iSector : Integer;
	//
	Ax, Ay, Bx, By, Cx, Cy, Dx, Dy : Integer;
	Px, Py : Integer;
	//
	iVertexNew : Integer;
	//
	nProc : Integer;
	Proc : Array [ 1 .. 1000 ] Of Integer;
	//
	nSS : Integer;
	SS : Array [ 1 .. 1000, 1 .. 2 ] Of Integer;

Procedure AddProc ( i : Integer );
Begin
	Inc ( nProc );
	Proc [ nProc ] := i;
End;

Begin
	//
	nSS := 0;
	//
	nProc := 0;
	AddProc ( iLineDef );
	//
	While nProc > 0 Do
	Begin
		//
		iCheck := Proc [ nProc ];
		Dec ( nProc );
		//
		{
		MapDeselectAll;
		LineDefs [ iCheck ].Selected := True;
		MapRefresh ( True );
		ShowMessage ( 'Checking ' + Comma ( iCheck ) );
		}
		//
		Ax := Vertex [ LineDefs [ iCheck ].VertexS ].x;
		Ay := Vertex [ LineDefs [ iCheck ].VertexS ].y;
		Bx := Vertex [ LineDefs [ iCheck ].VertexE ].x;
		By := Vertex [ LineDefs [ iCheck ].VertexE ].y;
		//
		i := 0;
		While ( i <= nLineDefs ) Do
		Begin
			//
			If i <> iCheck Then
			Begin
				//
				Cx := Vertex [ LineDefs [ i ].VertexS ].x;
				Cy := Vertex [ LineDefs [ i ].VertexS ].y;
				Dx := Vertex [ LineDefs [ i ].VertexE ].x;
				Dy := Vertex [ LineDefs [ i ].VertexE ].y;
				//
				If Not ( ( ( Ax = Cx ) And ( Ay = Cy ) ) Or ( ( Ax = Dx ) And ( Ay = Dy ) )
				Or ( ( Bx = Cx ) And ( By = Cy ) ) Or ( ( Bx = Dx ) And ( By = Dy ) ) ) Then
				Begin
					//
					If MapLineIntersect ( Ax, Ay, Bx, By, Cx, Cy, Dx, Dy, Px, Py ) Then
					Begin
						//ShowMessage ( 'LineDef ' + comma(iCheck) + ' crosses ' + comma(i) );
						//
						// --- Add intersection point (if not new)
						//
						iVertexNew := MapVertexAdd ( Px, Py );
						//
						// --- Add two new lines
						//
						MapLineDefDuplicate ( i, iVertexNew, LineDefs [ i ].VertexE );
						MapLineDefDuplicate ( iCheck, iVertexNew, LineDefs [ iCheck ].VertexE );
						//
						// --- adjust old lines
						//
						LineDefs [ i ].VertexE := iVertexNew;
						LineDefs [ iCheck ].VertexE := iVertexNew;
						//
						// --- New (closer) endpoint for our checked line
						//
						Bx := Vertex [ LineDefs [ iCheck ].VertexE ].x;
						By := Vertex [ LineDefs [ iCheck ].VertexE ].y;
						//
						Sectors [ MapLineDefFrontSector ( i ) ].iLL := nLineDefs - 1;
						If MapLineDefBackSector ( i ) >= 0 Then
							Sectors [ MapLineDefBackSector ( i ) ].iLL := nLineDefs - 1;
						{
						MapDeselectAll;
						LineDefs [ i ].Selected := True;
						LineDefs [ iCheck ].Selected := True;
						MapRefresh ( True );
						ShowMessage ( Comma ( iCheck ) + ' intersects ' + Comma ( i ) );
						}
						//
						AddProc ( nLineDefs );
					End;
				End;
			End;
			//
			Inc ( i );
		End;
		//
		{
		If bSplit Then
		Begin
			MapLineCheckIntersect ( nLineDefs );
			MapLineCheckIntersect ( iCheck );
		End;
		}
		//
		Px := Ax + Round ( ( Bx - Ax ) / 2 );
		Py := Ay + Round ( ( By - Ay ) / 2 );
		//
		iSector := MapPointInWhichSector ( Px, Py );
		//
		If iSector >= 0 Then
		Begin
			Inc ( nSS );
			SS [ nSS, 1 ] := iCheck;
			SS [ nSS, 2 ] := iSector;
		End;
	End;
	//
	For i := 1 To nSS Do
	Begin
		iCheck := SS [ i, 1 ];
		iSector := SS [ i, 2 ];
		//
		MapSideDefAddSectorMain ( iSector, '-' );
		LineDefs [ iCheck ].SideBack := nSideDefs;
		LineDefs [ iCheck ].Flags := LineDefs [ iCheck ].Flags Or ldefTwoSided;
		// make front see through as well
		SideDefs [ LineDefs [ iCheck ].SideFront ].Main := '-';
	End;
End;

// ############################################################################

Procedure TFormMain.MapMakeSector ( x, y : Integer );

Const
	MaxTVertex = 1000;

Var
	iLineDef : Integer;
	iVertex : Integer;
	//
	x0, y0 : Integer;
	//
	iBestVertex : Integer;
	dDist, dBestDist : Double;
	bCompleted : Boolean;
	//
	nTVertex : Integer;
	TVertex : Array [ 1 .. MaxTVertex ] Of Integer;
	//
	lCnt : Integer;

Procedure CheckVertex;
Begin
	//
	x0 := ( Vertex [ iVertex ].x - x );
	y0 := ( Vertex [ iVertex ].y - y );
	//
	dDist := x0 * x0 + y0 * y0;
	dDist := Sqrt ( dDist );
	//
	If dBestDist > dDist Then
	Begin
		dBestDist := dDist;
		iBestVertex := iVertex;
	End;
	//
End;

Function ExistV ( V : Integer ) : Integer;
Var
	i : Integer;
	b : Boolean;
Begin
	i := 1;
	b := False;
	While Not b And ( i <= nTVertex ) Do
	Begin
		If TVertex [ i ] = V Then
		Begin
			b := True;
		End
		Else
		Begin
			Inc ( i );
		End;
	End;
	//
	If Not b Then
		i := -1;
	ExistV := i;
End;

Procedure AddV ( V : Integer );
Begin
	If nTVertex = MaxTVertex Then
	Begin
		ShowMessage ( 'Internal error' );
	End
	Else
	Begin
		Inc ( nTVertex );
		TVertex [ nTVertex ] := V;
	End;
End;

Function CheckTVertex : Boolean;
Var
	p : TPolygon;
	i : Integer;
	p1 : TPoint;
	bOk : Boolean;
	v1, v2 : Integer;
Begin
	For i := 1 To nTVertex Do
	Begin
		p [ i - 1 ].x := Vertex [ TVertex [ i ] ].x;
		p [ i - 1 ].y := Vertex [ TVertex [ i ] ].y;
	End;
	//
	p1.x := x;
	p1.y := y;
	//
	bOk := False;
	//
	If PointInPolygon ( p, nTVertex - 1, p1 ) Then
	Begin
		//
		// --- we made sure that the original point is inside
		//
		i := 0;
		bOk := True;
		While ( i <= nLineDefs ) And bOk Do
		Begin
			//
			v1 := ExistV ( LineDefs [ i ].VertexS );
			v2 := ExistV ( LineDefs [ i ].VertexE );
			//
			If v1 = -1 Then
			Begin
				p1.x := Vertex [ LineDefs [ i ].VertexS ].x;
				p1.y := Vertex [ LineDefs [ i ].VertexS ].y;
				If PointInPolygon ( p, nTVertex - 1, p1 ) Then
				Begin
					bOk := False;
				End;
			End;
			//
			If v2 = -1 Then
			Begin
				p1.x := Vertex [ LineDefs [ i ].VertexE ].x;
				p1.y := Vertex [ LineDefs [ i ].VertexE ].y;
				If PointInPolygon ( p, nTVertex - 1, p1 ) Then
				Begin
					bOk := False;
				End;
			End;
			//
			If ( v1 <> -1 ) And ( v2 <> -1 ) Then
			Begin
				If ( Abs ( v1 - v2 ) > 1 ) And ( Abs ( v1 - v2 ) < nTVertex - 2 ) Then
				Begin
					p1.x := Round ( ( Vertex [ LineDefs [ i ].VertexS ].x + Vertex [ LineDefs [ i ].VertexE ].x ) / 2 );
					p1.y := Round ( ( Vertex [ LineDefs [ i ].VertexS ].y + Vertex [ LineDefs [ i ].VertexE ].y ) / 2 );
					If PointInPolygon ( p, nTVertex - 1, p1 ) Then
					Begin
						Show;
						bOk := False;
						//ShowMessage ( 'From ' + Comma ( v1 ) + ' to ' + Comma ( v2 ) );
					End;
				End;
			End;
			//
			Inc ( i );
		End;
	End;
	//
	CheckTVertex := bOk;
End;

Procedure ShowSolution;
Var
	i, j : Integer;
Begin
	//
	MapDeselectAll;
	//
	For i := 1 To nTVertex - 1 Do
	Begin
		j := 0;
		While j <= nLineDefs Do
		Begin
			If ( LineDefs [ j ].VertexS = TVertex [ i ] ) And ( LineDefs [ j ].VertexE = TVertex [ i + 1 ] )
			Or ( LineDefs [ j ].VertexE = TVertex [ i ] ) And ( LineDefs [ j ].VertexS = TVertex [ i + 1 ] ) Then
			Begin
				LineDefs [ j ].Selected := True;
				j := nLineDefs;
			End;
			Inc ( j );
		End;
	End;
	//
	MapRefresh;
	EditMapZoom.SetFocus;
End;

Function FindLine ( Var V : Integer; iStart : Integer ) : Integer;
Var
	iLD : Integer;
	bFound : Boolean;
Begin
	iLD := iStart;
	bFound := False;
	//
	While Not bFound And ( iLD <= nLineDefs ) Do
	Begin
		If ( LineDefs [ iLD ].VertexS = V ) Then
		Begin
			bFound := True;
			V := LineDefs [ iLD ].VertexE; // next
		End
		Else
		Begin
			If ( LineDefs [ iLD ].VertexE = V ) Then
			Begin
				bFound := True;
				V := LineDefs [ iLD ].VertexS; // next
			End
			Else
			Begin
				Inc ( iLD );
			End;
		End;
	End;
	//
	If bFound Then
		FindLine := iLD
	Else
		FindLine := -1;
End;

Function Follow ( V : Integer ) : Boolean;

Var
	bFail : Boolean;
	nTVertex_AtEntry : Integer;
	//
	iPrevVertex, iLDef : Integer;

Procedure ShowV ( j : Integer; s : String );
Var
	x, y : Integer;
Begin
	x := Vertex [ j ].x;
	y := Vertex [ j ].y;
	//
	CoordsMapToScreen ( x, y );
	ImageMap.Canvas.TextOut ( x - ImageMap.Canvas.TextWidth ( s ) Div 2,
		y - ImageMap.Canvas.TextHeight ( s ) Div 2, s );
End;

Procedure Show;
Var
	j : Integer;
Begin
	MapRefresh;
	//
	ImageMap.Canvas.Brush.Color := clBlack;
	ImageMap.Canvas.Font.Size := 12;
	ImageMap.Canvas.Font.Color := RGB ( 192, 192, 0 );
	//
	For j := 1 To nTVertex Do
	Begin
		If j = nTVertex Then
			ImageMap.Canvas.Font.Color := RGB ( 255, 255, 128 );
		ShowV ( TVertex [ j ], Comma ( j ) );
	End;
	//
	MessageDlgPos ( 'Line: ' + Comma ( iLDef ) + #13 +
		'Goes from: ' + Comma ( LineDefs [ iLDef ].VertexS ) + '-' +
		Comma ( LineDefs [ iLDef ].VertexE ) + #13 +
		'Vertex: ' + Comma ( V ), mtInformation, [mbOK], 0, 10, 10 );
End;

Begin
	//
	nTVertex_AtEntry := nTVertex;
	//
	AddV ( V );
	//
	bFail := False;
	//
	iPrevVertex := V;
	//
	iLDef := -1;
	While Not bCompleted And Not bFail Do
	Begin
		//
		V := iPrevVertex;
		//
		Inc ( lCnt );
		If ( lCnt And $FFFF ) = 0 Then
		Begin
			Status ( Comma ( lCnt ) + ' checks' );
			//Application.ProcessMessages;
		End;
		//
		iLDef := FindLine ( V, iLDef + 1 );
		If iLDef <> -1 Then
		Begin
			//LineDefs [ iLDef ].Selected := True;
			//
			If ( V = TVertex [ 1 ] ) Then
			Begin
				If ( nTVertex <> 2 ) Then
				Begin
					AddV ( V );
					//
					If CheckTVertex Then
					Begin
						//Show;
						//
						bCompleted := True;
					End;
				End
				Else
				Begin
					V := iPrevVertex; // keep looing
				End;
			End
			Else
			Begin
				If ExistV ( V ) <> -1 Then
				Begin
					{
					ImageMap.Canvas.Font.Color := RGB ( 255, 0, 0 );
					ShowV ( V, 'BAD' );
					MessageDlgPos ( 'BAD', mtInformation, [mbOK], 0, 10, 10 );
					}
					//
					V := iPrevVertex; // keep looing
				End
				Else
				Begin
					//
					Show;
					Follow ( V );
				End;
			End;
		End
		Else
		Begin
			bFail := True;
		End;
	End;
	//
	If bFail Then
	Begin
		nTVertex := nTVertex_AtEntry;
	End;
	//
	Follow := Not bFail;
End;

Function LineAngle ( x1, y1, x2, y2 : Integer ) : Double;
Var
	Angle : Double;
Begin
	If ( x2 - x1 ) <> 0 Then
	Begin
		Angle := ArcTan ( ( y2 - y1 ) / ( x2 - x1 ) );
		Angle := Angle / Pi * 180 + 90;
		If ( x1 > x2 ) Then
			Angle := Angle + 180;
	End
	Else
	begin
		// vertical
		Angle := 180;
		If ( y1 > y2 ) Then
			Angle := Angle + 180;
	End;
	LineAngle := Angle;
End;

Procedure MapLine ( x1, y1, x2, y2 : Integer );
Var
	Angle : Double;
	xa1, ya1, xa2, ya2 : Integer;
Begin
	Angle := LineAngle ( x1, y1, x2, y2 );
	//
	Angle := Round ( Angle * 100 ) / 100;
	//
	xa1 := x1 + ( x2 - x1 ) Div 2;
	ya1 := y1 + ( y2 - y1 ) Div 2;
	CoordsMapToScreen ( xa1, ya1 );
	ImageMap.Canvas.Brush.Style := bsClear;
	ImageMap.Canvas.Font.Size := 12;
	ImageMap.Canvas.TextOut ( xa1, ya1, FloatToStr ( Angle ) );
	//
	xa1 := x1;
	ya1 := y1;
	CoordsMapToScreen ( xa1, ya1 );
	xa2 := x2;
	ya2 := y2;
	CoordsMapToScreen ( xa2, ya2 );
	//
	ImageMap.Canvas.MoveTo ( xa1, ya1 );
	ImageMap.Canvas.LineTo ( xa2, ya2 );
	//
End;

Procedure Check_m ( x1, y1, x2, y2 : Integer );
Var
	Angle, BestAngle, SmallestAngle, ThisAngle : Double;
	BestAngleLineDef, SmallestAngleLineDef : Integer;
	//
	iL : Integer;
	lsx, lsy, lex, ley : Integer;

Procedure ChkAngle;
Begin
	If ( ThisAngle > Angle )
	And ( ThisAngle < BestAngle ) Then
	Begin
		BestAngle := ThisAngle;
		BestAngleLineDef := iL;
	End
	Else
	Begin
		If ( ThisAngle < SmallestAngle ) Then
		Begin
			SmallestAngle := ThisAngle;
			SmallestAngleLineDef := iL;
		End;
	End;
End;

Begin
	//
	// we've got a line that starts at (x1,y1)
	// and ends at (x2,y2)
	//
	// Store our line's angle
	Angle := LineAngle ( x1, y1, x2, y2 );
	If Angle = 360 Then
		Angle := 0;
	//
	BestAngle := 720;
	SmallestAngle := 720;
	//
	ImageMap.Canvas.Pen.Color := RGB ( 255, 0, 255 );
	//MapLine ( x1, y1, x2, y2 );
	//
	For iL := 0 To nLineDefs Do
	Begin
		lsx := Vertex [ LineDefs [ iL ].VertexS ].x;
		lsy := Vertex [ LineDefs [ iL ].VertexS ].y;
		lex := Vertex [ LineDefs [ iL ].VertexE ].x;
		ley := Vertex [ LineDefs [ iL ].VertexE ].y;
		//
		// ignore null lines
		If ( lsx <> lex ) Or ( lsy <> ley ) Then
		Begin
			//
			// ends same place our line does?
			If ( ( lex = x2 ) And ( ley = y2 ) ) Then
			begin
				// but it's not our line
				if ( lsx <> x1 ) Or ( lsy <> y1 ) Then
				Begin
					// good!
					ThisAngle := LineAngle ( lsx, lsy, lex, ley );
					//MapLine ( lsx, lsy, lex, ley );
					//
					ChkAngle;
				End;
			End
			Else
			Begin
				//
				// starts same place our line ends?
				// (e.g flipped line)
				If ( ( lsx = x2 ) And ( lsy = y2 ) ) Then
				begin
					// but it's not our line
					if ( lex <> x1 ) Or ( ley <> y1 ) Then
					Begin
						ThisAngle := LineAngle ( lex, ley, lsx, lsy );
						//MapLine ( lex, ley, lsx, lsy );
						//
						ChkAngle;
					End;
				End;
			End;
		End;
	End;
	//
	If BestAngle = 720 Then
	Begin
		BestAngle := SmallestAngle;
		BestAngleLineDef := SmallestAngleLineDef;
	End;
	//
	If BestAngle = 720 Then
	Begin
		bCompleted := False;
		ShowMessagePos ( 'Nowhere to go!' + #13 + Comma ( Round ( Angle ) ), 10, 10 );
	End
	Else
	Begin
		// go from our endline...
		lsx := Vertex [ LineDefs [ BestAngleLineDef ].VertexS ].x;
		lsy := Vertex [ LineDefs [ BestAngleLineDef ].VertexS ].y;
		lex := Vertex [ LineDefs [ BestAngleLineDef ].VertexE ].x;
		ley := Vertex [ LineDefs [ BestAngleLineDef ].VertexE ].y;
		//
		If ( lex = x2 ) And ( ley = y2 ) Then
		Begin
			lex := Vertex [ LineDefs [ BestAngleLineDef ].VertexS ].x;
			ley := Vertex [ LineDefs [ BestAngleLineDef ].VertexS ].y;
			lsx := Vertex [ LineDefs [ BestAngleLineDef ].VertexE ].x;
			lsy := Vertex [ LineDefs [ BestAngleLineDef ].VertexE ].y;
		End;
		//
		LineDefs [ BestAngleLineDef ].Selected := True;
		//
		MapLine ( lsx, lsy, lex, ley );
		{
		ShowMessagePos ( Comma ( Round ( BestAngle ) ), 10, 10 );
		}
		//
		If ( Vertex [ iBestVertex ].x = lex )
		And ( Vertex [ iBestVertex ].y = ley ) Then
		Begin
			bCompleted := True;
			MapRefresh;
			EditMapZoom.SetFocus;
			//ShowMessagePos ( 'Finished!', 10, 10 );
		End
		Else
		begin
			Check_m ( x2, y2, lex, ley );
		end;
	End;
End;

Begin
	//
	iBestVertex := 0;
	dBestDist := 10000000;
	//
	For iLineDef := 0 To nLineDefs Do
	Begin
		//
		iVertex := LineDefs [ iLineDef ].VertexS;
		CheckVertex;
		//
		iVertex := LineDefs [ iLineDef ].VertexE;
		CheckVertex;
		//
	End;
	//
	Caption := ( Comma ( iBestVertex ) );
	//
	MapDeselectAll;
	MapDeHighlightAll;
	Vertex [ iBestVertex ].Selected := True;
	MapRefresh;
	EditMapZoom.SetFocus;
	//
	{
	MapCenter ( Vertex [ iBestVertex ].x - 40, Vertex [ iBestVertex ].y - 40,
		Vertex [ iBestVertex ].x + 40, Vertex [ iBestVertex ].y + 40 );
	}
	//
	iVertex := iBestVertex;
	nTVertex := 0;
	//
	bCompleted := False;
	//
	//Follow ( iVertex );
	Check_m ( x, y, Vertex [ iVertex ].x, Vertex [ iVertex ].y );
	//
	If bCompleted Then
	Begin
		//ShowSolution;
		MapUpdateLineDefProperties ( True );
		//
		Status ( 'Sector found, all linedefs selected.' );
	End
	Else
	Begin
		Status ( 'Sorry, could not find sector.' );
	End;
	//
	ImageMap.Canvas.Font.Size := 8;
End;

//
Function TFormMain.MapFindNextUnusedSectorTag : Integer;
Var
	iSector, iHighestUsedTag : Integer;
Begin
	iHighestUsedTag := 0; // keep track of used tag numbers
	For iSector := 0 To nSectors Do
	Begin
		If Sectors [ iSector ].Tag > iHighestUsedTag Then
			iHighestUsedTag := Sectors [ iSector ].Tag;
	End;
	//
	MapFindNextUnusedSectorTag := iHighestUsedTag + 1;
End;

// ############################################################################

Procedure TFormMain.MapProcessSectors;
Var
	iSector, iLineDef : Integer;
	vs, ve : Integer;
Begin
	//
	// --- Keep track of Top,Left and Bottom,Right
	//
	For iSector := 0 To nSectors Do
	Begin
		With Sectors [ iSector ] Do
		Begin
			//
			iFL := -1;
			iLL := nLineDefs;
			//
			sx := $7FFFFFFF;
			sy := $7FFFFFFF;
			lx := -$7FFFFFFF;
			ly := -$7FFFFFFF;
		End;
	End;
	//
	For iLineDef := 0 To nLineDefs Do
	Begin
		//
		LineDefs [ iLineDef ].Ignore := False;
		//
		vs := LineDefs [ iLineDef ].VertexS;
		ve := LineDefs [ iLineDef ].VertexE;
		//
		iSector := MapLineDefFrontSector ( iLineDef );
		If ( iSector >= 0 ) And ( iSector <= nSectors ) Then
		Begin
			With Sectors [ iSector ] Do
			Begin
				//
				If iFL = -1 Then
					iFL := iLineDef;
				iLL := iLineDef;
				//
				If sx > Vertex [ vs ].x Then
					sx := Vertex [ vs ].x;
				If sx > Vertex [ ve ].x Then
					sx := Vertex [ ve ].x;
				//
				If sy > Vertex [ vs ].y Then
					sy := Vertex [ vs ].y;
				If sy > Vertex [ ve ].y Then
					sy := Vertex [ ve ].y;
				//
				//
				If lx < Vertex [ vs ].x Then
					lx := Vertex [ vs ].x;
				If lx < Vertex [ ve ].x Then
					lx := Vertex [ ve ].x;
				//
				If ly < Vertex [ vs ].y Then
					ly := Vertex [ vs ].y;
				If ly < Vertex [ ve ].y Then
					ly := Vertex [ ve ].y;
				//
			End;
			//
		End;
		//
		iSector := MapLineDefBackSector ( iLineDef );
		If ( iSector >= 0 ) And ( iSector <= nSectors ) Then
		Begin
			With Sectors [ iSector ] Do
			Begin
				//
				If iFL = -1 Then
					iFL := iLineDef;
				iLL := iLineDef;
				//
				If sx > Vertex [ vs ].x Then
					sx := Vertex [ vs ].x;
				If sx > Vertex [ ve ].x Then
					sx := Vertex [ ve ].x;
				//
				If sy > Vertex [ vs ].y Then
					sy := Vertex [ vs ].y;
				If sy > Vertex [ ve ].y Then
					sy := Vertex [ ve ].y;
				//
				//
				If lx < Vertex [ vs ].x Then
					lx := Vertex [ vs ].x;
				If lx < Vertex [ ve ].x Then
					lx := Vertex [ ve ].x;
				//
				If ly < Vertex [ vs ].y Then
					ly := Vertex [ vs ].y;
				If ly < Vertex [ ve ].y Then
					ly := Vertex [ ve ].y;
				//
			End;
			//
		End;
	End;
End;

// ---
// Takes two mapcoordinates
// returns the Sector ID that contains the point
// or -1 if not in any sectors
//

Function TFormMain.MapPointInWhichSector ( x, y : Integer ) : Integer;
Var
	iSector : Integer;
	bFound : Boolean;
Begin
	iSector := 0;
	bFound := False;
	While ( iSector <= nSectors ) And Not bFound Do
	Begin
		If MapPointInSector ( iSector, x, y ) Then
		Begin
			bFound := True;
		End
		Else
		Begin
			Inc ( iSector );
		End;
	End;
	//
	If Not bFound Then
	Begin
		iSector := -1;
	End;
	MapPointInWhichSector := iSector;
End;

Function TFormMain.MapPointInSector ( iSector, x, y : Integer ) : Boolean;

Var
	p : TPolygon;
	n : Integer;
	pt : TPoint;

Function SectorToPolygon ( iSector : Integer; Var p : TPolygon; Var nPoints : Integer ) : Boolean;

Var
	nLDefs : Integer; // Count
	LDefs : Array [ 1 .. 20000 ] Of Integer; // index or -1 is process
	iLDef : Integer;
	//
	i, iLineDef, iSegment : Integer;
	v : TPoint;
	StartingVertex, EndVertex : TPoint;
	bFound : Boolean;
	bBack : Boolean;
	bOk : Boolean;

// *** Finds first unprocessed line that belongs to our sector

Function FindLineDefSector ( iSector : Integer ) : Integer;
Var
	i : Integer;
	b : Boolean;
Begin
	i := 1;
	b := False;
	While ( i <= nLDefs ) And Not b Do
	Begin
		If ( LDefs [ i ] >= 0 ) Then
			b := True
		Else
			Inc ( i );
	End;
	//
	If b Then
		FindLineDefSector := i
	Else
		FindLineDefSector := -1;
End;

Function AddPoint ( p1 : TPoint ) : Boolean;
Begin
	If nPoints < PolyMax Then
	Begin
		p [ nPoints ] := p1;
		Inc ( nPoints );
		AddPoint := True;
	End
	Else
	Begin
		AddPoint := False;
	End;
End;

Begin
	//
	nPoints := 0;
	//
	If ( x > Sectors [ iSector ].lx ) Or ( x < Sectors [ iSector ].sx )
	Or ( y > Sectors [ iSector ].ly ) Or ( y < Sectors [ iSector ].sy ) Then
	Begin
		// --- not in this polygon
	End
	Else
	Begin
		//
		nLDefs := 0;
		//
		iLineDef := Sectors [ iSector ].iFL;
		If iLineDef < 0 Then
			iLineDef := 0;
		//
		While iLineDef <= Sectors [ iSector ].iLL Do
		Begin
			//
			If Not LineDefs [ iLineDef ].Ignore Then
			Begin
				If ( MapLineDefFrontSector ( iLineDef ) = iSector )
				Xor ( MapLineDefBackSector ( iLineDef ) = iSector ) Then
				Begin
					//
					Inc ( nLDefs );
					LDefs [ nLDefs ] := iLineDef;
					//
				End;
			End;
			//
			Inc ( iLineDef );
		End;
		//
		iSegment := 0;
		iLineDef := 1;
		//
		If nLDefs > 0 Then
		Begin
			//
			bOk := True;
			While bOk And ( iLineDef > 0 ) Do
			Begin
				//
				Inc ( iSegment );
				//
				If MapLineDefFrontSector ( LDefs [ iLineDef ] ) = iSector Then
				Begin
					EndVertex.x := Vertex [ LineDefs [ LDefs [ iLineDef ] ].VertexS ].x;
					EndVertex.y := Vertex [ LineDefs [ LDefs [ iLineDef ] ].VertexS ].y;
					bBack := False;
				End
				Else
				Begin
					EndVertex.x := Vertex [ LineDefs [ LDefs [ iLineDef ] ].VertexE ].x;
					EndVertex.y := Vertex [ LineDefs [ LDefs [ iLineDef ] ].VertexE ].y;
					bBack := True;
				End;
				//
				If iSegment = 1 Then
					StartingVertex := EndVertex // save for later
				Else
					AddPoint ( StartingVertex ); // go back to origin before new segment
				//
				v.x := EndVertex.x + 1;
				v.y := EndVertex.y + 1;
				//
				AddPoint ( EndVertex );
				//
				While bOk And ( ( v.x <> EndVertex.x ) Or ( v.y <> EndVertex.y ) ) Do
				Begin
					//
					If bBack Then
					Begin
						v.x := Vertex [ LineDefs [ LDefs [ iLineDef ] ].VertexS ].x;
						v.y := Vertex [ LineDefs [ LDefs [ iLineDef ] ].VertexS ].y;
					End
					Else
					Begin
						v.x := Vertex [ LineDefs [ LDefs [ iLineDef ] ].VertexE ].x;
						v.y := Vertex [ LineDefs [ LDefs [ iLineDef ] ].VertexE ].y;
					End;
					//
					LDefs [ iLineDef ] := -1; // Processed
					//
					If AddPoint ( v ) Then
					Begin
						//
						If ( ( v.x <> EndVertex.x ) Or ( v.y <> EndVertex.y ) ) Then
						Begin
							//
							bBack := False;
							//
							i := 1;
							bFound := False;
							While ( i <= nLDefs ) And Not bFound Do
							Begin
								//
								iLDef := LDefs [ i ];
								If iLDef >= 0 Then
								Begin
									//
									If ( Vertex [ LineDefs [ iLDef ].VertexS ].x = v.x )
									And ( Vertex [ LineDefs [ iLDef ].VertexS ].y = v.y )
									And ( MapLineDefFrontSector ( iLDef ) = iSector ) Then
									Begin
										bFound := True;
										bBack := False;
										iLineDef := i;
									End
									Else
									Begin
										If ( Vertex [ LineDefs [ iLDef ].VertexE ].x = v.x )
										And ( Vertex [ LineDefs [ iLDef ].VertexE ].y = v.y )
										And ( MapLineDefBackSector ( iLDef ) = iSector ) Then
										Begin
											bFound := True;
											bBack := True;
											iLineDef := i;
										End
										Else
										Begin
											Inc ( i );
										End;
									End;
								End
								Else
									Inc ( i );
							End;
							//
							If Not bFound Then
							Begin
								bOk := False;
								nPoints := 0;
							End;
							//
						End
					End
					Else
					Begin
						bOk := False;
						nPoints := 0;
					End;
				End;
				//
				If bOk Then
				Begin
					iLineDef := FindLineDefSector ( iSector );
				End;
				//
			End;
		End;
	End;
	//
	SectorToPolygon := nPoints > 0;
End;

Begin
	If SectorToPolygon ( iSector, p, n ) Then
	Begin
		pt.x := x;
		pt.y := y;
		MapPointInSector := PointInPolygon ( p, n, pt );
	End
	Else
	Begin
		MapPointInSector := False;
	End;
End;

Function TFormMain.MapSelect ( x, y : Integer; bSelect, bMulti, bCheckHit : Boolean ) : Boolean;
Var
	xp, yp : Integer;
	x1, y1, x2, y2 : Integer;
	//
	bRedraw : Boolean;
	PrevHighlight : Integer;
	//
	i : Integer;
	s : String;
	//
	//iHLVertex : Integer;
	iSelThing : Integer;
	iSelLineDefs : Integer;
	iSelLineDefChanges : Integer;
	iSelSectors : Integer;
	//
	bHit : Boolean;
	iHits : Integer;

Function Hit ( xCheck, yCheck : Integer ) : Boolean;
Begin
	CoordsMapToScreen ( xCheck, yCheck );
	If ( Abs ( xCheck - x ) < 5 ) And ( Abs ( yCheck - y ) < 5 ) Then
	Begin
		Hit := True;
	End
	Else
	Begin
		Hit := False;
	End;
end;

Begin
	bHit := True;
	iHits := 0;
	bRedraw := False;
	PrevHighlight := MapHighlight;
	//
	If Not bCheckHit Then
	Begin
		//
		MapDeHighlightAll;
		If bSelect And Not bMulti Then
		Begin
			MapDeSelectAll;
		End;
		//
	End;
	//
	xp := x;
	yp := y;
	CoordsScreenToMap ( xp, yp );
	//
	s := Comma ( xp ) + ' ; ' + Comma ( yp ) + ' ';
	//
	// -------------------------------------------------------------------------
	//
	iSelLineDefs := 0;
	iSelLineDefChanges := 0;
	If ( MapMode = mmLineDefs ) Or ( MapMode = mmAll ) Then
	Begin
		//
		// LineDefs
		//
		i := 0;
		While ( i <= nLineDefs ) And ( iSelLineDefs = 0 ) Do
		Begin
			x1 := Vertex [ LineDefs [ i ].VertexS ]. x;
			y1 := Vertex [ LineDefs [ i ].VertexS ]. y;
			x2 := Vertex [ LineDefs [ i ].VertexE ]. x;
			y2 := Vertex [ LineDefs [ i ].VertexE ]. y;
			//
			xp := x1 + Round ( ( x2 - x1 ) / 2 );
			yp := y1 + Round ( ( y2 - y1 ) / 2 );
			//
			If ( Hit ( xp, yp ) ) Then
			Begin
				//
				// *** Dragging Line ***
				//
				// point to start vertex...
				MapClickX := Vertex [ LineDefs [ i ].VertexS ]. x;
				MapClickY := Vertex [ LineDefs [ i ].VertexS ]. y;
				MapClickXP := MapClickX - xp;
				MapClickYP := MapClickY - yp;
				//
				Inc ( iHits );
				//
				If bCheckHit Then
				Begin
					If Not LineDefs [ i ].Selected Then
					Begin
						bHit := False;
					End;
				End
				Else
				Begin
					//
					x1 := Abs ( x1 - x2 );
					y1 := Abs ( y1 - y2 );
					s := s + '[LineDef ' + Comma ( i ) + ' Length: ' +
						Comma ( Round ( Sqrt ( x1 * x1 + y1 * y1 ) ) ) + '] ';
					//
					bRedraw := True;
					//
					If bSelect Then
					Begin
						LineDefs [ i ].Selected := Not LineDefs [ i ].Selected;
						//
						If ( LineDefs [ i ].Selected ) And ( iSelLineDefs = 0 ) Then
						Begin
							MapLastSelectedLineDef := i;
						End;
						//
						Inc ( iSelLineDefChanges );
					End
					Else
					Begin
						LineDefs [ i ].Highlighted := True;
						Inc ( MapHighlight );
					End;
					//
					If LineDefs [ i ].Selected Then
					Begin
						Inc ( iSelLineDefs );
					End;
				End;
			End;
			Inc ( i );
		End;
	End;
	//
	// Vertex
	//
	//iHLVertex := 0;
	If ( MapMode = mmAll ) Or ( MapMode = mmVertex ) Or ( MapMode = mmLineDefs ) Then
	Begin
		i := 0;
		While i <= nVertex Do
		Begin
			If Hit ( Vertex [ i ]. x, Vertex [ i ]. y ) Then
			Begin
				//
				// *** Dragging Vertex ***
				//
				MapClickX := Vertex [ i ].x;
				MapClickY := Vertex [ i ].y;
				MapClickXP := 0;
				MapClickYP := 0;
				//
				Inc ( iHits );
				//
				If bCheckHit Then
				Begin
					If Not Vertex [ i ].Selected Then
					Begin
						bHit := False;
					End;
				End
				Else
				Begin
					s := s + '[Vertex ' + Comma ( i ) + '] ';
					//
					bRedraw := True;
					//
					If bSelect Then
					Begin
						Vertex [ i ].Selected := Not Vertex [ i ].Selected;
						//
						i := nVertex; // out of loop
					End
					Else
					Begin
						Vertex [ i ].Highlighted := True;
						Inc ( MapHighlight );
						//Inc ( iHLVertex );
					End;
				End;
			End;
			Inc ( i );
		End;
	End;
	//
	// -------------------------------------------------------------------------
	//
	iSelThing := 0;
	If ( MapMode = mmAll ) Or ( MapMode = mmThings ) Then
	Begin
		//
		// Things
		//
		i := 0;
		While ( i <= nThings ) And ( iSelThing = 0 ) Do
		Begin
			If Hit ( Things [ i ]. x, Things [ i ]. y ) Then
			Begin
				//
				// *** Dragging Thing ***
				//
				MapClickX := Things [ i ].x;
				MapClickY := Things [ i ].y;
				MapClickXP := 0;
				MapClickYP := 0;
				//
				Inc ( iHits );
				//
				If bCheckHit Then
				Begin
					If Not Things [ i ].Selected Then
					Begin
						bHit := False;
					End;
				End
				Else
				Begin
					s := s + '[Thing ' + Comma ( i ) + '] ';
					//
					bRedraw := True;
					//
					If bSelect Then
					Begin
						Things [ i ].Selected := Not Things [ i ].Selected;
					End
					Else
					Begin
						Things [ i ].Highlighted := True;
						Inc ( MapHighlight );
					End;
					//
					If Things [ i ]. Selected Then
						Inc ( iSelThing );
					//
				End;
			End;
			Inc ( i );
		End;
	End;
	//
	// -------------------------------------------------------------------------
	//
	iSelSectors := 0;
	If ( MapMode = mmAll ) Or ( MapMode = mmSectors ) Then
	Begin
		//
		// Sectors
		//
		If ( iHits = 0 ) And ( MapMode <> mmDraw ) And ( MapMode <> mmDrawNewSector ) Then
		Begin
			//
			MapProcessSectors;
			//
			x1 := x;
			y1 := y;
			CoordsScreenToMap ( x1, y1 );
			x2 := 0;
			i := 0;
			While ( x2 = 0 ) And ( i <= nSectors ) Do
			Begin
				If MapPointInSector ( i, x1, y1 ) Then
				Begin
					//
					If bSelect Then
					Begin
						Sectors [ i ].Selected := True;
						//
						MapSelectSector ( i, True, False );
						Inc ( iSelSectors );
						Inc ( iHits );
						//
						// *** Dragging Sector ***
						//
						MapClickX := x1;
						MapClickY := y1;
						CoordsSnapToGrid ( MapClickX, MapClickY );
						MapClickXP := 0;
						MapClickYP := 0;
					End
					Else
						MapSelectSector ( i, False, True );
					//
					bRedraw := True;
					//
					x2 := 1;
				End;
				Inc ( i );
			End;
			//
			If x2 = 0 Then
			Begin
				MapDeHighlightAll;
				bRedraw := True;
			End;
			//
		End;
	End;
	//
	// ---
	//
	If Not bCheckHit Then
	Begin
		If ( MapHighlight = 0 ) And ( PrevHighlight > 0 ) Then
			bRedraw := True;
		//
		If bRedraw Then
		Begin
			MapRefresh;
			EditMapZoom.SetFocus;
			//
			If ( iSelSectors > 0 ) Then
			Begin
				MapUpdateSectorProperties;
				MapUpdateLineDefProperties ( True );
			End;
			//
			If ( iSelLineDefs > 0 ) Or ( iSelLineDefChanges > 0 ) Then
			Begin
				MapUpdateLineDefProperties ( True );
			End;
			//
			If ( iSelThing > 0 ) Then
			Begin
				MapUpdateThingProperties;
			End;
			//
			// --- Was there a new selection?
			//
			If mnuMapViewPropertiesBar.Checked Then
			Begin
				If ( MapMode = mmAll ) And ( iHits > 0 ) And bSelect Then
				Begin
					If ( iSelLineDefs > 0 ) And ( iSelThing = 0 ) Then
					Begin
						If MapPanelShowing <> mmLineDefs Then
							MapShowPanel ( mmLineDefs );
					End;
					//
					If ( iSelLineDefs = 0 ) And ( iSelThing > 0 ) Then
					Begin
						If MapPanelShowing <> mmThings Then
							MapShowPanel ( mmThings );
					End;
					//
					If ( iSelSectors > 0 ) Then
					Begin
						If MapPanelShowing <> mmSectors Then
							MapShowPanel ( mmSectors );
					End;
				End;
			End;
		End;
		//
		Status ( s );
	End;
	//
	MapSelect := bHit And ( iHits > 0 );
end;

Procedure TFormMain.MapSelectArea ( x1, y1, x2, y2 : Integer );
Var
	i : Integer;
	iThing, iLineDef, iVertex : Integer;

Function InArea ( x, y : Integer ) : Boolean;
Begin
	InArea := ( x >= x1 ) And ( x <= x2 ) And ( y >= y1 ) And ( y <= y2 );
End;

Begin
	//
	// Normalize coordinates
	//
	If x1 > x2 Then
	Begin
		i := x1;
		x1 := x2;
		x2 := i;
	End;
	If y1 > y2 Then
	Begin
		i := y1;
		y1 := y2;
		y2 := i;
	End;
	//
	If ( MapMode = mmThings ) Or ( MapMode = mmAll ) Then
	Begin
		For iThing := 0 To nThings Do
		Begin
			If InArea ( Things [ iThing ]. X, Things [ iThing ]. Y ) Then
			Begin
				Things [ iThing ].Selected := Not Things [ iThing ].Selected;
			End;
		End;
	End;
	//
	If ( MapMode = mmLineDefs ) Or ( MapMode = mmAll ) Then
	Begin
		For iLineDef := 0 To nLineDefs Do
		Begin
			If InArea ( Vertex [ LineDefs [ iLineDef ]. VertexS ]. X, Vertex [ LineDefs [ iLineDef ]. VertexS ]. Y )
			And InArea ( Vertex [ LineDefs [ iLineDef ]. VertexE ]. X, Vertex [ LineDefs [ iLineDef ]. VertexE ]. Y ) Then
			Begin
				LineDefs [ iLineDef ].Selected := Not LineDefs [ iLineDef ].Selected;
			End;
		End;
	End;
	//
	If ( MapMode = mmVertex ) Or ( MapMode = mmAll ) Then
	Begin
		For iVertex := 0 To nVertex Do
		Begin
			If InArea ( Vertex [ iVertex ]. X, Vertex [ iVertex ]. Y ) Then
			Begin
				Vertex [ iVertex ].Selected := Not Vertex [ iVertex ].Selected;
			End;
		End;
	End;
	//
	If ( MapMode = mmSectors ) Or ( MapMode = mmAll ) Then
	Begin
		For i := 0 To nSectors Do
		Begin
			If InArea ( Sectors [ i ].sx, Sectors [ i ].sy )
			And InArea ( Sectors [ i ].lx, Sectors [ i ].ly ) Then
			Begin
				Sectors [ i ].Selected := Not Sectors [ i ].Selected;
			End;
		End;
	End;
	//
	MapUpdateLineDefProperties ( True );
	MapUpdateThingProperties;
	MapUpdateSectorProperties;
	//
	MapRefresh;
	EditMapZoom.SetFocus;
End;

Procedure TFormMain.MapSelectSector ( iSector : Integer; bSelect, bHighlight : Boolean );
Var
	iLineDef : Integer;
begin
	For iLineDef := 0 To nLineDefs Do
	Begin
		If ( MapLineDefFrontSector ( iLineDef ) = iSector )
		Or ( MapLineDefBackSector ( iLineDef ) = iSector ) Then
		Begin
			If bSelect Then
				LineDefs [ iLineDef ].Selected := True;
			LineDefs [ iLineDef ].Highlighted := bHighlight;
		End;
		//
	End;
End;

Procedure TFormMain.MapSelectOneSector ( iSector : Integer );
Begin
	MapDeselectAll;
	MapDeHighlightAll;
	//
	MapSelectSector ( iSector, True, False );
	Sectors [ iSector ].Selected := True;
	//
	MapRefresh;
	EditMapZoom.SetFocus;
End;

procedure TFormMain.mnuPopupMapSelectFrontSectorClick(Sender: TObject);
Var
	iLineDef, iSector : Integer;
	s : String;
begin
	iLineDef := 0;
	While iLineDef <= nLineDefs Do
	Begin
		If LineDefs [ iLineDef ].Highlighted = True Then
		Begin
			MapSetMode ( mmSectors );
			//
			iSector := SideDefs [ LineDefs [ iLineDef ].SideFront ].Sector;
			s := IntToStr ( iSector );
			//
			If MapEditSector.Text = s Then
				MapSelectOneSector ( iSector )
			Else
			Begin
				MapEditSector.Text := s;
				//
				MapSelectOneSector ( iSector );
				MapUpdateSectorProperties;
			End;
			//
			iLineDef := nLineDefs; // exit from loop
		End;
		Inc ( iLineDef );
	End;
end;

procedure TFormMain.mnuPopupMapSelectBackSectorClick(Sender: TObject);
Var
	iLineDef, iSector : Integer;
	s : String;
begin
	iLineDef := 0;
	While iLineDef <= nLineDefs Do
	Begin
		If LineDefs [ iLineDef ].Highlighted = True Then
		Begin
			MapSetMode ( mmSectors );
			//
			iSector := SideDefs [ LineDefs [ iLineDef ].SideBack ].Sector;
			s := IntToStr ( iSector );
			//
			If MapEditSector.Text = s Then
				MapSelectOneSector ( iSector )
			Else
			Begin
				MapEditSector.Text := s;
				//
				MapSelectOneSector ( iSector );
				MapUpdateSectorProperties;
			End;
			//
			iLineDef := nLineDefs; // exit from loop
		End;
		Inc ( iLineDef );
	End;
end;

procedure TFormMain.MapSectorPrevClick(Sender: TObject);
Var
	iSector : Integer;
begin
	iSector := SafeVal ( MapEditSector.Text );
	//
	If iSector > 0 Then
	Begin
		Dec ( iSector );
		MapEditSector.Text := IntToStr ( iSector );
		//
		MapSelectOneSector ( iSector );
		MapUpdateSectorProperties;
	End;
end;

procedure TFormMain.MapSectorNextClick(Sender: TObject);
Var
	iSector : Integer;
begin
	iSector := SafeVal ( MapEditSector.Text );
	//
	If ( iSector < nSectors ) And ( iSector >= 0 ) Then
	Begin
		Inc ( iSector );
		MapEditSector.Text := IntToStr ( iSector );
		//
		MapSelectOneSector ( iSector );
		MapUpdateSectorProperties;
	End;
end;

procedure TFormMain.MapEditSectorKeyPress(Sender: TObject; var Key: Char);
Var
	iSector : Integer;
begin
	If Key = #13 Then
	Begin
		Key := #0;
		//
		iSector := SafeVal ( MapEditSector.Text );
		//
		If ( iSector <= nSectors ) And ( iSector >= 0 ) Then
		Begin
			MapEditSector.Text := IntToStr ( iSector );
			//
			MapSelectOneSector ( iSector );
			MapUpdateSectorProperties;
		End
		Else
		Begin
			MessageDlg ( 'Invalid sector number (must be between 0-' +
				IntToStr ( nSectors ) + ')', mtWarning, [mbOK], 0 );
		End;
	End;
end;

procedure TFormMain.MapSectorDupClick(Sender: TObject);
Var
	iSector : Integer;
begin
	iSector := SafeVal ( MapEditSector.Text );
	//
	If ( iSector <= nSectors ) And ( iSector >= 0 ) Then
	Begin
		MapSectorDuplicate ( iSector );
		MapEditSector.Text := IntToStr ( nSectors );
		//
		MapSelectOneSector ( nSectors );
		MapUpdateSectorProperties;
	End;
end;

procedure TFormMain.MapEditSectorTagKeyPress(Sender: TObject;
	var Key: Char);
begin
	Case Key Of
		#78, #110 : { N, n }
		Begin
			MapEditSectorTag.Text := IntToStr ( MapFindNextUnusedSectorTag );
			Key := #0;
		End;
	End;
end;

// ############################################################################

procedure TFormMain.mnuDrawLineDefsJoinClick(Sender: TObject);
Begin
	MapJoinLineDefs;
end;

procedure TFormMain.mnuDrawLineDefsSplitClick(Sender: TObject);
Begin
	MapSplitLineDefs;
end;

Procedure TFormMain.MapFlipLineDefs;
Var
	i : Integer;
	iMax : Integer;
	iVS, iVE : Integer;
	iSector : Integer;
Begin
	iMax := 0;
	//
	For i := 0 To nLineDefs Do
	Begin
		If LineDefs [ i ].Selected Then
		Begin
			//
			Inc ( iMax );
			//
			iVS := LineDefs [ i ].VertexS;
			iVE := LineDefs [ i ].VertexE;
			//
			LineDefs [ i ].VertexS := iVE; // flip coords
			LineDefs [ i ].VertexE := iVS;
			//
			// --- Flip front & back sectors
			//
			If ( LineDefs [ i ].SideFront <> -1 )
			And ( LineDefs [ i ].SideBack <> -1 ) Then
			Begin
				iSector := SideDefs [ LineDefs [ i ].SideFront ].Sector;
				SideDefs [ LineDefs [ i ].SideFront ].Sector := SideDefs [ LineDefs [ i ].SideBack ].Sector;
				SideDefs [ LineDefs [ i ].SideBack ].Sector := iSector;
			End;
			//
		End;
	End;
	//
	If iMax = 0 Then
	Begin
		MessageDlg ( 'No linedefs were selected.', mtInformation, [mbOK], 0 );
	End
	Else
	Begin
		Modified ( True );
		MapModified := True;
		MapRefresh;
		//
		MapUpdateLineDefProperties ( True );
	End;
	//
	EditMapZoom.SetFocus;
End;

Procedure TFormMain.MapFindSelectionExtent;
Var
	i : Integer;
	x, y : Integer;
	iVS, iVE : Integer;
Begin
	x0 := 32767;
	y0 := 32767;
	x1 := -32768;
	y1 := -32768;
	//
	If ( MapMode = mmLineDefs ) Or ( MapMode = mmVertex ) Or ( MapMode = mmAll ) Then
	Begin
		//
		For i := 0 To nLineDefs Do
		Begin
			If LineDefs [ i ].Selected Then
			Begin
				//
				iVS := LineDefs [ i ].VertexS;
				iVE := LineDefs [ i ].VertexE;
				//
				x := Vertex [ iVS ]. x;
				y := Vertex [ iVS ]. y;
				//
				If x < x0 Then
					x0 := x;
				If y < y0 Then
					y0 := y;
				//
				If x > x1 Then
					x1 := x;
				If y > y1 Then
					y1 := y;
				//
				x := Vertex [ iVE ]. x;
				y := Vertex [ iVE ]. y;
				//
				If x < x0 Then
					x0 := x;
				If y < y0 Then
					y0 := y;
				//
				If x > x1 Then
					x1 := x;
				If y > y1 Then
					y1 := y;
			End;
		End;
	End;
	//
	If ( MapMode = mmThings ) Or ( MapMode = mmAll ) Then
	Begin
		//
		For i := 0 To nThings Do
		Begin
			If Things [ i ].Selected Then
			Begin
				//
				x := Things [ i ]. x;
				y := Things [ i ]. y;
				//
				If x < x0 Then
					x0 := x;
				If y < y0 Then
					y0 := y;
				//
				If x > x1 Then
					x1 := x;
				If y > y1 Then
					y1 := y;
			End;
		End;
	End;
End;

Procedure TFormMain.MapFlip ( bHorizontal : Boolean );
Var
	i : Integer;
	iMax : Integer;
	x0, y0, x1, y1 : Integer;
	iVS, iVE : Integer;
Begin
	MapFindSelectionExtent ( x0, y0, x1, y1 );
	//
	iMax := 0;
	//
	If ( MapMode = mmLineDefs ) Or ( MapMode = mmVertex ) Or ( MapMode = mmAll ) Then
	Begin
		For i := 0 To nLineDefs Do
		Begin
			If LineDefs [ i ].Selected Then
			Begin
				Inc ( iMax );
				Vertex [ LineDefs [ i ].VertexS ].Selected := True;
				Vertex [ LineDefs [ i ].VertexE ].Selected := True;
			End;
		End;
	End;
	If ( MapMode = mmThings ) Or ( MapMode = mmAll ) Then
	Begin
		For i := 0 To nThings Do
		Begin
			If Things [ i ].Selected Then
			Begin
				Inc ( iMax );
			End;
		End;
	End;
	//
	If iMax = 0 Then
	Begin
		MessageDlg ( 'No linedefs or things were selected.', mtInformation, [mbOK], 0 );
	End
	Else
	Begin
		//
		If ( MapMode = mmLineDefs ) Or ( MapMode = mmVertex ) Or ( MapMode = mmAll ) Then
		Begin
			For i := 0 To nLineDefs Do
			Begin
				If LineDefs [ i ].Selected Then
				Begin
					iVS := LineDefs [ i ].VertexS;
					iVE := LineDefs [ i ].VertexE;
					//
					If bHorizontal Then
					Begin
						If Vertex [ iVS ].Selected Then
						Begin
							Vertex [ iVS ].Selected := False;
							Vertex [ iVS ].x := x0 + ( x1 - Vertex [ iVS ].x );
						End;
						//
						If Vertex [ iVE ].Selected Then
						Begin
							Vertex [ iVE ].Selected := False;
							Vertex [ iVE ].x := x0 + ( x1 - Vertex [ iVE ].x );
						End;
					End
					Else
					Begin
						If Vertex [ iVS ].Selected Then
						Begin
							Vertex [ iVS ].Selected := False;
							Vertex [ iVS ].y := y0 + ( y1 - Vertex [ iVS ].y );
						End;
						//
						If Vertex [ iVE ].Selected Then
						Begin
							Vertex [ iVE ].Selected := False;
							Vertex [ iVE ].y := y0 + ( y1 - Vertex [ iVE ].y );
						End;
					End;
					//
					LineDefs [ i ].VertexS := iVE;
					LineDefs [ i ].VertexE := iVS;
				End;
			End;
		End;
		//
		If ( MapMode = mmThings ) Or ( MapMode = mmAll ) Then
		Begin
			For i := 0 To nThings Do
			Begin
				If Things [ i ].Selected Then
				Begin
					//
					If bHorizontal Then
					Begin
						Things [ i ].x := x0 + ( x1 - Things [ i ].x );
						Things [ i ].Angle := ( 540 - Things [ i ].Angle ) Mod 360;
					End
					Else
					Begin
						Things [ i ].y := y0 + ( y1 - Things [ i ].y );
						Things [ i ].Angle := 360 - Things [ i ].Angle;
					End;
				End;
			End;
		End;
		//
		Modified ( True );
		MapModified := True;
		MapRefresh;
		//
		MapUpdateLineDefProperties ( True );
	End;
	//
	EditMapZoom.SetFocus;
End;

Procedure TFormMain.MapRotate ( bRight : Boolean );
Var
	i : Integer;
	iMax : Integer;
	x, y : Integer;
	x0, y0, x1, y1 : Integer;
	xm, ym : Integer;
	iVS, iVE : Integer;
Begin
	MapFindSelectionExtent ( x0, y0, x1, y1 );
	//
	iMax := 0;
	//
	If ( MapMode = mmLineDefs ) Or ( MapMode = mmVertex ) Or ( MapMode = mmAll ) Then
	Begin
		For i := 0 To nLineDefs Do
		Begin
			If LineDefs [ i ].Selected Then
			Begin
				Inc ( iMax );
				Vertex [ LineDefs [ i ].VertexS ].Selected := True;
				Vertex [ LineDefs [ i ].VertexE ].Selected := True;
			End;
		End;
	End;
	If ( MapMode = mmThings ) Or ( MapMode = mmAll ) Then
	Begin
		For i := 0 To nThings Do
		Begin
			If Things [ i ].Selected Then
			Begin
				Inc ( iMax );
			End;
		End;
	End;
	//
	If iMax = 0 Then
	Begin
		MessageDlg ( 'No linedefs or things were selected.', mtInformation, [mbOK], 0 );
	End
	Else
	Begin
		//
		xm := x0 + ( x1 - x0 ) Div 2;
		ym := y0 + ( y1 - y0 ) Div 2;
		//
		If ( MapMode = mmLineDefs ) Or ( MapMode = mmVertex ) Or ( MapMode = mmAll ) Then
		Begin
			For i := 0 To nLineDefs Do
			Begin
				If LineDefs [ i ].Selected Then
				Begin
					iVS := LineDefs [ i ].VertexS;
					iVE := LineDefs [ i ].VertexE;
					//
					If bRight Then
					Begin
						If Vertex [ iVS ].Selected Then
						Begin
							Vertex [ iVS ].Selected := False;
							x := xm + Vertex [ iVS ].y - ym;
							y := ym - Vertex [ iVS ].x + xm;
							Vertex [ iVS ].x := x;
							Vertex [ iVS ].y := y;
						End;
						//
						If Vertex [ iVE ].Selected Then
						Begin
							Vertex [ iVE ].Selected := False;
							x := xm + Vertex [ iVE ].y - ym;
							y := ym - Vertex [ iVE ].x + xm;
							Vertex [ iVE ].x := x;
							Vertex [ iVE ].y := y;
						End;
					End
					Else
					Begin
						If Vertex [ iVS ].Selected Then
						Begin
							Vertex [ iVS ].Selected := False;
							x := xm - Vertex [ iVS ].y + ym;
							y := ym + Vertex [ iVS ].x - xm;
							Vertex [ iVS ].x := x;
							Vertex [ iVS ].y := y;
						End;
						//
						If Vertex [ iVE ].Selected Then
						Begin
							Vertex [ iVE ].Selected := False;
							x := xm - Vertex [ iVE ].y + ym;
							y := ym + Vertex [ iVE ].x - xm;
							Vertex [ iVE ].x := x;
							Vertex [ iVE ].y := y;
						End;
					End;
				End;
			End;
		End;
		//
		If ( MapMode = mmThings ) Or ( MapMode = mmAll ) Then
		Begin
			For i := 0 To nThings Do
			Begin
				If Things [ i ].Selected Then
				Begin
					//
					If bRight Then
					Begin
						x := xm + Things [ i ].y - ym;
						y := ym - Things [ i ].x + xm;
						Things [ i ].x := x;
						Things [ i ].y := y;
						Things [ i ].Angle := ( Things [ i ].Angle + 270 ) Mod 360;
					End
					Else
					Begin
						x := xm - Things [ i ].y + ym;
						y := ym + Things [ i ].x - xm;
						Things [ i ].x := x;
						Things [ i ].y := y;
						Things [ i ].Angle := ( Things [ i ].Angle + 90 ) Mod 360;
					End;
				End;
			End;
		End;
		//
		Modified ( True );
		MapModified := True;
		MapRefresh;
		EditMapZoom.SetFocus;
		//
		MapUpdateLineDefProperties ( True );
	End;
End;

procedure TFormMain.mnuDrawLineDefsFlipClick(Sender: TObject);
Begin
	// From Menu
	MapFlipLineDefs;
end;

procedure TFormMain.mnuPopupMapFlipLineDefsClick(Sender: TObject);
begin
	// From Right click
	MapFlipLineDefs;
end;

procedure TFormMain.MapVertexReplace ( iUseVertex, iDontUseVertex : Integer );
Var
	i : Integer;
Begin
	For i := 0 To nLineDefs Do
	Begin
		If LineDefs [ i ].VertexS = iDontUseVertex Then
		Begin
			LineDefs [ i ].VertexS := iUseVertex;
		End;
		If LineDefs [ i ].VertexE = iDontUseVertex Then
		Begin
			LineDefs [ i ].VertexE := iUseVertex;
		End;
	End;
	//
End;

procedure TFormMain.MapVertexDelete ( iVertex : Integer );
Var
	i : Integer;
Begin
	For i := iVertex + 1 To nVertex Do
	Begin
		Vertex [ i - 1 ] := Vertex [ i ];
	End;
	//
	For i := 0 To nLineDefs Do
	Begin
		If LineDefs [ i ].VertexS > iVertex Then
		Begin
			Dec ( LineDefs [ i ].VertexS );
		End;
		If LineDefs [ i ].VertexE > iVertex Then
		Begin
			Dec ( LineDefs [ i ].VertexE );
		End;
	End;
	//
	Dec ( nVertex );
	//
End;

procedure TFormMain.MapJoinLineDefs;
Var
	i, iMax, iFirst, iJoined : Integer;
	iVS, iVE : Integer;
	iFS, iFE : Integer; // First Start, First End
	sText : String;
	d1, d2, d3, d4 : Integer;
Begin
	iMax := 0;
	//
	iFirst := -1;
	iJoined := -1;
	//
	For i := 0 To nLineDefs Do
	Begin
		If LineDefs [ i ].Selected Then
		Begin
			Inc ( iMax );
			//
			If iFirst = -1 Then
				iFirst := i
			Else
				iJoined := i;
		End;
	End;
	//
	// --- Only two linedefs selected?
	//
	If iMax = 0 Then
	Begin
		//
		// --- Look in vertexes
		//
		For i := 0 To nVertex Do
		Begin
			If Vertex [ i ].Selected Then
			Begin
				Inc ( iMax );
				//
				If iFirst = -1 Then
					iFirst := i
				Else
					iJoined := i;
			End;
		End;
		//
		If iMax = 2 Then
		Begin
			//
			// Adjust all vertexes
			//
			For i := 0 To nLineDefs Do
			Begin
				If LineDefs [ i ].VertexS = iJoined Then
				Begin
					LineDefs [ i ].VertexS := iFirst;
				End;
				If LineDefs [ i ].VertexE = iJoined Then
				Begin
					LineDefs [ i ].VertexE := iFirst;
				End;
			End;
			//
			// Delete the Joined Vertex
			//
			MapVertexDelete ( iJoined );
			//
			Modified ( True );
			MapModified := True;
			MapRefresh;
			EditMapZoom.SetFocus;
		End
		Else
		Begin
			iMax := -1; // Bad Selection
		End;
		//
	End
	Else
	Begin
		//
		// --- exactly two vertexes selected?
		//
		If iMax = 2 Then
		Begin
			//
			// --- swap linedef indexes
			//     so that the last selected linedef
			//     is the one that stays
			//
			If iJoined = MapLastSelectedLineDef Then
			Begin
				i := iFirst;
				iFirst := iJoined;
				iJoined := i;
			End;
			//
			iVS := LineDefs [ iJoined ].VertexS;
			iVE := LineDefs [ iJoined ].VertexE;
			//
			iFS := LineDefs [ iFirst ].VertexS;
			iFE := LineDefs [ iFirst ].VertexE;
			//
			// --- two special cases:
			//     the linedefs are already joined by one vertex
			//
			If ( iVS = iFE ) Or ( iVE = iFS ) Then
			Begin
				i := iFS;
				iFS := iFE;
				iFE := i;
			End
			Else
			Begin
				//
				d1 := MapVertexDistance ( iVS, iFS );
				d2 := MapVertexDistance ( iVE, iFE );
				d3 := MapVertexDistance ( iVS, iFE );
				d4 := MapVertexDistance ( iVE, iFS );
				//
				If ( d1 + d2 ) > ( d3 + d4 ) Then
				Begin
					i := iFS;
					iFS := iFE;
					iFE := i;
				End;
			End;
			//
			// Adjust all vertexes
			//
			For i := 0 To nLineDefs Do
			Begin
				if ( i <> iFirst ) Then
				Begin
					If iVS <> -1 Then
					Begin
						If LineDefs [ i ].VertexS = iVS Then
						Begin
							LineDefs [ i ].VertexS := iFS;
						End;
						If LineDefs [ i ].VertexE = iVS Then
						Begin
							LineDefs [ i ].VertexE := iFS;
						End;
					End;
					If iVE <> -1 Then
					Begin
						If LineDefs [ i ].VertexS = iVE Then
						Begin
							LineDefs [ i ].VertexS := iFE;
						End;
						If LineDefs [ i ].VertexE = iVE Then
						Begin
							LineDefs [ i ].VertexE := iFE;
						End;
					End;
				End;
			End;
			//
			// Adjust first (new) LineDef
			//
			LineDefs [ iFirst ].Flags := LineDefs [ iFirst ].Flags Or ldefTwoSided;
			LineDefs [ iFirst ].SideBack := LineDefs [ iJoined ].SideFront;
			//
			// Adjust both front and back sidedefs
			// to 'see through'
			//
			If Trim ( SideDefs [ LineDefs [ iFirst ].SideFront ].Above ) = '-' Then
			Begin
				If Trim ( SideDefs [ LineDefs [ iJoined ].SideFront ].Above ) <> '-' Then
					sText := SideDefs [ LineDefs [ iJoined ].SideFront ].Above
				Else
					sText := SideDefs [ LineDefs [ iFirst ].SideFront ].Main;
				//
				SideDefs [ LineDefs [ iFirst ].SideFront ].Above := sText;
			End;
			//
			If Trim ( SideDefs [ LineDefs [ iFirst ].SideFront ].Below ) = '-' Then
			Begin
				If Trim ( SideDefs [ LineDefs [ iJoined ].SideFront ].Below ) <> '-' Then
					sText := SideDefs [ LineDefs [ iJoined ].SideFront ].Below
				Else
					sText := SideDefs [ LineDefs [ iFirst ].SideFront ].Main;
				//
				SideDefs [ LineDefs [ iFirst ].SideFront ].Below := sText;
			End;
			//
			SideDefs [ LineDefs [ iFirst ].SideFront ].Main := '-';
			SideDefs [ LineDefs [ iFirst ].SideBack ].Main := '-';
			//
			// Delete the Joined LineDef
			//
			For i := iJoined + 1 To nLineDefs Do
			Begin
				LineDefs [ i - 1 ] := LineDefs [ i ];
			End;
			Dec ( nLineDefs );
			//
			Modified ( True );
			MapModified := True;
			MapRefresh;
		End
		Else
		Begin
			iMax := -1;
		End;
	End;
	//
	If iMax = -1 Then
	Begin
		MessageDlg ( 'For this feature you must have' + #13 +
			'2 LineDefs or 2 Vertexes selected.', mtInformation, [mbOk], 0 );
	End;
	EditMapZoom.SetFocus;
End;

procedure TFormMain.mnuPopupMapJoinLineDefsClick(Sender: TObject);
Begin
	MapJoinLineDefs;
end;

Procedure TFormMain.MapAutoAlignSelection;
Var
	iFirst, iLinedef, i, iCount : Integer;
	bFound : Boolean;
	iVertex : Integer;
	Offset : Integer;

Function FindLeft ( v : Integer ) : Integer;
Var
	i : Integer;
	b : Boolean;
Begin
	i := 0;
	b := False;
	While ( i <= nLineDefs ) And ( Not b ) Do
	Begin
		If ( LineDefs [ i ].Selected ) And ( LineDefs [ i ].VertexE = v ) Then
			b := True
		Else
			Inc ( i );
	End;
	//
	If b Then
		FindLeft := i
	Else
		FindLeft := -1;
End;

Function FindRight ( v : Integer ) : Integer;
Var
	i : Integer;
	b : Boolean;
Begin
	i := 0;
	b := False;
	While ( i <= nLineDefs ) And ( Not b ) Do
	Begin
		If ( LineDefs [ i ].Selected ) And ( LineDefs [ i ].VertexS = v ) Then
			b := True
		Else
			Inc ( i );
	End;
	//
	If b Then
		FindRight := i
	Else
		FindRight := -1;
End;

begin
	//
	iLineDef := 0;
	bFound := False;
	While ( iLineDef <= nLineDefs ) And ( Not bFound ) Do
	Begin
		If LineDefs [ iLineDef ].Selected Then
		Begin
			bFound := True;
		End
		Else
		begin
			Inc ( iLineDef );
		End;
	End;
	//
	If Not bFound Then
	Begin
		ShowMessage ( 'No linedefs were selected.' );
	End
	Else
	Begin
		//
		i := iLineDef;
		iFirst := iLineDef;
		While ( i >= 0 ) Do
		Begin
			iLineDef := i;
			iVertex := LineDefs [ iLineDef ].VertexS;
			i := FindLeft ( iVertex );
			//
			If i = iFirst Then
			Begin
				i := -1;
			End;
		End;
		//
		// --- Start texture aligning...
		//
		Offset := 0;
		iCount := 0;
		//
		i := iLineDef;
		While ( i >= 0 ) Do
		Begin
			iLineDef := i;
			iVertex := LineDefs [ iLineDef ].VertexE;
			//
			SideDefs [ LineDefs [ iLineDef ].SideFront ].xOffset := Offset;
			Offset := ( Offset + MapLineDefGetLength ( iLineDef ) ) Mod 256;
			//
			Inc ( iCount );
			//
			If ( i = iFirst ) And ( iCount > 1 ) Then
				i := -1
			Else
				i := FindRight ( iVertex );
		End;
		//
		MapRefresh;
		//
		Modified ( True );
		MapModified := True;
		//
		MapUpdateLineDefProperties ( True );
		//
		Status ( 'Auto Aligned ' + IntToStr ( iCount ) + ' linedefs.' );
	End;
	//
	EditMapZoom.SetFocus;
End;

procedure TFormMain.mnuPopupMapNewThingClick(Sender: TObject);
begin
	//
	Inc ( nThings );
	//
	With Things [ nThings ] Do
	Begin
		//
		x := MapClickX;
		y := MapClickY;
		CoordsSnapToGrid ( x, y );
		//
		If MapType = mtZDoom Then
		Begin
			Flags := 2023;
		End
		Else
		Begin
			Flags := 7;
		End;
		//
		Angle := MapLastThingAngle;
		//
		If MapLastThingType < 1 Then
		Begin
			// first thing added to the map in this session
			If nThings = 0 Then
				iType := 1
			Else
				iType := 3001;
		End
		Else
		Begin
			iType := MapLastThingType;
		End;
		//
		z := 0;
		Tag := 0;
		//
		Special := 0;
		Arg1 := 0;
		Arg2 := 0;
		Arg3 := 0;
		Arg4 := 0;
		Arg5 := 0;
		//
		Selected := True;
	End;
	//
	If MapMode <> mmThings Then
	Begin
		MapUpdateThingProperties;
		MapSetMode ( mmThings );
	End;
	//
	Modified ( True );
	//
	MapRefresh;
	EditMapZoom.SetFocus;
end;

// ###########################################################################

Function TFormMain.MapVertexFind ( x, y : Integer ) : Integer;
Var
	iVertex : Integer;
	bFound : Boolean;
Begin
	iVertex := 0;
	bFound := False;
	While Not bFound And ( iVertex <= nVertex ) Do
	Begin
		If ( Vertex [ iVertex ].x = x ) And ( Vertex [ iVertex ].y = y ) Then
		Begin
			bFound := True;
		End
		Else
			Inc ( iVertex );
	End;
	//
	If bFound Then
		MapVertexFind := iVertex
	Else
		MapVertexFind := -1;
End;

Function TFormMain.MapVertexAddNew ( x, y : Integer ) : Integer;
Begin
	Inc ( nVertex );
	Vertex [ nVertex ].x := x;
	Vertex [ nVertex ].y := y;
	//
	MapVertexAddNew := nVertex;
End;

Function TFormMain.MapVertexAdd ( x, y : Integer ) : Integer;
Var
	i : Integer;
Begin
	i := MapVertexFind ( x, y );
	If i = -1 Then
	Begin
		i := MapVertexAddNew ( x, y );
	End;
	//
	MapVertexAdd := i;
	//
	MapModified := True;
End;

Procedure TFormMain.MapSideDefAddSectorMain ( iSector : Integer; sMain : String );
Begin
	Inc ( nSideDefs );
	SideDefs [ nSideDefs ].xOffset := 0;
	SideDefs [ nSideDefs ].yOffset := 0;
	SideDefs [ nSideDefs ].Above := '-';
	SideDefs [ nSideDefs ].Below := '-';
	//
	SideDefs [ nSideDefs ].Main := sMain;
	SideDefs [ nSideDefs ].Sector := iSector;
End;

Procedure TFormMain.MapSideDefAdd;
Var
	b : Boolean;
	i : Integer;
	s : String;
Begin
	s := '';
	i := 1;
	b := False;
	While Not b And ( i <= nLineDefs ) Do
	Begin
		If LineDefs [ i ].Selected Then
			b := True
		Else
		Begin
			If SideDefs [ LineDefs [ i ].SideFront ].Sector = nSectors Then
			Begin
				If ( SideDefs [ LineDefs [ i ].SideFront ].Main <> '-' ) And ( s = '' ) Then
					s := SideDefs [ LineDefs [ i ].SideFront ].Main;
			End;
			Inc ( i );
		End;
	End;
	//
	If b And ( MapMode <> mmDrawNewSector ) Then
	Begin
		MapSideDefDuplicate ( LineDefs [ i ].SideFront );
	End
	Else
	Begin
		If b And ( SideDefs [ LineDefs [ i ].SideFront ].Main <> '-' ) And ( s = '' ) Then
			s := SideDefs [ LineDefs [ i ].SideFront ].Main;
		// default ...
		If s = '' Then
			s := 'GRAY7';
		MapSideDefAddSectorMain ( nSectors, s );
	End;
End;

Function TFormMain.MapSideDefDuplicate ( iSideDef : Integer ) : Integer;
Begin
	If iSideDef >= 0 Then
	Begin
		Inc ( nSideDefs );
		SideDefs [ nSideDefs ].xOffset := SideDefs [ iSideDef ].xOffset;
		SideDefs [ nSideDefs ].yOffset := SideDefs [ iSideDef ].yOffset;
		SideDefs [ nSideDefs ].Above := SideDefs [ iSideDef ].Above;
		SideDefs [ nSideDefs ].Below := SideDefs [ iSideDef ].Below;
		SideDefs [ nSideDefs ].Main := SideDefs [ iSideDef ].Main;
		SideDefs [ nSideDefs ].Sector := SideDefs [ iSideDef ].Sector;
		MapSideDefDuplicate := nSideDefs;
	End
	Else
	Begin
		MapSideDefDuplicate := iSideDef;
	End;
End;

Procedure TFormMain.MapSideDefDelete ( iSideDef : Integer );
Var
	i : Integer;
Begin
	For i := iSideDef + 1 To nSideDefs Do
	Begin
		SideDefs [ i - 1 ] := SideDefs [ i ];
	End;
	//
	For i := 0 To nLineDefs Do
	Begin
		If LineDefs [ i ].SideFront > iSideDef Then
		Begin
			Dec ( LineDefs [ i ].SideFront );
		End;
		If LineDefs [ i ].SideBack > iSideDef Then
		Begin
			Dec ( LineDefs [ i ].SideBack );
		End;
	End;
	//
	Dec ( nSideDefs );
	//
End;

Procedure TFormMain.MapLineDefDuplicate ( iLineDef, VertexS, VertexE : Integer );
Begin
	Inc ( nLineDefs );
	//
	LineDefs [ nLineDefs ].VertexS := VertexS;
	LineDefs [ nLineDefs ].VertexE := VertexE;
	//
	LineDefs [ nLineDefs ].Flags := LineDefs [ iLineDef ]. Flags;
	LineDefs [ nLineDefs ].iType := LineDefs [ iLineDef ]. iType;
	LineDefs [ nLineDefs ].Arg1 := LineDefs [ iLineDef ]. Arg1;
	LineDefs [ nLineDefs ].Arg2 := LineDefs [ iLineDef ]. Arg2;
	LineDefs [ nLineDefs ].Arg3 := LineDefs [ iLineDef ]. Arg3;
	LineDefs [ nLineDefs ].Arg4 := LineDefs [ iLineDef ]. Arg4;
	LineDefs [ nLineDefs ].Arg5 := LineDefs [ iLineDef ]. Arg5;
	LineDefs [ nLineDefs ].Tag := LineDefs [ iLineDef ]. Tag;
	//
	// --- Add New SideDefs if needed
	//
	LineDefs [ nLineDefs ].SideFront := MapSideDefDuplicate ( LineDefs [ iLineDef ]. SideFront );
	LineDefs [ nLineDefs ].SideBack := MapSideDefDuplicate ( LineDefs [ iLineDef ]. SideBack );
	//
	LineDefs [ nLineDefs ].Ignore := LineDefs [ iLineDef ].Ignore;
End;

procedure TFormMain.MapSplitLineDef ( iLineDef : Integer );
Var
	x1, y1, x2, y2 : Integer;
Begin
	//
	// --- Add New Vertex
	//
	x1 := Vertex [ LineDefs [ iLineDef ]. VertexS ]. x;
	y1 := Vertex [ LineDefs [ iLineDef ]. VertexS ]. y;
	x2 := Vertex [ LineDefs [ iLineDef ]. VertexE ]. x;
	y2 := Vertex [ LineDefs [ iLineDef ]. VertexE ]. y;
	//
	MapVertexAddNew ( x1 + ( x2 - x1 ) Div 2, y1 + ( y2 - y1 ) Div 2 );
	//
	// --- Add New LineDef
	//
	MapLineDefDuplicate ( iLineDef, nVertex, LineDefs [ iLineDef ]. VertexE );
	//
	LineDefs [ nLineDefs ].Selected := True;
	//
	LineDefs [ iLineDef ]. VertexE := nVertex;
End;

procedure TFormMain.MapSplitLineDefs;
Var
	iMax, i : Integer;
	bRefresh : Boolean;
Begin
	bRefresh := False;
	iMax := nLineDefs;
	For i := 0 To iMax Do
	Begin
		If LineDefs [ i ].Selected Then
		Begin
			MapSplitLineDef ( i );
			bRefresh := True;
		End;
	End;
	//
	If bRefresh Then
	Begin
		MapRefresh;
		//
		Modified ( True );
		MapModified := True;
	End;
	//
	EditMapZoom.SetFocus;
End;

Procedure TFormMain.MapSplitLineDef3 ( iLineDef, MiddleLength : Integer );
Var
	x1, y1, x2, y2 : Integer;
	OrigLen, NewLen : Double;
Begin
	//
	// --- Add New Vertexes
	//
	x1 := Vertex [ LineDefs [ iLineDef ]. VertexS ]. x;
	y1 := Vertex [ LineDefs [ iLineDef ]. VertexS ]. y;
	x2 := Vertex [ LineDefs [ iLineDef ]. VertexE ]. x;
	y2 := Vertex [ LineDefs [ iLineDef ]. VertexE ]. y;
	//
	If MiddleLength = 0 Then
	Begin
		// split to three equal parts
		MapVertexAddNew ( x1 + ( x2 - x1 ) Div 3, y1 + ( y2 - y1 ) Div 3 );
		MapVertexAddNew ( x1 + ( x2 - x1 ) * 2 Div 3, y1 + ( y2 - y1 ) * 2 Div 3 );
	End
	Else
	Begin
		// split so middle is specified length
		OrigLen := Sqrt ( ( x1 - x2 ) * ( x1 - x2 ) + ( y1 - y2 ) * ( y1 - y2 ) );
		NewLen := ( OrigLen - MiddleLength ) / 2;
		MapVertexAddNew ( Round ( x1 + ( x2 - x1 ) / ( OrigLen / NewLen ) ), Round ( y1 + ( y2 - y1 ) / ( OrigLen / NewLen ) ) );
		NewLen := NewLen + MiddleLength;
		MapVertexAddNew ( Round ( x1 + ( x2 - x1 ) / ( OrigLen / NewLen ) ), Round ( y1 + ( y2 - y1 ) / ( OrigLen / NewLen ) ) );
	End;
	//
	// --- Add New LineDefs #1
	//
	Inc ( nLineDefs );
	LineDefs [ nLineDefs ].VertexS := nVertex - 1;
	LineDefs [ nLineDefs ].VertexE := nVertex;
	//
	LineDefs [ nLineDefs ].Flags := LineDefs [ iLineDef ]. Flags;
	LineDefs [ nLineDefs ].iType := LineDefs [ iLineDef ]. iType;
	LineDefs [ nLineDefs ].Tag := LineDefs [ iLineDef ]. Tag;
	//
	// --- Add New SideDefs if needed
	//
	LineDefs [ nLineDefs ].SideFront := MapSideDefDuplicate ( LineDefs [ iLineDef ]. SideFront );
	LineDefs [ nLineDefs ].SideBack := MapSideDefDuplicate ( LineDefs [ iLineDef ]. SideBack );
	//
	LineDefs [ nLineDefs ].Selected := True;
	//
	// --- Add New LineDefs #2
	//
	Inc ( nLineDefs );
	LineDefs [ nLineDefs ].VertexS := nVertex;
	LineDefs [ nLineDefs ].VertexE := LineDefs [ iLineDef ]. VertexE;
	//
	LineDefs [ nLineDefs ].Flags := LineDefs [ iLineDef ]. Flags;
	LineDefs [ nLineDefs ].iType := LineDefs [ iLineDef ]. iType;
	LineDefs [ nLineDefs ].Tag := LineDefs [ iLineDef ]. Tag;
	//
	// --- Add New SideDefs if needed
	//
	LineDefs [ nLineDefs ].SideFront := MapSideDefDuplicate ( LineDefs [ iLineDef ]. SideFront );
	LineDefs [ nLineDefs ].SideBack := MapSideDefDuplicate ( LineDefs [ iLineDef ]. SideBack );
	//
	LineDefs [ nLineDefs ].Selected := True;
	//
	// --- connect old
	//
	LineDefs [ iLineDef ]. VertexE := nVertex - 1;
End;

procedure TFormMain.MapSplitLineDefs3;
Var
	iMax, i : Integer;
	bRefresh : Boolean;
Begin
	bRefresh := False;
	iMax := nLineDefs;
	For i := 0 To iMax Do
	Begin
		If LineDefs [ i ].Selected Then
		Begin
			bRefresh := True;
			//
			MapSplitLineDef3 ( i, 0 );
		End;
	End;
	//
	If bRefresh Then
	Begin
		MapRefresh;
		//
		Modified ( True );
		MapModified := True;
	End;
	//
	EditMapZoom.SetFocus;
End;

procedure TFormMain.mnuPopupMapSplitLineDefsClick(Sender: TObject);
Begin
	MapSplitLineDefs;
end;

procedure TFormMain.MapEditLDFlags3Click(Sender: TObject);
begin
	//
	If MapEditLDFlags3.Checked Then
	Begin
		If MapEditBackAbove.Text = '' Then
			MapEditBackAbove.Text := '-';
		If MapEditBackMain.Text = '' Then
			MapEditBackMain.Text := '-';
		If MapEditBackBelow.Text = '' Then
			MapEditBackBelow.Text := '-';
		//
		If MapEditBackX.Text = '' Then
			MapEditBackX.Text := '0';
		If MapEditBackY.Text = '' Then
			MapEditBackY.Text := '0';
	End;
end;

procedure TFormMain.MapSectorAdd;
Var
	i : Integer;
	b : Boolean;
Begin
	If nSectors <= 0 Then
	Begin
		Inc ( nSectors );
		//
		Sectors [ nSectors ].Floor := 0;
		Sectors [ nSectors ].Ceiling := 128;
		Sectors [ nSectors ].FloorTex := 'FLOOR0_1';
		Sectors [ nSectors ].CeilingTex := 'CEIL3_2';
		Sectors [ nSectors ].Light := 160;
		Sectors [ nSectors ].iType := 0;
		Sectors [ nSectors ].Tag := 0;
		//
	End
	Else
	Begin
		//
		i := 0;
		b := False;
		While Not b And ( i <= nSectors ) Do
		Begin
			If Sectors [ i ].Selected Then
			Begin
				b := True;
			End
			Else
			Begin
				Inc ( i );
			End;
		End;
		If Not b Then i := nSectors;
		MapSectorDuplicate ( i );
		//
	End;
End;

procedure TFormMain.MapSectorDuplicate ( iSector : Integer );
Begin
	Inc ( nSectors );
	//
	Sectors [ nSectors ].Floor := Sectors [ iSector ].Floor;
	Sectors [ nSectors ].Ceiling := Sectors [ iSector ].Ceiling;
	Sectors [ nSectors ].FloorTex := Sectors [ iSector ].FloorTex;
	Sectors [ nSectors ].CeilingTex := Sectors [ iSector ].CeilingTex;
	Sectors [ nSectors ].Light := Sectors [ iSector ].Light;
	Sectors [ nSectors ].iType := Sectors [ iSector ].iType;
	Sectors [ nSectors ].Tag := Sectors [ iSector ].Tag;
End;

Procedure TFormMain.MapSectorDelete ( iSector : Integer );
Var
	i : Integer;
Begin
	For i := iSector + 1 To nSectors Do
	Begin
		Sectors [ i - 1 ] := Sectors [ i ];
	End;
	//
	For i := 0 To nSideDefs Do
	Begin
		If SideDefs [ i ].Sector > iSector Then
		Begin
			Dec ( SideDefs [ i ].Sector );
		End;
	End;
	//
	Dec ( nSectors );
	//
End;

procedure TFormMain.MapNewSector ( iSides, iRadius : Integer );
Var
	sec, i : Integer;
Begin
	//
	// If drawing started inside a sector...
	//
	sec := MapPointInWhichSector ( MapClickX, MapClickY );
	//
	If sec >= 0 Then
		// then copy that one
		MapSectorDuplicate ( sec )
	Else
	Begin
		// otherwise copy selected, or last
		MapSectorAdd;
	End;
	//
	// Create new LineDefs
	//
	For i := 0 To iSides - 1 Do
	Begin
		Inc ( nLineDefs );
		LineDefs [ nLineDefs ].VertexS := nVertex + 1 + ( 0 + i ) Mod iSides;
		LineDefs [ nLineDefs ].VertexE := nVertex + 1 + ( 1 + i ) Mod iSides;
		LineDefs [ nLineDefs ].iType := 0;
		LineDefs [ nLineDefs ].Tag := 0;
		LineDefs [ nLineDefs ].SideFront := nSideDefs + 1 + i;
		//
		If sec >= 0 Then
		Begin
			// two sided
			LineDefs [ nLineDefs ].Flags := ldefTwoSided;
			LineDefs [ nLineDefs ].SideBack := nSideDefs + 1 + iSides + i;
		End
		Else
		Begin
			// single sided
			LineDefs [ nLineDefs ].Flags := 0;
			LineDefs [ nLineDefs ].SideBack := -1;
		End;
	End;
	//
	// Create new SideDefs
	//
	For i := 0 To iSides - 1 Do
	Begin
		MapSideDefAdd;
		SideDefs [ nSideDefs ].Sector := nSectors;
		If sec >= 0 Then
		Begin
			SideDefs [ nSideDefs ].Above := SideDefs [ nSideDefs ].Main;
			SideDefs [ nSideDefs ].Below := SideDefs [ nSideDefs ].Main;
			SideDefs [ nSideDefs ].Main := '-';
		End;
	End;
	//
	If sec >= 0 Then
	Begin
		For i := 0 To iSides - 1 Do
		Begin
			MapSideDefAdd;
			SideDefs [ nSideDefs ].Sector := sec;
			SideDefs [ nSideDefs ].Above := SideDefs [ nSideDefs ].Main;
			SideDefs [ nSideDefs ].Below := SideDefs [ nSideDefs ].Main;
			SideDefs [ nSideDefs ].Main := '-';
		End;
	End;
	//
	// Create new vertexes
	//
	CoordsSnapToGrid ( MapClickX, MapClickY );
	If iSides = 4 Then
	Begin
		// special, 4 sides
		MapVertexAddNew ( MapClickX, MapClickY + iRadius );
		MapVertexAddNew ( MapClickX + iRadius, MapClickY + iRadius );
		MapVertexAddNew ( MapClickX + iRadius, MapClickY );
		MapVertexAddNew ( MapClickX, MapClickY );
	End
	Else
	Begin
		For i := 0 To iSides - 1 Do
		Begin
			MapVertexAddNew (
				MapClickX + Round ( iRadius * Sin ( ( i * ( 360 / iSides ) ) / 180 * pi ) ),
				MapClickY + Round ( iRadius * Cos ( ( i * ( 360 / iSides ) ) / 180 * pi ) ) );
		End;
	End;
	//
	Modified ( True );
	MapModified := True;
	//
	MapRefresh;
	EditMapZoom.SetFocus;
End;

procedure TFormMain.mnuMakeSectorClick(Sender: TObject);
begin
	MapMakeSector ( MapClickX, MapClickY );
end;

procedure TFormMain.mnuPopupMapNewSectorClick(Sender: TObject);
Begin
	MapNewSector ( 4, 64 );
end;

procedure TFormMain.mnuPopupMapNewPolygonalSectorClick(Sender: TObject);
Var
	nSides, nRadius : Integer;
Begin
	//
	If MapLastPolygonSides = 0 Then
		MapLastPolygonSides := 8;
	//
	If MapLastPolygonRadius = 0 Then
		MapLastPolygonRadius := 128;
	//
	nSides := SafeVal ( InputBox ( 'New Polygonal Sector', 'Number of Sides',
		IntToStr ( MapLastPolygonSides ) ) );
	nRadius := SafeVal ( InputBox ( 'New Polygonal Sector', 'Radius',
		IntToStr ( MapLastPolygonRadius ) ) );
	//
	If ( nSides > 2 ) And ( nRadius > 0 ) Then
	Begin
		//
		MapLastPolygonSides := nSides;
		MapLastPolygonRadius := nRadius;
		//
		MapNewSector ( nSides, nRadius );
	End;
end;

Function TFormMain.MapTextureFind ( s : String ) : Integer;
Var
	i : Integer;
	bFound : Boolean;
Begin
	s := UpperCase ( Trim ( s ) );
	//
	i := 1;
	bFound := False;
	//
	While Not bFound And ( i < nTextures ) Do
	Begin
		If ( Textures [ i ].Name >= s ) And ( Copy ( Textures [ i ].Name, 1, Length ( s ) ) = s ) Then
			bFound := True
		Else
			Inc ( i );
	End;
	//
	MapTextureFind := i;
End;

procedure TFormMain.MapEditKeyDown(Sender: TObject;
	var Key: Word; Shift: TShiftState);
Var
	s : String;
	i : Integer;
begin
	Case Key Of
		33 : { page up }
		Begin
			s := TEdit ( Sender ).Text;
			i := MapTextureFind ( s );
			If ( i > 0 ) Then
			Begin
				TEdit ( Sender ).Text := Trim ( Textures [ i - 1 ].Name );
				TEdit ( Sender ).SelStart := 0;
				TEdit ( Sender ).SelLength := Length ( TEdit ( Sender ).Text );
			End;
		End;
		34 : { page down }
		Begin
			s := TEdit ( Sender ).Text;
			i := MapTextureFind ( s );
			If ( i > 0 ) And ( i + 1 <= nTextures ) Then
			Begin
				TEdit ( Sender ).Text := Trim ( Textures [ i + 1 ].Name );
				TEdit ( Sender ).SelStart := 0;
				TEdit ( Sender ).SelLength := Length ( TEdit ( Sender ).Text );
			End;
		End;
	End;
end;

procedure TFormMain.MapEditKeyUp(Sender: TObject; var Key: Word;
	Shift: TShiftState);
Var
	s, sNew : String;
	i : Integer;
begin
	//
	If TypedKey ( Key ) Then
	Begin
		//
		s := TEdit ( Sender ).Text;
		//
		i := MapTextureFind ( s );
		//
		If i > 0 Then
		Begin
			//
			sNew := Trim ( Textures [ i ].Name );
			//
			If BeginsWith ( sNew, s ) Then
			Begin
				i := TEdit ( Sender ).SelStart;
				TEdit ( Sender ).Text := sNew;
				TEdit ( Sender ).SelStart := i;
				TEdit ( Sender ).SelLength := Length ( sNew ) - i;
			End;
			//
		End;
	End;
end;

procedure TFormMain.MapFloorBrowse(e: TEdit);
Var
	tb : TFormTBrowse;
begin
	tb := TFormTBrowse.Create ( Self );
	tb.Mode := tbmFloor;
	tb.GotoImage ( e.Text );
	tb.ShowModal;
	e.Text := tb.Selected;
	tb.Free;
End;

procedure TFormMain.MapImageFloorDblClick(Sender: TObject);
Begin
	MapFloorBrowse ( MapEditSectorFloorTex );
end;

procedure TFormMain.MapImageCeilingDblClick(Sender: TObject);
begin
	MapFloorBrowse ( MapEditSectorCeilingTex );
end;

procedure TFormMain.MapEditSectorFloorTexKeyPress(Sender: TObject;
	var Key: Char);
begin
	If Key = #13 Then
	Begin
		MapFloorBrowse ( TEdit ( Sender ) );
	End
	Else
	Begin
		If ( Key >= 'a' ) And ( Key <= 'z' ) Then
		Begin
			// auto caps
			Key := Chr ( Ord ( Key ) - 32 );
		End;
	End;
end;

procedure TFormMain.MapEditSectorFloorTexChange(Sender: TObject);
begin
	MapFlatRefresh ( MapImageFloor.Canvas, TEdit ( Sender ).Text );
end;

procedure TFormMain.MapEditSectorTexChange(Sender: TObject);
begin
	MapFlatRefresh ( MapImageCeiling.Canvas, TEdit ( Sender ).Text );
end;

procedure TFormMain.MapEditSectorTexKeyDown(Sender: TObject;
	var Key: Word; Shift: TShiftState);
Var
	iFlat : Integer;
begin
	iFlat := MapFlatFind ( TEdit ( Sender ).Text );
	Case Key Of
		33 : // page up
		Begin
			If iFlat > 1 Then
				TEdit ( Sender ).Text := Flats [ iFlat - 1 ].Name;
		End;
		34 : // page down
		Begin
			If iFlat < nFlats Then
				TEdit ( Sender ).Text := Flats [ iFlat + 1 ].Name;
		End;
	End;
end;

procedure TFormMain.KeyPressUpperCase(Sender: TObject; var Key: Char);
begin
	If ( Key >= 'a' ) And ( Key <= 'z' ) Then
	Begin
		Key := Chr ( Ord ( Key ) - 32 );
	End;
end;

Function TFormMain.TypedKey ( Key : Word ) : Boolean;
Begin
	TypedKey := ( ( Key >= 65 ) And ( Key <= 90 ) )
		Or ( ( Key >= 48 ) And ( Key <= 59 ) )
		Or ( Key = 189 );
End;

procedure TFormMain.MapEditSectorTexKeyUp(Sender: TObject;
	var Key: Word; Shift: TShiftState);
Var
	iFlat : Integer;
	iStart : Integer;
	s : String;
begin
	If TypedKey ( Key ) Then
	Begin
		iStart := TEdit ( Sender ).SelStart;
		iFlat := MapFlatFind ( TEdit ( Sender ).Text );
		//
		s := Flats [ iFlat ].Name;
		//
		If BeginsWith ( s, TEdit ( Sender ).Text ) Then
		Begin
			TEdit ( Sender ).Text := s;
			TEdit ( Sender ).SelStart := iStart;
			TEdit ( Sender ).SelLength := Length ( TEdit ( Sender ).Text ) - iStart;
		End;
	End;
end;

// --- --- ---

procedure TFormMain.MapEditSectorKeyDown(Sender: TObject;
	var Key: Word; Shift: TShiftState);
Var
	Step : Integer;
begin
	If ssShift in Shift Then
		Step := 64
	Else
		Step := 8;
	//
	Case Key Of
		33 : // page up
		Begin
			TEdit ( Sender ).Text := IntToStr ( SafeVal ( TEdit ( Sender ).Text ) + Step );
		End;
		34 : // page down
		Begin
			TEdit ( Sender ).Text := IntToStr ( SafeVal ( TEdit ( Sender ).Text ) - Step );
		End;
	End;
end;

Procedure TFormMain.MapDuplicateSelected ( x, y : Integer );
Var
	i : Integer;
	bRefresh : Boolean;
Begin
	//
	bRefresh := False;
	//
	//CoordsScreenToMap ( x, y );
	x := x - MapClickX;
	y := y - MapClickY;
	//
	For i := 0 To nThings Do
	Begin
		If Things [ i ]. Selected Then
		Begin
			Inc ( nThings );
			//
			Things [ nThings ].x := Things [ i ].x + x;
			Things [ nThings ].y := Things [ i ].y + y;
			//
			Things [ nThings ].Angle := Things [ i ].Angle;
			Things [ nThings ].iType := Things [ i ].iType;
			Things [ nThings ].Flags := Things [ i ].Flags;
			Things [ nThings ].z := Things [ i ].z;
			Things [ nThings ].Tag := Things [ i ].Tag;
			Things [ nThings ].Special := Things [ i ].Special;
			Things [ nThings ].Arg1 := Things [ i ].Arg1;
			Things [ nThings ].Arg2 := Things [ i ].Arg2;
			Things [ nThings ].Arg3 := Things [ i ].Arg3;
			Things [ nThings ].Arg4 := Things [ i ].Arg4;
			Things [ nThings ].Arg5 := Things [ i ].Arg5;
			//
			bRefresh := True;
		End;
	End;
	//
	For i := 0 To nLineDefs Do
	Begin
		If LineDefs [ i ]. Selected Then
		Begin
			MapVertexAddNew ( Vertex [ LineDefs [ i ].VertexS ]. x + x, Vertex [ LineDefs [ i ].VertexS ]. y + y );
			MapVertexAddNew ( Vertex [ LineDefs [ i ].VertexE ]. x + x, Vertex [ LineDefs [ i ].VertexE ]. y + y );
			//
			MapLineDefDuplicate ( i, nVertex - 1, nVertex );
			//
			LineDefs [ nLineDefs ].Selected := False;
			//
			bRefresh := True;
		End;
	End;
	//
	If bRefresh Then
	Begin
		MapRefresh;
		Modified ( True );
		MapModified := True;
	End
	Else
	Begin
		ShowMessage ( 'Nothing was selected.' );
	End;
	//
	EditMapZoom.SetFocus;
End;

Procedure TFormMain.MapDrawSelection ( X, Y : Integer );
Begin
	//
	// --- Switch to XOR mode
	//
	ImageMap.Canvas.Pen.Mode := pmXor;
	ImageMap.Canvas.Pen.Color := clYellow;
	ImageMap.Canvas.Pen.Style := psDot;
	//
	ImageMap.Canvas.MoveTo ( MapClickX, MapClickY );
	ImageMap.Canvas.LineTo ( X, MapClickY );
	ImageMap.Canvas.LineTo ( X, Y );
	ImageMap.Canvas.LineTo ( MapClickX, Y );
	ImageMap.Canvas.LineTo ( MapClickX, MapClickY );
	//
	// --- Turn of XOR mode - back to normal
	//
	ImageMap.Canvas.Pen.Mode := pmCopy;
	ImageMap.Canvas.Pen.Style := psSolid;
	//
End;

// Map Mouse Procedures

procedure TFormMain.ImageMapMouseMove(Sender: TObject; Shift: TShiftState;
	X, Y: Integer);

Var
	x0, y0 : Integer;

Procedure DrawDrag ( X, Y : Integer );
Var
	i : Integer;
	x1, y1, x2, y2 : Integer;
Begin
	//
	// --- Switch to XOR mode
	//
	ImageMap.Canvas.Pen.Mode := pmXor;
	ImageMap.Canvas.Pen.Color := RGB ( 255, 224, 192 );
	//
	For i := 0 To nLineDefs Do
	Begin
		If LineDefs [ i ].Selected Then
		Begin
			x1 := Vertex [ LineDefs [ i ].VertexS ]. x;
			y1 := Vertex [ LineDefs [ i ].VertexS ]. y;
			x2 := Vertex [ LineDefs [ i ].VertexE ]. x;
			y2 := Vertex [ LineDefs [ i ].VertexE ]. y;
			//
			x1 := x1 - MapClickX + X;
			y1 := y1 - MapClickY + Y;
			x2 := x2 - MapClickX + X;
			y2 := y2 - MapClickY + Y;
			//
			CoordsMapToScreen ( x1, y1 );
			CoordsMapToScreen ( x2, y2 );
			//
			ImageMap.Canvas.MoveTo ( x1, y1 );
			ImageMap.Canvas.LineTo ( x2, y2 );
		End;
	End;
	//
	For i := 0 To nThings Do
	Begin
		If Things [ i ].Selected Then
		Begin
			x1 := Things [ i ]. x;
			y1 := Things [ i ]. y;
			//
			x1 := x1 - MapClickX + X;
			y1 := y1 - MapClickY + Y;
			//
			CoordsMapToScreen ( x1, y1 );
			//
			MapRenderThing ( Things [ i ].iType, x1, y1, Things [ i ].Angle );
		End;
	End;
	//
	For i := 0 To nVertex Do
	Begin
		If Vertex [ i ].Selected Then
		Begin
			x1 := Vertex [ i ]. x;
			y1 := Vertex [ i ]. y;
			//
			x1 := x1 - MapClickX + X;
			y1 := y1 - MapClickY + Y;
			//
			CoordsMapToScreen ( x1, y1 );
			//
			MapRenderVertex ( x1, y1 );
		End;
	End;
	//
	// --- Draw X at dragging point
	//
	x1 := X;
	y1 := Y;
	CoordsMapToScreen ( x1, y1 );
	ImageMap.Canvas.MoveTo ( x1 - 10, y1 - 10 );
	ImageMap.Canvas.LineTo ( x1 + 10, y1 + 10 );
	ImageMap.Canvas.MoveTo ( x1 + 10, y1 - 10 );
	ImageMap.Canvas.LineTo ( x1 - 10, y1 + 10 );
	//
	// --- Turn of XOR mode - back to normal
	//
	ImageMap.Canvas.Pen.Mode := pmCopy;
	//
End;

Procedure DrawLine ( x, y : Integer );
Var
	xs, ys : Integer;
Begin
	If MapLastVertex >= 0 Then
	Begin
		//
		// --- Switch to XOR mode
		//
		ImageMap.Canvas.Pen.Mode := pmXor;
		ImageMap.Canvas.Pen.Color := RGB ( 192, 224, 255 );
		//
		xs := Vertex [ MapLastVertex ]. x;
		ys := Vertex [ MapLastVertex ]. y;
		CoordsMapToScreen ( xs, ys );
		ImageMap.Canvas.MoveTo ( xs, ys );
		CoordsMapToScreen ( x, y );
		ImageMap.Canvas.LineTo ( x, y );
		//
		// --- Turn of XOR mode - back to normal
		//
		ImageMap.Canvas.Pen.Mode := pmCopy;
		//
	End;
End;

Begin
	{
	If KeepFromRight ( Caption, 4 ) <> 'Move' Then
		Caption := Caption + 'Move';
	}
	If MapLoaded Then
	Begin
		//
		MapLastX := X;
		MapLastY := Y;
		//
		If ( MapMode = mmDraw ) Or ( MapMode = mmDrawNewSector ) Then
		Begin
			//
			// Draw Line
			//
			If Not MapRefreshed Then
			Begin
				DrawLine ( MapDragX, MapDragY ); // erase old
			End;
			//
			CoordsScreenToMap ( X, Y ); // snap destination coordinate
			CoordsSnapToGrid ( X, Y );
			//
			DrawLine ( X, Y ); // draw new
			//
			MapDragX := X;
			MapDragY := Y;
			//
			MapRefreshed := False;
		End
		Else
		Begin
			If ( MapMode = mmDuplicate ) Then
			Begin
				If Not MapRefreshed Then
				Begin
					DrawDrag ( MapDragX, MapDragY );
				End;
				//
				CoordsScreenToMap ( X, Y );
				CoordsSnapToGrid ( X, Y );
				//
				DrawDrag ( X, Y );
				//
				MapDragX := X;
				MapDragY := Y;
				//
				MapRefreshed := False;
			End;
		End;
		//
		If ssLeft in Shift Then
		Begin
			//
			If ( MapMode <> mmDraw ) And ( MapMode <> mmDrawNewSector ) Then
			Begin
				//
				//If MapSelecting Then
				If MapMode = mmSelect Then
				Begin
					// erase old
					MapDrawSelection ( MapDragX, MapDragY );
					// draw new
					MapDrawSelection ( X, Y );
					//
				End;
				//
				If MapCanDrag Then
				Begin
					//
					//If MapDragging Then
					If MapMode = mmDrag Then
					Begin
						DrawDrag ( MapDragX, MapDragY );
						//
						CoordsScreenToMap ( X, Y );
						//
						X := X + MapClickXP;
						Y := Y + MapClickYP;
						//
						CoordsSnapToGrid ( X, Y );
						//
						DrawDrag ( X, Y );
					End
					Else
					Begin
						If MapMode <> mmSelect Then
						Begin
							{
							// Caption := 'Dragging from ' + Comma ( MapClickX ) + ',' + Comma ( MapClickY );
							ShowMessage ( 'From ' + Comma ( MapClickX ) + ',' + Comma ( MapClickY ) + #13 +
								'To ' + Comma ( X ) + ',' + Comma ( Y ) );
							}
							//
							x0 := MapClickX;
							y0 := MapClickY;
							//
							CoordsMapToScreen ( x0, y0 );
							//
							// --- Dragging point in selection?
							//
							If MapSelect ( x0, y0, False, False, True ) Then
							Begin
								//
								// --- Yes, drag all that's selected
								//
								X := MapClickX;
								Y := MapClickY;
								//
								MapModeSave;
								MapSetMode ( mmDrag );
								//MapDragging := True;
								DrawDrag ( X, Y );
								//
							End
							Else
							Begin
								//
								// --- No, try to select a new object
								//
								If MapSelect ( x0, y0, True, False, False ) Then
								Begin
									//
									// --- MapClick X and Y got updated in MapSelect
									//
									X := MapClickX;
									Y := MapClickY;
									//
									MapModeSave;
									MapSetMode ( mmDrag );
									//MapDragging := True;
									DrawDrag ( X, Y );
								End
								Else
								Begin
									//
									// --- Area Select
									// --- Convert coords back to screen
									//
									CoordsMapToScreen ( MapClickX, MapClickY );
									//
									MapModeSave;
									MapSetMode ( mmSelect );
									//MapSelecting := True;
									// draw first
									MapDrawSelection ( X, Y );
								End;
							End;
						End;
					End;
				End
				Else
				Begin
					//
					If MapCanSelect Then
					Begin
						If MapMode <> mmSelect Then
						Begin
							//
							// --- Area Select
							// --- Convert coords back to screen
							//
							CoordsMapToScreen ( MapClickX, MapClickY );
							//
							MapModeSave;
							MapSetMode ( mmSelect );
							//MapSelecting := True;
							// draw first
							MapDrawSelection ( X, Y );
						End;
					End;
				End;
			End;
			//
			MapDragX := X;
			MapDragY := Y;
		End
		Else
		Begin
			MapSelect ( x, y, False, False, False );
		End;
	End;
End;

procedure TFormMain.ImageMapMouseDown(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Begin
	{
	Caption := Caption + 'Down';
	}
	//
	If MapLoaded Then
	Begin
		// mm???
		If ( MapMode = mmDrag ) Or ( MapMode = mmSelect ) Then
			MapModeRestore;
		//
		//MapDragging := False;
		//MapSelecting := False;
		//
		// --- Store mouse down coordinates
		//
		MapDownX := X;
		MapDownY := Y;
		//
		// --- Convert click coordinates to map coords
		//
		CoordsScreenToMap ( X, Y );
		//
		If MapMode = mmDuplicate Then
		Begin
			MapCanDrag := False;
			MapCanSelect := False;
		End
		Else
		Begin
			MapCanDrag := Not ( ( ssCtrl in Shift ) Or ( ssShift in Shift ) );
			MapCanSelect := ( ssShift in Shift );
			//
			// --- save them
			MapClickX := x;
			MapClickY := y;
		End;
	End;
end;

procedure TFormMain.ImageMapMouseUp(Sender: TObject; Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
Var
	i : Integer;
	x0, y0 : Integer;
	bMoved : Boolean;
	bDoneDrawing : Boolean;
	iVertex : Integer;
Begin
	{
	Caption := Caption + 'Up';
	}
	//
	If MapLoaded Then
	Begin
		//If MapDragging Then
		If MapMode = mmDrag Then
		Begin
			//
			// --- Check for 3 pixels threshold
			//     to avoid unwanted dragging
			If Not ( ( Abs ( X - MapDownX ) < 2 )
			And ( Abs ( Y - MapDownY ) < 2 ) ) Then
			Begin
				Status ( 'Dragging from ' + Comma ( MapClickX ) + ',' + Comma ( MapClickY ) );
				//
				// mm???
				If ( MapMode = mmDrag ) Or ( MapMode = mmSelect )
				Or ( MapMode = mmDuplicate ) Then
					MapModeRestore;
				//MapDragging := False;
				//
				// Move objects
				//
				bMoved := False;
				For i := 0 To nLineDefs Do
				Begin
					If LineDefs [ i ].Selected Then
					Begin
						Vertex [ LineDefs [ i ].VertexS ].Selected := True;
						Vertex [ LineDefs [ i ].VertexE ].Selected := True;
					End;
				End;
				//
				//CoordsScreenToMap ( MapClickX, MapClickY );
				//
				CoordsScreenToMap ( X, Y );
				//
				X := X + MapClickXP;
				Y := Y + MapClickYP;
				//
				CoordsSnapToGrid ( X, Y );
				//
				For i := 0 To nVertex Do
				Begin
					If Vertex [ i ].Selected Then
					Begin
						x0 := Vertex [ i ].x;
						y0 := Vertex [ i ].y;
						//CoordsMapToScreen ( x0, y0 );
						x0 := x0 - MapClickX + X;
						y0 := y0 - MapClickY + Y;
						//CoordsScreenToMap ( x0, y0 );
						Vertex [ i ].x := x0;
						Vertex [ i ].y := y0;
						bMoved := True;
					End;
				End;
				//
				For i := 0 To nThings Do
				Begin
					If Things [ i ].Selected Then
					Begin
						x0 := Things [ i ].x;
						y0 := Things [ i ].y;
						//CoordsMapToScreen ( x0, y0 );
						x0 := x0 - MapClickX + X;
						y0 := y0 - MapClickY + Y;
						//CoordsScreenToMap ( x0, y0 );
						Things [ i ].x := x0;
						Things [ i ].y := y0;
						bMoved := True;
					End;
				End;
				//
				MapRefresh;
				EditMapZoom.SetFocus;
				//
				If bMoved Then
				Begin
					Modified ( True );
					MapModified := True;
					//
					MapUpdateThingProperties;
				End;
			End
			Else
			Begin
				MapModeRestore;
			End;
		End
		Else
		Begin
			//
			If MapMode = mmSelect {MapSelecting} Then
			Begin
				//
				MapModeRestore;
				//MapSelecting := False;
				MapDrawSelection ( X, Y );
				//
				// --- coords to map
				//
				CoordsScreenToMap ( MapClickX, MapClickY );
				CoordsScreenToMap ( X, Y );
				//
				If Not ( ssCtrl in Shift ) Then
				Begin
					MapDeselectAll;
					MapDeHighlightAll;
				End;
				//
				MapSelectArea ( MapClickX, MapClickY, X, Y );
				//
			End
			Else
			Begin
				//
				// ### DRAW MODE - draw new linedef ###
				//
				If ( MapMode = mmDraw ) Or ( MapMode = mmDrawNewSector ) Then
				Begin
					//
					// --- Snap to grid
					//
					MapClickX := X;
					MapClickY := Y;
					CoordsScreenToMap ( MapClickX, MapClickY );
					CoordsSnapToGrid ( MapClickX, MapClickY );
					//
					If MapLastVertex >= 0 Then
					Begin
						//
						bDoneDrawing := False;
						iVertex := MapVertexFind ( MapClickX, MapClickY );
						If iVertex = -1 Then
						Begin
							MapVertexAddNew ( MapClickX, MapClickY );
							iVertex := nVertex;
						End
						Else
						Begin
							bDoneDrawing := True;
						End;
						//
						Inc ( nLineDefs );
						//
						LineDefs [ nLineDefs ].VertexS := MapLastVertex;
						LineDefs [ nLineDefs ].VertexE := iVertex;
						//
						LineDefs [ nLineDefs ].Ignore := True; //!!!
						//
						LineDefs [ nLineDefs ].Flags := 0;
						LineDefs [ nLineDefs ].iType := 0;
						LineDefs [ nLineDefs ].Tag := 0;
						//
						MapSideDefAdd;
						LineDefs [ nLineDefs ].SideFront := nSideDefs;
						LineDefs [ nLineDefs ].SideBack := -1;
						//
						MapLineCheckIntersect ( nLineDefs );
						//
						If bDoneDrawing Then
						Begin
							MapSetMode ( mmAll );
						End;
					End
					Else
					Begin
						//
						// --- First point
						//
						MapVertexAddNew ( MapClickX, MapClickY );
						iVertex := nVertex;
						//
						If ( MapMode = mmDrawNewSector ) Then
						Begin
							//
							// If drawing started inside a sector...
							//
							i := MapPointInWhichSector ( MapClickX, MapClickY );
							//
							If i >= 0 Then
								// then copy that one
								MapSectorDuplicate ( i )
							Else
							Begin
								// otherwise copy selected, or last
								MapSectorAdd;
							End;
						End;
					End;
					//
					MapLastVertex := iVertex;
					//
					Modified ( True );
					MapModified := True;
					MapRefresh;
					EditMapZoom.SetFocus;
				End
				Else
				Begin
					//
					If MapMode = mmDuplicate Then
					Begin
						//
						MapDuplicateSelected ( MapDragX, MapDragY );
						//
						MapModeRestore;
						//
					End
					Else
					Begin
						//
						If Button = mbLeft Then
						Begin
							MapSelect ( x, y, True, ssCtrl in Shift, False );
						End;
						//
					End;
					//
				End;
			End;
		End;
	End
	Else
	Begin
		//
		// "real" load map on first click
		//
		DoMapLoad;
	End;
end;

Procedure TFormMain.LineDefsRefresh;
Var
	i : Integer;
	v1, v2 : Integer;
	x1, y1,
	x2, y2 : Integer;
	//
	r, RecSize : Integer;
Begin
	With ImageMap Do
	Begin
		Canvas.Brush.Color := clBlack;
		Canvas.FillRect ( Canvas.ClipRect );
	End;
	//
	If Not fOpen ( sFileName ) Then Exit;
	Seek ( f, cPos );
	//
	// ---
	//
	RecSize := 14;
	if ( cLen Mod RecSize ) <> 0 Then
		RecSize := 16;
	//
	// ---
	//
	Starting;
	//
	// -----------
	//
	ImageMap.Canvas.Pen.Color := clNavy;
	//
	x1 := -1;
	x2 := 0;
	While ( x1 < ImageMap.Width ) Do
	Begin
		x1 := MapX + Round ( ( x2 - Vertex_sx ) / MapZoom );
		ImageMap.Canvas.MoveTo ( x1, 0 );
		ImageMap.Canvas.LineTo ( x1, ImageMap.Height );
		Inc ( x2, 64 );
	End;
	//
	x1 := 1;
	x2 := 0;
	While ( x1 >= 0 ) And ( x1 < ImageMap.Width ) Do
	Begin
		x1 := MapX + Round ( ( x2 - Vertex_sx ) / MapZoom );
		ImageMap.Canvas.MoveTo ( x1, 0 );
		ImageMap.Canvas.LineTo ( x1, ImageMap.Height );
		Dec ( x2, 64 );
	End;
	//
	y1 := 1;
	y2 := 0;
	While ( y1 >= 0 ) Do
	Begin
		y1 := MapY - Round ( ( y2 - Vertex_sy ) / MapZoom );
		ImageMap.Canvas.MoveTo ( 0, y1 );
		ImageMap.Canvas.LineTo ( ImageMap.Width, y1 );
		Inc ( y2, 64 );
	End;
	//
	y1 := -1;
	y2 := 0;
	While ( y1 < ImageMap.Height ) Do
	Begin
		y1 := MapY - Round ( ( y2 - Vertex_sy ) / MapZoom );
		ImageMap.Canvas.MoveTo ( 0, y1 );
		ImageMap.Canvas.LineTo ( ImageMap.Width, y1 );
		Dec ( y2, 64 );
	End;
	//
	ImageMap.Canvas.Pen.Color := clGray;
	//
	// -----------
	//
	i := 0;
	While i < cLen Do
	Begin
		v1 := GetWord ( f );
		v2 := GetWord ( f );
		r := 4;
		//
		While r < RecSize Do
		Begin
			GetWord ( f );
			Inc ( r, 2 );
		End;
		//
		VertexCoords ( v1, x1, y1 );
		VertexCoords ( v2, x2, y2 );
		//
		ImageMap.Canvas.MoveTo ( x1, y1 );
		ImageMap.Canvas.LineTo ( x2, y2 );
		//
		Inc ( i, RecSize );
	End;
	//
	fClose;
	//
	Finished;
	ShowPage ( edMap );
	EditMapZoom.SetFocus;
end;

procedure TFormMain.EditMapZoomKeyPress(Sender: TObject; Var Key: Char);
Begin
	Key := #0;
end;

Procedure TFormMain.MapShowPanel ( Panel : TMapMode );
Begin
	//
	MapPanelShowing := Panel;
	//
	PanelMapLineDefs.Visible := Panel = mmLineDefs;
	PanelMapThings.Visible := Panel = mmThings;
	PanelMapSectors.Visible := Panel = mmSectors;
	PanelMapVertex.Visible := Panel = mmVertex;
	//
	ImageMap.Visible := False;
	//
	Case Panel Of

		mmLineDefs :
		Begin
			PanelMapLineDefs.Align := alBottom;
			PanelMapLineDefs.Visible := True;
		End;

		mmThings :
		Begin
			PanelMapThings.Align := alBottom;
			PanelMapThings.Visible := True;
		End;

		mmSectors :
		Begin
			PanelMapSectors.Align := alBottom;
			PanelMapSectors.Visible := True;
		End;

		mmVertex :
		Begin
			PanelMapVertex.Align := alBottom;
			PanelMapVertex.Visible := True;
		End;

	End;
	//
	ImageMap.Visible := True;
	//
End;

procedure TFormMain.mnuDrawAllClick(Sender: TObject);
begin
	MapSetMode ( mmAll );
end;

procedure TFormMain.mnuDrawLineDefsClick(Sender: TObject);
begin
	MapSetMode ( mmLineDefs );
end;

procedure TFormMain.mnuDrawDrawClick(Sender: TObject);
begin
	MapSetMode ( mmDraw );
end;

procedure TFormMain.mnuDrawNewSectorClick(Sender: TObject);
Begin
	MapSetMode ( mmDrawNewSector );
end;

procedure TFormMain.mnuDrawThingsClick(Sender: TObject);
begin
	MapSetMode ( mmThings );
end;

procedure TFormMain.mnuDrawSectorsClick(Sender: TObject);
begin
	MapSetMode ( mmSectors );
end;

procedure TFormMain.mnuDrawVertexClick(Sender: TObject);
begin
	MapSetMode ( mmVertex );
end;

procedure TFormMain.MapConfigSelect ( s : String );
var
	i : Integer;
Begin
	s := UpperCase ( s );
	For i := 0 To mnuMapConfig.Count - 1 Do
	Begin
		If UpperCase ( Replace ( mnuMapConfig.Items [ i ].Caption, '&', '' ) ) = s Then
		Begin
			mnuMapConfigClick ( mnuMapConfig.Items [ i ] );
		End;
	End;
End;

procedure TFormMain.mnuMapConfigClick(Sender: TObject);
Var
	s : String;
begin
	s := Replace ( TMenuItem ( Sender ).Caption, '&', '' );
	//
	If s <> 'Configuration' Then
	Begin
		TMenuItem ( Sender ).Checked := True;
		//
		ConstantDelete ( 'SECTORTYPES' );
		ConstantDelete ( 'SECTORCLASSES' );
		ConstantDelete ( 'LINEDEFTYPES' );
		ConstantDelete ( 'LINEDEFCLASSES' );
		ConstantDelete ( 'THINGTYPES' );
		ConstantDelete ( 'THINGCLASSES' );
		//
		ReadInfo ( sExePath + 'xwe-config-' + s + '.ini' );
	End;
end;

Function TFormMain.MapLineDefFrontSector ( iLineDef : Integer ) : Integer;
Begin
	MapLineDefFrontSector := SideDefs [ LineDefs [ iLineDef ].SideFront ].Sector;
End;

Function TFormMain.MapLineDefBackSector ( iLineDef : Integer ) : Integer;
Begin
	If LineDefs [ iLineDef ].SideBack = -1 Then
		MapLineDefBackSector := -1
	Else
		MapLineDefBackSector := SideDefs [ LineDefs [ iLineDef ].SideBack ].Sector;
End;

Function TFormMain.MapFindLineDefByVertex ( iVertex : Integer; bStart : Boolean; iStartLineDef : Integer ) : Integer;
Var
	iLineDef : Integer;
	bFound : Boolean;
Begin
	iLineDef := iStartLineDef;
	bFound := False;
	//
	While Not bFound And ( iLineDef <= nLineDefs ) Do
	Begin
		If bStart Then
		Begin
			If LineDefs [ iLineDef ].VertexS = iVertex Then
			Begin
				bFound := True;
			End
			Else
			Begin
				Inc ( iLineDef );
			End;
		End
		Else
		Begin
			If LineDefs [ iLineDef ].VertexE = iVertex Then
			Begin
				bFound := True;
			End
			Else
			Begin
				Inc ( iLineDef );
			End;
		End;
	End;
	//
	If bFound Then
		MapFindLineDefByVertex := iLineDef
	Else
		MapFindLineDefByVertex := -1;
End;

procedure TFormMain.mnuDrawSplitSectorClick(Sender: TObject);
var
	iVertex, iLineDef : Integer;
	iCount, iFirst, iLast : Integer;
	//
	iSector : Integer;
	iS1, iS2, iS3, iS4 : Integer;
	//
	bStopped, bStartVertex : Boolean;
begin
	//
	iCount := 0;
	iFirst := -1;
	iLast := -1;
	//
	For iVertex := 0 To nVertex Do
	Begin
		//
		If Vertex [ iVertex ].Selected Then
		Begin
			Inc ( iCount );
			//
			If iFirst = -1 Then iFirst := iVertex;
			iLast := iVertex;
		End;
		//
	End;
	//
	If iCount = 2 Then
	Begin
		//
		// --- Find out current sector
		//
		iS1 := -1;
		iS2 := -1;
		iS3 := -1;
		iS4 := -1;
		For iLineDef := nLineDefs DownTo 0 Do
		Begin
			If ( LineDefs [ iLineDef ].VertexS = iFirst )
			Or ( LineDefs [ iLineDef ].VertexE = iFirst ) Then
			Begin
				If LineDefs [ iLineDef ].SideFront <> - 1 Then
				Begin
					iS1 := SideDefs [ LineDefs [ iLineDef ].SideFront ].Sector;
				End;
				If LineDefs [ iLineDef ].SideBack <> - 1 Then
				Begin
					iS2 := SideDefs [ LineDefs [ iLineDef ].SideBack ].Sector;
				End;
			End;
			//
			If ( LineDefs [ iLineDef ].VertexS = iLast )
			Or ( LineDefs [ iLineDef ].VertexE = iLast ) Then
			Begin
				If LineDefs [ iLineDef ].SideFront <> - 1 Then
				Begin
					iS3 := SideDefs [ LineDefs [ iLineDef ].SideFront ].Sector;
				End;
				If LineDefs [ iLineDef ].SideBack <> - 1 Then
				Begin
					iS4 := SideDefs [ LineDefs [ iLineDef ].SideBack ].Sector;
				End;
			End;
		End;
		//
		iSector := -1;
		If ( iS1 <> -1 ) And ( ( iS1 = iS3 ) Or ( iS1 = iS4 ) ) Then
			iSector := iS1;
		If ( iS2 <> -1 ) And ( ( iS2 = iS3 ) Or ( iS2 = iS4 ) ) Then
			iSector := iS2;
		//
		If iSector >= 0 Then
		Begin
			//
			// --- Add New Sector
			//     (same as the original one we're cutting)
			//
			MapSectorDuplicate ( iSector );
			//
			// --- Add two new transparent sidedefs
			//
			MapSideDefAddSectorMain ( iSector, '-' );
			MapSideDefAddSectorMain ( nSectors, '-' );
			//
			// --- Add New LineDef
			//
			Inc ( nLineDefs );
			LineDefs [ nLineDefs ].VertexS := iFirst;
			LineDefs [ nLineDefs ].VertexE := iLast;
			//
			LineDefs [ nLineDefs ].Flags := ldefTwoSided;
			LineDefs [ nLineDefs ].iType := 0;
			LineDefs [ nLineDefs ].Tag := 0;
			//
			LineDefs [ nLineDefs ].SideFront := nSideDefs;
			LineDefs [ nLineDefs ].SideBack := nSideDefs - 1;
			//
			bStopped := False;
			iVertex := iLast;
			iLineDef := 0;
			bStartVertex := True;
			While Not bStopped Do
			Begin
				iLineDef := MapFindLineDefByVertex ( iVertex, bStartVertex, iLineDef ); // by start vertex
				//
				If iLineDef >= 0 Then
				Begin
					If ( bStartVertex And ( SideDefs [ LineDefs [ iLineDef ].SideFront ].Sector = iSector ) )
					Or ( Not bStartVertex And ( MapLineDefBackSector ( iLineDef ) = iSector ) )Then
					Begin
						LineDefs [ iLineDef ].Selected := True;
						//
						If bStartVertex Then
						Begin
							// This was a front facing linedef, so continue at it's end
							SideDefs [ LineDefs [ iLineDef ].SideFront ].Sector := nSectors;
							iVertex := LineDefs [ iLineDef ].VertexE
						End
						Else
						Begin
							// This was a "back" facing linedef, so continue at it's beginning
							SideDefs [ LineDefs [ iLineDef ].SideBack ].Sector := nSectors;
							iVertex := LineDefs [ iLineDef ].VertexS
						End;
						//
						If iVertex = iFirst Then
							bStopped := True;
						//
						iLineDef := 0; // start next search from 0
						bStartVertex := True;
					End
					Else
					Begin
						Inc ( iLineDef ); // start next search from where we left off
					End;
				End
				Else
				Begin
					If Not bStartVertex Then
					Begin
						// the end, sector not closed.
						bStopped := True;
					End
					Else
					Begin
						// now try to find a "backwards" linedef
						iLineDef := 0; // start next search from 0
						bStartVertex := False;
					End;
				End;
			End;
			//
			//MapSelectSector ( iSector );
			//
			Modified ( True );
			MapRefresh;
			EditMapZoom.SetFocus;
		End
		Else
		Begin
			ShowMessage ( 'Internal error: couldn''t identify sector.' );
		End;
	End
	Else
	Begin
		ShowMessage ( 'For this option you must have 2 vertexes selected.' );
	End;
end;

Function TFormMain.MapLineDefGetAngle ( iLineDef : Integer ) : Integer;
Var
	x1, y1, x2, y2 : Integer;
Begin
	x1 := Vertex [ LineDefs [ iLineDef ].VertexS ].x;
	y1 := Vertex [ LineDefs [ iLineDef ].VertexS ].y;
	x2 := Vertex [ LineDefs [ iLineDef ].VertexE ].x;
	y2 := Vertex [ LineDefs [ iLineDef ].VertexE ].y;
	//
	If y1 = y2 Then
	Begin
		If x1 > x2 Then
			MapLineDefGetAngle := 90
		Else
			MapLineDefGetAngle := 270;
	End
	Else
	Begin
		If x1 = x2 Then
		Begin
			If y1 > y2 Then
				MapLineDefGetAngle := 180
			Else
				MapLineDefGetAngle := 0;
		End
		Else
		Begin
			// not n/e/w/s
			MapLineDefGetAngle := 0;
		End;
	End;
End;

Function TFormMain.MapVertexDistance ( v1, v2 : Integer ) : Integer;
Var
	x1, y1, x2, y2 : Integer;
Begin
	x1 := Vertex [ v1 ]. x;
	y1 := Vertex [ v1 ]. y;
	x2 := Vertex [ v2 ]. x;
	y2 := Vertex [ v2 ]. y;
	//
	MapVertexDistance := Trunc ( Sqrt ( ( x1 - x2 ) * ( x1 - x2 ) + ( y1 - y2 ) * ( y1 - y2 ) ) );
End;

Function TFormMain.MapLineDefGetLength ( iLineDef : Integer ) : Integer;
Begin
	MapLineDefGetLength := MapVertexDistance ( LineDefs [ iLineDef ].VertexS,
		LineDefs [ iLineDef ].VertexE );
End;

procedure TFormMain.MapDeleteThing ( i : Integer );
Var
	iThing : Integer;
Begin
	//
	// Copy all things back by one in the array
	//
	For iThing := i + 1 To nThings Do
	Begin
		Things [ iThing - 1 ] := Things [ iThing ];
	End;
	// Dec total things
	Dec ( nThings );
End;

procedure TFormMain.MapLineDefDelete ( i : Integer );
Var
	iLineDef : Integer;
Begin
	//
	// Copy all LineDefs back by one in the array
	//
	For iLineDef := i + 1 To nLineDefs Do
	Begin
		LineDefs [ iLineDef - 1 ] := LineDefs [ iLineDef ];
	End;
	// Dec total LineDefs
	Dec ( nLineDefs );
End;

procedure TFormMain.mnuSelectionDeleteClick(Sender: TObject);
begin
	MapDeleteSelected;
end;

procedure TFormMain.MapDeleteSelected;
Var
	iThing, iLineDef : Integer;
	bRefresh : Boolean;
Begin
	bRefresh := False;
	//
	// Go through all things
	//
	iThing := 0;
	While iThing <= nThings Do
	Begin
		If Things [ iThing ].Selected Then
		Begin
			MapDeleteThing ( iThing );
			bRefresh := True;
		End
		Else
		Begin
			Inc ( iThing );
		End;
	End;
	//
	// Go through all LineDefs
	//
	iLineDef := 0;
	While iLineDef <= nLineDefs Do
	Begin
		If LineDefs [ iLineDef ].Selected Then
		Begin
			MapLineDefDelete ( iLineDef );
			bRefresh := True;
		End
		Else
		Begin
			Inc ( iLineDef );
		End;
	End;
	//
	If bRefresh Then
	Begin
		MapRefresh;
		Modified ( True );
		MapModified := True;
	End;
	//
	EditMapZoom.SetFocus;
End;

procedure TFormMain.mnuSelectionDuplicateClick(Sender: TObject);
Var
	xs, ys, xl, yl : Integer;
	i : Integer;

Procedure CheckCoords ( x, y : Integer );
Begin
	If x < xs Then
		xs := x;
	If x > xl Then
		xl := x;
	If y < ys Then
		ys := y;
	If y > yl Then
		yl := y;
End;

begin
	xs := 32767;
	ys := 32767;
	xl := -32768;
	yl := -32768;
	//
	For i := 0 To nThings Do
	Begin
		If Things [ i ].Selected Then
		Begin
			CheckCoords ( Things [ i ]. x, Things [ i ]. y );
		End;
	End;
	//
	For i := 0 To nVertex Do
	Begin
		If Vertex [ i ].Selected Then
		Begin
			CheckCoords ( Vertex [ i ]. x, Vertex [ i ]. y );
		End;
	End;
	//
	For i := 0 To nLineDefs Do
	Begin
		If LineDefs [ i ].Selected Then
		Begin
			CheckCoords ( Vertex [ LineDefs [ i ].VertexS ]. x, Vertex [ LineDefs [ i ].VertexS ]. y );
			CheckCoords ( Vertex [ LineDefs [ i ].VertexE ]. x, Vertex [ LineDefs [ i ].VertexE ]. y );
		End;
	End;
	//
	MapClickX := Round ( xs + ( xl - xs ) / 2 );
	MapClickY := Round ( ys + ( yl - ys ) / 2 );
	MapClickXP := 0;
	MapClickYP := 0;
	//
	{
	CoordsMapToScreen ( xs, ys );
	CoordsMapToScreen ( xl, yl );
	//
	ImageMap.Canvas.Rectangle ( xs, ys, xl, yl );
	}
	//
	MapSetMode ( mmDuplicate );
end;

procedure TFormMain.EditMapZoomKeyDown(Sender: TObject; Var Key: Word;
	Shift: TShiftState);
Begin
	Case Key Of

		13 : { Enter }
		Begin
			// fake mouse click
			ImageMapMouseDown ( Sender, mbLeft, Shift, MapLastX, MapLastY );
		End;

		27 : { Esc }
		Begin
			If ( MapMode = mmDrag ) Or ( MapMode = mmSelect ) Then
			Begin
				// cancel dragging or selection
				MapModeRestore;
				MapRefresh;
				//
				MapCanDrag := False;
				MapCanSelect := False;
			End;
		End;

		36 : { Home: Zoom All }
		Begin
			MapZoomAll;
			MapRefresh;
		End;

		37 : { cursor left }
		Begin
			MapX := MapX + ImageMap.Width Div 20;
			MapQuickDraw := True;
			MapRefresh;
		End;

		38 : { cursor up }
		Begin
			MapY := MapY + ImageMap.Width Div 20;
      MapQuickDraw := True;
			MapRefresh;
		End;

		39 : { cursor right }
		Begin
			MapX := MapX - ImageMap.Width Div 20;
			MapQuickDraw := True;
			MapRefresh;
		End;

		40 : { cursor down }
		Begin
			MapY := MapY - ImageMap.Width Div 20;
			MapQuickDraw := True;
			MapRefresh;
		End;

		45 : { Insert }
		Begin
			// not implemented
		End;

		46 : { Delete }
		Begin
			MapDeleteSelected;
		End;

		51 : { 3 }
		Begin
			mnuMapView3DClick ( Sender );
		End;

		65 : { A All Mode }
		Begin
			If ( ssShift in Shift ) Then
			Begin
				MapAutoAlignSelection;
			End
			Else
			Begin
				MapSetMode ( mmAll );
			End;
		End;

		67 : { C Compile }
		Begin
			If Not ( ssShift in Shift )
			And Not ( ssCtrl in Shift ) Then
			Begin
				mnuMapCompileClick ( Sender );
			End;
		End;

		68 : { D Draw }
		Begin
			If ( ssShift in Shift ) And Not ( ssCtrl in Shift ) Then
			Begin
				DoMapLoad;
				MapSetMode ( mmDrawNewSector );
			End
			Else
			Begin
				If ( ssShift in Shift ) And ( ssCtrl in Shift ) Then
				Begin
					DoMapLoad;
					MapDisplayDemo ( 'DEMO1' );
				End
				Else
				Begin
					If Not ( ssAlt in Shift ) Then
					Begin
						DoMapLoad;
						MapSetMode ( mmDraw );
					End;
				End;
			End;
		End;

		69 : { E fix all errors }
		Begin
			If Not ( ssAlt in Shift ) Then
				mnuMapFixAllErrorsClick ( Sender );
		End;

		70 : { F flip linedefs }
		Begin
			If Not ( ssAlt in Shift ) Then
				MapFlipLineDefs;
		End;

		71 : { G Grid }
		Begin
			mnuMapViewGridClick ( Sender );
		End;

		72 : { H Horizontal flip }
		Begin
			If ( ssShift in Shift ) Then
			Begin
				MapFlip ( True );
			End;
		End;

		74 : { J join linedefs }
		Begin
			MapJoinLineDefs;
		End;

		75 : { K checK Map }
		Begin
			mnuMapCheckClick ( Sender );
		End;

		76 : { L linedefs }
		Begin
			If ssShift in Shift Then
			Begin
				mnuMapDisplayLinedefLengthsClick ( Sender );
			End
			Else
			Begin
				MapSetMode ( mmLineDefs );
			End;
		End;

		77 : { M Make Sector }
		Begin
			If Not ( ssAlt in Shift ) And Not ( ssCtrl in Shift ) Then
			Begin
				CoordsScreenToMap ( MapLastX, MapLastY );
				MapMakeSector ( MapLastX, MapLastY );
			End;
		End;

		82 : { R Run }
		Begin
			If Not ( ssAlt in Shift ) And Not ( ssCtrl in Shift ) Then
			Begin
				If ssShift in Shift Then
					MapRunXWEScript ( '' )
				Else
					mnuMapRunClick ( Sender )
			End;
		End;

		83 : { S sectors/save }
		Begin
			If ssShift in Shift Then
			Begin
				mnuMapSaveClick ( Sender );
			End
			Else
			Begin
				MapSetMode ( mmSectors );
			End;
		End;

		84 : { T things mode/show hide things }
		Begin
			If ssShift in Shift Then
			Begin
				mnuMapViewShowThingsClick ( Sender );
			End
			Else
			Begin
				MapSetMode ( mmThings );
			End;
		End;

		86 : { V Vertex Mode }
		Begin
			If ( ssShift in Shift ) Then
			Begin
				MapFlip ( False ); // Vertical
			End
			Else
			Begin
				If ( ssCtrl in Shift ) Then
				Begin
					mnuSelectionDuplicateClick ( Sender );
				End
				Else
				Begin
					MapSetMode ( mmVertex );
				End;
			End;
		End;

		87 : { W Waded Bar }
		Begin
			If Not ( ssAlt in Shift ) And Not ( ssCtrl in Shift ) Then
			Begin
				mnuMapViewWadedBarClick ( Sender );
			End;
		End;

		88 : { X split linedefs }
		Begin
			If ssShift in Shift Then
			Begin
				MapSplitLineDefs3;
			End
			Else
			Begin
				MapSplitLineDefs;
			End;
		End;

		90 : { Z zoomin }
		Begin
			//
			CoordsScreenToMap ( MapLastX, MapLastY );
			//
			MapZoom := 4;
			//
			MapX := Round ( -MapLastX * MapZoom + ImageMap.Width Div 2 );
			MapY := Round ( MapLastY * MapZoom + ImageMap.Height Div 2 );
			//
			MapRefresh;
			//
			MapLastX := ImageMap.Width Div 2;
			MapLastY := ImageMap.Height Div 2;
		End;

		107 : {'+'}
		Begin
			If ssShift in Shift Then
			Begin
				MapGridInc;
			End
			Else
			Begin
				MapZoomIn;
			End;
		End;

		109 : {'-'}
		Begin
			If ssShift in Shift Then
			Begin
				MapGridDec;
			End
			Else
			Begin
				MapZoomOut;
			End;
		End;

		188 : { , comma: Rotate Left }
		Begin
			MapRotate ( False );
		End;

		190 : { , comma: Rotate Right }
		Begin
			MapRotate ( True );
		End;

		Else
      FormKeyDown ( Sender, Key, Shift );

	End;
end;

procedure TFormMain.EditMapZoomKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	Case Key Of

		13 : { enter }
		Begin
			// fake mouse click
			ImageMapMouseUp ( Sender, mbLeft, Shift, MapLastX, MapLastY );
		End;

		37, 38, 39, 40 : { cursor keys }
		Begin
			If MapQuickDraw Then
			Begin
				MapQuickDraw := False;
				MapRefresh;
			End;
		End;
	End;
end;

//***************************************************************************
// XWE SCRipt

Procedure TFormMain.MapRunXWEScript ( sFileName : String );
Var
	sf : File;
	s : String;
	//
	bStop : Boolean;
	//
	CommandCode : Integer;
	nParams : Integer;
	Params : Array [ 1 .. 256 ] Of String;
	//
	bRefresh : Boolean;
	//
	i : Integer;
	nLineDefsSelected : Integer;
	//
	// -- sector
	iSector : Integer;
	iProperty : Integer;
	Value : Variant;
	//
	// -- linedef
	iLineDef : Integer;
	iSV, iEV : Integer;
	Angle, DistLen, DistLen2 : Integer; // move
	//
	// -- point
	x, y : Integer;
	Dist, xr, yr : Double;
	//
	// -- thing
	iThing : Integer;
	//
	// -- vertex
	iVertex : Integer;

Function GetLine : String;
Var
	b : Byte;
	s0 : String;
Begin
	s0 := '';
	b := 0;
	While ( b <> 13 ) And Not Eof ( sf ) Do
	Begin
		b := GetByte ( sf );
		If ( b <> 10 ) And ( b <> 13 ) Then
		Begin
			s0 := s0 + Chr ( b );
		End;
	End;
	//
	s0 := Trim ( Replace ( s0, #9, ' ' ) );
	//
	GetLine := s0;
End;

Procedure ParseCommand ( s : String );
Var
	i : Integer;
	cm : String;
Begin
	CommandCode := 0;
	//
	If Length ( s ) > 0 Then
	Begin
		s := UpperCase ( s );
		//
		If Copy ( s, 1, 1 ) <> ';' Then
		Begin
			//
			i := 1;
			While ( ( s [ i ] >= 'A' ) And ( s [ i ] <= 'Z' ) )
			Or ( ( i > 1 ) And ( s [ i ] >= '0' ) And ( s [ i ] <= '9' ) ) Do
			Begin
				Inc ( i );
			End;
			cm := Copy ( s, 1, i - 1 );
			//
			If Copy ( Trim ( RemoveFromLeft ( s, i ) ), 1, 1 ) <> '=' Then
			Begin
				//
				CommandCode := ConstantFindByDescription ( 'XWESCRIPT', cm );
				//
			End;
		End;
	End;
End;

Procedure ParseLine ( sl : String );
Var
	i : Integer;
	cm : String; // command
	sp : String; // params
	isString : Boolean;
	Bracket : Integer;
Begin
	//
	sl := UpperCase ( sl );
	CommandCode := 0; // default
	//
	i := 1;
	//
	If Length ( sl ) > 0 Then
	Begin
		While ( ( sl [ i ] >= 'A' ) And ( sl [ i ] <= 'Z' ) )
		Or ( ( i > 1 ) And ( sl [ i ] >= '0' ) And ( sl [ i ] <= '9' ) ) Do
		Begin
			Inc ( i );
		End;
		//
		cm := Copy ( sl, 1, i - 1 );
		sp := Trim ( RemoveFromLeft ( sl, i ) );
		//
		If Copy ( sp, 1, 1 ) = '=' Then
		Begin
			//
			// Assignment
			//
			CommandCode := 0; // no command
			//
			sp := Trim ( RemoveFromLeft ( sp, 1 ) );
			SetVariable ( cm, Eval ( sp ) );
			//
			//ShowMessage ( cm + '=' + Comma ( GetVariable ( cm ) ) );
			//
		End
		Else
		Begin
			//
			ParseCommand ( sl );
			//
			If CommandCode < 0 Then
			Begin
				// !!!
				If MessageDlg ( 'Unknown command: ' + sl + #13 + 'Abort script?', mtConfirmation, [mbYes,mbNo], 0 ) = mrYes Then
				Begin
					bStop := True;
				End;
			End;
			//
			// --- Parse params
			//
			If ( Copy ( sp, 1, 1 ) = '(' )
			And ( KeepFromRight ( sp, 1 ) = ')' ) Then
			Begin
				sp := RemoveFromLeft ( RemoveFromRight ( sp, 1 ), 1 );
			End;
			sp := Trim ( sp );
			//
			isString := False;
			Bracket := 0;
			nParams := 0;
			i := 1;
			While sp <> '' Do
			Begin
				If ( i > Length ( sp ) ) Then
				Begin
					Inc ( nParams );
					Params [ nParams ] := Trim ( sp );
					sp := '';
				End
				Else
				Begin
					If sp [ i ] = '''' Then
					Begin
						isString := Not isString;
					End
					Else
					Begin
						If sp [ i ] = '(' Then
						Begin
							Inc ( Bracket );
						End
						Else
						Begin
							If sp [ i ] = ')' Then
							Begin
								Dec ( Bracket );
							End
							Else
							Begin
								If ( sp [ i ] = ',' ) And ( Bracket = 0 ) Then
								Begin
									Inc ( nParams );
									Params [ nParams ] := Trim ( Copy ( sp, 1, i - 1 ) );
									sp := RemoveFromLeft ( sp, i );
									i := 0;
								End;
							End;
						End;
					End;
					//
					Inc ( i );
				End;
			End;
		End;
	End;
End;

Function GetParam ( ParamIndex : Integer; Default : Variant ) : Variant;
Begin
	If ParamIndex > nParams Then
		GetParam := Default
	Else
		GetParam := Eval ( Params [ ParamIndex ] );
End;

Procedure ScriptError ( sError : String );
Begin
	ShowMessage ( sError );
End;

//

Function GetTexture ( sVar : String ) : String;
Var
	Value : Variant;
Begin
	Value := GetVariable ( sVar );
	If VarType ( Value ) <> VarString Then
		GetTexture := '-'
	Else
		GetTexture := Value;
End;

Function GetSector ( sVar : String ) : Integer;
Var
	Value : Variant;
Begin
	Value := GetVariable ( sVar );
	If VarType ( Value ) <> VarInteger Then
		GetSector := nSectors
	Else
		GetSector := Value;
End;

Function GetInteger ( sVar : String; Default : Integer ) : Integer;
Var
	Value : Variant;
	VType : Integer;
Begin
	Value := GetVariable ( sVar );
	VType := VarType ( Value );
	If ( VType = VarInteger ) Or ( VType = varByte ) Then
	Begin
		GetInteger := Value
	End
	Else
	Begin
		If ( VType = VarDouble ) Then
		Begin
			GetInteger := Value;
		End
		Else
		Begin
			GetInteger := Default
		End;
	End;
End;

Procedure NewLineDef ( iSV, iEV : Integer );

Var
	iFlags : Integer;
	iLineDef : Integer;
	bDone : Boolean;

Procedure AddFrontSideDef;
Begin
	//
	// --- Add Front SideDef
	//
	MapSideDefAddSectorMain ( GetSector ( 'LINEDEFFRONTSECTOR' ), GetTexture ( 'LINEDEFFRONTMAINTEXTURE' ) );
	SideDefs [ nSideDefs ].Above := GetTexture ( 'LINEDEFFRONTABOVETEXTURE' );
	SideDefs [ nSideDefs ].Below := GetTexture ( 'LINEDEFFRONTBELOWTEXTURE' );
	SideDefs [ nSideDefs ].xOffset := GetInteger ( 'LINEDEFFRONTXOFFSET', 0 );
	SideDefs [ nSideDefs ].yOffset := GetInteger ( 'LINEDEFFRONTYOFFSET', 0 );
End;

Begin
	//
	iFlags := GetInteger ( 'LINEDEFFLAGS', 0 );
	//
	bDone := False;
	//
	iLineDef := 0;
	While iLineDef <= nLineDefs Do
	Begin
		If ( LineDefs [ iLineDef ].VertexS = iSV )
		And ( LineDefs [ iLineDef ].VertexE = iEV ) Then
		Begin
			//!!!
			//ShowMessage ( 'Exists' );
			//
		End
		Else
		Begin
			If ( LineDefs [ iLineDef ].VertexS = iEV )
			And ( LineDefs [ iLineDef ].VertexE = iSV ) Then
			Begin
				//
				// --- Back side def exists
				//
				With LineDefs [ iLineDef ] Do
				Begin
					// --- make two sided
					Flags := Flags Or ldefTwoSided;
					//
					If SideBack = -1 Then
					Begin
						AddFrontSideDef;
						SideBack := nSideDefs;
						//
					End
					Else
					Begin
						SideDefs [ SideBack ].Sector := GetSector ( 'LINEDEFFRONTSECTOR' );
						// !!! etc.
					End;
					//
					// --- copy main to above/below textures -
					//     (to avoid hall of mirrors)
					If Trim ( SideDefs [ SideFront ].Above ) = '-' Then
					Begin
						SideDefs [ SideFront ].Above := SideDefs [ SideFront ].Main;
					End;
					If Trim ( SideDefs [ SideFront ].Below ) = '-' Then
					Begin
						SideDefs [ SideFront ].Below := SideDefs [ SideFront ].Main;
					End;
					//
					// --- clear main textures -
					SideDefs [ SideFront ].Main := '-';
					SideDefs [ SideBack ].Main := '-';
					//
					Selected := True;
				End;
				//
				bDone := True;
				//
			End;
		End;
		//
		Inc ( iLineDef );
	End;
	//
	If Not bDone Then
	Begin
		//
		// --- Add Front SideDef
		//
		AddFrontSideDef;
		//
		If ( iFlags And ldefTwoSided ) <> 0 Then
		Begin
			//
			// --- Add Back SideDef
			//
			MapSideDefAddSectorMain ( GetSector ( 'LINEDEFBACKSECTOR' ), GetTexture ( 'LINEDEFBACKMAINTEXTURE' ) );
			SideDefs [ nSideDefs ].Above := GetTexture ( 'LINEDEFBACKABOVETEXTURE' );
			SideDefs [ nSideDefs ].Below := GetTexture ( 'LINEDEFBACKBELOWTEXTURE' );
			SideDefs [ nSideDefs ].xOffset := GetInteger ( 'LINEDEFBACKXOFFSET', 0 );
			SideDefs [ nSideDefs ].yOffset := GetInteger ( 'LINEDEFBACKYOFFSET', 0 );
		End;
		//
		// --- Add new LineDef
		//
		Inc ( nLineDefs );
		With LineDefs [ nLineDefs ] Do
		Begin
			VertexS := iSV;
			VertexE := iEV;
			Flags := iFlags;
			iType := GetInteger ( 'LINEDEFTYPE', 0 );
			Tag := GetInteger ( 'LINEDEFTAG', 0 );
			//
			Arg1 := GetInteger ( 'LINEDEFARG1', 0 );
			Arg2 := GetInteger ( 'LINEDEFARG2', 0 );
			Arg3 := GetInteger ( 'LINEDEFARG3', 0 );
			Arg4 := GetInteger ( 'LINEDEFARG4', 0 );
			Arg5 := GetInteger ( 'LINEDEFARG5', 0 );
			//
			If ( iFlags And ldefTwoSided ) <> 0 Then
			Begin
				SideFront := nSideDefs - 1;
				SideBack := nSideDefs;
			End
			Else
			Begin
				SideFront := nSideDefs;
				SideBack := -1;
			End;
			//
			Selected := True;
		End;
	End;
	//
	MapClickX := Vertex [ iEV ]. x;
	MapClickY := Vertex [ iEV ]. y;
	//
	bRefresh := True;
End;

Begin
	bStop := False;
	//
	If sFileName = '' Then
	Begin
		With OpenDialog1 Do
		Begin
			InitialDir := sLastFolderXWEScript;
			Title := 'Select XWE Script File';
			Filter := 'Text Files|*.txt|All Files|*.*';
			If Execute And ( FileName <> '' ) Then
			Begin
				sFileName := FileName;
				sLastFolderXWEScript := Copy ( sFileName, 1, PosR ( '\', sFileName ) );
			End;
			Filter := '';
		End;
	End;
	//
	If sFileName <> '' Then
	Begin
		Status ( 'Executing script...' );
		//
		// TF ThingFlags
		SetVariable ( 'TF_LEVEL12', 1 );
		SetVariable ( 'TF_LEVEL3', 2 );
		SetVariable ( 'TF_LEVEL45', 4 );
		//
		// LF LinedefFlags
		SetVariable ( 'LF_IMPASSABLE', $0001 );
		SetVariable ( 'LF_BLOCKMONSTERS', $0002 );
		SetVariable ( 'LF_TWOSIDED', $0004 );
		SetVariable ( 'LF_UPPERUNPEGGED', $0008 );
		SetVariable ( 'LF_LOWERUNPEGGED', $0010 );
		SetVariable ( 'LF_SECRET', $0020 );
		SetVariable ( 'LF_BLOCKSOUND', $0040 );
		SetVariable ( 'LF_NEVERMAP', $0080 );
		SetVariable ( 'LF_ALWAYSMAP', $0100 );
		SetVariable ( 'LF_REPEATABLE', $0200 ); { zdoom }
		SetVariable ( 'LF_ENEMYACTIVATE', $2000 ); { zdoom }
		SetVariable ( 'LF_BLOCKEVERYTHING', $8000 ); { zdoom }
		//
		// ---
		SetVariable ( 'MAPANGLE', 0 );
		SetVariable ( 'PEN', 1 );
		//
		SetVariable ( 'LINEDEFFRONTABOVETEXTURE', '-' );
		SetVariable ( 'LINEDEFFRONTMAINTEXTURE', '-' );
		SetVariable ( 'LINEDEFFRONTBELOWTEXTURE', '-' );
		SetVariable ( 'LINEDEFBACKABOVETEXTURE', '-' );
		SetVariable ( 'LINEDEFBACKMAINTEXTURE', '-' );
		SetVariable ( 'LINEDEFBACKBELOWTEXTURE', '-' );
		//
		SetVariable ( 'LINEDEFFLAGS', 0 );
		SetVariable ( 'LINEDEFFRONTXOFFSET', 0 );
		SetVariable ( 'LINEDEFFRONTYOFFSET', 0 );
		SetVariable ( 'LINEDEFBACKXOFFSET', 0 );
		SetVariable ( 'LINEDEFBACKYOFFSET', 0 );
		//
		nXSLoops := 0;
		nXSCalls := 0;
		//
		bRefresh := False;
		//
		AssignFile ( sf, sFileName );
		FileMode := fmOpenReadWrite; // could be read
		Reset ( sf, 1 );
		//
		While Not Eof ( sf ) And Not bStop Do
		Begin
			//
			SetVariable ( 'MAPX', MapClickX );
			SetVariable ( 'MAPY', MapClickY );
			SetVariable ( 'NLINEDEFS', nLineDefs );
			SetVariable ( 'NTHINGS', nThings );
			SetVariable ( 'NSECTORS', nSectors );
			SetVariable ( 'NVERTEX', nVertex );
			//
			nLineDefsSelected := 0;
			For i := 0 To nLineDefs Do
			Begin
				If LineDefs [ i ].Selected Then
					Inc ( nLineDefsSelected );
			End;
			SetVariable ( 'NLINEDEFSSELECTED', nLineDefsSelected );
			//
			s := GetLine;
			//
			If s <> '' Then
			Begin
				//
				ParseLine ( s );
				//
				Case CommandCode Of

					{ STOP }
					99 :
					Begin
						bStop := True; // exit from script
					End;

					{ FOR <variable> <start> <end> <step> }
					100 :
					Begin
						//
						If nParams = 0 Then
						Begin
							ScriptError ( 'FOR loop variable missing.' );
						End
						Else
						Begin
							//
							Inc ( nXSLoops );
							//
							With XSLoops [ nXSLoops ] Do
							Begin
								FirstLine := FilePos ( sf );
								//
								VariableName := Params [ 1 ];
								//
								Value := GetParam ( 2, 1 );
								EndValue := GetParam ( 3, Value + 9 );
								StepValue := GetParam ( 4, 1 );
								//
								SetVariable ( VariableName, Value );
							End;
						End;
					End;

					{ NEXT }
					101 :
					Begin
						//
						With XSLoops [ nXSLoops ] Do
						Begin
							Value := Value + StepValue;
							//
							If ( ( StepValue > 0 ) And ( Value <= EndValue ) )
							Or ( ( StepValue < 0 ) And ( Value >= EndValue ) ) Then
							Begin
								Seek ( sf, FirstLine );
								SetVariable ( VariableName, Value );
							End
							Else
							Begin
								// end of the loop
								Dec ( nXSLoops );
							End;
						End;
						//
					End;

					{ IF <expression> }
					102 :
					Begin
						Value := Eval ( Params [ 1 ] );
						If Value <> 0 Then
						Begin
							// true, so continue with script?
						End
						Else
						Begin
							// find next else or endif
							i := 1;
							While i > 0 Do
							Begin
								s := GetLine;
								ParseCommand ( s );
								If CommandCode = 102 Then
									Inc ( i ); // next level
								If CommandCode = 104 Then
									Dec ( i ); // prev level
								If ( CommandCode = 103 ) And ( i = 1 ) Then
									Dec ( i ); // else on our level
							End;
						End;
					End;

					{ ELSE }
					103 :
					Begin
						// assume we bumped into this else
						// because we are inside an if, so
						// find next endif
						While ( CommandCode <> 104 ) Do
						Begin
							s := GetLine;
							ParseCommand ( s );
						End;
					End;

					{ CALL <identifier> }
					105 :
					Begin
						If nParams = 0 Then
						Begin
							ScriptError ( 'CALL identifier missing.' );
						End
						Else
						Begin
							//
							Inc ( nXSCalls );
							//
							// remember return position
							With XSCalls [ nXSCalls ] Do
							Begin
								ReturnLine := FilePos ( sf );
								SubName := Params [ 1 ];
								//
								i := 1;
								While ( nParams > i ) And ( i < 8 ) Do
								Begin
									Inc ( i );
									CallParams [ i - 1 ] := Eval ( Params [ i ] );
									SetVariable ( 'PARAM' + IntToStr ( i - 1 ), Eval ( Params [ i ] ) );
								End;
							End;
							//
							// find CALL <identifier>
							While ( CommandCode <> 106 ) And Not EOF ( sf ) Do
							Begin
								s := GetLine;
								ParseCommand ( s );
								If CommandCode = 106 Then
								Begin
									// This is a CALL command, but check if it's the
									// one we're looking for
									ParseLine ( s );
									If Params [ 1 ] <> XSCalls [ nXSCalls ].SubName Then
									Begin
										// wrong sub, keep going
										CommandCode := 0;
									End;
								End;
							End;
							//
							If EOF ( sf ) Then
							Begin
								ScriptError ( 'Invalid CALL, sub ' +
									XSCalls [ nXSCalls ].SubName + ' does not exist.' );
							End;
						End;
					End;

					{ SUB }
					106 :
					Begin
						// skip everything until ENDSUB
						While CommandCode <> 107 Do
						Begin
							s := GetLine;
							ParseCommand ( s );
						End;
					End;

					{ ENDSUB }
					107 :
					Begin
						If nXSCalls = 0 Then
						Begin
							ScriptError ( 'ENDSUB without SUB found.' );
						End
						Else
						Begin
							// return
							Seek ( sf, XSCalls [ nXSCalls ]. ReturnLine );
							Dec ( nXSCalls );
						End;
					End;

					{ LEFT }
					900 :
					Begin
						Value := ( GetVariable ( 'MAPANGLE' ) + 90 ) Mod 360;
						SetVariable ( 'MAPANGLE', Value );
					End;

					{ RIGHT }
					901 :
					Begin
						Value := ( GetVariable ( 'MAPANGLE' ) - 90 );
						If Value < 0 Then
							Value := Value + 360;
						SetVariable ( 'MAPANGLE', Value );
					End;

					{ TURNAROUND }
					902 :
					Begin
						Value := ( GetVariable ( 'MAPANGLE' ) Mod 360 );
						If Value >= 180 Then
							Value := Value - 180
						Else
							Value := Value + 180;
						SetVariable ( 'MAPANGLE', Value );
					End;

					{ MOVE <DISTANCE> [<DISTANCE2>] }
					903 :
					Begin
						MapClickX := GetVariable ( 'MAPX' );
						MapClickY := GetVariable ( 'MAPY' );
						iSV := MapVertexAdd ( MapClickX, MapClickY );
						//
						Angle := ( GetVariable ( 'MAPANGLE' ) Mod 360 ) Div 90;
						DistLen := GetParam ( 1, 64 );
						DistLen2 := GetParam ( 2, 0 );
						//
						Case Angle Of
							0 : { east }
							Begin
								MapClickX := MapClickX + DistLen;
								MapClickY := MapClickY + DistLen2;
							End;
							1 : { north }
							Begin
								MapClickY := MapClickY + DistLen;
								MapClickX := MapClickX - DistLen2;
							End;
							2 : { west }
							Begin
								MapClickX := MapClickX - DistLen;
								MapClickY := MapClickY - DistLen2;
							End;
							3 : { south }
							Begin
								MapClickY := MapClickY - DistLen;
								MapClickX := MapClickX + DistLen2;
							End;
							Else
							Begin
								ScriptError ( 'Move command issued with current angle is not N/E/S/W.' );
							End;
						End;
						//
						// -- update
						SetVariable ( 'MAPX', MapClickX );
						SetVariable ( 'MAPY', MapClickY );
						//
						iEV := MapVertexAdd ( MapClickX, MapClickY );
						//
						If GetVariable ( 'PEN' ) = 1 Then
						Begin
							NewLineDef ( iSV, iEV );
						End;
					End;

					{ MOVETO <X> <Y> }
					904 :
					Begin
						MapClickX := GetParam ( 1, MapClickX );
						MapClickY := GetParam ( 2, MapClickY );
						SetVariable ( 'MAPX', MapClickX );
						SetVariable ( 'MAPY', MapClickY );
					End;

					{ DOWN }
					905 :
					Begin
						SetVariable ( 'PEN', 1 );
					End;

					{ UP }
					906 :
					Begin
						SetVariable ( 'PEN', 0 );
					End;

					{ NEWLINEDEF <X1> <Y1> <X2> <Y2> }
					1000 :
					Begin
						iSV := MapVertexAdd ( GetParam ( 1, 0 ), GetParam ( 2, 0 ) );
						iEV := MapVertexAdd ( GetParam ( 3, 0 ), GetParam ( 4, 0 ) );
						//
						NewLineDef ( iSV, iEV );
						//
					End;

					{ NEWLINEDEFTO <X1> <Y1> }
					1001 :
					Begin
						iSV := MapVertexAdd ( MapClickX, MapClickY );
						iEV := MapVertexAdd ( GetParam ( 1, 0 ), GetParam ( 2, 0 ) );
						//
						NewLineDef ( iSV, iEV );
						//
					End;

					{ SETLINEDEFPROPERTY <LINEDEFID> <PROPERTY> <VALUE> }
					1002 :
					Begin
						iLineDef := GetParam ( 1, 0 );
						iProperty := ConstantFindByDescription ( 'LINEDEFPROPERTY', Params [ 2 ] );
						If iProperty < 1 Then
						Begin
							ScriptError ( 'Invalid LineDef property "' + Params [ 2 ] + '".' );
						End
						Else
						Begin
							Case iProperty Of

								1 : ScriptError ( 'LineDef ID cannot be set.' );

								2 : LineDefs [ iLineDef ].VertexS := GetParam ( 3, 0 );
								3 : LineDefs [ iLineDef ].VertexE := GetParam ( 3, 0 );
								4 : LineDefs [ iLineDef ].Flags := GetParam ( 3, 0 );
								5 : LineDefs [ iLineDef ].iType := GetParam ( 3, 0 );
								6 : LineDefs [ iLineDef ].Tag := GetParam ( 3, 0 );

								7 : LineDefs [ iLineDef ].SideFront := GetParam ( 3, 0 ); // dangerous!
								8 : LineDefs [ iLineDef ].SideBack := GetParam ( 3, 0 );

								09 : LineDefs [ iLineDef ].ARG1 := GetParam ( 3, 0 );
								10 : LineDefs [ iLineDef ].ARG2 := GetParam ( 3, 0 );
								11 : LineDefs [ iLineDef ].ARG3 := GetParam ( 3, 0 );
								12 : LineDefs [ iLineDef ].ARG4 := GetParam ( 3, 0 );
								13 : LineDefs [ iLineDef ].ARG5 := GetParam ( 3, 0 );

								14 : LineDefs [ iLineDef ].Selected := GetParam ( 3, 0 ) <> 0;

								15 : SideDefs [ LineDefs [ iLineDef ].SideFront ].Above := Eval ( Params [ 3 ] );
								16 : SideDefs [ LineDefs [ iLineDef ].SideFront ].Main := Eval ( Params [ 3 ] );
								17 : SideDefs [ LineDefs [ iLineDef ].SideFront ].Below := Eval ( Params [ 3 ] );
								18 : SideDefs [ LineDefs [ iLineDef ].SideFront ].xOffset := Eval ( Params [ 3 ] );
								19 : SideDefs [ LineDefs [ iLineDef ].SideFront ].yOffset := Eval ( Params [ 3 ] );
								20 : SideDefs [ LineDefs [ iLineDef ].SideFront ].Sector := GetParam ( 3, 0 );

								21 : SideDefs [ LineDefs [ iLineDef ].SideBack ].Above := Eval ( Params [ 3 ] );
								22 : SideDefs [ LineDefs [ iLineDef ].SideBack ].Main := Eval ( Params [ 3 ] );
								23 : SideDefs [ LineDefs [ iLineDef ].SideBack ].Below := Eval ( Params [ 3 ] );
								24 : SideDefs [ LineDefs [ iLineDef ].SideBack ].xOffset := Eval ( Params [ 3 ] );
								25 : SideDefs [ LineDefs [ iLineDef ].SideBack ].yOffset := Eval ( Params [ 3 ] );
								26 : SideDefs [ LineDefs [ iLineDef ].SideBack ].Sector := GetParam ( 3, 0 );

								27 : ScriptError ( 'LineDef Angle cannot be set.' );
								28 : ScriptError ( 'LineDef Length cannot be set.' );

							End;
							//
							bRefresh := True;
						End;
					End;

					{ GETLINEDEFPROPERTY <VAR> <LINEDEFID> <PROPERTY> }
					1003 :
					Begin
						iLineDef := GetParam ( 2, 0 );
						iProperty := ConstantFindByDescription ( 'LINEDEFPROPERTY', Params [ 3 ] );
						If iProperty < 1 Then
						Begin
							ScriptError ( 'Invalid LineDef property "' + Params [ 3 ] + '".' );
						End
						Else
						Begin
							Case iProperty Of

								1 : Value := iLineDef; // kind of pointless, but there

								2 : Value := LineDefs [ iLineDef ].VertexS;
								3 : Value := LineDefs [ iLineDef ].VertexE;
								4 : Value := LineDefs [ iLineDef ].Flags;
								5 : Value := LineDefs [ iLineDef ].iType;
								6 : Value := LineDefs [ iLineDef ].Tag;

								7 : Value := LineDefs [ iLineDef ].SideFront;
								8 : Value := LineDefs [ iLineDef ].SideBack;

								09 : Value := LineDefs [ iLineDef ].Arg1;
								10 : Value := LineDefs [ iLineDef ].Arg2;
								11 : Value := LineDefs [ iLineDef ].Arg3;
								12 : Value := LineDefs [ iLineDef ].Arg4;
								13 : Value := LineDefs [ iLineDef ].Arg5;

								14 : Value := LineDefs [ iLineDef ].Selected;

								15 : Value := SideDefs [ LineDefs [ iLineDef ].SideFront ].Above;
								16 : Value := SideDefs [ LineDefs [ iLineDef ].SideFront ].Main;
								17 : Value := SideDefs [ LineDefs [ iLineDef ].SideFront ].Below;
								18 : Value := SideDefs [ LineDefs [ iLineDef ].SideFront ].xOffset;
								19 : Value := SideDefs [ LineDefs [ iLineDef ].SideFront ].yOffset;
								20 : Value := SideDefs [ LineDefs [ iLineDef ].SideFront ].Sector;

								21 : Value := SideDefs [ LineDefs [ iLineDef ].SideBack ].Above;
								22 : Value := SideDefs [ LineDefs [ iLineDef ].SideBack ].Main;
								23 : Value := SideDefs [ LineDefs [ iLineDef ].SideBack ].Below;
								24 : Value := SideDefs [ LineDefs [ iLineDef ].SideBack ].xOffset;
								25 : Value := SideDefs [ LineDefs [ iLineDef ].SideBack ].yOffset;
								26 : Value := SideDefs [ LineDefs [ iLineDef ].SideBack ].Sector;

								27 : Value := MapLineDefGetAngle ( iLineDef );
								28 : Value := MapLineDefGetLength ( iLineDef );

							End;
							//
							SetVariable ( Params [ 1 ], Value );
						End;
					End;

					{ DELETELINEDEF <LINEDEFID> }
					1004 :
					Begin
						MapLineDefDelete ( GetParam ( 1, 0 ) );
						bRefresh := True;
					End;

					{ SPLIT <LINEDEFID> }
					1010 :
					Begin
						MapSplitLineDef ( GetParam ( 1, 0 ) );
						bRefresh := True;
					End;

					{ SPLIT3 <LINEDEFID> }
					1011 :
					Begin
						MapSplitLineDef3 ( GetParam ( 1, 0 ), GetParam ( 2, 0 ) );
						bRefresh := True;
					End;

					{ GETSELECTEDLINEDEF <VAR> [<INDEX>] }
					1020 :
					Begin
						i := GetParam ( 2, 0 );
						iLineDef := -1;
						Repeat
							Inc ( iLineDef );
							While Not LineDefs [ iLineDef ].Selected Do
							Begin
								Inc ( iLineDef );
							End;
							Dec ( i );
						Until i < 0;
						//
						SetVariable ( Params [ 1 ], iLineDef );
					End;

					{ NEWTHING <ID> <X> <Y> [<ANGLE>] [<FLAGS>] }
					2000 :
					Begin
						Inc ( nThings );
						With Things [ nThings ] Do
						Begin
							iType := Eval ( Params [ 1 ] );
							x := Eval ( Params [ 2 ] );
							y := Eval ( Params [ 3 ] );
							Angle := GetParam ( 4, 0 );
							Flags := GetParam ( 5, 7 );
							Tag := GetParam ( 6, 0 );
							// --
							z := GetParam ( 7, 0 );
							Special := GetParam ( 8, 0 );
							Arg1 := GetParam ( 9, 0 );
							Arg2 := GetParam ( 10, 0 );
							Arg3 := GetParam ( 11, 0 );
							Arg4 := GetParam ( 12, 0 );
							Arg5 := GetParam ( 13, 0 );
						End;
						//
						bRefresh := True;
					End;

					{ SETTHINGPROPERTY <THING_ID> <PROPERTY_NAME> <VALUE> }
					2002 :
					Begin
						iThing := GetParam ( 1, 0 );
						iProperty := ConstantFindByDescription ( 'THINGPROPERTY', Params [ 2 ] );
						If iProperty < 1 Then
						Begin
							ScriptError ( 'Invalid Thing property "' + Params [ 2 ] + '".' );
						End
						Else
						Begin
							//
							bRefresh := True;
							//
							Case iProperty Of

								1 : { id }
								Begin
									ScriptError ( 'Thing ID cannot be set.' );
								End;

								2 : { x }
								Begin
									Things [ iThing ].x := GetParam ( 3, 0 );
								End;

								3 : { y }
								Begin
									Things [ iThing ].y := GetParam ( 3, 0 );
								End;

							End;
						End;
					End;

					{ GETTHINGPROPERTY <VALUE> <THING_ID> <PROPERTY_NAME> }
					2003 :
					Begin
						iThing := GetParam ( 2, 0 );
						iProperty := ConstantFindByDescription ( 'THINGPROPERTY', Params [ 3 ] );
						If iProperty < 1 Then
						Begin
							ScriptError ( 'Invalid Thing property "' + Params [ 3 ] + '".' );
						End
						Else
						Begin
							//
							bRefresh := True;
							//
							Case iProperty Of

								1 : { id }
								Begin
									Value := iThing;
								End;

								2 : { x }
								Begin
									Value := Things [ iThing ].x;
								End;

								3 : { y }
								Begin
									Value := Things [ iThing ].y;
								End;

							End;
							//
							SetVariable ( Params [ 1 ], Value );
						End;
					End;

					{ NEWSECTOR <FH> <CH> <FT> <CT> <LIGHT> <TYPE> <TAG> }
					3000 :
					Begin
						Inc ( nSectors );
						With Sectors [ nSectors ] Do
						Begin
							Floor := GetParam ( 1, 0 );
							Ceiling := GetParam ( 2, 128 );
							FloorTex := GetParam ( 3, '' );
							CeilingTex := GetParam ( 4, '' );
							Light := GetParam ( 5, 160 );
							iType := GetParam ( 6, 0 );
							Tag := GetParam ( 7, 0 );
						End;
						//
						bRefresh := True;
					End;

					{ SECTORDUPLICATE <SECTOR_ID> }
					3001 :
					Begin
						MapSectorDuplicate ( GetParam ( 1, 0 ) );
						//
						bRefresh := True;
					End;

					{ SECTORSETPROPERTY <SECTOR_ID> <PROPERTY_NAME> <VALUE> }
					3002 :
					Begin
						iSector := GetParam ( 1, 0 );
						iProperty := ConstantFindByDescription ( 'SECTORPROPERTY', Params [ 2 ] );
						If iProperty < 1 Then
						Begin
							ScriptError ( 'Invalid Sector property "' + Params [ 2 ] + '".' );
						End
						Else
						Begin
							//
							bRefresh := True;
							//
							Case iProperty Of

								1 : { id }
								Begin
									ScriptError ( 'Sector ID cannot be set.' );
								End;

								2 : { floor height }
								Begin
									Sectors [ iSector ].Floor := GetParam ( 3, 0 );
								End;

								3 : { ceiling height }
								Begin
									Sectors [ iSector ].Ceiling := GetParam ( 3, 0 );
								End;

								4 : { floor texture }
								Begin
									Value := GetParam ( 3, '' );
									Sectors [ iSector ].FloorTex := Value;
								End;

								5 : { ceiling texture }
								Begin
									Value := GetParam ( 3, '' );
									Sectors [ iSector ].CeilingTex := Value;
								End;

								6 : { light }
								Begin
									Value := GetParam ( 3, '' );
									Sectors [ iSector ].Light := Value;
								End;

								7 : { type }
								Begin
									Value := GetParam ( 3, '' );
									Sectors [ iSector ].iType := Value;
								End;

								8 : { tag }
								Begin
									Value := GetParam ( 3, '' );
									Sectors [ iSector ].Tag := Value;
								End;

							End;
						End;
					End;

					{ GETSECTORPROPERTY <var> <SECTOR_ID> <PROPERTY_NAME> }
					3003 :
					Begin
						iSector := GetParam ( 2, 0 );
						iProperty := ConstantFindByDescription ( 'SECTORPROPERTY', Params [ 3 ] );
						If iProperty < 1 Then
						Begin
							ScriptError ( 'Invalid Sector property "' + Params [ 3 ] + '".' );
						End
						Else
						Begin
							//
							Case iProperty Of

								1 : { id }
								Begin
									Value := iSector;
								End;

								2 : { floor height }
								Begin
									Value := Sectors [ iSector ].Floor;
								End;

								3 : { ceiling height }
								Begin
									Value := Sectors [ iSector ].Ceiling;
								End;

								4 : { floor texture }
								Begin
									Value := Sectors [ iSector ].FloorTex;
								End;

								5 : { ceiling texture }
								Begin
									Value := Sectors [ iSector ].CeilingTex;
								End;

								6 : { light }
								Begin
									Value := Sectors [ iSector ].Light;
								End;

							End;
							//
							SetVariable ( Params [ 1 ], Value );
						End;
					End;

					{ SETVERTEXPROPERTY <VERTEX_ID> <PROPERTY_NAME> <VALUE> <...VALUE 2> }
					4002 :
					Begin
						iVertex := GetParam ( 1, 0 );
						iProperty := ConstantFindByDescription ( 'VERTEXPROPERTY', Params [ 2 ] );
						If iProperty < 1 Then
						Begin
							ScriptError ( 'Invalid Vertex property "' + Params [ 2 ] + '".' );
						End
						Else
						Begin
							//
							bRefresh := True;
							//
							Case iProperty Of

								1 : { id }
								Begin
									ScriptError ( 'Vertex ID cannot be set.' );
								End;

								2 : { x }
								Begin
									Vertex [ iVertex ].x := GetParam ( 3, 0 );
								End;

								3 : { y }
								Begin
									Vertex [ iVertex ].y := GetParam ( 3, 0 );
								End;

								4 : { x, y }
								Begin
									Vertex [ iVertex ].x := GetParam ( 3, 0 );
									Vertex [ iVertex ].y := GetParam ( 4, 0 );
								End;

							End;
						End;
					End;

					{ GETVERTEXPROPERTY <VALUE> <VERTEX_ID> <PROPERTY_NAME> }
					4003 :
					Begin
						iVertex := GetParam ( 2, 0 );
						iProperty := ConstantFindByDescription ( 'VERTEXPROPERTY', Params [ 3 ] );
						If iProperty < 1 Then
						Begin
							ScriptError ( 'Invalid Vertex property "' + Params [ 3 ] + '".' );
						End
						Else
						Begin
							//
							bRefresh := True;
							//
							Case iProperty Of

								1 : { id }
								Begin
									Value := iVertex;
								End;

								2 : { x }
								Begin
									Value := Vertex [ iVertex ].x;
								End;

								3 : { y }
								Begin
									Value := Vertex [ iVertex ].y;
								End;

							End;
							//
							SetVariable ( Params [ 1 ], Value );
						End;
					End;

					{ POINTINWHICHSECTOR <var> <X> <Y> }
					5000 :
					Begin
						iSector := MapPointInWhichSector ( GetParam ( 2, 0 ), GetParam ( 3, 0 ) );
						SetVariable ( Params [ 1 ], iSector );
					End;

					{ ROTATEPOINT <varx> <vary> <X0> <Y0> <DIST> <ANGLE> }
					5001 :
					Begin
						Dist := GetParam ( 5, 64 );
						//
						Angle := 90 - ( GetParam ( 6, 0 ) Mod 360 );
						//
						x := GetParam ( 3, 0 );
						xr := Dist * Sin ( Angle / 180 * pi );
						x := x + Round ( xr );
						//
						y := GetParam ( 4, 0 );
						yr := Dist * Cos ( Angle / 180 * pi );
						y := y + Round ( yr );
						//
						SetVariable ( Params [ 1 ], x );
						SetVariable ( Params [ 2 ], y );
					End;

					{ DeselectAll }
					5002 :
					Begin
						//
						MapDeselectAll;
						MapDeHighlightAll;
						//
					End;

					{ GETUSERINPUT <var> <PROMPT> <DEFAULT> }
					6000 :
					Begin
						SetVariable ( Params [ 1 ], InputBox ( 'Enter Value',
							GetParam ( 2, 'Enter Value' ), GetParam ( 3, '' ) ) );
					End;

					{ INPUTNUMBER <var> <PROMPT> <DEFAULT> }
					6001 :
					Begin
						SetVariable ( Params [ 1 ], SafeVal ( InputBox ( 'Enter Value',
							GetParam ( 2, 'Enter Value' ), GetParam ( 3, '' ) ) ) );
					End;

					{ MSGBOX <var> }
					6002 :
					Begin
						ShowMessage ( Eval ( Params [ 1 ] ) );
					End;

					{ TRIM <Var> }
					7000 :
					Begin
						SetVariable ( Params [ 1 ], Trim ( GetVariable ( Params [ 1 ] ) ) );
					End;

					{ UPPERCASE <Var> }
					7001 :
					Begin
						SetVariable ( Params [ 1 ], UpperCase ( GetVariable ( Params [ 1 ] ) ) );
					End;

					{ LOWERCASE <Var> }
					7002 :
					Begin
						SetVariable ( Params [ 1 ], LowerCase ( GetVariable ( Params [ 1 ] ) ) );
					End;

					{ RANDOM <Var> <RANGE> }
					7010 :
					Begin
						SetVariable ( Params [ 1 ], Random ( Integer ( Eval ( Params [ 2 ] ) ) ) );
					End;

				End;
			End;
			//
			// --- allow update from script
			MapClickX := GetVariable ( 'MAPX' );
			MapClickY := GetVariable ( 'MAPY' );
		End;
		//
		CloseFile ( sf );
		//
		If bRefresh Then
		Begin
			Modified ( True );
			MapRefresh;
		End;
	End;
	//
	EditMapZoom.SetFocus;
End;

//***********

Procedure TFormMain.MapDisplayDemo ( sEntry : String );
Var
	iEntry : Integer;
	iThing : Integer;
	//
	x, y, Angle : Integer;
	n : Integer; // data length
	sp, sx, sy, an : ShortInt;
	//
	x0, y0, x1, y1 : Integer;
Begin
	iEntry := FindEntry ( sEntry );
	If iEntry > 0 Then
	Begin
		//
		If Not fOpen ( sEditFile ) Then Exit;
		fSeek ( f, WadEntries [ iEntry ].Position );
		//
		GetLong ( f );
		GetLong ( f );
		GetLong ( f );
		GetByte ( f );
		//
		iThing := 0;
		While Things [ iThing ].iType <> 1 Do
		Begin
			Inc ( iThing );
		End;
		x := Things [ iThing ].x;
		y := Things [ iThing ].y;
		Angle := Round ( Things [ iThing ].Angle / ( 360 / 256 ) );
		//
		ImageMap.Canvas.Pen.Color := clGreen;
		ImageMap.Canvas.Brush.Color := clGreen;
		//
		n := WadEntries [ iEntry ].Size - 14;
		While n > 0 Do
		begin
			x0 := x;
			y0 := y;
			CoordsMapToScreen ( x0, y0 );
			//
			sx := GetByte ( f );
			sy := GetByte ( f );
			an := GetByte ( f );
			sp := GetByte ( f );
			//
			ImageMap.Canvas.TextOut ( 100, 20, IntToStr ( sp ) );
			//
			Angle := Angle + an;
			//
			x := x + Round ( sx / 3 * Cos ( ( Angle * ( 360 / 256 ) ) / 180 * pi ) );
			y := y + Round ( sx / 3 * Sin ( ( Angle * ( 360 / 256 ) ) / 180 * pi ) );
			x := x + Round ( sy / 3 * Sin ( ( Angle * ( 360 / 256 ) ) / 180 * pi ) );
			y := y - Round ( sy / 3 * Cos ( ( Angle * ( 360 / 256 ) ) / 180 * pi ) );
			x1 := x;
			y1 := y;
			CoordsMapToScreen ( x1, y1 );
			//
			ImageMap.Canvas.MoveTo ( x0, y0 );
			ImageMap.Canvas.LineTo ( x1, y1 );
			ImageMap.Canvas.FrameRect ( Classes.Rect ( x1 - 1, y1 - 1, x1 + 2, y1 + 2 ) );
			//
			Dec ( n, 4 );
		End;
		//
		ImageMap.Canvas.TextOut ( 100, 10, IntToStr ( Angle ) );
		//
		fClose;
	End;
End;

//***************************************************************************

Function TFormMain.ScriptEditorCreateCodeMax : Boolean;
Begin
	Try
		Application.ProcessMessages;
		//
		ScriptCMax := TCodeMax.Create ( PanelScript );
		PanelScript.InsertControl ( ScriptCMax );
		//
		ScriptEditorCreateCodeMax := True;
	Except
		on E : Exception do
		begin
			ShowMessage('Exception class name = '+E.ClassName);
			ShowMessage('Exception message = '+E.Message);
			bHasCodeMax := False;
			ScriptEditorCreateCodeMax := False;
		end;
	End;
End;

Procedure TFormMain.ScriptEditor ( sEditorType : String; bFocus : Boolean );
Var
	s, s1 : String;
	i, c : Integer;
	pb, b : Byte;
	Globals : IGlobals;
	bSuccess : Boolean;

Procedure RegisterLanguage;

Var
	j : Integer;
	f0 : TFont;
	Lang : ILanguage;

Function LanguageProperty ( sp : String ) : Boolean;
Var
	sProp : String;
Begin
	SplitAtMark ( sp, sProp, ':' );
	sProp := Trim ( sProp );
	If sProp = '' Then
	Begin
		LanguageProperty := False;
	End
	Else
	Begin
		sp := Trim ( UpperCase ( sp ) );
		//
		sProp := Replace ( sProp, ',,', ',' );
		sProp := Replace ( sProp, ',', #10 );
		//
		If sp = 'SINGLELINECOMMENTS' Then
		Begin
			Lang.SingleLineComments := sProp;
		End
		Else If sp = 'OPERATORS' Then
		Begin
			Lang.Operators := sProp;
		End;
		//
		LanguageProperty := True;
	End;
End;

Begin
	//
	// #####
	//
	Lang := CoLanguage.Create;
	//
	s := '';
	c := ConstantFind ( sEditorType );
	//
	// --- Language Definition Found?
	//
	If c > -1 Then
	Begin
		//
		// --- Yes, process it
		//
		For j := 0 To Constants [ c ].ValueCount - 1 Do
		Begin
			//
			// --- Get one line
			//
			s1 := ConstantValues [ Constants [ c ].ValueStart + j ].Description;
			//
			// --- Lang Prop? (if has ":", then yes)
			//
			If Not LanguageProperty ( s1 ) Then
			Begin
				//
				// Otherwise it's a keyword
				//
				s := s + ScriptEditorGetKeyWord ( s1 ) + ',';
			End;
		End;
		//
		Lang.Keywords := Replace ( s, ',', Chr ( 10 ) );
		//
		Lang.CaseSensitive := False;
		Lang.Style := cmLangStyleProcedural;
		Lang.MultiLineComments1 := '/*';
		Lang.MultiLineComments2 := '*/';
		Lang.ScopeKeywords1 := '{';
		Lang.ScopeKeywords2 := '}';
		Lang.StringDelims := Chr(34) + #10 + '''';
		Lang.EscapeChar := '';
		Lang.TerminatorChar := '';
		//
		Globals := CoGlobals.Create;
		Globals.RegisterLanguage ( sEditorType, Lang );
	End
	Else
	Begin
		Status ( sEditorType + ' is not defined' );
	End;
	//
	// #########
	//
	f0 := TFont.Create;
	Try
		If ( Pos ( ';', CMaxFontString ) = 0 ) Then
		Begin
			CMaxFontString := 'FIXEDSYS;-12';
		End;
		f0.Name := Copy ( CMaxFontString, 0, Pos ( ';', CMaxFontString ) - 1 );
		f0.Height := SafeVal ( RemoveFromLeft ( CMaxFontString, Pos ( ';', CMaxFontString ) ) );
		//
		With ScriptCMax Do
		Begin
			OnChange := ScriptCMaxChange;
			OnKeyDown := ScriptCMaxKeyDown;
			OnKeyPress := ScriptCMaxKeyPress;
			OnSelChange := ScriptCMaxSelChange;
			//OnMouseDown := ScriptCMaxMouseDown;
			//
			If c > -1 Then
			Begin
				Language := sEditorType;
			End;
			//
			Font := f0;
			SetFontStyle ( 2, 0 );
			//
			Align := alClient;
			//BorderStyle := 2;
			ColorSyntax := bCodeMaxSyntaxHighlighting;
			DisplayLeftMargin := False;
			//
		End;
	Finally
		f0.Free;
	End;
End;

Begin
	//
	// ---
	//
	If Not fOpen ( sEditFile ) Then Exit;
	//
	Try
		Starting;
		//
		bSuccess := True;
		//
		Try
			//
			Seek ( f, cPos );
			//
			ScriptLanguage := sEditorType; // save for later
			//
			// --- Load dynamic controls ---
			//
			Try
				If Not bScriptInit Then
				Begin
					ShowPage ( edScript );
					//
					If bHasCodeMax Then
					Begin
						If Not ScriptEditorCreateCodeMax Then
						Begin
							bHasCodeMax := False;
						End;
						//
					End;
					//
					If Not bHasCodeMax Then
					Begin
						//
						// ### Init Memo
						//
						ScriptMemo := TMemo.Create ( PanelScript );
						PanelScript.InsertControl ( ScriptMemo );
						//
						With ScriptMemo Do
						Begin
							Align := alClient;
							//
							OnKeyUp := ScriptMemoKeyUp;
							OnKeyDown := ScriptMemoKeyDown;
							OnChange := ScriptMemoChange;
							OnEnter := ScriptMemoOnEnter;
							OnMouseDown := ScriptMemoMouseDown;
							//
							Font.Name := 'FIXEDSYS';
							Font.Size := 9;
							//
							ScrollBars := ssBoth;
							WantTabs := True;
						end;
					End;
					//
					bScriptInit := True;
				End;
			Finally
				//
				If Not bSuccess Then
				Begin
					bHasCodeMax := False;
					bScriptInit := False;
				End;
				//
				// --- Hide while loading
				//
				If bHasCodeMax Then
				Begin
					RegisterLanguage; // do it every time
					//
					ScriptCMax.Visible := False;
				End
				Else
				Begin
					ScriptMemo.Visible := False;
				End;
			End;
			//
			// --- Load the Script ---
			//
			ScriptEditorClear;
			//
			s := '';
			i := 0;
			pb := 0;
			//
			While i < cLen Do
			Begin
				b := GetByte ( f );
				//
				If ( ( b = 10 ) And ( pb <> 13 ) )
				Or ( b = 13 ) Then
				Begin
					ScriptEditorAddLine ( s );
					s := '';
				End
				Else
				Begin
					If ( b <> 10 ) And ( b <> 13 ) Then
						s := s + Chr ( b );
				End;
				//
				pb := b;
				//
				Inc ( i, 1 );
			End;
		Finally
			//
			fClose;
			//
		End;
		//
		If s <> '' Then
			ScriptEditorAddLine ( s );
		//
		Modified ( False );
		//
		// --- Show after loading
		//
		If bHasCodeMax Then
		Begin
			ScriptCMax.Visible := True;
		End
		Else
		Begin
			ScriptMemo.Visible := True;
		End;
		//
		ShowPage ( edScript );
		//
		If bFocus Then
		Begin
			If bHasCodeMax Then
				ScriptCMax.SetFocus
			Else
				ScriptMemo.SetFocus;
		End;
		//
	Finally
		Finished;
	End;
End;

Function TFormMain.ScriptEditorGetKeyWord ( s : String ) : String;
Begin
	If Pos ( '(', s ) > 0 Then
	Begin
		s := Copy ( s, 1, Pos ( '(', s ) - 1 );
	End;
	If Pos ( '/', s ) > 0 Then
	Begin
		s := Copy ( s, 1, Pos ( '/', s ) - 1 );
	End;
	ScriptEditorGetKeyWord := Trim ( s );
End;

// --------------------------------------------------------

Procedure TFormMain.ScriptEditorAddLine ( sLine : String );
Begin
	If bHasCodeMax Then
	Begin
		If ScriptCMax.Text = '' Then
		Begin
			ScriptCMax.Text := sLine;
		End
		Else
		Begin
			ScriptCMax.InsertLine ( ScriptCMax.LineCount, sLine );
		End;
	End
	Else
	Begin
		ScriptMemo.Lines.Add ( sLine );
	End;
End;

Function TFormMain.ScriptEditorGetLine ( iLine : Integer ) : String;
Begin
	If bHasCodeMax Then
	Begin
		ScriptEditorGetLine := ScriptCMax.GetLine ( iLine );
	End
	Else
	Begin
		ScriptEditorGetLine := ScriptMemo.Lines [ iLine ];
	End;
End;

Function TFormMain.ScriptEditorLineCount : Integer;
Begin
	If bHasCodeMax Then
	Begin
		ScriptEditorLineCount := ScriptCMax.LineCount;
	End
	Else
	Begin
		ScriptEditorLineCount := ScriptMemo.Lines.Count;
	End;
End;

Procedure TFormMain.ScriptEditorClear;
Begin
	If bHasCodeMax Then
	Begin
		ScriptCMax.Text := '';
	End
	Else
	Begin
		ScriptMemo.Lines.Clear;
	End;
End;

// --- Save

Function TFormMain.ScriptSave : Boolean;
Var
	i, Lines : Integer;
	s : String;
Begin
	fOpenTemp;
	//
	Lines := ScriptEditorLineCount;
	For i := 0 To Lines - 1 Do
	Begin
		s := ScriptEditorGetLine ( i );
		If Length ( s ) > 0 Then
		Begin
			BlockWrite ( fo, s [ 1 ], Length ( s ) );
		End;
		SendByte ( fo, 13 );
		SendByte ( fo, 10 );
	End;
	//
	CloseFile ( fo );
	//
	ReplaceFile ( iSel, sTempFile, True, True );
	//
	Modified ( False );
	UpdateModifiedDate;
	//
	ScriptSave := True;
End;

// --- Compile

procedure TFormMain.mnuScriptCompileClick(Sender: TObject);
Var
	sPath, sExec, sParam : String;
	sFile : String;
	sDest : String;
	sError : String;
	Dummy : TextFile;
	//
	s1, s2, s3 : String;
	iLine, iPos, iChars : Integer;
	Range : IRange;
Begin
	If ScriptSave Then
	Begin
		//
		ToolsGet ( 'Action Script Compiler', 'ACC.EXE', sPath, sExec, sParam );
		//
		If Not FileExists ( sPath + sExec ) Then
		Begin
			ShowMessage ( 'File not found:' + #13 + sPath + sExec );
		End
		Else
		Begin
			//
			sFile := RemoveFolder ( sTempFile );
			sDest := '(xwe)(' + sUniqueID + ')(Compile)result.lmp';
			sError := 'acs.err';
			//
			CopyFile ( PChar ( sTempFile ), PChar ( sPath + sFile ), False );
			//
			// --- erase dest file
			//
			If FileExists ( sPath + sDest ) Then
			Begin
				AssignFile ( Dummy, sPath + sDest );
				Erase ( Dummy );
			End;
			//
			// --- erase error output file
			//
			If FileExists ( sPath + sError ) Then
			Begin
				AssignFile ( Dummy, sPath + sError );
				Erase ( Dummy );
			End;
			//
			{
			ExecAndWait ( sPath + sExec, sFile + ' ' + sDest, SW_NORMAL );
			}
			ExecuteFile ( sPath + sExec, sFile + ' ' + sDest, sPath, SW_NORMAL );
			//
			While Not FileExists ( sPath + sDest ) And Not FileExists ( sPath + sError ) Do
			Begin
				//Application.ProcessMessages;
			End;
			//
			If FileExists ( sPath + sDest ) Then
			Begin
				// compiled successfully
				Delay ( 200 );
				ReplaceFile ( iSel - 1, sPath + sDest, True, True );
				Status ( 'Compiled successfully.' );
			End
			Else
			Begin
				If Not FileExists ( sPath + sError ) Then
				Begin
					Status ( 'Compile error.' );
				End
				Else
				Begin
					Delay ( 200 );
					//
					AssignFile ( Dummy, sPath + sError );
					Reset ( Dummy );
					//
					ReadLn ( Dummy, s1 ); // "Line nn"
					ReadLn ( Dummy, s2 ); // Error message
					ReadLn ( Dummy, s3 ); // Line containing the error
					ReadLn ( Dummy, s3 ); // Error position
					CloseFile ( Dummy );
					//
					Status ( 'Error: ' + s2 );
					//
					s1 := RemoveFromLeft ( s1, Pos ( ' ', s1 ) );
					s1 := Copy ( s1, 1, Pos ( ' ', s1 ) - 1 );
					//
					iLine := SafeVal ( s1 );
					iPos := Pos ( '^', s3 );
					//
					If iLine > 0 Then
					Begin
						if bHasCodeMax Then
						Begin
							Range := CoRange.Create;
							Range.StartLineNo := iLine - 1;
							Range.StartColNo := iPos;
							Range.EndLineNo := iLine - 1;
							Range.EndColNo := iPos;
							ScriptCMax.SetSel ( Range, True );
						End
						Else
						Begin
							// Set the cursor within the memo
							iChars := 0;
							Dec ( iLine, 2 );
							While iLine >= 0 Do
							Begin
								Inc ( iChars, Length ( ScriptMemo.Lines [ iLine ] ) + 2 );
								Dec ( iLine );
							End;
							ScriptMemo.SelStart := iChars + iPos - 2;
						End;
					End;
				End;
			End;
			//
			DeleteTempFiles ( sPath, '(' + sUniqueID + ')(Compile)*' );
		End;
		//
	End;
End;

procedure TFormMain.mnuScriptSaveClick(Sender: TObject);
Begin
	ScriptSave;
end;

// ---

procedure TFormMain.mnuScriptGotoLineClick(Sender: TObject);
var
	iLine : Integer;
	s : String;
begin
	If bHasCodeMax Then
	Begin
	End
	Else
	Begin
		iLine := ScriptMemoUpdateCursorPos;
		//
		s := InputBox ( 'Go to line...', 'Enter line number (1-' + Comma ( ScriptMemo.Lines.Count ) + '; current: ' + Comma ( iLine ) + ')', '' );
		//
		If s <> '' Then
		Begin
			iLine := SafeVal ( s ) - 1;
			ScriptMemo.SelStart := ScriptMemo.Perform ( EM_LINEINDEX, iLine, 0 );
			ScriptMemo.Perform ( EM_SCROLLCARET, 0, 0 );
		End;
	End;
end;

// ---

Procedure TFormMain.ScriptFindKeyWord ( iStartPos : Integer );
Var
	s, sComp : String;
	ci, vs, KeyWord : Integer;

Function IsLetter ( c : Char ) : Boolean;
Begin
	IsLetter := ( c = '_' ) Or ( ( c >= 'a' ) And ( c <= 'z' ) )
		Or ( ( c >= 'A' ) And ( c <= 'Z' ) ) Or ( ( c >= '0' ) And ( c <= '9' ) );
end;

Begin
	s := ScriptKeyWordLine;
	If s <> '' Then
	Begin
		//
		// Find beginning
		//
		ScriptKeyWordPos := iStartPos;
		While ( ScriptKeyWordPos > 0 ) And IsLetter ( s [ ScriptKeyWordPos ] ) Do
		Begin
			Dec ( ScriptKeyWordPos );
		End;
		Inc ( ScriptKeyWordPos );
		//
		// Find Length
		//
		ScriptKeyWordLen := 1;
		While ( ScriptKeyWordPos + ScriptKeyWordLen - 1 <= Length ( s ) ) And IsLetter ( s [ ScriptKeyWordPos + ScriptKeyWordLen - 1 ] ) Do
		Begin
			Inc ( ScriptKeyWordLen );
		End;
		Dec ( ScriptKeyWordLen );
		//
		If ScriptKeyWordLen > 0 Then
		Begin
			s := Copy ( s, ScriptKeyWordPos, ScriptKeyWordLen );
			//
			// --- Find matching keywords
			//
			ScriptWordList.Items.Clear;
			//
			// --- ...in the current language
			//
			ci := ConstantFind ( ScriptLanguage );
			//
			KeyWord := 0;
			vs := Constants [ ci ].ValueStart;
			While KeyWord < Constants [ ci ].ValueCount Do
			Begin
				sComp := ConstantValues [ vs + KeyWord ].Description;
				If BeginsWith ( UpperCase ( sComp ), UpperCase ( s ) ) Then
				Begin
					ScriptWordList.Items.Add ( sComp );
				End;
				Inc ( KeyWord );
			End;
		End;
	End;
End;

Procedure TFormMain.ScriptShowWordList ( x, y : Integer );
Var
	i : Integer;
Begin
	With ScriptWordList Do
	Begin
		Top := y;
		Left := x;
		//
		Height := Items.Count * Canvas.TextHeight ( 'Yy' ) + 8;
		If ( Top + Height ) > PanelScript.Height Then
		Begin
			Height := PanelScript.Height - Top;
		End;
		//
		Width := PanelScript.Width - 24 - Left;
		If ( Width < 300 ) Then
		Begin
			i := PanelScript.Width - 300;
			Width := 300;
			If i < 0 Then
			Begin
				i := 0;
				Width := PanelScript.Width;
			End;
			Left := i;
		End;
		//
		// pre select the first one
		//
		ItemIndex := 0;
		//
		Visible := True;
		BringToFront;
		SetFocus;
	End;
End;

Procedure TFormMain.ScriptPickFromList ( i : Integer );
Var
	s : String;
	r : IRange;
Begin
	s := ScriptEditorGetKeyWord ( ScriptWordList.Items [ i ] );
	//
	ScriptKeyWordLine := Copy ( ScriptKeyWordLine, 1, ScriptKeyWordPos - 1 ) + s +
		RemoveFromLeft ( ScriptKeyWordLine, ScriptKeyWordPos + ScriptKeyWordLen );
	//
	If bHasCodeMax Then
	Begin
		ScriptCMax.DeleteLine ( ScriptCurY );
		ScriptCMax.InsertLine ( ScriptCurY, ScriptKeyWordLine );
		//
		r := CoRange.Create;
		r.StartLineNo := ScriptCurY;
		r.EndLineNo := ScriptCurY;
		r.StartColNo := ScriptKeyWordPos + Length ( s ) - 1;
		r.EndColNo := r.StartColNo;
		//
		ScriptCMax.SetSel ( r, True );
	End
	Else
	Begin
		ScriptMemo.Lines [ ScriptCurY ] := ScriptKeyWordLine;
	End;
End;

Procedure TFormMain.ScriptMemoChange ( Sender : TObject );
Begin
	Modified ( True );
End;

Procedure TFormMain.ScriptMemoOnEnter ( Sender : TObject );
Begin
	ScriptMemoUpdateCursorPos;
End;

Procedure TFormMain.ScriptMemoMouseDown ( Sender: TObject; Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
Begin
	If ScriptWordList.Visible Then
		ScriptWordList.Visible := False;
End;

Function TFormMain.ScriptMemoUpdateCursorPos : Integer;
Var
	x, y : Integer;
	//Len : Integer;
Begin
	(*
	x := 0;
	y := 0;
	Len := 0;
	While Len <= ScriptMemo.SelStart Do
	Begin
		x := ScriptMemo.SelStart - Len + 1;
		Inc ( Len, Length ( ScriptMemo.Lines [ y ] ) + 2 );
		Inc ( y );
	End;
	*)
	x := ScriptMemo.CaretPos.x + 1;
	y := ScriptMemo.Perform ( EM_LINEFROMCHAR, -1, 0 ) + 1;
	//
	Status ( IntToStr ( y ) + ':' + IntToStr ( x ) );
	//
	ScriptMemoUpdateCursorPos := y;
End;

Procedure TFormMain.ScriptMemoKeyUp ( Sender: TObject; Var Key: Word; Shift: TShiftState );
Begin
	ScriptMemoUpdateCursorPos;
End;

Procedure TFormMain.ScriptMemoKeyDown ( Sender: TObject; Var Key: Word; Shift: TShiftState );
Var
	s : String;
	i, y : Integer;
	Stop : Boolean;
Begin
	ScriptMemoUpdateCursorPos;
	//
	Case Key Of

		13 :
		Begin
			If ( ScriptMemo.CaretPos.x >= 0 ) Then
			Begin
				// what was this supposed to do???
				Application.ProcessMessages;
				s := ScriptMemo.Lines [ ScriptMemo.CaretPos.y - 1 ];
				i := 0;
				Stop := False;
				While Not Stop Do
				Begin
					If ( Length ( s ) >= i + 1 ) Then
					Begin
						If s [ i + 1 ] = ' ' Then
							Inc ( i )
						Else
							Stop := True
					End
					Else
						Stop := True;
				End;
				ScriptMemo.Lines [ ScriptMemo.CaretPos.y ] := Copy ( s, 1, i ) +
					ScriptMemo.Lines [ ScriptMemo.CaretPos.y ];
			End;
		End;

		32 :
		Begin
			If ssCtrl in Shift Then
			Begin
				ScriptCurX := ScriptMemo.CaretPos.x;
				ScriptCurY := ScriptMemo.CaretPos.y;
				//
				ScriptKeyWordLine := ScriptMemo.Lines.Strings [ ScriptCurY ];
				//
				ScriptFindKeyWord ( ScriptCurX );
				//
				If ScriptWordList.Items.Count > 0 Then
				Begin
					If ScriptWordList.Items.Count = 1 Then
					Begin
						//
						ScriptPickFromList ( 0 );
						//
					End
					Else
					Begin
						// --- Show list
						Canvas.Font := ScriptMemo.Font;
						//y := ( ScriptMemo.CaretPos.y + 1 );
						y := ScriptMemo.Perform ( EM_LINEFROMCHAR, -1, 0 ) - ScriptMemo.Perform ( EM_GETFIRSTVISIBLELINE, 0, 0 ) + 1;
						y := ScriptMemo.Top + Canvas.TextHeight ( 'Yy' ) * y;
						(*
						If y < 15 Then
						Begin
							y := ScriptMemo.Top + Canvas.TextHeight ( 'Yy' ) * y;
						End
						Else
						Begin
							y := ScriptMemo.Top + 100;
						End;
						*)
						ScriptShowWordList ( ScriptMemo.Left + Canvas.TextWidth ( 'X' ) * ScriptMemo.CaretPos.x + 2, y + 2 );
					End;
				End;
			End;
		End;

		71 : // CTRL + G
		Begin
			If ssCtrl in Shift Then
			Begin
				mnuScriptGotoLineClick ( Sender );
			End;
		End;

	End;
End;

procedure TFormMain.ScriptCMaxKeyDown ( Sender: TObject; const Control: ICodeMax;
	KeyCode, Shift: Integer; Var pbStop : WordBool  );
Var
	kc : Word;
	ss : TShiftState;
Begin
	kc := KeyCode;
	ss := []; // !!!
	FormKeyDown ( Sender, kc, ss );
	//ShowMessage ( IntToStr ( SendMessage ( ScriptCMax.Handle, CMM_ISCOLORSYNTAXENABLED, 0, 0) ) );
End;

procedure TFormMain.ScriptCMaxKeyPress ( Sender: TObject; const Control: ICodeMax;
	KeyAscii, Shift: Integer; Var pbStop : WordBool );
Var
	Processed : Boolean;
	r : IRange;
	p : IPosition;
	re : IRect;
Begin
	Processed := False;
	Case KeyAscii Of

		32 : // space
		Begin
			If Shift = 2 Then // ctrl space
			Begin
				r := ScriptCMax.GetSel ( False );
				//
				ScriptCurX := r.StartColNo;
				ScriptCurY := r.StartLineNo;
				//
				ScriptKeyWordLine := ScriptCMax.GetLine ( ScriptCurY );
				//
				ScriptFindKeyWord ( ScriptCurX );
				//
				// --- Any matches found?
				//
				If ScriptWordList.Items.Count > 0 Then
				Begin
					//
					// --- Only one match?
					//
					If ScriptWordList.Items.Count = 1 Then
					Begin
						//
						// --- put it back
						//
						ScriptPickFromList ( 0 );
						//
					end
					Else
					Begin
						//
						// --- Get cursor position in pixels
						//
						p := CoPosition.Create;
						p.LineNo := r.StartLineNo;
						p.ColNo := r.StartColNo;
						re := ScriptCMax.PosFromChar ( p );
						//
						ScriptShowWordList ( re.Left, ScriptCMax.Top + re.Bottom );
					End;
				End;
				//
				Processed := True;
			End;
		End;

		Else
		Begin
			// Caption := Comma ( KeyAscii ) + ' ' + Comma ( Shift );
		End;

	End;
	pbStop := Processed;
End;

Procedure TFormMain.ScriptCMaxSelChange  ( Sender: TObject; const Control: ICodeMax );
Var
	r : IRange;
Begin
	r := ScriptCMax.GetSel ( True );
	Status ( Comma ( r.StartLineNo ) + ':' + Comma ( r.StartColNo ) );
End;

Procedure TFormMain.ScriptCMaxChange ( Sender: TObject; const Control: ICodeMax );
Begin
	//Caption := Caption + ' c';
	Modified ( True );
end;

procedure TFormMain.ScriptWordListDblClick(Sender: TObject);
Var
	c : Char;
begin
	c := #13;
	ScriptWordListKeyPress ( Sender, c );
end;

procedure TFormMain.ScriptWordListKeyPress(Sender: TObject; Var Key: Char);
Begin
	If Key = #13 Then
	Begin
		ScriptPickFromList ( ScriptWordList.ItemIndex );
	End;
	//
	Key := #0;
	//
	ScriptWordList.Visible := False;
	//
	If bHasCodeMax Then
	Begin
		ScriptCMax.SetFocus;
	End
	Else
	Begin
		ScriptMemo.SetFocus;
	End;
end;

procedure TFormMain.ScriptWordListExit(Sender: TObject);
begin
	If ScriptWordList.Visible Then
		ScriptWordList.Visible := False;
end;

//***************************************************************************

Function TFormMain.GridSave : Boolean;
Var
	x, y : Integer;
	s : String;
Begin
	Starting;
	//
	fOpenTemp;
	//
	For y := 1 To gridMain.RowCount - 1 Do
	Begin
		For x := 0 To gridMain.ColCount - 1 Do
		Begin
			s := gridMain.Cells [ x, y ];
			Case WadEntryCols [ WadEntryTypes [ GridType ].ColStart + x ].iLen Of

				2 :
				Begin
					SendWord ( fo, SafeVal ( s ) );
				End;

				4 :
				Begin
					SendLong ( fo, SafeVal ( s ) );
				End;

				8 :
				Begin
					SendString8 ( fo, s );
				End;

			End;
		End;
	End;
	//
	CloseFile ( fo );
	//
	ReplaceFile ( iSel, sTempFile, True, True );
	//
	Modified ( False );
	UpdateModifiedDate;
	Finished;
	//
	GridSave := True;
end;

procedure TFormMain.mnuGridSaveClick(Sender: TObject);
Begin
	GridSave;
End;

procedure TFormMain.mnuGridAddLineClick(Sender: TObject);
Var
	x, y : Integer;
Begin
	gridMain.RowCount := gridMain.RowCount + 1;
	//
	For y := gridMain.RowCount - 1 DownTo gridMain.Row + 1 Do
	Begin
		For x := 0 To gridMain.ColCount - 1 Do
		Begin
			gridMain.Cells [ x, y ] := gridMain.Cells [ x, y - 1 ];
		End;
	End;
	//
	gridMain.Row := gridMain.Row + 1;
	For x := 0 To gridMain.ColCount - 1 Do
	Begin
		gridMain.Cells [ x, gridMain.Row ] := '';
	End;
	//
	Modified ( True );
end;

procedure TFormMain.mnuGridDeleteLineClick(Sender: TObject);
Var
	x, y, ys, ym : Integer;
Begin
	ys := gridMain.Row;
	ym := gridMain.RowCount;
	//
	If ( gridMain.RowCount > 2 ) And ( gridMain.Row >= gridMain.RowCount - 1 ) Then
	Begin
		gridMain.Refresh;
		Application.ProcessMessages;
		gridMain.Row := gridMain.RowCount - 2;
		gridMain.Col := 0;
		gridMain.Refresh;
		Application.ProcessMessages;
	End;
	//
	For y := ys + 1 To ym Do
	Begin
		For x := 0 To gridMain.ColCount - 1 Do
		Begin
			gridMain.Cells [ x, y - 1 ] := gridMain.Cells [ x, y ];
		End;
	End;
	//
	If gridMain.RowCount > 2 Then
	Begin
		// remove last row
		gridMain.RowCount := gridMain.RowCount - 1;
	End
	Else
	Begin
		// clear first row instead
		For x := 0 To gridMain.ColCount - 1 Do
		Begin
			gridMain.Cells [ x, 1 ] := '';
		End;
	End;
	//
	Modified ( True );
end;

procedure TFormMain.mnuGridGotoLineClick(Sender: TObject);
Var
	iRow : Integer;
Begin
	iRow := SafeVal ( InputBox ( 'Go to Line...', 'Enter line number (zero based)', IntToStr ( gridMain.Row - 1 ) ) ) + 1;
	If ( iRow >= 1 ) And ( iRow < gridMain.RowCount ) Then
	Begin
		gridMain.Row := iRow;
		gridMain.SetFocus;
	End;
end;

Procedure TFormMain.GridEditor ( i : Integer; bFocus : Boolean );
Var
	x, y : Integer;

	p, i4 : Integer;
	s8 : String;
	si : SmallInt;
	b : Byte;

Begin
	If WadEntryTypes [ i ].Cols = 0 Then
	Begin
		ShowMessage ( 'Entry cannot be displayed' );
	End
	Else
	Begin
		//
		ShowPage ( edNone );
		//
		GridType := i;
		//
		With GridMain Do
		Begin
			RowCount := 2;
			ColCount := WadEntryTypes [ i ].Cols;
			FixedCols := 0;
			FixedRows := 1;
			//
			DefaultRowHeight := 18;
		End;
		//
		For x := 0 To WadEntryTypes [ i ].Cols - 1 Do
		Begin
			GridMain.Cells [ x, 0 ] := WadEntryCols [ WadEntryTypes [ i ].ColStart + x ].Desc;
			GridMain.Cells [ x, 1 ] := ''; //clear first row

			Case WadEntryCols [ WadEntryTypes [ i ].ColStart + x ].iLen Of

				1, 2, 4 :
				Begin
					GridMain.ColWidths [ x ] := 42;
				end;

				8 :
				Begin
					GridMain.ColWidths [ x ] := 60;
				end;

			end;
		End;
		//
		If Not fOpen ( sEditFile ) Then Exit;
		//
		Starting;
		fSeek ( f, cPos );
		//
		If WadEntryTypes [ i ].Header = 0 Then
		Begin
			GridEditHeader.Visible := False;
			GridMain.Top := 8;
		End
		Else
		Begin
			GridEditHeader.Visible := True;
			GridMain.Top := 32;
			//
			GridEditHeader.Text := '';
			For p := 1 To WadEntryTypes [ i ].Header Do
			Begin
				b := Byte ( GetByte ( f ) );
				GridEditHeader.Text := GridEditHeader.Text + '$' + IntToHex ( b, 2 );
				if p < WadEntryTypes [ i ].Header Then
				Begin
					GridEditHeader.Text := GridEditHeader.Text + ' ';
				End;
			End;
		End;
		//
		// ---
		//
		GridRecSize := 0;
		For x := 0 To WadEntryTypes [ i ].Cols - 1 Do
		Begin
			Inc ( GridRecSize, WadEntryCols [ WadEntryTypes [ i ].ColStart + x ].iLen );
		End;
		//
		p := 0;
		y := 1;
		//
		While p < cLen Do
		Begin
			If y >= GridMain.RowCount Then
			Begin
				GridMain.RowCount := GridMain.RowCount + 1;
			End;

			For x := 0 To WadEntryTypes [ i ].Cols - 1 Do
			Begin

				Case WadEntryCols [ WadEntryTypes [ i ].ColStart + x ].iLen Of

					1 :
					Begin
						b := Byte ( GetByte ( f ) );
						GridMain.Cells [ x, y ] := IntToStr ( b );
						//
						Inc ( p, 1 );
					end;

					2 :
					Begin
						si := GetWord ( f );
						GridMain.Cells [ x, y ] := IntToStr ( si );
						//
						Inc ( p, 2 );
					end;

					4 :
					Begin
						i4 := GetLong ( f );
						GridMain.Cells [ x, y ] := IntToStr ( i4 );
						//
						Inc ( p, 4 );
					end;

					8 :
					Begin
						s8 := GetString ( f, 8 );
						GridMain.Cells [ x, y ] := s8;
						//
						Inc ( p, 8 );
					End;

				End;

			End;

			Inc ( y );

		End;
		//
		GridEditorTotal.Caption := Comma ( GridMain.RowCount - 1 ) + ' entries';
		//
		fClose;
		//
		ShowPage ( edGrid );
		//
		Finished;
		Modified ( False );
		//
		If bFocus Then
		Begin
			GridMain.SetFocus;
		End;
	End;
End;

procedure TFormMain.GridMainKeyPress(Sender: TObject; Var Key: Char);
Begin
	Modified ( True );
end;

procedure TFormMain.GridMainKeyDown(Sender: TObject; Var Key: Word;
	Shift: TShiftState);
Begin
	Case Key Of

		116 : { F5 }
		Begin
			Dec ( WadEntries [ iSel ].Position, GridRecSize );
			Inc ( WadEntries [ iSel ].Size, GridRecSize );
			UpdateWadEntry ( ListWad.Selected.Index, iSel );
			ShowEntry ( '', False );
		End;

		117 : { F6 }
		Begin
			Inc ( WadEntries [ iSel ].Position, GridRecSize );
			Dec ( WadEntries [ iSel ].Size, GridRecSize );
			UpdateWadEntry ( ListWad.Selected.Index, iSel );
			ShowEntry ( '', False );
		End;

		118 : { F7 }
		Begin
			Dec ( WadEntries [ iSel ].Size, GridRecSize );
			UpdateWadEntry ( ListWad.Selected.Index, iSel );
			ShowEntry ( '', False );
		End;

		119 : { F8 }
		Begin
			Inc ( WadEntries [ iSel ].Size, GridRecSize );
			UpdateWadEntry ( ListWad.Selected.Index, iSel );
			ShowEntry ( '', False );
		End;

		120 : { F9 }
		Begin
			WriteWadEntry ( iSel );
			UpdateWadEntry ( ListWad.Selected.Index, iSel );
			ShowMessage ( 'Changed.' );
		End;

		Else
		Begin
			//Caption := Comma ( Key );
		End;
	End;
end;

procedure TFormMain.GridMainSelectCell(Sender: TObject; ACol,
	ARow: Integer; Var CanSelect: Boolean);
Begin
	Status ( Comma ( ACol ) + ':' + Comma ( ARow - 1 ) );
end;

// ##################################

Procedure TFormMain.DrawRect ( c : TCanvas; x, y, xs, ys : Integer );
Begin
	c.MoveTo ( x, y );
	c.LineTo ( x + xs - 1, y );
	c.LineTo ( x + xs - 1, y + ys - 1 );
	c.LineTo ( x, y + ys - 1 );
	c.LineTo ( x, y );
end;

// !TextScreen

procedure TFormMain.mnuTextScreenFillClick(Sender: TObject);
Var
	c : Integer;
	x, y : Integer;
	x1, y1, x2, y2 : Integer;
Begin
	c := SafeVal ( InputBox ( 'Fill', 'Enter fill character code', '32' ) );
	If c > 0 Then
	Begin
		If TextScreen_x < TextScreen_bx Then
		Begin
			x1 := TextScreen_x;
			x2 := TextScreen_bx;
		End
		Else
		Begin
			x1 := TextScreen_bx;
			x2 := TextScreen_x;
		End;
		//
		If TextScreen_y < TextScreen_by Then
		Begin
			y1 := TextScreen_y;
			y2 := TextScreen_by;
		End
		Else
		Begin
			y1 := TextScreen_by;
			y2 := TextScreen_y;
		End;
		//
		For x := x1 To x2 Do
		Begin
			For y := y1 To y2 Do
			Begin
				TextScreen [ x, y, 0 ] := c;
				If TextScreen_bc >= 0 Then
				Begin
					TextScreen [ x, y, 1 ] := TextScreen_bc Shl 4 Or ( TextScreen [ x, y, 1 ] And $F );
				End;
				If TextScreen_fc >= 0 Then
				Begin
					TextScreen [ x, y, 1 ] := TextScreen_fc Or ( TextScreen [ x, y, 1 ] And $F0 );
				End;
			End;
		End;
		//
		TextScreenRefresh;
	End;
end;

procedure TFormMain.mnuTextScreenCopyClick(Sender: TObject);
Var
	Color : Byte;
Begin
	//
	// Get color of current char
	//
	Color := TextScreen [ TextScreen_x, TextScreen_y, 1 ];
	TextScreen_fc := Color And $0F;
	TextScreen_bc := Color Shr 4;
	//
	// Store current char for drawing
	//
	TextScreen_char := TextScreen [ TextScreen_x, TextScreen_y, 0 ];
	//
	TextScreenRefreshColors;
end;

//========================================
// Copies the selected area to the buffer
//
procedure TFormMain.mnuTextScreenCopyAreaClick(Sender: TObject);
Var
	x, y, bx, by : Integer;
Begin
	//
	// --- Store size of selection
	//
	TextScreen_bsx := Abs ( TextScreen_x - TextScreen_bx );
	TextScreen_bsy := Abs ( TextScreen_y - TextScreen_by );
	//
	// --- Calculate base of area
	//
	If TextScreen_bx < TextScreen_x Then
		bx := TextScreen_bx
	Else
		bx := TextScreen_x;
	If TextScreen_by < TextScreen_y Then
		by := TextScreen_by
	Else
		by := TextScreen_y;
	//
	For y := 0 To TextScreen_bsy Do
	Begin
		For x := 0 To TextScreen_bsx Do
		Begin
			TextScreenBuffer [ x, y, 0 ] := TextScreen [ bx + x, by + y, 0 ];
			TextScreenBuffer [ x, y, 1 ] := TextScreen [ bx + x, by + y, 1 ];
		End;
	End;
end;

//-----------------
// Paste buffer
//
procedure TFormMain.mnuTextScreenPasteAreaClick(Sender: TObject);
Var
	x, y : Integer;
Begin
	For y := 0 To TextScreen_bsy Do
	Begin
		For x := 0 To TextScreen_bsx Do
		Begin
			If ( TextScreen_x + x < TextScreen_sx )
			And ( TextScreen_y + y < TextScreen_sy ) Then
			Begin
				TextScreen [ TextScreen_x + x, TextScreen_y + y, 0 ] := TextScreenBuffer [ x, y, 0 ];
				TextScreen [ TextScreen_x + x, TextScreen_y + y, 1 ] := TextScreenBuffer [ x, y, 1 ];
			End;
		End;
	End;
	//
	TextScreenRefresh;
end;

procedure TFormMain.ImageTextScreenColorsMouseDown(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Begin
	If Button = mbLeft Then
	Begin
		x := x Div TextScreenColorWidth - 1;
		TextScreen_fc := x;
		TextScreenRefreshColors;
	End
	Else
	Begin
		If Button = mbRight Then
		Begin
			x := x Div TextScreenColorWidth - 1;
			TextScreen_bc := x;
			TextScreenRefreshColors;
		End
	End;
end;

Function TFormMain.TextScreenSave : Boolean;
Var
	x, y : Integer;
Begin
	Starting;
	//
	fOpenTemp;
	//
	For y := 0 To TextScreen_sy - 1 Do
	Begin
		For x := 0 To TextScreen_sx - 1 Do
		Begin
			SendByte ( fo, TextScreen [ x, y, 0 ] );
			SendByte ( fo, TextScreen [ x, y, 1 ] );
		End;
	End;
	//
	CloseFile ( fo );
	//
	ReplaceFile ( iSel, sTempFile, True, True );
	//
	Modified ( False );
	UpdateModifiedDate;
	//
	Finished;
	//
	TextScreenSave := True;
End;

procedure TFormMain.mnuTextScreenSaveClick(Sender: TObject);
Begin
	TextScreenSave;
end;

Procedure TFormMain.TextScreenCursor ( Show : Boolean );
Begin
	ImageTextScreen.Canvas.Pen.Mode := pmXor;
	ImageTextScreen.Canvas.Pen.Color := RGB ( $FF, $CC, $AA );
	DrawRect ( ImageTextScreen.Canvas,
		TextScreen_x * TextScreen_px, TextScreen_y * TextScreen_py,
		TextScreen_px, TextScreen_py );
End;

Procedure TFormMain.TextScreenSelection ( Show : Boolean );
Var
	x1, y1, x2, y2 : Integer;
Begin
	If ( TextScreen_x <> TextScreen_bx )
	Or ( TextScreen_y <> TextScreen_by ) Then
	Begin
		If TextScreen_x < TextScreen_bx Then
		Begin
			x1 := TextScreen_x;
			x2 := TextScreen_bx;
		End
		Else
		Begin
			x1 := TextScreen_bx;
			x2 := TextScreen_x;
		End;
		//
		If TextScreen_y < TextScreen_by Then
		Begin
			y1 := TextScreen_y;
			y2 := TextScreen_by;
		End
		Else
		Begin
			y1 := TextScreen_by;
			y2 := TextScreen_y;
		End;
		//
		ImageTextScreen.Canvas.Pen.Color := clGray;
		DrawRect ( ImageTextScreen.Canvas,
			x1 * TextScreen_px, y1 * TextScreen_py,
			( x2 - x1 + 1 ) * TextScreen_px, ( y2 - y1 + 1 ) * TextScreen_py );
	End;
End;

procedure TFormMain.TextScreenEditKeyDown(Sender: TObject; Var Key: Word;
	Shift: TShiftState);
procedure AfterMove;
Begin
	// if shift is not held while moving...
	If Not ( ssShift in Shift ) Then
	Begin
		// new selection
		TextScreen_bx := TextScreen_x;
		TextScreen_by := TextScreen_y;
	End;
	//
	TextScreenCursor ( True );
	TextScreenSelection ( True );
End;
Begin
	Case Key Of

		36 : { home }
		Begin
			If TextScreen_x > 0 Then
			Begin
				TextScreenSelection ( False );
				TextScreenCursor ( False );
				TextScreen_x := 0;
				TextScreenCursor ( True );
				TextScreenSelection ( True );
			End
			Else
			Begin
				If TextScreen_y > 0 Then
				Begin
					TextScreenSelection ( False );
					TextScreenCursor ( False );
					TextScreen_y := 0;
					TextScreenCursor ( True );
					TextScreenSelection ( True );
				End;
			End;
		End;

		37 : { cursor left }
		Begin
			TextScreenSelection ( False );
			TextScreenCursor ( False );
			//
			If TextScreen_x = 0 Then
			Begin
				TextScreen_x := TextScreen_sx - 1;
			End
			Else
			Begin
				Dec ( TextScreen_x );
			End;
			//
			AfterMove;
		End;

		38 : { cursor up }
		Begin
			TextScreenSelection ( False );
			TextScreenCursor ( False );
			//
			If TextScreen_y = 0 Then
			Begin
				TextScreen_y := TextScreen_sy - 1;
			End
			Else
			Begin
				Dec ( TextScreen_y );
			End;
			//
			AfterMove;
		End;

		39 : { cursor right }
		Begin
			TextScreenSelection ( False );
			TextScreenCursor ( False );
			//
			If TextScreen_x = TextScreen_sx - 1 Then
			Begin
				TextScreen_x := 0;
			End
			Else
			Begin
				Inc ( TextScreen_x );
			End;
			//
			AfterMove;
		End;

		40 : { cursor down }
		Begin
			TextScreenSelection ( False );
			TextScreenCursor ( False );
			//
			If TextScreen_y = TextScreen_sy - 1 Then
			Begin
				TextScreen_y := 0;
			End
			Else
			Begin
				Inc ( TextScreen_y );
			End;
			//
			AfterMove;
		End;

	End;
	FormKeyDown ( Sender, Key, Shift );
end;

procedure TFormMain.TextScreenEditKeyPress(Sender: TObject; Var Key: Char);
Var
	ch : Integer;
Begin
	// Letter?
	If ( Key >= #32 ) Then
	Begin
		// Coords valid?
		If ( TextScreen_x >= 0 ) And ( TextScreen_x < TextScreen_sx )
		And ( TextScreen_y >= 0 ) And ( TextScreen_y < TextScreen_sy ) Then
		Begin
			//
			// *** Write! ***
			//
			TextScreenSelection ( False );
			TextScreenCursor ( False );
			//
			If Key = #32 Then
				ch := TextScreen_char
			Else
				ch := Ord ( Key );
			//
			TextScreen [ TextScreen_x, TextScreen_y, 0 ] := ch;
			//
			If TextScreen_bc >= 0 Then
			Begin
				TextScreen [ TextScreen_x, TextScreen_y, 1 ] :=
					TextScreen_bc Shl 4 Or ( TextScreen [ TextScreen_x, TextScreen_y, 1 ] And $F );
			End;
			If TextScreen_fc >= 0 Then
			Begin
				TextScreen [ TextScreen_x, TextScreen_y, 1 ] :=
					TextScreen_fc Or ( TextScreen [ TextScreen_x, TextScreen_y, 1 ] And $F0 );
			End;
			//
			TextScreenRefreshChar ( TextScreen_x, TextScreen_y );
			//
			Inc ( TextScreen_x );
			//
			TextScreenCursor ( True );
			TextScreenSelection ( True );
			//
			Modified ( True );
		End;
	End
	Else
	Begin

		//Caption := Comma ( Ord ( Key ) );

	End;
end;

procedure TFormMain.chkTextScreenGridClick(Sender: TObject);
Begin
	if chkTextScreenGrid.Checked Then
	Begin
		Inc ( TextScreen_px );
		Inc ( TextScreen_py );
	End
	Else
	Begin
		Dec ( TextScreen_px );
		Dec ( TextScreen_py );
	End;
	//
	TextScreenRefresh;
end;

procedure TFormMain.ImageTextScreenMouseMove(Sender: TObject;
	Shift: TShiftState; X, Y: Integer);
Begin
	If ssLeft in Shift Then
	Begin
		x := x Div TextScreen_px;
		y := y Div TextScreen_py;
		//
		If ( x >= 0 ) And ( x < TextScreen_sx )
		And ( y >= 0 ) And ( y < TextScreen_sy ) Then
		Begin
			TextScreenSelection ( False );
			//
			TextScreenCursor ( False );
			//
			TextScreen_x := x;
			TextScreen_y := y;
			//
			TextScreenCursor ( True );
			//
			TextScreenSelection ( True );
		End;
	End;
end;

procedure TFormMain.ImageTextScreenMouseDown(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Begin
	x := x Div TextScreen_px;
	y := y Div TextScreen_py;
	//
	If ( x >= 0 ) And ( x < TextScreen_sx )
	And ( y >= 0 ) And ( y < TextScreen_sy ) Then
	Begin
		If Button = mbRight Then
		Begin
			Inc ( TextScreen [ x, y, 0 ] );
			TextScreen [ x, y, 1 ] := $1F;
			TextScreenRefresh;
		End
		Else
		Begin
			TextScreenSelection ( False );
			TextScreenCursor ( False );
			TextScreen_x := x;
			TextScreen_y := y;
			TextScreen_bx := x;
			TextScreen_by := y;
			TextScreenCursor ( True );
			TextScreenSelection ( True );
		End;
	End;
end;

Procedure TFormMain.TextScreenLoad;
Var
	x, y : Integer;
	i : Integer;
Begin
	Starting;
	//
	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( F, cPos );
	//
	i := 0; // size counter
	For y := 0 To TextScreen_sy - 1 Do
	Begin
		For x := 0 To TextScreen_sx - 1 Do
		Begin
			If i < cLen Then
			Begin
				TextScreen [ x, y, 0 ] := GetByte ( f );
				TextScreen [ x, y, 1 ] := GetByte ( f );
			End
			Else
			Begin
				TextScreen [ x, y, 0 ] := 0;
				TextScreen [ x, y, 1 ] := 0;
			End;
			Inc ( i, 2 );
		End;
	End;
	//
	fClose;
	//
	Finished;
  //
  Modified ( False );
end;

Procedure TFormMain.TextScreenRefreshChar ( x, y : Integer );
Var
	b, c : Byte;
Begin
	b := TextScreen [ x, y, 0 ];
	c := TextScreen [ x, y, 1 ];
	//
	With ImageTextScreen.Canvas Do
	Begin
		Brush.Color := ConstantFindIndex ( 'BASIC_COLORS', c Shr 4 );
		Font.Color := ConstantFindIndex ( 'BASIC_COLORS', c And $F );
		TextOut ( x * TextScreen_px, y * TextScreen_py, Chr ( b ) );
	End;
end;

Procedure TFormMain.TextScreenRefreshColors;
Var
	w, h : Integer;
	i : Integer;
	s : String;
Begin
	TextScreenColorWidth := ImageTextScreenColors.Width Div 17;
	w := TextScreenColorWidth;
	h := ImageTextScreenColors.Height - 1;
	//
	With ImageTextScreenColors.Canvas Do
	Begin
		Font.Name := 'Tahoma';
		//
		Brush.Color := clBlack;
		FillRect ( ClipRect );
		//
		For i := -1 To 15 Do
		Begin
			If i < 0 Then
			Begin
				Brush.Color := RGB ( 160, 140, 120 );
				Brush.Style := bsFDiagonal;
			End
			Else
			Begin
				Brush.Color := ConstantFindIndex ( 'BASIC_COLORS', i );
				Brush.Style := bsSolid;
			End;
			//
			FillRect ( Classes.Rect ( 1 + ( i + 1 ) * w, 1, ( i + 2 ) * w, h ) );
			//
			s := '';
			If TextScreen_bc = i Then
			Begin
				s := 'B';
			End;
			If TextScreen_fc = i Then
			Begin
				s := s + 'F';
			End;
			//
			If s <> '' Then
			Begin
				If i < 0 Then
					Font.Color := clWhite
				Else
					Font.Color := ConstantFindIndex ( 'BASIC_COLORS', 15 - i );
				//
				TextOut ( ( i + 1 ) * w + ( w - TextWidth ( s ) ) Div 2, ( h - TextHeight ( s ) ) Div 2, s );
			End;
		End;
	End;
End;

Procedure TFormMain.TextScreenRefresh;
Var
	x, y : Integer;
	b, c : Byte;
Begin
	Starting;
	//
	If PanelTextScreen.Tag = 0 Then
	Begin
		PanelReset ( PanelTextScreen, ImageTextScreen );
	End;
	//
	With ImageTextScreenColors Do
	Begin
		Picture.Bitmap.Width := ImageTextScreenColors.Width;
		Picture.Bitmap.Height := ImageTextScreenColors.Height;
	End;
	//
	With ImageTextScreen Do
	Begin
		Picture.Bitmap.Width := ImageTextScreen.Width;
		Picture.Bitmap.Height := ImageTextScreen.Height;
		//
		With Canvas Do
		Begin
			Brush.Color := RGB ( 64, 80, 96 );
			FillRect ( ClipRect );
		End;
	End;
	//
	For y := 0 To TextScreen_sy - 1 Do
	Begin
		For x := 0 To TextScreen_sx - 1 Do
		Begin
			//
			b := TextScreen [ x, y, 0 ];
			c := TextScreen [ x, y, 1 ];
			//
			With ImageTextScreen.Canvas Do
			Begin
				Brush.Color := ConstantFindIndex ( 'BASIC_COLORS', c Shr 4 );
				Font.Color := ConstantFindIndex ( 'BASIC_COLORS', c And $F );
				TextOut ( x * TextScreen_px, y * TextScreen_py, Chr ( b ) );
			End;
		End;
	End;
	//
	TextScreenCursor ( True );
	TextScreenSelection ( True );
	//
	Finished;
end;

Procedure TFormMain.TextScreenEditor ( bFocus : Boolean );
Begin
	With ImageTextScreen.Canvas Do
	Begin
		Font.Name := 'TERMINAL';
		Font.Charset := OEM_CHARSET;
		Font.Size := 6;
	End;
	TextScreen_px := 6;
	TextScreen_py := 8;
	//
	If chkTextScreenGrid.Checked Then
	Begin
		Inc ( TextScreen_px );
		Inc ( TextScreen_py );
	End;
	//
	TextScreen_sx := 80;
	TextScreen_sy := 25;
	//
	TextScreen_bx := 0;
	TextScreen_by := 0;
	TextScreen_x := 0;
	TextScreen_y := 0;
	//
	TextScreen_bc := -1;
	TextScreen_fc := -1;
	//
	TextScreenLoad;
	TextScreenRefresh;
	TextScreenRefreshColors;
	//
	ShowPage ( edTextScreen );
	//
	If bFocus Then
	Begin
		TextScreenEdit.SetFocus;
	End;
end;

Procedure TFormMain.SpeakerSound;
Var
	i : Integer;
	l : Integer;
	w : Word;
	b : Array [ 0 .. 1023 ] Of Byte;
	bp : Byte;
	s : String;

Procedure Sound(mhz : integer);
{mhz = the frequency of the pc speaker}
Var
	count : word;
Begin
	count := 1193280 div mhz;
	asm
		mov al,$b6
		out $43,al
		mov ax,count
		out $42,al
		mov al,ah
		out $42,al
		mov al,3
		out $61,al
	end;
end;

Procedure NoSound;
{turn off the pc speaker}
Begin
	asm
		mov al,0
		out $61,al
	end;
end;

{
Var
	n : Cardinal;
	}

Begin
	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( F, cPos );
	//
	MemoHex.Lines.Clear;
	//
	GetWord ( f ); // 00
	w := GetWord ( f ); // Length
	l := w;
	BlockRead ( F, b [ 0 ], l ); // Data
	//
	bp := 0;
	//
	For i := 0 To l - 1 Do
	Begin
		If bp <> b [ i ] Then
		Begin
			{
			If b [ i ] = 0 Then
				NoSound
			Else
				Sound ( b [ i ] * ( 8 + b [ i ] Div 5 ) );
			}
		End;
		//
		s := s + IntToHex ( b [ i ], 2 ) + ' ';
		//
		bp := b [ i ];
		//
		{
		For n := 1 To 500000 Do
		Begin
			If n = 0 Then
				b [ 0 ] := 0;
		End;
		}
	End;
	//
	{
	NoSound;
	}
	//
	MemoHex.Lines.Add ( s );
	fClose;
	Modified ( False );
	//
	ShowPage ( edHex );
End;

Procedure TFormMain.WaveFreeMem;
Begin
	If iWaveDataSize > 0 Then
	Begin
		FreeMem ( WaveData, 44 + iWaveDataSize );
	End;
	iWaveDataSize := 0;
	WaveData := Nil;
End;

Procedure TFormMain.WaveGetMem ( DataSize : Integer );
Begin
	WaveFreeMem;
	iWaveDataSize := DataSize;
	GetMem ( WaveData, 44 + iWaveDataSize );
End;

procedure TFormMain.UpDownImageZoomClick(Sender: TObject;
	Button: TUDBtnType);
Begin
	ImageRenderCurrent;
end;

Function TFormMain.WaveIdentify ( iLen : Integer ) : TWaveFormat;
Var
	T : TWaveFormat;
	HL1, HL2 : Cardinal;
Begin
	//
	T := wfmtNone;
	//
	If iLen > 8 Then
	Begin
		HL1 := Cardinal ( GetLong ( f ) );
		HL2 := Cardinal ( GetLong ( f ) );
		//
		Case HL1 Of
			//
			$61657243 : // { "Crea"tive }
			Begin
				T := wfmtVOC;
			End;
			//
			$2B110003,
			$56220003,
			$AC440003 : // { $0003/11025 $0003/22050 $0003/44100 : Doom }
			Begin
				If Integer ( HL2 + 8 ) = iLen Then
				Begin
					T := wfmtDOOM;
				End;
			End;
			//
			$46464952, $52494646 : // { RIFF (FFIR) : WAVE }
			Begin
				T := wfmtWAV;
			End;
			//
			$80808080 : // { Probably RAW... }
			Begin
				T := wfmtRAW;
			End;
			//
			$5367674F : // OggS: Ogg Sound
			Begin
				T := wfmtOgg;
			End;
			//
		End;
	End;
	//
	WaveIdentify := T;
End;

Function TFormMain.WaveIdentifyFile ( sFN : String; iPos, iLen : Integer ) : TWaveFormat;
Begin
	//
	If fOpenCount > 0 Then
	Begin
		Status ( 'WARNING: The file was still open (usually means last operation failed)' );
		//ShowMessage ( 'The file was still open.' );
		While fOpenCount > 0 Do
		Begin
			fClose;
		End;
	End;
	//
	If fOpen ( sFN ) Then
	Begin
		If fSeek ( f, iPos ) Then
		Begin
			WaveIdentifyFile := WaveIdentify ( iLen );
		End
		Else
		Begin
			WaveIdentifyFile := wfmtNone;
		End;
		//
		fClose;
	End
	Else
	Begin
		WaveIdentifyFile := wfmtNone;
	End;
	//
End;

procedure TFormMain.WaveReverseByteOrder;
Var
	i : Integer;
	w : Word;
Begin
	//
	For i := 0 To iWaveDataLength Div 2 Do
	Begin
		w := WaveData^.Words [ 22 + i ];
		w := ( w And 255 ) Shl 8 + ( w Shr 8 );
		WaveData^.Words [ 22 + i ] := w;
	End;
	//
	WaveEditorRefresh;
end;

Procedure TFormMain.WaveEditorRefresh;

Var
	x, p, i : Integer;
	s, b : Integer;
	yc, xs : Integer;
	Zoom : Integer;
	sHeader : String;

Function GetWaveData ( Position : Integer ) : Integer;
Var
	w : Word;
Begin
	Case iWaveBits Of

		1 :
		Begin
			GetWaveData := WaveData^.Bytes [ Position ];
		End;

		2 :
		Begin
			w := Word ( WaveData^.Words [ Position ] );
			w := ( w And 255 ) Shl 8 + ( w Shr 8 );
			w := w Xor $7FFF;
			//
			GetWaveData := ShortInt ( w );
		End;

		4 :
		Begin
			GetWaveData := WaveData^.Words [ Position ];
		End;

		Else
		Begin
			GetWaveData := 0;
		End;

	End;
End;

Begin
	If PanelWave.Tag = 0 Then
	Begin
		PanelReset ( PanelWave, PanelWaveImage );
	End;
	//
	xs := PanelWaveImage.Width;
	If iWaveLen < xs Then xs := iWaveLen;
	//
	yc := PanelWaveImage.Height Div 2;
	iWaveEditor_y := yc - 128;
	//
	With PanelWaveImage.Canvas Do
	Begin
		Brush.Color := clWhite;
		FillRect ( ClipRect );
		//
		Pen.Color := clBlue;
		MoveTo ( 0, yc );
		LineTo ( PanelWaveImage.Width, yc );
		//
		Pen.Color := clDkGray;
		MoveTo ( 0, yc - 128 );
		LineTo ( PanelWaveImage.Width, yc - 128 );
		//
		MoveTo ( 0, yc + 128 );
		LineTo ( PanelWaveImage.Width, yc + 128 );
		//
		Pen.Color := clSilver;
		Pen.Style := psDot;
		MoveTo ( 0, yc - 64 );
		LineTo ( PanelWaveImage.Width, yc - 64 );
		//
		MoveTo ( 0, yc + 64 );
		LineTo ( PanelWaveImage.Width, yc + 64 );
		Pen.Style := psSolid;
		//
	End;
	//
	PanelWaveImage.Canvas.Pen.Color := clBlack;
	PanelWaveImage.Canvas.Font.Name := 'Tahoma';
	//
	WaveEditSampleRate.Tag := 1;
	WaveEditSampleRate.Text := Comma ( iWaveSampleRate );
	WaveEditSampleRate.Tag := 0;
	//
	sHeader := sWaveFormat + ', ';
	//
	If iWaveBits = 1 Then
		sHeader := sHeader + '8 bit, '
	Else
		sHeader := sHeader + '16 bit, ';
	//
	If iWaveChannels = 1 Then
		sHeader := sHeader + 'Mono'
	Else
		sHeader := sHeader + 'Stereo';
	//
	sHeader := sHeader + ' - Length: ' + Comma ( iWaveDataLength );
	//
	PanelWaveImage.Canvas.TextOut ( 4, 4, sHeader );
	//
	If sWaveExtra <> '' Then
	Begin
		PanelWaveImage.Canvas.TextOut ( 4, 18, 'Extra info: ' + sWaveExtra );
	End;
	//
	// ---
	//
	Zoom := PanelWaveUpDownZoom.Position;
	If Zoom < 1 Then Zoom := 1;
	//
	PanelWaveImage.Canvas.Pen.Color := clRed;
	x := 0;
	p := 44 + Round ( ( iWaveLen / WaveScroll.Max ) * WaveScroll.Position ); // position
	//
	If ( iWaveBits = 2 ) Then
		p := p Or 1;
	//
	While ( x < xs ) And ( p < iWaveLen ) Do
	Begin
		s := 0;
		For i := 1 To Zoom Do
		Begin
			If ( p >= iWaveDataSize ) Then
				b := 128
			Else
				b := GetWaveData ( p );
			s := s + b;
			//
			Inc ( p, iWaveBits );
		End;
		//
		{
		If iWaveBps = 2 Then
		Begin
			s := s Shr 8;
		End;
		}
		//
		s := Round ( s / Zoom );
		//
		If ( iWaveBits = 2 ) Then
			s := s + 128;
		//
		If x = 0 Then
			PanelWaveImage.Canvas.MoveTo ( x, yc - 128 + s )
		Else
			PanelWaveImage.Canvas.LineTo ( x, yc - 128 + s );
		Inc ( x );
	End;
	//
	If ( x < xs ) Then
	Begin
		PanelWaveImage.Canvas.Brush.Color := clSilver;
		PanelWaveImage.Canvas.FillRect ( Classes.Rect ( x, yc - 127, PanelWaveImage.Width, yc + 128 ) );
	End;
End;

procedure TFormMain.WaveScrollChange(Sender: TObject);
Begin
	WaveEditorRefresh;
end;

procedure TFormMain.PanelWaveUpDownZoomClick(Sender: TObject;
	Button: TUDBtnType);
Begin
	WaveEditorRefresh;
end;

Procedure TFormMain.SetWaveDataHeader ( i : Integer; d : Cardinal );
Begin
	WaveData^.Bytes [ i ] := d And 255;
	WaveData^.Bytes [ i + 1 ] := d Shr 8 And 255;
	WaveData^.Bytes [ i + 2 ] := d Shr 16 And 255;
	WaveData^.Bytes [ i + 3 ] := d Shr 24 And 255;
End;

Procedure TFormMain.WaveEditor;
Begin
	Starting;
	//
	If PanelWave.Tag = 0 Then
	Begin
		PanelWave.Visible := True;
		PanelWaveImage.Refresh;
		PanelWave.Tag := 1;
	End;
	//
	With PanelWaveImage Do
	Begin
		Picture.Bitmap.Width := Width;
		Picture.Bitmap.Height := Height;
	End;
	//
	WaveLoad ( sEditFile, iSel );
	//
	WaveScroll.Min := 0;
	WaveScroll.Max := 10;
	WaveScroll.Position := 0;
	//
	WaveEditorRefresh;
	//
	Modified ( False );
	//
	ShowPage ( edWave );
	//
	If gAutoPlaySounds Then
		mnuWavePlayClick ( Self );
	//
	Finished;
End;

Procedure TFormMain.WaveLoad ( sFileName : String; iEntry : Integer );
Var
	w1, Compression : Longint;
	w2, iPos, iLen : Longint;
	b : Byte;
	bRevByteOrder : Boolean;

	// for IMA-ADPCM DECOMPRESSION
Var
	Index, CurrentSample, Delta : Integer;
	Code, HighBits, Sign : Byte;
	Code2, Code3 : Byte;
	bLow : Boolean;
	iDataPos : Integer;

Const
	IndexAdjust : Array [ 0.. 7 ] Of Integer = (-1,-1,-1,-1,2,4,6,8);
	StepTable : Array [ 0 .. 88 ] Of Integer = (
		7,     8,     9,     10,    11,    12,     13,    14,    16,
		17,    19,    21,    23,    25,    28,     31,    34,    37,
		41,    45,    50,    55,    60,    66,     73,    80,    88,
		97,    107,   118,   130,   143,   157,    173,   190,   209,
		230,   253,   279,   307,   337,   371,    408,   449,   494,
		544,   598,   658,   724,   796,   876,    963,   1060,  1166,
		1282,  1411,  1552,  1707,  1878,  2066,   2272,  2499,  2749,
		3024,  3327,  3660,  4026,  4428,  4871,   5358,  5894,  6484,
		7132,  7845,  8630,  9493,  10442, 11487,  12635, 13899, 15289,
		16818, 18500, 20350, 22385, 24623, 27086,  29794, 32767 );

Function Get3Bytes : Longint;
Var
	b : Byte;
	iLen : Longint;
Begin
	b := Byte ( GetByte ( f ) ); // length ( 3 bytes )
	iLen := b;
	b := Byte ( GetByte ( f ) );
	iLen := iLen Or ( b Shl 8 );
	b := Byte ( GetByte ( f ) );
	iLen := iLen Or ( b Shl 16 );
	//
	Get3Bytes := iLen;
End;

Begin
	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( F, WadEntries [ iEntry ].Position );
	//
	bWaveExportable := True;
	Compression := 1;
	iWaveSampleRate := 0;
	iWaveDataLength := 0;
	iWaveLen := 0;
	iWaveBits := 1;
	iWaveChannels := 1;
	//
	bRevByteOrder := False;
	//
	sWaveExtra := '';
	//
	iPos := 0;
	//
	If UpperCase ( KeepFromRight ( Trim ( WadEntries [ iEntry ].Name ), 4 ) ) = '.RAW' Then
	Begin
		//
		// RAW FORMAT
		//
		iWaveSampleRate := 11025;
		iWaveDataLength := WadEntries [ iEntry ].Size; // full length of this entry
		iWaveBits := 1;
		//
		sWaveFormat := 'RAW Format';
		//
		w1 := 1; // 1 = ok
	End
	Else
	Begin
		//
		w1 := Word ( GetWord ( f ) ); // Signature
		//
		Case w1 Of

			3 :
			Begin
				//
				// --- Doom Wave
				//
				iWaveSampleRate := Word ( GetWord ( f ) ); // Sample Rate
				iWaveDataLength := GetLong ( f ); // Data Length
				//iWaveBits := GetWord ( f ) + 1; // Bytes Per Sample
				//
				Compression := 1;
				//
				sWaveFormat := 'Doom Wave Format';
				//
				{
				If iWaveDataLength > ( WadEntries [ iEntry ].Size - 8 ) Then
				Begin
					}
					iWaveDataLength := WadEntries [ iEntry ].Size - 8;
					{
				End;
				}
			End;

			$4F4D : // { "MO"VI : System shock sound file }
			Begin
				//
				// --- Get sample rate
				//
				Seek ( f, WadEntries [ iEntry ].Position + $26 );
				iWaveSampleRate := Word ( GetWord ( f ) );
				//
				// --- Get sample start position
				//
				Seek ( f, WadEntries [ iEntry ].Position + $8 );
				iPos := Word ( GetWord ( f ) );
				iPos := iPos + $400;
				//
				Seek ( f, WadEntries [ iEntry ].Position + iPos );
				iWaveDataLength := WadEntries [ iEntry ].Size - iPos;
				//
				iWaveBits := 1;
				//
				sWaveFormat := 'System Shock Audio Format';
			End;

			$7243 : // { "Cr"eative }
			Begin
				Seek ( f, WadEntries [ iEntry ].Position + $1A );
				//
				iWaveBits := 1;
				//
				b := 0;
				While b <> 1 Do
				Begin
					b := GetByte ( f );
					//
					Case b Of

						0 :
						Begin
							b := 1;
						End;

						1 :
						Begin
							If iPos = 0 Then
							Begin
								iPos := FilePos ( f ) - 1;
								Compression := 2; // Segmented VOC
							End;
							//
							// --- Read the length
							//
							iLen := Get3Bytes;
							//
							// --- Length includes following 2 bytes
							//
							iLen := iLen - 2;
							//
							// --- Add to total length
							//
							iWaveDataLength := iWaveDataLength + iLen;
							//
							b := GetByte ( f ); // sample rate
							iWaveSampleRate := 1000000 Div ( 256 - b );
							//
							GetByte ( f ); // Compression flag - ignored for now
							//
							// --- go to beginning of next segment
							//
							Seek ( f, FilePos ( f ) + iLen );
							//
						End;

						2 :
						Begin
							//
							// --- Read the length
							//
							iLen := Get3Bytes;
							//
							// --- Add to total length
							//
							iWaveDataLength := iWaveDataLength + iLen;
							//
							// --- go to beginning of next segment
							//
							Seek ( f, FilePos ( f ) + iLen );
						End;

						5 : // ASCII info
						Begin
							iLen := Get3Bytes;
							//
							If iLen > 0 Then
							Begin
								sWaveExtra := sWaveExtra + GetString ( f, iLen );
							End;
						End;

						6 : // repeat
						Begin
							Get3Bytes;
							//
							GetWord ( f ); // repeat times
						End;

						9 : // Special Data block defined by Duke3D
						Begin
							//
							iLen := Get3Bytes;
							//
							// --- Data length includes the 12 extra bytes
							//
							iWaveDataLength := iLen - 12;
							//
							iWaveSampleRate := GetWord ( f ); // Sample Rate
							//
							GetWord ( f ); // ???
							//
							iWaveBits := Byte ( GetByte ( f ) );
							iWaveBits := iWaveBits Shr 3;
							//
							If iWaveBits = 2 Then
							Begin
								//
								// 16 bit VOC files are in reverse byte order
								//
								bRevByteOrder := True;
							End;
							//
							GetByte ( f ); // 1=mono, 2=stereo
							GetByte ( f ); // ???
							//
							GetLong ( f ); // ???
							//
							b := 1;
							//
							iPos := FilePos ( f ); // start from here
							Compression := 1;
						End;

						Else
						Begin
							ShowMessage ( 'Internal error: Byte = ' + Comma ( b ) );
						End;

					End;
				End;
				{
				Seek ( f, WadEntries [ iEntry ].Position + $1B );
				DataLength := GetWord ( f ); // Data Length
				//
				Seek ( f, WadEntries [ iEntry ].Position + $1E );
				iWaveSampleRate := GetWord ( f ); // Sample Rate
				//
				Seek ( f, WadEntries [ iEntry ].Position + $23 );
				iWaveBPS := GetByte ( f );
				//
				Seek ( f, WadEntries [ iEntry ].Position + $2A );
				}
				//
				If iPos = 0 Then
				Begin
					//
					sWaveFormat := 'Error reading VOC file';
					bWaveExportable := False;
					//
				End
				Else
				Begin
					//
					Seek ( f, iPos );
					sWaveFormat := 'VOC Format';
					//
				End;
			End;

			$4952, $4646 : // { "RI"FF or "FF"IR }
			Begin
				// Skip first 12 bytes
				Seek ( f, WadEntries [ iEntry ].Position + 8 );
				//
				GetLong ( f ); // should be "WAVE"
				{
				if ( w2 = $564157FF ) Then
				Begin
					// handle WAVES in WRS files,
					// they have an extra $FF before "WAVE"
					GetByte ( f ); // skip one byte
				End;
				}
				//
				b := 0; // flag
				//
				While b = 0 Do
				Begin
					//
					w2 := GetLong ( f ); // identifier
					iLen := GetLong ( f ); // data chunk size
					iPos := FilePos ( f ) - WadEntries [ iEntry ].Position;
					//
					Case w2 Of

						$20746D66 : { fmt#20 }
						Begin
							// get header data
							Compression := GetWord ( f ); // 01
							//
							iWaveChannels := GetWord ( f ); // 1=mono, 2=stereo
							//
							If ( iWaveChannels < 1 ) Or ( iWaveChannels > 2 ) Then
								iWaveChannels := 1;
							//
							iWaveSampleRate := GetLong ( f ); // Sample Rate
							//
							GetLong ( f );
							//
							iWaveBits := GetWord ( f ); // 1=8bit, 2=16bit, 4=stereo 16bit
							iWaveBits := iWaveBits Div iWaveChannels;
						End;

						$61746164 : { data }
						Begin
							// data block, exit from loop
							b := 1;
							iWaveDataLength := iLen;
						End;

					End;
					//
					// --- other blocks are ignored
					If b <> 1 Then
					Begin
						If iPos + iLen > WadEntries [ iEntry ].Size Then
						Begin
							b := 1; // exit from loop
							w1 := 0; // not WAVE
						End
						Else
						Begin
							Seek ( f, WadEntries [ iEntry ].Position + iPos + iLen );
						End;
					End;
				End;
				//
				If w1 = 0 Then
				Begin
					sWaveFormat := 'Not a WAV file';
					bWaveExportable := False;
				End
				Else
				Begin
					sWaveFormat := 'WAV Format';
				End;
			End;

			$8080 :
			Begin
				//
				// assume RAW FORMAT...
				//
				iWaveSampleRate := 11025;
				iWaveDataLength := WadEntries [ iEntry ].Size; // full length of this entry
				iWaveBits := 1;
				//
				sWaveFormat := 'RAW Format';
			End;

			$674F : // $5367674F OggS
			Begin
				iWaveSampleRate := 44100;
				iWaveDataLength := 0; //
				iWaveBits := 1;
				//
				bWaveExportable := False;
				sWaveFormat := 'OGG Format (cannot preview)';
			End;

			Else
			Begin
				w1 := 0; // unknown format
				//
				sWaveFormat := 'Unknown file/format';
				bWaveExportable := False;
			End;

		End;
	End;
	//
	// --- Known file?
	//
	If ( w1 <> 0 ) And ( iWaveDataLength >= 0 ) Then
	Begin
		//
		If iWaveBits < 1 Then iWaveBits := 1;
		//
		iWaveLen := iWaveDataLength Div iWaveBits;
		//
		Case Compression Of
			//
			$01 : { PCM }
			Begin
				//
				// --- Security check to prevent reading too much
				//
				If FileSize ( f ) - FilePos ( f ) < iWaveDataLength Then
				Begin
					iWaveDataLength := FileSize ( f ) - FilePos ( f );
				End;
				//
				WaveGetMem ( iWaveDataLength );
				BlockRead ( f, WaveData^.Bytes[44], iWaveDataLength );
			End;
			//
			$02 : { PCM - for segmented VOC files }
			Begin
				//
				// --- Security check to prevent reading too much
				//
				If FileSize ( f ) - FilePos ( f ) < iWaveDataLength Then
				Begin
					iWaveDataLength := FileSize ( f ) - FilePos ( f );
				End;
				//
				WaveGetMem ( iWaveDataLength );
				//
				b := 1;
				iPos := 44;
				While b <> 0 Do
				Begin
					b := GetByte ( f );
					//
					If ( b = 1 ) Or ( b = 2 ) Then
					Begin
						iLen := Get3Bytes;
						//
						If b = 1 Then
						Begin
							iLen := iLen - 2;
							//
							GetByte ( f ); // skip 2 bytes
							GetByte ( f );
						End;
						//
						BlockRead ( f, WaveData^.Bytes [ iPos ], iLen );
						Inc ( iPos, iLen );
					End
					Else
					Begin
						If b <> 0 Then
						Begin
							b := 0; // error!
						End;
					End;
				End;
			End;
			//
			$11 : { IMA-ADPCM DECOMPRESSION }
			Begin
				iWaveBits := 2; // force 16 bits
				iWaveLen := iWaveDataLength Div iWaveBits;
				//
				WaveGetMem ( iWaveDataLength * 10 );
				//
				Index := 0;
				CurrentSample := 0;
				//
				iPos := 0; // source data position
				bLow := True; // low 4 bits first
				HighBits := 0;
				//
				iDataPos := 22; // dest pos - start after WAVE header (WORDS)
				//
				While iPos < iWaveDataLength Do
				Begin
					//
					// --- Get next 4 bits
					//
					If bLow Then
					Begin
						Code := GetByte ( f );
						HighBits := Code Shr 4;
						Code := Code And $F;
					End
					Else
					Begin
						Code := HighBits;
						Inc ( iPos );
					End;
					bLow := Not bLow;
					//
					// Separate the sign bit from the rest
					//
					If ( Code And $8 ) <> 0 then
						Sign := 1
					Else
						Sign := 0;
					//
					Code := Code And $7;
					//
					Delta := ( StepTable [ Index ] * Code ) Div 4 + StepTable [ Index ] Div 8;
					// The last one is to minimize errors
					if Sign = 1 Then
						Delta := -Delta;
					//
					CurrentSample := CurrentSample + Delta;
					//
					If CurrentSample > 32767 Then
						CurrentSample := 32767
					Else
						If CurrentSample < -32768 Then
							CurrentSample := -32768;
					//
					WaveData^.Words [ iDataPos ] := CurrentSample;
					Inc ( iDataPos );
					//
					Index := Index + IndexAdjust [ Code ];
					//
					If Index < 0 Then
						Index := 0;
					If Index > 88 Then
						Index := 88;
				End;
			End;
			//
			$2A : { ROTH WAV }
			Begin
				//
				// --- Security check to prevent reading too much
				//
				{iWaveLen := iWaveLen * 2;
				iWaveDataLength := iWaveDataLength * 2;}
				//
				If FileSize ( f ) - FilePos ( f ) < iWaveDataLength Then
				Begin
					iWaveDataLength := FileSize ( f ) - FilePos ( f );
				End;
				//
				WaveGetMem ( iWaveDataLength );
				//
				iPos := 0; // source data position
				iDataPos := 0;
				//
				bLow := False;
				//
				Code2 := 0;
				Code3 := 0;
				//
				While iPos < iWaveDataLength Do
				Begin
					Code := GetByte ( f );
					Inc ( iPos );
					If ( Code > Code2 ) And ( Code2 < Code3 ) Then
					Begin
						bLow := Not bLow;
						//ShowMessage ( IntToStr ( iPos ) );
					End;
					//
					Code3 := Code2;
					Code2 := Code;
					//CurrentSample := Code;

					(*
					If bLow Then
						CurrentSample := $80 - Code
					Else
						CurrentSample := $80 + Code;
						*)

					CurrentSample := Code Shr 1 + ( Code And 1 ) Shl 7;
					(*
					CurrentSample := ( Code And 128 ) Shr 7
						Or ( Code And 64 ) Shr 5
						Or ( Code And 32 ) Shr 3
						Or ( Code And 16 ) Shr 1
						Or ( Code And 8 ) Shl 1
						Or ( Code And 4 ) Shl 3
						Or ( Code And 2 ) Shl 5
						Or ( Code And 1 ) Shl 7;
						*)
					//
					WaveData^.Bytes [ 44 + iDataPos ] := CurrentSample;
					Inc ( iDataPos );
				End;
			End;
			//
			Else
			Begin
				//
				// --- Unknown compression ---
				//
				WaveGetMem ( iWaveDataLength );
				MessageDlg ( 'Unknown compression method: $' + IntToHex ( Compression, 2 ),
					mtError, [mbOK], 0 );
				bWaveExportable := False;
			End;
			//
		End;
		//
		If bRevByteOrder Then
			WaveReverseByteOrder;
		//
		WaveEditorUpdateHeader;
	End;
	//
	fClose;
End;

// ###########################################################################

procedure TFormMain.WaveEditorUpdateHeader;
Begin
	//
	// --- Init sample header for playing it as WAV
	//
	SetWaveDataHeader ( 00, $46464952 ); // RIFF
	SetWaveDataHeader ( 04, 44 + iWaveDataLength - 8 );
	SetWaveDataHeader ( 08, $45564157 ); // WAVE
	//
	SetWaveDataHeader ( 12, $20746d66 ); // fmt-
	SetWaveDataHeader ( 16, $10 ); // size of format chunk
	SetWaveDataHeader ( 20, $10001 );
	SetWaveDataHeader ( 24, iWaveSampleRate );
	SetWaveDataHeader ( 28, iWaveSampleRate );
	SetWaveDataHeader ( 32, ( ( iWaveBits * 8 ) Shl 16 ) Or iWaveBits );
	//
	SetWaveDataHeader ( 36, $61746164 ); //'DATA'
	SetWaveDataHeader ( 40, iWaveDataLength );
End;

procedure TFormMain.WaveEditSampleRateChange(Sender: TObject);
Begin
	If WaveEditSampleRate.Tag = 0 Then
	Begin
		Modified ( True );
		//
		iWaveSampleRate := SafeVal ( WaveEditSampleRate.Text );
		//
		SetWaveDataHeader ( 24, iWaveSampleRate );
		SetWaveDataHeader ( 28, iWaveSampleRate );
	End;
end;

Function TFormMain.WaveSave : Boolean;
Begin
	If ( iWaveChannels = 1 ) And ( iWaveBits = 1 ) Then
	Begin
		Starting;
		//
		fOpenTemp;
		//
		SendWord ( fo, 3 );
		SendWord ( fo, iWaveSampleRate );
		SendWord ( fo, iWaveDataLength );
		SendWord ( fo, 0 ); // bits?
		//
		BlockWrite ( fo, WaveData^.Bytes [ 44 ], iWaveDataLength );
		//
		CloseFile ( fo );
		//
		ReplaceFile ( iSel, sTempFile, True, True );
		//
		Modified ( False );
		UpdateModifiedDate;
		//
		Finished;
		//
		WaveSave := True;
	End
	Else
	Begin
		MessageDlg ( 'Only 8 bit mono wave files' + #13 +
			'can be saved as Doom Format', mtInformation, [mbOK], 0 );
		//
		WaveSave := False;
	End;
End;

procedure TFormMain.mnuWaveSaveClick(Sender: TObject);
Begin
	WaveSave;
end;

procedure TFormMain.mnuWavePlayClick(Sender: TObject);
Begin
	// Play it from memory as WAV
	PlaySound ( PChar ( WaveData ), 0, SND_MEMORY + SND_ASYNC );
end;

procedure TFormMain.mnuWaveStopClick(Sender: TObject);
begin
	PlaySound ( Nil, 0, SND_MEMORY );
end;

procedure TFormMain.WaveEditKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	Case Key Of
		80 :
		Begin
			Status ( 'Play' );
			mnuWavePlayClick ( Sender );
		End;
		//
		87 :
		Begin
			WaveFreeMem;
			iWaveDataLength := SafeVal ( InputBox ( 'New Length', 'Enter New Length', '0' ) );
			WaveGetMem ( iWaveDataLength );
			WaveEditorUpdateHeader;
			WaveEditorRefresh;
		End;
		//
		Else
		Begin
			Status ( 'KeyDown ' + IntToStr ( Key ) );
			FormKeyDown ( Sender, Key, Shift );
		End;
	End;
end;

procedure TFormMain.WaveEditKeyPress(Sender: TObject; var Key: Char);
begin
	Key := #0;
end;

procedure TFormMain.PanelWaveImageMouseDown(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
	y0, zoom : Integer;
begin
	bWaveEditorDrawing := True;
	//
	Zoom := PanelWaveUpDownZoom.Position;
	If Zoom < 1 Then Zoom := 1;
	X := X * Zoom + Round ( ( iWaveLen / WaveScroll.Max ) * WaveScroll.Position );
	//
	y0 := Y - iWaveEditor_y;
	If y0 < 0 Then y0 := 0;
	If y0 > 255 Then y0 := 255;
	//
	If X < iWaveDataSize Then
	Begin
		WaveData^.Bytes [ 44 + X ] := y0;
		//
		WaveEditorRefresh;
		Modified ( True );
	End;
	//
	iWaveLastX := X;
	iWaveLastY := y0;
	//
end;

procedure TFormMain.PanelWaveImageMouseMove(Sender: TObject;
	Shift: TShiftState; X, Y: Integer);
Var
	y0, i, Zoom : Integer;
begin
	If bWaveEditorDrawing Then
	Begin
		Zoom := PanelWaveUpDownZoom.Position;
		If Zoom < 1 Then Zoom := 1;
		X := X * Zoom + Round ( ( iWaveLen / WaveScroll.Max ) * WaveScroll.Position );
		//
		y0 := Y - iWaveEditor_y;
		If y0 < 0 Then y0 := 0;
		If y0 > 255 Then y0 := 255;
		//
		If iWaveLastX > X Then
		Begin
			For i := iWaveLastX DownTo X Do
			Begin
				WaveData^.Bytes [ 44 + i ] := y0;
			End;
		End
		Else
		Begin
			For i := iWaveLastX To X Do
			Begin
				WaveData^.Bytes [ 44 + i ] := y0;
			End;
		End;
		//
		iWaveLastX := X;
		iWaveLastY := y0;
		//
		WaveEditorRefresh;
		Modified ( True );
	End;
end;

procedure TFormMain.PanelWaveImageMouseUp(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	bWaveEditorDrawing := False;
end;

// ###########################################################################
// !Palette Editor
//

Function TFormMain.PaletteSave : Boolean;
Var
	i1, i2, i3 : Integer;
Begin
	Starting;
	//
	fOpenTemp;
	//
	For i1 := 0 To nPalette Do
	Begin
		For i2 := 0 To 255 Do
		Begin
			For i3 := 0 To 2 Do
			Begin
				SendByte ( fo, Palette [ i1, i2, i3 ] );
			End;
		End;
	End;
	//
	CloseFile ( fo );
	//
	ReplaceFile ( iSel, sTempFile, True, True );
	//
	Modified ( False );
	UpdateModifiedDate;
	Finished;
	//
	PaletteReady := False;
	//
	PaletteSave := True;
end;

procedure TFormMain.mnuPaletteSaveClick(Sender: TObject);
Begin
	PaletteSave;
End;

procedure TFormMain.mnuPaletteSaveAsClick(Sender: TObject);
Var
	sFN : String;
	i2, i3 : Integer;
begin
	//
	sFN := ExportFileName ( iSel, '.act', True );
	sFN := ExportGetFileName ( sFN, 'ACT Files (*.act)|*.ACT', 'act' );
	//
	If sFN <> '' Then
	Begin
		//
		Starting;
		//
		AssignFile ( fo, sFN );
		FileMode := fmOpenReadWrite;
		ReWrite ( fo, 1 );
		//
		For i2 := 0 To 255 Do
		Begin
			For i3 := 0 To 2 Do
			Begin
				SendByte ( fo, Palette [ iPalette, i2, i3 ] );
			End;
		End;
		//
		CloseFile ( fo );
		//
		//Modified ( False ); // still needs to be saved in file
		Finished;
		//
		PaletteReady := False;
	End;
	//
end;

procedure TFormMain.mnuPaletteUseClick(Sender: TObject);
Var
	i, n : Integer;
Begin
	PreparePalette;
	//
	n := nPaletteColors;
	if n > 256 Then n := 256;
	//
	// --- EOB3: some images need the colors on both 7 & 8 line
	//
	If n = 32 Then
	Begin
		For i := 0 To n - 1 Do
		Begin
			Pal [ 256 - 32 - n + i ] := Palette [ iPalette, i, 2 ] Shl 16 +
				Palette [ iPalette, i, 1 ] Shl 8 +
				Palette [ iPalette, i, 0 ];
		End;
	End;
	//
	// Copy colors to end of palette
	//
	For i := 0 To n - 1 Do
	Begin
		Pal [ 256 - n + i ] := Palette [ iPalette, i, 2 ] Shl 16 +
			Palette [ iPalette, i, 1 ] Shl 8 +
			Palette [ iPalette, i, 0 ];
	End;
	//
	iPreferredPal := -2; // custom!
	PaletteReady := True;
end;

Function TFormMain.PaletteGetZoom : Integer;
Var
	Zoom : Integer;
Begin
	Zoom := UpDownPaletteZoom.Position * 4;
	If chkPaletteGrid.Checked Then
		Inc ( Zoom, 2 );
	//
	PaletteGetZoom := Zoom;
End;

Procedure TFormMain.PaletteRefreshColor ( iPal, iCol : Integer );
Var
	Zoom, Pad, Size, x, y : Integer;
Begin
	Zoom := UpDownPaletteZoom.Position * 4;
	Size := Zoom;
	Pad := 0;
	If chkPaletteGrid.Checked Then
	Begin
		Inc ( Zoom, 2 );
		Inc ( Pad );
	End;
	//
	x := Palette_xPos + ( iCol And 31 ) * Zoom + Pad;
	y := Palette_yPos + ( iCol Shr 5 ) * Zoom + Pad;
	//
	With ImagePalette Do
	Begin
		Canvas.Brush.Color :=	PaletteToRGB ( iPal, iCol );
		Canvas.FillRect ( Classes.Rect ( x, y, x + Size, y + Size ) );
		//
		// Check selection
		//
		If ( iPal = 0 ) Then
		Begin
			If PaletteSel [ iCol ] Then
			Begin
				Canvas.Brush.Color :=	PaletteSelectionColor ( iPal, iCol );
				Canvas.FrameRect ( Classes.Rect ( x + 1, y + 1, x + Size - 1, y + Size - 1 ) );
			End;
		End;
	End;
End;

Procedure TFormMain.PaletteRefresh;
Var
	Zoom : Integer;
	iPal, iColor : Integer;
Begin
	Starting;
	//
	If PanelPalette.Tag = 0 Then
	Begin
		PanelPalette.Visible := True;
		ImagePalette.Refresh;
		//
		ImagePalette.Picture.Bitmap.Width := ImagePalette.Width;
		ImagePalette.Picture.Bitmap.Height := ImagePalette.Height;
		//
		PanelPalette.Tag := 1;
	End;
	//
	Zoom := PaletteGetZoom;
	//
	With ImagePalette Do
	Begin
		Canvas.Brush.Color := clBlack;
		Canvas.FillRect ( Canvas.ClipRect );
		//
		For iPal := 0 To ( ImagePalette.Height Div ( 8 * Zoom + 4 ) ) Do
		Begin
			//
			If iPal + iPalette <= nPalette Then
			Begin
				Palette_yPos := 4 + iPal * ( 8 * Zoom + 4 );
				Palette_xPos := 4;
				//
				Canvas.Brush.Color := clWhite;
				Canvas.FrameRect ( Classes.Rect ( Palette_xPos - 1, Palette_yPos - 1,
					Palette_xPos + 32 * Zoom + 1, Palette_yPos + 8 * Zoom + 1 ) );
				//
				For iColor := 0 To 255 Do
				Begin
					PaletteRefreshColor ( iPal + iPalette, iColor );
				End;
			End;
		End;
		//
	End;
	//
	Palette_yPos := 4;
	Palette_xPos := 4;
	//
	PaletteCursor ( True );
	//
	ShowPage ( edPalette );
	//
	Finished;
End;

Procedure TFormMain.PaletteCursor ( bShow : Boolean );
Var
	Zoom : Integer;
	x, y : Integer;
	iColor : Integer;
	h, s, l : Double;
	sPalName : String;
Begin
	With ImagePalette.Canvas Do
	Begin
		//
		Zoom := PaletteGetZoom;
		//
		iColor := Palette_y * 32 + Palette_x;
		//
		x := 4 + Palette_x * Zoom;
		y := 4 + Palette_y * Zoom;
		//
		If bShow Then
		Begin
			Pen.Color := PaletteSelectionColor ( iPalette, iColor );
			//
			MoveTo ( x, y );
			LineTo ( x + Zoom - 1, y );
			LineTo ( x + Zoom - 1, y + Zoom - 1 );
			LineTo ( x, y + Zoom - 1 );
			LineTo ( x, y );
			//
			If bShow Then
			Begin
				sPalName := 'Palette: ' + IntToStr ( iPalette );
				If iPalette = 0 Then
					sPalName := sPalName + ' (Normal)'
				Else If ( iPalette >= 1 ) And ( iPalette <= 9 ) Then
					sPalName := sPalName + ' (Hurt)'
				Else If ( iPalette >= 10 ) And ( iPalette <= 12 ) Then
					sPalName := sPalName + ' (Pickup)'
				Else If ( iPalette = 13 ) Then
					sPalName := sPalName + ' (RadSuit)';

				PaletteLabelColor.Caption := 'Index: ' + Zero ( iColor, 3 ) + ' [$' + IntToHex ( iColor, 2 ) + '] ' + sPalName;
				//
				PaletteEditR.Text := Comma ( Palette [ iPalette, iColor, 0 ] );
				PaletteEditG.Text := Comma ( Palette [ iPalette, iColor, 1 ] );
				PaletteEditB.Text := Comma ( Palette [ iPalette, iColor, 2 ] );
				//
				RGBtoHSL (
					Palette [ iPalette, iColor, 0 ],
					Palette [ iPalette, iColor, 1 ],
					Palette [ iPalette, iColor, 2 ], h, s, l );
				//
				PaletteEditH.Text := FloatToStr ( h );
				PaletteEditS.Text := FloatToStr ( s );
				PaletteEditL.Text := FloatToStr ( l );
			End;
		End
		Else
		Begin
			If chkPaletteGrid.Checked Then
			Begin
				Pen.Color := clBlack;
				//
				MoveTo ( x, y );
				LineTo ( x + Zoom - 1, y );
				LineTo ( x + Zoom - 1, y + Zoom - 1 );
				LineTo ( x, y + Zoom - 1 );
				LineTo ( x, y );
			End;
			//
			PaletteRefreshColor ( iPalette, iColor );
		End;
	End;
End;

Function TFormMain.PaletteToRGB ( iPal, iCol : Integer ) : Integer;
Begin
	PaletteToRGB :=
		( Palette [ iPal, iCol, 2 ] Shl 16 ) Or
		( Palette [ iPal, iCol, 1 ] Shl 8 ) Or
		( Palette [ iPal, iCol, 0 ] );
End;

Function TFormMain.PaletteSelectionColor ( iPal, iCol : Integer ) : Integer;
Begin
	If ( ( Palette [ iPal, iCol, 0 ] > 127 )
	Or ( Palette [ iPal, iCol, 1 ] > 127 )
	Or ( Palette [ iPal, iCol, 2 ] > 127 ) )
	And Not chkPaletteGrid.Checked Then
		PaletteSelectionColor := clBlack
	Else
		PaletteSelectionColor := clWhite;
End;

Procedure TFormMain.PaletteGetCoords ( Var x, y : Integer );
Var
	Zoom : Integer;
Begin
	Zoom := PaletteGetZoom;
	//
	Palette_xPos := 4;
	Palette_yPos := 4;
	//
	x := ( x - Palette_xPos ) Div Zoom;
	y := ( y - Palette_yPos ) Div Zoom;
End;

procedure TFormMain.mnuPaletteGradientClick(Sender: TObject);
Var
	i, iCnt, iSel : Integer; // for selection
	iFirst, iLast : Integer;
	//
	r0, g0, b0 : Integer; // for RGB grad
	r1, g1, b1 : Integer;
	//
	//h, s, l0, l1 : Double; // for HSL grad
	//rd, gd, bd : Double;
	//
	f : TFormRGBValue;
Begin
	//
	iFirst := 0;
	iLast := 0;
	//
	iSel := 0;
	For i := 0 To 255 Do
	Begin
		If PaletteSel [ i ] Then
		Begin
			If iSel = 0 Then
			Begin
				iFirst := i;
			End;
			Inc ( iSel );
			iLast := i;
		End;
	End;
	//
	If ( iSel = 0 ) Then
	Begin
		MessageDlg ( 'No colors selected.', mtWarning, [mbOK], 0 );
	End
	Else
	Begin
		//If ( MessageDlg ( 'Yes = RGB gradient' + #13 + 'No = HSL gradient', mtConfirmation, [mbYes,mbNo], 0 ) = mrYes ) Then
		//Begin
			//
			r0 := Palette [ iPalette, iFirst, 0 ];
			g0 := Palette [ iPalette, iFirst, 1 ];
			b0 := Palette [ iPalette, iFirst, 2 ];
			//
			r1 := Palette [ iPalette, iLast, 0 ];
			g1 := Palette [ iPalette, iLast, 1 ];
			b1 := Palette [ iPalette, iLast, 2 ];
			//
			(*
			r0 := SafeVal ( InputBox ( 'Start R Component Value', 'Enter Start R (of RGB)', IntToStr ( Palette [ iPalette, iFirst, 0 ] ) ) );
			g0 := SafeVal ( InputBox ( 'Start G Component Value', 'Enter Start G (of RGB)', IntToStr ( Palette [ iPalette, iFirst, 1 ] ) ) );
			b0 := SafeVal ( InputBox ( 'Start B Component Value', 'Enter Start B (of RGB)', IntToStr ( Palette [ iPalette, iFirst, 2 ] ) ) );
			//
			r1 := SafeVal ( InputBox ( 'End R Component Value', 'Enter End R (of RGB)', IntToStr ( Palette [ iPalette, iLast, 0 ] ) ) );
			g1 := SafeVal ( InputBox ( 'End G Component Value', 'Enter End G (of RGB)', IntToStr ( Palette [ iPalette, iLast, 1 ] ) ) );
			b1 := SafeVal ( InputBox ( 'End B Component Value', 'Enter End B (of RGB)', IntToStr ( Palette [ iPalette, iLast, 2 ] ) ) );
			*)
			//
			f := TFormRGBValue.Create ( Self );
			f.SetFormMode ( RGBValueGradient, iSel );
			f.SetStartRGB ( r0, g0, b0 );
			f.SetEndRGB ( r1, g1, b1 );
			f.ShowModal;
			//
			r0 := f.tbStartR.Position;
			g0 := f.tbStartG.Position;
			b0 := f.tbStartB.Position;
			//
			r1 := f.tbEndR.Position;
			g1 := f.tbEndG.Position;
			b1 := f.tbEndB.Position;
			//
			f.Free;
			//
			Dec ( iSel );
			iCnt := 0;
			For i := 0 To 255 Do
			Begin
				If PaletteSel [ i ] Then
				Begin
					Palette [ iPalette, i, 0 ] := r0 + Round ( ( r1 - r0 ) / iSel * iCnt );
					Palette [ iPalette, i, 1 ] := g0 + Round ( ( g1 - g0 ) / iSel * iCnt );
					Palette [ iPalette, i, 2 ] := b0 + Round ( ( b1 - b0 ) / iSel * iCnt );
					Inc ( iCnt );
				End;
			End;
		(*
		End
		Else
		Begin
			//
			rd := Palette [ iPalette, iFirst, 0 ];
			gd := Palette [ iPalette, iFirst, 1 ];
			bd := Palette [ iPalette, iFirst, 2 ];
			//
			RGBtoHSL ( rd, gd, bd, h, s, l0 );
			//
			h := StrToFloat ( InputBox ( 'Hue', 'Enter Hue (0-1)', FloatToStr ( h ) ) );
			s := StrToFloat ( InputBox ( 'Saturation', 'Enter Saturation (0-1)', FloatToStr ( s ) ) );
			l0 := StrToFloat ( InputBox ( 'Start Luminance', 'Enter Start Luminance (0-1)', FloatToStr ( l0 ) ) );
			l1 := StrToFloat ( InputBox ( 'End Luminance', 'Enter End Luminance (0-1)', '0' ) );
			//
			Dec ( iSel );
			iCnt := 0;
			For i := 0 To 255 Do
			Begin
				If PaletteSel [ i ] Then
				Begin
					//
					HSLtoRGB ( h, s, l0 + ( l1 - l0 ) / iSel * iCnt, rd, gd, bd );
					//
					Palette [ iPalette, i, 0 ] := Round ( rd );
					Palette [ iPalette, i, 1 ] := Round ( gd );
					Palette [ iPalette, i, 2 ] := Round ( bd );
					Inc ( iCnt );
				End;
			End;
		End;
		*)
		//
		PaletteRefresh;
		//
		Modified ( True );
	End;
	PaletteEdit.SetFocus;
end;

procedure TFormMain.ImagePaletteDblClick(Sender: TObject);
Var
	iColor : Integer;
	r0, g0, b0 : Integer;
Begin
	iColor := Palette_y * 32 + Palette_x;
	//
	r0 := Palette [ iPalette, iColor, 0 ];
	g0 := Palette [ iPalette, iColor, 1 ];
	b0 := Palette [ iPalette, iColor, 2 ];
	//
	r0 := SafeVal ( InputBox ( 'Edit Color', 'Enter R Value', IntToStr ( r0 ) ) );
	g0 := SafeVal ( InputBox ( 'Edit Color', 'Enter G Value', IntToStr ( g0 ) ) );
	b0 := SafeVal ( InputBox ( 'Edit Color', 'Enter B Value', IntToStr ( b0 ) ) );
	//
	Palette [ iPalette, iColor, 0 ] := r0;
	Palette [ iPalette, iColor, 1 ] := g0;
	Palette [ iPalette, iColor, 2 ] := b0;
	//
	PaletteRefresh;
	PaletteEdit.SetFocus;
	Modified ( True );
end;

procedure TFormMain.mnuPaletteRadSuitEffectClick(Sender: TObject);
Var
	f : TFormRGBValue;
	iPal, iCol : Integer;
	r0, g0, b0 : Integer;
	r, g, b : Integer;
begin
	f := TFormRGBValue.Create ( Self );
	f.SetFormMode ( RGBValueMix, 0 );
	f.SetStartRGB ( 0, 255, 0 );
	f.ShowModal;
	//
	r0 := f.tbStartR.Position;
	g0 := f.tbStartG.Position;
	b0 := f.tbStartB.Position;
	//
	f.Free;
	//
	If nPalette < 13 Then
	Begin
		nPalette := 13;
		PaletteScroll.Max := nPalette;
	End;
	//
	For iPal := 13 To 13 Do
	Begin
		For iCol := 0 To 255 Do
		Begin
			r := Palette [ 0, iCol, 0 ];
			g := Palette [ 0, iCol, 1 ];
			b := Palette [ 0, iCol, 2 ];
			//
			r := r + Round ( ( r0 - r ) * 0.5 );
			g := g + Round ( ( g0 - g ) * 0.5 );
			b := b + Round ( ( b0 - b ) * 0.5 );
			//
			Palette [ iPal, iCol, 0 ] := r;
			Palette [ iPal, iCol, 1 ] := g;
			Palette [ iPal, iCol, 2 ] := b;
		End;
	End;
	//
	PaletteRefresh;
	PaletteEdit.SetFocus;
	Modified ( True );
end;

procedure TFormMain.mnuPalettePickupEffectClick(Sender: TObject);
Var
	f : TFormRGBValue;
	iPal, iCol : Integer;
	r0, g0, b0 : Integer;
	r, g, b : Integer;
begin
	f := TFormRGBValue.Create ( Self );
	f.SetFormMode ( RGBValueMix, 0 );
	f.SetStartRGB ( 255, 255, 0 );
	f.ShowModal;
	//
	r0 := f.tbStartR.Position;
	g0 := f.tbStartG.Position;
	b0 := f.tbStartB.Position;
	//
	f.Free;
	//
	If nPalette < 12 Then
	Begin
		nPalette := 12;
		PaletteScroll.Max := nPalette;
	End;
	//
	For iPal := 1 To 3 Do
	Begin
		For iCol := 0 To 255 Do
		Begin
			r := Palette [ 0, iCol, 0 ];
			g := Palette [ 0, iCol, 1 ];
			b := Palette [ 0, iCol, 2 ];
			//
			r := r + Round ( ( r0 - r ) * ( iPal / 4 ) );
			g := g + Round ( ( g0 - g ) * ( iPal / 4 ) );
			b := b + Round ( ( b0 - b ) * ( iPal / 4 ) );
			//
			Palette [ iPal + 9, iCol, 0 ] := r;
			Palette [ iPal + 9, iCol, 1 ] := g;
			Palette [ iPal + 9, iCol, 2 ] := b;
		End;
	End;
	//
	PaletteRefresh;
	PaletteEdit.SetFocus;
	Modified ( True );
end;

procedure TFormMain.mnuPaletteDamageEffectClick(Sender: TObject);
Var
	f : TFormRGBValue;
	iPal, iCol : Integer;
	r0, g0, b0 : Integer;
	r, g, b : Integer;
Begin
	f := TFormRGBValue.Create ( Self );
	f.SetFormMode ( RGBValueMix, 0 );
	f.SetStartRGB ( 255, 0, 0 );
	f.ShowModal;
	//
	r0 := f.tbStartR.Position;
	g0 := f.tbStartG.Position;
	b0 := f.tbStartB.Position;
	//
	f.Free;
	//
	If nPalette < 9 Then
	Begin
		nPalette := 9;
		PaletteScroll.Max := nPalette;
	End;
	//
	For iPal := 1 To 9 Do
	Begin
		For iCol := 0 To 255 Do
		Begin
			r := Palette [ 0, iCol, 0 ];
			g := Palette [ 0, iCol, 1 ];
			b := Palette [ 0, iCol, 2 ];
			//
			r := r + Round ( ( r0 - r ) * ( iPal / 9 ) );
			g := g + Round ( ( g0 - g ) * ( iPal / 9 ) );
			b := b + Round ( ( b0 - b ) * ( iPal / 9 ) );
			//
			Palette [ iPal, iCol, 0 ] := r;
			Palette [ iPal, iCol, 1 ] := g;
			Palette [ iPal, iCol, 2 ] := b;
		End;
	End;
	//
	PaletteRefresh;
	PaletteEdit.SetFocus;
	Modified ( True );
end;

procedure TFormMain.mnuPaletteArrangeClick(Sender: TObject);
Var
	i, iCheck : Integer;
	iBest : Integer;
	iDiff, iBestDiff : Integer;
	iDoomPal : Integer;
	Used : Array [ 0 .. 255 ] Of Boolean;
	NewPos : Array [ 0 .. 255 ] Of Byte;
	CopyPal : Array [ 0 .. 255, 0 .. 2 ] Of Byte;
	r, g, b : Byte;
Begin
	//
	iDoomPal := FindPal ( 'DOOM' );
	//
	For i := 0 To 255 Do
	Begin
		Used [ i ] := False;
	End;
	//
	For i := 0 To 255 Do
	Begin
		//
		r := Pals [ iDoomPal ].Pal [ i, 0 ];
		g := Pals [ iDoomPal ].Pal [ i, 1 ];
		b := Pals [ iDoomPal ].Pal [ i, 2 ];
		//
		iBest := 0;
		iBestDiff := 1000000;
		//
		For iCheck := 0 To 255 Do
		Begin
			If Not Used [ iCheck ] Then
			Begin
				//
				iDiff := Abs ( Palette [ 0, iCheck, 0 ] - r ) +
					Abs ( Palette [ 0, iCheck, 1 ] - g ) +
					Abs ( Palette [ 0, iCheck, 2 ] - b );
				//
				if iDiff < iBestDiff Then
				Begin
					iBestDiff := iDiff;
					iBest := iCheck
				End;
				//
			End;
		End;
		//
		Used [ iBest ] := True;
		NewPos [ iBest ] := i;
	End;
	//
	For i := 0 To 255 Do
	Begin
		CopyPal [ i, 0 ] := Palette [ 0, i, 0 ];
		CopyPal [ i, 1 ] := Palette [ 0, i, 1 ];
		CopyPal [ i, 2 ] := Palette [ 0, i, 2 ];
	End;
	//
	For i := 0 To 255 Do
	Begin
		Palette [ 0, NewPos [ i ], 0 ] := CopyPal [ i, 0 ];
		Palette [ 0, NewPos [ i ], 1 ] := CopyPal [ i, 1 ];
		Palette [ 0, NewPos [ i ], 2 ] := CopyPal [ i, 2 ];
	End;
	//
	Modified ( True );
	//
	PaletteRefresh;
	PaletteEdit.SetFocus;
end;

procedure TFormMain.PaletteSelectAll ( bSelect : Boolean );
Var
	i : Integer;
Begin
	For i := 0 To 255 Do
	Begin
		PaletteSel [ i ] := bSelect;
	End;
End;

procedure TFormMain.ImagePaletteMouseMove(Sender: TObject;
	Shift: TShiftState; X, Y: Integer);
Var
	iColor : Integer;
Begin
	ImagePalette.ShowHint := False;
	ImagePalette.Hint := '';
	Application.ProcessMessages;
	//
	PaletteGetCoords ( X, Y );
	//
	iColor := X + Y * 32;
	//
	If iColor < 256 Then
	Begin
		ImagePalette.ShowHint := True;
		ImagePalette.Hint := IntToHex ( Palette [ 0, iColor, 0 ], 2 ) + ' ' +
			IntToHex ( Palette [ 0, iColor, 1 ], 2 ) + ' ' +
			IntToHex ( Palette [ 0, iColor, 2 ], 2 );
	End;
end;

procedure TFormMain.ImagePaletteMouseDown(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
	iColor : Integer;
Begin
	PaletteGetCoords ( X, Y );
	//
	iColor := X + Y * 32;
	//
	If iColor < 256 Then
	Begin
		PaletteBeforeCursorMove ( Shift );
		//
		Palette_x := x;
		Palette_y := y;
		//
		PaletteCursorMoved ( Shift );
	End
	Else
	Begin
		PanelPaletteRGB.Caption := '';
	End;
	//
	PaletteEdit.SetFocus;
end;

procedure TFormMain.chkPaletteGridClick(Sender: TObject);
Begin
	PaletteRefresh;
	PaletteEdit.SetFocus;
end;

procedure TFormMain.UpDownPaletteZoomClick(Sender: TObject;
	Button: TUDBtnType);
Begin
	PaletteRefresh;
	PaletteEdit.SetFocus;
end;

procedure TFormMain.PaletteEditKeyPress(Sender: TObject; Var Key: Char);
Begin
	Key := #0;
end;

Procedure TFormMain.PaletteBeforeCursorMove ( Shift : TShiftState );
Var
	iColor : Integer;
Begin
	//
	// --- Deselect all if not CTRL
	//
	If Not ( ssCtrl in Shift ) Then
	Begin
		//SelectRange ( False );
		For iColor := 0 To 255 Do
		Begin
			If PaletteSel [ iColor ] Then
			Begin
				PaletteSel [ iColor ] := False;
				PaletteRefreshColor ( iPalette, iColor );
			End;
		End;
	End;
	//
	// --- Hide cursor
	//
	PaletteCursor ( False );
End;

Procedure TFormMain.PaletteCursorMoved ( Shift : TShiftState );

Procedure SelectRange ( bSelect : Boolean );
Var
	x, y : Integer;
	x1, y1, x2, y2 : Integer;
Begin
	If Palette_x < Palette_xb Then
	Begin
		x1 := Palette_x;
		x2 := Palette_xb;
	End
	Else
	Begin
		x1 := Palette_xb;
		x2 := Palette_x;
	End;
	//
	If Palette_y < Palette_yb Then
	Begin
		y1 := Palette_y;
		y2 := Palette_yb;
	End
	Else
	Begin
		y1 := Palette_yb;
		y2 := Palette_y;
	End;
	//
	For y := y1 To y2 Do
	Begin
		For x := x1 To x2 Do
		Begin
			PaletteSel [ y * 32 + x ] := bSelect;
			PaletteRefreshColor ( iPalette, y * 32 + x );
		End;
	End;
End;

Begin
	If ssShift in Shift Then
	Begin
		SelectRange ( True );
	End
	Else
	Begin
		// move anchor
		Palette_xb := Palette_x;
		Palette_yb := Palette_y;
	End;
	//
	// --- Show cursor
	//
	PaletteCursor ( True );
End;

procedure TFormMain.PaletteEditKeyDown(Sender: TObject; Var Key: Word;
	Shift: TShiftState);
Var
	iColor : Integer;

Begin
	If PanelPalette.Tag = 0 Then
	Begin
		PaletteRefresh;
	End;
	//
	Case Key Of

		32 : { space }
		Begin
			iColor := Palette_y * 32 + Palette_x;
			PaletteSel [ iColor ] := Not PaletteSel [ iColor ];
			PaletteRefreshColor ( iPalette, iColor );
			PaletteCursor ( True );
		End;

		33 : { page up }
		Begin
			If ( iPalette > 0 ) Then
			Begin
				Dec ( iPalette );
				PaletteScroll.Position := iPalette;
			End;
		End;

		34 : { page down }
		Begin
			If ( iPalette < nPalette ) Then
			Begin
				Inc ( iPalette );
				PaletteScroll.Position := iPalette;
			End;
		End;

		37 : { cursor left }
		Begin
			If Palette_x > 0 Then
			Begin
				PaletteBeforeCursorMove ( Shift );
				Dec ( Palette_x );
				PaletteCursorMoved ( Shift );
			End;
		End;

		38 : { cursor up }
		Begin
			If Palette_y > 0 Then
			Begin
				PaletteBeforeCursorMove ( Shift );
				Dec ( Palette_y );
				PaletteCursorMoved ( Shift );
			End;
		End;

		39 : { cursor right }
		Begin
			If Palette_x < 31 Then
			Begin
				PaletteBeforeCursorMove ( Shift );
				Inc ( Palette_x );
				PaletteCursorMoved ( Shift );
			End;
		End;

		40 : { cursor down }
		Begin
			If Palette_y < 7 Then
			Begin
				PaletteBeforeCursorMove ( Shift );
				Inc ( Palette_y );
				PaletteCursorMoved ( Shift );
			End;
		End;

		71 : { G - gradient }
		Begin
			mnuPaletteGradientClick ( Self );
		End;

		Else
		Begin
			FormKeyDown ( Sender, Key, Shift );
			//Caption := Comma ( Key );
		End;

	End;
end;

procedure TFormMain.PaletteScrollChange(Sender: TObject);
Begin
	iPalette := PaletteScroll.Position;
	PaletteRefresh;
	PaletteEdit.SetFocus;
end;

Procedure TFormMain.PaletteEditor ( bFocus : Boolean );
Begin
	If fOpen ( sEditFile ) Then
	Begin
		PaletteLoad  ( cPos, cLen );
		fClose;
	End;
	//
	iPalette := 0;
	Palette_x := 0;
	Palette_y := 0;
	//
	PaletteScroll.Min := 0;
	PaletteScroll.Max := nPalette;
	//
	PaletteSelectAll ( False );
	//
	PaletteRefresh;
	//
	Modified ( False );
	//
	If bFocus Then
	Begin
		PaletteEdit.SetFocus;
	End;
End;

// --- --- --- ###############################################################

procedure TFormMain.mnuColorMapInvulnerabilityClick(Sender: TObject);
Var
	x, r, g, b : Integer;
	min, max : Integer;
begin
	min := SafeVal ( InputBox ( 'Build Invulnerability Map', 'Color range start:', '80' ) );
	max := SafeVal ( InputBox ( 'Build Invulnerability Map', 'Color range end:', '111' ) );
	//
	// --- Last line is inverse (for god mode effect)
	//
	For x := 0 To 255 Do
	Begin
		r := Pal [ x ] And 255;
		g := Pal [ x ] Shr 8 And 255;
		b := Pal [ x ] Shr 16 And 255;
		//
		r := Round ( r * 0.3 + g * 0.59 + b * 0.11 );
		//
		ColorMaps [ 32, x ] := min + Round ( ( max - min ) * ( r / 255 ) );
	End;
	//
	Modified ( True );
	//
	ColorMapRefresh;
end;

procedure TFormMain.mnuColormapRebuildSpClick(Sender: TObject);
Var
	iStart, iEnd, iUseStart, iUseEnd : Integer;
begin
	//
	iStart := SafeVal ( InputBox ( 'Rebuild ColorMap', 'Rebuild range: Start', '0' ) );
	iEnd := SafeVal ( InputBox ( 'Rebuild ColorMap', 'Rebuild range: End', '31' ) );
	//
	iUseStart := SafeVal ( InputBox ( 'Rebuild ColorMap', 'Use colors: Start', '0' ) );
	iUseEnd := SafeVal ( InputBox ( 'Rebuild ColorMap', 'Use colors: End', '31' ) );
	//
	ColormapRebuild ( iStart, iEnd, iUseStart, iUseEnd, 0, 0, 0, 32 );
	//
	Modified ( True );
	//
	ColorMapRefresh;
end;

procedure TFormMain.mnuColorMapRebuildClick(Sender: TObject);
Var
	i, x, y : Integer;
	r, g, b : Byte;
	r0, g0, b0 : Byte;
	Steps : Integer;
	//
	gBeg, gLen : Byte;
	GradBeg, GradLen : Array [ 0 .. 255 ] Of Byte;
Begin
	//
	gBeg := 0;
	gLen := 1;
	//
	x := 0;
	y := 12;
	//
	For i := 0 To 255 Do
	Begin
		r := Pal [ i ] And 255;
		g := Pal [ i ] Shr 8 And 255;
		b := Pal [ i ] Shr 16 And 255;
		//
		r0 := Pal [ i - 1 ] And 255;
		g0 := Pal [ i - 1 ] Shr 8 And 255;
		b0 := Pal [ i - 1 ] Shr 16 And 255;
		//
		ImageColorMap.Canvas.Brush.Color := Pal [ i ];
		ImageColorMap.Canvas.FillRect ( Classes.Rect ( x, y, x, y ) );
		//
		If ( Abs ( r - r0 ) <= 40 )
		And ( Abs ( g - g0 ) <= 40 )
		And ( Abs ( b - b0 ) <= 40 ) Then
		Begin
			//
			Inc ( gLen );
			GradBeg [ i ] := gBeg;
			//
			Inc ( x );
		End
		Else
		Begin
			While ( gBeg < i ) Do
			Begin
				GradLen [ gBeg ] := gLen;
				Inc ( gBeg );
			End;
			GradBeg [ i ] := gBeg;
			gLen := 1;
			//
			Inc ( y );
			x := 0;
		End;
		//
	End;
	//
	For i := 0 To 255 Do
	Begin
		GradBeg [ i ] := 0;
		GradLen [ i ] := 255;
	End;
	//
	nColorMaps := 34;
	//
	r0 := SafeVal ( InputBox ( 'Rebuild ColorMap', 'Enter R Value of Final RGB', '0' ) );
	g0 := SafeVal ( InputBox ( 'Rebuild ColorMap', 'Enter G Value of Final RGB', '0' ) );
	b0 := SafeVal ( InputBox ( 'Rebuild ColorMap', 'Enter B Value of Final RGB', '0' ) );
	//
	Steps := SafeVal ( InputBox ( 'Rebuild ColorMap', 'Reach final color in ... steps', '32' ) );
	//
	ColormapRebuild ( 0, 255, 0, 255, r0, g0, b0, Steps );
	//
	// --- Last line is inverse (for god mode effect)
	//
	For x := 0 To 255 Do
	Begin
		r := Pal [ x ] And 255;
		g := Pal [ x ] Shr 8 And 255;
		b := Pal [ x ] Shr 16 And 255;
		//
		r := 255 - Round ( r * 0.3 + g * 0.59 + b * 0.11 );
		//
		ColorMaps [ 32, x ] := ImagePaletteMatchRGB ( r, r, r );
	End;
	//
	Modified ( True );
	//
	ColorMapRefresh;
end;

procedure TFormMain.ColormapRebuild ( iStart, iEnd, iUseStart, iUseEnd : Integer; r0,g0,b0 : Byte; Steps : Integer );
Var
	x, y : Integer;
	d : Double;
	r, g, b : Byte;
	s1 : Integer;
Begin
	If ( iUseStart = 0 ) And ( iUseEnd = 255 ) Then
	begin
		//
		// --- First line is "normal"
		//
		For x := iStart To iEnd Do
		Begin
			ColorMaps [ 0, x ] := x;
		End;
		s1 := 1;
	End
	Else
	Begin
		s1 := 0;
	End;
	//
	// --- Build other 31 lines
	//
	For y := s1 To 32 - 1 Do
	Begin
		d := y / Steps;
		If d > 1 Then d := 1;
		//
		For x := iStart To iEnd Do
		Begin
			r := Pal [ x ] And 255;
			g := Pal [ x ] Shr 8 And 255;
			b := Pal [ x ] Shr 16 And 255;
			//
			r := r + Round ( ( r0 - r ) * d );
			g := g + Round ( ( g0 - g ) * d );
			b := b + Round ( ( b0 - b ) * d );
			//
			ColorMaps [ y, x ] := ImagePaletteMatchRGBRange ( r, g, b, iUseStart, iUseEnd );
		End;
	End;
End;

procedure TFormMain.mnuColorMapDisplayHorizontallyClick(Sender: TObject);
Begin
	mnuColorMapDisplayHorizontally.Checked := Not mnuColorMapDisplayHorizontally.Checked;
	ColorMapRefresh;
end;

procedure TFormMain.mnuColorMapDisplayGridClick(Sender: TObject);
Begin
	mnuColorMapDisplayGrid.Checked := Not mnuColorMapDisplayGrid.Checked;
	ColorMapRefresh;
end;

Procedure TFormMain.ColorMapRefresh;
Var
	x, y, iGrid : Integer;
Begin
	If PanelColorMap.Tag = 0 Then
	Begin
		PanelColorMap.Visible := True;
		ImageColorMap.Refresh;
		//
		ImageColorMap.Picture.Bitmap.Width := ImageColorMap.Width;
		ImageColorMap.Picture.Bitmap.Height := ImageColorMap.Height;
		//
		PanelColorMap.Tag := 1;
	End;
	//
	ImageColorMap.Canvas.Brush.Color := RGB ( 32, 64, 96 );
	ImageColorMap.Canvas.FillRect ( ImageColorMap.Canvas.ClipRect );
	//
	If mnuColorMapDisplayGrid.Checked Then
	Begin
		iGrid := 1;
	End
	Else
	Begin
		iGrid := 0;
	End;
	//
	For y := 0 To nColorMaps - 1 Do
	Begin
		For x := 0 To 255 Do
		Begin
			ImageColorMap.Canvas.Brush.Color := Pal [ ColorMaps [ y, x ] ];
			//
			If mnuColorMapDisplayHorizontally.Checked Then
			Begin
				ImageColorMap.Canvas.FillRect ( Classes.Rect (
						( ImageColorMap.Width * x ) Shr 8, y * 6,
						( ImageColorMap.Width * ( x + 1 ) ) Shr 8 - iGrid, y * 6 + 6 - iGrid ) );
			End
			Else
			Begin
				ImageColorMap.Canvas.FillRect ( Classes.Rect (
					y * 6, ( ImageColorMap.Height * x ) Shr 8,
					y * 6 + 6 - iGrid, ( ImageColorMap.Height * ( x + 1 ) ) Shr 8 - iGrid ) );
			End;
		End;
	End;
End;

Procedure TFormMain.ColorMapEditor;
Var
	iColorMap : Integer;
Begin
	Starting;
	//
	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( F, cPos );
	//
	nColorMaps := cLen Div 256;
	//
	For iColorMap := 0 To nColorMaps - 1 Do
	Begin
		BlockRead ( f, ColorMaps [ iColorMap, 0 ], 256 );
	End;
	//
	fClose;
	//
	PreparePalette;
	//
	ColorMapRefresh;
	//
	ShowPage ( edColorMap );
	//
	Modified ( False );
	//
	Finished;
End;

Function TFormMain.ColorMapSave : Boolean;
Var
	y : Integer;
Begin
	Starting;
	//
	fOpenTemp;
	//
	For y := 0 To nColorMaps - 1 Do
	Begin
		BlockWrite ( fo, ColorMaps [ y, 0 ], 256 );
	End;
	//
	CloseFile ( fo );
	//
	ReplaceFile ( iSel, sTempFile, True, True );
	//
	Modified ( False );
	UpdateModifiedDate;
	Finished;
	//
	ColorMapSave := True;
end;

procedure TFormMain.mnuColorMapSaveClick(Sender: TObject);
Begin
	ColorMapSave;
End;

// --- --- ---

Procedure TFormMain.DemoEditor;
Var
	b : Byte;
	sp, sx, sy, an : ShortInt;
	i : Integer;
	sec : Integer;
	s : String;
Begin
	Starting;
	//
	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( F, cPos );
	//
	MemoHex.Visible := False;
	MemoHex.Lines.Clear;
	//
	b := GetByte ( f );
	s := ConstantFindDescription ( 'DEMOVERSION', b );
	MemoHex.Lines.Add ( '- Version ' + s );
	//
	b := GetByte ( f );
	s := ConstantFindDescription ( 'SKILL', b );
	MemoHex.Lines.Add ( '- Skill ' + s );
	//
	b := GetByte ( f );
	MemoHex.Lines.Add ( '- Episode ' + IntToStr ( b + 1 ) );
	//
	b := GetByte ( f );
	MemoHex.Lines.Add ( '- Level ' + IntToStr ( b ) );
	//
	b := GetByte ( f );
	MemoHex.Lines.Add ( '- Multiplayer rule ' + IntToStr ( b ) );
	b := GetByte ( f );
	MemoHex.Lines.Add ( '- Respawn ' + IntToStr ( b ) );
	b := GetByte ( f );
	MemoHex.Lines.Add ( '- Fast ' + IntToStr ( b ) );
	b := GetByte ( f );
	MemoHex.Lines.Add ( '- NoMonsters ' + IntToStr ( b ) );
	//
	b := GetByte ( f );
	MemoHex.Lines.Add ( '- Which player''s point of view ' + IntToStr ( b ) );
	//
	b := GetByte ( f );
	If b = 0 Then s := 'No' Else s := 'Yes';
	MemoHex.Lines.Add ( '- Green Player ' + s );
	b := GetByte ( f );
	If b = 0 Then s := 'No' Else s := 'Yes';
	MemoHex.Lines.Add ( '- Indigo Player ' + s );
	b := GetByte ( f );
	If b = 0 Then s := 'No' Else s := 'Yes';
	MemoHex.Lines.Add ( '- Brown Player ' + s );
	b := GetByte ( f );
	If b = 0 Then s := 'No' Else s := 'Yes';
	MemoHex.Lines.Add ( '- Red Player ' + s );
	//
	i := 13;
	//
	MemoHex.Lines.Add ( Comma ( ( cLen - i - 1 ) Div 4 ) + ' entries' );
	MemoHex.Lines.Add ( '35 entries/second : ' + Comma ( ( ( cLen - i ) Div 4 ) Div 35 ) + ' seconds' );
	//
	if ( cLen > 500 ) Then cLen := 500; // cut it off to speed things up
	//
	sec := 0;
	While i < cLen Do
	Begin
		//
		If ( sec Mod 35 ) = 0 Then
		Begin
			MemoHex.Lines.Add ( '*********| ' + Comma ( sec Div 35 ) + ' seconds |*********' );
		End;

		// X-MOVE Y-MOVE ANGLE SPECIAL
		sx := GetByte ( f );
		//
		if Byte ( sx ) <> $80 Then
		Begin
			sy := GetByte ( f );
			an := GetByte ( f );
			sp := GetByte ( f );
			//
			Case sp Of

				0 : s := '--------';
				1 : s := '  Fire  ';
				2 : s := '  Use   ';
				4 : s := 'Weapon 1';
				$C : s := 'Weapon 2';
				$14 : s := 'Weapon 3';
				$1C : s := 'Weapon 4';
				$24 : s := 'Weapon 5';
				$2C : s := 'Weapon 6';
				$34 : s := 'Weapon 7';
				Else s := IntToHex ( sp, 1 );

			End;
			//
			s := s + ' | ';
			//
			if ( sx = 0 ) And ( sy = 0 ) Then
			Begin
				s := s + '---------';
			End
			Else
			Begin
				s := s + La ( Comma ( sx ), 4 ) + ',' + La ( Comma ( sy ), 4 );
			End;
			//
			s := s + ' | ';
			//
			If an = 0 Then
			Begin
				s := s + 'No turn';
			End
			Else
			Begin
				If an < 0 Then
					s := s + 'Turn right ' + IntToStr ( an )
				Else
					s := s + 'Turn left ' + IntToStr ( an );
			End;
			//
			MemoHex.Lines.Add ( s );
			//
			Inc ( i, 4 );
			Inc ( sec );
		End
		Else
		begin
			s := '[ EOF ]';
			MemoHex.Lines.Add ( s );
			//
			Inc ( i, 1 );
		End;
	End;
	//
	fClose;
	//
	MemoHex.Visible := True;
	ShowPage ( edHex );
	//
	Finished;
	Modified ( False );
End;

// ###########################################################################

Function TFormMain.ForceExtension ( s, sExt : String ) : String;
Begin
	//
	If PosR ( '.', s ) > 0 Then
	Begin
		s := Copy ( s, 1, PosR ( '.', s ) - 1 );
	End;
	//
	If UpperCase ( KeepFromRight ( s, Length ( sExt ) ) ) <> UpperCase ( sExt ) Then
	Begin
		s := s + sExt;
	End;
	//
	ForceExtension := s;
End;

// ###########################################################################
//
//

procedure TFormMain.SaveBMP ( iEntry : Integer; sFN : String );
Var
	xs, ys, xf, x, y : Integer;
	Color : Cardinal;
Begin
	If sFN = '' Then
	Begin
		sFN := ExportFileName ( iEntry, '.bmp', True );
		sFN := ExportGetFileName ( sFN, 'Bmp Files (*.bmp)|*.BMP', 'bmp' );
	End
	Else
	Begin
		sFN := ForceExtension ( sFN, '.bmp' );
	End;
	//
	If sFN <> '' Then
	Begin
		//
		Starting;
		//
		If ImageFormat = fmtDoom Then
		Begin
			xs := cImage.Width;
			ys := cImage.Height;
			//
			xf := xs; // x width, pad to 4 byte boundary
			While ( xf And 3 ) > 0 Do
				Inc ( xf );
			//
			// *** Save 8 bit BMP ***
			//
			AssignFile ( fo, sFN );
			FileMode := fmOpenReadWrite;
			ReWrite ( fo, 1 );
			//
			SendWord ( fo, $4D42 ); // "BM"
			SendLong ( fo, 54 + 256 * 4 + xf * ys ); // File Size
			SendLong ( fo, 0 );
			SendLong ( fo, 54 + 256 * 4 ); // bitmap start
			SendLong ( fo, 40 ); // Header size (minus prev bytes)
			SendLong ( fo, xs );
			SendLong ( fo, ys );
			SendWord ( fo, 1 ); // Planes
			SendWord ( fo, 8 ); // Bits per pixel
			SendLong ( fo, 0 ); // Compression mode
			SendLong ( fo, 0 ); // Image size in bytes
			//
			SendWord ( fo, Image_xr ); // x res -- store alignment!
			SendWord ( fo, Image_yr ); // --
			SendLong ( fo, $55555555 ); // y res
			//
			SendWord ( fo, $100 ); // Colors Used
			SendWord ( fo, 0 ); // ??
			SendLong ( fo, 0 );
			//
			// Use Cyan for transparency
			//
			Pal [ 247 ] := $FFFF00;
			//
			For x := 0 To 255 Do
			Begin
				SendByte ( fo, Pal [ x ] Shr 16 And 255 );
				SendByte ( fo, Pal [ x ] Shr 8 And 255 );
				SendByte ( fo, Pal [ x ] And 255 );
				SendByte ( fo, 0 );
			End;
			//
			For y := ys - 1 DownTo 0 Do
			Begin
				For x := 0 To xs - 1 Do
				Begin
					Color := cImage.Canvas.Pixels [ x, y ];
					SendByte ( fo, ImagePaletteMatch ( Color ) );
				End;
				//
				For x := xs + 1 To xf Do
				Begin
					SendByte ( fo, 0 );
				End;
			End;
			//
			CloseFile ( fo );
			//
			Pal [ 247 ] := 0;
			//
			// ---
			//
		End
		Else
		Begin
			// 24 or 32 bit...
			cImage.SaveToFile ( sFN );
		End;
		//
		Finished;
		//
	End;
End;

procedure TFormMain.SaveWav ( iEntry : Integer; sFN : String );
Begin
	If sFN = '' Then
	Begin
		sFN := ExportFileName ( iEntry, '.wav', True );
		sFN := ExportGetFileName ( sFN, 'Wav Files (*.wav)|*.WAV', 'wav' );
	End
	Else
	Begin
		sFN := ForceExtension ( sFN, '.wav' );
	End;
	//
	If sFN <> '' Then
	Begin
		//
		sLastFolderExport := Copy ( sFN, 1, PosR ( '\', sFN ) );
		//
		Starting;
		//
		AssignFile ( fo, sFN );
		FileMode := fmOpenReadWrite;
		ReWrite ( fo, 1 );
		//
		WaveLoad ( sEditFile, iEntry );
		BlockWrite ( fo, WaveData^.Bytes [ 0 ], iWaveDataLength + $44 );
		//
		CloseFile ( fo );
		//
		Finished;
		//
	End;
end;

Procedure TFormMain.SaveLmp ( iEntry : Integer; sFN, sExt : String );
Begin
	If sExt = '' Then
  Begin
  	sExt := '.lmp';
  End;
  //
	If sFN = '' Then
	Begin
		sFN := ExportFileName ( iEntry, sExt, False );
		sFN := ExportGetFileName ( sFN, UpperCase ( RemoveFromLeft ( sExt, 1 ) ) + ' Files (*' + sExt + ')|*' + sExt, RemoveFromLeft ( sExt, 1 ) );
	End
	Else
	Begin
		sFN := ForceExtension ( sFN, sExt );
	End;
	//
	If sFN <> '' Then
	Begin
		//
		Starting;
		//
		fOpen ( sEditFile );
		//
		Seek ( F, WadEntries [ iEntry ].Position );
		//
		AssignFile ( fo, sFN );
		FileMode := fmOpenReadWrite;
		ReWrite ( fo, 1 );
		//
		// ---------
		//
		CopyData ( f, fo, WadEntries [ iEntry ].Size );
		//
		fClose;
		CloseFile ( fo );
		//
		Finished;
		//
		sLastFolderExport := Copy ( sFN, 1, PosR ( '\', sFN ) );
	End;
End;

Function TFormMain.ExportFileName ( iEntry : Integer; sExt : String; bForce : Boolean ) : String;
Var
	s : String;
Begin
	s := RemoveFolder ( Trim ( WadEntries [ iEntry ].Name ) );
	//
	// --- remove invalid characters
	//
	s := Replace ( s, ':', '' );
	s := Replace ( s, '/', '' );
	s := Replace ( s, '\', '' );
	s := Replace ( s, '*', '' );
	s := Replace ( s, '?', '' );
	s := Replace ( s, '<', '' );
	s := Replace ( s, '>', '' );
	s := Replace ( s, '|', '' );
	s := Replace ( s, '"', '' );
	//
	If PosR ( '.', s ) = 0 Then
	Begin
		s := s + sExt;
	End
	Else
	Begin
		If bForce Then
		Begin
			s := Copy ( s, 1, PosR ( '.', s ) - 1 ) + sExt;
		End;
	End;
	//
	ExportFileName := s;
End;

Function TFormMain.ExportGetFileName ( sName, sFilter, sExt : String ) : String;
Begin
	SaveDialog1.InitialDir := sLastFolderExport;
	SaveDialog1.Title := 'Export';
	//
	SaveDialog1.FileName := sName;
	SaveDialog1.Filter := sFilter + '|All Files (*.*)|*.*';
	SaveDialog1.DefaultExt := sExt;
	//
	If SaveDialog1.Execute Then
	Begin
		ExportGetFileName := SaveDialog1.FileName;
	End
	Else
	Begin
		ExportGetFileName := '';
	End;
End;

Procedure TFormMain.ExtractEntry ( iEntry : Integer; sExt : String );
begin
	//
	// --- Export the current entry into a separate temp file
	//
	sTempFile := sTempFolder + '(xwe)(' + sUniqueID + ')(lump)' + RemoveFolder ( Trim ( WadEntries [ iEntry ].Name ) );
	If UpperCase ( KeepFromRight ( sTempFile, 4 ) ) <> sExt Then
	Begin
		sTempFile := sTempFile + sExt;
	End;
	//
	AssignFile ( fo, sTempFile );
	FileMode := fmOpenReadWrite;
	ReWrite ( fo, 1 );
	//
	fOpen ( sEditFile );
	Seek ( f, WadEntries [ iEntry ].Position );
	//
	CopyData ( f, fo, WadEntries [ iEntry ].Size );
	//
	fClose;
	CloseFile ( fo );
end;

Procedure TFormMain.ExportEntry ( iEntry : Integer; sFN : String; bRaw : Boolean );
Var
	s : String;
	iEntryType : Integer;
Begin
	iEntryType := WadEntries [ iEntry ].EntryType;
	//
	If iEntryType = 0 Then
		s := ''
	Else
		s := WadEntryTypes [ iEntryType ].ExportMethod;
	//
	If Not mnuEntryViewHex.Checked And Not bRaw And bWaveExportable And ( s = 'WAV' ) Then
	Begin
		SaveWav ( iEntry, sFN );
	End
	Else
	Begin
		// if view raw is NOT checked and it's an image...
		If Not mnuEntryViewHex.Checked And Not bRaw And ( ImageLoadEntry ( iEntry ) ) Then
		Begin
			// PNGs are saved as raw
			If ImageFormat = fmtPNG Then
			Begin
				SaveLmp ( iEntry, sFN, '.png' );
			End
			Else
			Begin
				// otherwise export as BMP
				SaveBmp ( iEntry, sFN );
			End;
		End
		Else
		Begin
			// save as raw lump
			SaveLmp ( iEntry, sFN, '' );
		End;
	End;
End;

Function TFormMain.ExportGetFolder : String;
Begin
	//
	// Ask for folder
	//
	SaveDialog1.InitialDir := sLastFolderExport;
	SaveDialog1.FileName := 'filename will be ignored';
	SaveDialog1.Title := 'Select Folder for Multiple Export';
	SaveDialog1.Filter := 'All Files (*.*)|*.*';
	//
	If SaveDialog1.Execute Then
	Begin
		//
		sLastFolderExport := Copy ( SaveDialog1.FileName, 1, PosR ( '\', SaveDialog1.FileName ) );
		ExportGetFolder := sLastFolderExport;
		//
	End
	Else
	Begin
		ExportGetFolder := '';
	End;
End;

procedure TFormMain.mnuEntrySaveAsClick(Sender: TObject);
begin
	ExportEntries ( False );
end;

procedure TFormMain.mnuEntrySaveAsRawClick(Sender: TObject);
begin
	ExportEntries ( True );
end;

procedure TFormMain.ExportEntries ( bRaw : Boolean );
Var
	i, sc, iEntry : Integer;
	s : String;
Begin
	sc := ListWad.SelCount;
	If sc > 0 Then
	Begin
		If sc = 1 Then
		Begin
			// let user specify the name
			ExportEntry ( EntryGetIndex ( ListWad.Selected.Index ), '', bRaw );
		End
		Else
		Begin
			//
			// Ask for folder
			//
			s := ExportGetFolder;
			//
			If s <> '' Then
			Begin
				//
				For i := 0 To ListWad.Items.Count - 1 Do
				Begin
					If ListWad.Items[i].Selected Then
					Begin
						iEntry := EntryGetIndex ( i );
						s := sLastFolderExport + ExportFileName ( iEntry, '', False );
						ExportEntry ( iEntry, s, bRaw );
					End;
				End;
			End;
		End;
	End;
end;

{
procedure TFormMain.BitBtn1Click(Sender: TObject);
Var
	sFileName : String;
Begin
	sFileName := 'e:\1.wav';
	MMSystem.sndPlaySound ( PChar ( sFileName ), SND_NODEFAULT );
end;
}

// ############################################################################
// MUSIC
//

Function TFormMain.MusicIdentify ( iPos, iLen : Integer ) : TMusicFormat;
Var
	T : TMusicFormat;
	HL1 : Cardinal;
Begin
	//
	T := mfmtNone;
	//
	If iLen > 4 Then
	Begin
		//
		HL1 := Cardinal ( GetLong ( f ) );
		//
		Case HL1 Of
			//
			$1A53554D : // MUS $1A: Doom MUS
			Begin
				T := mfmtDOOM;
			End;
			//
			$4D494D48 : // "HMIM"IDI: 'HM' format
			Begin
				T := mfmtHM;
			End;
			//
			$6468544D : // MTHd: Standard midi file
			Begin
				T := mfmtMIDI;
			End;
			//
			$4D504D49 : // IMPM: Impulse Tracker
			Begin
				T := mfmtIT;
			End;
			//
			Else
			Begin
				If iLen > $30 Then
				Begin
					fSeek ( f, iPos + $2C );
					HL1 := Cardinal ( GetLong ( f ) );
					//InputBox ( '','',IntToHex(HL1,8));
					//
					Case HL1 Of
						//
						$4D524353 : // SCRM: Scream Tracker
						Begin
							T := mfmtSCRM;
						End;
						//
					End;
					//
				End;
			End;
			//
		End;
		//
	End;
	//
	MusicIdentify := T;
End;

Function TFormMain.MusicIdentifyFile ( sFN : String; iPos, iLen : Integer ) : TMusicFormat;
Begin
	//
	If fOpenCount > 0 Then
	Begin
		Status ( 'WARNING: The file was still open (usually means last operation failed)' );
		//ShowMessage ( 'The file was still open.' );
		While fOpenCount > 0 Do
		Begin
			fClose;
		End;
	End;
	//
	If fOpen ( sFN ) Then
	Begin
		If fSeek ( f, iPos ) Then
		Begin
			MusicIdentifyFile := MusicIdentify ( iPos, iLen );
		End
		Else
		Begin
			MusicIdentifyFile := mfmtNone;
		End;
		//
		fClose;
	End
	Else
	Begin
		MusicIdentifyFile := mfmtNone;
	End;
End;

procedure TFormMain.mpMusicNotify(Sender: TObject);
begin
	Status ( 'MIDI playback ended' );
end;

procedure TFormMain.mnuMusicPlayClick(Sender: TObject);

Var
	sPath, sExec, sParam : String;
	header : Longint;

begin
	mpMusic.Close;
	//
	Case MusicFormat Of

		mfmtMIDI :
		Begin
			ExtractEntry ( iSel, '.MID' );
			//
			mpMusic.FileName := sTempFile;
			Try
				mpMusic.Open;
				mpMusic.Play;
				//
				Status ( 'MIDI playback started' );
			Except
				ShowMessage ( 'Media Player could not play this MIDI file.' );
			End;
			//
		End;

		mfmtDOOM :
		Begin
			//
			// Delete any old MUS file (if exists)
			//
			If FileExists ( sTempFolder + '(xwe)t.mus' ) Then
			Begin
				AssignFile ( fo, sTempFolder + '(xwe)t.mus' );
				Erase ( fo );
			End;
			//
			// *** Extract it
			//
			ExtractEntry ( iSel, '.MUS' );
			AssignFile ( fo, sTempFile );
			sTempFile := sTempFolder + '(xwe)t';
			Rename ( fo, sTempFile + '.mus' );
			//
			// *** Convert it
			//
			ToolsGet ( 'Mus2Midi Utility', 'MUS2MIDI.EXE', sPath, sExec, sParam );
			ExecAndWait ( sPath + sExec, '-T160 ' + sTempFile + '.mus ' + sTempFile + '.mid', SW_NORMAL );
			//
			mpMusic.FileName := sTempFile + '.MID';
			Try
				mpMusic.Open;
				mpMusic.Play;
				Status ( 'Playing...' );
			Except
				ShowMessage ( 'Media Player could not play the converted MIDI file.' + #13 + #13 +
					'Make sure you''re using MUS2MIDI version 1.0,' + #13 +
					'the older versions do not convert MIDIs properly.' );
			End;
			//
		End;

		Else
		Begin
			If Not fOpen ( sEditFile ) Then Exit;
			fSeek ( F, WadEntries [ iWadEntryCurrentIndex ].Position );
			header := GetLong ( f ); // Read 4 bytes
			fClose;
			//
			If ( ( header = $03334449 ) // ID3
				Or ( header = $0093FBFF ) // various MP3 headers
				Or ( header = $00C3F3FF )
				) Then
			Begin
				ExtractEntry ( iSel, '.MP3' );
				//
				mpMusic.FileName := sTempFile;
				Try
					mpMusic.Open;
					mpMusic.Play;
					//
					Status ( 'MP3 playback started' );
				Except
					ShowMessage ( 'Media Player could not play this file.' );
				End;
			End
			Else
			Begin
				Status ( 'Could not determine file type from header: ' + IntToHex ( header, 8 ) );
				ShowMessage ( 'Cannot play this file because the format is unknown.' + #13 +
					'Perhaps you can extract the entry and try playing it with an external player.' );
			End;
		End;

	End;
end;

procedure TFormMain.mnuMusicStopClick(Sender: TObject);
begin
	if mpMusic.Mode = mpPlaying Then
	Begin
		mpMusic.Stop;
		mpMusic.Close;
		//
		Status ( 'Stopped.' );
	End;
end;

procedure TFormMain.mnuMusicConvertMIDI2MUSClick(Sender: TObject);
Var
	sPath, sExec, sParam : String;
begin
	If MusicFormat = mfmtMIDI Then
	Begin
		mnuMusicStopClick ( Sender );
		//
		// *** Delete any old MUS or MID file (if exists)
		//
		If FileExists ( sTempFolder + '(xwe)c.mid' ) Then
		Begin
			AssignFile ( fo, sTempFolder + '(xwe)c.mid' );
			Erase ( fo );
		End;
		If FileExists ( sTempFolder + '(xwe)c.mus' ) Then
		Begin
			AssignFile ( fo, sTempFolder + '(xwe)c.mus' );
			Erase ( fo );
		End;
		//
		// *** Extract and rename lump
		//
		ExtractEntry ( iSel, '.MID' );
		AssignFile ( fo, sTempFile );
		sTempFile := sTempFolder + '(xwe)c';
		Rename ( fo, sTempFile + '.mid' );
		//
		// *** Convert it
		//
		ToolsGet ( 'Midi2Mus Utility', 'MIDI2MUS.EXE', sPath, sExec, sParam );
		ExecAndWait ( sPath + sExec, sTempFile + '.mid ', SW_NORMAL );
		//
		// *** Import it
		//
		Delay ( 250 );
		If FileExists ( sTempFile + '.mus' ) Then
		Begin
			ImportEntryFile ( iSel, sTempFile + '.mus', True, True );
			ShowEntry ( '', False );
			//
			Status ( 'Successfully converted MIDI to MUS.' );
		End
		Else
		Begin
			ShowMessage ( 'Conversion failed.' );
		End;
	End
	Else
	Begin
		ShowMessage ( 'Cannot convert this entry (not MIDI format).' );
	End;
end;

Procedure TFormMain.MusEditor;

function ByteToNote ( n : Byte ) : String;
Const
	Notes : Array [ 0 .. 11 ] Of String =
	(
		'C-', 'C#', 'D-', 'D#',
		'E-', 'F-', 'F#', 'G-',
		'G#', 'A-', 'A#', 'B-'
	);
Begin
	ByteToNote := Notes [ n Mod 12 ] + IntToStr ( n Div 12 );
End;

Function AdlibPortName ( b : Byte ) : String;
Var
	s : String;
Begin
	Case b Of
		$01 :
			s := 'Test LSI / Enable waveform control';

		$02 :
			s := 'Timer 1 data';

		$03 :
			s := 'Timer 2 data';

		$04 :
			s := 'Timer control flags';

		$08 :
			s := 'Speech synthesis mode / Keyboard split note select';

		$20,$21,$22,$23,$24,$25,
		$28,$29,$2A,$2B,$2C,$2D,
		$30,$31,$32,$33,$34,$35 :
			s := 'Amp Mod / Vibrato / EG type / Key Scaling / Multiple';

		$40,$41,$42,$43,$44,$45,
		$48,$49,$4A,$4B,$4C,$4D,
		$50,$51,$52,$53,$54,$55 :
			s := 'Key scaling level / Operator output level';

		$60,$61,$62,$63,$64,$65,
		$68,$69,$6A,$6B,$6C,$6D,
		$70,$71,$72,$73,$74,$75 :
			s := 'Attack Rate / Decay Rate';

		$80,$81,$82,$83,$84,$85,
		$88,$89,$8A,$8B,$8C,$8D,
		$90,$91,$92,$93,$94,$95 :
			s := 'Sustain Level / Release Rate';

		$A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7,$A8 :
			s := 'Frequency (low 8 bits)';

		$B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8 :
			s := 'Key On / Octave / Frequency (high 2 bits)';

		$BD :
			s := 'AM depth / Vibrato depth / Rhythm control';

		$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8 :
			s := 'Feedback strength / Connection type';

		$E0,$E1,$E2,$E3,$E4,$E5,
		$E8,$E9,$EA,$EB,$EC,$ED,
		$F0,$F1,$F2,$F3,$F4,$F5 :
			s := 'Wave Select';

		Else
			s := '### ERROR ###';
	End;
	//
	AdlibPortName := s;
End;

Var
	i, iRow, c : Integer;
	s : String;
	Event : Byte;
	Channel : Byte;
	b, v : Byte;
	iTime : Integer;
	w : Word;

	// --- Header
	h1, h2 : Word; // header (first 4 bytes)
	h3 : Cardinal;

	{scoreLen,
	scoreStart,}
	Channels,	// count of primary channels
	instrCnt : Word;

Procedure ClearGrid;
Var
	c : Integer;
Begin
	For c := 0 To MusGrid.ColCount Do
	Begin
		MusGrid.Cells [ c, 0 ] := '';
		MusGrid.Cells [ c, 1 ] := '';
	End;
End;

Procedure tDump ( s : String );
begin
	MusMemoIns.Lines.Add ( s );
End;

Procedure DumpS3M;
Var
	Name : String;
	i, c : Integer;
	//
	nOrders : Integer;
	nSamples : Integer;
	//
	Offset, Offs1 : Integer;
Begin
	fSeek ( f, cPos );
	Name := GetString ( f, $1D );
	c := 1;
	While ( c < $1D ) And ( Name [ c ] <> #0 ) Do Begin
		Inc ( c );
	End;
	//
	Name := Trim ( Name );
	If Name = '' Then
		Name := '(unnamed)';
	tDump ( 'Module name: ' + Name );

	{ clear for 16 bit }
	//Format := 0;
	If Byte ( GetByte ( f ) ) <> 16 Then
	Begin
		tDump ( 'Not S3M file.' );
	End
	Else
	Begin

		GetWord ( f ); { unknown bytes }

		nOrders := GetWord ( f );
		{{
		If ( nOrder And 1 ) = 1
		Then Begin
			// order numbers should be even!
			_Warning := True;
		End;
		}
		nSamples := GetWord ( f );

		GetWord ( f ); // nPatterns

		{ maybe we should check these above, }
		{ and give a warning if nonsense values are found. }

		GetWord ( f ); { Flags, not necessary }
		GetWord ( f ); { Created with tracker, not necessary }
		GetWord ( f ); { File format }

		{
		If c = 1
		Then Begin
			UnsignedSamples := False;
		End
		Else Begin
			If c <> 2
			Then Begin
				// This should be two
				_Warning := True;
			End;
		End;
		}

		{ id bytes }
		If GetString ( f, 4 ) <> 'SCRM' Then
		Begin
			tDump ( 'Not S3M file.' );
		End
		Else
		Begin

			GetByte ( f ); // GVol, 1 );
			GetByte ( f ); // iSpeed, 1 );
			GetByte ( f ); // iTempo, 1 );
			GetByte ( f ); // MVol, 1 );

			{ for compatibility }
			{
			Sep := 0;

			If MVol >= $80
			Then Begin
				OutputStyle := os_Stereo;
				MVol := MVol And $7F;
			End
			Else Begin
				OutputStyle := os_Mono;
			End;
			}

			{ in ST3.2 there are 2 info bytes }
			{ probably the new flags }

			//GrabBytes ( nothing [ 1 ], 12 );
			GetLong ( f );
			GetLong ( f );
			GetLong ( f );

			//
			//nChannels := 32;
			For i := 0 To 31 Do Begin
				GetByte ( f );
				{
				If ( c = 255 ) Or ( i = 31 )
				Then Begin
					With Channels [ i ] Do Begin
						On := False;
						Volume := 0;
						Panning := pan_Center;
						ChType := 0;
					End;
				End
				Else Begin
					With Channels [ i ] Do Begin
						On := ( c And $80 ) = 0;
						c := c And $7F;
						If c < 8
						Then Begin
							Panning := pan_Left;
							Volume := vol_Max;
							ChType := ch_Samples;
						End
						Else Begin
							If c < 16
							Then Begin
								Panning := pan_Right;
								Volume := vol_Max;
								ChType := ch_Samples;
							End
							Else Begin
								Panning := pan_Center;
								Volume := vol_Max;
								ChType := ch_Adlib;
							End;
						End;
					End;
				End;
				}
			End;

			For i := 0 To nOrders - 1 Do Begin
				GetByte ( f );
				{
				If c = 254
				Then Begin
					c := orderSkip;
				End
				Else Begin
					If c = 255
					Then Begin
						c := orderRestart;
					End;
				End;
				Orders [ i ] := c;
				}
			End;

			Offs1 := FilePos ( f );
			//
			For i := 0 To nSamples - 1 Do Begin
				Offset := Word ( GetWord ( f ) );
				//
				//GetMem ( Samples, nIns * SizeOf ( TSample ) );
				//For i := 0 To nIns - 1 Do Begin

				Seek ( f, cPos + Offset Shl 4 );

				//With Samples^ [ i ] Do Begin

					GetByte ( f ); //InsType, 1 );
					Name := Trim ( GetString ( f, $C ) );
					//
					If Name <> '' Then
					Begin
						tDump ( 'Sample #' + Zero ( i + 1, 2 ) + ': ' + Name ); 
					End;
					//GrabBytes ( DosName [ 1 ], $C );

					{
					GetByte ( nothing [ 1 ], 1 );

					GetWord ( MemSeg, 2 );
					GetWord ( DataLength, 2 );
					GetWord ( DataLengthHi, 2 );
					GetLong ( LoopBeg, 4 );
					GetLong ( LoopEnd, 4 );
					GetByte ( Vol, 1 );

					GetByte ( nothing [ 1 ], 1 );

					GetWord ( nothing [ 1 ], 2 );
					// GetLong ( Usage : Word;  Internal!

					GetLong ( C2Speed, 4 );
					GrabBytes ( nothing [ 1 ], 12 );
					GrabBytes ( SampName [ 1 ], 28 );
					GetLong ( Info [ 1 ], 4 );

					c := DataLength;

					If MaxAvail > c
					Then Begin

						GetMem ( InsData, c );
						SamplePos := Longint ( MemSeg ) Shl 4;
						Seek ( mf, SamplePos );
						GrabBytes ( InsData^, c );

					End
					Else Begin

						// not enough memory for this sample

						_Warning := True;
						DataLength := 0;
						InsData := Nil;

					End;
				End;
				}
			//End;
				Inc ( Offs1, 2 );
				Seek ( f, Offs1 );
			End;
			//
			//For i := 0 To nPatt - 1 Do Begin
				//GetWord ( pp [ 100 + i ], 2 );
			//End;

			{*** in ST3.2 here comes 32 (nChannel) bytes ***}
			{ desribing channel panning 0 : ..; 21 - 2F : panning }

			{ Header is all readed. }

			{ Read patterns }
			(*
			GetMem ( Patterns, nPatt * SizeOf ( TPackedPattern ) );
			For i := 0 To nPatt - 1 Do Begin
				Seek ( mf, pp [ 100 + i ] Shl 4 );
				With Patterns^ [ i ] Do Begin
					RawLength := 0;
					GetWord ( RawLength, 2 );
					If RawLength = 0
					Then Begin
						Rows := 64;
						Method := 0;
						Used := False;
						Empty := True;
						Data := Nil;
					End
					Else Begin
						Rows := 64;
						Method := 1;
						Used := False;
						Empty := False;
						Dec ( RawLength, 2 );
						GetMem ( Data, RawLength );
						GrabBytes ( Data^, RawLength );
					End;
				End;
			End;
			*)
		End;
	End;
End;

Procedure DumpIT;
Var
	c : Integer;
	Name : String;
	//
	nOrders : Integer;
	nInstruments : Integer;
	nSamples : Integer;
	//
	o1, o2 : Integer; // file offsets
Begin
	Name := '';
	For c := 1 To 26 Do
		Name := Name + ' ';

	Name := GetString ( f, 26 );
	//Name [ 0 ] := #26;
	For c := 1 To Length ( Name ) Do Begin
		If Name [ c ] = #0
		Then Name [ c ] := #$20; { pad 0's to spaces }
	End;
	Name := Trim ( Name );
	If Name = '' Then
		Name := '(unnamed)';
	tDump ( 'Module name: ' + Name );

	{ 2 unused bytes }
	GetWord ( f );

	nOrders := GetWord ( f );
	tDump ( '- Orders: ' + Comma ( nOrders ) );
	nInstruments := GetWord ( f );
	tDump ( '- Instruments: ' + Comma ( nInstruments ) );
	nSamples := GetWord ( f );
	tDump ( '- Samples: ' + Comma ( nSamples ) );
	tDump ( '- Patterns: ' + Comma ( GetWord ( f ) ) );

	{ created with tracker }
	GetWord ( f );
	{ compatible with tracker }
	GetWord ( f );

	{ Flags }
	GetWord ( f );
	{
	If ( Flags And $1 ) = 0
	Then Begin
		OutputStyle := os_Mono;
	End
	Else Begin
		OutputStyle := os_Stereo;
	End;
	Ins_Control := ( Flags And $4 ) <> 0;
	Linear_Slides := ( Flags And $8 ) <> 0;
	}
	{ rest of the flags are uninteresting... }

	{ Special }
	GetWord ( f ); { rest is undefined... }

	GetByte ( f ); { global vol }
	GetByte ( f ); { mixing vol }
	GetByte ( f );
	GetByte ( f );
	GetByte ( f ); { separation }

	GetByte ( f ); { #0 }

	{
	If ( Special And $1 ) = 0
	Then Begin
		GetLong ( f, nothing [ 1 ], 10 );
	End
	Else Begin
		}
		GetWord ( f ); // message length
		GetLong ( f ); // message offset
		GetLong ( f ); // unused
		{
	End;
	}

	//nChannels := 64;

	For c := 0 To 63 Do Begin
		GetByte ( f );
		{
		With Channels [ c ] Do Begin
			ChOn := True;
			ChType := ch_Samples;
			If ab = 100
			Then Begin
				Surround := True;
				Panning := pan_Center;
			End
			Else Begin
				Surround := False;
				If ab > $80
				Then Begin
					ChOn := False;
					Dec ( ab, $80 )
				End;
				Panning := Word ( ab ) Shl 2;
			End;
		End;
		}
	End;

	For c := 0 To 63 Do Begin
		GetByte ( f );
		{
		If ab = 64
		Then Begin
			Channels [ c ]. Volume := 255;
		End
		Else Begin
			Channels [ c ]. Volume := ab Shl 2;
		End;
		}
	End;

	For c := 0 To nOrders - 1 Do Begin
		GetByte ( f );
		{
		If ab = 254
		Then Begin
			aw := order_Skip;
		End
		Else Begin
			If ab = 255
			Then Begin
				aw := order_end;
			End
			Else Begin
				aw := ab;
			End;
		End;
		Order [ c ] := aw;
		}
	End;

	{ longint tables ... }

	{ Read Instruments }
	//o1 := FilePos ( mf );
	If nInstruments > 0 Then
	Begin
		For c := 0 To nInstruments - 1 Do Begin
			GetLong ( f ); // offset, o2, 4 );
			{
			Seek ( mf, o2 );
			GetLong ( f, Instruments [ c ]. d, SizeOf ( TInstrument ) );
			Inc ( o1, 4 );
			Seek ( mf, o1 );
			}
		End;
	End;

	{ Read Samples }
	o1 := FilePos ( f );
	If nSamples > 0 Then
	Begin
		For c := 1 To nSamples Do Begin
			o2 := GetLong ( f );
			Seek ( f, cPos + o2 );

			//With Samples [ c ] Do Begin

				GetLong ( f ); { IMPS }
				GetString ( f, $C );
				GetByte ( f ); { #00 }
				GetByte ( f ); // GlobalVolume
				GetByte ( f ); // flags
				GetByte ( f ); // volume

				Name := Trim ( GetString ( f, 26 ) );
				If Name <> '' Then
				Begin
					tDump ( 'Sample #' + Zero ( c, 2 ) + ': ' + Trim ( Name ) );
				End;

				{
				GetLong ( f, IT_Flags, 2 ); // "Convert"
				GetLong ( f, Len, 4 );
				GetLong ( f, LoopBegin, 4 );
				GetLong ( f, LoopEnd, 4 );
				GetLong ( f, C5Speed, 4 );
				GetLong ( f, SusLoopBegin, 4 );
				GetLong ( f, SusLoopEnd, 4 );

				GetLong ( f, o2, 4 );

				GetLong ( f, ViS, 1 );
				GetLong ( f, ViD, 1 );
				GetLong ( f, ViR, 1 );
				GetLong ( f, ViT, 1 );

				//Seek ( mf, o2 );
				//GetMem ( Data, Len );
				//GetLong ( f, Data^, Len );
				}
			//End;

			Inc ( o1, 4 );
			Seek ( f, o1 ); // absolute address
		End;
	End;

	{ Read Patterns }
	{
	o1 := FilePos ( mf );
	For c := 0 To nPatterns - 1 Do Begin
		//
		GetMem ( Patterns [ c ], SizeOf ( TPattern ) );
		InitPattern ( Patterns [ c ]^, 256, nChannels );
		//
		Patterns [ c ]^.Empty := False;
		Patterns [ c ]^.Method := 1;
		//
		GetLong ( f, o2, 4 );
		Seek ( mf, o2 );
		//
		// ########## read a pattern
		//
		GetLong ( f, RawLen, 2 );
		GetLong ( f, xRows, 2 );
		GetLong ( f, nothing [ 1 ], 4 );

		//
		GetMem ( p, SizeOf ( TPackedPattern ) );

		GetLong ( f, p^, RawLen );
		it_UnpackPattern ( p, RawLen, xRows, nChannels, song, c );

		FreeMem ( p, SizeOf ( TPackedPattern ) );
		//

		// ----------------------------
		Inc ( o1, 4 );
		Seek ( mf, o1 );
	End;
	}
End;

Begin
	If Not fOpen ( sEditFile ) Then Exit;
	//
	Starting;
	//
	MusicFormat := mfmtNone;
	//
	fSeek ( F, cPos );
	//
	If PanelMus.Visible Then
	Begin
		ShowPage ( edNone );
	End;
	//
	MusMemoIns.Clear;
	//
	MusGrid.RowCount := 2;
	MusGrid.ColCount := 17;
	MusGrid.Visible := False;
	//
	i := 0;
	//
	h1 := GetWord ( f ); // Read Header (MUS $1A)
	h2 := GetWord ( f );
	Inc ( i, 4 );
	//
	If ( h1 = $554D ) And ( h2 = $1A53 ) Then // "MUS" + $1A
	Begin
		MusicFormat := mfmtDOOM;
		//
		// *** Interpret as MUS format ***
		//
		ClearGrid;
		//
		GetWord ( f ); // score length
		Inc ( i, 2 );
		GetWord ( f ); // score start
		Inc ( i, 2 );
		//
		channels := GetWord ( f ); // count of primary channels
		Inc ( i, 2 );
		GetWord ( f ); // count of secondary channels
		Inc ( i, 2 );
		instrCnt := GetWord ( f );
		Inc ( i, 2 );
		GetWord ( f ); // dummy
		Inc ( i, 2 );
		//
		MusMemoIns.Lines.Add ( '[' + IntToStr ( Channels ) + ' Channels + Drums]' );

		For Channel := 1 To instrCnt Do
		Begin
			w := GetWord ( f );
			Inc ( i, 2 );

			If w >= 135 Then
			Begin
				s := ConstantFindDescription ( 'MIDI_PERCUSSION', w - 100 );
			End
			Else
			Begin
				s := ConstantFindDescription ( 'MIDI_INSTRUMENT', w );
			End;

			//If Channel <= Channels Then
			//Begin
			//	MusGrid.Cells [ Channel, 0 ] := s;
			//End;

			s := 'Instrument ' + Zero ( Channel, 2 ) + ': #' + Zero ( w, 3 ) + ': ' + s;
			MusMemoIns.Lines.Add ( s );
		End;
		//
		For Channel := 1 To instrCnt Do
		Begin
			MusGrid.Cells [ Channel, 0 ] := '???';
		End;
		//
		For Channel := 0 To 16 Do
		Begin
			If ( Channel <= Channels ) Or ( Channel = 16 ) Then
			Begin
				MusGrid.ColWidths [ Channel ] := 80;
			End
			Else
			Begin
				MusGrid.ColWidths [ Channel ] := -1;
			End;
		End;

		// --

		s := '';
		iRow := 1;
		//
		While i < cLen Do
		Begin
			//
			If ( i And $1FF ) = 0 Then
			Begin
				Status ( 'Working... ' + IntToStr ( Round ( i / cLen * 100 ) ) + '%' );
			End;
			//
			Event := GetByte ( f );
			Inc ( i, 1 );
			//
			Channel := Event And 15;
			Event := Event Shr 4;
			//
			{
			0 - release note
			1 - play note
			2 - pitch wheel (bender)
			3 - system event (valueless controller)
			4 - change controller
			5 - ???
			6 - score end
			7 - ???
			}
			//
			Case Event And 7 Of

				0 : // release note
				Begin
					MusGrid.Cells [ Channel + 1, iRow ] :=
						MusGrid.Cells [ Channel + 1, iRow ] + '^^^ ';
					//
					GetByte ( f );
					Inc ( i );
				End;

				1 : // play note
				Begin
					b := GetByte ( f ); // note
					//
					MusGrid.Cells [ Channel + 1, iRow ] :=
						MusGrid.Cells [ Channel + 1, iRow ] + ByteToNote ( b And $7F ) + ' ';
					//
					Inc ( i );
					If ( b And $80 ) <> 0 Then
					Begin
						b := GetByte ( f ); // volume
						//
						MusGrid.Cells [ Channel + 1, iRow ] :=
							MusGrid.Cells [ Channel + 1, iRow ] + 'V' + IntToStr ( b ) + ' ';
						//
						Inc ( i );
					End;
				End;

				2 : // Glide
				Begin
					b := GetByte ( f ); // Glide amount
					//
					MusGrid.Cells [ Channel + 1, iRow ] :=
						MusGrid.Cells [ Channel + 1, iRow ] + 'Glide(' + IntToStr ( b ) + ') ';
					//
					Inc ( i );
				End;

				3 : // system event (valueless controller)
				Begin
					b := GetByte ( f ); // n
					//
					MusGrid.Cells [ Channel + 1, iRow ] :=
						MusGrid.Cells [ Channel + 1, iRow ] + 'System(' + IntToStr ( b ) + ') ';
					//
					Inc ( i );
				End;

				4 : // change controller
				Begin
					b := GetByte ( f ); // Controller
					Inc ( i );
					v := GetByte ( f ); // Value
					Inc ( i );
					//
					If b <> 0 Then
					Begin
						MusGrid.Cells [ Channel + 1, iRow ] :=
							MusGrid.Cells [ Channel + 1, iRow ] + 'C[' + IntToStr ( b ) + ']=' + IntToStr ( v ) + ' ';
					End
					Else
					Begin
						// Controller 0 : Change Patch
						If Channel = 15 Then
						Begin
							MusGrid.Cells [ Channel + 1, 0 ] := 'Drums';
						End
						Else
						Begin
							MusGrid.Cells [ Channel + 1, 0 ] := ConstantFindDescription ( 'MIDI_INSTRUMENT', v );
						End;
					End;
				End;

				5 : // event5???
				Begin
					MusGrid.Cells [ Channel + 1, iRow ] :=
						MusGrid.Cells [ Channel + 1, iRow ] + 'E5? ';
				End;

				6 : // End
				Begin
					// End Track
					MusGrid.Cells [ Channel + 1, iRow ] :=
						MusGrid.Cells [ Channel + 1, iRow ] + 'E6? ';
				End;

				7 : // event7???
				Begin
					MusGrid.Cells [ Channel + 1, iRow ] :=
						MusGrid.Cells [ Channel + 1, iRow ] + 'E7? ';
				End;

			End;
			//
			// --- Last?
			//
			If ( Event And 8 ) <> 0 Then
			Begin
				iTime := 0;
				Repeat
					b := GetByte ( f );
					Inc ( i );
					iTime := iTime * $80 + ( b And $7F );
				Until ( b And $80 ) = 0;
				//
				s := IntToHex ( iTime, 8 ) + ' ' + s;
				//
				MusGrid.Cells [ 0, iRow ] := s;
				s := '';
				//
				Inc ( iRow );
				If iRow > MusGrid.RowCount Then
				Begin
					MusGrid.RowCount := MusGrid.RowCount + 1;
					For c := 0 To MusGrid.ColCount Do
						MusGrid.Cells [ c, MusGrid.RowCount ] := '';
				End;
			End;
		End;

		//If s <> '' Then
		//	MusMemoPatt.Lines.Add ( s );

		MusGrid.Visible := True;
	End
	Else
	Begin
		If h1 = cLen - 90 Then
		Begin
			MusicFormat := mfmtIMF;
			//
			MusMemoIns.Lines.Add ( 'Apogee IMF Music Format.' );
			//
			// *** Apogee IMF Music Format ***
			//
			MusGrid.ColCount := 3;
			MusGrid.DefaultRowHeight := 16;
			ClearGrid;
			//
			MusGrid.Cells [ 0, 0 ] := 'Address';
			MusGrid.ColWidths [ 0 ] := 310;
			MusGrid.Cells [ 1, 0 ] := 'Data';
			MusGrid.Cells [ 2, 0 ] := 'Delay';
			//
			Seek ( F, cPos + 2 );
			//
			iRow := 1;
			While i < h1 Do
			Begin
				MusGrid.RowCount := MusGrid.RowCount + 1;
				//
				For c := 0 To MusGrid.ColCount Do
					MusGrid.Cells [ c, MusGrid.RowCount ] := '';
				//
				b := GetByte ( f );
				MusGrid.Cells [ 0, iRow ] := IntToHex ( b, 2 ) + ' ' + AdlibPortName ( b );
				//
				b := GetByte ( f );
				MusGrid.Cells [ 1, iRow ] := IntToHex ( b, 2 );
				//
				w := GetWord ( f );
				MusGrid.Cells [ 2, iRow ] := IntToHex ( w, 4 );
				//
				Inc ( iRow );
				Inc ( i, 4 );
			End;
			//
			MusGrid.Visible := True;
		End
		Else
		Begin
			If ( h1 = $544D ) And ( h2 = $6468 ) Then
			Begin
				MusicFormat := mfmtMIDI;
				//
				MusMemoIns.Lines.Add ( 'Standard MIDI file.' );
				ClearGrid;
			End
			Else
			Begin
				If ( h1 = $4D49 ) And ( h2 = $4D50 ) Then
				Begin
					MusicFormat := mfmtIT;
					//
					tDump ( 'Impulse Tracker Module.' );
					//
					DumpIT;
					//
					ClearGrid;
				End
				Else
				Begin
					Seek ( f, cPos + $2C );
					h3 := Cardinal ( GetLong ( f ) );
					//
					If h3 = $4D524353 Then
					Begin
						MusicFormat := mfmtSCRM;
						//
						MusMemoIns.Lines.Add ( 'Scream Tracker Module.' );
						//
						DumpS3M;
						//
						ClearGrid;
					End
					Else
					Begin
						MusMemoIns.Lines.Add ( 'Unknown file format.' );
						ClearGrid;
					End;
				End;
			End;
		End;
	End;
	//
	fClose;
	//
	ShowPage ( edMus );
	//
	Modified ( False );
	//
	Finished;
End;

procedure TFormMain.mnuEntryRenameClick(Sender: TObject);
Begin
	EntryRename;
end;

procedure TFormMain.mnuPL_RenameClick(Sender: TObject);
Begin
	EntryRename;
end;

Procedure TFormMain.EntryRenameByIndex ( iEntry : Integer; sName : String );
Var
	i : Integer;
Begin
	// Set the name in our internal array
	WadEntries [ iEntry ].Name := sName;
	// Save it into disk
	SaveWadEntryName ( iEntry );
	// Re-identify the new entry
	WadEntryIdentify ( iEntry );
	//
	// --- Find and update this entry on the screen
	//
	i := 0;
	While i < ListWad.Items.Count  Do
	Begin
		If EntryGetIndex ( i ) = iEntry Then
		Begin
			UpdateWadEntry ( i, iEntry );
			i := ListWad.Items.Count;
		End
		Else
			Inc ( i );
	End;
End;

procedure TFormMain.EntryRename;
Var
	sc, i, c : Integer;
	mask : String;
	s : String;
	NameSize : Integer;

Procedure SetName ( i : Integer );
Var
	Index : Integer;
Begin
	Index := EntryGetIndex ( i );
	//
	WadEntries [ Index ].Name := s;
	//
	If Not gFileReadOnly Then
	Begin
		{$IFDEF FULLVERSION}
		If IsFileEditable Then
		Begin
			{$ENDIF}
			SaveWadEntryName ( Index );
			//
			UpdateModifiedDate;
			{$IFDEF FULLVERSION}
		End;
		{$ENDIF}
	End;
	//
	// --- Update Screen
	//
	WadEntryIdentify2 ( Index );
	WadEntryIdentify ( Index );
	//
	UpdateWadEntry ( i, Index );
End;

Begin
	{$IFDEF FULLVERSION}
	If IsFileEditable Then
	Begin
		{$ENDIF}
		NameSize := 8;
	{$IFDEF FULLVERSION}
	End
	Else
	Begin
		NameSize := 256;
	End;
	{$ENDIF}
	//
	sc := ListWad.SelCount;
	If sc > 0 Then
	Begin
		If sc = 1 Then
		Begin
			s := Trim ( ListWad.Selected.Caption );
			s := InputBox ( 'Rename Single Enrty', 'Enter new entry name (up to ' +
				Comma ( NameSize ) + ' characters)', s );
			If s <> '' Then
			Begin
				//
				{$IFDEF FULLVERSION}
				If IsFileEditable Then
				Begin
					{$ENDIF}
					SaveUndo ( 'Rename Entry' );
					{$IFDEF FULLVERSION}
				End;
				{$ENDIF}
				//
				s := Copy ( Trim ( s ), 1, NameSize );
				If Not gDontAutoCapitalize Then
				Begin
					s := UpperCase ( s );
				End;
				If Length ( s ) < NameSize Then
				Begin
					s := Copy ( s + '        ', 1, NameSize );
				End;
				//
				SetName ( ListWad.Selected.Index );
				//
				ShowEntry ( '', False );
			End;
		End
		Else
		Begin
			//
			// --- Multiple rename
			//
			mask := '';
			For i := 0 To ListWad.Items.Count - 1 Do // go through all items
			Begin
				If ListWad.Items [ i ].Selected Then // selected ??
				Begin
					s := ListWad.Items [ i ].Caption;
					If mask = '' Then // first one??
					Begin
						mask := s; // yes, start from here
					End
					Else
					Begin // no, check against previous ones.
						For c := 1 To NameSize Do
						Begin
							If c <= Length ( mask ) Then
							Begin
								If mask [ c ] <> '*' Then // do we have to check this char?
								Begin
									If Length ( s ) < c Then
									Begin
										// another no-match
										mask [ c ] := '*';
									End
									Else
									Begin
										// yes, check it
										If s [ c ] <> mask [ c ] Then
										Begin
											// another no-match
											mask [ c ] := '*';
										End;
									End;
								End;
							End;
						End;
					End;
				End;
			End;
			// --- done, show it to user
			mask := InputBox ( 'Rename Multiple Enrties', 'Enter new name (*=no change).', mask );
			If mask <> '' Then
			Begin
				//
				SaveUndo ( 'Rename Multiple Entries' );
				//
				mask := Copy ( Trim ( mask ), 1, NameSize );
				If Not gDontAutoCapitalize Then
				Begin
					mask := UpperCase ( mask );
				End;
				If Length ( mask ) < NameSize Then
				Begin
					mask := Copy ( mask + '        ', 1, NameSize );
				End;
				// --- go through the list
				For i := 0 To ListWad.Items.Count - 1 Do // go through all items
				Begin
					If ListWad.Items [ i ].Selected Then // selected ??
					Begin
						s := ListWad.Items [ i ].Caption;
						For c := 1 To Length ( mask ) Do
						Begin
							If mask [ c ] <> '*' Then // do we have to change this char?
							Begin
								If Length ( s ) >= c Then
									s [ c ] := mask [ c ]
								Else
									s := s + mask [ c ];
							End;
						End;
						s := Trim ( s );
						//
						SetName ( i );
						//
					End;
				End;
			End;
		End;
	End;
end;

//#############################################################################
//
// --- TEXTURES ---
//
//#############################################################################

Procedure TFormMain.TextureForceLoad;
Begin
	nTextures := 0;
	//
	main_PIndex := 0;
	main_TIndex := FindEntry ( 'TEXTURE1' );
	If main_TIndex > 0 Then
	Begin
		TextureLoad ( main_TIndex );
	End
	Else
	Begin
		//
		// --- Look in Main WAD
		//
		main_TIndex := FindEntryInMain ( 'TEXTURE1' );
		//
		If main_TIndex > 0 Then
		Begin
			// Copy from Main
			CopyEntryFromMain ( main_TIndex );
			UpdateWadEntry ( nWadEntries - 1, nWadEntries );
			//
			WadEntryIdentify ( nWadEntries );
			main_TIndex := nWadEntries;
			//
			TextureLoad ( main_TIndex );
		End
		Else
		Begin
			// Create New Texture1 entry
			WadEntryNew ( 'TEXTURE1' );
			main_TIndex := nWadEntries;
		End;
	End;
	//
	main_TextureAddCount := 0;
	main_bSavePatch := False;
End;

Procedure TFormMain.TextureAdd ( Index : Integer );
Var
	s : String;
	x, y, xr, yr : Integer;
	Patch : Integer;
	fmt : TImageFormat;
Begin
	s := WadEntries [ Index ].Name;
	//
	fmt := ImageIdentifyEntry ( Index, x, y, xr, yr );
	If ( fmt = fmtDoom ) Or ( fmt = fmtPNG ) Then
	Begin
		//
		If main_TextureAddCount = 0 Then
		Begin
			PatchNamesForceLoad;
		End;
		//
		// --- Add New Texture
		//
		Inc ( nTextures );
		Textures [ nTextures ].Name := s;
		Textures [ nTextures ].xs := x;
		Textures [ nTextures ].ys := y;
		//
		Inc ( nTexturePatches );
		Textures [ nTextures ].PatchStart := nTexturePatches;
		Textures [ nTextures ].PatchCount := 1;
		Textures [ nTextures ].Loaded := False;
		//
		Patch := PatchFind ( s );
		//
		If Patch < 0 Then
		Begin
			// add it
			Patch := nPatches;
			Inc ( nPatches );
			Patches [ Patch ].Name := s;
			Patches [ Patch ].Loaded := False;
			Patches [ Patch ].xs := 0;
			Patches [ Patch ].ys := 0;
			//
			main_bSavePatch := True;
		End;
		//
		TexturePatches [ nTexturePatches ].ID := Patch;
		TexturePatches [ nTexturePatches ].xPos := 0;
		TexturePatches [ nTexturePatches ].yPos := 0;
		//
		Inc ( main_TextureAddCount );
	End;
End;

procedure TFormMain.mnuPL_AddtoTextureClick(Sender: TObject);
Var
	i : Integer;
Begin
	Starting;
	//
	SaveUndo ( 'Add Textures' );
	//
	// load
	//
	TextureForceLoad;
	//
	// --- Add them
	//
	main_bSavePatch := False;
	main_TextureAddCount := 0;
	For i := 0 To ListWad.Items.Count - 1 Do
	Begin
		If ListWad.Items [ i ].Selected Then
		Begin
			TextureAdd ( EntryGetIndex ( i ) );
		End;
	End;
	//
	// main_PIndex and main_TIndex unchanged
	//
	If main_bSavePatch Then
	Begin
		PatchNamesSaveData;
		ReplaceFile ( main_PIndex, sTempFile, False, True );
	End;
	//
	TextureSaveData;
	ReplaceFile ( main_TIndex, sTempFile, False, True );
	//
	Finished;
	Status ( 'Added ' + Comma ( main_TextureAddCount ) + ' Textures' );
end;

Function TFormMain.TextureSave : Boolean;
Begin
	// save to a temp file
	If TextureSaveData Then
	Begin
		//
		// replace lump in WAD with temp file
		ReplaceFile ( iSel, sTempFile, True, True );
		//
		Modified ( False );
		UpdateModifiedDate;
		//
		TextureSave := True;
	End
	Else
	Begin
		TextureSave := False;
	End;
End;

Function TFormMain.TextureSaveData : Boolean;
Var
	i, Patch, PatchStart : Integer;
	UsedSpace : Integer;
Begin
	fOpenTemp;
	//
	SendLong ( fo, nTextures );
	//
	UsedSpace := 4 + nTextures * 4; // header + datapositions
	//
	For i := 1 To nTextures Do
	Begin
		Textures [ i ].DataPosition := UsedSpace; // recalc
		//
		SendLong ( fo, Textures [ i ].DataPosition );
		//
		// Add this texture's size to the used space
		//
		Inc ( UsedSpace, 8 ); // name
		Inc ( UsedSpace, 14 ); // headers
		Inc ( UsedSpace, Textures [ i ].PatchCount * 10 );
	End;
	//
	For i := 1 To nTextures Do
	Begin
		//
		SendString8 ( fo, Textures [ i ].Name );

		SendWord ( fo, Textures [ i ].Flags );
		SendByte ( fo, Textures [ i ].xScale );
		SendByte ( fo, Textures [ i ].yScale );
		//
		SendWord ( fo, Textures [ i ].xs );
		SendWord ( fo, Textures [ i ].ys );
		SendLong ( fo, Textures [ i ].sp2 );

		SendWord ( fo, Textures [ i ].PatchCount );
		//
		PatchStart := Textures [ i ].PatchStart;
		//
		For Patch := 0 To Textures [ i ].PatchCount - 1 Do
		Begin
			SendWord ( fo, TexturePatches [ Patch + PatchStart ].xPos );
			SendWord ( fo, TexturePatches [ Patch + PatchStart ].yPos );
			SendWord ( fo, TexturePatches [ Patch + PatchStart ].ID );
			SendLong ( fo, TexturePatches [ Patch + PatchStart ].sp1 );
		End;
	End;
	//
	CloseFile ( fo );
	//
	TextureSaveData := True;
end;

Procedure TFormMain.UpdateTexture ( iTexture : Integer );
Begin
	With GridTextures Do
	Begin
		// update texture entry
		Cells [ 0, iTexture ] := Trim ( Textures [ iTexture ].Name );
		//
		Cells [ 1, iTexture ] := IntToStr ( Textures [ iTexture ].xs );
		Cells [ 2, iTexture ] := IntToStr ( Textures [ iTexture ].ys );
		//
		Cells [ 3, iTexture ] := IntToStr ( Textures [ iTexture ].xScale );
		Cells [ 4, iTexture ] := IntToStr ( Textures [ iTexture ].yScale );
		//
		Cells [ 5, iTexture ] := '$' + IntToHex ( Textures [ iTexture ].Flags, 4 );
    //
		Cells [ 6, iTexture ] := IntToStr ( Textures [ iTexture ].PatchCount );
	End;
End;

Procedure TFormMain.TextureInit;
Var
	iEntry : Integer;
Begin
	iEntry := FindEntry ( 'TEXTURE1' );
	//
	If iEntry > 0 Then
	Begin
		TextureLoad ( iEntry );
	End
	Else
	Begin
		//
		iEntry := FindEntryInMain ( 'TEXTURE1' );
		//
		If iEntry > 0 Then
		Begin
			AssignFile ( f, sMainWAD );
			FileMode := fmOpenRead;
			Reset ( f, 1 );
			TextureLoadFromFile ( MainWadEntries [ iEntry ]. Position );
			fClose;
		End;
		//
	End;
End;

procedure TFormMain.TextureLoadFromFile ( iPos : Integer );
Var
	i, Patch : Integer;
Begin
	//
	// *** Read from file ***
	//     assume file "F" is open
	//
	fSeek ( f, iPos );
	//
	nTextures := 0;
	nTexturePatches := 0;
	//
	nTextures := GetLong ( f );
	//
	For i := 1 To nTextures Do
	Begin
		Textures [ i ].DataPosition := GetLong ( f );
	End;
	//
	For i := 1 To nTextures Do
	Begin
		Seek ( F, iPos + Textures [ i ].DataPosition );
		//
		Textures [ i ].Name := GetString ( f, 8 );
		Textures [ i ].Flags := GetWord ( f );
		Textures [ i ].xScale := GetByte ( f );
		Textures [ i ].yScale := GetByte ( f );
		Textures [ i ].xs := GetWord ( f );
		Textures [ i ].ys := GetWord ( f );
		Textures [ i ].sp2 := GetLong ( f );
		Textures [ i ].PatchCount := GetWord ( f );
		Textures [ i ].Loaded := False;
		For Patch := 1 To Textures [ i ].PatchCount Do
		Begin
			Inc ( nTexturePatches );
			If Patch = 1 Then
				Textures [ i ].PatchStart := nTexturePatches;

			TexturePatches [ nTexturePatches ].xPos := GetWord ( f );
			TexturePatches [ nTexturePatches ].yPos := GetWord ( f );
			TexturePatches [ nTexturePatches ].ID := GetWord ( f );
			TexturePatches [ nTexturePatches ].sp1 := GetLong ( f );

			//MemoHex.Lines.Add ( IntToStr ( TexturePatches [ Patch ].ID ) );
		End;
	End;
End;

procedure TFormMain.TextureLoad ( iEntry : Integer );
Begin
	//
	If WadEntries [ iEntry ].Size = 0 Then
	Begin
		// Empty Texture entry
		nTextures := 0;
	End
	Else
	Begin
		//
		If Not fOpen ( sFileName ) Then Exit;
		//
		Starting;
		//
		TextureLoadFromFile ( WadEntries [ iEntry ].Position );
		//
		fClose;
		//
		Finished;
		//
    Modified ( False );
	End;
End;

procedure TFormMain.TextureEditor;
Var
	i : Integer;
Begin
	PreparePalette;
	TextureLoad ( iSel );
	//
	// *** Display ***
	//
	With GridTextures Do
	Begin
		FixedCols := 0;
		ColCount := 7;
		RowCount := 2;
		DefaultRowHeight := 18;
		//
		Cells [ 0, 0 ] := 'Name';
		Cells [ 1, 0 ] := 'Width';
		Cells [ 2, 0 ] := 'Height';
		Cells [ 3, 0 ] := 'x Scale';
		Cells [ 4, 0 ] := 'y Scale';
		Cells [ 5, 0 ] := 'Flags';
		Cells [ 6, 0 ] := 'Patches';
	End;
	TextureSplitter2Moved ( Self ); // align
	//
	With GridTexturePatches Do
	Begin
		FixedCols := 0;
		DefaultRowHeight := 18;
		ColCount := 5;
		Cells [ 0, 0 ] := 'UID';
		ColWidths [ 0 ] := 40;
		Cells [ 1, 0 ] := 'PID';
		ColWidths [ 1 ] := 40;
		Cells [ 2, 0 ] := 'PatchName';
		Cells [ 3, 0 ] := 'xPos';
		Cells [ 4, 0 ] := 'yPos';
		ColWidths [ 3 ] := 40;
		ColWidths [ 4 ] := 40;
	End;

	//
	//GridTextures.Width := PanelTexture.Width Div 2;
	//GridTexturePatches.Width := PanelTexture.Width - GridTextures.Width;

	GridTextures.Visible := False;
	For i := 1 To nTextures Do
	Begin
		If i >= GridTextures.RowCount Then
		Begin
			GridTextures.RowCount := GridTextures.RowCount + 1;
		End;
		UpdateTexture ( i );
	End;
	//
	LastTexture := 0;
	GridTextures.Row := GridTextures.RowCount - 1;
	TextureShow ( nTextures );
	//
	GridTextures.Visible := True;
	//
	ShowPage ( edTexture );
	//
	If bFocus Then
	Begin
		GridTextures.SetFocus;
	End;
End;

Function TFormMain.PatchNameByID ( ID : Integer ) : String;
Begin
	PatchInit;

	If ( ID < 0 ) Or ( ID >= nPatches ) Then
	Begin
		PatchNameByID := IntToStr ( ID );
	End
	Else
	Begin
		PatchNameByID := Patches [ ID ].Name;
	End;
End;

Function TFormMain.PatchName ( n : Integer ) : String;
Begin
	PatchName := PatchNameByID ( TexturePatches [ n ].ID );
End;

Function TFormMain.PatchFind ( s : String ) : Integer;
Var
	i, iPatch : Integer;
Begin
	iPatch := -1;
	i := 0;
	//
	While ( i < nPatches ) Do
	Begin
		If UpperCase ( Trim ( Patches [ i ].Name ) ) = UpperCase ( Trim ( s ) ) Then
		Begin
			iPatch := i;
			i := nPatches;
		End;
		Inc ( i );
	End;
	//
	PatchFind := iPatch;
End;

procedure TFormMain.TextureShow ( n : Integer );
Var
	i, y : Integer;
Begin
	With GridTexturePatches Do
	Begin
		RowCount := 2;
		Cells [ 0, 1 ] := '';
		Cells [ 1, 1 ] := '';
		Cells [ 2, 1 ] := '';
		Cells [ 3, 1 ] := '';
		Cells [ 4, 1 ] := '';
	End;
	//
	If ( n > 0 ) And ( n <= nTextures ) Then
	Begin
		LastTexture := n;
		//
		// *** Show Patches in Grid ***
		//
		With GridTexturePatches Do
		Begin
			//
			i := Textures [ n ].PatchStart;
			For y := 1 To Textures [ n ].PatchCount Do
			Begin
				//
				// add row if necessary
				//
				If y >= RowCount Then
				Begin
					RowCount := RowCount + 1;
				End;
				//
				Cells [ 0, y ] := Comma ( i );
				Cells [ 1, y ] := Comma ( TexturePatches [ i ].ID );
				Cells [ 2, y ] := PatchName ( i );
				Cells [ 3, y ] := IntToStr ( TexturePatches [ i ].xPos );
				Cells [ 4, y ] := IntToStr ( TexturePatches [ i ].yPos );
				//
				Inc ( i );
			End;
		End;
	End
	Else
	Begin
		If nTextures = 0 Then
		Begin
			With GridTextures Do
			Begin
				Cells [ 0, 1 ] := '';
				Cells [ 1, 1 ] := '';
				Cells [ 2, 1 ] := '';
				Cells [ 3, 1 ] := '';
				Cells [ 4, 1 ] := '';
				Cells [ 5, 1 ] := '';
        Cells [ 6, 1 ] := '';
			End;
		End;
	End;
	//
	TextureDraw ( n );
End;

procedure TFormMain.TextureDrawCanvas ( n : Integer; Zoom : Double; c : TCanvas );
Var
	i, y : Integer;
Begin
	//
	// draw patches on texture
	//
	With c Do
	Begin
		//
		// *** Draw patches ***
		//
		i := Textures [ n ].PatchStart;
		//
		For y := 1 To Textures [ n ].PatchCount Do
		Begin
			//
			// --- Get the patch's image
			//
			PatchLoad ( TexturePatches [ i ].ID );
			//
			If Image_xs > 0 Then
			Begin
				//
				// Render image
				//
				ImageRenderCurrentAt ( c,
					iTexture_xc + Round ( TexturePatches [ i ].xPos * Zoom ),
					iTexture_yc + Round ( TexturePatches [ i ].yPos * Zoom ), Zoom );
				//
				TexturePatches [ i ].xSize := Image_xs;
				TexturePatches [ i ].ySize := Image_ys;
			End
			Else
			Begin
				//
				// Just write name
				ImageTexture.Canvas.TextOut (
					iTexture_xc + TexturePatches [ i ].xPos,
					iTexture_yc + TexturePatches [ i ].yPos, PatchName ( i ) );
				//
				TexturePatches [ i ].xSize := 64;
				TexturePatches [ i ].ySize := 64;
			End;
			//
			Inc ( i );
		End;
	End;
End;

procedure TFormMain.TextureDraw ( n : Integer );
Var
	x, y : Integer;
	xs, ys : Integer;
	t : Integer;

Procedure VLine ( x, y1, y2 : Integer );
Begin
	With ImageTexture.Canvas Do
	Begin
		MoveTo ( x, y1 );
		LineTo ( x, y2 + 1 );
	End;
End;

Procedure HLine ( y, x1, x2 : Integer );
Begin
	With ImageTexture.Canvas Do
	Begin
		MoveTo ( x1, y );
		LineTo ( x2 + 1, y );
	End;
End;

Begin
	//
	// --- Init
	//
	If PanelTexture.Tag = 0 Then
	Begin
		PanelTexture.Visible := True;
		ImageTexture.Refresh;
		PanelTexture.Tag := 1;
	End;
	//
	With ImageTexture.Canvas Do
	Begin
		ImageTexture.Picture.Bitmap.Width := ImageTexture.Width;
		ImageTexture.Picture.Bitmap.Height := ImageTexture.Height;
		//
		Brush.Color := RGB ( 32, 16, 0 );
		FillRect ( ClipRect );
	End;
	//
	If ( n > 0 ) And ( n <= nTextures ) Then
	Begin
		xs := Round ( Textures [ n ].xs * TextureZoom );
		ys := Round ( Textures [ n ].ys * TextureZoom );
		iTexture_xc := ( ImageTexture.Width - xs ) Div 2;
		iTexture_yc := ( ImageTexture.Height - ys ) Div 2;
		//
		TextureDrawCanvas ( n, TextureZoom, ImageTexture.Canvas );
		//
		With ImageTexture.Canvas Do
		Begin
			//
			// *** Draw Frame ***
			//
			Brush.Color := clBlack;
			//
			FrameRect ( Classes.Rect ( iTexture_xc - 1, iTexture_yc - 1,
				iTexture_xc + xs + 1, iTexture_yc + ys + 1 ) );
			//
			Brush.Color := clGray;
			FrameRect ( Classes.Rect ( iTexture_xc - 2, iTexture_yc - 2,
				iTexture_xc + xs + 2, iTexture_yc + ys + 2 ) );
			t := 5;
			//
			Pen.Color := clGray;
			//
			x := 0;
			While x <= xs Do
			Begin
				VLine ( iTexture_xc + x, iTexture_yc - 3 - t, iTexture_yc - 3 );
				VLine ( iTexture_xc + x, iTexture_yc + ys + 2, iTexture_yc + ys + t + 2 );
				Inc ( x, 16 );
			End;
			y := 0;
			While y <= ys Do
			Begin
				HLine ( iTexture_yc + y, iTexture_xc - 2 - t, iTexture_xc - 2 );
				HLine ( iTexture_yc + y, iTexture_xc + xs + 2, iTexture_xc + xs + t + 2 );
				Inc ( y, 16 );
			End;
			//
		End;
	End;
End;

Procedure TFormMain.TexturePatchesSwap ( i1, i2 : Integer );
Var
	Swap : Integer;
Begin
	Swap := TexturePatches [ i1 ].ID;
	TexturePatches [ i1 ].ID := TexturePatches [ i2 ].ID;
	TexturePatches [ i2 ].ID := Swap;
	//
	Swap := TexturePatches [ i1 ].xPos;
	TexturePatches [ i1 ].xPos := TexturePatches [ i2 ].xPos;
	TexturePatches [ i2 ].xPos := Swap;
	//
	Swap := TexturePatches [ i1 ].yPos;
	TexturePatches [ i1 ].yPos := TexturePatches [ i2 ].yPos;
	TexturePatches [ i2 ].yPos := Swap;
	//
	Swap := TexturePatches [ i1 ].sp1;
	TexturePatches [ i1 ].sp1 := TexturePatches [ i2 ].sp1;
	TexturePatches [ i2 ].sp1 := Swap;
End;

procedure TFormMain.mnuTexturePatchMoveUpClick(Sender: TObject);
Var
	iRow : Integer;
	ID : Integer;
Begin
	//
	iRow := GridTexturePatches.Row;
	//
	If iRow > 1 Then
	Begin
		ID := PatchCurrentID;
		//
		If ( ID > 0 ) Then
		Begin
			TexturePatchesSwap ( ID, ID - 1 );
			TextureShow ( LastTexture );
			GridTexturePatches.Row := iRow - 1;
		End;
		//
	End;
end;

procedure TFormMain.mnuTexturePatchMoveDownClick(Sender: TObject);
Var
	iRow : Integer;
	ID : Integer;
Begin
	//
	iRow := GridTexturePatches.Row;
	//
	If iRow < GridTexturePatches.RowCount - 1 Then
	Begin
		ID := PatchCurrentID;
		//
		If ( ID > 0 ) Then
		Begin
			TexturePatchesSwap ( ID, ID + 1 );
			TextureShow ( LastTexture );
			GridTexturePatches.Row := iRow + 1;
		End;
		//
	End;
end;

procedure TFormMain.mnuTextureDeletePatchClick(Sender: TObject);
Var
	i : Integer;
	ID : Integer;
Begin
	//
	ID := PatchCurrentID;
	//
	If ( ID > 0 ) Then
	Begin
		//
		// --- decrement patch counter for the current texture
		//
		Dec ( Textures [ LastTexture ].PatchCount );
		//
		// --- move TexturePatches back in array
		//
		For i := ID + 1 To nTexturePatches Do
		Begin
			TexturePatches [ i - 1 ] := TexturePatches [ i ];
		End;
		//
		// --- Fix "PatchStart" for all the following textures
		//
		For i := LastTexture + 1 To nTextures Do
		Begin
			Dec ( Textures [ i ].PatchStart );
		End;
		//
		// --- decrement overall counter
		//
		Dec ( nTexturePatches );
		//
		// *** Refresh the screen
		//
		TextureShow ( LastTexture );
	End;
	//
end;

// --- Patch dragging

Function TFormMain.PatchCurrentID : Integer;
Var
	ID : Integer;
Begin
	ID := SafeVal ( GridTexturePatches.Cells [ 0, GridTexturePatches.Row ] );
	//
	If ( ID > 0 ) And ( Textures [ LastTexture ].PatchCount > 0 ) Then
	Begin
		PatchCurrentID := ID;
	End
	Else
	Begin
		PatchCurrentID := 0;
	End;
End;

Procedure TFormMain.TextureDrawDragFrame ( x, y : Integer );
Var
	xs, ys : Integer;
	xp, yp : Integer;
	ID : Integer;
Begin
	ID := PatchCurrentID;
	//
	If ( ID > 0 ) Then
	Begin
		//
		// --- save for later
		iTextureLastX := X;
		iTextureLastY := Y;
		//
		// --- get position of patch
		xp := Round ( TexturePatches [ ID ].xPos * TextureZoom );
		yp := Round ( TexturePatches [ ID ].yPos * TextureZoom );
		//
		// --- calculate screen position of patch
		xp := iTexture_xc + xp;
		yp := iTexture_yc + yp;
		//
		xs := Round ( TexturePatches [ ID ].xSize * TextureZoom );
		ys := Round ( TexturePatches [ ID ].ySize * TextureZoom );
		//
		// --- calculate position of dragging
		//
		x := x - iTextureDragX + xp;
		y := y - iTextureDragY + yp;
		//
		With ImageTexture.Canvas Do
		Begin
			Pen.Mode := pmXor;
			Pen.Color := clWhite;
			//
			MoveTo ( x, y );
			LineTo ( x + xs - 1, y );
			LineTo ( x + xs - 1, y + ys - 1 );
			LineTo ( x, y + ys - 1 );
			LineTo ( x, y );
			//
			Pen.Mode := pmCopy;
		End;
	End;
End;

procedure TFormMain.ImageTextureMouseDown(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
	i, ID : Integer;
	x0, y0, x1, y1 : Integer;
Begin
	If ssLeft in Shift Then
	Begin
		//
		i := GridTexturePatches.RowCount - 1;
		ID := 0;
		//
		While ( i > 0 ) And ( ID = 0 ) Do
		Begin
			ID := SafeVal ( GridTexturePatches.Cells [ 0, i ] );
			//
			x0 := iTexture_xc + Round ( TexturePatches [ ID ].xPos * TextureZoom );
			y0 := iTexture_yc + Round ( TexturePatches [ ID ].yPos * TextureZoom );
			x1 := iTexture_xc + Round ( ( TexturePatches [ ID ].xPos + TexturePatches [ ID ].xSize ) * TextureZoom );
			y1 := iTexture_yc + Round ( ( TexturePatches [ ID ].yPos + TexturePatches [ ID ].ySize ) * TextureZoom );
			//
			//ImageTexture.Canvas.FrameRect ( Classes.Rect ( x0, y0, x1, y1 ) );
			//
			If ( x0 <= X ) And ( x1 >= X ) And ( y0 <= Y ) And ( y1 >= Y ) Then
			Begin
				//
			End
			Else
			Begin
				Dec ( i );
				ID := 0;
			End;
		End;
		//
		If ID > 0 Then
		Begin
			GridTexturePatches.Row := i;
		End;
		//
		iTextureDragX := X;
		iTextureDragY := Y;
		//
		TextureDrawDragFrame ( X, Y );
		//
	End;
end;

procedure TFormMain.ImageTextureMouseMove(Sender: TObject;
	Shift: TShiftState; X, Y: Integer);
Begin
	If ssLeft in Shift Then
	Begin
		TextureDrawDragFrame ( iTextureLastX, iTextureLastY );
		TextureDrawDragFrame ( X, Y );
	End;
end;

procedure TFormMain.ImageTextureMouseUp(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
	ID, iRow : Integer;
Begin
	If Button = mbLeft Then
	Begin
		TextureDrawDragFrame ( iTextureLastX, iTextureLastY );
		//
		// --- moved to x, y
		//
		ID := PatchCurrentID;
		If ID > 0 Then
		Begin
			TexturePatches [ ID ].xPos := TexturePatches [ ID ].xPos - Round ( ( iTextureDragX - X ) / TextureZoom );
			TexturePatches [ ID ].yPos := TexturePatches [ ID ].yPos - Round ( ( iTextureDragY - Y ) / TextureZoom );
			//
			With GridTexturePatches Do
			Begin
				iRow := Row;
				Cells [ 3, Row ] := IntToStr ( TexturePatches [ ID ].xPos );
				Cells [ 4, Row ] := IntToStr ( TexturePatches [ ID ].yPos );
				//
				TextureShow ( LastTexture );
				//
				Row := iRow;
			End;
			//
			Modified ( True );
		End;
	End;
end;

procedure TFormMain.GridTexturesSelectCell(Sender: TObject; ACol,
	ARow: Integer; Var CanSelect: Boolean);
Begin
	If ARow <> LastTexture Then
	Begin
		TextureShow ( ARow );
	End;
end;

procedure TFormMain.TextureSplitter1Moved(Sender: TObject);
Begin
	// invalidate
	PanelTexture.Tag := 1;
	TextureDraw ( LastTexture );
end;

procedure TFormMain.TextureSplitter2Moved(Sender: TObject);
Var
	sbx : Integer;
	tw : Integer;
	w0, w1, w1l : Integer;
	i : Integer;
begin
	sbx := GetSystemMetrics ( SM_CXVSCROLL );
	//
	tw := GridTextures.Width - sbx - 12;
	//
	w0 := 68;
	w1 := ( tw - w0 ) Div 6;
	If ( w1 < 24 ) Then
	Begin
		w1 := 24;
		w1l := 24;
	End
	Else
	Begin
		If ( w1 > 44 ) Then
		Begin
			w1 := 44;
			w0 := tw - ( 6 * w1 );
		End;
		w1l := tw - w0 - w1 * 5;
	End;
	//
	GridTextures.ColWidths [ 0 ] := w0;
	For i := 1 To 5 Do
	Begin
		GridTextures.ColWidths [ i ] := w1;
	End;
	GridTextures.ColWidths [ 6 ] := w1l;
end;

procedure TFormMain.GridTexturePatchesKeyPress(Sender: TObject;
	Var Key: Char);
Var
	s : String;
	i : Integer;
	tb : TFormTBrowse;
Begin
	Case Key Of

		#13 : // enter
		Begin
			With TStringGrid ( Sender ) Do
			Begin
				// in third column (patch name)...
				If Col = 2 Then
				Begin
					// ...bring up the texture browser
					tb := TFormTBrowse.Create ( Self );
					tb.Mode := tbmTexture;
					tb.GotoImage ( Cells [ Col, Row ] );
					tb.ShowModal;
					Cells [ Col, Row ] := tb.Selected;
					tb.Free;
				End;
			End;
		End;

		'+' :
		Begin
			With TStringGrid ( Sender ) Do
			Begin
				s := Cells [ Col, Row ];
				If IsNumbers ( s ) Then
				Begin
					i := StrToInt ( s ) + 1;
					Cells [ Col, Row ] := IntToStr ( i );
					//
					// --- update patch name if ID is changed
					If Col = 1 Then
					Begin
						GridTexturePatches.Cells [ 2, Row ] := PatchNameByID ( i );
					End;
					//
					GridTexturePatchesSetEditText ( Sender, Col, Row, Cells [ Col, Row ] );
					//
					Key := #0;
				End;
			End;
		End;

		'-' :
		Begin
			With TStringGrid ( Sender ) Do
			Begin
				s := Cells [ Col, Row ];
				If IsNumbers ( s ) Then
				Begin
					i := StrToInt ( s ) - 1;
					Cells [ Col, Row ] := IntToStr ( i );
					//
					// --- update patch name if ID is changed
					If Col = 1 Then
					Begin
						GridTexturePatches.Cells [ 2, Row ] := PatchNameByID ( i );
					End;
					//
					GridTexturePatchesSetEditText ( Sender, Col, Row, Cells [ Col, Row ] );
					//
					Key := #0;
				End;
			End;
		End;

	End;
end;

procedure TFormMain.GridTexturesKeyPress(Sender: TObject; Var Key: Char);
Var
	s : String;
Begin
	Case Key Of

		#13 :
		Begin
			Key := #0;
			TextureQuickFind.SetFocus;
		End;

		'*' :
		Begin
			With TStringGrid ( Sender ) Do
			Begin
				s := Cells [ Col, Row ];
				If IsNumbers ( s ) Then
				Begin
					Cells [ Col, Row ] := IntToStr ( StrToInt ( s ) * 2 );
				End;
			End;
			Key := #0;
			Modified ( True );
		End;

		'/' :
		Begin
			With TStringGrid ( Sender ) Do
			Begin
				s := Cells [ Col, Row ];
				If IsNumbers ( s ) Then
				Begin
					Cells [ Col, Row ] := IntToStr ( StrToInt ( s ) Div 2 );
				End;
			End;
			Key := #0;
			Modified ( True );
		End;

		'+' :
		Begin
			With TStringGrid ( Sender ) Do
			Begin
				s := Cells [ Col, Row ];
				If IsNumbers ( s ) Then
				Begin
					Cells [ Col, Row ] := IntToStr ( StrToInt ( s ) + 1 );
				End;
			End;
			Key := #0;
			Modified ( True );
		End;

		'-' :
		Begin
			With TStringGrid ( Sender ) Do
			Begin
				s := Cells [ Col, Row ];
				If IsNumbers ( s ) Then
				Begin
					Cells [ Col, Row ] := IntToStr ( StrToInt ( s ) - 1 );
				End;
			End;
			Key := #0;
			Modified ( True );
		End;

		Else
		Begin
			Modified ( True );
		End;

	End;
end;

procedure TFormMain.GridTexturePatchesKeyDown(Sender: TObject;
	Var Key: Word; Shift: TShiftState);
Begin
	//Caption := IntToStr ( Key );
end;

procedure TFormMain.GridTexturesKeyDown(Sender: TObject; Var Key: Word;
	Shift: TShiftState);
Begin
	Case Key Of
		45 : // Insert
		Begin
			mnuTextureNewClick ( Sender );
		End;

		46 : // Delete
		Begin
			If ssAlt in Shift Then
			Begin
				mnuTextureDeleteClick ( Sender );
			End;
		End;

		Else
		Begin
			//Caption := 'Key=' + IntToStr ( Key );
		End;
	End;
end;

procedure TFormMain.mnuTextureNewClick(Sender: TObject);
Begin
	//
	// *** Insert new texture
	//
	Inc ( nTextures );
	With Textures [ nTextures ] Do
	Begin
		Name := 'UNTITLED';
		DataPosition := 0;
		Flags := 0;
		sp2 := 0;
		xScale := 0;
		yScale := 0;
		xs := 64;
		ys := 64;
		PatchStart := 0;
		PatchCount := 0;
	End;
	//
	With GridTextures Do
	Begin
		// --- only add new line, if this is not the first
		If nTextures > 1 Then
		Begin
			RowCount := RowCount + 1;
		End;
		//
		TextureDraw ( nTextures );
		Row := nTextures;
		UpdateTexture ( nTextures );
	End;
	//
	Modified ( True );
end;

procedure TFormMain.mnuTextureDuplicateClick(Sender: TObject);
Var
	s, c : String;
	iCount, iMul : Integer;
	iPS : Integer;
Begin
	If nTextures > 0 Then
	Begin
		//
		// *** Insert new texture
		//
		Inc ( nTextures );
		With Textures [ nTextures ] Do
		Begin
			//
			// --- Create new name
			//
			s := Trim ( Textures [ LastTexture ].Name );
			iCount := 0;
			iMul := 1;
			//
			c := Copy ( s, Length ( s ), 1 );
			While ( c >= '0' ) And ( c <= '9' ) Do
			Begin
				iCount := iCount + ( Ord ( c [ 1 ] ) - 48 ) * iMul;
				iMul := iMul * 10;
				s := Copy ( s, 1, Length ( s ) - 1 );
				c := Copy ( s, Length ( s ), 1 );
			End;
			//
			Inc ( iCount );
			c := IntToStr ( iCount );
			If Length ( s + c ) > 8 Then
			Begin
				s := Copy ( s, 1, 8 - Length ( c ) );
			End;
			s := s + c;
			Name := s;
			//
			// --- Copy properties
			//
			DataPosition := 0;
			sp2 := 0;
			//
			Flags := Textures [ LastTexture ].Flags;
			xs := Textures [ LastTexture ].xs;
			ys := Textures [ LastTexture ].ys;
			xScale := Textures [ LastTexture ].xScale;
			yScale := Textures [ LastTexture ].yScale;
			//
			PatchStart := 0; // reset patches first!
			PatchCount := 0;
			//
			If Textures [ LastTexture ].PatchCount > 0 Then
			Begin
				PatchStart := nTexturePatches + 1;
				//
				For iCount := 1 To Textures [ LastTexture ].PatchCount Do
				Begin
					Inc ( PatchCount );
					Inc ( nTexturePatches );
					//
					iPS := Textures [ LastTexture ].PatchStart + iCount - 1;
					TexturePatches [ nTexturePatches ].ID := TexturePatches [ iPS ].ID;
					TexturePatches [ nTexturePatches ].xPos := TexturePatches [ iPS ].xPos;
					TexturePatches [ nTexturePatches ].yPos := TexturePatches [ iPS ].yPos;
					TexturePatches [ nTexturePatches ].sp1 := TexturePatches [ iPS ].sp1;
				End;
			End;
		End;
		//
		With GridTextures Do
		Begin
			// --- only add new line, if this is not the first
			If nTextures > 1 Then
			Begin
				RowCount := RowCount + 1;
			End;
			//
			Row := nTextures;
			UpdateTexture ( nTextures );
		End;
		//
		Modified ( True );
	End;
end;

procedure TFormMain.mnuTextureDeleteClick(Sender: TObject);
Var
	i, ps, pn : Integer;
Begin
	If nTextures > 0 Then
	Begin
		//
		// Save number of patches and PatchStart for later
		//
		pn := Textures [ LastTexture ].PatchCount;
		ps := Textures [ LastTexture ].PatchStart;
		//
		// All textures after current one
		//
		For i := LastTexture To nTextures - 1 Do
		Begin
			// move ahead
			Textures [ i ] := Textures [ i + 1 ];
			// fix PatchStart value
			Dec ( Textures [ i ].PatchStart, pn );
			// update on screen
			UpdateTexture ( i );
		End;
		//
		// One less texture
		//
		Dec ( nTextures );
		If ( GridTextures.Row = GridTextures.RowCount - 1 )
		And ( GridTextures.Row > 1 ) Then
			GridTextures.Row := GridTextures.Row - 1;
		If GridTextures.RowCount > 2 Then
			GridTextures.RowCount := GridTextures.RowCount - 1; // remove last row from screen
		//
		// ---
		//
		For i := ps + pn To nTexturePatches Do
		Begin
			TexturePatches [ i - pn ] := TexturePatches [ i ];
		End;
		//
		// [pn] less texture patches
		//
		Dec ( nTexturePatches, pn );
		//
		//
		//
		{
		If LastTexture >= nTextures Then
		Begin
			Dec ( LastTexture );
			GridTextures.Row := LastTexture;
		End;
		}
		TextureShow ( LastTexture );
		//
		Modified ( True );
	End;
end;

procedure TFormMain.mnuTextureNewPatchClick(Sender: TObject);

Var
	NewPatchID : Integer;
	iCount : Integer;

procedure NiceAlign ( PatchID : Integer );
Var
	iEntry : Integer;
	x, y, xr, yr : Integer;
Begin
	x := Patches [ PatchID ].xs;
	y := Patches [ PatchID ].ys;
	//
	If ( x = 0 ) And ( y = 0 ) Then
	Begin
		iEntry := FindEntry ( PatchNameByID ( PatchID ) );
		If iEntry > 0 Then
		Begin
			ImageGetDetails ( iEntry, x, y, xr, yr );
		End;
	End;
	//
	If TexturePatches [ NewPatchID - 1 ].xPos + x < Textures [ LastTexture ].xs Then
	Begin
		TexturePatches [ NewPatchID ].xPos := TexturePatches [ NewPatchID - 1 ].xPos + x;
		TexturePatches [ NewPatchID ].yPos := TexturePatches [ NewPatchID - 1 ].yPos;
	End
	Else
	Begin
		If TexturePatches [ NewPatchID - 1 ].yPos + y < Textures [ LastTexture ].ys Then
		Begin
			TexturePatches [ NewPatchID ].xPos := 0;
			TexturePatches [ NewPatchID ].yPos := TexturePatches [ NewPatchID - 1 ].yPos + y;
		End
		Else
		Begin
			TexturePatches [ NewPatchID ].xPos := 0;
			TexturePatches [ NewPatchID ].yPos := 0;
		End;
	End;
End;

Begin
	If nTextures > 0 Then
	Begin
		If LastTexture = 0 Then
		Begin
			LastTexture := nTextures;
		End;
		//
		If LastTexture < nTextures Then
		Begin
			If Textures [ LastTexture ].PatchCount = 0 Then
			Begin
				//
				iCount := LastTexture;
				NewPatchID := 0;
				//
				// Until the texture has no patches...
				While ( NewPatchID = 0 ) And ( Textures [ iCount ].PatchCount = 0 ) Do
				Begin
					If iCount = 1 Then
					Begin
						// first one, so pick
						// brand new, goes to the very end
						NewPatchID := nTexturePatches + 1;
					End
					Else
					Begin
						Dec ( iCount ); // ...keep going back
					End;
				End;
				// found previous texture with patches
				NewPatchID := Textures [ iCount ].PatchStart +
					Textures [ iCount ].PatchCount;
			End
			Else
			Begin
				// add this patch to the end of the patches of this texture :-)
				NewPatchID := Textures [ LastTexture ].PatchStart +
					Textures [ LastTexture ].PatchCount;
			End;
		End
		Else
		Begin
			// brand new, goes to the very end
			NewPatchID := nTexturePatches + 1;
		End;
		//
		// *** Move subsequent pathces forward (if necessary)
		//
		For iCount := nTexturePatches + 1 DownTo NewPatchID + 1 Do
		Begin
			TexturePatches [ iCount ] := TexturePatches [ iCount - 1 ];
		End;
		//
		// *** Fix PatchStart for subsequent textures (if necessary)
		//
		For iCount := LastTexture + 1 To nTextures Do
		Begin
			Inc ( Textures [ iCount ]. PatchStart );
		End;
		//
		Inc ( nTexturePatches );
		//
		// *** Initialize the new texture patch ***
		//
		With TexturePatches [ NewPatchID ] Do
		Begin
			//
			ID := nPatches - 1;
			xPos := 0;
			yPos := 0;
			//
			If LastTexture > 0 Then
			Begin
				If ( Textures [ LastTexture ].PatchCount > 0 ) Then
				Begin
					ID := TexturePatches [
						Textures [ LastTexture ].PatchStart +
						Textures [ LastTexture ].PatchCount - 1 ].ID;
					//
					NiceAlign ( ID );
				End;
			End;
		End;
		//
		// *** Attach it...
		//
		Inc ( Textures [ LastTexture ].PatchCount );
		If Textures [ LastTexture ].PatchCount = 1 Then
		Begin
			Textures [ LastTexture ].PatchStart := NewPatchID;
		End;
		//
		// --- Update screen
		//
		TextureShow ( LastTexture );
		//
		GridTexturePatches.SetFocus;
		GridTexturePatches.Row := GridTexturePatches.RowCount - 1;
		//
		Modified ( True );
	End;
End;

procedure TFormMain.mnuTexturesSaveClick(Sender: TObject);
Begin
	TextureSave;
end;

procedure TFormMain.GridTexturePatchesSetEditText(Sender: TObject; ACol,
	ARow: Integer; const Value: String);
Var
	s : String;
	ID, iValue : Integer;
	PatchID : Integer;
	bChanged : Boolean;
Begin
	//
	// --- Update patch properties from the grid
	//
	ID := SafeVal ( GridTexturePatches.Cells [ 0, ARow ] );
	iValue := SafeVal ( GridTexturePatches.Cells [ ACol, ARow ] );
	//
	bChanged := False;
	//
	Case ACol Of
		//
    0 :
    Begin
      GridTexturePatches.Cells [ 0, ARow ] := IntToStr ( Textures [ LastTexture ].PatchStart + ARow - 1 );
    End;
    //
		1 :
		Begin
			If TexturePatches [ ID ].ID <> iValue Then
			Begin
				TexturePatches [ ID ].ID := iValue;
				GridTexturePatches.Cells [ 2, ARow ] := PatchName ( ID );
				bChanged := True;
			End;
		End;
		//
		2 :
		Begin
			// look up patch name
			s := Trim ( UpperCase ( GridTexturePatches.Cells [ ACol, ARow ] ) );
			PatchID := 0;
			While ( PatchID < nPatches ) And Not bChanged Do
			Begin
				If Trim ( UpperCase ( Patches [ PatchID ].Name ) ) = s Then
				Begin
					bChanged := True;
					//
					TexturePatches [ ID ].ID := PatchID;
					GridTexturePatches.Cells [ 1, ARow ] := IntToStr ( PatchID );
				End
				Else
				Begin
					Inc ( PatchID );
				End;
			End;
		End;
		//
		3 :
		Begin
			If TexturePatches [ ID ].xPos <> iValue Then
			Begin
				TexturePatches [ ID ].xPos := iValue;
				bChanged := True;
			End;
		End;
		//
		4 :
		Begin
			If TexturePatches [ ID ].yPos <> iValue Then
			Begin
				TexturePatches [ ID ].yPos := iValue;
				bChanged := True;
			End;
		End;
	End;
	//
	If bChanged Then
	Begin
		TextureDraw ( LastTexture );
		Modified ( True );
	End;
end;

procedure TFormMain.GridTexturesSetEditText(Sender: TObject; ACol,
	ARow: Integer; const Value: String);
Begin
	Case ACol Of

		0 :
		Begin
			Textures [ ARow ].Name := Value;
		End;

		1 :
		Begin
			If IsNumbers ( Value ) Then
			Begin
				Textures [ ARow ].xs := StrToInt ( Value );
			End;
		End;

		2 :
		Begin
			If IsNumbers ( Value ) Then
			Begin
				Textures [ ARow ].ys := StrToInt ( Value );
			End;
		End;

		3 :
		Begin
			If IsNumbers ( Value ) Then
			Begin
				Textures [ ARow ].xScale := StrToInt ( Value );
			End;
		End;

		4 :
		Begin
			If IsNumbers ( Value ) Then
			Begin
				Textures [ ARow ].yScale := StrToInt ( Value );
			End;
		End;

    5 :
    Begin
      If IsNumbers ( Value ) Then
      Begin
        Textures [ ARow ].Flags := StrToInt ( Value );
      End;
    End;

	End;
end;

procedure TFormMain.TextureQuickFindKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	FormKeyDown ( Sender, Key, Shift );
end;

procedure TFormMain.TextureQuickFindKeyPress(Sender: TObject;
	Var Key: Char);
Var
	i : Integer;
	s : String;

Procedure FindPixels ( FindColor_Lo, FindColor_Hi : Integer; FindString : String; Light : Boolean );
Const
	FindingsMax = 2000;
Type
	TFindings = Record
		PatchID : Integer;
		xp, yp : Integer;
		ExtraColors : Integer;
	End;
Var
	iPatch : Integer;
	xs, ys : Integer;
	x, y, ym : Integer;
	mColor : Integer;
	len : Integer;
	//
	rt, gt, bt : Integer;
	//
	dx, dy : Integer;
	//
	nFindings : Integer;
	Findings : Array [ 1 .. FindingsMax ] Of TFindings;
	SwapFindings : TFindings;
	//
	sc : String;

Procedure DisplayFinding ( f : Integer );
Var
	x0, y0, yc : Integer;
Begin
	PatchLoad ( Findings [ f ].PatchID );
	//
	x0 := Findings [ f ].xp;
	y0 := Findings [ f ].yp;
	//
	For yc := 1 To len Do
	Begin
		ImageTexture.Canvas.Brush.Color := cImage.Canvas.Pixels [ x0, y0 + yc - 1 ];
		ImageTexture.Canvas.FillRect ( Classes.Rect ( dx, dy + yc * 8, dx + 8, dy + yc * 8 + 8 ) );
	End;
	Inc ( dx, 10 );
	If ( dx + 16 ) > ImageTexture.Width Then
	Begin
		dx := 16;
		dy := dy + len * 8 + 10;
	End;
End;

Begin
	ImageTexture.Canvas.Brush.Color := RGB ( 100, 140, 180 );
	ImageTexture.Canvas.FillRect ( ImageTexture.Canvas.ClipRect );
	//
	dx := 16;
	dy := 16;
	//
	len := Length ( FindString );
	//
	nFindings := 0;
	//
	iPatch := 0;
	While ( iPatch < nPatches ) And ( nFindings < FindingsMax ) Do
	Begin
		//
		PatchLoad ( iPatch );
		//
		Application.ProcessMessages;
		Caption := Zero ( iPatch, 4 ) + '/' + Zero ( nPatches - 1, 4 ) + ' ' + Comma ( nFindings ) + ' found';
		//
		xs := Patches [ iPatch ].xs;
		ys := Patches [ iPatch ].ys;
		//
		For x := 0 To xs - 1 Do
		Begin
			y := 0;
			While y < ( ys - 1 - len ) Do
			Begin
				ym := 0;
				rt := 0;
				gt := 0;
				bt := 0;
				//
				mColor := ImagePaletteMatch ( cImage.Canvas.Pixels [ x, y + ym ] );
				//
				While ( ym < len )
				And ( ( mColor >= FindColor_Lo ) And ( mColor <= FindColor_Hi ) And ( FindString [ ym + 1 ] = '*' ) )
				Or ( ( ( mColor < FindColor_Lo ) Or ( mColor > FindColor_Hi ) ) And ( FindString [ ym + 1 ] <> '*' ) ) Do
				Begin
					If FindString [ ym + 1 ] <> '*' Then
					Begin
						Inc ( rt, GetRValue ( cImage.Canvas.Pixels [ x, y + ym ] ) );
						Inc ( gt, GetGValue ( cImage.Canvas.Pixels [ x, y + ym ] ) );
						Inc ( bt, GetBValue ( cImage.Canvas.Pixels [ x, y + ym ] ) );
					End;
					//
					Inc ( ym );
					//
					mColor := ImagePaletteMatch ( cImage.Canvas.Pixels [ x, y + ym ] );
				End;
				//
				If ym = len Then
				Begin
					//ShowMessage ( Patches [ iPatch ].Name + ' @ ' + Zero ( x, 4 ) + ',' + Zero ( y, 4 ) );
					//
					If nFindings < FindingsMax Then
					begin
						Inc ( nFindings );
						With Findings [ nFindings ] Do
						Begin
							PatchID := iPatch;
							xp := x;
							yp := y;
							ExtraColors := rt + gt + bt;
						End;
						//
						DisplayFinding ( nFindings );
					End;
				End;
				//
				Inc ( y );
			End;
		End;
		Inc ( iPatch );
	End;
	//
	If nFindings > 1 Then
	Begin
		//
		dx := 16;
		dy := dy + len * 8 + 20;
		//
		If ( dy + len * 8 + 16 ) > ImageTexture.Height Then
		Begin
			dy := 0;
			dx := dx - 2;
		End;
		//
		For x := 1 To nFindings - 1 Do
		Begin
			ym := x;
			For y := x + 1 To nFindings Do
			Begin
				If Light Then
				Begin
					If Findings [ y ].ExtraColors > Findings [ ym ].ExtraColors Then
						ym := y;
				End
				Else
				Begin
					If Findings [ y ].ExtraColors < Findings [ ym ].ExtraColors Then
						ym := y;
				End;
			End;
			//
			SwapFindings := Findings [ ym ];
			Findings [ ym ] := Findings [ x ];
			Findings [ x ] := SwapFindings;
		End;
		//
		sc := '';
		For x := 1 To 40 Do
		Begin
			DisplayFinding ( x );
			//
			If ( x Mod 5 ) = 0 Then
				dx := dx + 10;
			//
			y := 1;
			While TexturePatches [ y ].ID <> Findings [ x ].PatchID Do
				Inc ( y );
			//
			ym := 1;
			While ( ym <= nTextures )
			And ( ( Textures [ ym ].PatchStart > y )
			Or ( Textures [ ym ].PatchStart + Textures [ ym ].PatchCount - 1 < y )
			Or ( Textures [ ym ].Animated <> taNone ) ) Do
			Begin
				Inc ( ym );
			End;
			//
			If ym <= nTextures Then
			Begin
				ImageTexture.Canvas.Brush.Color := RGB ( 140, 180, 220 );
				ImageTexture.Canvas.TextOut ( ImageTexture.Width - 240, x * 12,
					Zero ( x, 3 ) + ': ' +
					Textures [ ym ].Name + ' (' +
					Patches [ Findings [ x ].PatchID ].Name + ') ' +
					Zero ( TexturePatches [ y ].xPos + Findings [ x ].xp, 3 ) + ',' +
					Zero ( TexturePatches [ y ].yPos + Findings [ x ].yp, 3 ) );
				//
				sc := sc + #9 + #9 + 't = "' + Textures [ ym ].Name + '"' + #13 +
					#9 + #9 + 'x = ' + IntToStr ( TexturePatches [ y ].xPos + Findings [ x ].xp ) + #13 +
					#9 + #9 + 'y = ' + IntToStr ( TexturePatches [ y ].yPos + Findings [ x ].yp ) + #13 +
					#9 + #9 + 'call line' + #13;
			End;
		End;
		//
		InputBox ( sc, sc, sc );
	End;
	//
End;

Begin
	Case Key Of
		#13 :
		Begin
			Key := #0;
			//
			s := UpperCase ( Trim ( TextureQuickFind.Text ) );
			//
			If Length ( s ) > 0 Then
			Begin
				//
				i := 1; // skip first row with column names
				While i <= nTextures Do
				Begin
					If BeginsWith ( GridTextures.Cells [ 0, i ], s ) Then
					Begin
						GridTextures.Row := i;
						GridTextures.SetFocus;
						i := nTextures + 1;
					End
					Else
					Begin
						Inc ( i );
					End;
				End;
			End;
		End;

		'!' :
		Begin
			TextureRebuildFlags;
			FindPixels ( 168, 191, '.*****.', False );
		End;

		'+' :
		Begin
			Key := #0;
			If TextureZoom < 5 Then
			Begin
				TextureZoom := TextureZoom + 0.5;
				TextureDraw ( LastTexture );
			End;
		End;

		'-' :
		Begin
			Key := #0;
			If TextureZoom > 0.5 Then
			begin
				TextureZoom := TextureZoom - 0.5;
				TextureDraw ( LastTexture );
			End;
		End;

	End;
end;

procedure TFormMain.mnuPL_FindSectorsClick(Sender: TObject);
Var
	s : String;
	sMap : String;
	iSector, iMap : Integer;
	iUseCount : Integer;
	i : Integer;

procedure FindThroughSector ( iEntry : Integer );
Var
	i, sc, ic, iLen : Integer;
	iColLen : Integer;
	iSectorCount : Integer;
	s8 : String;
	dummy : Array [ 0 .. 255 ] Of Byte;
Begin
	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( F, WadEntries [ iEntry ].Position );
	//
	iSectorCount := 0;
	i := 0;
	iLen := WadEntries [ iEntry ].Size;
	//
	While i < iLen Do
	Begin
		//
		sc := WadEntryTypes [ iSector ].ColStart;
		For ic := 0 To WadEntryTypes [ iSector ].Cols - 1 Do
		Begin
			iColLen := WadEntryCols [ sc + ic ].iLen;
			//
			If iColLen = 8 Then
			Begin
				s8 := GetString ( f, 8 );
				If UpperCase ( Trim ( s8 ) ) = s Then
				Begin
					// Found !
					Inc ( iUseCount );
					//
					MemoHex.Lines.Add ( '[Entry: ' + Comma ( iEntry ) + '] ' +
						'[Map: ' + sMap + '] ' +
						WadEntries [ iEntry ].Name + ' [Sector: ' +
						Comma ( iSectorCount ) + '] ' + WadEntryCols [ sc + ic ].Desc );
				End;
			End
			Else
			Begin
				BlockRead ( F, dummy, iColLen );
			End;
			//
			Inc ( i, iColLen );
		End;
		//
		Inc ( iSectorCount );
	End;
	fClose;
end;

Begin
	If ListWad.SelCount = 1 Then
	Begin
		s := UpperCase ( Trim ( ListWad.Selected.Caption ) );
		//
		iSector := FindEntryType ( 'SECTOR' );
		iMap := FindEntryType ( 'MAP' );
		//
		If iSector > 0 Then
		Begin
			//
			MemoHex.Lines.Clear;
			sMap := '???';
			//
			For i := 1 To nWadEntries Do
			Begin
				If MatchName ( Trim ( WadEntries [ i ].Name ), WadEntryTypes [ iSector ].Entry ) Then
				Begin
					FindThroughSector ( i );
				End
				Else
				Begin
					If MatchName ( Trim ( WadEntries [ i ].Name ), WadEntryTypes [ iMap ].Entry ) Then
					Begin
						sMap := Trim ( WadEntries [ i ].Name );
					End;
				End;
			End;
			//
			If iUseCount = 0 Then
			Begin
				MemoHex.Lines.Add ( 'This entry is not used in any sectors.' );
			End
			Else
			Begin
				MemoHex.Lines.Add ( '--- Used ' + Comma ( iUseCount ) + ' times.' );
			End;
			//
			ShowPage ( edHex );
		End;
	End;
end;

procedure TFormMain.mnuEntryNewClick(Sender: TObject);
Var
	s : String;
	iEntryPos, iListEntry : Integer;
Begin
	If CheckFileExtModified Then
	Begin
		If CheckModified Then
		Begin
			iWadEntryType := 0;
			//
			s := 'UNTITLED';
			If InputQuery ( 'New entry', 'Enter entry name', s ) Then
			Begin
				s := Copy ( Trim ( s ), 1, 8 );
				If Not gDontAutoCapitalize Then
				Begin
					s := UpperCase ( s );
				End;
				//
				If s <> '' Then
				Begin
					WadEntryNewGetPos ( iEntryPos, iListEntry );
					//
					WadEntryNewAtPos ( s, iEntryPos, iListEntry, False );
					//
					//AddNewWadEntry ( s ); // add users new entry
					//ShowEntry ( '', False ); // ...and select it
				End;
			End;
		End;
	End;
end;

Procedure TFormMain.CopyEntryFromMain ( iEntry : Integer );
Var
	fm : File;
Begin
	//
	// Gets added to end of list
	//
	WadEntryNew ( MainWadEntries [ iEntry ].Name );
	//
	// Copy the lump from the main WAD to a temporary file
	//
	fOpenTemp;
	//
	AssignFile ( fm, sMainWAD );
	FileMode := fmOpenRead; // read-only by default
	Reset ( fm, 1 );
	//
	Seek ( fm, MainWadEntries [ iEntry ].Position );
	CopyData ( fm, fo, MainWadEntries [ iEntry ].Size );
	//
	CloseFile ( fm );
	CloseFile ( fo );
	//
	// Copy it into our WAD (no undo, no refresh)
	//
	ReplaceFile ( nWadEntries, sTempFile, False, False );
End;

Function TFormMain.ImagePaletteMatch ( Color : Integer ) : Byte;
Begin
	ImagePaletteMatch := ImagePaletteMatchRGB (
		Color And 255, ( Color Shr 8 ) And 255, ( Color Shr 16 ) And 255 );
End;

Function TFormMain.ImagePaletteMatchRGB ( r, g, b : Byte ) : Byte;
Begin
	ImagePaletteMatchRGB := ImagePaletteMatchRGBRange ( r, g, b, 0, 255 );
End;

Function TFormMain.ImagePaletteMatchRGBRange ( r, g, b, iStart, iEnd : Byte ) : Byte;
Var
	BestPal, BestTDiff, BestIDiff,
	CurrPal, TDiff, IDiff : Integer;
	pr, pg, pb : Byte; // palette r,g,b
Begin
	//
	// --- Special check : CYAN    (00FFFF) for transparency
	//                   : MAGENTA (FC00FC) for transparency
	//
	If ( ( r = 0 ) And ( g = 255 ) And ( b = 255 ) )
	Or ( ( r = 252 ) And ( g = 0 ) And ( b = 252 ) ) Then
	Begin
		BestPal := 247; // special color
	End
	Else
	Begin
		//
		BestPal := 0;
		BestTDiff := 100000;
		BestIDiff := 100000;
		//
		CurrPal := iStart;
		While ( CurrPal <= iEnd ) And ( BestTDiff > 0 ) Do
		Begin
			pr := Pal [ CurrPal ] And 255;
			pg := Pal [ CurrPal ] Shr 8 And 255;
			pb := Pal [ CurrPal ] Shr 16 And 255;
			//
			If ( pr = r ) And ( pg = g ) And ( pb = b ) Then
			Begin
				BestTDiff := 0;
				BestPal := CurrPal;
			End
			Else
			Begin
				TDiff := Abs ( pr - r ) + Abs ( pg - g ) + Abs ( pb - b );
				IDiff := Abs ( pr - r );
				If IDiff < Abs ( pg - g ) Then IDiff := Abs ( pg - g );
				If IDiff < Abs ( pb - b ) Then IDiff := Abs ( pb - b );
				//
				If ( BestTDiff > TDiff )
				Or ( ( BestTDiff >= TDiff ) And ( BestIDiff > IDiff ) ) Then
				Begin
					BestTDiff := TDiff;
					BestIDiff := IDiff;
					BestPal := CurrPal;
				End;
			End;
			Inc ( CurrPal );
		End;
		//
	End;
	//
	// return matching color
	ImagePaletteMatchRGBRange := BestPal;
End;

Function TFormMain.ImagePaletteMatchNew ( Color : Integer ) : Word;
Begin
	ImagePaletteMatchNew := ImagePaletteMatchRGBNew (
		Color And 255, ( Color Shr 8 ) And 255, ( Color Shr 16 ) And 255 );
End;

Function TFormMain.ImagePaletteMatchRGBNew ( r, g, b : Byte ) : Word;
Begin
	ImagePaletteMatchRGBNew := ImagePaletteMatchRGBRangeNew ( r, g, b, 0, 255 );
End;

Function TFormMain.ImagePaletteMatchRGBRangeNew ( r, g, b, iStart, iEnd : Byte ) : Word;
Var
	BestPal, BestTDiff, BestIDiff,
	CurrPal, TDiff, IDiff : Integer;
	pr, pg, pb : Byte; // palette r,g,b
Begin
	//
	// --- Special check : CYAN    (00FFFF) for transparency
	//                   : MAGENTA (FF00FF) for transparency
	//
	If ( ( r = 0 ) And ( g = 255 ) And ( b = 255 ) )
	Or ( ( r = 252 ) And ( g = 0 ) And ( b = 252 ) )
	Or ( ( ImageFormat = fmtPNG ) And ( r + b Shl 8 + g Shl 16 = Image_PNG_Transparent_Color ) ) Then
	Begin
		BestPal := $100; // special color
	End
	Else
	Begin
		//
		BestPal := 0;
		BestTDiff := 100000;
		BestIDiff := 100000;
		//
		CurrPal := iStart;
		While ( CurrPal <= iEnd ) And ( BestTDiff > 0 ) Do
		Begin
			pr := Pal [ CurrPal ] And 255;
			pg := Pal [ CurrPal ] Shr 8 And 255;
			pb := Pal [ CurrPal ] Shr 16 And 255;
			//
			If ( pr = r ) And ( pg = g ) And ( pb = b ) Then
			Begin
				BestTDiff := 0;
				BestPal := CurrPal;
			End
			Else
			Begin
				TDiff := Abs ( pr - r ) + Abs ( pg - g ) + Abs ( pb - b );
				IDiff := Abs ( pr - r );
				If IDiff < Abs ( pg - g ) Then IDiff := Abs ( pg - g );
				If IDiff < Abs ( pb - b ) Then IDiff := Abs ( pb - b );
				//
				If ( BestTDiff > TDiff )
				Or ( ( BestTDiff >= TDiff ) And ( BestIDiff > IDiff ) ) Then
				Begin
					BestTDiff := TDiff;
					BestIDiff := IDiff;
					BestPal := CurrPal;
				End;
			End;
			Inc ( CurrPal );
		End;
		//
	End;
	//
	// return matching color
	ImagePaletteMatchRGBRangeNew := BestPal;
End;

function TFormMain.ImageConvertToDoom ( xs, ys, xr, yr : Integer ) : String;

Var
	x, y, yd, yt,
	yStart, yMax : Integer;
	//
	r, g, b : Integer;
	//
	fs : File;
	sNewTemp : String;
	//
	StartPos, FSize : Integer;
	//
	bMemory : Boolean;
	pdPos : Integer;

Procedure SequenceCloseLast;
Begin
	// Send closing bytes to last sequence
	//
	// -- Go back to starting pos
	//    and save length of sequence written
	//
	Seek ( fo, StartPos );
	SendByte ( fo, g );
	//
	Seek ( fo, FSize );
	SendByte ( fo, 0 );
	Inc ( FSize, 1 );
	//
	If ( yd >= 254 ) Then
	Begin
		yd := y - g;
	End;
End;

Procedure SequenceStartNew;
Var
	ys : Integer;
Begin
	// Send starting sequence
	ys := y - yd;
	If ys > 254 Then ys := 254;
	SendByte ( fo, Byte ( ys ) );
	Inc ( FSize );
	//
	StartPos := FSize;  // remember starting pos
	SendByte ( fo, 0 ); // send a 'zero' as length now...
	//
	SendByte ( fo, 0 );
	Inc ( FSize, 2 );
	//
	g := 0; // reset length
End;

Begin
	PreparePalette;
	//
	// --- new
	//
	If ( sListWadFilter = 'FLOOR' )
	And ( ( ( xs = 64 ) And ( ys = 64 ) )
	Or ( ( xs = 128 ) And ( ys = 128 ) )
	Or ( ( xs = 256 ) And ( ys = 256 ) ) ) Then
	Begin

		Starting;
		fOpenTemp;
		For y := 0 To ys - 1 Do
		Begin
			//
			for x := 0 To xs - 1 Do
			Begin
				SendByte ( fo, ImagePaletteMatch ( cImage.Canvas.Pixels [ x, y ] ) );
			End;
		End;
		//
		If sTempFile <> '' Then
		Begin
			CloseFile ( fo );
			//
			sNewTemp := sTempFile;
			//
		End;
	End
	Else
	Begin
		//
		// Regular images
		//
		Starting;
		//
		bMemory := ( xs * ys * 2 ) < SizeOf ( TPicData );
		pdPos := 0;
		If bMemory Then
		Begin
			GetMem ( PicData, xs * ys * 2 );
		End
		Else
		Begin
			fOpenTemp;
		End;
		//
		For x := 0 To xs - 1 Do
		Begin
			//
			If ( x And 15 ) = 0 Then
			Begin
				Status ( 'Pre-processing ' + IntToStr ( x * 100 Div xs ) + '%' );
			End;
			//
			If bMemory Then
			Begin
				For y := 0 To ys - 1 Do
				Begin
					b := ImagePaletteMatchNew ( cImage.Canvas.Pixels [ x, y ] );
					PicData^ [ pdPos ] := Byte ( b And 255 );
					PicData^ [ pdPos + 1 ] := Byte ( b Shr 8 And 255 );
					Inc ( pdPos, 2 );
				End;
			End
			Else
			Begin
				For y := 0 To ys - 1 Do
				Begin
					SendWord ( fo, ImagePaletteMatchNew ( cImage.Canvas.Pixels [ x, y ] ) );
				End;
			End;
		End;
		//
		If Not bMemory Then
		Begin
			CloseFile ( fo );
		End;
		//
		// Check image size
		//
		yMax := ys;
		yStart := 0;
		//
		// --- Open temporary file...
		//
		If bMemory Then
		Begin
			pdPos := 0;
		End
		Else
		Begin
			sNewTemp := sTempFile;
			AssignFile ( fs, sNewTemp );
			Reset ( fs, 1 );
		End;
		//
		fOpenTemp;
		//
		SendWord ( fo, xs ); // write size
		SendWord ( fo, ys - yStart );
		//
		If Not Image_KeepAlignment Then
		Begin
			If xs < 300 Then
			Begin
				If ( xr = 0 ) Then
					xr := xs Div 2; // default for sprites
				If ( yr = 0 ) Then
					yr := ys - yStart - 4;
			End;
		End;
		//
		SendWord ( fo, xr ); // write x offset
		SendWord ( fo, yr ); // write y offset
		//
		FSize := 8;
		//
		// --- Seek Table
		//
		For x := 0 To xs - 1 Do
		Begin
			SendLong ( fo, 0 ); // use 0's for now
			Inc ( FSize, 4 );
			//SendLong ( fo, 8 + 4 * xs + x * ( ys + 5 ) );
		End;
		//
		// --- Bitmap data
		//
		For x := 0 To xs - 1 Do
		Begin
			//
			if x = 42 then
			begin
				Status ('debug breakpoint');
			end;
			//
			If ( x And 15 ) = 0 Then
			Begin
				Status ( 'Converting ' + IntToStr ( x * 100 Div xs ) + '%' );
			End;
			//
			// --- Seek back and update 'seek table'
			//
			Seek ( fo, 8 + 4 * x );
			SendLong ( fo, FSize );
			Seek ( fo, FSize );
			//
			r := $100;
			g := 0;
			StartPos := -1;
			yd := 0;
			//
			// --- Seek to start pos in temp file
			//     multiply by two, to compensate for saved words
			//
			If bMemory Then
			Begin
				pdPos := x * yMax * 2 + yStart;
			End
			Else
			Begin
				Seek ( fs, x * yMax * 2 + yStart );
			End;
			//
			y := yStart;
			While y < ys Do
			Begin
				//
				If bMemory Then
				Begin
					b := Word ( PicData^ [ pdPos ] Or PicData^ [ pdPos + 1 ] Shl 8 );
					Inc ( pdPos, 2 );
				End
				Else
				Begin
					b := Word ( GetWord ( fs ) );
				End;
				//
				If ( b = $100 ) Then
				Begin
					If ( r <> $100 ) Then
					Begin
						SequenceCloseLast;
					End;
				End
				Else
				Begin
					If ( r = $100 ) Then
					Begin
						While ( y - yd >= 254 ) Do
						Begin
							yt := yd;
							yd := y - 254; // start will be 254
							SequenceStartNew; // add "fake" sequence
							SequenceCloseLast;
							yd := yt + 254;
						End;
						//
						SequenceStartNew;
					End
					Else
					Begin
						// start a new sequence if current seq length is 254 (maximum)
						// or we've first reached row 254
						If ( g = 254 )
						Or ( ( yd = 0 ) And ( y = 254 ) ) Then
						Begin
							SequenceCloseLast;
							SequenceStartNew;
							Inc ( yd, 254 );
						End;
					End;
					SendByte ( fo, Byte ( b ) );
					Inc ( FSize );
					Inc ( g ); // inc sequence length
				End;
				//
				r := b;
				Inc ( y );
			End;
			//
			If r <> $100 Then
			Begin
				SequenceCloseLast;
			End;
			// end of line
			SendByte ( fo, $FF );
			Inc ( FSize, 1 );
		End;
		//
		CloseFile ( fo );
		//
		If bMemory Then
		Begin
			FreeMem ( PicData, xs * ys * 2 );
		End
		Else
		Begin
			// close and delete temp file
			CloseFile ( fs );
			AssignFile ( fo, sNewTemp );
			Erase ( fo );
		End;
		//
	End;
	//
	Status ( 'Finished.' );
	Finished;
	//
	ImageConvertToDoom := sTempFile;
End;

// --- Import

Procedure TFormMain.ImportEntryFile ( iEntry : Integer; sFile : String; bUndo, bForceRaw : Boolean );
Var
	sOrig, ext, s : String;
	Dummy : File;
	FSize : Integer;
	x, y, xr, yr : Integer;
	Format : TImageFormat;
	//
	bDelete : Boolean;
Begin
	sOrig := sFile;
	ext := UpperCase ( KeepFromRight ( sFile, 3 ) );
	//
	AssignFile ( Dummy, sFile );
	FileMode := fmOpenReadWrite;
	Reset ( Dummy, 1 );
	FSize := FileSize ( Dummy );
	CloseFile ( Dummy );
	//
	bDelete := False;
	//
	If Not bForceRaw Then
	Begin
		Format := ImageIdentifyFile ( sFile, 0, FSize, x, y, xr, yr );
		If Format <> fmtNone Then
		Begin
			ImageLoad ( sFile, 0, FSize, x, y, 0, 0, Format );
			sFile := ImageConvertToDoom ( x, y, xr, yr );
			bDelete := True;
			//
			PanelImage.Tag := 0;
		End;
	End;
	//
	If sFile <> '' Then
	Begin
		ReplaceFile ( iEntry, sFile, bUndo, True );
		//
		If bDelete Then
		Begin
			AssignFile ( Dummy, sFile );
			Erase ( Dummy );
		End;
		//
		// ### UPDATE WAD ENTRY ###
		//
		If WadEntries [ iEntry ].Name = 'UNTITLED' Then
		Begin
			s := UpperCase ( RemoveFolder ( Trim ( sOrig ) ) );
			If Pos ( '.', s ) > 0 Then
			Begin
				s := Copy ( s, 1, Pos ( '.', s ) - 1 ); // cut ext
			End;
			If Length ( s ) > 8 Then
			Begin
				s := Copy ( s, 1, 8 ); // max 8 chars
			End;
			If s <> '' Then
			Begin
				WadEntries [ iEntry ].Name := s;
				SaveWadEntryName ( iEntry );
				//
				WadEntryIdentify2 ( iEntry );
				WadEntryIdentify ( iEntry );
			End;
		End;
	End;
End;

procedure TFormMain.mnuEntryLoadClick(Sender: TObject);
Begin
	ImportEntry ( False );
End;

procedure TFormMain.mnuEntryLoadRawClick(Sender: TObject);
begin
	ImportEntry ( True );
end;

procedure TFormMain.ImportEntry ( bForceRaw : Boolean );
Var
	iCnt : Integer;
	s : String;
Begin
	iWadEntryType := 0;
	//
	If sLastFolderImport = '' Then
	begin
		s := sFileName;
		s := Copy ( s, 1, PosR ( '\', s ) - 1 );
	End
	Else
		s := sLastFolderImport;
	//
	OpenDialogImport.InitialDir := s;
	OpenDialogImport.Options := [ofHideReadOnly,ofEnableSizing,ofAllowMultiSelect];
	//
	If OpenDialogImport.Execute Then
	Begin
		//
		iCnt := OpenDialogImport.Files.Count;
		If iCnt > 0 Then
		Begin
			ImportEntries ( OpenDialogImport.Files, bForceRaw );
		End;
	End;
end;

procedure TFormMain.ImportEntries ( Strings : TStrings; bForceRaw : Boolean );
Var
	i, iCnt : Integer;
	iEntry, iListEntry : Integer;
	s : String;
	//
	t0, t1 : Integer;
	bRaw : Boolean;
	//
	Marker : ( marker_None, marker_Floor, marker_Sprite, marker_Patch );
Begin
	iCnt := Strings.Count;
	If iCnt > 0 Then
	Begin
		SaveUndo ( 'Import ' + Comma ( iCnt ) + ' entries' );
		//
		t0 := GetTickCount;
		//
		s := Strings [ 0 ];
		sLastFolderImport := Copy ( s, 1, PosR ( '\', s ) - 1 );
		//
		WadEntryNewGetPos ( iEntry, iListEntry );
		//
		// Special checks
		// if the list is filtered, create markers if they don't exists yet
		//
		Marker := marker_None;
		If sListWadFilter = 'FLOOR' Then
		Begin
			If ( FindEntry ( 'F*_START' ) = 0 ) And ( FindEntry ( 'F*_END' ) = 0 ) Then
			Begin
				Marker := marker_Floor;
			End;
		End;
		If sListWadFilter = 'SPRITE' Then
		Begin
			If ( FindEntry ( 'S*_START' ) = 0 ) And ( FindEntry ( 'S*_END' ) = 0 ) Then
			Begin
				Marker := marker_Sprite;
			End;
		End;
		If sListWadFilter = 'PATCH' Then
		Begin
			//
			TextureForceLoad; // initiate patch adding sequence
			//
			If ( FindEntry ( 'P*_START' ) = 0 ) And ( FindEntry ( 'P*_END' ) = 0 ) Then
			Begin
				Marker := marker_Patch;
			End;
		End;
		//
		If Marker <> marker_None Then
		Begin
			Case Marker Of
				marker_Floor :
					WadEntryNewAtPos ( 'FF_START', iEntry, -1, False );
				marker_Sprite :
					WadEntryNewAtPos ( 'SS_START', iEntry, -1, False );
				marker_Patch :
					WadEntryNewAtPos ( 'PP_START', iEntry, -1, False );
			End;
			Inc ( iEntry );
		End;
		//
		For i := 0 To iCnt - 1 Do
		Begin
			WadEntryNewAtPos ( '', iEntry, iListEntry, False );
			//
			WadEntries [ iEntry ].EntryType := 0;
			//
			bRaw := bForceRaw;
			If gRawPNG And ( LowerCase ( KeepFromRight ( Strings [ i ], 4 ) ) = '.png' ) Then
				bRaw := True;
			ImportEntryFile ( iEntry, Strings [ i ], False, bRaw );
			UpdateWadEntry ( iListEntry, iEntry );
			//
			// Special check for PATCH filter
			//
			If sListWadFilter = 'PATCH' Then
			Begin
				TextureAdd ( iEntry );
			End;
			//
			Inc ( iEntry );
			Inc ( iListEntry );
		End;
		//
		If Marker <> marker_None Then
		Begin
			Case Marker Of
				marker_Floor :
					WadEntryNewAtPos ( 'FF_END', iEntry, -1, False );
				marker_Sprite :
					WadEntryNewAtPos ( 'SS_END', iEntry, -1, False );
				marker_Patch :
					WadEntryNewAtPos ( 'PP_END', iEntry, -1, False );
			End;
			Inc ( iEntry );
		End;
		//
		If sListWadFilter = 'PATCH' Then
		Begin
			//
			// Finish up adding PATCHes
			//
			// must look up indexes again!!!
			main_PIndex := FindEntry ( 'PNAMES' );
			main_TIndex := FindEntry ( 'TEXTURE1' );
			//
			If main_bSavePatch Then
			Begin
				PatchNamesSaveData; // no undo, no list update
				ReplaceFile ( main_PIndex, sTempFile, False, False {!} );
			End;
			//
			TextureSaveData;
			ReplaceFile ( main_TIndex, sTempFile, False, False {!} );
			//
			// TEXTURE1 and PNAMES now in list with wrong ID
			// must use full refresh to be safe. :-(
			ShowWadEntries;
			//
		End;
		//
		t1 := GetTickCount;
		//
		Status ( 'Imported ' + IntToStr ( iCnt ) + ' entries (' + IntToStr ( t1 - t0 ) + ' milliseconds)' );
	End;
end;

procedure TFormMain.mnuEntryReplaceClick(Sender: TObject);
Begin
	ReplaceEntry ( False );
End;

procedure TFormMain.mnuEntryReplaceRawClick(Sender: TObject);
begin
	ReplaceEntry ( True );
end;

procedure TFormMain.mnuPL_ReplaceClick(Sender: TObject);
begin
	ReplaceEntry ( False );
end;

procedure TFormMain.mnuPL_ReplaceRawClick(Sender: TObject);
begin
	ReplaceEntry ( True );
end;

procedure TFormMain.ReplaceEntry ( bForceRaw : Boolean );
Var
	sc : Integer;
	s : String;
	iIndex : Integer;
Begin
	sc := ListWad.SelCount;
	If sc > 0 Then
	Begin
		If sc = 1 Then
		Begin
			If sLastFolderImport = '' Then
			Begin
				s := sFileName;
				s := Copy ( s, 1, PosR ( '\', s ) - 1 );
			End
			Else
				s := sLastFolderImport;
			//
			iIndex := EntryGetIndex ( ListWad.Selected.Index );
			//
			OpenDialogImport.InitialDir := s;
			//
			//OpenDialogImport.FileName := Trim ( WadEntries [ iIndex ].Name ) + '.*';
			//
			OpenDialogImport.Title := 'Open file to import';
			OpenDialogImport.Options := [ofHideReadOnly,ofEnableSizing];
			//
			If OpenDialogImport.Execute Then
			Begin
				s := OpenDialogImport.FileName;
				sLastFolderImport := Copy ( s, 1, PosR ( '\', s ) - 1 );
				//
				ImportEntryFile ( iIndex, s, True, bForceRaw );
				//
				ShowEntry ( '', False );
			End;
		End
		Else
		Begin
			MessageDlg ( 'You cannot replace multiple entries.', mtWarning, [mbOK], 0 );
		End;
	End;
end;

procedure TFormMain.SendWadSignature;
Begin
	SendByte ( fo, Ord ( 'P' ) ); // header (PWAD signature)
	SendByte ( fo, Ord ( 'W' ) );
	SendByte ( fo, Ord ( 'A' ) );
	SendByte ( fo, Ord ( 'D' ) );
End;

procedure TFormMain.UpdateWadList;
Var
	i : Integer;
Begin
	//
	// --- Update full List on the screen
	//
	For i := 0 To ListWad.Items.Count - 1 Do
	Begin
		UpdateWadEntry ( i, EntryGetIndex ( i ) );
	End;
End;

procedure TFormMain.mnuFileCleanUpClick(Sender: TObject);
Begin
	If Not gFileReadOnly And IsFileOpen Then
		If CheckFileExtModified Then
			If CheckModified Then
				WadFileCleanUp ( False );
End;

Procedure TFormMain.WadFileAutoCleanUp;
Begin
	If isFileModified And gAutoCleanUp And Not gFileReadOnly And IsFileOpen Then
	Begin
		If Not isFileExtModified Then
		begin
			//ShowMessage ( 'Auto Cleanup!' );
			WadFileCleanUp ( True );
		End;
	End;
End;

procedure TFormMain.WadFileCleanUp ( bQuiet : Boolean );
Var
	OrigSize, NewSize : Integer;
	//
	i, p, c : Integer;
	//
	sNew, s : String;
	//
	DataLength : Integer;

Function GenerateNewFileName ( s, sExt : String ) : String;
Var
	Cnt : Integer;
	sn : String;
Begin
	Cnt := 0;
	//
	Repeat
		Inc ( Cnt );
		sn := IntToStr ( Cnt );
		While Length ( sn ) < 3 Do
			sn := '0' + sn;
		sn := s + '.' + sn + '.' + sExt;
	Until Not FileExists ( sn );
	//
	GenerateNewFileName := sn;
End;

Begin
	If FileType <> ftWADFile Then
	Begin
		{$IFDEF USEDEBUG}
		DoDebugLn ( 'Not a WAD file, no cleanup' );
		{$ENDIF}
	End
	Else
	Begin
		{$IFDEF USEDEBUG}
		DoDebugLn ( 'Performing cleanup' );
		{$ENDIF}
		//
		Starting;
		//
		sNew := GenerateNewFileName ( sFileName, 'new' );
		AssignFile ( fo, sNew );
		FileMode := fmOpenReadWrite;
		ReWrite ( fo, 1 );
		//
		While fOpenCount > 0 Do Begin
			fClose; // just in case...
		End;
		//
		fOpen ( sFileName );
		OrigSize := FileSize ( f );
		//
		// --- Pre calculate ---
		//
		c := 0;
		For i := 1 To nWadEntries Do
		Begin
			Inc ( c, WadEntries [ i ].Size );
		End;
		iWadDirPos := c + 12;
		//
		// ---
		//
		SendWadSignature;
		SendLong ( fo, nWadEntries ); // number of entries
		SendLong ( fo, iWadDirPos );  // position of directory
		//
		p := 12;
		//
		For i := 1 To nWadEntries Do
		Begin
			//
			Status ( 'Copying Entry ' + Comma ( i ) );
			//
			DataLength := WadEntries [ i ].Size;
			Seek ( f, WadEntries [ i ].Position );
			//
			WadEntries [ i ].Position := p;
			Inc ( p, DataLength );
			//
			CopyData ( f, fo, DataLength );
			//
		End;
		//
		// --- Write entire directory
		//
		Status ( 'Writing Directory' );
		For i := 1 To nWadEntries Do
		Begin
			SendWadEntryFromArray ( fo, i );
		End;
		//
		fClose;
		//
		NewSize := FileSize ( fo );
		//
		CloseFile ( fo );
		//
		// --- backup original
		//
		If gOnlyOneBack Then
		Begin
			s := Copy ( sFileName, 1, PosR ( '.', sFileName ) ) + 'bak';
			//
			If FileExists ( s ) Then
			Begin
				AssignFile ( fo, s );
				Erase ( fo );
			End;
			//
		End
		Else
		Begin
			s := GenerateNewFileName ( sFileName, 'bak' );
		End;
		//
		// --- rename old file
		AssignFile ( fo, sFileName );
		Rename ( fo, s );
		//
		AssignFile ( fo, sNew );
		Rename ( fo, sFileName );
		//
		s := 'Successfully finished.' + #13 + #13;
		//
		If OrigSize = NewSize Then
		Begin
			s := s + 'File size remained the same';
		End
		Else
		Begin
			If OrigSize > NewSize Then
			Begin
				s := s + 'Gained ' + Comma ( OrigSize - NewSize ) + ' bytes';
			End
			Else
			Begin
				s := s + 'File size increased by ' + Comma ( NewSize - OrigSize ) + ' bytes!!!';
			End;
		End;
		s := s + #13 + #13 + 'Old size: ' + Comma ( OrigSize ) + #13 +
			'New size: ' + Comma ( NewSize );
		//
		UpdateWadList;
		//
		Finished;
		FileModified ( False );
		UpdateModifiedDate;
		//
		If Not bQuiet Then
			MessageDlg ( s, mtInformation, [mbOK], 0 )
		Else
			Status ( s );
	End;
end;

procedure TFormMain.mnuPL_DeleteClick(Sender: TObject);
Begin
	mnuEntryDeleteClick(Sender);
end;

procedure TFormMain.EntryDeleteSelected;
Var
	i, ListIndex, iCount : Integer;
	//iOld : Integer;
	iEntry : Integer;
Begin
	If ListWad.SortType = stNone Then
	Begin
		//
		// Quick method, when list is not sorted
		//
		iCount := 0; // number of items deleted so far
		//
		ListIndex := 0;
		While ListIndex < ListWad.Items.Count Do
		Begin
			//
			// get its index
			iEntry := StrToInt ( ListWad.Items [ ListIndex ].SubItems [ 0 ] ) - iCount;
			//
			If ListWad.Items [ ListIndex ].Selected Then
			Begin
				// take it out from the list
				ListWad.Items.Delete ( ListIndex );
				Inc ( iCount );
				//
				// take it out from the array
				For i := iEntry To nWadEntries - 1 Do
				Begin
					WadEntries [ i ] := WadEntries [ i + 1 ];
				End;
				Dec ( nWadEntries );
				//
				// don't INC listindex, because we removed one
				// it now points to the next item that needs to be checked
			End
			Else
			Begin
				If iCount > 0 Then
				Begin
					ListWad.Items [ ListIndex ].SubItems [ 0 ] := IntToStr ( iEntry );
				End;
				Inc ( ListIndex );
			End;
		End;
	End
	Else
	Begin
		//
		// new!!!
		//
		For ListIndex := 0 To ListWad.Items.Count - 1 Do
		Begin
			If ListWad.Items [ ListIndex ].Selected Then
			Begin
				//
				// get its index
				iEntry := StrToInt ( ListWad.Items [ ListIndex ].SubItems [ 0 ] );
				//
				// mark for deletion
				WadEntries [ iEntry ].Size := -1;
			End;
		End;
		//
		i := 1; // source
		iEntry := 1; // dest
		While iEntry <= nWadEntries Do
		Begin
			If WadEntries [ i ].Size = -1 Then
			Begin
				Dec ( nWadEntries );
			End
			Else
			Begin
				WadEntries [ iEntry ] := WadEntries [ i ];
				Inc ( iEntry );
			End;
			Inc ( i );
		End;
		//
		ShowWadEntries; // full screen refresh
		//
		// Slower method, when list is sorted
		//
		{
		iOld := 1;
		i := 1;
		iCount := nWadEntries;
		While ( i <= iCount ) Do
		Begin
			//
			// --- get the list index
			ListIndex := EntryFindListIndex ( iOld );
			//
			// --- is this entry even in the list?
			If ListIndex >=0 Then
			Begin
				If ListWad.Items [ ListIndex ].Selected Then
				Begin
					// take it out from the list
					ListWad.Items.Delete ( ListIndex );
					Dec ( nWadEntries );
				End
				Else
				Begin
					// Keep in the list, but update Index
					ListWad.Items [ ListIndex ].SubItems [ 0 ] := IntToStr ( i );
					ListIndex := -1;
				End;
			End;
			//
			If ListIndex = -1 Then
			Begin
				WadEntries [ i ] := WadEntries [ iOld ];
				Inc ( i );
			End;
			//
			Inc ( iOld ); // increment "old" counter
		End;
		}
	End;
	//
	UpdateSelection;
	//
	// *** Rewrite directory, Update file ***
	// (it can always go to the same position,
	//  because it will always be shorter)
	//
	If fOpen ( sFileName ) Then
	Begin
		Seek ( f, iWadDirPos );
		//
		For i := 1 To nWadEntries Do
		Begin
			SendWadEntryFromArray ( f, i );
		End;
		//
		Seek ( f, 4 );
		SendLong ( f, nWadEntries ); // Write New number of entries
		//
		fClose;
		//
		FileModified ( True );
	End;
End;

procedure TFormMain.mnuEntryDeleteClick(Sender: TObject);
Var
	SelectionCount : Integer;
Begin
	SelectionCount := ListWad.SelCount;
	//
	If SelectionCount > 0 Then
	Begin
		If CheckFileExtModified Then
		Begin
			If CheckModified Then
			Begin
				//
				// *** Ask confirm for multiple entries ***
				//
				If SelectionCount > 1 Then
				Begin
					If MessageDlg ( 'Are you sure you want to delete these ' + Comma ( SelectionCount ) + ' entries?',
						mtConfirmation, [mbYes,mbNo], 0 ) = mrNo Then
						SelectionCount := 0;
				End;
				//
				If SelectionCount > 0 Then
				Begin
					//
					SaveUndo ( 'Delete Entry' );
					//
					// ---
					//
					EntryDeleteSelected;
					//
					Modified ( False );
					UpdateModifiedDate;
					//
					ShowPage ( edNone );
				End;
			End;
		End;
	End;
end;

procedure TFormMain.mnuFileMergeClick(Sender: TObject);
Var
	sPath, sExec, sParam, sMain : String;
	//
	nUndoSave : Integer;
	sUndoSave : String;
Begin
	If CheckModified Then
	Begin
		With OpenDialog1 Do
		Begin
			//
			InitialDir := Copy ( sFileName, 1, PosR ( '\', sFileName ) - 1 );
			//
			Title := 'Select Wad File to Merge';
			FilterIndex := 1;
			//
			If Execute Then
			Begin
				SaveUndo ( 'Merge' );
				nUndoSave := nUndo;
				sUndoSave := mnuEditUndo.Caption;
				//
				ToolsGet ( 'DeuSF Utility', 'DEUSF.EXE', sPath, sExec, sParam );
				sMain := ExtractShortPathName ( sMainWad );
				sParam := '-doom ' + Copy ( sMain, 1, PosR ( '\', sMain ) ) + ' -join ' + ExtractShortPathName ( sFileName ) + ' ' + ExtractShortPathName ( Filename );
				{$IFDEF USEDEBUG}
				DoDebugLn ( 'Executing merge: "' + sPath + sExec + '"; Parameters: "' + sParam + '"' );
				{$ENDIF}
				ExecAndWait ( sPath + sExec, sParam, SW_NORMAL );
				OpenWad ( sFileName, False );
				//
				nUndo := nUndoSave;
				mnuEditUndo.Caption := sUndoSave;
				mnuEditUndo.Enabled := True;
			End;
		End;
	End;
End;

procedure TFormMain.mnuFileJoinClick(Sender: TObject);
Var
	iNewEntries, iNewDirPos : Integer;
	i, iOld : Integer;
	//
	NewPos, DataLength : Integer;
Begin
	If CheckModified Then
	Begin
		With OpenDialog1 Do
		Begin
			//
			InitialDir := Copy ( sFileName, 1, PosR ( '\', sFileName ) - 1 );
			//
			Title := 'Select Wad File to Merge';
			FilterIndex := 1;
			//
			If Execute Then
			Begin
				SaveUndo ( 'Join' );
				//
				AssignFile ( fo, FileName );
				FileMode := fmOpenRead; // read-only by default
				Reset ( fo, 1 );
				//
				If ReadWadHeader ( fo, iNewEntries, iNewDirPos ) Then
				Begin
					//
					If fOpen ( sFileName ) Then
					Begin
						Starting;
						//
						Seek ( fo, iNewDirPos );
						//
						iOld := nWadEntries;
						//
						// === merge dir
						//
						For i := 1 To iNewEntries Do
						Begin
							WadEntryLoad ( fo );
							AddWadEntry ( nWadEntries );
						End;
						//
						iWadEntryType := 0; // clear section type
						IdentifyAllEntries;
						//
						// === merge entries
						//
						NewPos := FileSize ( f );
						Seek ( f, NewPos );
						//
						For i := iOld + 1 To nWadEntries Do
						Begin
							//
							Status ( 'Copying New Entry ' + Comma ( i ) );
							//
							DataLength := WadEntries [ i ].Size;
							Seek ( fo, WadEntries [ i ].Position );
							//
							WadEntries [ i ].Position := NewPos;
							Inc ( NewPos, DataLength );
							//
							CopyData ( fo, f, DataLength );
							//
						End;
						//
						// === Write New Directory
						//
						Status ( 'Writing Directory' );
						iWadDirPos := NewPos;
						//
						For i := 1 To nWadEntries Do
						Begin
							SendWadEntryFromArray ( f, i );
						End;
						Seek ( f, 4 );
						SendLong ( f, nWadEntries ); // Write New number of entries
						SendLong ( f, iWadDirPos ); // Write New Directory position
						//
						fClose;
						//
						UpdateModifiedDate;
						//
						Finished;
						//
						ShowWadEntries;
						//
						UpdateSelection;
						//
						Status ( Comma ( iNewEntries ) + ' entries merged.' );
					End;
				End;
				//
				CloseFile ( fo );
			End;
		End;
	End;
end;

procedure TFormMain.chkImageTileClick(Sender: TObject);
Begin
	ImageRenderCurrent;
end;

procedure TFormMain.cmdImageWeaponClick(Sender: TObject);
begin
	If cmdImageWeapon.Caption = 'W: Auto' Then
	Begin
		cmdImageWeapon.Caption := 'W: Off';
	End
	Else
	Begin
		If cmdImageWeapon.Caption = 'W: Off' Then
		Begin
			cmdImageWeapon.Caption := 'W: On';
		End
		Else
		Begin
			cmdImageWeapon.Caption := 'W: Auto';
		End;
	End;
	//
	ImageRenderCurrent;
	EditImageCursor.SetFocus;
end;

// ---

procedure TFormMain.ListWadDragDrop(Sender, Source: TObject; X,
	Y: Integer);
Var
	i : TListItem;
	iDest : Integer;
	{iSelCount : Integer;}
Begin
	i := ListWad.GetItemAt ( X, Y );
	//
	If i <> Nil Then
	Begin
		{
		iSelCount := ListWad.SelCount;
		}
		//
		iDest := EntryGetIndex ( i.Index );
		WadEntriesMoveTo ( i.Index, iDest );
		{
		ShowMessage ( 'Sorry this function is not implemented yet' + #13 +
			Comma ( iSelCount ) + ' items dropped at ' + Comma ( i.Index ) );
		}
	End;
end;

procedure TFormMain.ListWadDragOver(Sender, Source: TObject; X, Y: Integer;
	State: TDragState; Var Accept: Boolean);
Begin
	if (y < 15) then
	begin
		{On the upper edge - should scroll up }
		SendMessage ( ListWad.Handle, WM_VSCROLL, SB_LINEUP, 0 );
	end
	else
	begin
		if (ListWad.Height - y < 15) then
		begin
			{ On the lower edge - should scroll down }
			SendMessage ( ListWad.Handle, WM_VSCROLL, SB_LINEDOWN, 0 );
		end;
	end;
	Accept := True;
end;

Procedure TFormMain.WadEntriesMoveTo ( iDestPos, iDest : Integer );
Var
	i, iFirstEntry, iLastEntry, iEntry, iCount : Integer;
	iLoop : Integer;
	we : TWadEntry;
	bMoved : Boolean;
Begin
	bMoved := False;
	iCount := 0;
	//
	// --- Find first selected
	//
	i := 0;
	iFirstEntry := -1;
	iLastEntry := -1;
	While ( i < ListWad.Items.Count ) Do
	Begin
		If ListWad.Items [ i ].Selected Then
		Begin
			If iFirstEntry = -1 Then
				iFirstEntry := EntryGetIndex ( i );
			iLastEntry := EntryGetIndex ( i );
		End;
		Inc ( i );
	End;
	//
	If iFirstEntry >= 0 Then
	Begin
		//
		//
		If ( iFirstEntry < iDest ) And ( iLastEntry > iDest ) Then
		Begin
			MessageDlg ( 'Stop that!!!', mtWarning, [mbOK], 0 );
		End
		Else
		Begin
			//
			If iFirstEntry > iDest Then
			Begin
				// Go through the whole list
				For i := 0 To ListWad.Items.Count - 1 Do
				Begin
					// The selected ones...
					If ListWad.Items [ i ].Selected Then
					Begin
						Inc ( iCount );
						// ... are moved
						iEntry := EntryGetIndex ( i );
						//
						// move up
						we := WadEntries [ iEntry ];
						//
						For iLoop := iEntry - 1 DownTo iDest Do
						Begin
							WadEntries [ iLoop + 1 ] := WadEntries [ iLoop ];
						End;
						//
						WadEntries [ iDest ] := we;
						//
						bMoved := True;
						//
						// --- Also, increase dest position
						//
						Inc ( iDest );
					End
				End
			End
			Else
			Begin
				If iFirstEntry < iDest Then
				Begin
					// Go through the whole list
					For i := ListWad.Items.Count - 1 DownTo 0 Do
					Begin
						// The selected ones...
						If ListWad.Items [ i ].Selected Then
						Begin
							Inc ( iCount );
							//
							iEntry := EntryGetIndex ( i );
							// move down
							we := WadEntries [ iEntry ];
							//
							For iLoop := iEntry + 1 To iDest Do
							Begin
								WadEntries [ iLoop - 1 ] := WadEntries [ iLoop ];
							End;
							//
							WadEntries [ iDest ] := we;
							//
							bMoved := True;
							//
							// --- Also, decrease dest position
							//
							Dec ( iDest );
							//
							If iCount > 1 Then
								Dec ( iDestPos );
						End;
					End;
				End;
			End;
			//
			If bMoved Then
			Begin
				If fOpen ( sFileName ) Then
				Begin
					// re-write entire directory
					Seek ( f, iWadDirPos );
					For i := 1 To nWadEntries Do
					Begin
						SendWadEntryFromArray ( f, i );
					End;
					fClose;
					//
					For i := 0 To ListWad.Items.Count - 1 Do
					Begin
						//
						If ( i >= iDestPos ) And ( i < iDestPos + iCount ) Then
						Begin
							ListWad.Items [ i ].Selected := True;
							If i = iDestPos Then
							Begin
								ListWad.Items [ i ].Focused := True;
							End;
						End
						Else
						Begin
							ListWad.Items [ i ].Selected := False;
						End;
						//
						UpdateWadEntry ( i, EntryGetIndex ( i ) );
					End;
				End;
			End;
		End;
	End;
End;

//
// Swaps two entries in the list, used in move up and move down
//
Procedure TFormMain.WadEntriesSwap ( l1, l2 : Integer; sUndo : String );
Var
	i1, i2 : Integer;
	swap : TWadEntry;
Begin
	//
	// --- Keep only one backup
	//
	If sLastUndo <> sUndo Then
		SaveUndo ( sUndo );
	//
	i1 := EntryGetIndex ( l1 );
	i2 := EntryGetIndex ( l2 );
	//
	swap := WadEntries [ i1 ];
	WadEntries [ i1 ] := WadEntries [ i2 ];
	WadEntries [ i2 ] := swap;
	//
	UpdateWadEntry ( l1, i1 );
	UpdateWadEntry ( l2, i2 );
	//
	ListWad.Items.Item [ l1 ].Selected := False;
	ListWad.Items.Item [ l2 ].Focused := True;
	ListWad.Items.Item [ l2 ].Selected := True;
	//
	// --- Save changes into wad directory
	//
	If fOpen ( sFileName ) Then
	Begin
		//
		Seek ( f, iWadDirPos + ( i1 - 1 ) * 16 );
		SendWadEntryFromArray ( f, i1 );
		//
		Seek ( f, iWadDirPos + ( i2 - 1 ) * 16 );
		SendWadEntryFromArray ( f, i2 );
		//
		fClose;
		//
		UpdateModifiedDate;
	End;
End;

procedure TFormMain.mnuEntryMoveUpClick(Sender: TObject);
Var
	SelectedIndex : Integer;
	l1, l2 : Integer;
	bFirst : Boolean;
Begin
	If Not bBusy Then
	Begin
		If ListWad.SortType <> stNone Then
		Begin
			ShowMessage ( 'You cannot use this feature while the list is sorted.' );
		End
		Else
		Begin
			If CheckModified Then
			Begin
				bBusy := True;
				bFirst := True;
				//
				// process all entries
				SelectedIndex := 0;
				While SelectedIndex < ListWad.Items.Count Do
				Begin
					// selected?
					If ListWad.Items [ SelectedIndex ].Selected Then
					Begin
						//
						// move (swap with previous)
						l1 := SelectedIndex;
						l2 := l1 - 1;
						//
						If ( l2 < 0 ) Then
						Begin
							// already at top
							SelectedIndex := ListWad.Items.Count;
						End
						Else
						Begin
							WadEntriesSwap ( l1, l2, 'Move Up' );
							//
							If bFirst Then
							Begin
								ListWad.Items [ l2 ].MakeVisible ( True );
								bFirst := False;
							End;
						End;
					End;
					//
					Inc ( SelectedIndex );
				End;
				//
				bBusy := False;
			End;
		End;
	End;
end;

procedure TFormMain.mnuEntryMoveDownClick(Sender: TObject);
Var
	SelectedIndex : Integer;
	l1, l2 : Integer;
	bFirst : Boolean;
Begin
	If Not bBusy Then
	Begin
		If ListWad.SortType <> stNone Then
		Begin
			ShowMessage ( 'You cannot use this feature while the list is sorted.' );
		End
		Else
		Begin
			If CheckModified Then
			Begin
				bBusy := True;
				bFirst := True;
				//
				// process all entries
				SelectedIndex := ListWad.Items.Count - 1;
				While ( SelectedIndex >= 0 ) Do
				Begin
					// selected?
					If ListWad.Items [ SelectedIndex ].Selected Then
					Begin
						// move (swap with next)
						l1 := SelectedIndex;
						l2 := l1 + 1;
						//
						If ( l2 < nWadEntries ) And ( l2 < ListWad.Items.Count ) Then
						Begin
							WadEntriesSwap ( l1, l2, 'Move Down' );
							//
							If bFirst Then
							Begin
								ListWad.Items [ l2 ].MakeVisible ( True );
								bFirst := False;
							End;
						End
						Else
						Begin
							SelectedIndex := 0;
						End;
					End;
					//
					Dec ( SelectedIndex );
				End;
				//
				bBusy := False;
			End;
		End;
	End;
end;

Function TFormMain.HexSave : Boolean;
Var
	bSaved : Boolean;
	i : Integer;
	s : String;
Begin
	bSaved := False;
	If mnuHexSave.Enabled Then
	Begin
		If CheckFileExtModified Then
		Begin
			fOpenTemp;
			//
			For i := 0 To MemoHex.Lines.Count - 1 Do
			Begin
				s := MemoHex.Lines.Strings [ i ];
				If Length ( s ) > 0 Then
					BlockWrite ( fo, s [ 1 ], Length ( s ) );
				SendByte ( fo, 13 );
				SendByte ( fo, 10 );
			End;
			//
			CloseFile ( fo );
			//
			ReplaceFile ( iSel, sTempFile, True, True );
			//
			Modified ( False );
			UpdateModifiedDate;
			//
			bSaved := True;
		End;
	End;
	HexSave := bSaved;
end;

procedure TFormMain.mnuHexSaveClick(Sender: TObject);
Begin
	HexSave;
End;

procedure TFormMain.MemoHexChange(Sender: TObject);
Begin
	Modified ( True );
end;

procedure TFormMain.MemoHexKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	FormKeyDown ( Sender, Key, Shift );
end;

procedure TFormMain.MemoHexKeyUp(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	MemoHexUpdateCursorPos;
end;

procedure TFormMain.MemoHexMouseUp(Sender: TObject; Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
begin
	MemoHexUpdateCursorPos;
end;

procedure TFormMain.MemoHexUpdateCursorPos;
Var
	x, y, Len : Integer;
begin
	x := 0;
	y := 0;
	Len := 0;
	While Len <= MemoHex.SelStart Do
	Begin
		x := MemoHex.SelStart - Len + 1;
		Inc ( Len, Length ( MemoHex.Lines [ y ] ) + 2 );
		Inc ( y );
	End;
	//
	Status ( IntToStr ( y ) + ':' + IntToStr ( x ) );
end;

procedure TFormMain.HexViewChange ( iNewMode : Integer );
Begin
	iHexView := iNewMode;
	mnuHexEditText.Checked := iNewMode = 0;
	mnuHexViewBytes.Checked := iNewMode = 1;
	mnuHexViewWords.Checked := iNewMode = 2;
	mnuHexViewAscii.Checked := iNewMode = 3;
end;

procedure TFormMain.mnuHexEditTextClick(Sender: TObject);
Begin
	HexViewChange ( 0 );
	ShowEntry ( '', True );
end;

procedure TFormMain.mnuHexViewBytesClick(Sender: TObject);
Begin
	HexViewChange ( 1 );
	ShowEntry ( '', True );
end;

procedure TFormMain.mnuHexViewWordsClick(Sender: TObject);
Begin
	HexViewChange ( 2 );
	ShowEntry ( '', True );
end;

procedure TFormMain.mnuHexViewAsciiClick(Sender: TObject);
Begin
	HexViewChange ( 3 );
	ShowEntry ( '', True );
end;

procedure TFormMain.mnuFileNewClick(Sender: TObject);
Begin
	If CheckModified Then
	Begin
		SaveDialog1.Filter := 'WAD Files (*.wad)|*.wad|All Files (*.*)|*.*';
		SaveDialog1.DefaultExt := 'wad';
		SaveDialog1.Title := 'Create new Wad file';
		If SaveDialog1.Execute Then
		Begin
			mnuFileCloseClick ( Sender );
			//
			AssignFile ( f, SaveDialog1.FileName );
			FileMode := fmOpenReadWrite;
			ReWrite ( f, 1 );
			Inc ( fOpenCount ); // !
			//
			SendByte ( f, Ord ( 'P' ) );
			SendByte ( f, Ord ( 'W' ) );
			SendByte ( f, Ord ( 'A' ) );
			SendByte ( f, Ord ( 'D' ) );
			//
			SendLong ( f, 0 ); // Entries
			SendLong ( f, 0 ); // Directory Position
			//
			fClose;
			//
			UpdateModifiedDate;
			//
			OpenWad ( SaveDialog1.FileName, False );
		End;
	End;
end;

Procedure TFormMain.ImageShowMulti ( b : Boolean );
Begin
	If b Then
	Begin
		PanelImageArt.Visible := b;
		ImageSplitter.Visible := b;
	End
	Else
	Begin
		ImageSplitter.Visible := b;
		PanelImageArt.Visible := b;
	End;
	//
	mnuImageSave0.Visible := b;
	mnuImageSaveCurrent.Visible := b;
	mnuImageSaveAll.Visible := b;
End;

//******************************************************
// ART format
//

{$IFDEF FULLVERSION}
Procedure TFormMain.ArtRenderImage ( iIndex : Integer );
Var
	xp, yp : Integer;
	Zoom : Double;
Begin
	//
	//---
	ImageRefreshPanel;

	With Image1 Do
	Begin
		Picture.Bitmap.Width := Width;
		Picture.Bitmap.Height := Height;
		Canvas.Brush.Color := clAqua;
		Canvas.FillRect ( Canvas.ClipRect );
	End;
	//
	Zoom := ImageGetZoom;
	//
	xp := ( Image1.Width - ( Round ( Imgs [ iIndex ].xs * Zoom ) ) ) Div 2;
	yp := ( Image1.Height - ( Round ( Imgs [ iIndex ].ys * Zoom ) ) ) Div 2;
	//
	ArtRenderImageAt ( iIndex, xp, yp, Zoom );
End;

Procedure TFormMain.ArtBrowse ( iStart : Integer );
Var
	Stop : Boolean;
	i : Integer;
	x, y, ym : Integer;
Begin
	x := 0;
	y := 0;
	ym := 0;
	//
	i := iStart;
	//
	ImageRefreshPanel;
	//
	Image1.Canvas.Brush.Color := clAqua;
	Image1.Canvas.FillRect ( Image1.Canvas.ClipRect );
	//
	Stop := False;
	While Not Stop Do
	Begin
		If Imgs [ i ].xs + Imgs [ i ].ys > 0 Then
		Begin
			//
			If ( x + Imgs [ i ].xs > Image1.Width ) And ( x <> 0 ) Then
			Begin
				x := 0;
				Inc ( y, ym + 1 );
				ym := 0;
			End;
			//
			If ( y + Imgs [ i ].ys > Image1.Height ) And ( y <> 0 ) Then
				Stop := True;
			//
			If Not Stop Then
			Begin
				ArtRenderImageAt ( i, x, y, 1 );
				x := x + Imgs [ i ].xs + 1;
				If Imgs [ i ].ys > ym Then
					ym := Imgs [ i ].ys;
			End;
		End;
		//
		Inc ( i );
		//
		If i > nImgs Then
			Stop := True;
	End;
End;

Procedure TFormMain.ArtImageLoad ( iIndex : Integer );
Var
	x, y : Integer;
	b : Byte;
Begin
	PreparePalette;
	//
	fOpen ( sEditFile );
	fSeek ( f, Imgs [ iIndex ].Position );
	//
	If ( Imgs [ iIndex ].xs > 0 ) And ( Imgs [ iIndex ].ys > 0 ) Then
	Begin
		ImageResetCurrent ( Imgs [ iIndex ].xs, Imgs [ iIndex ].ys );
		ImageUpdateSize;
		Image_xr := 0;
		Image_yr := 0;
		//
		Case ImgType Of

			ImgDuke :
			Begin
				For x := 0 To Imgs [ iIndex ].xs - 1 Do
				Begin
					For y := 0 To Imgs [ iIndex ].ys - 1 Do
					Begin
						b := GetByte ( f );
						SetPixel ( cImage.Canvas.Handle, x, y, Pal [ b ] );
					End;
				End;
			End;

			ImgQuake :
			Begin
				For y := 0 To Imgs [ iIndex ].ys - 1 Do
				Begin
					For x := 0 To Imgs [ iIndex ].xs - 1 Do
					Begin
						b := GetByte ( f );
						SetPixel ( cImage.Canvas.Handle, x, y, Pal [ b ] );
					End;
				End;
			End;

		End;
	End;
	//
	fClose;
	//
End;

Procedure TFormMain.ArtRenderImageAt ( iIndex, xp, yp : Integer; Zoom : Double );
Begin
	ArtImageLoad ( iIndex );
	ImageRenderCurrentAt ( Image1.Canvas, xp, yp, Zoom );
End;

Procedure TFormMain.ArtEditor;

Var
	i, ls, le : Integer;
	FPos : Integer;

Begin
	Starting;
	//
	PreparePalette;
	//
	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( F, cPos );
	//
	GetLong ( f ); // Version
	GetLong ( f ); // NumTiles
	ls := GetLong ( f );
	le := GetLong ( f );
	//
	//
	//
	nImgs := le - ls + 1;
	//
	If nImgs > MaxImg Then
	Begin
		ShowMessage ( 'Loading ' + Comma ( MaxImg ) + ' entries out of ' + Comma ( nImgs ) );
		nImgs := MaxImg;
	End;
	//MemoHex.Lines.Add ( '#: ' + Comma ( n ) );
	//
	For i := 1 To nImgs Do
	Begin
		Imgs [ i ].xs := GetWord ( f );
	End;
	For i := 1 To nImgs Do
	Begin
		Imgs [ i ].ys := GetWord ( f );
	End;
	For i := 1 To nImgs Do
	Begin
		Imgs [ i ].Flags := GetLong ( f );
	End;
	//
	//---
	//
	FPos := cPos + ( 4 * 4 ) + nImgs * ( 2 + 2 + 4 );
	For i := 1 To nImgs Do
	Begin
		Imgs [ i ].Name := Zero ( i, 3 );
		Imgs [ i ].Position := FPos;
		Inc ( FPos, Imgs [ i ].xs * Imgs [ i ].ys );
	End;
	//
	fClose;
	//
	Finished;
	//
	ImgType := ImgDuke;
	ImgDisplayList;
	// --- khm
	ArtRenderImage ( 1 );
	ArtBrowse ( 1 );
	//
	ShowPage ( edImage );
End;

Procedure TFormMain.ImgDisplayList;
Var
	i, n : Integer;
Begin
	//
	ImageArtGrid.ColCount := 3;
	ImageArtGrid.RowCount := 2;
	ImageArtGrid.DefaultRowHeight := 18;
	ImageArtGrid.DefaultColWidth := 44;
	ImageArtGrid.ColWidths [ 0 ] := -1;
	ImageArtGrid.ColWidths [ 1 ] := 60;
	//
	ImageArtGrid.Cells [ 1, 0 ] := 'Name';
	ImageArtGrid.Cells [ 2, 0 ] := 'Size';
	//
	n := 0;
	For i := 1 To nImgs Do
	Begin
		If Imgs [ i ].xs + Imgs [ i ].ys > 0 Then
		Begin
			Inc ( n );
			//
			If ( n + 1 ) > ImageArtGrid.RowCount Then
				ImageArtGrid.RowCount := ImageArtGrid.RowCount + 1;
			//
			ImageArtGrid.Cells [ 0, n ] := IntToStr ( i );
			ImageArtGrid.Cells [ 1, n ] := Imgs [ i ].Name;
			ImageArtGrid.Cells [ 2, n ] := Comma ( Imgs [ i ].xs ) + '*' + Comma ( Imgs [ i ].ys );
		End;
	End;
	//
	ImageShowMulti ( True );
	//
	ImageArtGrid.Row := 1;
	//
End;
{$ENDIF}

procedure TFormMain.ImageArtGridSelectCell(Sender: TObject; ACol,
	ARow: Integer; Var CanSelect: Boolean);
{$IFDEF FULLVERSION}
Var
	x, y : Integer;
	{$ENDIF}
Begin
	{$IFDEF FULLVERSION}
	Case FileType Of

		EOB3File, LGRESFile, DASFile, LABFile, SingleFile, SingleLumpFile, CSFile :
		Begin
			If ImgType <> ImgOther Then
			Begin
				ArtImageLoad ( SafeVal ( ImageArtGrid.Cells [ 0, ARow ] ) );
				ImageRenderCurrent;
			End
			Else
			Begin
				Image_SubIndex := ARow;
				ImageLoadEntry ( iSel );
				ImageRenderCurrent;
			End;
		End;

		DarkForcesFile :
		Begin
			// Dark Forces WAX
			x := Imgs [ ARow ].xs;
			y := Imgs [ ARow ].ys;
			//
			Image_Header := 0;
			//
			ImageLoad ( sEditFile, Imgs [ ARow ].Position, 0, x, y,
				Imgs [ ARow ].xr, Imgs [ ARow ].yr, fmtDFSprite );
			ImageRenderCurrent;
		End;

		Else
		Begin
			// DUKE, QUAKE, etc.
			ArtImageLoad ( SafeVal ( ImageArtGrid.Cells [ 0, ARow ] ) );
			ImageRenderCurrent;
		End;
	End;
	{$ENDIF}
end;

(*
Procedure TFormMain.UnrealIndex;
{
Var
	B0, B1, B2, B3, B4, B5 : Byte;
	Original, I : Integer;
	V : Cardinal;
	}
Begin
	Original := I;
	V := Abs(I);
	If I >= 0 Then
		B0 := 0
	Else
		B0 := $80;
	If V < $40 Then
		B0 := B0 + V
	Else
		B0 := B0 + ((V And $3f)+$40);
	I := 0;
	{Ar << B0;}

	If ( B0 And $40 ) <> 0 Then
	Begin
		V := V Shr 6;
		If (V < $80) Then
			B1 := V
		Else
			B1 := ((V And $7f)+$80);
		{Ar << B1;}
		If ( B1 And $80 ) <> 0 Then
		Begin
			V := V Shr 7;
			If (V < $80) Then
				B2 := V
			Else
				B2 := ((V And $7f)+$80);
			{Ar << B2;}
			If ( B2 And $80 ) <> 0 Then
			Begin
				V := V Shr 7;
				If (V < $80) Then
					B3 := V
				Else
					B3 := ((V And $7f)+$80);
				{Ar << B3;}
				If ( B3 And $80 ) <> 0 Then
				Begin
					V := V Shr 7;
					B4 := V;
					{Ar << B4;}
					I := B4;
				End;
				I := (I Shl 7) + (B3 And $7f);
			End;
			I := (I Shl 7) + (B2 And $7f);
		End;
		I := (I Shl 7) + (B1 And $7f);
	End;

	I := (I Shl 6) + (B0 And $3f);

	if ( B0 And $80 ) <> 0 Then
		I := -I;
	{
	if ( Ar.IsSaving() And I!=Original ) Then
		appErrorf("Mismatch: %08X %08X",I,Original);
	}

	{return Ar;}

End;
*)

// #################

{$IFDEF FULLVERSION}
Procedure TFormMain.WaxEditor;

Var
	nSeq, nFrame, nCell : Integer;
	iSeq, iFrame, iCell : Integer;
	pSeq, pFrame, pCell : Integer;
	i : Integer;
	b : Boolean;
	xr, yr : Integer;

Begin
	Starting;
	//
	If Not fOpen ( sEditFile ) Then Exit;
	Seek ( F, cPos );
	//
	GetLong ( f ); // Version
	nSeq := GetLong ( f ); // Seq
	nFrame := GetLong ( f );
	nCell := GetLong ( f );
	//
	Status ( Comma ( nSeq ) + ', ' + Comma ( nFrame ) + ', ' + Comma ( nCell ) );
	//
	i := 0;
	//
	For iSeq := 0 To nSeq - 1 Do
	Begin
		Seek ( f, cPos + $20 + iSeq * 4 );
		pSeq := GetLong ( f );
		//
		If ( pSeq < cLen ) And ( pSeq > 0 ) Then
		Begin
			//
			For iFrame := 0 To nFrame - 1 Do
			Begin
				Seek ( f, cPos + $1C + pSeq + iFrame * 4 );
				pFrame := GetLong ( f );
				//
				If ( pFrame < cLen ) And ( pFrame > 0 ) Then
				Begin
					//
					For iCell := 0 To nCell - 1 Do
					Begin
						//
						Seek ( f, cPos + $10 + pFrame + iCell * 4 );
						pCell := GetLong ( f );
						//
						If ( pCell < cLen ) And ( pCell > 0 ) Then
						Begin
							//
							Seek ( f, cPos + pCell );
							xr := GetLong ( f );
							yr := GetLong ( f );
							//
							Seek ( f, cPos + pCell + $0C );
							pCell := GetLong ( f );
							//
							If ( pCell < cLen ) And ( pCell > 0 ) Then
							Begin
								//
								Seek ( f, cPos + pCell );
								//
								If i < MaxImg Then
								Begin
									Inc ( i );
									//
									Imgs [ i ].xs := GetLong ( f );
									Imgs [ i ].ys := GetLong ( f );
									//
									If ( Imgs [ i ].xs < 2048 ) And ( Imgs [ i ].xs > 0 )
									And ( Imgs [ i ].ys < 2048 ) And ( Imgs [ i ].ys > 0 ) Then
									Begin
										//
										Imgs [ i ].xr := -xr;
										Imgs [ i ].yr := -yr;
										//
										Imgs [ i ].Position := cPos + pCell;
										Imgs [ i ].Name := 'S' + Comma ( iSeq + 1 ) +
											' F' + Comma ( iFrame + 1 ) +
											' C' + Comma ( iCell + 1 );
									End
									Else
									Begin
										Imgs [ i ].xs := 0;
										Imgs [ i ].ys := 0;
										Imgs [ i ].Position := 0;
										Imgs [ i ].Name := '';
									End;
								End;
							End;
						End;
					End;
				End;
			End;
		End;
	End;
	//
	nImgs := i;
	//
	fClose;
	//
	Finished;
	//
	Status ( Comma ( nSeq ) + ', ' + Comma ( nFrame ) + ', ' + Comma ( nCell ) );
	//
	ImgType := ImgWax;
	//
	PreparePalette;
	//
	ImgDisplayList;
	//
	ImageArtGridSelectCell ( Self, 0, 1, b );
	//
	ShowPage ( edImage );
End;

Procedure TFormMain.BspEditor;
Var
	i : Integer;
	p, FPos : Integer;
	BspHeader : Integer;

Procedure Sort;
Var
	i1, i2, l : Integer;
	x : TImg;
Begin
	For i1 := nImgs DownTo 2 Do
	Begin
		l := i1;
		For i2 := 1 To i1 - 1 Do
		Begin
			If ( Imgs [ i2 ].ys > Imgs [ l ].ys )
			Or ( ( Imgs [ i2 ].ys = Imgs [ l ].ys )
			And ( Imgs [ i2 ].xs > Imgs [ l ].xs ) )
			Then
				l := i2;
		End;
		If l <> i1 Then
		Begin
			x := Imgs [ l ];
			Imgs [ l ] := Imgs [ i1 ];
			Imgs [ i1 ] := x;
		End;
	End;
End;

Begin
	Starting;
	//
	If Not fOpen ( sEditFile ) Then Exit;
	//
	// --- Check Header
	Seek ( F, cPos );
	BspHeader := GetLong ( f );
	//
	If BspHeader = $50534249 Then // "IBSP"
	Begin
		fClose;
		ShowPage ( edNone );
		//
		Finished;
		//
		Application.ProcessMessages;
		MessageDlg ( 'QuakeII files are not yet supported.', mtError, [mbOK], 0 );
	End
	Else
	Begin
		//
		// --- Assume it to be Quake 1
		//
		Seek ( F, cPos + $14 );
		FPos := GetLong ( f ); // gfx data file pointer
		Seek ( F, cPos + FPos );
		//
		nImgs := GetLong ( f ); // number of entries
		If nImgs > MaxImg Then
			nImgs := MaxImg; // security check
		//
		// Read all image pointers
		//
		For i := 1 To nImgs Do
		Begin
			p := GetLong ( f );
			If ( p = -1 ) Or ( ( p + cPos + FPos + 40 ) > FileSize ( f ) ) Then
			Begin
				Imgs [ i ].Position := 0;
			End
			Else
			Begin
				Imgs [ i ].Position := p + cPos + FPos + 40; // 40 is header size
			End;
		End;
		//
		// Read image headers
		//
		For i := 1 To nImgs Do
		Begin
			If ( Imgs [ i ].Position < 40 ) Then
			Begin
				Imgs [ i ].Name := '';
				Imgs [ i ].xs := 0;
				Imgs [ i ].ys := 0;
			End
			Else
			Begin
				Seek ( f, Imgs [ i ].Position - 40 );
				Imgs [ i ].Name := GetString ( f, 12 ); // name : 12 chars
				// --- fix name
				If Pos ( ' ', Imgs [ i ].Name ) > 0 Then
					Imgs [ i ].Name := Copy ( Imgs [ i ].Name, 1, Pos ( ' ', Imgs [ i ].Name ) - 1 );
				//
				GetLong ( f ); // 4 chars : ??
				Imgs [ i ].xs := GetLong ( f ); // x size
				Imgs [ i ].ys := GetLong ( f ); // y size
				// followed by 4 longs?
				//
				// security check
				If ( Imgs [ i ].xs <= 0 )
				Or ( Imgs [ i ].ys <= 0 ) Then
				Begin
					Imgs [ i ].Position := 0;
					Imgs [ i ].Name := '';
					Imgs [ i ].xs := 0;
					Imgs [ i ].ys := 0;
				End;
			End;
		End;
		//
		fClose;
		Finished;
		//
		Application.ProcessMessages;
		//
		Sort;
		//
		ImgType := ImgQuake;
		ImgDisplayList;
		ArtBrowse ( 1 );
		ShowPage ( edImage );
	End;
End;

Procedure TFormMain.ZipLoadDlls;
Begin
	If Not ZipDllsLoaded Then
	Begin
		zipM.Load_Zip_Dll;
		zipM.Load_Unz_Dll;
		ZipDllsLoaded := True;
		//
		local_zipM := zipM;
	End;
End;
{$ENDIF}

procedure TFormMain.mnuPL_EditPositionClick(Sender: TObject);
Var
	s : String;
	p, Index : Integer;
Begin
	If ListWad.SelCount = 1 Then
	Begin
		If CheckModified Then
		Begin
			Index := EntryGetIndex ( ListWad.Selected.Index );
			//
			p := WadEntries [ Index ].Position;
			s := InputBox ( 'Edit position','Enter new file position', IntToStr ( p ) );
			//
			If s <> '' Then
			Begin
				// --- Store in array
				WadEntries [ Index ].Position := SafeVal ( s );
				//
				If Not gFileReadOnly Then
				Begin
					{$IFDEF FULLVERSION}
					If IsFileEditable Then
					Begin
						{$ENDIF}
						WriteWadEntry ( Index );
						{$IFDEF FULLVERSION}
					End;
					{$ENDIF}
					//
					FileModified ( True );
				End;
				//
				// --- update on screen
				UpdateWadEntry ( ListWad.Selected.Index, Index );
				ShowEntry ( '', False );
			End;
		End;
	End;
end;

procedure TFormMain.mnuPL_EditSizeClick(Sender: TObject);
Var
	s : String;
	p, Index : Integer;
Begin
	If ListWad.SelCount = 1 Then
	Begin
		If CheckModified Then
		Begin
			Index := EntryGetIndex ( ListWad.Selected.Index );
			//
			p := WadEntries [ iSel ].Size;
			s := InputBox ( 'Edit size','Enter new entry size', IntToStr ( p ) );
			//
			If s <> '' Then
			Begin
				// --- Store in array
				WadEntries [ Index ].Size := SafeVal ( s );
				//
				If Not gFileReadOnly Then
				Begin
					{$IFDEF FULLVERSION}
					If IsFileEditable Then
					Begin
						{$ENDIF}
						WriteWadEntry ( Index );
						{$IFDEF FULLVERSION}
					End;
					{$ENDIF}
					//
					FileModified ( True );
				End;
				//
				// --- update on screen
				UpdateWadEntry ( ListWad.Selected.Index, Index );
				ShowEntry ( '', False );
			End;
		End;
	End;
end;

procedure TFormMain.mnuMapUsedTexturesClick(Sender: TObject);
Var
	Text : Array [ 0 .. 5000 ] Of String;
	nText, iText : Integer;
	iSideDef : Integer;
Procedure AddIfNotUsed ( s : String );
Var
	i : Integer;
	bFound : Boolean;
Begin
	bFound := False;
	i := 0;
	While ( i <= nText ) And Not bFound Do
	Begin
		If Text [ i ] = s Then
		Begin
			bFound := True;
		End
		Else
		Begin
			Inc ( i );
		End;
	End;
	If Not bFound Then
	Begin
		Inc ( nText );
		i := nText;
		If i > 0 Then
		Begin
			While ( Text [ i - 1 ] > s ) Do
			Begin
				Dec ( i );
				Text [ i + 1 ] := Text [ i ];
			End;
		End;
		Text [ i ] := s;
	End;
end;
Begin
	DoMapLoad;
	//
	nText := -1;
	For iSideDef := 0 To nSideDefs Do
	Begin
		AddIfNotUsed ( UpperCase ( Trim ( SideDefs [ iSideDef ].Above ) ) );
		AddIfNotUsed ( UpperCase ( Trim ( SideDefs [ iSideDef ].Below ) ) );
		AddIfNotUsed ( UpperCase ( Trim ( SideDefs [ iSideDef ].Main ) ) );
	End;
	//
	MemoHex.Lines.Clear;
	For iText := 0 To nText Do
	Begin
		MemoHex.Lines.Add ( Text [ iText ] );
	End;
	//
	ShowPage ( edHex );
	//
	Modified ( False );
end;

// *** Import Risen3D file

procedure TFormMain.mnuMapImportRisen3DClick(Sender: TObject);
Var
	tf : TextFile;
	sLine : String;
	Values : TStringList;
	//
	bSuccess : Boolean;
	iSuccess, iError : Integer; // keep track of how many lines were ok
	//
	iLineDef : Integer;
	iSideDef : Integer;
	iSide : Integer;
	x : Integer;
	y : Integer;
begin
	If CheckModified Then
	Begin
		With OpenDialogImport Do
		Begin
			FilterIndex := 6;
			If Execute Then
			Begin
				SaveUndo ( 'ImportRisen3D' );
				//
				AssignFile ( tf, FileName );
				Reset ( tf );
				//
				iSuccess := 0;
				iError := 0;
				//
				While Not EOF ( tf ) Do
				Begin
					ReadLn ( tf, sLine );
					Values := Split ( sLine, ' ' );
					//
					// LINE 1439 side 0 offx 4 offy 33
					//
					bSuccess := False;
					If Values.Count = 8 Then
					Begin
						iLineDef := SafeVal ( Values[1] );
						iSide := SafeVal ( Values[3] );
						x := SafeVal ( Values[5] );
						y := SafeVal ( Values[7] );
						//
						If ( iLineDef >= 0 ) And ( iLineDef <= nLineDefs )
						And ( ( iSide = 0 ) Or ( iSide = 1 ) ) Then
						Begin
							If iSide = 0 Then
							Begin
								iSideDef := LineDefs [ iLineDef ].SideFront;
							End
							Else
							Begin
								iSideDef := LineDefs [ iLineDef ].SideBack;
							End;
							SideDefs [ iSideDef ].xOffset := x;
							SideDefs [ iSideDef ].yOffset := y;
							bSuccess := True;
						End;
					End;
					//
					If bSuccess Then
					Begin
						Inc ( iSuccess );
					End
					Else
					Begin
						Inc ( iError );
					End;
				End;
				//
				CloseFile ( tf );
				//
				If ( iSuccess > 0 ) Then
					Modified ( True );
				//
				ShowMessage ( 'Successfully set: ' + Comma ( iSuccess ) + ' lines, errors: ' + Comma ( iError ) );
			End;
		End;
	End;
end;

procedure TFormMain.mnuTexturesCheckClick(Sender: TObject);
Var
	i : Integer;
Begin
	For i := 0 To nTexturePatches Do
	Begin
		If TexturePatches [ i ].ID >= nPatches Then
		Begin
			ShowMessage ( 'prob' );
		End;
	End;
end;

procedure TFormMain.EditImageZoomKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	Case Key Of

		107 : { + }
		Begin
			UpDownImageZoom.Position := UpDownImageZoom.Position + 1;
			ImageRenderCurrent;
		End;
		//
		109 : { - }
		Begin
			UpDownImageZoom.Position := UpDownImageZoom.Position - 1;
			ImageRenderCurrent;
		End;

		(*
		121: // F10
		Begin
			Key := 0;
			ShowPage ( edHex );
		End;
		*)

		Else
		Begin
			Caption := IntToStr ( Key );
		End;

	End;
end;

procedure TFormMain.EditImageZoomKeyPress(Sender: TObject; var Key: Char);
begin
	If ( Key = #43 ) Or ( Key = #45 ) Then
		Key := #0;
end;

// ###

procedure TFormMain.Delay ( i : Cardinal );
Var
	c : Cardinal;
Begin
	c := GetTickCount;
	While GetTickCount - c < i Do
	Begin
		//
	End;
End;

// ###

{
The following code is from Foley & Van Dam:
"Fundamentals of Interactive Computer Graphics"
(found on the net, and converted to Pascal).
It performs the conversion in both directions:
}

{
Public Type HSL
		Hue As Integer
		Saturation As Integer
		Luminance As Integer
End Type

Public Function RGBtoHSL(ByVal Red As Integer, _
                         ByVal Green As Integer, _
                         ByVal Blue As Integer) As HSL

    Dim pRed As Single
    Dim pGreen As Single
    Dim pBlue As Single
    Dim RetVal As HSL
    Dim pMax As Single
    Dim pMin As Single
    Dim pLum As Single
		Dim pSat As Single
		Dim pHue As Single
    
		pRed = Red / 255
    pGreen = Green / 255
    pBlue = Blue / 255

		If pRed > pGreen Then
       If pRed > pBlue Then
					pMax = pRed
       Else
          pMax = pBlue
       End If
    ElseIf pGreen > pBlue Then
				pMax = pGreen
    Else
        pMax = pBlue
    End If

		If pRed < pGreen Then
        If pRed < pBlue Then
            pMin = pRed
        Else
            pMin = pBlue
				End If
		ElseIf pGreen < pBlue Then
        pMin = pGreen
    Else
				pMin = pBlue
    End If

    pLum = (pMax + pMin) / 2

		If pMax = pMin Then
        pSat = 0
				pHue = 0
    Else
				If pLum < 0.5 Then
            pSat = (pMax - pMin) / (pMax + pMin)
        Else
            pSat = (pMax - pMin) / (2 - pMax - pMin)
        End If
        
        Select Case pMax!
        Case pRed
            pHue = (pGreen - pBlue) / (pMax - pMin)
        Case pGreen
            pHue = 2 + (pBlue - pRed) / (pMax - pMin)
				Case pBlue
						pHue = 4 + (pRed - pGreen) / (pMax - pMin)
        End Select
    End If

    RetVal.Hue = pHue * 239 \ 6
    If RetVal.Hue < 0 Then RetVal.Hue = RetVal.Hue + 240

    RetVal.Saturation = Int(pSat * 239)
    RetVal.Luminance = Int(pLum * 239)

		RGBtoHSL = RetVal
End Function
}

Procedure TFormMain.RGBtoHSL ( R, G, B : double; var H, S, L : double );
Var
	var_Max, var_Min, del_Max : double;
	del_R, del_G, del_B : double;
Begin
	R := R / 255;
	G := G / 255;
	B := B / 255;
	//
	var_Max := B;
	var_Min := B;
	if R > var_Max then var_Max := R;
	if G > var_Max then var_Max := G;
	if R < var_Min then var_Min := R;
	if G < var_Min then var_Min := G;
	//
	L := ( var_Max + var_Min ) / 2.0;
	//
	if ( var_Max = var_Min ) then
	begin
		S := 0.0;
		H := 0.0;   {actually it's undefined}
	end
	else
	begin
		del_Max := var_Max - var_Min;
		//
		if (L < 0.5) then
		Begin
			S := del_Max / ( var_Max + var_Min );
		End
		else
		Begin
			If ( 2.0 - var_Max - var_Min ) <> 0 Then
				S := del_Max / ( 2.0 - var_Max - var_Min )
			Else
				S := 0;
		End;
		//
		del_R := ( ( ( var_Max - R ) / 6 ) + ( del_Max / 2 ) ) / del_Max;
		del_G := ( ( ( var_Max - G ) / 6 ) + ( del_Max / 2 ) ) / del_Max;
		del_B := ( ( ( var_Max - B ) / 6 ) + ( del_Max / 2 ) ) / del_Max;
		//
		if      ( R = var_Max ) then H := del_B - del_G
		else if ( G = var_Max ) then H := ( 1 / 3 ) + del_R - del_B
		else if ( B = var_Max ) then H := ( 2 / 3 ) + del_G - del_R;
		//
		if ( H < 0 ) then H := H + 1;
		if ( H > 1 ) then H := H - 1;
		{
		if (r=var_Max) then
			H := (g-b)/delta
		else
			if (g=var_Max) then
				H := 2.0 + (b-r)/delta
			else
				H := 4.0+(r-g)/delta;
		H := H / 6.0;
		if (H < 0.0) then
			H := H + 1;
		}
	end;   {if}
end;   {proc}

(*
procedure TFormMain.HSLtoRGB ( H, S, L : Double; Var R, G, B : Double );
Var
	m1, m2 : double;
Begin
	if ( S = 0.0 ) then
	begin
		R := L * 255;
		G := L * 255;
		B := L * 255;
	end
	else
	begin
		if ( L <= 0.5 ) then
			m2 := L * ( 1.0 + S )
		else
			m2 := L + S - ( L * S );
		//
		m1 := 2.0 * L - m2;
		R := 255 * HuetoRGB ( m1, m2, H + 1.0 / 3.0 );
		G := 255 * HuetoRGB ( m1, m2, H );
		B := 255 * HuetoRGB ( m1, m2, H - 1.0 / 3.0 );
	end;
end;

Function TFormMain.HuetoRGB ( m1, m2, h : Double) : Double;
Begin
	if ( h < 0 ) Then
		h := h + 1.0;
	if ( h > 1 ) Then
		h := h - 1.0;
	//
	if ( 6.0 * h < 1 ) then
		result := ( m1 + ( m2 - m1 ) * h * 6.0 )
	else
		if ( 2.0 * h < 1 ) then
			result := m2
		else
			if ( 3.0 * h < 2.0 ) then
				result := ( m1 + ( m2 - m1 ) * ( ( 2.0 / 3.0 ) - h ) * 6.0 )
			else
				result := m1;
End;
*)

(*
Let A,B,C,D be 2-space position vectors.  Then the directed line segments AB & CD are given by:

				AB=A+r(B-A), r in [0,1]
				CD=C+s(D-C), s in [0,1]
If AB & CD intersect, then

				A+r(B-A)=C+s(D-C), or

				Ax+r(Bx-Ax)=Cx+s(Dx-Cx)
				Ay+r(By-Ay)=Cy+s(Dy-Cy)  for some r,s in [0,1]
Solving the above for r and s yields

						(Ay-Cy)(Dx-Cx)-(Ax-Cx)(Dy-Cy)
				r = -----------------------------  (eqn 1)
						(Bx-Ax)(Dy-Cy)-(By-Ay)(Dx-Cx)

						(Ay-Cy)(Bx-Ax)-(Ax-Cx)(By-Ay)
				s = -----------------------------  (eqn 2)
						(Bx-Ax)(Dy-Cy)-(By-Ay)(Dx-Cx)

Let P be the position vector of the intersection point, then

				P=A+r(B-A) or

				Px=Ax+r(Bx-Ax)
				Py=Ay+r(By-Ay)
By examining the values of r & s, you can also determine some other limiting conditions:

				If 0<=r<=1 & 0<=s<=1, intersection exists
						r<0 or r>1 or s<0 or s>1 line segments do not intersect

*)

Procedure TFormMain.Image1DrawDragFrame ( x, y : Integer );
Var
	xs, ys : Integer;
	xp, yp : Integer;
Begin
	//
	// --- save for later
	ImageLastX := X;
	ImageLastY := Y;
	//
	// --- get position of patch
	xp := Round ( Image_xr * ImageGetZoom );
	yp := Round ( Image_yr * ImageGetZoom );
	//
	If Image_Weapon Then
	Begin
		xp := xp + Round ( 160 * ImageGetZoom );
		yp := yp + Round ( 200 * ImageGetZoom );
	End;
	//
	// --- calculate screen position of patch
	xp := Image_xc - xp;
	yp := Image_yc - yp;
	//
	xs := Round ( Image_xs * ImageGetZoom );
	ys := Round ( Image_ys * ImageGetZoom );
	//
	// --- calculate position of dragging
	//
	x := x - ImageDragX + xp;
	y := y - ImageDragY + yp;
	//
	With Image1.Canvas Do
	Begin
		Pen.Mode := pmXor;
		Pen.Color := clWhite;
		//
		MoveTo ( x, y );
		LineTo ( x + xs - 1, y );
		LineTo ( x + xs - 1, y + ys - 1 );
		LineTo ( x, y + ys - 1 );
		LineTo ( x, y );
		//
		Pen.Mode := pmCopy;
	End;
End;

procedure TFormMain.Image1MouseMove(Sender: TObject;
	Shift: TShiftState; X, Y: Integer);
Begin
	if Not mnuImageEdit.Checked Then
	begin
		If ssLeft in Shift Then
		Begin
			Image1DrawDragFrame ( ImageLastX, ImageLastY );
			Image1DrawDragFrame ( X, Y );
		End;
	End;
end;

procedure TFormMain.Image1MouseUp(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
	xOffs, yOffs : Integer;
Begin
	if Not mnuImageEdit.Checked Then
	begin
		If Button = mbLeft Then
		Begin
			Image1DrawDragFrame ( ImageLastX, ImageLastY );
			//
			// --- moved to x, y
			//
			xOffs := Round ( ( ImageDragX - X ) / ImageGetZoom );
			yOffs := Round ( ( ImageDragY - Y ) / ImageGetZoom );
			//
			If ( xOffs <> 0 ) Or ( yOffs <> 0 ) Then
			Begin
				Image_xr := Image_xr + xOffs;
				Image_yr := Image_yr + yOffs;
				//
				ImageUpdateAlignment;
				ImageRenderCurrent;
				//
				Modified ( True );
				//
				If gAutoApplyOffsets Then
				Begin
					mnuImageApplyClick ( Sender );
				End;
			End;
		End;
	End;
	//
	EditImageCursor.SetFocus;
end;

procedure TFormMain.Image1MouseDown(Sender: TObject; Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
Var
	x0, y0 : Integer;
	z : Integer;
begin
	if mnuImageEdit.Checked Then
	begin
		//
		// -- force focus to form?
		//
		EditImageCursor.SetFocus;
		//
		z := Image1.Width Div 32;
		If y > ( Image1.Height - z * 8 ) Then
		Begin
			x0 := x Div z;
			y0 := ( y - ( Image1.Height - z * 8 ) ) Div z;
			If ( x0 >=0 ) And ( x0 < 32 )
			And ( y0 >=0 ) And ( y0 < 8 ) Then
			Begin
				ImageCurColor := x0 + y0 * 32;
				ImageDrawCursor;
			End;
		End
		Else
		Begin
			x0 := x Div Round ( ImageGetZoom );
			y0 := y Div Round ( ImageGetZoom );
			//
			If ( x0 >= 0 ) And ( x0 <= Image_xs )
			And ( y0 >= 0 ) And ( y0 <= Image_ys ) Then
			Begin
				ImageCurX := x Div Round ( ImageGetZoom );
				ImageCurY := y Div Round ( ImageGetZoom );
				//
				ImageRenderCurrent;
				ImageDrawCursor;
				//
			End;
		End;
	End
	Else
	Begin
		If ssLeft in Shift Then
		Begin
			//
			ImageDragX := X;
			ImageDragY := Y;
			//
			Image1DrawDragFrame ( X, Y );
			//
		End;
	End;
end;

procedure TFormMain.EditImageCursorKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);

Var
	Tmp, Step : Integer;

begin
	If mnuImageEdit.Checked Then
	Begin
		//
		// *** Editing Keys ***
		//
		Case Key Of
			37 : { Cursor Left }
			Begin
				If ssCtrl in Shift Then
				Begin
					If Image_scroll_x < 0 Then
					Begin
						Inc ( Image_scroll_x, 16 );
						If Image_scroll_x > 0 Then
							Image_scroll_x := 0;
						ImageRenderCurrent;
					End;
				End
				Else
				Begin
					Step := 1;
					If ssShift in Shift Then Step := 16;
					//
					If ImageCurX > 0 Then
					Begin
						ImageHideCursor;
						Dec ( ImageCurX, Step );
						If ImageCurX < 0 Then
							ImageCurX := 0;
						ImageDrawCursor;
					End;
				End;
				Key := 0;
			End;
			//
			38 : { Cursor Up }
			Begin
				If ssCtrl in Shift Then
				Begin
					If Image_scroll_y < 0 Then
					Begin
						Inc ( Image_scroll_y, 16 );
						If Image_scroll_y > 0 Then
							Image_scroll_y := 0;
						ImageRenderCurrent;
					End;
				End
				Else
				Begin
					Step := 1;
					If ssShift in Shift Then Step := 16;
					//
					If ImageCurY > 0 Then
					Begin
						ImageHideCursor;
						Dec ( ImageCurY, Step );
						If ImageCurY < 0 Then
							ImageCurY := 0;
						ImageDrawCursor;
					End;
				End;
				Key := 0;
			End;
			//
			39 : { Cursor Right }
			Begin
				If ssCtrl in Shift Then
				Begin
					If Image_scroll_x > -Image_xs Then
					Begin
						Dec ( Image_scroll_x, 16 );
						If Image_scroll_x < -Image_xs Then
							Image_scroll_x := -Image_xs;
						ImageRenderCurrent;
					End;
				End
				Else
				Begin
					Step := 1;
					If ssShift in Shift Then Step := 16;
					//
					If ImageCurX < Image_xs - 1 Then
					Begin
						ImageHideCursor;
						Inc ( ImageCurX, Step );
						If ImageCurX > Image_xs - 1 Then
							ImageCurX := Image_xs - 1;
						ImageDrawCursor;
					End;
				End;
				Key := 0;
			End;
			//
			40 : { Cursor Down }
			Begin
				If ssCtrl in Shift Then
				Begin
					If Image_scroll_y > -Image_ys Then
					Begin
						Dec ( Image_scroll_y, 16 );
						If Image_scroll_y < -Image_ys Then
							Image_scroll_y := -Image_ys;
						ImageRenderCurrent;
					End;
				End
				Else
				Begin
					Step := 1;
					If ssShift in Shift Then Step := 16;
					//
					If ImageCurY < Image_ys - 1 Then
					Begin
						ImageHideCursor;
						Inc ( ImageCurY, Step );
						If ImageCurY > Image_ys - 1 Then
							ImageCurY := Image_ys - 1;
						ImageDrawCursor;
					End;
				End;
				Key := 0;
			End;
			//
			46 : { Del }
			Begin
				cImage.Canvas.Pixels [ ImageCurX, ImageCurY ] := RGB ( 0, 255, 255 );
				//ImageRenderCurrent;
				ImageDrawCursor;
				Status ( 'Delete Pixels' );
				Key := 0;
				//
				Modified ( True );
				ImageOnlyAlignmentModified := False;
			End;
			//
			49, 50, 51, 52,
			53, 54, 55, 56 : { 1 - 8 }
			Begin
				cImage.Canvas.Pixels [ ImageCurX - Image_scroll_x, ImageCurY - Image_scroll_y ] := Pal [ ImageCurColor + Key - 49 ];
				//ImageRenderCurrent;
				ImageDrawCursor;
				Status ( 'Draw with ' + IntToStr ( Key - 48 ) );
				Key := 0;
				//
				Modified ( True );
				ImageOnlyAlignmentModified := False;
			End;
			//
			71 : { G - get color }
			Begin
				ImageCurColor := ImagePaletteMatch ( cImage.Canvas.Pixels [ ImageCurX - Image_scroll_x, ImageCurY - Image_scroll_y ] );
				ImageDrawCursor;
				Status ( 'Got color ' + IntToStr ( ImageCurColor ) );
			End;
			//
			72 : { H - Height }
			Begin
				Tmp := SafeVal ( InputBox ( 'New height', 'Enter new height', IntToStr ( Image_ys ) ) );
				//
				If Tmp > 0 Then
				Begin
					Image_ys := Tmp;
					ImageUpdateSize;
					ImageRenderCurrent;
					ImageDrawCursor;
					//
					Modified ( True );
					ImageOnlyAlignmentModified := False;
				End;
			End;
			//
			86 : { V }
			Begin
				//
			End;
			//
			87 : { W - WIDTH }
			Begin
				Tmp := SafeVal ( InputBox ( 'New width', 'Enter new width', IntToStr ( Image_xs ) ) );
				//
				If Tmp > 0 Then
				Begin
					Image_xs := Tmp;
					cImage.Width := Image_xs;
					ImageUpdateSize;
					ImageRenderCurrent;
					ImageDrawCursor;
					//
					Modified ( True );
					ImageOnlyAlignmentModified := False;
				End;
			End;
			//
			107 : { + }
			Begin
				If ssCtrl in Shift Then
				Begin
					UpDownImageZoom.Position := UpDownImageZoom.Position + 1;
					ImageRenderCurrent;
				End
				Else
				Begin
					if ssShift in Shift Then
					Begin
						ImageCurColor := ( ImageCurColor + 8 ) And 255;
					End
					Else
					Begin
						ImageCurColor := ( ImageCurColor + 1 ) And 255;
					End;
					ImageDrawCursor;
				End;
				Key := 0;
			End;
			//
			109 : { - }
			Begin
				If ssCtrl in Shift Then
				Begin
					UpDownImageZoom.Position := UpDownImageZoom.Position - 1;
					ImageRenderCurrent;
				End
				Else
				Begin
					if ssShift in Shift Then
					Begin
						ImageCurColor := ( ImageCurColor - 8 ) And 255;
					End
					Else
					Begin
						ImageCurColor := ( ImageCurColor - 1 ) And 255;
					End;
					ImageDrawCursor;
				End;
				Key := 0;
			End;
			//
			Else
			Begin
				FormKeyDown ( Sender, Key, Shift );
				//Status ( IntToStr ( Key ) );
			End;
		End;
	End
	Else
	Begin
		//
		Case Key Of

			37 : { Cursor Left }
			Begin
				If ssCtrl in Shift Then
				Begin
					Inc ( Image_xr, 16 );
				End
				Else
				Begin
					Inc ( Image_xr );
				End;
				ImageUpdateAlignment;
				ImageRenderCurrent;
				Modified ( True );
				Key := 0;
			End;
			//
			38 : { Cursor Up }
			Begin
				If ssCtrl in Shift Then
				Begin
					Inc ( Image_yr, 16 );
				End
				Else
				Begin
					Inc ( Image_yr );
				End;
				ImageUpdateAlignment;
				ImageRenderCurrent;
				Modified ( True );
				Key := 0;
			End;
			//
			39 : { Cursor Right }
			Begin
				If ssCtrl in Shift Then
				Begin
					Dec ( Image_xr, 16 );
				End
				Else
				Begin
					Dec ( Image_xr );
				End;
				ImageUpdateAlignment;
				ImageRenderCurrent;
				Modified ( True );
				Key := 0;
			End;
			//
			40 : { Cursor Down }
			Begin
				If ssCtrl in Shift Then
				Begin
					Dec ( Image_yr, 16 );
				End
				Else
				Begin
					Dec ( Image_yr );
				End;
				ImageUpdateAlignment;
				ImageRenderCurrent;
				Modified ( True );
				Key := 0;
			End;

			109 : // -
			Begin
				UpDownImageZoom.Position := UpDownImageZoom.Position - 1;
				ImageRenderCurrent;
			End;

			107 : // +
			Begin
				UpDownImageZoom.Position := UpDownImageZoom.Position + 1;
				ImageRenderCurrent;
			End;

			67 : { C - CTRL+C - Copy }
			Begin
				If ssCtrl in Shift Then
				Begin
					Clipboard.Assign ( cImage );
					Status ( 'Image copied to clipboard.' );
				End;
			End;

			84 : // t
			Begin
				chkImageTile.Checked := Not chkImageTile.Checked;
				chkImageTileClick ( Sender );
			End;

			86 : { V - CTRL+V - Paste }
			Begin
				If ssCtrl in Shift Then
				Begin
					If ClipBoard.HasFormat ( CF_PICTURE ) Then
					Begin
						cImage.Assign ( ClipBoard );
						cImage.PixelFormat := pf24bit;
						//
						ImageRenderCurrent;
						//
						Status ( 'Pasted clipboard to image.' );
						//
						Modified ( True );
						ImageOnlyAlignmentModified := False;
					End;
				End;
			End;

			87 : // w
			Begin
				cmdImageWeaponClick ( Sender );
			End;

			69 : // E: *** Switch to edit mode on "E" ***
			Begin
				mnuImageEditClick ( Sender );
				Key := 0;
			End;

			Else
			Begin
				FormKeyDown ( Sender, Key, Shift );
			End;
		End;
	End;
end;

procedure TFormMain.mnuImageEditClick(Sender: TObject);
Var
	x : Integer;
begin
	mnuImageEdit.Checked := Not mnuImageEdit.Checked;
	//
	If mnuImageEdit.Checked Then
	Begin
		x := Image1.Width Div 32;
		x := Image1.Height - x * 8;
		UpDownImageZoom.Position := x Div Image_ys;
	End;
	//
	ImageRenderCurrent;
	//
	If mnuImageEdit.Checked Then
	Begin
		ImageDrawCursor;
	End;
end;

procedure TFormMain.Image1DblClick(Sender: TObject);
begin
	mnuImageEditClick(Sender);
end;

procedure TFormMain.EditImageCursorKeyPress(Sender: TObject;
	var Key: Char);
begin
	// suppress all keypresses
	Key := #0;
end;

procedure TFormMain.mnuViewMenuBarClick(Sender: TObject);
begin
	mnuViewMenuBar.Checked := Not mnuViewMenuBar.Checked;
	If mnuViewMenuBar.Checked Then
		Menu := MainMenu1
	Else
		Menu := MainMenu2;
	//
	PanelsReset;
end;

procedure TFormMain.tbFilterAllClick(Sender: TObject);
begin
	If CheckModified Then
	Begin
		ListWad.SortType := stNone;
		ListWad.Column[0].Caption := 'Name';
		sListWadFilter := '';
		ShowWadEntries;
	End;
end;

procedure TFormMain.tbFilterClick(Sender: TObject);
begin
	If CheckModified Then
	Begin
		// First time click?
		If sListWadFilter <> TToolButton(Sender).Hint Then
		Begin
			sListWadFilter := TToolButton(Sender).Hint;
			//
			ShowWadEntries;
			Status ( 'Filter: ' + TToolButton(Sender).Hint );
		End
		Else
		Begin
			// double click?
			If ( GetTickCount - iLastFilterClick < 350 ) And Not gFileReadOnly And IsFileOpen Then
			Begin
				// show import dialog
				mnuEntryLoadClick ( Self );
			End;
		End;
		iLastFilterClick := GetTickCount;
	End;
end;

procedure TFormMain.mnuViewFilterToolbarClick(Sender: TObject);
begin
	mnuViewFilterToolbar.Checked := Not mnuViewFilterToolbar.Checked;
	tbFilter.Visible := mnuViewFilterToolbar.Checked;
	//
	PanelsReset;
end;

procedure TFormMain.EditQuickFindKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	FormKeyDown ( Sender, Key, Shift );
end;

procedure TFormMain.mnuViewStatusBarClick(Sender: TObject);
begin
	mnuViewStatusBar.Checked := Not mnuViewStatusBar.Checked;
	StatusBrowse.Visible := mnuViewStatusBar.Checked;
	//
	PanelsReset;
end;

procedure TFormMain.MapEditTextureKeyPress(Sender: TObject;
	var Key: Char);
Var
	tb : TFormTBrowse;
begin
	If Key = #13 Then
	Begin
		tb := TFormTBrowse.Create ( Self );
		tb.Mode := tbmTexture;
		tb.GotoImage ( TEdit ( Sender ).Text );
		tb.ShowModal;
		TEdit ( Sender ).Text := tb.Selected;
		tb.Free;
	End
	Else
	Begin
		If ( Key >= 'a' ) And ( Key <= 'z' ) Then
		Begin
			// auto caps
			Key := Chr ( Ord ( Key ) - 32 );
		End;
	End;
end;

procedure TFormMain.MapEditFrontAboveEnter(Sender: TObject);
begin
	MapLineDefTextureDehighlight;
	MapLineDefTextureHighlight ( 1 );
end;

procedure TFormMain.MapEditFrontMainEnter(Sender: TObject);
begin
	MapLineDefTextureDehighlight;
	MapLineDefTextureHighlight ( 2 );
end;

Procedure TFormMain.MapLineDefTextureDehighlight;
Begin
	If MapLineDefTextureBox <> 0 Then
		MapListTextureEditBox ( MapLineDefTextureBox ).Color := RGB ( $C0, $B0, $A0 );
	MapLineDefTextureBox := 0;
End;

Procedure TFormMain.MapLineDefTextureHighlight ( Index : Integer );
Begin
	MapLineDefTextureBox := Index;
	MapListTextureEditBox ( MapLineDefTextureBox ).Color := RGB ( $D0, $C0, $B0 );
End;

Function TFormMain.MapListTextureEditBox ( Index : Integer ) : TEdit;
Begin
	Case Index Of
		1 : MapListTextureEditBox := MapEditFrontAbove;
		2 : MapListTextureEditBox := MapEditFrontMain;
		3 : MapListTextureEditBox := MapEditFrontBelow;
		4 : MapListTextureEditBox := MapEditBackAbove;
		5 : MapListTextureEditBox := MapEditBackMain;
		6 : MapListTextureEditBox := MapEditBackBelow;
		Else MapListTextureEditBox := Nil;
	End;
End;

procedure TFormMain.MapListTexturesDblClick(Sender: TObject);
begin
	If MapLineDefTextureBox <> 0 Then
	Begin
		MapListTextureEditBox ( MapLineDefTextureBox ).Text := MapListTextures.Items [ MapListTextures.ItemIndex ];
	End;
end;

procedure TFormMain.MapEditFrontBelowEnter(Sender: TObject);
begin
	MapLineDefTextureDehighlight;
	MapLineDefTextureHighlight ( 3 );
end;

procedure TFormMain.MapEditBackAboveEnter(Sender: TObject);
begin
	MapLineDefTextureDehighlight;
	MapLineDefTextureHighlight ( 4 );
end;

procedure TFormMain.MapEditBackMainEnter(Sender: TObject);
begin
	MapLineDefTextureDehighlight;
	MapLineDefTextureHighlight ( 5 );
end;

procedure TFormMain.MapEditBackBelowEnter(Sender: TObject);
begin
	MapLineDefTextureDehighlight;
	MapLineDefTextureHighlight ( 6 );
end;

procedure TFormMain.PanelImageEditXKeyUp(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	Modified ( True );
end;

Procedure TFormMain.PanelReset ( Panel : TPanel; Image : TImage );
Begin
	Panel.Visible := True;
	Image.Refresh;
	//
	Image.Picture.Bitmap.Width := Image.Width;
	Image.Picture.Bitmap.Height := Image.Height;
	//
	Panel.Tag := 1;
End;

procedure TFormMain.ListWadCustomDrawItem(Sender: TCustomListView;
	Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
Var
	i : Integer;
begin
	i := SafeVal ( Item.SubItems[0] );
	If WadEntries [ i ].EntryType = 2 Then
	Begin
		//Sender.Canvas.Font.Color := clWindowText;
		Sender.Canvas.Brush.Color := RGB ( 240, 240, 240 );
		//Sender.Canvas.FillRect ( Classes.Rect ( Item.Left, Item.Top, Item.Left + Sender.Column[0].Width, Item.Top + 17 ) );
	End;
end;

procedure TFormMain.ListWadColumnClick(Sender: TObject;
  Column: TListColumn);
begin
	If sListWadFilter = '' Then
  Begin
		ShowMessage ( 'You can only sort the list when it is filtered.' );
  End
  Else
  Begin
    If ListWad.SortType = stText Then
    Begin
			ListWad.Column[0].Caption := 'Name';
      ListWad.SortType := stNone;
			ShowWadEntries;
		End
		Else
		Begin
			ListWad.Column[0].Caption := 'Name *';
			ListWad.SortType := stText;
		End;
	End;
end;

procedure TFormMain.mnuPL_ChangeTypeClick(Sender: TObject);
Var
	i, Index : Integer;
	nt : Integer;
	s : String;
begin
	If ListWad.SelCount > 0 Then
	Begin
		i := ListWad.Selected.Index;
		Index := EntryGetIndex ( i );
		s := LowerCase ( Trim ( InputBox ( 'New type', 'Enter new type (ID number or type name)', IntToStr ( WadEntries [ Index ].EntryType ) ) ) );
		//
		// Try to find entry by name
		//
		nt := -1;
		For i := 1 To nWadEntryTypes Do
		Begin
			If ( LowerCase ( WadEntryTypes [ i ].Description ) = s ) Then
			Begin
				nt := i;
			End;
		End;
		//
		// Try to evaluate it as a number
		//
		If nt = -1 Then
			nt := SafeVal ( s );
		//
		For i := 0 To ListWad.Items.Count - 1 Do // go through all items
		Begin
			If ListWad.Items [ i ].Selected Then // selected ??
			Begin
				Index := EntryGetIndex ( i );
				WadEntries [ Index ].EntryType := nt;
				//
				UpdateWadEntry ( i, Index );
			End;
		End;
	End;
end;

procedure TFormMain.FormWindowProc ( var Message : TMessage );
begin
	if Message.Msg = WM_DROPFILES then
		HandleDroppedFiles ( Message ); // handle WM_DROPFILES message
	DefaultWindowProc ( Message );
end;

procedure TFormMain.HandleDroppedFiles ( var Msg : TMessage );
var
	pcFileName: PChar;
	i, iSize, iFileCount: integer;
	Files : TStringList;
begin
	Files := TStringList.Create;
	//
	pcFileName := ''; // to avoid compiler warning message
	iFileCount := DragQueryFile(Msg.wParam, $FFFFFFFF, pcFileName, 255);
	//
	i := 0;
	While i < iFileCount Do
	Begin
		iSize := DragQueryFile(Msg.wParam, i, nil, 0) + 1;
		pcFileName := StrAlloc ( iSize );
		DragQueryFile(Msg.wParam, i, pcFileName, iSize);
		//
		if FileExists(pcFileName) then
		Begin
			// handle the file
			Files.Add ( pcFileName );
		End;
		StrDispose(pcFileName);
		//
		Inc ( i );
	End;
	DragFinish(Msg.wParam);
	//
	ImportEntries ( Files, False );
	//
	Files.Free;
end;

// ############################################################################

procedure TFormMain.mnuFileTexturesClick(Sender: TObject);
Var
	iEntryIndex : Integer;
	iTexture : Integer;
	iSideDef : Integer;
	//
	iTypeSideDef : Integer;
	iTypeMapInfo : Integer;
	//
	Sort1, Sort2, Swap : Integer;
	SwapUsedTexture : TUsedTexture;
	//
	ExportFile : TextFile;

	t0 : Cardinal;

Procedure CountTexture ( sTexture : String; CheckAnim, CheckSwitch : Boolean );
Var
	i : Integer;
	bFound : Boolean;
	iTexture : Integer;
Begin
	sTexture := Trim ( UpperCase ( sTexture ) );
	//
	i := 1;
	bFound := False;
	While ( i <= nUsedTextures ) And Not bFound Do
	Begin
		If UsedTextures [ i ].Name = sTexture Then
		Begin
			bFound := True;
		End
		Else
		Begin
			Inc ( i );
		End;
	End;
	//
	If Not bFound Then
	Begin
		Inc ( nUsedTextures );
		i := nUsedTextures;
		UsedTextures [ i ].Name := sTexture;
		UsedTextures [ i ].UsedCount := 0;
		UsedTextures [ i ].TextureIndex := 0;
	End;
	Inc ( UsedTextures [ i ].UsedCount );
	//
	If ( CheckAnim Or CheckSwitch ) And ( sTexture <> '-' ) Then
	Begin
		//
		// -- find this texture in the Textures array
		//
		If UsedTextures [ i ].TextureIndex <> 0 Then
		Begin
			iTexture := UsedTextures [ i ].TextureIndex;
			bFound := True;
		End
		Else
		Begin
			iTexture := 1;
			bFound := False;
			While Not bFound And ( iTexture <= nTextures ) Do
			Begin
				If UpperCase ( Trim ( Textures [ iTexture ].Name ) ) = sTexture Then
				Begin
					bFound := True;
					UsedTextures [ i ].TextureIndex := iTexture;
				End
				Else
					Inc ( iTexture );
			End;
		End;
		//
		If bFound Then
		Begin
			//
			If CheckAnim Then
			Begin
				If Textures [ iTexture ].Animated <> taNone Then
				Begin
					// go back to beginning of sequence
					While Textures [ iTexture ].Animated <> taAnimStart Do
					Begin
						Dec ( iTexture );
					End;
					Repeat
						CountTexture ( Textures [ iTexture ].Name, False, True );
						Inc ( iTexture );
					Until Textures [ iTexture - 1 ].Animated = taAnimEnd;
				End;
			End;
			//
			If CheckSwitch Then
			Begin
				If Textures [ iTexture ].SwitchPairName <> '' Then
				Begin
					CountTexture ( Textures [ iTexture ].SwitchPairName, True, False );
				End;
			End;
		End;
	End;
End;

Procedure ProcessMapInfo ( iPos, iLen : Integer );
Var
	ReadLen : Integer;
	s : String;

Function GetLine : String;
Var
	b : Byte;
	s0 : String;
Begin
	b := 0;
	While ( ReadLen < iLen ) And ( b <> 10 ) And ( b <> 13 ) Do
	Begin
		b := Byte ( GetByte ( f ) );
		Inc ( ReadLen );
		//
		If ( b = 10 ) Or ( b = 13 ) Then
		Begin
			If s0 = '' Then
			Begin
				b := 0; // skip leading lf/cr
			End;
		End
		Else
		Begin
			s0 := s0 + Chr ( b );
		End;
	End;
	//
	GetLine := s0;
End;

Begin
	If Not fOpen ( sEditFile ) Then Exit;
	fSeek ( f, iPos );
	//
	While ReadLen < iLen Do
	Begin
		s := UpperCase ( Trim ( GetLine ) );
		If s <> '' Then
		Begin
			//
			s := Trim ( Replace ( Replace ( s, #9, ' ' ), '  ', ' ' ) );
			//
			// skip comments
			If Copy ( s, 1, 2 ) <> '//' Then
			Begin
				//
				If Pos ( 'SKY1', s ) > 0 Then
				Begin
					s := Trim ( RemoveFromLeft ( s, 4 ) );
					If Pos ( ' ', s ) > 0 Then
						s := Copy ( s, 1, Pos ( ' ', s ) - 1 );
					CountTexture ( s, True, True );
				End;
				//
			End;
		End;
	End;
	//
	fClose;
End;

begin
	{
	process ANIMDEFS
	process MAPINFO
	process BEHAVIOR lumps
	process TX_START/TX_END things
	//
	map 01-11 sky1
	map 12-20 sky2
	map 21-32 sky3
	}
	t0 := GetTickCount;
	//
	ShowPage ( edNone );
	Starting;
	//
	// --- Load Textures
	//
	If nTextures = 0 Then
		TextureInit;
	//
	// --- Mark them all unused, recreate Anim & Switch flags
	//
	For iTexture := 1 To nTextures Do
	Begin
		Textures [ iTexture ].Used := False;
	End;
	TextureRebuildFlags;
	//
	// --- Get type index for various type
	//
	iTypeSideDef := FindEntryType ( 'SIDEDEFS' );
	iTypeMapInfo := FindEntryType ( 'MAPINFO' );
	//
	// --- Process whole list
	//
	For iEntryIndex := 1 To nWadEntries Do
	Begin
		Status ( Comma ( iEntryIndex ) );
		//
		If WadEntries [ iEntryIndex ].EntryType = iTypeSideDef Then
		Begin
			//
			// --- Process SIDEDEFS entry
			//
			SideDefsLoad ( iEntryIndex );
			//
			For iSideDef := 0 To nSideDefs Do
			Begin
				CountTexture ( SideDefs [ iSideDef ].Above, True, True );
				CountTexture ( SideDefs [ iSideDef ].Main, True, True );
				CountTexture ( SideDefs [ iSideDef ].Below, True, True );
			End;
		End
		Else
		Begin
			If WadEntries [ iEntryIndex ].EntryType = iTypeMapInfo Then
			Begin
				//
				// --- Process MAPINFO entry
				//
				ProcessMapInfo ( WadEntries [ iEntryIndex ].Position, WadEntries [ iEntryIndex ].Size );
			End;
		End;
	End;
	//
	// --- Sort
	//
	For Sort1 := 1 To nUsedTextures - 1 Do
	Begin
		Swap := Sort1;
		For Sort2 := Sort1 + 1 To nUsedTextures Do
		Begin
			If UsedTextures [ Swap ].Name > UsedTextures [ Sort2 ].Name Then
				Swap := Sort2;
		End;
		//
		SwapUsedTexture := UsedTextures [ Sort1 ];
		UsedTextures [ Sort1 ] := UsedTextures [ Swap ];
		UsedTextures [ Swap ] := SwapUsedTexture;
	End;
	//
	// --- Export list to file
	//
	{
	AssignFile ( ExportFile, 'C:\used.txt' );
	ReWrite ( ExportFile );
	//
	For iEntryIndex := 1 To nUsedTextures Do
	Begin
		WriteLn ( ExportFile, UsedTextures [ iEntryIndex ].Name + ' ' +
			IntToStr ( UsedTextures [ iEntryIndex ].UsedCount ) );
	End;
	//
	CloseFile ( ExportFile );
	}
	//
	AssignFile ( ExportFile, 'C:\not_used.txt' );
	ReWrite ( ExportFile );
	//
	For iTexture := 1 To nTextures Do
	Begin
		iEntryIndex := 1;
		While iEntryIndex <= nUsedTextures Do
		Begin
			If Trim ( UpperCase ( Textures [ iTexture ].Name ) ) = UsedTextures [ iEntryIndex ].Name Then
			Begin
				Textures [ iTexture ].Used := True;
				iEntryIndex := nUsedTextures;
			End;
			Inc ( iEntryIndex );
		End;
		//
		If Not Textures [ iTexture ].Used Then
		Begin
			WriteLn ( ExportFile, Textures [ iTexture ].Name );
		End;
	End;
	//
	CloseFile ( ExportFile );
	//
	Finished;
	Status ( IntToStr ( nUsedTextures ) + ' textures used. (' + Comma ( GetTickCount - t0 ) + ' milliseconds)' );
end;

{
	Mega Cleanup:
		- delete "useless" lumps: "_DEUTEX_", any marker that's not START/END
		- save 8 bit mono WAVs in Doom Wave format
		- remove unused flats
		- remove unused textures
		- remove SCRIPT entries
		- remove whitespaces from text entries
		- auto crop images
		- crop weapon sprites
}

end.
