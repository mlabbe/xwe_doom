unit TBrowse;

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

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ExtCtrls, StdCtrls,
	Texture, Globals;

type
	TTBrowseMode = ( tbmTexture, tbmFloor );
	//
	TFormTBrowse = class(TForm)
		lblQuickFind: TLabel;
		EditQuickFind: TEdit;
		sbTexture: TScrollBar;
		img00: TImage;
		img01: TImage;
		img02: TImage;
		img03: TImage;
		img04: TImage;
		img05: TImage;
		img06: TImage;
		img07: TImage;
		img08: TImage;
		img09: TImage;
		img10: TImage;
    img11: TImage;
		img12: TImage;
		img13: TImage;
		img14: TImage;
		img15: TImage;
		img16: TImage;
		img17: TImage;
		img18: TImage;
		img19: TImage;
		img20: TImage;
    img21: TImage;
    img22: TImage;
    img23: TImage;
    img24: TImage;
    img25: TImage;
    img26: TImage;
    img27: TImage;
    img28: TImage;
    img29: TImage;
    img30: TImage;
    img31: TImage;
    img32: TImage;
    img33: TImage;
    img34: TImage;
    img35: TImage;
		img36: TImage;
		img37: TImage;
		img38: TImage;
		img39: TImage;
		img40: TImage;
    img41: TImage;
    img42: TImage;
    img43: TImage;
    img44: TImage;
    img45: TImage;
    img46: TImage;
    img47: TImage;
    img48: TImage;
    img49: TImage;
    img50: TImage;
    img51: TImage;
    img52: TImage;
    img53: TImage;
		img54: TImage;
    img55: TImage;
    img56: TImage;
    img57: TImage;
    img58: TImage;
    img59: TImage;
		img60: TImage;
		img61: TImage;
		img62: TImage;
		img63: TImage;
		img64: TImage;
		img65: TImage;
		img66: TImage;
		img67: TImage;
		img68: TImage;
		img69: TImage;
		img70: TImage;
		img71: TImage;
		img72: TImage;
		img73: TImage;
		img74: TImage;
		img75: TImage;
		img76: TImage;
		img77: TImage;
		img78: TImage;
		img79: TImage;
		img80: TImage;
		img81: TImage;
		img82: TImage;
		img83: TImage;
		img84: TImage;
		img85: TImage;
		img86: TImage;
		img87: TImage;
		img88: TImage;
		img89: TImage;
		img90: TImage;
		img91: TImage;
		img92: TImage;
		img93: TImage;
		img94: TImage;
		img95: TImage;
		img96: TImage;
		img97: TImage;
		img98: TImage;
		img99: TImage;
		procedure FormCreate(Sender: TObject);
		procedure EditQuickFindKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure FormActivate(Sender: TObject);
		procedure imgClick(Sender: TObject);
		procedure sbTextureChange(Sender: TObject);
		procedure EditQuickFindKeyPress(Sender: TObject; var Key: Char);
	private
		{ Private declarations }
		//
		Zoom : Double;
		MaxHeight : Integer;
		//
		Procedure RenderTexture ( t : Integer; c : TCanvas );
		Procedure RendImage ( t, Index : Integer );
		Procedure RenderFloor ( t : Integer; c : TCanvas );
		Procedure RendFloor ( t, Index : Integer );
		Procedure Arrange ( i1, i2 : TImage );
		Procedure UpdateAll;
		Function iArray ( Index : Integer ) : TImage;
		Function x_Name ( i : Integer ) : String;
		//
	public
		{ Public declarations }
		SelectedID : Integer;
		Selected : String;
		//
		Mode : TTBrowseMode;
		//
		Procedure GotoImage ( s : String );
	End;

var
	FormTBrowse: TFormTBrowse;

implementation

{$R *.DFM}

Procedure TFormTBrowse.RendImage ( t, Index : Integer );
Var
	i : TImage;
Begin
	i := iArray ( Index );
	//
	i.Visible := False;
	i.Width := Textures [ t ].xs;
	i.Height := Textures [ t ].ys;
	i.Picture.Bitmap.Width := Textures [ t ].xs;
	i.Picture.Bitmap.Height := Textures [ t ].ys;
	//
	If Index > 0 Then
	Begin
		Arrange ( iArray ( Index ), iArray ( Index - 1 ) );
	End;
	//
	If MaxHeight <> -1 Then
	Begin
		If MaxHeight < i.Height Then
			MaxHeight := i.Height;
		//
		i.Visible := True;
		//
		i.Hint := Textures [ t ].Name + ' (' + IntToStr ( Textures [ t ].xs ) + ' * ' +
			IntToStr ( Textures [ t ].ys ) + ')';
		RenderTexture ( t, i.Canvas );
	End;
End;

Procedure TFormTBrowse.RendFloor ( t, Index : Integer );
Var
	i : TImage;
Begin
	i := iArray ( Index );
	//
	i.Visible := False;
	i.Width := 64;
	i.Height := 64;
	i.Picture.Bitmap.Width := 64;
	i.Picture.Bitmap.Height := 64;
	//
	If Index > 0 Then
	Begin
		Arrange ( iArray ( Index ), iArray ( Index - 1 ) );
	End;
	//
	If MaxHeight <> -1 Then
	Begin
		If MaxHeight < i.Height Then
			MaxHeight := i.Height;
		//
		i.Visible := True;
		//
		i.Hint := Flats [ t ].Name;
		//
		RenderFloor ( t, i.Canvas );
	End;
End;

Procedure TFormTBrowse.RenderTexture ( t : Integer; c : TCanvas );
Var
	i, y : Integer;
	xr, yr : Integer;
Begin
	//
	// draw patches on texture
	//
	If Textures [ t ].Loaded And gCacheTextures Then
	Begin
		c.CopyRect ( c.ClipRect, Textures [ t ].Bitmap.Canvas, c.ClipRect );
	End
	Else
	Begin
		Cursor := crHourGlass;
		//
		With c Do
		Begin
			Brush.Color := RGB ( 0, 255, 255 );
			FillRect ( ClipRect );
			//
			// *** Draw patches ***
			//
			i := Textures [ t ].PatchStart;
			//
			For y := 1 To Textures [ t ].PatchCount Do
			Begin
				//
				// --- Get the patch's image
				//
				PatchLoad ( TexturePatches [ i ].ID );
				//
				xr := TexturePatches [ i ].xPos;
				yr := TexturePatches [ i ].yPos;
				//
				If Image_xs > 0 Then
				Begin
					//
					// Render image
					//
					{
					ImageRenderCurrentAt ( c,
						iTexture_xc + Round ( TexturePatches [ i ].xPos * Zoom ),
						iTexture_yc + Round ( TexturePatches [ i ].yPos * Zoom ), Zoom );
					}
					//
					If ( Textures [ t ].PatchCount <> 1 )
					And ( Patches [ TexturePatches [ i ].ID ].IsTransparent ) Then
					Begin
						c.Brush.Style := bsClear;
						c.BrushCopy (
							Classes.Rect ( xr, yr, xr + Image_xs, yr + Image_ys ),
							cImage, Classes.Rect ( 0, 0, Image_xs, Image_ys ), RGB ( 0, 255, 255 ) );
					End
					Else
					Begin
						c.CopyRect ( Classes.Rect ( xr, yr, xr + Image_xs, yr + Image_ys ),
							cImage.Canvas, Classes.Rect ( 0, 0, Image_xs, Image_ys ) );
					End;
					//
					TexturePatches [ i ].xSize := Image_xs;
					TexturePatches [ i ].ySize := Image_ys;
				End
				Else
				Begin
					//
					// Just write name
					c.TextOut ( xr, yr, IntToStr ( i ) );
					//
					TexturePatches [ i ].xSize := 64;
					TexturePatches [ i ].ySize := 64;
				End;
				//
				Inc ( i );
			End;
			//
			If gCacheTextures Then
			Begin
				Textures [ t ].Loaded := True;
				Textures [ t ].Bitmap := TBitmap.Create;
				Textures [ t ].Bitmap.Width := Textures [ t ].xs;
				Textures [ t ].Bitmap.Height := Textures [ t ].ys;
				//
				Textures [ t ].Bitmap.Canvas.CopyRect (
					Textures [ t ].Bitmap.Canvas.ClipRect, c,
					Textures [ t ].Bitmap.Canvas.ClipRect );
			End;
		End;
		//
		Cursor := crDefault;
	End;
End;

Procedure TFormTBrowse.RenderFloor ( t : Integer; c : TCanvas );
Begin
	//
	// draw patches on texture
	//
	If Flats [ t ].Loaded And gCacheTextures Then
	Begin
		c.CopyRect ( c.ClipRect, Flats [ t ].Bitmap.Canvas, c.ClipRect );
	End
	Else
	Begin
		Cursor := crHourGlass;
		//
		With c Do
		Begin
			Brush.Color := RGB ( 0, 255, 255 );
			FillRect ( ClipRect );
			//
			MapFlatRefresh ( c, Flats [ t ].Name );
			//
			If gCacheTextures Then
			Begin
				Flats [ t ].Loaded := True;
				Flats [ t ].Bitmap := TBitmap.Create;
				Flats [ t ].Bitmap.Width := 64;
				Flats [ t ].Bitmap.Height := 64;
				//
				Flats [ t ].Bitmap.Canvas.CopyRect (
					Flats [ t ].Bitmap.Canvas.ClipRect, c,
					Flats [ t ].Bitmap.Canvas.ClipRect );
			End;
		End;
		//
		Cursor := crDefault;
	End;
End;

procedure TFormTBrowse.FormCreate(Sender: TObject);
Begin
	SelectedID := 1;
	Zoom := 2;
	PatchInit;
End;

procedure TFormTBrowse.Arrange ( i1, i2 : TImage );
Var
	l : Integer;
	t : Integer;
Begin
	l := i2.Left + i2.Width + 4;
	t := i2.Top;
	//
	If l + i1.Width > ClientWidth - 8 - 8 Then
	Begin
		t := i2.Top + MaxHeight + 4;
		l := 8;
		MaxHeight := 0;
		//
	End;
	//
	If t + i1.Height > ClientHeight Then
	Begin
		MaxHeight := -1;
	End;
	//
	i1.Left := l;
	i1.Top := t;
End;

procedure TFormTBrowse.EditQuickFindKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
Begin
	Caption := IntToStr ( Key );
	//
	Case Key Of
		37 :
		Begin
			If SelectedID > 1 Then
			Begin
				Dec ( SelectedID );
				UpdateAll;
			End;
		End;

		39 :
		Begin
			If SelectedID < nTextures Then
			Begin
				Inc ( SelectedID );
				UpdateAll;
			End;
		End;
	End;
End;

Procedure TFormTBrowse.UpdateAll;
var
	i : Integer;
Begin
	If Mode = tbmTexture Then
	Begin
		MaxHeight := 0;
		For i := 0 To 99 Do
		Begin
			RendImage ( SelectedID + i, i );
		End;
	End
	Else
	Begin
		For i := 0 To 99 Do
			RendFloor ( SelectedID + i, i );
	End;
End;

Function TFormTBrowse.iArray ( Index : Integer ) : TImage;
Begin
	Case Index Of
		00 : iArray := img00;
		01 : iArray := img01;
		02 : iArray := img02;
		03 : iArray := img03;
		04 : iArray := img04;
		05 : iArray := img05;
		06 : iArray := img06;
		07 : iArray := img07;
		08 : iArray := img08;
		09 : iArray := img09;
		10 : iArray := img10;
		11 : iArray := img11;
		12 : iArray := img12;
		13 : iArray := img13;
		14 : iArray := img14;
		15 : iArray := img15;
		16 : iArray := img16;
		17 : iArray := img17;
		18 : iArray := img18;
		19 : iArray := img19;
		20 : iArray := img20;
		21 : iArray := img21;
		22 : iArray := img22;
		23 : iArray := img23;
		24 : iArray := img24;
		25 : iArray := img25;
		26 : iArray := img26;
		27 : iArray := img27;
		28 : iArray := img28;
		29 : iArray := img29;
		30 : iArray := img30;
		31 : iArray := img31;
		32 : iArray := img32;
		33 : iArray := img33;
		34 : iArray := img34;
		35 : iArray := img35;
		36 : iArray := img36;
		37 : iArray := img37;
		38 : iArray := img38;
		39 : iArray := img39;
		40 : iArray := img40;
		41 : iArray := img41;
		42 : iArray := img42;
		43 : iArray := img43;
		44 : iArray := img44;
		45 : iArray := img45;
		46 : iArray := img46;
		47 : iArray := img47;
		48 : iArray := img48;
		49 : iArray := img49;
		50 : iArray := img50;
		51 : iArray := img51;
		52 : iArray := img52;
		53 : iArray := img53;
		54 : iArray := img54;
		55 : iArray := img55;
		56 : iArray := img56;
		57 : iArray := img57;
		58 : iArray := img58;
		59 : iArray := img59;
		60 : iArray := img60;
		61 : iArray := img61;
		62 : iArray := img62;
		63 : iArray := img63;
		64 : iArray := img64;
		65 : iArray := img65;
		66 : iArray := img66;
		67 : iArray := img67;
		68 : iArray := img68;
		69 : iArray := img69;
		70 : iArray := img70;
		71 : iArray := img71;
		72 : iArray := img72;
		73 : iArray := img73;
		74 : iArray := img74;
		75 : iArray := img75;
		76 : iArray := img76;
		77 : iArray := img77;
		78 : iArray := img78;
		79 : iArray := img79;
		80 : iArray := img80;
		81 : iArray := img81;
		82 : iArray := img82;
		83 : iArray := img83;
		84 : iArray := img84;
		85 : iArray := img85;
		86 : iArray := img86;
		87 : iArray := img87;
		88 : iArray := img88;
		89 : iArray := img89;
		90 : iArray := img90;
		91 : iArray := img91;
		92 : iArray := img92;
		93 : iArray := img93;
		94 : iArray := img94;
		95 : iArray := img95;
		96 : iArray := img96;
		97 : iArray := img97;
		98 : iArray := img98;
		99 : iArray := img99;
		Else iArray := nil;
	End;
End;

procedure TFormTBrowse.FormActivate(Sender: TObject);
{
Var
	t0, t1 : Cardinal;
	i : Integer;
	}
Begin
	{
	t0 := GetTickCount;
	For i := 1 To nTextures Do
	Begin
		RenderTexture ( i, img00.Canvas );
	End;
	}
	//
	UpdateAll;
	//
	If Mode = tbmTexture Then
	Begin
		sbTexture.Min := 1;
		sbTexture.Max := nTextures;
		sbTexture.LargeChange := 20;
	End
	Else
	Begin
		sbTexture.Min := 1;
		sbTexture.Max := nFlats - 100;
		sbTexture.LargeChange := sbTexture.Max Div 2;
	End;
	//
	{
	t1 := GetTickCount;
	ShowMessage ( IntToStr ( t1 - t0 ) );
	}
End;

procedure TFormTBrowse.imgClick(Sender: TObject);
Begin
	SelectedID := SelectedID + TImage ( Sender ).Tag;
	If Mode = tbmTexture Then
	Begin
		Selected := UpperCase ( Trim ( Textures [ SelectedID ].Name ) );
	End
	Else
	Begin
		Selected := UpperCase ( Trim ( Flats [ SelectedID ].Name ) );
	End;
	Close;
End;

procedure TFormTBrowse.sbTextureChange(Sender: TObject);
Begin
	If Visible Then
	Begin
		SelectedID := sbTexture.Position;
		UpdateAll;
	End;
End;

Procedure TFormTBrowse.GotoImage ( s : String );
Var
	i : Integer;
	bFound : Boolean;
Begin
	i := 1;
	bFound := False;
	//
	s := UpperCase ( Trim ( s ) );
	//
	If Mode = tbmTexture Then
	Begin
		While ( i <= nTextures ) And Not bFound Do
		Begin
			If UpperCase ( Trim ( Textures [ i ].Name ) ) = s Then
			Begin
				bFound := True;
				sbTexture.Position := i;
				SelectedID := i;
			End
			Else
			Begin
				Inc ( i );
			End;
		End;
	End
	Else
	Begin
		While ( i <= nFlats ) And Not bFound Do
		Begin
			If UpperCase ( Trim ( Flats [ i ].Name ) ) = s Then
			Begin
				bFound := True;
				sbTexture.Position := i;
				SelectedID := i;
			End
			Else
			Begin
				Inc ( i );
			End;
		End;
	End;
End;

procedure TFormTBrowse.EditQuickFindKeyPress(Sender: TObject;
	var Key: Char);
var
	s : String;
	Max, cnt : Integer;
	i : Integer;
begin
	If Key = #13 Then
	Begin
		Key := #0;
		//
		If Mode = tbmTexture Then
			Max := nTextures
		Else
			Max := nFlats;
		//
		s := UpperCase ( Trim ( EditQuickFind.Text ) );
		If Copy ( x_Name ( SelectedID ), 1, Length ( s ) ) <> s Then
			i := 0
		Else
			i := SelectedID; 
		//
		cnt := 0;
		Repeat
			Inc ( i );
			If ( i = Max ) Then
				i := 0;
		Until ( cnt = Max ) Or ( Copy ( x_Name ( i ), 1, Length ( s ) ) = s );
		//
		If cnt < Max Then
		Begin
			SelectedID := i;
			UpdateAll;
		End;
	End;
end;

Function TFormTBrowse.x_Name ( i : Integer ) : String;
Begin
	If Mode = tbmTexture Then
		x_Name := UpperCase ( Trim ( Textures [ i ].Name ) )
	Else
		x_Name := UpperCase ( Trim ( Flats [ i ].Name ) );
End;

End.
