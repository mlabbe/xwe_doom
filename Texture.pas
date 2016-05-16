unit Texture;

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

{$DEFINE FULLVERSION}
{$DEFINE SUPPORTGIF}

interface

Uses
	Windows, Graphics, Dialogs, SysUtils, Classes, Grids,
	Stringz, WadFile, FileIO, {$IFDEF SUPPORTGIF}GIFImage{$ENDIF},
	PNGImage, Globals;

Type
	tRGBTripleArray = ARRAY[WORD] OF TRGBTriple;
	pRGBTripleArray = ^TRGBTripleArray;

	TTextureAnim = ( taNone, taAnimStart, taAnim, taAnimEnd );

	TTexture = Record
		Name : String;
		DataPosition : Integer; // within lump
		//
		Flags : Word; // ZDooM Flags
		//
		xScale, yScale : Byte; // ZDooM
		//
		sp2 : Integer; // special ???
		//
		xs, ys : Integer; // size
		//
		PatchStart : Integer; // Internal
		PatchCount : Integer;
		Loaded : Boolean;
		Bitmap : TBitmap;
		Used : Boolean;
		Animated : TTextureAnim;
		SwitchPairName : String; 
	End;

	TTexturePatch = Record
		ID : Integer;
		xPos, yPos : Integer;
		sp1 : Integer; // special ???
		// --- internal
		xSize, ySize : Integer;
	End;

	TUsedTexture = Record
		Name : String;
		UsedCount : Integer;
		TextureIndex : Integer;
	End;

	TPatch = Record
		Name : String;
		// --- internal
		Loaded : Boolean;
		Bitmap : TBitmap; // cache
		xs, ys : Integer;
		IsTransparent : Boolean;
	End;

	TImageFormat = ( fmtNone, fmtDoom, fmtDoomBeta, fmtDoomOldSprite, fmtDoomOld, fmtFloor,
		fmtZDoom,
		fmtQuake,
		fmtHalfLife, fmtHalfLife2, fmtPPM, fmtROTT, fmtROTT2,
		fmtWolfWall, fmtWolfSprite, fmtGeneric, fmtCPS, fmtEOB3, fmtLGRES,
		fmtDFBM, fmtDFSprite, fmtDFWAX, fmtBBM, fmtDescent,
		fmtROTH, fmtROTHPal, fmtROTHMul, fmtROTHPlain,
		fmtDuke2Pal, fmtDuke2,
		fmtREZPal, fmtGenericPal, fmtCSPal, fmtCSFloors,
		fmtUU1, fmtUnreal,
		fmtLABMul, fmtGLB, fmtGreed,
		fmtKTRez,
		fmtGenericRGB,
		fmtFTX,
		fmtBMP, fmtPCX, fmtGIF, fmtTGA, fmtJPG, fmtPNG );

	TFlat = Record
		Name : String;
		//
		Local : Boolean;
		Loaded : Boolean;
		Bitmap : TBitmap;
	End;

Var
	// ***********
	Pal : Array [ 0 .. 255 ] Of TColor;
	nPalette : Integer; // number of palettes (256)
	nPaletteColors : Integer; // for EOB3 Use
	Palette : Array [ 0 .. 31, 0 .. 255, 0 .. 3 ] Of Byte; // the palette
	
	// ***********
	nPatches : Integer; // zero indexed
	Patches : Array [ 0 .. 10000 ] Of TPatch;
	PStartMain : Integer; // index of "P_START" in main wad

	//
	nTextures : Integer;
	Textures : Array [ 1 .. 10000 ] Of TTexture;

	//
	nTexturePatches : Integer;
	TexturePatches : Array [ 1 .. 10000 ] Of TTexturePatch;

	//
	nUsedTextures : Integer;
	UsedTextures : Array [ 1 .. 10000 ] Of TUsedTexture;

	//
	nFlats : Integer;
	Flats : Array [ 0 .. 10000 ] Of TFlat;

	// *************
	cImage : TBitmap;
	Image_xs, Image_ys, Image_xr, Image_yr : Integer;
	Image_Header : Integer; // for generic stuff
	Image_KeepAlignment : Boolean;
	ImageFormat : TImageFormat;
	Image_Transparent : Boolean; // only for doom patches
	Image_PNG_Transparent_Color : Integer;

	// multiple image support
	nImgs : Integer;
	Image_SubIndex : Integer; // for EOB3 sub indexing
	isg : TStringGrid;

	{$IFDEF SUPPORTGIF}
	TGi : TGIFImage;
	{$ENDIF}

	// For Load Image
	// supported game specific variables
	sUnrealNameTable : Array [ 0 .. 511 ] Of String; // Unreal Name Table
	iTR_Size : Byte; // Ultima Underworld TR files
	iDP_TextureEntries : Longint; // Descent PIG files
	iDP_SoundEntries : Longint; // Descent PIG files
	iDP_DataStart : Longint; // Descent PIG files

	// ##########################################################################

	Procedure PaletteLoad ( EntryPos, EntryLen : Integer );

	Function ImageIdentify ( iLen : Integer; Var x, y, xr, yr : Integer ) : TImageFormat;
	Function ImageIdentifyFile ( sFN : String; iPos, iLen : Integer; Var x, y, xr, yr : Integer ) : TImageFormat;
	Function ImageLoadEntry ( iEntry : Integer ) : Boolean;
	Function ImageIdentifyEntry ( iEntry : Integer; Var x, y, xr, yr : Integer ) : TImageFormat;

	Procedure ImageResetCurrent ( xs, ys : Integer );

	Function ImageLoad ( sFN : String; iPos, iLen : Integer; Var xs, ys : Integer; xr, yr : Integer; Format : TImageFormat ) : Boolean;
	Function ImageLoadTo ( sFN : String; iPos, iLen : Integer; Var xs, ys : Integer; Format : TImageFormat; c : TBitmap ) : Boolean;
	Function ImageLoadEntryMain ( iEntry : Integer ) : Boolean;

	Procedure ScanPNGForOffsets ( sFileName : String; Var xOffs, yOffs : Integer );

	Procedure PatchInit;
	procedure PatchNamesLoad ( iEntry : Integer );
	Procedure PatchNamesLoadFromFile ( Var f : File; Size : Integer );
	procedure PatchLoad ( i : Integer );

	Function TextureIsAnimStart ( s : String ) : Boolean;
	Function TextureIsAnimEnd ( s : String ) : Boolean;
	Function TextureIsSwitch ( s : String ) : String;

	Procedure TextureRebuildFlags;

	Function MapFlatFind ( s : String ) : Integer;
	Procedure MapFlatRefresh ( c : TCanvas; s : String );

implementation

Procedure PaletteLoad ( EntryPos, EntryLen : Integer );
Var
	iColor : Integer;
	i, Len, Mul : Integer;
	h1, h2 : Word;
	r, g, b, h : Byte;
	bAlpha : Boolean;
Begin
	nPalette := 0;
	iColor := 0;
	//
	Len := EntryLen;
	Mul := 1;
	{$IFDEF FULLVERSION}
	Case FileType Of
		//
		DukeFile, Duke2File :
		Begin
			Len := 256 * 3;
			Mul := 4; // values times 4
		End;
		//
		AARESFile :
		Begin
			Mul := 4;
		End;
		//
	End;
	{$ENDIF}
	//
	If Len = 768 + 8 Then
	Begin
		// Future Shock COL files
		Inc ( EntryPos, 8 );
		Dec ( Len, 8 );
	End;
	//
	fSeek ( f, EntryPos );
	h1 := Word ( GetWord ( f ) );
	h2 := Word ( GetWord ( f ) );
	//
	If ( h1 = ( EntryLen - 26 ) Div 14 ) And ( h2 = $1A ) Then
	Begin
		Len := h1 * 3;
		Seek ( f, EntryPos + $1A );
		Mul := 4;
	End
	Else
	Begin
		Seek ( f, EntryPos );
	End;
	//
	i := 0;
	h := 0; // highest value
	//
	bAlpha := False; // alpha byte (4th byte after RGB) present
	If Len = 1024 Then
	Begin
		bAlpha := True;
		Len := 3 * 256;
	End;
	//
	// ---
	//
	nPaletteColors := Len Div 3;
	Len := nPaletteColors * 3; // safety
	//
	While i < Len Do
	Begin
		If iColor = 256 Then
		Begin
			iColor := 0;
			Inc ( nPalette );
		End;
		//
		r := Byte ( GetByte ( f ) );
		g := Byte ( GetByte ( f ) );
		b := Byte ( GetByte ( f ) );
		//
		If bAlpha Then
		Begin
			GetByte ( f );
		End;
		//
		{$IFDEF FULLVERSION}
		If FileType = EOB1File Then
		Begin
			r := r And 63;
			g := g And 63;
			b := b And 63;
		End;
		{$ENDIF}
		//
		Palette [ nPalette, iColor, 0 ] := Byte ( r * Mul );
		Palette [ nPalette, iColor, 1 ] := Byte ( g * Mul );
		Palette [ nPalette, iColor, 2 ] := Byte ( b * Mul );
		//
		If r > h Then h := r;
		If g > h Then h := g;
		If b > h Then h := b;
		//
		Inc ( i, 3 );
		//
		Inc ( iColor );
	End;
	//
	While iColor < 256 Do
	Begin
		Palette [ nPalette, iColor, 0 ] := 0;
		Palette [ nPalette, iColor, 1 ] := 0;
		Palette [ nPalette, iColor, 2 ] := 0;
		Inc ( iColor );
	End;
	//
	If ( h <= 63 ) And ( Mul = 1 ) Then
	Begin
		For i := 0 To nPalette Do
		Begin
			For iColor := 0 To 255 Do
			Begin
				Palette [ i, iColor, 0 ] := Palette [ i, iColor, 0 ] * 4;
				Palette [ i, iColor, 1 ] := Palette [ i, iColor, 1 ] * 4;
				Palette [ i, iColor, 2 ] := Palette [ i, iColor, 2 ] * 4;
			End;
		End;
	End;
End;

// ############################################################################

Procedure LoadAdrenixImage ( Var x, y : Integer );
Var
	iEntry, iLen, i, iMatch : Integer;
	d : PData;
	s : String;
Begin
	x := 0;
	y := 0;
	//
	iEntry := FindEntry ( 'TEXTURES' );
	//
	If iEntry >= 0 Then
	Begin
		//
		// --- Take name of selected graphic file
		//
		s := WadEntries [ iSel ].Name;
		//
		// --- Load the "TEXTURES" entry into memory
		//
		iLen := WadEntries [ iEntry ].Size;
		If iLen > DataMax Then iLen := DataMax;
		//
		GetMem ( d, iLen );
		//
		fOpen ( sFileName );
		Seek ( f, WadEntries [ iEntry ].Position );
		BlockRead ( f, d^, iLen );
		//
		fClose;
		//
		// --- Search through entry for filename
		//
		i := 1;
		While ( i < iLen ) And ( i <> -1 ) Do
		Begin
			//
			// --- Only search after "0"
			//
			if d^ [ i - 1 ] = 0 Then
			Begin
				iMatch := 0;
				While ( iMatch < Length ( s ) ) And ( iMatch <> -1 ) Do
				Begin
					If d^ [ i + iMatch ] = Ord ( s [ iMatch + 1 ] ) Then
					Begin
						// one more letter found
						Inc ( iMatch );
					End
					Else
					Begin
						iMatch := -1;
					End;
				End;
			End
			Else
			Begin
				iMatch := -1;
			End;
			//
			// --- Found?
			//
			If iMatch <> -1 Then
			Begin
				//
				// --- Yes! Take width and height from previous longs
				//
				x := d^ [ i - 8 ] + d^ [ i - 7 ] Shl 8;
				y := d^ [ i - 4 ] + d^ [ i - 3 ] Shl 8;
				i := -1;
			End
			Else
			Begin
				Inc ( i );
			End;
		End;
		//
		FreeMem ( d, iLen );
	End;
End;

Function ImageIdentify ( iLen : Integer; Var x, y, xr, yr : Integer ) : TImageFormat;
Var
	HeadW1, HeadW2, HeadW3, HeadW4, HeadW5 : Word;
	//
	xc : Integer;
	SeekTab : Array [ 0 .. 8192 - 1 ] Of Longint;
	SeekTabW : Array [ 0 .. 256 - 1 ] Of Word;
	//
	iBasePos : Integer;
	//
	T : TImageFormat;

Function GetNum : Integer;
Var
	i, n : Integer;
	b : Byte;
Begin
	i := 0;
	n := 0;
	b := GetByte ( f );
	While ( b >= $30 ) And ( b <= $39 ) And ( n < 4 ) Do
	Begin
		i := i * 10 + Ord ( b ) - 48;
		Inc ( n );
		b := GetByte ( f );
	End;
	GetNum := i;
End;

Begin
	T := fmtNone;
	iBasePos := FilePos ( f );
	//
	If iLen > 8 Then
	Begin
		//
		{$IFDEF FULLVERSION}
		//
		// *** Special Wolf ***
		//
		If FileType = WolfFile Then
		Begin
			If iLen = 4096 Then
			Begin
				T := fmtWolfWall;
			End
			Else
			Begin
				T := fmtWolfSprite;
			End;
			x := 64;
			y := 64;
			xr := 0;
			yr := 0;
		End;
		//
		// *** Special Ultima Underworld 1 ***
		//
		If FileType = TRFile Then
		Begin
			T := fmtGeneric;
			//
			x := iTR_Size;
			y := iTR_Size;
			xr := 0;
			yr := 0;
		End;
		//
		// *** Special MDK DTI files ***
		//
		If FileType = DTIFile Then
		Begin
			T := fmtGenericPal;
			//
			Seek ( f, $4C ); // oh, soo bad.
			x := GetLong ( f ) + 4; // ?!?! why 4?
			y := GetLong ( f );
			xr := 0;
			yr := 0;
			//
			Image_Header := 0;
		End;
		//
		If FileType = GLBFile Then
		Begin
			T := fmtGLB;
			//
			x := GetLong ( f );
			y := GetLong ( f );
			Image_Header := GetLong ( f );
			xr := 0;
			yr := 0;
			//
			If ( Image_Header <> 0 ) Or ( x <= 0 ) Or ( x > 1024 ) Or ( y <= 0 ) Or ( y > 1024 ) Then
			Begin
				T := fmtNone; // probably not an image
				Seek ( f, iBasePos );
			End;
		End;
		//
		If FileType = XPRFile Then
		Begin
			Image_Header := 0;
			//
			If iLen = 16384 Then
			Begin
				x := 64;
				y := 64;
			End
			Else
			Begin
				x := Round ( Sqrt ( iLen ) );
				y := x;
			End;
			xr := 0;
			yr := 0;
			//
			T := fmtGenericRGB;
		End;
		//
		If FileType = BLOFile Then
		Begin
			//
			xr := GetWord ( f );
			x := GetWord ( f );
			//
			If ( ( xr = $10 ) And ( x = $62 ) )
			Or ( ( xr = $20 ) And ( x = $A2 ) )
			Or ( ( xr = $30 ) And ( x = $E2 ) ) Then
			Begin
				x := xr * 4;
				y := 64;
				xr := 0;
				yr := 0;
				//
				T := fmtGeneric;
				Image_Header := 128 + 2;
			End
			Else
			Begin
				//
				Image_Header := GetWord ( f );
				//
				If ( x <= 0 ) Or ( x > 512 ) Or ( xr < -x ) Or ( xr > x )
				Or ( Image_Header <> x * 2 + 4 ) Then // !!4
				Begin
					// probably not an image
					Seek ( f, iBasePos );
				End
				Else
				Begin
					T := fmtGreed;
					// it's an image, find out height
					y := 0;
					for HeadW4 := 0 To x - 1 Do
					Begin
						Seek ( f, iBasePos + 4 + HeadW4 * 2 );
						Image_Header := GetWord ( f );
						Seek ( f, iBasePos + Image_Header );
						HeadW5 := Byte ( GetByte ( f ) );
						If HeadW5 > y Then
							y := HeadW5;
					End;
					//
					yr := y;
				End;
			End;
		End;
		//
		If FileType = Duke2File Then
		begin
			If ( iLen = 32048 ) Then
			Begin
				T := fmtDuke2Pal;
				//
				x := 320;
				y := 200;
				xr := 0;
				yr := 0;
				//
				Image_Header := 0;
			End
			Else
			Begin
				If ( iLen = 32000 ) Then
				Begin
					T := fmtDuke2;
					//
					x := 320;
					y := 200;
					xr := 0;
					yr := 0;
					//
					Image_Header := 0;
				End;
			End;
		End;
		//
		If FileType = UnrealFile Then
		Begin
			T := fmtUnreal;
		End;
		//
		If FileType = KTRezFile Then
		Begin
			x := GetLong ( f ); // 4?
			//
			Image_Header := 0;
			//
			If x <> 4 Then
			Begin
				GetByte ( f ); // $FF?
				//
				GetLong ( f ); // 4?
				//
				Image_Header := 5;
			End;
			//
			x := Word ( GetWord ( f ) );
			y := Word ( GetWord ( f ) );
			xr := GetWord ( f );
			yr := GetWord ( f );
			//
			If ( x <= 256 ) And ( y <= 256 ) Then
			Begin
				T := fmtKTRez;
			End
      Else
      Begin
      	Seek ( f, iBasePos );
      End;
		End;
		//
		If FileType = FShockFile Then
		Begin
			Image_Header := 0;
			//
			x := 256;
			y := iLen Div 256;
			xr := 0;
			yr := 0;
			//
			T := fmtGeneric;
		End;
		//
		If FileType = SingleFile Then
		Begin
			If UpperCase ( KeepFromRight ( sFileName, 3 ) ) = 'VGR' Then
			Begin
				x := Word ( GetWord ( f ) ) + 1;
				y := Word ( GetWord ( f ) ) + 1;
				Image_Header := 4;
				xr := 0;
				yr := 0;
				//
				T := fmtGeneric;
			End;
		End;
		//
		{$ENDIF}
		//
		If T = fmtNone Then
		Begin
			//
			// *********************************************************************
			// ### Identify by first 2 bytes ###
			//
			HeadW1 := Word ( GetWord ( f ) );
			HeadW2 := 0;
			//
			Case HeadW1 Of
				//
				$050A :
				Begin
					GetWord ( f ); // skip 2 bytes of header
					//
					xr := GetWord ( f );
					yr := GetWord ( f );
					x := GetWord ( f );
					y := GetWord ( f );
					//
					// safety checks
					If ( x >= 0 ) And ( x <= 1024 ) And ( y >=0 ) And ( y <= 1024 ) Then
					Begin
						//
						x := x - xr + 1;
						y := y - yr + 1;
						//
						xr := 0;
						yr := 0;
						//
						T := fmtPCX;
						//
					End;
				End;
				//
				$3650 : { "P6" }
				Begin
					GetByte ( f ); // 0A
					//
					x := GetNum;
					y := GetNum;
					//
					GetNum; // Colors?
					//
					xr := 0;
					yr := 0;
					//
					If ( iLen = x * y * 3 + FilePos ( f ) ) Then
					Begin
						T := fmtPPM;
					End;
				End;
				//
				$4157 : { "WA" }
				Begin
					x := GetWord ( f );
					If x = $4658 Then // !!! 58
					Begin
						T := fmtLABMul;
						x := 0;
						y := 0;
						xr := 0;
						yr := 0;
					End;
					Seek ( f, iBasePos + 2 );
				End;

				$4D42 : { "BM" }
				Begin
					x := GetWord ( f );
					If x = $1E20 Then
					Begin
						//
						x := GetWord ( f );
						y := GetWord ( f );
						//
						xr := 0;
						yr := 0;
						//
						T := fmtDFBM; // Dark Forces bitmap format
					End
					Else
					Begin
						//
						Seek ( f, iBasePos + 18 );
						x := GetLong ( f );
						y := GetLong ( f );
						//
						If ( x < $10000 ) And ( y < $10000 ) Then
						Begin
							T := fmtBMP;
							//
							Seek ( f, iBasePos + 38 );
							xr := GetWord ( f );
							yr := GetWord ( f );
							Image_KeepAlignment := True;
							If GetLong ( f ) <> $55555555 Then
							Begin
								xr := 0;
								yr := 0;
								Image_KeepAlignment := False;
							End;
						End;
						//
						Seek ( f, iBasePos + 2 );
					End;
				End;
				//
				{
				$4947 :
				Begin
					T := fmtGIF;
					//
					x := 64;
					y := 64;
					xr := 0;
					yr := 0;
				End;
				}
        //
        $5089 : { $89"PNG" }
				Begin
					x := GetWord ( f );
					If x = $474E Then
					Begin
						T := fmtPNG;
						//
						GetLong ( f );
						GetLong ( f ); // skip 8 bytes
						If GetLong ( f ) = $52444849 Then // IHDR
						Begin
							x := GetLong2 ( f );
							y := GetLong2 ( f );
						End
						Else
						Begin
							x := 128;
							y := 128;
						End;
						xr := 0;
            yr := 0;
            Image_Header := 0;
          End;
        End;
				//
				$9119 :
				Begin
					x := Word ( GetWord ( f ) );
					y := Word ( GetWord ( f ) );
					//
					If iLen = ( x * y + $300 + $20 ) Then
					Begin
						// almost like GenericPal, but
						// palette has to be * 4
						T := fmtCSPal;
						xr := 0;
						yr := 0;
						Image_Header := $20;
					End
					Else
					Begin
						// go back
						Seek ( f, iBasePos + 2 );
					End;
				End;
				//
				$D8FF :
				Begin
					T := fmtJPG;
					//
					x := 64;
					y := 64;
					xr := 0;
					yr := 0;
				End;
				//
				$1040, $1240, $10C4 : { ROTH DAS multiple image file }
				Begin
					{$IFDEF FULLVERSION}
					If FileType = DASFile Then
					Begin
						T := fmtROTHMul;
						//
						x := 0;
						y := 0;
						xr := 0;
						yr := 0;
					End;
					{$ENDIF}
				End;
				//
				$1100, $1180, $1182, $1300, $1380, $1700 : { ROTH DAS graphics }
				Begin
					// check for ROTH DAS graphic file
					//
					Seek ( f, iBasePos + 10 );
					Image_Header := Word ( GetWord ( f ) );
					//
					Seek ( f, iBasePos + Image_Header + 2 );
					y := GetWord ( f );
					x := GetWord ( f );
					Seek ( f, iBasePos + 2 );
					//
					If ( x > 0 ) And ( x < 512 ) And ( y > 0 ) And ( y < 512 ) Then
					Begin
						//
						T := fmtROTHPlain;
						//
						xr := 0;
						yr := 0;
						//
						Inc ( Image_Header, 6 );
					End
					Else
					Begin
						// check for compressed file
						//
						Seek ( f, iBasePos + 12 );
						Image_Header := Word ( GetWord ( f ) );
						Seek ( f, iBasePos + 2 );
						//
						If ( Image_Header = $FFFE ) Then
						Begin
							// check for compressed file
							//
							Seek ( f, iBasePos + $22 );
							y := GetWord ( f );
							GetWord ( f );
							x := GetWord ( f );
							Seek ( f, iBasePos + 2 );
							//
							If ( x > 0 ) And ( x < 512 ) And ( y > 0 ) And ( y < 512 ) Then
							Begin
								//
								T := fmtROTH;
								//
								xr := 0;
								yr := 0;
								//
								Image_Header := $28;
							End;
						End;
					End;
				End;
				//
				Else
				Begin
					// EOB1 CPS files
					If HeadW1 = iLen - 2 Then
					Begin
						// check for 6th bytes to be FA00
						Seek ( f, iBasePos + 4 );
						x := Word ( GetWord ( f ) );
						Seek ( f, iBasePos + 2 );
						//
						If x = $FA00 Then
						Begin
							T := fmtCPS;
							//
							x := 320;
							y := 200;
							xr := 0;
							yr := 0;
							//
						End;
					End
					Else
					Begin
						// old doom format
						If ( HeadW1 And 255 ) * 4 * ( HeadW1 Shr 8 ) = iLen - 2 Then
						Begin
							T := fmtDoomOld;
							//
							x := ( HeadW1 And 255 ) * 4;
							y := ( HeadW1 Shr 8 );
							xr := 0;
							yr := 0;
							//
							Image_Header := 2;
						End
						Else
						Begin
							//
							// ugly hack, some EOB3 entries were mis identified as ROTT
							// EOB3 can never have ROTT, but perhaps other files can have EOB3
							if FileType <> EOB3File Then
							Begin
								//
								// old doom sprite format
								//
								x := HeadW1 And 255;
								y := HeadW1 Shr 8;
								//
								// y has to be dividable by 4
								If ( T = fmtNone ) And ( iLen = ( x * y * 4 ) + 4 ) And ( ( y And 3 ) = 0 ) Then
								Begin
									T := fmtROTT2; // ROTT small image
									x := x * 4;
									xr := 0;
									yr := 0;
								End
								Else
								Begin
									If ( x > 3 ) And ( y > 0 )
									And ( iLen <= x * ( y + 3 ) + 4 + x * 2  )
									And ( iLen >= x * 3 + 4 ) Then
									Begin
										T := fmtDoomOldSprite;
										//
										xr := GetByte ( f );
										yr := GetByte ( f );
										//
										BlockRead ( f, SeekTabW, x * 2 );
										//
										Seek ( f, iBasePos + 2 );
										//
										xc := 0;
										While ( T = fmtDoomOldSprite ) And ( xc < x ) Do
										Begin
											If ( SeekTabW [ xc ] > iLen ) Or ( SeekTabW [ xc ] < 8 ) Then
											Begin
												T := fmtNone;
											End;
											Inc ( xc );
										End;
									End;
								End;
							End;
						End;
					End;
				End;
			End;
			//
			// *********************************************************************
			// ### Identify by first 4 bytes ###
			//
			If T = fmtNone Then
			Begin
				HeadW2 := Word ( GetWord ( f ) );
				//
				If ( HeadW1 = $4D49 ) And ( HeadW2 = $5A47 ) Then
				Begin
					// ZDoom image
					T := fmtZDoom;
					//
					x := GetWord ( f );
					y := GetWord ( f );
					xr := GetWord ( f );
					yr := GetWord ( f );
				End;
				//
				If ( HeadW1 = $4947 ) And ( HeadW2 = $3846 ) Then
				Begin
					T := fmtGIF;
					//
					x := 64;
					y := 64;
					xr := 0;
					yr := 0;
				End;
				//
				If ( HeadW1 = $0003 ) And ( HeadW2 = $0000 ) Then
				Begin
					y := GetWord ( f );
					x := GetWord ( f );
					//
					If ( x >= 16 ) And ( y >= 16 ) And ( x < 1024 ) And ( y < 1024 ) Then
					begin
						// ROTH image file from DBASE200
						T := fmtROTH;
						xr := 0;
						yr := 0;
						//
						Image_Header := 8;
					End;
					//
					Seek ( f, iBasePos + 4 );
				End;
				//
				If ( HeadW1 = $0000 ) And ( HeadW2 = $0000 ) Then
				Begin
					HeadW3 := Word ( GetWord ( f ) );
					HeadW4 := Word ( GetWord ( f ) );
					If ( HeadW3 = $FFFE ) And ( HeadW4 = $FFFF ) Then
					Begin
						// DTX image - Shogo REZ
						T := fmtREZPal;
						//
						x := GetWord ( f );
						y := GetWord ( f );
						xr := 0;
						yr := 0;
						//
						Image_Header := $2C;
					End;
					//
					Seek ( f, iBasePos + 4 );
				End;
				//
				If ( HeadW1 = $0001 ) And ( HeadW2 = $0000 ) Then
				Begin
					//
					x := GetWord ( f );
					y := GetWord ( f );
					Seek ( f, iBasePos + 4 );
					//
					If ( x > 0 ) And ( x < 512 ) And ( y > 0 ) And ( y < 512 ) Then
					begin
						// ROTH image file from DBASE300
						T := fmtROTHPal;
						xr := 0;
						yr := 0;
						//
						Image_Header := 8;
					end;
				End;
				//
				If ( HeadW1 = $001E ) And ( HeadW2 = $0000 ) Then
				Begin
					// ROTH (multiple?) image file from DBASE200
					T := fmtGeneric;
					//
					x := 128;
					y := 200;
					xr := 0;
					yr := 0;
					//
					Image_Header := $B4;
				End;
				//
				If FileType = GRFile Then
				Begin
					If ( iLen < 65536 )
					And ( ( HeadW2 Shr 8 ) = ( ( iLen - 5 ) And 255 ) )
					And ( ( HeadW1 Shr 8 ) > 0 ) And ( ( HeadW2 And 255 ) > 0 )
					And Not ( ( HeadW1 = $544D ) And ( HeadW2 = $6468 ) ) // ignore MThd
					And Not ( ( HeadW1 = $4341 ) And ( HeadW2 = $0053 ) ) // ignore ACS
					Then
					Begin
						//
						// --- Ultima Underworld I GR Files
						//
						T := fmtGeneric;
						//
						x := HeadW1 Shr 8;
						y := HeadW2 And 255;
						xr := 0;
						yr := 0;
						//
						Image_Header := 5;
					End;
				End;
				//
				// UU1 GR files
				If ( ( HeadW1 And 255 ) = 8 )
				And ( ( HeadW1 Shr 8 ) * ( HeadW2 And 255 ) > iLen ) Then
				Begin
					T := fmtUU1; // compressed
					//
					x := HeadW1 Shr 8;
					y := HeadW2 And 255;
					xr := x Div 2;
					yr := y;
					//
					Image_Header := 5;
				End;
				//
				If ( HeadW1 = $4F46 ) And ( HeadW2 = $4D52 ) Then
				Begin
					Seek ( f, iBasePos + $15 );
					x := GetByte ( f );
					Seek ( f, iBasePos + $17 );
					y := GetByte ( f );
					Seek ( f, iBasePos + 4 );
					//
					If ( x > 0 ) And ( y > 0 ) Then
					Begin
						// "FORM" header, BBM files
						T := fmtBBM; // in Descent HOG files
						//
						xr := 0;
						yr := 0;
					End;
				End;
				//
				If ( T = fmtNone ) Then
				Begin
					// AARESFile : Amulets & Armor
					x := HeadW1;
					y := HeadW2;
					//
					If ( x < 256 ) And ( y < 256 ) Then
					Begin
						//
						HeadW3 := ( x * y )
							+ ( x Div 2 * y Div 2 )
							+ ( x Div 4 * y Div 4 )
							+ ( x Div 8 * y Div 8 )
							+ ( x Div 16 * y Div 16 );
						If ( iLen = 4 + HeadW3 + 16 ) Then
						Begin
							T := fmtGeneric;
							xr := 0;
							yr := 0;
							Image_Header := 4;
						End;
					End;
				End;
				//
				If T = fmtNone Then
				Begin
					//If ( HeadW2 <> 0 ) And ( Longint ( HeadW2 Shl 16 ) + HeadW1 = iLen ) Then
					If ( Longint ( HeadW2 Shl 16 ) + HeadW1 = iLen ) Then
					Begin
						Seek ( f, iBasePos + 8 );
						x := GetWord ( f );
						Seek ( f, iBasePos + 4 );
						//
						// This word is zero in EOB3 image files
						//
						If x = 0 Then
						Begin
							//
							T := fmtEOB3; // EOB 3 multiple image format
							//
							x := 0;
							y := 0;
							xr := 0;
							yr := 0;
						End
						Else
						Begin
							//
							T := fmtDescent; // Descent Texture
							//
							x := 0;
							y := 0;
							xr := 0;
							yr := 0;
						End;
					End;
				End;
				//
				If T = fmtNone Then
				Begin
					If ( HeadW1 * 4 + 2 + 4 < iLen ) And ( HeadW2 < iLen ) Then
					Begin
						//
						Seek ( f, iBasePos + HeadW1 * 4 + 2 );
						x := GetLong ( f );
						Seek ( f, iBasePos + 4 );
						//
						// This long is entry size in System Shock
						// (last+1 image pointer, points to end of entry)
						//
						If x = iLen Then
						Begin
							// --- check size
							Seek ( f, iBasePos + HeadW2 + 8 );
							x := GetWord ( f );
							y := GetWord ( f );
							//
							If ( x <= 1024 ) And ( x > 0 )
							And ( y <= 1024 ) And ( y > 0 ) Then
							Begin
								//
								// System shock (multiple) image
								//
								T := fmtLGRES;
								xr := 0;
								yr := 0;
								//
								Image_Header := HeadW2 + 28;
							End;
						End;
					End;
				End;
				//
				{$IFDEF FULLVERSION}
				If ( FileType = PIGFile ) Then
				Begin
					If T = fmtNone Then
					Begin
						T := fmtDescent; // Descent Texture
						//
						x := 0;
						y := 0;
						xr := 0;
						yr := 0;
					End;
				End;
				{$ENDIF}
				//
				If T = fmtNone Then
				Begin
					HeadW3 := Word ( GetWord ( f ) );
					Seek ( f, iBasePos + 4 );
					//
					If FileType = DASFile Then
					Begin
						If ( iLen = ( HeadW2 * HeadW3 + 6 ) )
						Or ( iLen = ( HeadW2 * HeadW3 + 7 ) ) Then
						Begin
							// ROTH DAS images
							xr := 0;
							yr := 0;
							y := HeadW2;
							x := HeadW3;
							T := fmtROTHPlain;
							Image_Header := 6;
						End;
					End;
					//
					// --- check for 4byte * 4byte header
					//
					If FileType = GLBFile Then
					Begin
						If ( iLen = HeadW1 * HeadW3 + 8 )
						Or ( iLen = HeadW1 * HeadW3 + 12 )
						Or ( iLen = HeadW1 * HeadW3 + 16 ) Then
						Begin
							//
							// Demonstar / GLB images
							//
							T := fmtGeneric;
							Image_Header := iLen - ( HeadW1 * HeadW3 );
							x := HeadW1;
							y := HeadW3;
							xr := 0;
							yr := 0;
						End;
					End;
				End;
				//
				// *******************************************************************
				// ### Identify by first 8 bytes ###
				//
				If T = fmtNone Then
				Begin
					If HeadW2 = 0 Then
					Begin
						HeadW3 := GetWord ( f );
						HeadW4 := GetWord ( f );
						//
						If ( HeadW2 = 0 ) And ( HeadW4 = 0 )
						And ( iLen = HeadW1 * HeadW3 +
							HeadW1 * HeadW3 Div 4 +
							HeadW1 * HeadW3 Div 16 +
							HeadW1 * HeadW3 Div 64 + 24 ) Then
						Begin
							T := fmtGeneric; // QUAKE 1 texture
							//
							x := HeadW1;
							y := HeadW3;
							xr := 0;
							yr := 0;
							Image_Header := 24;
						End
						Else
						Begin
							If ( HeadW4 = 0 ) And ( iLen = HeadW1 * HeadW3 + 8 ) Then
							Begin
								T := fmtQuake;
								//
								x := HeadW1;
								y := HeadW3;
								xr := 0;
								yr := 0;
							End
							Else
							Begin
								If ( HeadW4 = 0 ) And ( iLen = HeadW1 * HeadW3 + 12 + 3 * 256 ) Then
								Begin
									T := fmtHalfLife;
									//
									x := HeadW1;
									y := HeadW3;
									xr := 0;
									yr := 0;
								End
								Else
								Begin
									If ( HeadW4 = 0 ) And ( iLen = HeadW1 * HeadW3 * 4 + 12 ) Then
									Begin
										T := fmtFTX; // FAKK2 images
										//
										x := HeadW1;
										y := HeadW3;
										xr := 0;
										yr := 0;
									End;
								End;
							End;
						End;
					End
					Else
					Begin
						If ( HeadW1 = 0 ) And ( ( HeadW2 = 2 ) Or ( HeadW2 = 10 ) ) Then
						Begin
							GetLong ( f );
							GetLong ( f );
							x := Integer ( GetWord ( f ) );
							y := Integer ( GetWord ( f ) );
							xr := 0;
							yr := 0;
							//
							If Not ( ( x <= 0 ) Or ( y <= 0 ) ) Then
							Begin
								T := fmtTGA;
							End;
						End;
					End;
				End;
			End;
			//
			If T = fmtNone Then
			Begin
				HeadW3 := Word ( GetWord ( f ) ); // y?
				If ( HeadW2 > 0 ) And ( HeadW3 > 0 )
				And ( HeadW2 < 512 ) And ( HeadW3 < 512 ) Then
				Begin
					xr := SmallInt ( GetWord ( f ) ); // align x
					yr := SmallInt ( GetWord ( f ) ); // align y
					//
					HeadW4 := Word ( GetWord ( f ) );
					HeadW5 := Word ( GetWord ( f ) );
					//
					If ( ( HeadW4 = HeadW2 * 2 + 10 )
					Or ( HeadW5 = HeadW2 * 2 + 12 ) )
					And ( iLen < ( HeadW2 * HeadW3 + 450 ) )
					And ( yr <= HeadW3 ) Then
					Begin
						// masked rott images have 12 bytes header,
						// and extra $0015 is there.
						//
						T := fmtROTT;
						//
						x := HeadW2;
						y := HeadW3;
					End
					Else
						Seek ( f, FilePos ( f ) - 10 );
				End
				Else
					Seek ( f, FilePos ( f ) - 2 );
			End;
			//
			If T = fmtNone Then
			Begin
				//
				// doom format
				//
				If ( HeadW1 > 0 ) And ( HeadW2 > 0 )
				And ( HeadW1 < 8192 ) And ( HeadW2 < 32768 )
				And ( iLen <= HeadW1 * ( HeadW2 * 6 + 4 ) + 8 )
				And ( iLen >= HeadW1 * 4 + 8 ) Then
				Begin
					T := fmtDoom;
					//
					x := HeadW1;
					y := HeadW2;
					xr := GetWord ( f );
					yr := GetWord ( f );
					//
					BlockRead ( f, SeekTab, x * 4 );
					Seek ( f, iBasePos + 4 );
					//
					xc := 0;
					While ( T = fmtDoom ) And ( xc < x ) Do
					Begin
						If ( SeekTab [ xc ] > iLen ) Or ( SeekTab [ xc ] < 8 ) Then
						Begin
							T := fmtNone;
						End;
						Inc ( xc );
					End;
				End;
				//
				If T = fmtNone Then
				Begin
					//
					// doom beta format
					//
					If ( HeadW1 > 0 ) And ( HeadW2 > 0 )
					And ( HeadW1 < 256 ) And ( HeadW2 < 256 )
					And ( iLen <= HeadW1 * ( HeadW2 * 3 + 4 ) + 8 )
					And ( iLen >= HeadW1 * 2 + 8 ) Then
					Begin
						T := fmtDoomBeta;
						//
						x := HeadW1;
						y := HeadW2;
						xr := GetWord ( f );
						yr := GetWord ( f );
						//
						BlockRead ( f, SeekTabW, x * 2 );
						Seek ( f, iBasePos + 4 );
						//
						xc := 0;
						While ( T = fmtDoomBeta ) And ( xc < x ) Do
						Begin
							If ( SeekTabW [ xc ] > iLen ) Or ( SeekTabW [ xc ] < 8 ) Then
							Begin
								T := fmtNone;
							End;
							Inc ( xc );
						End;
					End;
				End;
			End;
			//
			If T = fmtNone Then
			Begin
				If ( HeadW1 = $0100 ) And ( HeadW2 = $0010 ) Then
				Begin
					T := fmtDFWAX; // Dark Forces WAX multiple image format
					//
					x := 0;
					y := 0;
					xr := 0;
					yr := 0;
				End;
			End;
			//
			If ( T = fmtNone ) And ( ( iLen = 4096 ) Or ( iLen = 8192 ) )Then
			Begin
				{$IFDEF FULLVERSION}
				If IsFileEditable Then
				Begin
					{$ENDIF}
					T := fmtFloor;
					{$IFDEF FULLVERSION}
				End
				Else
				Begin
					T := fmtGeneric;
					Image_Header := 0;
				End;
				{$ENDIF}
				//
				x := 64;
				y := iLen Div 64;
				xr := 0;
				yr := 0;
			End;
			//
			If T = fmtNone Then
			Begin
				// Necrodome, ROTT, etc
				If ( HeadW1 <= 512 ) And ( HeadW2 <= 512 )
				And ( HeadW1 > 0 ) And ( HeadW2 > 0 ) Then
				begin
					If ( ( Cardinal ( iLen ) = Cardinal ( Cardinal ( HeadW1 ) * Cardinal ( HeadW2 ) + 4 ) )
					Or ( Cardinal ( iLen ) = Cardinal ( Cardinal ( HeadW1 ) * Cardinal ( HeadW2 ) + 8 ) )
					Or ( Cardinal ( iLen ) = Cardinal ( Cardinal ( HeadW1 ) * Cardinal ( HeadW2 ) + 10 ) )
					Or ( Cardinal ( iLen ) = Cardinal ( Cardinal ( HeadW1 ) * Cardinal ( HeadW2 ) + 12 ) ) ) Then
					Begin
						xr := 0;
						yr := 0;
						x := HeadW1;
						y := HeadW2;
						T := fmtGeneric;
						Image_Header := iLen - ( HeadW1 * HeadW2 );
					End;
				End;
			End;
			//
			If T = fmtNone Then
			Begin
				If iLen > 24 Then
				Begin
					GetLong ( f );
					GetLong ( f );
					GetLong ( f );
					HeadW1 := Word ( GetWord ( f ) );
					HeadW2 := Word ( GetWord ( f ) );
					HeadW3 := Word ( GetWord ( f ) );
					HeadW4 := Word ( GetWord ( f ) );
					//
					If ( HeadW2 = 0 ) And ( HeadW4 = 0 )
					And ( ( HeadW1 And 15 ) = 0 ) And ( ( HeadW3 And 15 ) = 0 )
					And ( HeadW1 > 0 ) And ( HeadW3 > 0 )
					And ( HeadW1 < 256 ) And ( HeadW3 < 256 ) Then
					Begin
						HeadW4 := HeadW1 * HeadW3;
						HeadW2 := HeadW4 + HeadW4 Div 4 + HeadW4 Div 16 + HeadW4 Div 64;
						//
						If iLen = 40 + HeadW2 + 768 + 4 Then
						Begin
							T := fmtHalfLife2;
							//
							x := HeadW1;
							y := HeadW3;
							xr := 0;
							yr := 0;
						End;
					End;
				End;
			End;
			//
			If ( T = fmtNone ) And ( iLen > 32 ) Then
			Begin
				Seek ( f, iBasePos );
				xr := GetLong ( f );
				yr := GetLong ( f );
				//
				Seek ( f, iBasePos + $20 );
				x := GetLong ( f );
				y := GetLong ( f );
				HeadW1 := Word ( GetLong ( f ) );
				//
				If ( x > 0 ) And ( y > 0 ) And ( x < 2048 ) And ( y < 2048 ) Then
				Begin
					If ( iLen = x * y + ( 32 + 8 + 16 ) ) Or ( HeadW1 = 1 ) Then
					Begin
						// If headw1 = 1 then it's compressed
						T := fmtDFSprite;
						//
						xr := -xr;
						yr := -yr;
						//
						// --- Set Image_Header to 32
						//     when loading from WAX files,
						//     Image_Header will be 0 (missing)
						//
						Image_Header := 32;
					End
					Else
					Begin
						If ( iLen = HeadW1 + ( x * y ) + ( x Div 2 * y Div 2 )
							+ ( x Div 4 * y Div 4 ) + ( x Div 8 * y Div 8 ) ) Then
						Begin
							// Quake2
							T := fmtGeneric;
							xr := 0;
							yr := 0;
							Image_Header := HeadW1;
						End;
					End;
				End;
			End;
			//
			{$IFDEF FULLVERSION}
			If FileType = AdrenixFile Then
			Begin
				//
				// Try to find image dimensions
				//
				LoadAdrenixImage ( x, y );
				If x <> 0 Then
				Begin
					//
					// --- Found, this is a graphic entry
					//
					T := fmtGeneric;
					Image_Header := 0;
					xr := 0;
					yr := 0;
				End;
			End;
			{$ENDIF}
			//
			{$IFDEF FULLVERSION}
			If FileType = EOB1File Then
			Begin
				{
				T := fmtGeneric;
				Image_Header := 0;
				x := 64;
				y := iLen Div 64;
				xr := 0;
				yr := 0;
				}
			End;
			{$ENDIF}
			//
			If T = fmtNone Then
			Begin
				Case iLen Of
					//
					16 * 16 + 12,
					32 * 32 + 12,
					32 * 192 + 12,
					32 * 64 + 12,
					64 * 64 + 12,
					64 * 128 + 12,
					128 * 128 + 12,
					128 * 256 + 12,
					256 * 256 + 12 :
					Begin
						Seek ( f, iBasePos );
						//
						T := fmtGeneric;
						Image_Header := 12;
						y := GetLong ( f );
						x := GetLong ( f );
						xr := 0;
						yr := 0;
					End;
					//
					5461 : // Adrenix
					Begin
						T := fmtGeneric;
						Image_Header := 0;
						x := 64;
						y := 64;
						xr := 0;
						yr := 0;
					End;
					//
					10581 : // Adrenix
					Begin
						T := fmtGeneric;
						Image_Header := 0;
						x := 64;
						y := 128;
						xr := 0;
						yr := 0;
					End;
					//
					16384 : // eradicator
					Begin
						T := fmtGeneric;
						Image_Header := 0;
						//
						If FileType = ftWADFile Then
						Begin
							x := 128;
							y := 128;
						End
						Else
						Begin
							x := 256;
							y := 64;
						End;
						//
						xr := 0;
						yr := 0;
					End;
					//
					16960 : // Some Descent 2 images
					Begin
						T := fmtGeneric;
						Image_Header := 0;
						x := 320;
						y := 53;
						xr := 0;
						yr := 0;
					End;
					//
					21845 : // Adrenix
					Begin
						T := fmtGeneric;
						Image_Header := 0;
						x := 128;
						y := 128;
						xr := 0;
						yr := 0;
					End;
					//
					43349 : // Adrenix
					Begin
						T := fmtGeneric;
						Image_Header := 0;
						x := 256;
						y := 128;
						xr := 0;
						yr := 0;
					End;
					//
					51200 :
					Begin
						T := fmtGeneric;
						Image_Header := 0;
						x := 200;
						y := 256;
						xr := 0;
						yr := 0;
					End;
					//
					64000 : // Hexen
					Begin
						T := fmtGeneric;
						Image_Header := 0;
						x := 320;
						y := 200;
						xr := 0;
						yr := 0;
					End;
					//
					65536 : // Alien Trilogy
					Begin
						T := fmtGeneric;
						Image_Header := 0;
						x := 256;
						y := 256;
						xr := 0;
						yr := 0;
					End;
					//
					73728 : // Greed
					Begin
						T := fmtGeneric;
						Image_Header := 0;
						x := 64;
						y := 288 * 4;
						xr := 0;
						yr := 0;
					End;
					//
					307200 : // Necrodome
					Begin
						T := fmtGeneric;
						Image_Header := 0;
						x := 640;
						y := 480;
						xr := 0;
						yr := 0;
					End;
					//
					352320 : // Chasm: The rift FLOOR.## files
					Begin
						T := fmtCSFloors;
						//
						Image_Header := 0;
						//
						x := 64;
						y := 64;
						xr := 0;
						yr := 0;
					End;
					//
				End;
			End;
			//
		End;
	End;
	//
	ImageIdentify := T;
End;

Function ImageIdentifyFile ( sFN : String; iPos, iLen : Integer; Var x, y, xr, yr : Integer ) : TImageFormat;
Begin
	//
	If fOpenCount > 0 Then
	Begin
		//Status ( 'WARNING: The file was still open (usually means last operation failed)' );
		//ShowMessage ( 'The file was still open.' );
		While fOpenCount > 0 Do
		Begin
			fClose;
		End;
	End;
	//
	If FileExists ( sFN ) Then
	Begin
		If fOpen ( sFN ) Then
		Begin
			If fSeek ( f, iPos ) Then
			Begin
				ImageIdentifyFile := ImageIdentify ( iLen, x, y, xr, yr );
			End
			Else
			Begin
				ImageIdentifyFile := fmtNone;
			End;
			//
			fClose;
		End
		Else
		Begin
			ImageIdentifyFile := fmtNone;
		End;
	End
	Else
	Begin
		ImageIdentifyFile := fmtNone;
	End;
	//
End;

Procedure ImageResetCurrent ( xs, ys : Integer );
Begin
	Image_xs := xs;
	Image_ys := ys;
	//
	cImage.Width := xs;
	cImage.Height := ys;
	//
	cImage.Canvas.Brush.Color := clAqua;
	cImage.Canvas.FillRect ( cImage.Canvas.ClipRect );
End;

// ###########################################################################
// Loads the selected image to
// "cImage"
//

Function ImageLoad ( sFN : String; iPos, iLen : Integer; Var xs, ys : Integer; xr, yr : Integer; Format : TImageFormat ) : Boolean;
Begin
	Image_xr := xr;
	Image_yr := yr;
	//
	ImageLoad := ImageLoadTo ( sFN, iPos, iLen, xs, ys, Format, cImage );
End;

// ###########################################################################
// Loads the specified image from a file to a canvas
//

Function ImageLoadTo ( sFN : String; iPos, iLen : Integer; Var xs, ys : Integer; Format : TImageFormat; c : TBitmap ) : Boolean;

Function ExtractFile ( sExt : String ) : String;
Begin
	If iPos <> 0 Then
	Begin
		// Not an individual file,
		// this is a resource within a WAD
		If Not fOpen ( sFN ) Then
		Begin
			ImageLoadTo := False;
			Exit;
		End;
		//
		Seek ( f, iPos );
		//
		fOpenTemp;
		CopyData ( f, fo, iLen );
		CloseFile ( fo );
		fClose;
		//
		AssignFile ( fo, sTempFile );
		sTempFile := sTempFile + sExt;
		Rename ( fo, sTempFile );
		//
		ExtractFile := sTempFile;
		//
	End
	Else
	Begin
		ExtractFile := sFN;
	End;
End;

// Doom loader variables

Var
	iSkippedBytes : Integer;
	SeekTab : Array [ 0 .. 8192 - 1 ] Of Longint;
	SeekTabW : Array [ 0 .. 256 - 1 ] Of Word; // old sprite format
	x, y, xc, yc, fp, i : Integer;
	yt : Integer; // y base for tall images
	n : Byte;
	cm : Byte;
	r, g, b : Byte;
	LocalPal : Array [ 0 .. 255 ] Of Cardinal;
	//
	Col : TColor;
	sl : pRGBTripleArray;
	slPNG : pByteArray;

	// ROTT
	iSeekPos, iHeadPos : Word;
	n1, n2 : Byte;
	x2, y2 : Integer;

	// WOLF
	x1, y1, j : Integer;
	ColumnDef : Array [ 0 .. 64, 0 .. 64 * 3 ] Of Integer;
	StartOffset : Array [ 0 .. 64 ] Of Word;
	PicDataSize : Integer;

	// BMP, JPG, PNG
	TempPic : TPicture;
	TempBitmap : TBitmap;
	ExtractedFileName : String;
	pngObject : TPNGObject;
	PNGPalette : TChunkPLTE;
	PNGCol : tagRGBQUAD; 

	// PCX
	Manufacturer, Version, Encoding : Byte;
	BytesPerLine : Word;
	Planes, Plane, Count, Counter, Bit : Byte;
	ReadyBytes, TotalBytes : Word;
	BitPerPixel : Byte;
	MaxColors : Word;

	// CPS
	iCW : Word;
	iRelPos : Word;

	// Duke2
	n3, n4 : Byte;

	// Unreal
	bName : Byte;
	bInfo : Byte;
	iValue : Integer;
	iPaletteIndex : Integer;

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
	//
	nImgs := 0;
	Image_Transparent := False;
	Image_PNG_Transparent_Color := -1;
	//
	Case Format Of

		// ********
		// Load PNG

		fmtPNG :
		Begin
			ExtractedFileName := ExtractFile ( '.PNG' );
			ScanPNGForOffsets ( ExtractedFileName, image_xr, image_yr );
			//
			pngObject := TPNGObject.Create;
			pngObject.LoadFromFile ( ExtractedFileName );
			//
			xs := pngObject.Width;
			ys := pngObject.Height;
			ImageResetCurrent ( xs, ys );
			//
			Case pngObject.TransparencyMode Of

				ptmBit :
				Begin
					Image_PNG_Transparent_Color := pngObject.TransparentColor;
					//
					For y := 0 To ys - 1 Do
					Begin
						sl := c.ScanLine [ y ];
						For x := 0 To xs - 1 Do
						Begin
							Col := pngObject.Pixels [ x, y ];
							If ( Col <> pngObject.TransparentColor ) Then
							Begin
								sl [ x ].rgbtRed := GetRValue ( Col );
								sl [ x ].rgbtGreen := GetGValue ( Col );
								sl [ x ].rgbtBlue := GetBValue ( Col );
							End;
						End;
					End;
				End;

				ptmNone :
				Begin
					(*
					//TempPic := TPicture.Create;
					//TempPic.LoadFromFile ( ExtractedFileName );
					//
					TempBitmap := TBitmap.Create;
					TempBitmap.Width := xs;
					TempBitmap.Height := ys;
					//TempBitmap.Assign ( TempPic.Graphic );
					TempBitmap.Assign ( pngObject );
					//
					c.Canvas.CopyRect ( TempBitmap.Canvas.ClipRect,
						TempBitmap.Canvas, TempBitmap.Canvas.ClipRect );
					//
					//TempPic.Bitmap.FreeImage;
					TempBitmap.Free;
					*)
					PNGPalette := TChunkPLTE ( pngObject.Chunks.FindChunk ( TChunkPLTE ) );
					//
					If PNGPalette = nil Then
					Begin
						For y := 0 To ys - 1 Do
						Begin
							sl := c.ScanLine [ y ];
							For x := 0 To xs - 1 Do
							Begin
								Col := pngObject.Pixels [ x, y ];
								sl [ x ].rgbtRed := GetRValue ( Col );
								sl [ x ].rgbtGreen := GetGValue ( Col );
								sl [ x ].rgbtBlue := GetBValue ( Col );
							End;
						End;
					End
					Else
					Begin
						For y := 0 To ys - 1 Do
						Begin
							sl := c.ScanLine [ y ];
							slPNG := pngObject.Scanline [ y ];
							For x := 0 To xs - 1 Do
							Begin
								b := slPNG [ x ];
								pngCol := PNGPalette.Item [ b ];
								//Col := pngObject.Pixels [ x, y ];
								//sl [ x ].rgbtRed := GetRValue ( Col );
								//sl [ x ].rgbtGreen := GetGValue ( Col );
								//sl [ x ].rgbtBlue := GetBValue ( Col );
								sl [ x ].rgbtRed := pngCol.rgbRed;
								sl [ x ].rgbtGreen := pngCol.rgbGreen;
								sl [ x ].rgbtBlue := pngCol.rgbBlue;
							End;
						End;
					End;
				End;

			End;
			//
			pngObject.Free;
			//
			ImageLoadTo := True;
		End;

		// ****************
		// LOAD DOOM FORMAT

		fmtDoom :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			Seek ( f, iPos );
			//
			xs := Word ( GetWord ( f ) );
			ys := Word ( GetWord ( f ) );
			GetWord ( f ); // xr
			GetWord ( f ); // yr
			iSkippedBytes := 8;
			//
			ImageResetCurrent ( xs, ys );
			//
			BlockRead ( F, SeekTab, xs * 4 );
			Inc ( iSkippedBytes, xs * 4 );

			iLen := iLen - iSkippedBytes;

			GetMem ( PicData, iLen );
			BlockRead ( F, PicData^, iLen );

			For x := 0 To xs - 1 Do
			Begin
				//Seek ( F, iPos + SeekTab [ x ] );
				fp := SeekTab [ x ] - iSkippedBytes;

				//Status ( 'Processing Line ' + Comma ( x + 1 ) + ' of ' + Comma ( xs ) );

				b := gb;
				y := 0;
				yt := 0;

				If b = $FF Then
					Image_Transparent := True;

				// loop until sequence length is $FF
				While b <> $FF Do
				Begin

					If b = 254 Then
					Begin
						yt := yt + 254;
					End
					Else
					Begin
						If Not ( ( y = b - 1 ) Or ( y = b + 1 ) Or ( y = b ) ) And ( b > 0 ) Then
						Begin
							Image_Transparent := True;
						End;
						//
						If yt = 0 Then
							y := b
						Else
						Begin
							y := yt + b;
							yt := y;
						End;
						//
					End;

					// ---
					n := gb; // sequence length

					gb; // drop first byte
					//Inc ( y );
					For i := 1 To n Do
					Begin
						// ---
						if ( y >= ys ) Then
						Begin
							//ShowMessage ( 'oops -- y=' + IntToStr ( y ) );
							y := ys - 1;
						End;
						if ( y < 0 ) Then
						Begin
							//ShowMessage ( 'oops -- y=' + IntToStr ( y ) );
							y := 0;
						End;
						if ( x >= xs ) Then
						Begin
							ShowMessage ( 'oops -- x=' + IntToStr ( x ) );
							//x := xs - 1;
						End;
						//
						sl := c.ScanLine [ y ];
						Col := Pal [ PicData^ [ fp ] ];
						sl [ x ].rgbtRed := GetRValue ( Col );
						sl [ x ].rgbtGreen := GetGValue ( Col );
						sl [ x ].rgbtBlue := GetBValue ( Col );
						//
						Inc ( fp );
						Inc ( y );
					End;
					gb; // drop last byte
					//Inc ( y );

					// ---
					b := gb;
				End;
				//
				If y < ys Then
				Begin
					Image_Transparent := True;
				End;
				//
			End;

			FreeMem ( PicData, iLen );

			{
			If c = Nil Then
				ImageRenderCurrent
			Else
				ImageRenderCurrentAt ( c, xp, yp, Zoom );
			}

			ImageLoadTo := True;
			//
			fClose;
		End;

		// ****************
		// LOAD DOOM FORMAT

		fmtDoomBeta, fmtDoomOldSprite :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			Seek ( f, iPos );
			//
			ImageResetCurrent ( xs, ys );
			//
			if ( Format = fmtDoomBeta ) Then
			Begin
				GetWord ( f ); // x
				GetWord ( f ); // y
				GetWord ( f ); // xr
				GetWord ( f ); // yr

				iSkippedBytes := 8;
			End
			Else
			Begin
				GetWord ( f ); // x,y
				GetWord ( f ); // xr,yr

				iSkippedBytes := 4;
			End;

			BlockRead ( F, SeekTabW, xs * 2 );
			Inc ( iSkippedBytes, xs * 2 );

			iLen := iLen - iSkippedBytes;

			GetMem ( PicData, iLen );
			BlockRead ( F, PicData^, iLen );

			For x := 0 To xs - 1 Do
			Begin
				//Seek ( F, iPos + SeekTab [ x ] );
				fp := SeekTabW [ x ] - iSkippedBytes;

				//Status ( 'Processing Line ' + Comma ( x + 1 ) + ' of ' + Comma ( xs ) );

				b := gb;
				y := 0;

				While b <> $FF Do
				Begin

					If b = 254 Then
						y := y - 2
					Else
						y := b - 1;

					// ---
					b := gb;

					n := b;
					For i := 0 To n Do
					Begin
						// ---
						b := gb;

						If ( y < ys ) And ( i <> 0 ) And ( i <> n + 1 ) Then
						Begin
							sl := c.ScanLine [ y ];
							Col := Pal [ b ];
							sl [ x ].rgbtRed := GetRValue ( Col );
							sl [ x ].rgbtGreen := GetGValue ( Col );
							sl [ x ].rgbtBlue := GetBValue ( Col );
						End;

						Inc ( y );
					End;

					// ---
					//b := gb;
				End;
			End;

			FreeMem ( PicData, iLen );

			{
			If c = Nil Then
				ImageRenderCurrent
			Else
				ImageRenderCurrentAt ( c, xp, yp, Zoom );
			}

			ImageLoadTo := True;
			//
			fClose;
		End;

		// *****************
		// Load Floor
		//

		fmtFloor:
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			Seek ( f, iPos );
			//
			ImageResetCurrent ( xs, ys );
			//
			GetMem ( PicData, iLen );
			BlockRead ( F, PicData^, iLen );

			// extract floor image

			fp := 0;
			//
			For y := 0 To ys - 1 Do
			Begin
				//
				sl := c.ScanLine [ y ];
				//
				For x := 0 To xs - 1 Do
				Begin
					// b := PicData^ [ y * ys + x ];
					// SetPixel ( c.Handle, x, y, Pal [ b ] );
					Col := Pal [ PicData^ [ fp ] ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
					//
					Inc ( fp );
				End;
			End;
			//
			FreeMem ( PicData, iLen );
			//
			ImageLoadTo := True;
			//
			fClose;
		End;

		// *********************************
		// Load old Doom format (alpha/beta)

		fmtDoomOld :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + Image_Header );
			//
			For y2 := 0 To 3 Do
			Begin
				For y := 0 To ( ys Shr 2 ) - 1 Do
				Begin
					For x2 := 0 To 3 Do
					Begin
						For x := 0 To ( xs Shr 2 ) - 1 Do
						Begin
							b := Byte ( GetByte ( f ) );
							//
							sl := c.ScanLine [ y * 4 + x2 ];
							Col := Pal [ b ];
							sl [ x * 4 + y2 ].rgbtRed := GetRValue ( Col );
							sl [ x * 4 + y2 ].rgbtGreen := GetGValue ( Col );
							sl [ x * 4 + y2 ].rgbtBlue := GetBValue ( Col );
						End;
					End;
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// ************************
		// Load ZDooM image format
		//
		fmtZDoom :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos );
			//
			GetLong ( f ); // IMGZ header
			GetWord ( f ); // x, y, xr, yr
			GetWord ( f );
			GetWord ( f );
			GetWord ( f );
			//
			x := GetLong ( f );
			//
			If x = 0 Then
			Begin
				//
				// --- Uncompressed
				//
				GetLong ( f );
				GetLong ( f );
				//
				For y := 0 To ys - 1 Do
				Begin
					sl := c.ScanLine [ y ];
					For x := 0 To xs - 1 Do
					Begin
						b := Byte ( GetByte ( f ) );
						Col := Pal [ b ];
						sl [ x ].rgbtRed := GetRValue ( Col );
						sl [ x ].rgbtGreen := GetGValue ( Col );
						sl [ x ].rgbtBlue := GetBValue ( Col );
					End;
				End;
				//
				ImageLoadTo := True;
			End
			Else
			Begin
				If x = 1 Then
				Begin
					//
					// --- RLE compression
					//
					GetLong ( f );
					GetLong ( f );
					//
					y := 0;
					While y < ys Do
					Begin
						sl := c.ScanLine [ y ];
						//
						x := 0;
						While x < xs Do
						Begin
							b := Byte ( GetByte ( f ) );
							If b > $80 Then
							Begin
								n := ( 255 - b ) + 2;
								b := Byte ( GetByte ( f ) );
								While n > 0 Do
								Begin
									Col := Pal [ b ];
									sl [ x ].rgbtRed := GetRValue ( Col );
									sl [ x ].rgbtGreen := GetGValue ( Col );
									sl [ x ].rgbtBlue := GetBValue ( Col );
									Inc ( x );
									Dec ( n );
								End;
							End
							Else
							Begin
								n := b + 1;
								While n > 0 Do
								Begin
									b := Byte ( GetByte ( f ) );
									Col := Pal [ b ];
									sl [ x ].rgbtRed := GetRValue ( Col );
									sl [ x ].rgbtGreen := GetGValue ( Col );
									sl [ x ].rgbtBlue := GetBValue ( Col );
									Inc ( x );
									Dec ( n );
								End;
							End;
						End;
						Inc ( y );
					End;
					//
					ImageLoadTo := True;
				End
				Else
				Begin
					ShowMessage ( 'Unknown Compression Method ' + IntToHex ( x, 8 ) );
					ImageLoadTo := False;
				End;
			End;
			//
			fClose;
		End;

		// *****************
		// Load Quake
		//

		fmtQuake:
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			Seek ( f, iPos + 8 ); // Skip 8 bytes header
			//
			ImageResetCurrent ( xs, ys );
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					b := Byte ( GetByte ( f ) );
					Col := Pal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
				End;
			End;
			//
			ImageLoadTo := True;
			//
			fClose;
		End;

		// *****************
		// Load HalfLife
		//

		fmtHalfLife:
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			// read palette
			//
			Seek ( f, iPos + xs * ys + 8 + 2 );
			//
			For x := 0 To 255 Do
			Begin
				b := GetByte ( f );
				g := GetByte ( f );
				r := GetByte ( f );
				LocalPal [ x ]:=
					( Cardinal ( r ) Shl 16 ) +
					( Cardinal ( g ) Shl 8 ) +
					( Cardinal ( b ) );
			End;
			//
			Seek ( f, iPos + 8 ); // Skip 8 bytes header
			//
			ImageResetCurrent ( xs, ys );
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					b := GetByte ( f );
					Col := LocalPal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
				End;
			End;
			//
			ImageLoadTo := True;
			//
			fClose;
		End;

		fmtHalfLife2:
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			// read palette
			//
			x := xs * ys;
			Seek ( f, iPos + 40 + x + x Div 4 + x Div 16 + x Div 64 + 2 );
			//
			For x := 0 To 255 Do
			Begin
				b := GetByte ( f );
				g := GetByte ( f );
				r := GetByte ( f );
				LocalPal [ x ]:=
					( Cardinal ( r ) Shl 16 ) +
					( Cardinal ( g ) Shl 8 ) +
					( Cardinal ( b ) );
				//
				// Pal [ x ] := LocalPal [ x ];
			End;
			//
			Seek ( f, iPos + 40 ); // Skip 40 bytes header
			//
			ImageResetCurrent ( xs, ys );
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					b := GetByte ( f );
					Col := LocalPal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
				End;
			End;
			//
			ImageLoadTo := True;
			//
			fClose;
		End;

		// ***********************
		// Load FTX (FAKK2 images)
		//

		fmtFTX :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			Seek ( f, iPos + 12 ); // Skip 12 bytes header
			//
			ImageResetCurrent ( xs, ys );
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					sl [ x ].rgbtRed := Byte ( GetByte ( f ) );
					sl [ x ].rgbtGreen := Byte ( GetByte ( f ) );
					sl [ x ].rgbtBlue := Byte ( GetByte ( f ) );
					//
					GetByte ( f ); // transparency?
				End;
			End;
			//
			ImageLoadTo := True;
			//
			fClose;
		End;

		//************
		// BBM Format
		//

		fmtBBM:
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			// read palette
			//
			Seek ( f, iPos + $30 );
			//
			For x := 0 To 255 Do
			Begin
				b := GetByte ( f );
				g := GetByte ( f );
				r := GetByte ( f );
				LocalPal [ x ]:=
					( Cardinal ( r ) Shl 16 ) +
					( Cardinal ( g ) Shl 8 ) +
					( Cardinal ( b ) );
			End;
			//
			Seek ( f, iPos + $448 ); // Skip $448 bytes header
			//
			ImageResetCurrent ( xs, ys );
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					b := GetByte ( f );
					Col := LocalPal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
				End;
			End;
			//
			ImageLoadTo := True;
			//
			fClose;
		End;

		//************************
		// Descent Texture Format
		//

		fmtDescent :
		Begin
			{$IFDEF FULLVERSION}
			//
			// --- Is this an image?
			//
			If iSel <= iDP_TextureEntries Then
			Begin
				If Not fOpen ( sFN ) Then
				Begin
					ImageLoadTo := False;
					Exit;
				End;
				//
				// Get data from file header!
				//
				If FileType = PIG2File Then
					Seek ( f, iWadDirPos + ( ( iSel - 1 ) * 18 ) + 9 )
				Else
					Seek ( f, iWadDirPos + ( ( iSel - 1 ) * 17 ) + 9 );
				//
				If FileType = PIG2File Then
				Begin
					// Descent 2
					xs := Byte ( GetByte ( f ) );
					ys := Byte ( GetByte ( f ) );
					//
					b := Byte ( GetByte ( f ) ); // size 2
					ys := ys + Word ( ( b Shr 4 ) Shl 8 );
					xs := xs + Word ( ( b And 15 ) Shl 8 );
					//
					b := Byte ( GetByte ( f ) ); // flags
				End
				Else
				Begin
					// Descent 1
					xs := Byte ( GetByte ( f ) );
					ys := Byte ( GetByte ( f ) );
					//
					b := Byte ( GetByte ( f ) ); // flags
				End;
				//
				ImageResetCurrent ( xs, ys );
				//
				// --- Check for RLE Compression
				//
				If ( ( b And 8 ) <> 0 )
				Or ( ( b And 32 ) <> 0 ) Then
				Begin
					//
					// *** Load compressed
					//
					Seek ( f, iPos + 4 ); // Skip 4 bytes header (which is data length)
					//
					If ( b And 32 ) <> 0 Then
					Begin
						//
						For y := 0 To ys - 1 Do
						Begin
							GetWord ( f );
						End;
						//
					End
					Else
					Begin
						//
						For y := 0 To ys - 1 Do
						Begin
							GetByte ( f );
						End;
						//
					End;
					//
					For y := 0 To ys - 1 Do
					Begin
						x := 0;
						n1 := 0;
						While ( n1 <> $E0 ) Do
						Begin
							n1 := Byte ( GetByte ( f ) );
							//
							If ( n1 And $E0 ) <> $E0 Then
							Begin
								b := n1;
								n1 := 1;
							End
							Else
							Begin
								If ( n1 <> $E0 ) Then
								Begin
									b := Byte ( GetByte ( f ) );
								End;
							End;
							//
							For n2 := 1 To ( n1 And $1F ) Do
							Begin
								If ( b <> 255 ) Or ( FileType = PIG2File ) Then
								Begin
									// SetPixel ( c.Handle, x, y, Pal [ b ] );
									sl := c.ScanLine [ y ];
									Col := Pal [ b ];
									sl [ x ].rgbtRed := GetRValue ( Col );
									sl [ x ].rgbtGreen := GetGValue ( Col );
									sl [ x ].rgbtBlue := GetBValue ( Col );
								End;
								//
								Inc ( x );
								If ( x = xs ) Then
								Begin
									x := 0;
									//Inc ( y );
								End;
							End;
						End;
					End;
				End
				Else
				Begin
					//
					// *** Load Uncompressed
					//
					Seek ( f, iPos );
					//
					For y := 0 To ys - 1 Do
					Begin
						sl := c.ScanLine [ y ];
						For x := 0 To xs - 1 Do
						Begin
							b := Byte ( GetByte ( f ) );
							// SetPixel ( c.Handle, x, y, Pal [ b ] );
							Col := Pal [ b ];
							sl [ x ].rgbtRed := GetRValue ( Col );
							sl [ x ].rgbtGreen := GetGValue ( Col );
							sl [ x ].rgbtBlue := GetBValue ( Col );
						End;
					End;
				End;
				//
				ImageLoadTo := True;
				//
				fClose;
			End
			Else
			Begin
				ImageLoadTo := False; // not a texture - but a sound file
			End;
			{$ELSE}
			ImageLoadTo := False;
			{$ENDIF}
		End;

		// *********
		// Load ROTT

		fmtROTT :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + 10 );
			iHeadPos := GetWord ( f );
			If iHeadPos = $0015 Then
			Begin
				iHeadPos := 12; // masked!!!
				Encoding := 1;
			End
			Else
			Begin
				iHeadPos := 10;
				Encoding := 0;
			End;
			//
			For x := 0 To xs - 1 Do
			Begin
				//
				Seek ( f, iPos + iHeadPos + x * 2 ); // Skip 10 bytes header
				iSeekPos := GetWord ( f );
				//
				Seek ( f, iPos + iSeekPos );
				//
				If Encoding = 0 Then
				Begin
					//
					// normal images
					//
					Repeat
						n1 := GetByte ( f ); // skip
						//
						If n1 <> $FF Then
						Begin
							y := n1;
							n2 := Byte ( GetByte ( f ) ); // bytes to follow
							//
							While ( y < ys ) And ( n2 > 0 ) Do
							Begin
								b := Byte ( GetByte ( f ) );
								If b <> $FF Then
								Begin
									sl := c.ScanLine [ y ];
									Col := Pal [ b ];
									sl [ x ].rgbtRed := GetRValue ( Col );
									sl [ x ].rgbtGreen := GetGValue ( Col );
									sl [ x ].rgbtBlue := GetBValue ( Col );
								End;
								Inc ( y );
								Dec ( n2 );
							End;
						End;
					Until n1 = $FF;
					//
				End
				Else
				Begin
					//
					n1 := GetByte ( f ); // skip
					n2 := Byte ( GetByte ( f ) ); // bytes to follow
					y := n1;
					//
					n1 := 0;
					//
					While ( n2 <> $FF ) Do
					Begin
						//
						While ( y >= 0 ) And ( y < ys ) And ( n2 > 0 ) Do
						Begin
							b := Byte ( GetByte ( f ) );
							If b <> $FF Then
							Begin
								sl := c.ScanLine [ y ];
								Col := Pal [ b ];
								sl [ x ].rgbtRed := GetRValue ( Col );
								sl [ x ].rgbtGreen := GetGValue ( Col );
								sl [ x ].rgbtBlue := GetBValue ( Col );
							End;
							Inc ( y );
							Dec ( n2 );
						End;
						//
						Inc ( n1 );
						If n1 = 1 Then
						Begin
							n2 := Byte ( GetByte ( f ) ); // bytes to follow
							//
							If n2 <> $FF Then
							Begin
								GetByte ( f ); // skip 3 bytes???
								GetByte ( f );
								GetByte ( f );
							End;
						End;
						//
						If n2 <> $FF Then
						Begin
							n2 := Byte ( GetByte ( f ) ); // bytes to follow
							y := ys - n2;
						End;
						//
					End;
					//
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// ************
		// Load ROTT2

		fmtROTT2 :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + 2 );
			//
			For y2 := 0 To 3 Do
			Begin
				For y := 0 To ( ys Shr 2 ) - 1 Do
				Begin
					For x2 := 0 To 3 Do
					Begin
						For x := 0 To ( xs Shr 2 ) - 1 Do
						Begin
							b := Byte ( GetByte ( f ) );
							// SetPixel ( c.Handle, x * 4 + y2, y * 4 + x2, Pal [ b ] );
							sl := c.ScanLine [ y * 4 + x2 ];
							Col := Pal [ b ];
							sl [ x * 4 + y2 ].rgbtRed := GetRValue ( Col );
							sl [ x * 4 + y2 ].rgbtGreen := GetGValue ( Col );
							sl [ x * 4 + y2 ].rgbtBlue := GetBValue ( Col );
						End;
					End;
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// ************
		// Load Generic

		fmtGeneric :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + Image_Header );
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					b := Byte ( GetByte ( f ) );
					Col := Pal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

    // ****************
		// Load Generic RGB

		fmtGenericRGB :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + Image_Header );
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					r := Byte ( GetByte ( f ) );
          GetByte ( f );
					g := Byte ( GetByte ( f ) );
          GetByte ( f );
					b := Byte ( GetByte ( f ) );
          GetByte ( f );
					//
          GetByte ( f );
          GetByte ( f );
          //
					sl [ x ].rgbtRed := r;
					sl [ x ].rgbtGreen := g;
					sl [ x ].rgbtBlue := b;
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// ********************
		// Load Wolf Wall Image

		fmtWolfWall :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos );
			//
			For x := 0 To xs - 1 Do
			Begin
				For y := 0 To ys - 1 Do
				Begin
					b := Byte ( GetByte ( f ) );
					sl := c.ScanLine [ y ];
					Col := Pal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// ****************
		// Load Wolf Sprite

		fmtWolfSprite :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos );
			//
			x1 := GetWord ( f );
			x2 := GetWord ( f );
			//
			for x := x1 to x2 do
			Begin
				Seek ( f, iPos + word(4+(x-x1)*2));
				StartOffset [ x ] := GetWord ( f );
				Seek ( f, iPos + StartOffset [ x ] );
				i := 0;
				ColumnDef [ x, i ] := GetWord ( f );
				While ColumnDef [ x, i ]<>0 do
				Begin
					Inc ( i );
					ColumnDef [ x, i ] := GetWord ( f );
					Inc ( i );
					ColumnDef [ x, i ] := GetWord ( f );
					Inc ( i );
					ColumnDef [ x, i ] := GetWord ( f );
				End;
			end;
			//
			Seek ( f, iPos );
			PicDataSize := Longint ( iPos + 4 + ( x2 - x1 + 1 ) * 2 );
			PicDataSize := iPos + StartOffset [ x1 ] - PicDataSize;
			PicDataSize := PicDataSize + 4 + ( x2 - x1 + 1) * 2;
			//
			GetMem ( PicData, PicDataSize );
			BlockRead ( f, PicData^, picdatasize);
			//
			for x:= x1 to x2 do
			Begin
				i:= 0;
				While ColumnDef[x,i]<>0 do
				Begin
					y2 := ColumnDef [x,i] div 2;
					y1 := ColumnDef [x,i+2] div 2;
					j := y1+ColumnDef [x,i+1];
					For y := y1 to y2-1 do
					Begin
						// SetPixel ( c.Handle, x, y, Pal [ picdata^ [ j ] ] );
						sl := c.ScanLine [ y ];
						Col := Pal [ picdata^ [ j ] ];
						sl [ x ].rgbtRed := GetRValue ( Col );
						sl [ x ].rgbtGreen := GetGValue ( Col );
						sl [ x ].rgbtBlue := GetBValue ( Col );
						Inc ( j );
					End;
					Inc(i,3);
				End;
			end;
			//
			FreeMem ( PicData, PicDataSize );
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// ********
		// Load BMP

		fmtBMP :
		Begin
			TempPic := TPicture.Create;
			ExtractedFileName := ExtractFile ( '.BMP' );
			//
			If Not fOpen ( ExtractedFileName ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			// look up bitsperpixel and compression
			Seek ( f, 28 );
			x1 := Word ( GetWord ( f ) );
			y1 := Word ( GetWord ( f ) ); // 0 = no compression, others=RLE
			If ( ( x1 = 8 ) And ( y1 = 0 ) ) Then
			Begin
				//
				ImageResetCurrent ( xs, ys );
				//
				// 256 color image
				Seek ( f, 46 );
				i := GetWord ( f ); // number of colors
				If i = 0 Then i := 256;
				If ( i < 0 ) Or ( i > 256 ) Then
				Begin
					ShowMessage ( 'Invalid BMP file, number of colors: ' + IntToStr ( i ) );
					ImageLoadTo := False;
				End
				Else
				Begin
					Seek ( f, 14 );
					fp := GetLong ( f ) + 14;
					Seek ( f, fp );
					//
					// read palette
					For x := 0 To i - 1 Do
					Begin
						r := Byte ( GetByte ( f ) );
						g := Byte ( GetByte ( f ) );
						b := Byte ( GetByte ( f ) );
						GetByte ( f );
						LocalPal [ x ]:=
							( Cardinal ( r ) Shl 16 ) +
							( Cardinal ( g ) Shl 8 ) +
							( Cardinal ( b ) );
					End;
					//
					Seek ( f, 10 );
					fp := GetLong ( f ); // bitmap begin
					Seek ( f, fp );
					//
					For y := ys - 1 DownTo 0 Do
					Begin
						sl := c.ScanLine [ y ];
						For x := 0 To xs - 1 Do
						Begin
							b := Byte ( GetByte ( f ) );
							Col := LocalPal [ b ];
							sl [ x ].rgbtRed := GetRValue ( Col );
							sl [ x ].rgbtGreen := GetGValue ( Col );
							sl [ x ].rgbtBlue := GetBValue ( Col );
						End;
						If ( xs And 3 ) <> 0 Then
						Begin
							// lines are padded to 4 byte boundaries, skip some bytes
							For x := ( xs And 3 ) To 3 Do
							Begin
								GetByte ( f );
							End;
						End;
					End;
				End;
				//
				fClose;
				//
			End
			Else
			Begin
				//
				// check for 24 bit
				If ( x1 = 24 ) Then
				Begin
					//
					ImageResetCurrent ( xs, ys );
					//
					// 24 bit color image
					Seek ( f, 10 );
					fp := GetLong ( f ); // bitmap begin
					Seek ( f, fp );
					//
					For y := ys - 1 DownTo 0 Do
					Begin
						sl := c.ScanLine [ y ];
						For x := 0 To xs - 1 Do
						Begin
							b := Byte ( GetByte ( f ) );
							g := Byte ( GetByte ( f ) );
							r := Byte ( GetByte ( f ) );
							sl [ x ].rgbtRed := r;
							sl [ x ].rgbtGreen := g;
							sl [ x ].rgbtBlue := b;
						End;
						If ( ( xs * 3 ) And 3 ) <> 0 Then
						Begin
							// lines are padded to 4 byte boundaries, skip some bytes
							For x := ( ( xs * 3 ) And 3 ) To 3 Do
							Begin
								GetByte ( f );
							End;
						End;
					End;
					//
					fClose;
					//
				End
				Else
				Begin
					//
					fClose;
					//
					// let Delphi handle it
					// (for RLE compressed images, 4 or other number of bits)
					TempPic.LoadFromFile ( ExtractedFileName );
					//
					xs := TempPic.Width;
					ys := TempPic.Height;
					//
					ImageResetCurrent ( xs, ys );
					//
					c.Canvas.CopyRect ( TempPic.Bitmap.Canvas.ClipRect,
						TempPic.Bitmap.Canvas, TempPic.Bitmap.Canvas.ClipRect );
					//
					TempPic.Bitmap.FreeImage;
					//
					ImageLoadTo := True;
				End;
			End;
		End;

		// ********
		// Load PCX

		fmtPCX :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos );
			//
			BlockRead ( f, Manufacturer, 1 );
			BlockRead ( f, Version, 1 );
			BlockRead ( f, Encoding, 1 );
			BlockRead ( f, BitPerPixel, 1 );
			//
			GetWord ( f ); // skip size
			GetWord ( f );
			GetWord ( f );
			GetWord ( f );
			{
			BlockRead ( f, x, 2 );
			BlockRead ( f, y, 2 );
			BlockRead ( f, xs, 2 );
			BlockRead ( f, ys, 2 );
			xs := xs - x + 1;
			ys := ys - y + 1;
			}
			//
			GetWord ( f );
			//BlockRead ( f, ReadLine. p^, 2 ); { HDPI }
			GetWord ( f );
			//BlockRead ( f, ReadLine. p^, 2 ); { VDPI }

			//GetMem ( PicData, 60 );
			//BlockRead ( f, PicData^, 48 );

			//BlockRead ( f, ReadLine. p^, 48 ); { Palette }
			//GetByte ( f );
			//BlockRead ( f, ReadLine. p^, 1 ); { reserved zero }

			Seek ( f, iPos + 65 );
			BlockRead ( f, Planes, 1 );
			BlockRead ( f, BytesPerLine, 2 );

			//BlockRead ( f, PicData^, 60 );
			//BlockRead ( f, ReadLine. p^, 60 );
			//FreeMem ( PicData, 60 );

			// --- Get Palette

			Seek ( f, iPos + iLen - ( 3 * 256 + 1 ) );
			If GetByte ( f ) = 12 Then
			Begin
				For i := 0 To 255 Do
				Begin
					b := GetByte ( f );
					g := GetByte ( f );
					r := GetByte ( f );
					LocalPal [ i ] := r Shl 16 + g Shl 8 + b;
				End;
			End;

			Seek ( f, iPos + $80 );

			MaxColors := Planes * 1 Shl BitPerPixel;

			TotalBytes := Planes * BytesPerLine;
			ReadyBytes := 0;

			x := 0;
			y := 0;
			Plane := 0;

			While ( y < ys ) And ( x < xs ) Do
			Begin
				{$b-}
				b := GetByte ( f );
				{$b+}
				If IOResult <> 0 Then
				Begin
					b := 0;
					x := xs - 1;
					y := ys - 1;
				End;
				//
				If Encoding > 0 Then
				Begin
					If b > $BF Then
					Begin
						Count := b And $3F;
						BlockRead ( f, b, 1 );
					End
					Else
					Begin
						Count := 1;
					End;
					//
					For Counter := 1 To Count Do
					Begin
						If BitPerPixel = 1 Then
						Begin
							For Bit := 0 To 7 Do
							Begin
								{
								ReadLine. p^ [ x Shl 3 + 8 - Bit ] := ReadLine. p^ [ x Shl 3 + 8 - Bit ]
									Or ( b Shr Bit And 1 ) Shl Plane;
								}
							End;
						End
						Else
						Begin
							sl := c.ScanLine [ y ];
							Col := LocalPal [ b ];
							sl [ x ].rgbtRed := GetRValue ( Col );
							sl [ x ].rgbtGreen := GetGValue ( Col );
							sl [ x ].rgbtBlue := GetBValue ( Col );
						End;
						//
						Inc ( x );
						//
						If x = BytesPerLine Then
						Begin
							x := 0;
							If BitPerPixel = 8 Then
							Begin
								Inc ( Plane );
							End;
						End;
						Inc ( ReadyBytes );
					End;
				End
				Else
				Begin
					Inc ( ReadyBytes );
				End;
				//
				If ReadyBytes >= TotalBytes Then
				Begin
					{
					If MaxAvail > xSize Then
					Begin
						GetBMem ( y, xSize );
					End
					Else Begin
						DuplicateLine ( y, y - 1 );
					End;
					Move ( ReadLine. p^, BM [ y ]. p^, xSize );
					FillChar ( ReadLine. p^, xSize, 0 );
					}
					ReadyBytes := 0;
					Plane := 0;
					x := 0;
					Inc ( y );
				End;
			End;

			(*
			{ Check for 256 color palette }
			If ( Version = 5 ) And Not Eof ( f )
			Then Begin
				x := 0;
				BlockRead ( f, x, 1 );
				If x = 12 Then
				Begin
					For i := 0 To 255 Do
					Begin
						r := GetByte ( f );
						g := GetByte ( f );
						b := GetByte ( f );
						LocalPal [ i ] := r Shl 16 + g Shl 8 + b;
						//BlockRead ( f, Colors [ 0 ], 768 );
					End;
				End
				Else
				Begin
					{
					For i := 0 To MaxColors - 1 Do
					Begin
						Colors [ i, 0 ] := Round ( 63 * ( i / ( MaxColors - 1 ) ) );
						Colors [ i, 1 ] := Colors [ i, 0 ];
						Colors [ i, 2 ] := Colors [ i, 0 ];
					End;
					}
				End;
			End;
			*)
			//
			fClose;
			//
			BitPerPixel := BitPerPixel * Planes;
			//
			ImageLoadTo := True;
		End;

		fmtGIF :
		Begin
			{$IFDEF SUPPORTGIF}
			TGi := TGIFImage.Create;
			TGi.LoadFromFile ( ExtractFile ( '.GIF' ) );
			//
			xs := TGi.Width;
			ys := TGi.Height;
			//
			ImageResetCurrent ( xs, ys );
			//
			cImage.Canvas.CopyRect ( TGi.Bitmap.Canvas.ClipRect,
				TGi.Bitmap.Canvas, TGi.Bitmap.Canvas.ClipRect );
			//
			ImageLoadTo := True;
			//
			TGi.Free;
			{$ELSE}
			ImageLoadTo := False;
			{$ENDIF}
		End;

		// *****************
		// Load TGA
		//

		fmtTGA:
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			// --- Get Compression
			Seek ( f, iPos + $2 );
			cm := GetByte ( f );
			//
			If ( cm <> 2 ) And ( cm <> 10 ) Then
			Begin
				//
				ShowMessage ( 'Unsupported TGA file.' + #13 + '(Compression: ' + IntToStr ( cm ) +')' );
				fClose;
				ImageLoadTo := False;
				//
			End
			Else
			Begin
				//
				// --- Get Color Depth
				//
				Seek ( f, iPos + $10 );
				BitPerPixel := GetByte ( f );
				//
				If ( BitPerPixel <> $18 ) And ( BitPerPixel <> $20 ) Then
				Begin
					//
					ShowMessage ( 'Only 24 and 32 bit TGA images are supported. ' + IntToStr ( BitPerPixel ) );
					fClose;
					ImageLoadTo := False;
					//
				End
				Else
				Begin
					//
					Seek ( f, iPos + 18 ); // Skip 18 bytes header
					//
					ImageResetCurrent ( xs, ys );
					//
					Case cm Of

						2 :
						Begin
							//
							For y := ys - 1 DownTo 0 Do
							Begin
								sl := c.ScanLine [ y ];
								For x := 0 To xs - 1 Do
								Begin
									b := GetByte ( f );
									g := GetByte ( f );
									r := GetByte ( f );
									//
									If BitPerPixel = $20 Then
									Begin
										n := GetByte ( f ); // Luminance?
										//
										r := Round ( ( n / 255 ) * r );
										g := Round ( ( n / 255 ) * g );
										b := Round ( ( n / 255 ) * b );
									End;
									//
									//SetPixel ( c.Handle, x, y, RGB ( r, g, b ) );
									sl [ x ].rgbtRed := r;
									sl [ x ].rgbtGreen := g;
									sl [ x ].rgbtBlue := b;
								End;
							End;
						End;

						10 :
						Begin
							y := ys - 1;
							sl := c.ScanLine [ y ];
							//
							x := 0;
							//
							While y >= 0 Do
							Begin
								n1 := GetByte ( f );
								//
								If ( n1 And $80 ) = 0 Then
								Begin
									// raw packet
									//
									n1 := ( n1 And 127 );
									//
									For i := 0 To n1 Do
									Begin
										b := GetByte ( f );
										g := GetByte ( f );
										r := GetByte ( f );
										//
										If BitPerPixel = $20 Then
										Begin
											n := GetByte ( f ); // Luminance?
											//
											r := Round ( ( n / 255 ) * r );
											g := Round ( ( n / 255 ) * g );
											b := Round ( ( n / 255 ) * b );
										End;
										sl [ x ].rgbtRed := r;
										sl [ x ].rgbtGreen := g;
										sl [ x ].rgbtBlue := b;
										//SetPixel ( c.Handle, x, y, RGB ( r, g, b ) );
										//
										Inc ( x );
										If x = xs Then
										Begin
											x := 0;
											Dec ( y );
											If ( y >= 0 ) Then sl := c.ScanLine [ y ];
										End;
									End;
								End
								Else
								Begin
									// run length
									//
									n1 := ( n1 And 127 );
									//
									b := GetByte ( f );
									g := GetByte ( f );
									r := GetByte ( f );
									//
									If BitPerPixel = $20 Then
									Begin
										n := GetByte ( f ); // Luminance?
										//
										r := Round ( ( n / 255 ) * r );
										g := Round ( ( n / 255 ) * g );
										b := Round ( ( n / 255 ) * b );
									End;
									//
									For i := 0 To n1 Do
									Begin
										sl [ x ].rgbtRed := r;
										sl [ x ].rgbtGreen := g;
										sl [ x ].rgbtBlue := b;
										//SetPixel ( c.Handle, x, y, RGB ( r, g, b ) );
										//
										Inc ( x );
										If x = xs Then
										Begin
											x := 0;
											Dec ( y );
											If ( y >= 0 ) Then sl := c.ScanLine [ y ];
										End;
									End;
								End;
							End;
						End;

					End;
					//
					fClose;
					//
					ImageLoadTo := True;
				End;
			End;
		End;

		// *****************
		// Load PPM
		//

		fmtPPM:
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			Seek ( f, iPos + 13 ); // Skip at least 13 bytes header
			//
			b := GetByte ( f );
			While b <> $A Do // skip header
			Begin
				b := GetByte ( f );
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			For y := 0 to ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					sl [ x ].rgbtRed := GetByte ( f );
					sl [ x ].rgbtGreen := GetByte ( f );
					sl [ x ].rgbtBlue := GetByte ( f );
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// **********************
		// Load DarkForces Bitmap
		//

		fmtDFBM:
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			Seek ( f, iPos + 32 ); // Skip 32 bytes header
			//
			ImageResetCurrent ( xs, ys );
			//
			For x := 0 to xs - 1 Do
			Begin
				For y := ys - 1 DownTo 0 Do
				Begin
					b := GetByte ( f );
					//
					If ( b <> 0 ) Then
					Begin
						sl := c.ScanLine [ y ];
						Col := Pal [ b ];
						sl [ x ].rgbtRed := GetRValue ( Col );
						sl [ x ].rgbtGreen := GetGValue ( Col );
						sl [ x ].rgbtBlue := GetBValue ( Col );
					End;
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// **********************
		// Load DarkForces Sprite
		//

		fmtDFSprite:
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + Image_Header + 8 ); // Check Compress Flag
			If GetLong ( f ) = 1 Then
			Begin
				//
				For x := 0 to xs - 1 Do
				Begin
					//
					Seek ( f, iPos + Image_Header + 8 + 16 + x * 4 );
					iSeekPos := GetLong ( f ) + Image_Header;
					//
					If x = xs - 1 Then
					Begin
						i := iLen - iSeekPos; // !!! cLen changed to iLen
					End
					Else
					Begin
						i := GetLong ( f ) + Image_Header;
						i := i - iSeekPos;
					End;
					//
					Seek ( f, iPos + iSeekPos );
					//
					y := ys;
					While i > 0 Do
					Begin
						b := GetByte ( f );
						Dec ( i );
						//
						If b > $80 Then
						Begin
							y := y - ( b And $7F );
						End
						Else
						Begin
							n1 := b;
							While ( n1 > 0 ) And ( i > 0 ) Do
							Begin
								b := GetByte ( f );
								Dec ( n1 );
								Dec ( i );
								//
								If ( b <> 0 ) Then
								Begin
									sl := c.ScanLine [ y ];
									Col := Pal [ b ];
									sl [ x ].rgbtRed := GetRValue ( Col );
									sl [ x ].rgbtGreen := GetGValue ( Col );
									sl [ x ].rgbtBlue := GetBValue ( Col );
								End;
								Dec ( y );
							End;
						End;
					End;
				End;
				//
			End
			Else
			Begin
				//
				Seek ( f, iPos + Image_Header + 24 ); // Skip 56 bytes header
				//
				For x := 0 to xs - 1 Do
				Begin
					For y := ys - 1 DownTo 0 Do
					Begin
						b := GetByte ( f );
						If b <> 0 Then
						Begin
							//SetPixel ( c.Handle, x, y, Pal [ b ] );
							sl := c.ScanLine [ y ];
							Col := Pal [ b ];
							sl [ x ].rgbtRed := GetRValue ( Col );
							sl [ x ].rgbtGreen := GetGValue ( Col );
							sl [ x ].rgbtBlue := GetBValue ( Col );
						End;
					End;
				End;
				//
			End;
			fClose;
			//
			ImageLoadTo := True;
		End;

		//*************************
		// CPS Format (EOB1, EOB2)
		//

		fmtCPS:
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			Seek ( f, iPos + 10 ); // Skip 10 bytes header
			//
			ImageResetCurrent ( xs, ys );
			//
			// get twice the memory for safety
			GetMem ( PicData, 64000 * 2 );
			//
			For y := 0 To ys - 1 Do
			Begin
				For x := 0 To xs - 1 Do
				Begin
					PicData^ [ y * xs + x ] := 3 + ( ( x + y ) And 1 );
				End;
			End;
			//
			x := 0; // current pos
			//
			b := 0;
			While b <> $80 Do
			Begin
				//
				If ( x > 160 * 320 + 80 ) Then
					Inc ( b );
				//
				b := Byte ( GetByte ( f ) );
				//
				If b = $FF Then
				Begin
					iCW := Word ( GetWord ( f ) );
					iRelPos := Word ( GetWord ( f ) );
					//
					For i := 0 To iCW - 1 Do
					Begin
						b := PicData^ [ iRelPos + i ]; // !!!
						PicData^ [ x ] := b;
						Inc ( x );
					End;
					b := 0; // avoid exiting from loop
					//
				End
				Else
				Begin
					If b = $FE Then
					Begin
						iCW := Word ( GetWord ( f ) );
						b := Byte ( GetByte ( f ) );
						//
						For i := 0 To iCW - 1 Do
						Begin
							PicData^ [ x ] := b;
							Inc ( x );
						End;
						b := 0; // avoid exiting from loop
						//
					End
					Else
					Begin
						//
						If ( b And $80 ) = 0 Then
						Begin
							iCW := ( ( b Shr 4 ) And 7 ) + 3;
							//
							iRelPos := Byte ( GetByte ( f ) );
							iRelPos := iRelPos Or ( ( b And $F ) Shl 8 );
							//
							If iRelPos > x Then
							Begin
								ShowMessage ( 'Error reading image' + #13 +
									'Current Position: ' + IntToStr ( x ) );
								b := $80; // exit
							End
							Else
							Begin
								//
								For i := 0 To iCW - 1 Do
								Begin
									b := PicData^ [ x - iRelPos + i ];
									PicData^ [ x + i ] := b;
								End;
								b := 0; // avoid exiting from loop
								//
								Inc ( x, iCW );
								//
							End;
						End
						Else
						Begin
							If ( b And $C0 ) = $80 Then
							Begin
								//
								// if b = $80, stops
								//
								iCW := b And $3F;
								//
								For i := 1 To iCW Do
								Begin
									b := Byte ( GetByte ( f ) );
									PicData^ [ x ] := b;
									b := 0;
									Inc ( x );
								End;
								//
							End
							Else
							Begin
								//
								iCW := b And $3F + 3;
								iRelPos := Word ( GetWord ( f ) );
								//
								For i := 0 To iCW - 1 Do
								Begin
									b := PicData^ [ iRelPos + i ]; // !!!
									PicData^ [ x ] := b;
									Inc ( x );
								End;
								b := 0; // avoid exiting from loop
								//
							End;
						End;
					End;
				End;
				//
				If x > 64000 Then
				Begin
					ShowMessage ( 'Error reading image' + #13 + 'Current position: ' + IntToStr ( x ) );
					b := $80;
				End;
				//
			End;
			//ShowMessage ( IntToStr ( x ) );
			//
			fClose;
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					b := PicData^ [ y * xs + x ];
					Col := Pal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
				End;
			End;
			//
			FreeMem ( PicData, 64000 * 2 );
			//
			ImageLoadTo := True;
		End;

		// ****************************
		// Load EOB3 (multiple images)

		fmtEOB3 :
		Begin
			{$IFDEF FULLVERSION}
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			Try
				Seek ( f, iPos + 4 );
				nImgs := GetWord ( f ); // get number of images
				//
				If ( Image_SubIndex > nImgs )
				Or ( Image_SubIndex < 1 ) Then
				Begin
					Image_SubIndex := 1;
				End;
				//
				If nImgs > 1 Then
				Begin
					//
					isg.DefaultRowHeight := 18;
					//
					isg.RowCount := nImgs + 1;
					isg.ColCount := 2;
					isg.ColWidths [ 0 ] := -1; // hide first column, not needed
					//
					isg.Cells [ 1, 0 ] := 'Image';
					//
					For y := 1 To nImgs Do
					Begin
						isg.Cells [ 1, y ] := Zero ( y, 3 );
					End;
				End;
				//
				Seek ( f, iPos + 6 + ( Image_SubIndex - 1 ) * 4  );
				Image_Header := GetLong ( f );
				//
				If Image_Header < iLen Then
				Begin
					Seek ( f, iPos + Image_Header );
					//
					xs := GetWord ( f );
					ys := GetWord ( f );
					//
					ImageResetCurrent ( xs, ys );
					//
					b := 0;
					While b <> $FF Do
					Begin
						b := Byte ( GetByte ( f ) );
						//
						If b <> $FF Then
						Begin
							yc := b; // get first byte, y position
							//
							Repeat
								x := Byte ( GetByte ( f ) ); // starting x
								//
								r := Byte ( GetByte ( f ) ); // flag
								//
								b := Byte ( GetByte ( f ) ); // drop
								//
								n := Byte ( GetByte ( f ) ); // number of bytes to follow
								//
								y := yc;
								//
								xc := 0;
								While xc < n Do
								Begin
									cm := Byte ( GetByte ( f ) );
									Inc ( xc );
									//
									If ( cm And 1 ) = 1 Then
									Begin
										cm := ( cm + 1 ) Div 2;
										// compression
										b := Byte ( GetByte ( f ) );
										Inc ( xc );
										//
										While cm > 0 Do
										Begin
											sl := c.ScanLine [ y ];
											Col := Pal [ b ];
											sl [ x ].rgbtRed := GetRValue ( Col );
											sl [ x ].rgbtGreen := GetGValue ( Col );
											sl [ x ].rgbtBlue := GetBValue ( Col );
											Inc ( x );
											Dec ( cm );
										End;
									End
									Else
									Begin
										cm := ( cm + 2 ) Div 2;
										// pixel data (colors)
										While cm > 0 Do
										Begin
											b := Byte ( GetByte ( f ) );
											Inc ( xc );
											sl := c.ScanLine [ y ];
											Col := Pal [ b ];
											sl [ x ].rgbtRed := GetRValue ( Col );
											sl [ x ].rgbtGreen := GetGValue ( Col );
											sl [ x ].rgbtBlue := GetBValue ( Col );
											Inc ( x );
											Dec ( cm );
										End;
									End;
								End;
								//
							Until r = $80; // flag, stop at $80
						End;
						//
					End;
					//
					ImageLoadTo := True;
				End
				Else
					ImageLoadTo := False;
			Finally
				//
				fClose;
				//
			End;
			{$ELSE}
			ImageLoadTo := False;
			{$ENDIF}
		End;

		// **************************************
		// Load DarkForces WAX (multiple images)

		fmtDFWAX :
		Begin
			{$IFDEF FULLVERSION}
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			Seek ( f, iPos + 4 );
			nImgs := GetWord ( f ); // get number of images
			//
			If ( Image_SubIndex > nImgs )
			Or ( Image_SubIndex < 1 ) Then
			Begin
				Image_SubIndex := 1;
			End;
			//
			If nImgs > 1 Then
			Begin
				//
				isg.DefaultRowHeight := 18;
				//
				isg.RowCount := nImgs + 1;
				isg.ColCount := 2;
				isg.ColWidths [ 0 ] := -1; // hide first column, not needed
				//
				isg.Cells [ 1, 0 ] := 'Image';
				//
				For y := 1 To nImgs Do
				Begin
					isg.Cells [ 1, y ] := Zero ( y, 3 );
				End;
			End;
			//
			Seek ( f, iPos + 6 + ( Image_SubIndex - 1 ) * 4  );
			Image_Header := GetLong ( f );
			Seek ( f, iPos + Image_Header );
			//
			xs := GetWord ( f );
			ys := GetWord ( f );
			//
			ImageResetCurrent ( xs, ys );
			//
			b := 0;
			While b <> $FF Do
			Begin
				b := GetByte ( f );
				//
				If b <> $FF Then
				Begin
					yc := b; // get first byte, y position
					//
					Repeat
						x := Byte ( GetByte ( f ) ); // starting x
						//
						r := GetByte ( f ); // flag
						//
						b := GetByte ( f ); // drop
						//
						n := GetByte ( f ); // number of bytes to follow
						//
						y := yc;
						//
						xc := 0;
						While xc < n Do
						Begin
							cm := GetByte ( f );
							Inc ( xc );
							//
							If ( cm And 1 ) = 1 Then
							Begin
								cm := ( cm + 1 ) Div 2;
								// compression
								b := GetByte ( f );
								Inc ( xc );
								//
								While cm > 0 Do
								Begin
									sl := c.ScanLine [ y ];
									Col := Pal [ b ];
									sl [ x ].rgbtRed := GetRValue ( Col );
									sl [ x ].rgbtGreen := GetGValue ( Col );
									sl [ x ].rgbtBlue := GetBValue ( Col );
									Inc ( x );
									Dec ( cm );
								End;
							End
							Else
							Begin
								cm := ( cm + 2 ) Div 2;
								// pixel data (colors)
								While cm > 0 Do
								Begin
									b := GetByte ( f );
									Inc ( xc );
									sl := c.ScanLine [ y ];
									Col := Pal [ b ];
									sl [ x ].rgbtRed := GetRValue ( Col );
									sl [ x ].rgbtGreen := GetGValue ( Col );
									sl [ x ].rgbtBlue := GetBValue ( Col );
									Inc ( x );
									Dec ( cm );
								End;
							End;
						End;
						//
					Until r = $80; // flag, stop at $80
				End;
				//
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
			{$ELSE}
			ImageLoadTo := False;
			{$ENDIF}
		End;

		// ******************************
		// Load LG RES (multiple images)

		fmtLGRES :
		Begin
			{$IFDEF FULLVERSION}
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			Seek ( f, iPos );
			nImgs := GetWord ( f ); // get number of images
			//
			If ( Image_SubIndex > nImgs )
			Or ( Image_SubIndex < 1 ) Then
			Begin
				Image_SubIndex := 1;
			End;
			//
			If nImgs > 1 Then
			Begin
				//
				isg.DefaultRowHeight := 18;
				//
				isg.RowCount := nImgs + 1;
				isg.ColCount := 2;
				isg.ColWidths [ 0 ] := -1; // hide first column, not needed
				//
				isg.Cells [ 1, 0 ] := 'Image';
				//
				For y := 1 To nImgs Do
				Begin
					isg.Cells [ 1, y ] := Zero ( y, 3 );
				End;
			End;
			//
			Seek ( f, iPos + 2 + ( Image_SubIndex - 1 ) * 4 );
			Image_Header := GetLong ( f );
			//
			If Image_Header < iLen Then
			Begin
				// --- Get compression flag
				Seek ( f, iPos + Image_Header + 4 );
				cm := Byte ( GetByte ( f ) );
				//
				// --- Get Size from image header + 8
				//
				Seek ( f, iPos + Image_Header + 8 );
				xs := GetWord ( f );
				ys := GetWord ( f );
				//
				ImageResetCurrent ( xs, ys );
				//
				// --- Image data begins from header + 28
				//
				Seek ( f, iPos + Image_Header + 28 );
				//
				If cm = 4 Then
				Begin
					// --- cm = 4, compressed bitmap
					{
					00 nn xx		write nn bytes of colour xx
					nn .. ..    0<nn<0x80	copy nn bytes direct
					80 00 00		skip rest of file (end of compressed data)
					80 mm nn    0<nn<0x80	skip (nn*256+mm) bytes (write transparencies)
					80 nn 80 .. ..		copy nn bytes direct
					80 mm nn    0x80<nn<0xBF copy ((nn&0x3f)*256+mm) bytes
					80 mm nn xx 0xC0<nn	write ((nn&0x3f)*256+mm) bytes of colour xx
					nn	        0x80<nn	skip (nn&0x7f) bytes
					}
					//
					y := 0;
					x := 0;
					//
					i := 0; // stop flag
					//
					While i = 0 Do
					Begin
						b := Byte ( GetByte ( f ) );
						//
						If ( b = 0 ) Then
						Begin
							//
							// --- Color compress
							//
							n := Byte ( GetByte ( f ) ); // count
							b := Byte ( GetByte ( f ) ); // color
							//
							While n > 0 Do
							Begin
								sl := c.ScanLine [ y ];
								Col := Pal [ b ];
								sl [ x ].rgbtRed := GetRValue ( Col );
								sl [ x ].rgbtGreen := GetGValue ( Col );
								sl [ x ].rgbtBlue := GetBValue ( Col );
								Inc ( x );
								If x = xs Then
								Begin
									x := 0;
									Inc ( y );
								End;
								Dec ( n );
							End;
							//
						End
						Else
						Begin
							If b < $80 Then
							Begin
								//
								// --- Direct
								//
								n := b;
								While n > 0 Do
								Begin
									b := Byte ( GetByte ( f ) );
									//
									sl := c.ScanLine [ y ];
									Col := Pal [ b ];
									sl [ x ].rgbtRed := GetRValue ( Col );
									sl [ x ].rgbtGreen := GetGValue ( Col );
									sl [ x ].rgbtBlue := GetBValue ( Col );
									Inc ( x );
									If x = xs Then
									Begin
										x := 0;
										Inc ( y );
									End;
									Dec ( n );
								End;
								//
							End
							Else
							Begin
								If b = $80 Then
								Begin
									//
									b := Byte ( GetByte ( f ) );
									n := Byte ( GetByte ( f ) );
									//
									If ( b = 0 ) And ( n = 0 ) Then
									Begin
										//
										// --- End marker
										//
										i := 1; // stop
									End
									Else
									Begin
										//
										If n < $80 Then
										Begin
											iCW := Word ( n ) Shl 8 + Word ( b );
											//
											// --- skip
											//
											While iCW > 0 Do
											Begin
												Inc ( x );
												If x = xs Then
												Begin
													x := 0;
													Inc ( y );
												End;
												Dec ( iCW );
											End;
										End
										Else
										Begin
											//
											// --- Direct
											//
											// get count
											iCW := Word ( n And $3F ) Shl 8 + Word ( b );
											//
											If ( n >= $C0 ) Then
											Begin
												b := Byte ( GetByte ( f ) );
												//
												While iCW > 0 Do
												Begin
													sl := c.ScanLine [ y ];
													Col := Pal [ b ];
													sl [ x ].rgbtRed := GetRValue ( Col );
													sl [ x ].rgbtGreen := GetGValue ( Col );
													sl [ x ].rgbtBlue := GetBValue ( Col );
													Inc ( x );
													If x = xs Then
													Begin
														x := 0;
														Inc ( y );
													End;
													Dec ( iCW );
												End;
											End
											Else
											Begin
												//
												iCW := Word ( n And $3F ) Shl 8 + Word ( b );
												//
												While iCW > 0 Do
												Begin
													b := Byte ( GetByte ( f ) );
													//
													sl := c.ScanLine [ y ];
													Col := Pal [ b ];
													sl [ x ].rgbtRed := GetRValue ( Col );
													sl [ x ].rgbtGreen := GetGValue ( Col );
													sl [ x ].rgbtBlue := GetBValue ( Col );
													//
													Inc ( x );
													If x = xs Then
													Begin
														x := 0;
														Inc ( y );
													End;
													Dec ( iCW );
												End;
											End;
										End;
										//
									End;
								End
								Else
								Begin
									//
									// --- Skip
									//
									b := b And $7F;
									//
									n := b;
									While n > 0 Do
									Begin
										Inc ( x );
										If x = xs Then
										Begin
											x := 0;
											Inc ( y );
										End;
										Dec ( n );
									End;
								End;
							End;
						End;
					End;
					//
				End
				Else
				Begin
					//
					// --- cm = 2, uncompressed bitmap
					//
					For y := 0 To ys - 1 Do
					Begin
						For x := 0 To xs - 1 Do
						Begin
							b := Byte ( GetByte ( f ) );
							If b <> 0 Then
							Begin
								sl := c.ScanLine [ y ];
								Col := Pal [ b ];
								sl [ x ].rgbtRed := GetRValue ( Col );
								sl [ x ].rgbtGreen := GetGValue ( Col );
								sl [ x ].rgbtBlue := GetBValue ( Col );
							End;
						End;
					End;
				End;
				//
				ImageLoadTo := True;
			End
			Else
				ImageLoadTo := False;
			//
			fClose;
			//
			{$ELSE}
			ImageLoadTo := False;
			{$ENDIF}
		End;

		// ***************
		// ROTH (DBASE2)

		fmtROTH :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + Image_Header );
			//
			x := 0;
			y := 0;
			i := Image_Header;
			//
			While i < iLen Do
			Begin
				b := Byte ( GetByte ( f ) );
				//
				// --- Compression
				//
				If ( b > $F0 ) Then
				Begin
					//
					// --- Yes
					//
					n := b And $0F; // count is lower 4 bits
					b := Byte ( GetByte ( f ) ); // get color
					//
					While n > 0 Do
					Begin
						If b <> 0 Then
						Begin
							sl := c.ScanLine [ y ];
							Col := Pal [ b ];
							sl [ x ].rgbtRed := GetRValue ( Col );
							sl [ x ].rgbtGreen := GetGValue ( Col );
							sl [ x ].rgbtBlue := GetBValue ( Col );
						End;
						Inc ( y );
						If y = ys Then
						Begin
							y := 0;
							Inc ( x );
						End;
						//
						Dec ( n );
					End;
					//
				End
				Else
				Begin
					If b <> 0 Then
					Begin
						sl := c.ScanLine [ y ];
						Col := Pal [ b ];
						sl [ x ].rgbtRed := GetRValue ( Col );
						sl [ x ].rgbtGreen := GetGValue ( Col );
						sl [ x ].rgbtBlue := GetBValue ( Col );
					End;
					Inc ( y );
					If y = ys Then
					Begin
						y := 0;
						Inc ( x );
					End;
					//
				End;
				//
				Inc ( i );
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// **************************
		// ROTH with Palette (DBASE3)

		fmtROTHPal :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + Image_Header );
			//
			For x := 0 To 255 Do
			Begin
				b := GetByte ( f );
				g := GetByte ( f );
				r := GetByte ( f );
				LocalPal [ x ]:=
					( Cardinal ( r ) Shl 16 ) +
					( Cardinal ( g ) Shl 8 ) +
					( Cardinal ( b ) );
			End;
			//
			x := 0;
			y := 0;
			i := Image_Header;
			//
			While i < iLen Do
			Begin
				b := Byte ( GetByte ( f ) );
				//
				// --- Compression
				//
				If ( b > $F0 ) Then
				Begin
					//
					// --- Yes
					//
					n := b And $0F; // count is lower 4 bits
					b := Byte ( GetByte ( f ) ); // get color
					//
					While n > 0 Do
					Begin
						sl := c.ScanLine [ y ];
						Col := LocalPal [ b ];
						sl [ x ].rgbtRed := GetRValue ( Col );
						sl [ x ].rgbtGreen := GetGValue ( Col );
						sl [ x ].rgbtBlue := GetBValue ( Col );
						//
						Inc ( x );
						If x = xs Then
						Begin
							x := 0;
							Inc ( y );
						End;
						//
						Dec ( n );
					End;
					//
				End
				Else
				Begin
					sl := c.ScanLine [ y ];
					Col := LocalPal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
					Inc ( x );
					If x = xs Then
					Begin
						x := 0;
						Inc ( y );
					End;
					//
				End;
				//
				Inc ( i );
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// *****************************
		// Load ROTH DAS multiple images

		fmtROTHMul :
		Begin
			{$IFDEF FULLVERSION}
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			// --- Find out number of images
			//
			Seek ( f, iPos + 8 );
			nImgs := -1;
			//
			x := 1;
			While x <> 0 Do
			Begin
				x := GetWord ( f );
				Inc ( nImgs );
			End;
			//
			If ( Image_SubIndex > nImgs )
			Or ( Image_SubIndex < 1 ) Then
			Begin
				Image_SubIndex := 1;
			End;
			//
			If nImgs > 1 Then
			Begin
				//
				isg.DefaultRowHeight := 18;
				//
				isg.RowCount := nImgs + 1;
				isg.ColCount := 2;
				isg.ColWidths [ 0 ] := -1; // hide first column, not needed
				//
				isg.Cells [ 1, 0 ] := 'Image';
				//
				For y := 1 To nImgs Do
				Begin
					isg.Cells [ 1, y ] := Zero ( y, 3 );
				End;
			End;
			//
			Seek ( f, iPos + 8 + ( Image_SubIndex - 1 ) * 2  );
			Image_Header := Word ( GetWord ( f ) );
			//
			If Image_Header >= $8000 Then
			Begin
				// mirrored image
				Image_Header := Image_Header And $7FFF;
				n := 1; // flag mirroring
			End
			Else
				n := 0; // normal
			//
			Image_Header := Image_Header * $10;
			//
			If Image_Header < iLen Then
			Begin
				Seek ( f, iPos + Image_Header + 2 );
				//
				ys := GetWord ( f );
				xs := GetWord ( f );
				//
				ImageResetCurrent ( xs, ys );
				//
				For x := 0 To xs - 1 Do
				Begin
					For y := 0 To ys - 1 Do
					Begin
						b := Byte ( GetByte ( f ) );
						If b <> 0 Then
						Begin
							If n = 1 Then
							Begin
								sl := c.ScanLine [ y ];
								Col := Pal [ b ];
								sl [ xs - 1 - x ].rgbtRed := GetRValue ( Col );
								sl [ xs - 1 - x ].rgbtGreen := GetGValue ( Col );
								sl [ xs - 1 - x ].rgbtBlue := GetBValue ( Col );
							End
							Else
							begin
								sl := c.ScanLine [ y ];
								Col := Pal [ b ];
								sl [ x ].rgbtRed := GetRValue ( Col );
								sl [ x ].rgbtGreen := GetGValue ( Col );
								sl [ x ].rgbtBlue := GetBValue ( Col );
							End;
						End;
					End;
				End;
				//
				ImageLoadTo := True;
			End
			Else
				ImageLoadTo := False;
			//
			fClose;
			//
			{$ELSE}
			ImageLoadTo := False;
			{$ENDIF}
		End;

		// **********************
		// Load ROTH plain images

		fmtROTHPlain :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + Image_Header );
			//
			For x := 0 To xs - 1 Do
			Begin
				For y := 0 To ys - 1 Do
				Begin
					b := Byte ( GetByte ( f ) );
					if b <> 0 Then
					Begin
						sl := c.ScanLine [ y ];
						Col := Pal [ b ];
						sl [ x ].rgbtRed := GetRValue ( Col );
						sl [ x ].rgbtGreen := GetGValue ( Col );
						sl [ x ].rgbtBlue := GetBValue ( Col );
					End;
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// *****************************
		// Duke2 MNI Image with palette

		fmtDuke2Pal :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + Image_Header + ( xs * ys ) Div 2 );
			//
			For x := 0 To 15 Do
			Begin
				b := Byte ( GetByte ( f ) );
				g := Byte ( GetByte ( f ) );
				r := Byte ( GetByte ( f ) );
				//
				If ( b = 64 ) Then b := 63;
				If ( g = 64 ) Then g := 63;
				If ( r = 64 ) Then r := 63;
				//
				b := Byte ( b Shl 2 );
				g := Byte ( g Shl 2 );
				r := Byte ( r Shl 2 );
				//
				LocalPal [ x ]:=
					( Cardinal ( r ) Shl 16 ) +
					( Cardinal ( g ) Shl 8 ) +
					( Cardinal ( b ) );
			End;
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To ( xs Div 8 ) - 1 Do
				Begin
					Seek ( f, iPos + Image_Header + y * ( xs Div 8 ) + x );
					n1 := Byte ( GetByte ( f ) );
					Seek ( f, iPos + Image_Header + y * ( xs Div 8 ) + x + ( xs Div 8 ) * ys * 1 );
					n2 := Byte ( GetByte ( f ) );
					Seek ( f, iPos + Image_Header + y * ( xs Div 8 ) + x + ( xs Div 8 ) * ys * 2 );
					n3 := Byte ( GetByte ( f ) );
					Seek ( f, iPos + Image_Header + y * ( xs Div 8 ) + x + ( xs Div 8 ) * ys * 3 );
					n4 := Byte ( GetByte ( f ) );
					//
					For xc := 0 To 7 Do
					Begin
						b := ( ( n1 Shr ( 7 - xc ) ) And 1 ) +
							( ( n2 Shr ( 7 - xc ) ) And 1 ) Shl 1 +
							( ( n3 Shr ( 7 - xc ) ) And 1 ) Shl 2 +
							( ( n4 Shr ( 7 - xc ) ) And 1 ) Shl 3;
						Col := LocalPal [ b ];
						sl [ x * 8 + xc ].rgbtRed := GetRValue ( Col );
						sl [ x * 8 + xc ].rgbtGreen := GetGValue ( Col );
						sl [ x * 8 + xc ].rgbtBlue := GetBValue ( Col );
					End;
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// ********************
		// Duke2 MNI Image ???

		fmtDuke2 :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			Seek ( f, iPos + Image_Header );
			//
			For y := 0 To ( ys Div 8 ) - 1 Do
			Begin
				For x := 0 To ( xs Div 8 ) - 1 Do
				Begin
        	For yc := 0 To 7 Do
					Begin
						sl := c.ScanLine [ y * 8 + yc ];
						Seek ( f, iPos + Image_Header + (y * 8 + yc) * ( xs Div 8 ) + x );
						n1 := Byte ( GetByte ( f ) );
						Seek ( f, iPos + Image_Header + (y * 8 + yc) * ( xs Div 8 ) + x + ( xs Div 8 ) * ys * 1 );
						n2 := Byte ( GetByte ( f ) );
						Seek ( f, iPos + Image_Header + (y * 8 + yc) * ( xs Div 8 ) + x + ( xs Div 8 ) * ys * 2 );
						n3 := Byte ( GetByte ( f ) );
						Seek ( f, iPos + Image_Header + (y * 8 + yc) * ( xs Div 8 ) + x + ( xs Div 8 ) * ys * 3 );
						n4 := Byte ( GetByte ( f ) );
						//
						For xc := 0 To 7 Do
						Begin
							b := ( ( n1 Shr ( 7 - xc ) ) And 1 ) +
								( ( n2 Shr ( 7 - xc ) ) And 1 ) Shl 1 +
								( ( n3 Shr ( 7 - xc ) ) And 1 ) Shl 2 +
								( ( n4 Shr ( 7 - xc ) ) And 1 ) Shl 3;
							Col := Pal [ b ];
							sl [ x * 8 + xc ].rgbtRed := GetRValue ( Col );
							sl [ x * 8 + xc ].rgbtGreen := GetGValue ( Col );
							sl [ x * 8 + xc ].rgbtBlue := GetBValue ( Col );
						End;
					End;
				End;
			End;
			(*
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To ( xs Div 2 ) - 1 Do
				Begin
					b := Byte ( GetByte ( f ) );
					Col := Pal [ b And 15 ];
					sl [ x * 2 ].rgbtRed := GetRValue ( Col );
					sl [ x * 2 ].rgbtGreen := GetGValue ( Col );
					sl [ x * 2 ].rgbtBlue := GetBValue ( Col );
					Col := Pal [ b Shr 4 ];
					sl [ x * 2 + 1 ].rgbtRed := GetRValue ( Col );
					sl [ x * 2 + 1 ].rgbtGreen := GetGValue ( Col );
					sl [ x * 2 + 1 ].rgbtBlue := GetBValue ( Col );
				End;
			End;
			*)
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// ***************************
		// Generic Image With Palette
		// DTI file (MDK)

		fmtGenericPal :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + Image_Header );
			//
			For x := 0 To 255 Do
			Begin
				b := Byte ( GetByte ( f ) );
				g := Byte ( GetByte ( f ) );
				r := Byte ( GetByte ( f ) );
				//
				LocalPal [ x ]:=
					( Cardinal ( r ) Shl 16 ) +
					( Cardinal ( g ) Shl 8 ) +
					( Cardinal ( b ) );
			End;
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					b := Byte ( GetByte ( f ) );
					Col := LocalPal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// ******************************************
		// Load Chasm: The rift multiple floor images

		fmtCSFloors :
		Begin
			{$IFDEF FULLVERSION}
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			// 4 mipmaps (64x, 32x, 16x, 8x)
			nImgs := iLen Div 5504; // get number of images
			//
			If ( Image_SubIndex > nImgs )
			Or ( Image_SubIndex < 1 ) Then
			Begin
				Image_SubIndex := 1;
			End;
			//
			If nImgs > 1 Then
			Begin
				//
				isg.DefaultRowHeight := 18;
				//
				isg.RowCount := nImgs + 1;
				isg.ColCount := 2;
				isg.ColWidths [ 0 ] := -1; // hide first column, not needed
				//
				isg.Cells [ 1, 0 ] := 'Image';
				//
				For y := 1 To nImgs Do
				Begin
					isg.Cells [ 1, y ] := Zero ( y, 3 );
				End;
			End;
			//
			Seek ( f, iPos + 64 + Image_SubIndex * 5504 );
			//
			xs := 64;
			ys := 64;
			ImageResetCurrent ( xs, ys );
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					b := Byte ( GetByte ( f ) );
					Col := Pal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
				End;
			End;
			//
			ImageLoadTo := True;
			//
			fClose;
			//
			{$ELSE}
			ImageLoadTo := False;
			{$ENDIF}
		End;

		// **********************************
		// Chasm: The rift image with palette

		fmtCSPal :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + Image_Header );
			//
			For x := 0 To 255 Do
			Begin
				b := Byte ( GetByte ( f ) ) * 4;
				g := Byte ( GetByte ( f ) ) * 4;
				r := Byte ( GetByte ( f ) ) * 4;
				//
				LocalPal [ x ]:=
					( Cardinal ( r ) Shl 16 ) +
					( Cardinal ( g ) Shl 8 ) +
					( Cardinal ( b ) );
			End;
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					b := Byte ( GetByte ( f ) );
					Col := LocalPal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// ***************************
		// DTX entry (REZ files)

		fmtREZPal :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			Seek ( f, iPos + Image_Header );
			//
			For x := 0 To 255 Do
			Begin
				GetByte ( f );
				b := GetByte ( f );
				g := GetByte ( f );
				r := GetByte ( f );
				//
				LocalPal [ x ]:=
					( Cardinal ( r ) Shl 16 ) +
					( Cardinal ( g ) Shl 8 ) +
					( Cardinal ( b ) );
			End;
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					b := Byte ( GetByte ( f ) );
					Col := LocalPal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// ***********************************
		// Load Ultima Underworld 1 Compressed

		fmtUU1 :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			For y := 0 To ys - 1 Do
			Begin
				sl := c.ScanLine [ y ];
				For x := 0 To xs - 1 Do
				Begin
					sl [ x ].rgbtRed := 160;
					sl [ x ].rgbtGreen := 170;
					sl [ x ].rgbtBlue := 180;
				End;
			End;
			//
			Seek ( f, iPos + 5 );
			//
			{$IFDEF USEDEBUG}StartDebug;{$ENDIF}
			//
			x := 0;
			y := 0;
			While ( y < ys ) Do
			Begin
				b := Byte ( GetByte ( f ) );
				//
				If ( b And $0F ) = 0 Then
				Begin
					{$IFDEF USEDEBUG}
					DebugLn ( IntToHex ( b, 2 ) + '  ' );
					{$ENDIF}
					//
					n := Byte ( GetByte ( f ) );
					{$IFDEF USEDEBUG}
					Debug ( IntToHex ( n, 2 ) + '# ' );
					{$ENDIF}
					//
					x := n;
					Inc ( y );
					{
					x := x + ( n And $7F ) + 3;
					While x > xs Do
					Begin
						Dec ( x, xs );
						Inc ( y );
					End;
					}
				End
				Else
				Begin
					//
					{$IFDEF USEDEBUG}
					Debug ( IntToHex ( b, 2 ) + '  ' );
					{$ENDIF}
					//
					sl := c.ScanLine [ y ];
					Col := Pal [ b ];
					sl [ x ].rgbtRed := GetRValue ( Col );
					sl [ x ].rgbtGreen := GetGValue ( Col );
					sl [ x ].rgbtBlue := GetBValue ( Col );
					//
				End;
				Inc ( x );
				If x = xs Then
				Begin
					Inc ( y );
					x := 0;
				End;
			End;
			//
			fClose;
			//
			{$IFDEF USEDEBUG}
			EndDebug;
			{$ENDIF}
			//
			ImageLoadTo := True;
		End;

		fmtJPG :
		Begin
			TempPic := TPicture.Create;
			TempPic.LoadFromFile ( ExtractFile ( '.JPG' ) );
			//
			xs := TempPic.Width;
			ys := TempPic.Height;
			ImageResetCurrent ( xs, ys );
			//
			//Image1.Picture.Bitmap.Assign ( Image1.Picture.Graphic );
			//cImage.Canvas.CopyRect ( Image1.Picture.Bitmap.Canvas.ClipRect,
			//	Image1.Picture.Bitmap.Canvas, Image1.Picture.Bitmap.Canvas.ClipRect );
			//
			TempBitmap := TBitmap.Create;
			TempBitmap.Width := xs;
			TempBitmap.Height := ys;
			TempBitmap.Assign ( TempPic.Graphic );
			//
			c.Canvas.CopyRect ( TempBitmap.Canvas.ClipRect,
				TempBitmap.Canvas, TempBitmap.Canvas.ClipRect );
			//
			//c.Assign ( TempPic.Graphic );
			//
			// --- ???
			//
			TempPic.Bitmap.FreeImage;
			TempBitmap.Free;
			//
			ImageLoadTo := True;
		End;

		// **************************************
		// Load Images from BLO files (Greed)

		fmtGreed :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			xs := xs;
			ImageResetCurrent ( xs, ys );
			//
			For x := 0 To xs - 1 Do
			Begin
				Seek ( f, iPos + 4 + x * 2 );
				//
				y := Word ( GetWord ( f ) ); // Pointer to column's data
				if x = xs - 1 Then
					j := iLen
				Else
					j := Word ( GetWord ( f ) ); // next column
				j := j - y;
				//
				Seek ( f, iPos + y );
				//
				// --- first three bytes are something...
				//
				b := Byte ( GetByte ( f ) );
				y := ys - b;
				{
				If b <> ys Then
					ShowMessage ( 'b is ' + IntToHex ( b, 2 ) + ', y is ' + IntToHex ( ys, 2 ) );
				}
				Dec ( j );
				b := Byte ( GetByte ( f ) );
				Dec ( j );
				b := Byte ( GetByte ( f ) );
				{
				If b <> $FF Then
					ShowMessage ( 'b is ' + IntToHex ( b, 2 ) );
				}
				Dec ( j );
				//
				//y := 0;
				While j > 0 Do
				Begin
					b := Byte ( GetByte ( f ) );
					Dec ( j );
					If b <> 0 Then
					Begin
						sl := c.ScanLine [ y ];
						Col := Pal [ b ];
						sl [ x ].rgbtRed := GetRValue ( Col );
						sl [ x ].rgbtGreen := GetGValue ( Col );
						sl [ x ].rgbtBlue := GetBValue ( Col );
					End;
					Inc ( y );
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// **************************************
		// Load Images from GLB files (Demonstar)

		fmtGLB :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			For y := 0 To ys - 1 Do
			Begin
				fSeek ( f, iPos + 12 + y * 4 );
				x := GetLong ( f );
				If x > 0 Then
				Begin
					fSeek ( f, iPos + x );
					//
					x := GetLong ( f ); // starting x
					//
					While x >= 0 Do
					Begin
						If GetLong ( f ) <> y Then
						Begin
							x := -1;
						End
						Else
						Begin
							j := GetLong ( f );
							While j > 0 Do
							Begin
								b := Byte ( GetByte ( f ) );
								sl := c.ScanLine [ y ];
								Col := Pal [ b ];
								sl [ x ].rgbtRed := GetRValue ( Col );
								sl [ x ].rgbtGreen := GetGValue ( Col );
								sl [ x ].rgbtBlue := GetBValue ( Col );
								Inc ( x );
								Dec ( j );
							End;
							//
							x := GetLong ( f ); // starting x
							//
						End;
					End;
				End;
			End;
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		// ******************************
		// Load Outlaws LAB multiple NWX

		fmtLABMul :
		Begin
			{$IFDEF FULLVERSION}
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			// --- Find out number of images
			//
			fSeek ( f, iPos + $14 );
			i := GetLong ( f );
			//
			fSeek ( f, iPos + i );
			GetLong ( f ); // CELT
			nImgs := GetLong ( f ); // number of images
			GetLong ( f ); // CELT entry length?
			//
			If ( Image_SubIndex > nImgs )
			Or ( Image_SubIndex < 1 ) Then
			Begin
				Image_SubIndex := 1;
			End;
			//
			If nImgs > 1 Then
			Begin
				//
				isg.DefaultRowHeight := 18;
				//
				isg.RowCount := nImgs + 1;
				isg.ColCount := 2;
				isg.ColWidths [ 0 ] := -1; // hide first column, not needed
				//
				isg.Cells [ 1, 0 ] := 'Image';
				//
				For y := 1 To nImgs Do
				Begin
					isg.Cells [ 1, y ] := Zero ( y, 3 );
				End;
			End;
			//
			// --- back to beginning
			//
			fSeek ( f, iPos + $14 );
			i := GetLong ( f );
			fSeek ( f, iPos + i + 12 );
			//
			For i := 1 To Image_SubIndex - 1 Do
			Begin
				GetLong ( f ); // index of image??
				x := GetLong ( f ); // length of image
				xs := GetLong ( f ); // width
				ys := GetLong ( f ); // height
				GetLong ( f ); // flags
				fSeek ( f, FilePos ( f ) + x ); // skip data
			End;
			//
			GetLong ( f ); // index??
			GetLong ( f ); // length
			xs := GetLong ( f );
			ys := GetLong ( f );
			//
			ImageResetCurrent ( xs, ys );
			//
			x := GetLong ( f ); // flags
			fp := FilePos ( f );
			//
			If ( x And 1 ) = 0 Then
			Begin
				//
				// --- horizontal reading
				//
				For y := 0 To ys - 1 Do
				Begin
					fSeek ( f, fp + y * 4 );
					i := GetLong ( f );
					fSeek ( f, fp + i );
					//
					x := 0;
					While x < xs Do
					Begin
						//ShowMessage ( Comma ( FilePos ( f ) ) );
						b := Byte ( GetByte ( f ) );
						If ( b And 1 ) = 1 Then
						Begin
							j := ( Word ( b ) + 1 ) Shr 1;
							b := Byte ( GetByte ( f ) );
							While j > 0 Do
							Begin
								sl := c.ScanLine [ y ];
								Col := Pal [ b ];
								sl [ x ].rgbtRed := GetRValue ( Col );
								sl [ x ].rgbtGreen := GetGValue ( Col );
								sl [ x ].rgbtBlue := GetBValue ( Col );
								Inc ( x );
								Dec ( j );
							End;
						End
						Else
						Begin
							j := ( Word ( b ) + 2 ) Shr 1;
							While j > 0 Do
							Begin
								b := Byte ( GetByte ( f ) );
								sl := c.ScanLine [ y ];
								Col := Pal [ b ];
								sl [ x ].rgbtRed := GetRValue ( Col );
								sl [ x ].rgbtGreen := GetGValue ( Col );
								sl [ x ].rgbtBlue := GetBValue ( Col );
								Inc ( x );
								Dec ( j );
							End;
						End;
					End;
				End;
			End
			Else
			Begin
				//
				// --- vertical reading
				//
				For x := 0 To xs - 1 Do
				Begin
					fSeek ( f, fp + x * 4 );
					i := GetLong ( f );
					fSeek ( f, fp + i );
					//
					y := ys - 1;
					While y >= 0 Do
					Begin
						//ShowMessage ( Comma ( FilePos ( f ) ) );
						b := Byte ( GetByte ( f ) );
						If ( b And 1 ) = 1 Then
						Begin
							j := ( Word ( b ) + 1 ) Shr 1;
							b := Byte ( GetByte ( f ) );
							While j > 0 Do
							Begin
								sl := c.ScanLine [ y ];
								Col := Pal [ b ];
								sl [ x ].rgbtRed := GetRValue ( Col );
								sl [ x ].rgbtGreen := GetGValue ( Col );
								sl [ x ].rgbtBlue := GetBValue ( Col );
								Dec ( y );
								Dec ( j );
							End;
						End
						Else
						Begin
							j := ( Word ( b ) + 2 ) Shr 1;
							While j > 0 Do
							Begin
								b := Byte ( GetByte ( f ) );
								sl := c.ScanLine [ y ];
								Col := Pal [ b ];
								sl [ x ].rgbtRed := GetRValue ( Col );
								sl [ x ].rgbtGreen := GetGValue ( Col );
								sl [ x ].rgbtBlue := GetBValue ( Col );
								Dec ( y );
								Dec ( j );
							End;
						End;
					End;
				End;
			End;
			//
			ImageLoadTo := True;
			//
			fClose;
			//
			{$ELSE}
			ImageLoadTo := False;
			{$ENDIF}
		End;

		// ***************************
		// Unreal Image Format

		fmtUnreal :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			Seek ( f, iPos );
			//
			iPaletteIndex := -1;
			xs := -1;
			ys := -1;
			//
			n := 0;
			While n = 0 Do
			Begin
				bName := Byte ( GetByte ( f ) );
				//
				If ( sUnrealNameTable [ bName ] = 'None' ) Then
				Begin
					n := 1; // get out of loop
				End;
				//
				bInfo := Byte ( GetByte ( f ) );
				//
				iValue := 0;
				//
				Case ( bInfo And 15 ) Of
					//
					$A : // struct
					Begin
						bName := Byte ( GetByte ( f ) );
					End;
					//
				End;
				//
				// Array index bit set, and not boolean property?
				If ( ( bInfo And $80 ) = $80 ) And ( ( bInfo And $F ) <> 3 ) Then
				Begin
					GetByte ( f ); // array index
				End;
				//
				Case ( bInfo Shr 4 ) And 7 Of

					0 : iValue := Byte ( GetByte ( f ) );
					1 : iValue := Word ( GetWord ( f ) );
					2 : iValue := GetLong ( f );
					3 :
					Begin
						GetLong ( f );
						GetLong ( f );
						GetLong ( f );
					End;
					4 :
					Begin
						GetLong ( f );
						GetLong ( f );
						GetLong ( f );
						GetLong ( f );
					End;
					5 :
					Begin
						bInfo := Byte ( GetByte ( f ) );
						While bInfo > 0 Do
						Begin
							GetByte ( f );
							Dec ( bInfo );
						End;
					End;
					6 :
					Begin
						i := Word ( GetWord ( f ) );
						While i > 0 Do
						Begin
							GetByte ( f );
							Dec ( i );
						End;
					End;
					7 :
					Begin
						i := Cardinal ( GetLong ( f ) );
						While i > 0 Do
						Begin
							GetByte ( f );
							Dec ( i );
						End;
					End;
				End;
				//
				If ( sUnrealNameTable [ bName ] = 'Palette' ) Then
					iPaletteIndex := ( iValue And 255 );
				If ( sUnrealNameTable [ bName ] = 'USize' ) Then
					xs := iValue;
				If ( sUnrealNameTable [ bName ] = 'VSize' ) Then
					ys := iValue;
				//
				//ShowMessage ( sUnrealNameTable [ bName ] + ' ' + IntToHex ( bInfo, 2 ) + ' = ' + IntToHex ( iValue, 2 ) );
				//
			End;
			//
			if ( xs > 0 ) And ( ys > 0 ) And ( iPaletteIndex >= 0 ) Then
			Begin
				//
				GetLong ( f ); // offset???
				//i := GetLongUnreal ( f ); // size of data
				//
				// --- let's do a security check
				//
				if ( FilePos ( f ) + xs * ys ) > ( FileSize ( f ) ) Then
				Begin
					fClose;
					ImageLoadTo := False;
				End
				Else
				Begin
					//
					{
					If ( i <> xs * ys ) And ( i <> 0 ) Then
					Begin
						ShowMessage ( 'Possible error: Image Data: ' + IntToStr ( i ) + #13 +
							'Size: ' + IntToStr ( xs ) + '*' + IntToStr ( ys ) );
					End;
					}
					//
					If iPaletteIndex >= 0 Then
					Begin
						i := FilePos ( f );
						//
						PaletteLoad ( WadEntries [ iPaletteIndex ].Position,
							WadEntries [ iPaletteIndex ].Size );
						//
						For x := 0 To 255 Do
						Begin
							Pal [ x ] := Palette [ 0, x, 0 ] +
								Palette [ 0, x, 1 ] Shl 8 +
								Palette [ 0, x, 2 ] Shl 16;
						End;
						//
						fSeek ( f, i );
					End;
					//
					Image_xr := 0;
					Image_yr := 0;
					ImageResetCurrent ( xs, ys );
					//
					For y := 0 To ys - 1 Do
					Begin
						For x := 0 To xs - 1 Do
						Begin
							b := Byte ( GetByte ( f ) );
							sl := c.ScanLine [ y ];
							Col := Pal [ b ];
							sl [ x ].rgbtRed := GetRValue ( Col );
							sl [ x ].rgbtGreen := GetGValue ( Col );
							sl [ x ].rgbtBlue := GetBValue ( Col );
						End;
					End;
					//
					fClose;
					//
					ImageLoadTo := True;
				End;
			End
			Else
			Begin
				fClose;
				ImageLoadTo := False;
			End;
		End;

		// ************
		// KTRez images

		fmtKTRez :
		Begin
			If Not fOpen ( sFN ) Then
			Begin
				ImageLoadTo := False;
				Exit;
			End;
			//
			ImageResetCurrent ( xs, ys );
			//
			For x := 0 To xs - 1 Do
			Begin
				// pointer table
				fSeek ( f, iPos + Image_Header + 12 + x * 2 );
				i := GetWord ( f ) + 4; // add 4 to this pointer
				//
				j := 0;
				While j <> $FF Do
				Begin
					fSeek ( f, iPos + Image_Header + i );
					//
					j := Byte ( GetByte ( f ) ); // skip
					//
					If j <> $FF Then
					Begin
						n := Byte ( GetByte ( f ) ); // len
						fSeek ( f, iPos + Image_Header + Word ( GetWord ( f ) ) );
						//
						Inc ( i, 4 );
						//
						For y := 0 To n - 1 Do
						Begin
							If ( ys > y + j ) Then
							Begin
								sl := c.ScanLine [ y + j ];
								Col := Pal [ Byte ( GetByte ( f ) ) ];
								sl [ x ].rgbtRed := GetRValue ( Col );
								sl [ x ].rgbtGreen := GetGValue ( Col );
								sl [ x ].rgbtBlue := GetBValue ( Col );
							End;
						End;
					End;
				End;
			End;
		{
			i := 0;
			//
			x := 0;
			While ( x < xs ) And ( i < iLen ) Do
			Begin
				y := 0;
				While ( y < ys ) And ( i < iLen ) Do
				Begin
					b := Byte ( GetByte ( f ) );
					Inc ( i );
					//
					If y < ys Then
					Begin

					End;
					If b = 255 Then
					Begin
						y := ys;
					End
					Else
					Begin
						Inc ( y );
					End;
				End;
				Inc ( x );
			End;
			}
			//
			fClose;
			//
			ImageLoadTo := True;
		End;

		Else
		Begin
			ImageLoadTo := False;
		End;

	End;
	//
	ImageFormat := Format;
End;

// scan through the given PNG file and look for offsets
Procedure ScanPNGForOffsets ( sFileName : String; Var xOffs, yOffs : Integer );
Var
	fPNG : File;
	bDone : Boolean;
	i, BytesRead, ChunkID, ChunkLen : Integer;
Begin
	{$I-}
	AssignFile ( fPNG, sFileName );
	FileMode := fmOpenRead;
	Reset ( fPNG, 1 );
	{$I+}
	i := IOResult;
	If i = 0 Then
	Begin
		//
		GetLong2 ( fPNG ); // PNG
		GetLong2 ( fPNG ); // second part of header
		//
		BytesRead := 8;
		//
		ChunkID := 1;
		bDone := False;
		//
		// stop at IEND or end of file
		While ( ChunkID <> $49454E44 ) And ( BytesRead <= cLen ) And Not bDone Do
		Begin
			ChunkLen := GetLong2 ( fPNG ); // get length
			ChunkID := GetLong2 ( fPNG ); // get chunk id
			Inc ( BytesRead, 8 );
			//
			// look for existing grab
			//
			If ChunkID = $67724162 Then
			Begin
				xOffs := GetLong2 ( fPNG );
				yOffs := GetLong2 ( fPNG );
				bDone := True;
			End;
			//
			// skip this chunk
			Seek ( fPNG, FilePos ( fPNG ) + ChunkLen );
			Inc ( BytesRead, ChunkLen );
			//
			GetLong ( fPNG ); // skip CRC
			Inc ( BytesRead, 4 );
			//
		End;
		//
		CloseFile ( fPNG );
	End;
End;

// ###########################################################################
//
//

Function ImageLoadEntry ( iEntry : Integer ) : Boolean;
Var
	Format : TImageFormat;
	x, y, xr, yr : Integer;
Begin
	Format := ImageIdentifyEntry ( iEntry, x, y, xr, yr );
	If Format = fmtNone Then
	Begin
		ImageLoadEntry := False;
	End
	Else
	Begin
		ImageLoadEntry := ImageLoad ( sEditFile, WadEntries [ iEntry ].Position,
			WadEntries [ iEntry ].Size, x, y, xr, yr, Format );
	End;
End;

Function ImageIdentifyEntry ( iEntry : Integer; Var x, y, xr, yr : Integer ) : TImageFormat;
Begin
	//
	OpenEntry ( iEntry );
	//
	fOpen ( sEditFile );
	//
	Seek ( f, WadEntries [ iEntry ].Position );
	//
	ImageIdentifyEntry := ImageIdentify ( WadEntries [ iEntry ].Size, x, y, xr, yr );
	//
	fClose;
	//
End;

Function ImageLoadEntryMain ( iEntry : Integer ) : Boolean;
Var
	Format : TImageFormat;
	x, y, xr, yr : Integer;
Begin
	Format := ImageIdentifyFile ( sMainWad,
		MainWadEntries [ iEntry ].Position,
		MainWadEntries [ iEntry ].Size, x, y, xr, yr );
	If Format = fmtNone Then
	Begin
		ImageLoadEntryMain := False;
	End
	Else
	Begin
		ImageLoadEntryMain := ImageLoad ( sMainWad, MainWadEntries [ iEntry ].Position,
			MainWadEntries [ iEntry ].Size, x, y, xr, yr, Format );
	End;
End;

Procedure PatchInit;
Var
	i : Integer;
	fm : File;
Begin
	If nPatches = 0 Then
	Begin
		i := FindEntry ( 'PNAMES' );
		If i > 0 Then
		Begin
			PatchNamesLoad ( i );
		End
		Else
		Begin
			i := FindEntryInMain ( 'PNAMES' );
			If i > 0 Then
			Begin
				AssignFile ( fm, sMainWAD );
				FileMode := fmOpenRead;
				Reset ( fm, 1 );
				//
				Seek ( fm, MainWadEntries [ i ].Position );
				//
				PatchNamesLoadFromFile ( fm, MainWadEntries [ i ].Size );
				//
				CloseFile ( fm );
			End;
		End;
	End;
	//
	PStartMain := FindEntryInMain ( 'P_START' );
End;

procedure PatchNamesLoad ( iEntry : Integer );
Begin
	//
	If Not fOpen ( sFileName ) Then Exit;
	//
	Seek ( F, WadEntries [ iEntry ].Position );
	//
	PatchNamesLoadFromFile ( f, WadEntries [ iEntry ].Size );
	//
	fClose;
End;

Procedure PatchNamesLoadFromFile ( Var f : File; Size : Integer );
Var
	i : Integer;
Begin
	nPatches := GetLong ( f );

	// *** Security check ***
	// is nPatches invalid?
	If nPatches > ( ( Size - 4 ) Div 8 ) Then
	Begin
		// Yes, looks like it.
		nPatches := ( Size - 4 ) Div 8;
	End;

	For i := 0 To nPatches - 1 Do
	Begin
		Patches [ i ].Name := GetString ( f, 8 );
		Patches [ i ].Loaded := False;
		Patches [ i ].xs := 0;
		Patches [ i ].ys := 0;
		Patches [ i ].IsTransparent := False;
	End;
	//
End;

procedure PatchLoad ( i : Integer );
Var
	s : String;
	iImage : Integer;
Begin
	If Patches [ i ].Loaded Then
	Begin
		cImage.Width := Patches [ i ].xs;
		cImage.Height := Patches [ i ].ys;
		//
		cImage.Canvas.CopyRect (
				cImage.Canvas.ClipRect, Patches [ i ].Bitmap.Canvas,
				cImage.Canvas.ClipRect );
		//
		Image_xs := Patches [ i ].xs;
		Image_ys := Patches [ i ].ys;
	End
	Else
	Begin
		s := Patches [ i ].Name; // get name
		//
		iImage := FindEntry ( s ); // find the entry
		//
		If iImage > 0 Then
		Begin
			// found in current wad
			ImageLoadEntry ( iImage ); // load it.
		End
		Else
		Begin
			iImage := FindEntryInMainFrom ( s, PStartMain ); // --- Try to find in Main
			//
			If iImage > 0 Then
			Begin
				// found in main wad
				ImageLoadEntryMain ( iImage ); // load it
			End
			Else
			Begin
				Image_xs := 0;
				Image_ys := 0;
			End;
		End;
		//
		// --- Was it loaded?
		//
		If iImage > 0 Then
		Begin
			Patches [ i ].Loaded := True;
			Patches [ i ].Bitmap := TBitmap.Create;
			Patches [ i ].Bitmap.Width := Image_xs;
			Patches [ i ].Bitmap.Height := Image_ys;
			Patches [ i ].IsTransparent := Image_Transparent;
			//
			Patches [ i ].Bitmap.Canvas.CopyRect (
				Patches [ i ].Bitmap.Canvas.ClipRect, cImage.Canvas,
				Patches [ i ].Bitmap.Canvas.ClipRect );
			//
			Patches [ i ].xs := Image_xs;
			Patches [ i ].ys := Image_ys;
		End
		Else
		Begin
			Image_xs := 0;
			Image_ys := 0;
		End;
	End;
End;

Function TextureIsAnimStart ( s : String ) : Boolean;
Begin
	(*
	{false,     "NUKAGE3",      "NUKAGE1",      8},
		{false,     "FWATER4",      "FWATER1",      8},
		{false,     "SWATER4",      "SWATER1",      8},
		{false,     "LAVA4",        "LAVA1",        8},
		{false,     "BLOOD3",       "BLOOD1",       8},

		{false,     "RROCK08",      "RROCK05",      8},
		{false,     "SLIME04",      "SLIME01",      8},
		{false,     "SLIME08",      "SLIME05",      8},
		{false,     "SLIME12",      "SLIME09",      8},

		// animated textures
		{true,      "BLODGR4",      "BLODGR1",      8},
		{true,      "SLADRIP3",     "SLADRIP1",     8},

		{true,      "BLODRIP4",     "BLODRIP1",     8},
		{true,      "FIREWALL",     "FIREWALA",     8},
		{true,      "GSTFONT3",     "GSTFONT1",     8},
		{true,      "FIRELAVA",     "FIRELAV3",     8},
		{true,      "FIREMAG3",     "FIREMAG1",     8},
		{true,      "FIREBLU2",     "FIREBLU1",     8},
		{true,      "ROCKRED3",     "ROCKRED1",     8},

		{true,      "BFALL4",       "BFALL1",       8},
		{true,      "SFALL4",       "SFALL1",       8},
		{true,      "WFALL4",       "WFALL1",       8},
		{true,      "DBRAIN4",      "DBRAIN1",      8},
	*)
	If ( s = 'BFALL1' )
	Or ( s = 'BLOODRIP1' )
	Or ( s = 'DBRAIN1' )
	Or ( s = 'FIREBLU1' )
	Or ( s = 'FIRELAV2' )
	Or ( s = 'FIREMAG1' )
	Or ( s = 'FIREWALA' )
	Or ( s = 'GSTFONT1' )
	Or ( s = 'ROCKRED1' )
	Or ( s = 'SFALL1' ) Then
	Begin
		TextureIsAnimStart := True;
	End
	Else
	Begin
		TextureIsAnimStart := False;
	End;
End;

Function TextureIsAnimEnd ( s : String ) : Boolean;
Begin
	If ( s = 'BFALL4' )
	Or ( s = 'BLOODRIP4' )
	Or ( s = 'DBRAIN4' )
	Or ( s = 'FIREBLU2' )
	Or ( s = 'FIRELAVA' )
	Or ( s = 'FIREMAG3' )
	Or ( s = 'FIREWALL' )
	Or ( s = 'GSTFONT3' )
	Or ( s = 'ROCKRED3' )
	Or ( s = 'SFALL4' ) Then
	Begin
		TextureIsAnimEnd := True;
	End
	Else
	Begin
		TextureIsAnimEnd := False;
	End;
End;

Function TextureIsSwitch ( s : String ) : String;
Var
	se : String;
Begin
	s := UpperCase ( Trim ( s ) );
	se := RemoveFromLeft ( s, 3 );
	If ( se = 'BLUE' )
	Or ( se = 'BRCOM' )
	Or ( se = 'BRIK' )
	Or ( se = 'BRN1' )
	Or ( se = 'BRN2' )
	Or ( se = 'BRNGN' )
	Or ( se = 'BROWN' )
	Or ( se = 'CMT' )
	Or ( se = 'COMM' )
	Or ( se = 'COMP' )
	Or ( se = 'DIRT' )
	Or ( se = 'EXIT' )
	Or ( se = 'GARG' )
	Or ( se = 'GRAY' )
	Or ( se = 'GRAY1' )
	Or ( se = 'GSTON' )
	Or ( se = 'HOT' )
	Or ( se = 'LION' )
	Or ( se = 'MARB' )
	Or ( se = 'MET2' )
	Or ( se = 'METAL' )
	Or ( se = 'MOD1' )
	Or ( se = 'PANEL' )
	Or ( se = 'PIPE' )
	Or ( se = 'ROCK' )
	Or ( se = 'SATYR' )
	Or ( se = 'SKIN' )
	Or ( se = 'SKULL' )
	Or ( se = 'SLAD' )
	Or ( se = 'STARG' )
	Or ( se = 'STON1' )
	Or ( se = 'STON2' )
	Or ( se = 'STON6' )
	Or ( se = 'STONE' )
	Or ( se = 'STRTN' )
	Or ( se = 'TEK' )
	Or ( se = 'VINE' )
	Or ( se = 'WDMET' )
	Or ( se = 'WOOD' )
	Or ( se = 'ZIM' ) Then
	Begin
		If ( Copy ( s, 1, 3 ) = 'SW1' ) Then
		Begin
			TextureIsSwitch := 'SW2' + se;
		End
		Else
		Begin
			If ( Copy ( s, 1, 3 ) = 'SW2' ) Then
			Begin
				TextureIsSwitch := 'SW1' + se;
			End
			Else
			Begin
				TextureIsSwitch := '';
			End;
		End;
	End
	Else
	Begin
		TextureIsSwitch := '';
	End;
End;

Procedure TextureRebuildFlags;
Var
	iTexture : Integer;
	IsAnim : Boolean;
Begin
	IsAnim := False;
	For iTexture := 1 To nTextures Do
	Begin
		Textures [ iTexture ].SwitchPairName := TextureIsSwitch ( Textures [ iTexture ].Name );
		//
		If TextureIsAnimStart ( UpperCase ( Trim ( Textures [ iTexture ].Name ) ) ) Then
		Begin
			Textures [ iTexture ].Animated := taAnimStart;
			IsAnim := True;
		End
		Else
		Begin
			If TextureIsAnimEnd ( UpperCase ( Trim ( Textures [ iTexture ].Name ) ) ) Then
			Begin
				Textures [ iTexture ].Animated := taAnimEnd;
				IsAnim := False;
			End
			Else
			Begin
				If IsAnim Then
				Begin
					Textures [ iTexture ].Animated := taAnim;
				End
				Else
				Begin
					Textures [ iTexture ].Animated := taNone;
				End;
			End;
		End;
	End;
End;

// --- Flat Stuff

Function MapFlatFind ( s : String ) : Integer;
Var
	iFlat : Integer;
	bFound : Boolean;
Begin
	s := UpperCase ( Trim ( s ) );
	//
	iFlat := 0;
	bFound := False;
	//
	While Not bFound And ( iFlat < nFlats ) Do
	Begin
		If Flats [ iFlat ].Name >= s Then
			bFound := True
		Else
			Inc ( iFlat );
	End;
	//
	MapFlatFind := iFlat;
End;

Procedure MapFlatRefresh ( c : TCanvas; s : String );
var
	bFound : Boolean;
	i, x, y : Integer;
	d : Array [ 0 .. 256 * 256 - 1 ] Of Byte;
	FlatSize : Integer;
	Width : Integer;
Begin
	bFound := False;
	//
	s := UpperCase ( Trim ( s ) );
	i := MapFlatFind ( s );
	//
	If i > 0 Then
	Begin
		//
		FlatSize := 0;
		//
		If Flats [ i ].Local Then
		Begin
			//
			// --- Load From Local
			//
			i := FindEntry ( s );
			//
			If i > 0 Then
			Begin
				fOpen ( sFileName );
				fSeek ( f, WadEntries [ i ].Position );
				FlatSize := WadEntries [ i ].Size;
				If FlatSize > $10000 Then
					FlatSize := $10000;
				BlockRead ( f, d, FlatSize );
				fClose;
				//
				bFound := True;
			End;
		End
		Else
		Begin
			//
			// --- Load From Main
			//
			i := FindEntryInMain ( s );
			//
			If i > 0 Then
			Begin
				AssignFile ( f, sMainWAD );
				FileMode := fmOpenRead;
				Reset ( f, 1 );
				Seek ( f, MainWadEntries [ i ].Position );
				FlatSize := MainWadEntries [ i ].Size;
				If FlatSize > $10000 Then
					FlatSize := $10000;
				BlockRead ( f, d, FlatSize );
				CloseFile ( f );
				//
				bFound := True;
			End;
			//
		End;
		//
		If bFound Then
		Begin
			//
			If FlatSize = 256 * 256 Then
				Width := 256
			Else
				If FlatSize = 128 * 128 Then
					Width := 128
				Else
					Width := 64;
			//
			For y := 0 To 63 Do
			Begin
				For x := 0 To 63 Do
				Begin
					c.Pixels [ x, y ] := Pal [ d [ y * Width + x ] ];
				End;
			End;
		End;
	End;
	//
	If Not bFound Then
	Begin
		//
		// --- Flat not found
		//
		c.Brush.Color := RGB ( 120, 130, 140 );
		c.FillRect ( c.ClipRect );
	End;
End;

end.
