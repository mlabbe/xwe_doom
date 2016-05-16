unit RGBValue;

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
	StdCtrls, ComCtrls, Stringz, ExtCtrls, Texture;

type
	TFormMode = ( RGBValueSingle, RGBValueGradient, RGBValueMix );

	TFormRGBValue = class(TForm)

		cmdOK: TButton;
		cmdCancel: TButton;
		PanelStartColor: TPanel;
		tbStartR: TTrackBar;
		LabelStartR: TLabel;
		EditStartR: TEdit;
		LabelStartG: TLabel;
		EditStartG: TEdit;
		tbStartG: TTrackBar;
		LabelStartB: TLabel;
		EditStartB: TEdit;
		tbStartB: TTrackBar;
		LabelStartHex: TLabel;
		EditStartHex: TEdit;
		PanelEndColor: TPanel;
		LabelEndR: TLabel;
		LabelEndG: TLabel;
		LabelEndB: TLabel;
		LabelEndHex: TLabel;
		tbEndR: TTrackBar;
		EditEndR: TEdit;
		EditEndG: TEdit;
		tbEndG: TTrackBar;
		EditEndB: TEdit;
		tbEndB: TTrackBar;
		EditEndHex: TEdit;
		PanelPreview: TPanel;
		ImagePreview: TImage;
		procedure tbChange(Sender: TObject);
		procedure EditStartRKeyPress(Sender: TObject; var Key: Char);
		procedure EditStartGKeyPress(Sender: TObject; var Key: Char);
		procedure EditStartHexKeyUp(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure EditStartHexKeyPress(Sender: TObject; var Key: Char);
		procedure cmdOKClick(Sender: TObject);
		procedure cmdCancelClick(Sender: TObject);
		procedure EditKeyUp(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure EditEndHexKeyUp(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure FormCreate(Sender: TObject);
	private
		{ Private declarations }
		bDontUpdateText : Boolean;
		//
		FormMode : TFormMode;
		GradientSize : Integer;
		//
		Function ValidColor ( EditBox : TEdit ) : Boolean;
		Function GetTrackBar ( EditBox: TEdit ) : TTrackBar;
		Function GetEditBox ( TrackBar: TTrackBar ) : TEdit;
		Procedure UpdateStartHex;
		Procedure UpdateEndHex;
		Procedure UpdatePreview;
	public
		{ Public declarations }
		StartR, StartG, StartB : Integer;
		Procedure SetFormMode ( NewFormMode : TFormMode; NewGradientSize : Integer );
		Procedure SetStartRGB ( r, g, b : Integer );
		Procedure SetEndRGB ( r, g, b : Integer );
	end;

var
	FormRGBValue: TFormRGBValue;

implementation

{$R *.DFM}

Function TFormRGBValue.ValidColor ( EditBox : TEdit ) : Boolean;
Begin
	ValidColor := ( Length ( EditBox.Text ) = 6 ) And IsNumbers ( '$' + EditBox.Text );
End;

Procedure TFormRGBValue.UpdatePreview;
Var
	x, y, Size : Integer;
	Hex : Integer;
	//
	i : Integer;
	r0, g0, b0, r1, g1, b1 : Integer;
	r, g, b : Integer;
	//
	MixValue : Integer;
Begin
	Size := 9;
	x := 0;
	y := 0;
	//
	Case FormMode Of
		RGBValueSingle :
		Begin
			If ValidColor ( EditStartHex ) Then
			Begin
				Hex := SafeVal ( '$' + EditStartHex.Text );
				r0 := ( ( Hex Shr 16 ) And $FF );
				g0 := ( Hex Shr 8 And $FF );
				b0 := Hex And $FF;
				//
				ImagePreview.Canvas.Brush.Color := r0 + g0 Shl 8 + b0 Shl 16;
				ImagePreview.Canvas.FillRect ( Classes.Rect ( x, y, x + Size, y + Size ) );
			End;
		End;
		//
		RGBValueGradient :
		Begin
			If ValidColor ( EditStartHex ) And ValidColor ( EditEndHex ) Then
			Begin
				Hex := SafeVal ( '$' + EditStartHex.Text );
				r0 := ( ( Hex Shr 16 ) And $FF );
				g0 := ( Hex Shr 8 And $FF );
				b0 := Hex And $FF;
				//
				Hex := SafeVal ( '$' + EditEndHex.Text );
				r1 := ( ( Hex Shr 16 ) And $FF );
				g1 := ( Hex Shr 8 And $FF );
				b1 := Hex And $FF;
				//
				For i := 0 To GradientSize - 1 Do
				Begin
					r := r0 + Round ( ( r1 - r0 ) / ( GradientSize - 1 ) * i );
					g := g0 + Round ( ( g1 - g0 ) / ( GradientSize - 1 ) * i );
					b := b0 + Round ( ( b1 - b0 ) / ( GradientSize - 1 ) * i );
					//
					ImagePreview.Canvas.Brush.Color := r + g Shl 8 + b Shl 16;
					ImagePreview.Canvas.FillRect ( Classes.Rect ( x, y, x + Size, y + Size ) );
					Inc ( x, Size );
					If ( x + Size ) > ImagePreview.Width Then
					Begin
						x := 0;
						Inc ( y, Size );
					End;
				End;
			End;
		End;
		//
		RGBValueMix :
		Begin
			If ValidColor ( EditStartHex ) Then
			Begin
				Hex := SafeVal ( '$' + EditStartHex.Text );
				r0 := ( ( Hex Shr 16 ) And $FF );
				g0 := ( Hex Shr 8 And $FF );
				b0 := Hex And $FF;
				//
				MixValue := 75;
				//
				For i := 0 To 255 Do
				Begin
					r1 := Palette [ 0, i, 0 ];
					g1 := Palette [ 0, i, 1 ];
					b1 := Palette [ 0, i, 2 ];
					//
					r := r0 + Round ( ( r1 - r0 ) * MixValue / 100 );
					g := g0 + Round ( ( g1 - g0 ) * MixValue / 100 );
					b := b0 + Round ( ( b1 - b0 ) * MixValue / 100 );
					//
					ImagePreview.Canvas.Brush.Color := r + g Shl 8 + b Shl 16;
					ImagePreview.Canvas.FillRect ( Classes.Rect ( x, y, x + Size, y + Size ) );
					Inc ( x, Size + 1 );
					//If ( ( x + Size + 1 ) > ImagePreview.Width ) Then
					If ( i And 31 ) = 31 Then
					Begin
						x := 0;
						Inc ( y, Size + 1 );
					End;
				End;
			End;
		End;
	End;
End;

Function TFormRGBValue.GetTrackBar ( EditBox: TEdit ) : TTrackBar;
Begin
			 If EditBox = EditStartR Then GetTrackBar := tbStartR
	Else If EditBox = EditStartG Then GetTrackBar := tbStartG
	Else If EditBox = EditStartB Then GetTrackBar := tbStartB
	Else If EditBox = EditEndR   Then GetTrackBar := tbEndR
	Else If EditBox = EditEndG   Then GetTrackBar := tbEndG
	Else If EditBox = EditEndB   Then GetTrackBar := tbEndB
	Else GetTrackBar := nil;
End;

Function TFormRGBValue.GetEditBox ( TrackBar: TTrackBar ) : TEdit;
Begin
			 If TrackBar = tbStartR Then GetEditBox := EditStartR
	Else If TrackBar = tbStartG Then GetEditBox := EditStartG
	Else If TrackBar = tbStartB Then GetEditBox := EditStartB
	Else If TrackBar = tbEndR   Then GetEditBox := EditEndR
	Else If TrackBar = tbEndG   Then GetEditBox := EditEndG
	Else If TrackBar = tbEndB   Then GetEditBox := EditEndB
	Else GetEditBox := nil;
End;

Procedure TFormRGBValue.UpdateStartHex;
Var
	Hex : Integer;
	sHex : String;
Begin
	Hex := SafeVal ( EditStartR.Text ) Shl 16 + SafeVal ( EditStartG.Text ) Shl 8 + SafeVal ( EditStartB.Text );
	sHex := IntToHex ( Hex, 6 );
	If EditStartHex.Text <> sHex Then
	Begin
		EditStartHex.Text := sHex;
	End;
	UpdatePreview;
End;

Procedure TFormRGBValue.UpdateEndHex;
Var
	Hex : Integer;
	sHex : String;
Begin
	Hex := SafeVal ( EditEndR.Text ) Shl 16 + SafeVal ( EditEndG.Text ) Shl 8 + SafeVal ( EditEndB.Text );
	sHex := IntToHex ( Hex, 6 );
	If EditEndHex.Text <> sHex Then
	Begin
		EditEndHex.Text := sHex;
	End;
	UpdatePreview;
End;

procedure TFormRGBValue.tbChange(Sender: TObject);
begin
	If bDontUpdateText Then
		bDontUpdateText := False
	Else
		GetEditBox(TTrackBar(Sender)).Text := IntToStr ( TTrackBar(Sender).Position );
	//
	If ( GetEditBox(TTrackBar(Sender)) = EditStartR )
	Or ( GetEditBox(TTrackBar(Sender)) = EditStartG )
	Or ( GetEditBox(TTrackBar(Sender)) = EditStartB ) Then
		UpdateStartHex
	Else
		UpdateEndHex;
end;

procedure TFormRGBValue.EditStartRKeyPress(Sender: TObject; var Key: Char);
begin
	If Key = ',' Then
	Begin
		Key := #0;
		EditStartG.SetFocus;
	End;
end;

procedure TFormRGBValue.EditStartGKeyPress(Sender: TObject; var Key: Char);
begin
	If Key = ',' Then
	Begin
		Key := #0;
		EditStartB.SetFocus;
	End;
end;

procedure TFormRGBValue.EditStartHexKeyUp(Sender: TObject; var Key: Word;
	Shift: TShiftState);
Var
	Hex : Integer;
begin
	If ValidColor ( TEdit(Sender) ) Then
	Begin
		Hex := SafeVal ( '$' + TEdit(Sender).Text );
		If ( Hex >= 0 ) And ( Hex <= $FFFFFF ) Then
		Begin
			tbStartR.Position := Hex Shr 16 And 255;
			tbStartG.Position := Hex Shr 8 And 255;
			tbStartB.Position := Hex And 255;
		End;
	End;
end;

procedure TFormRGBValue.EditEndHexKeyUp(Sender: TObject; var Key: Word;
	Shift: TShiftState);
Var
	Hex : Integer;
begin
	If ValidColor ( TEdit(Sender) ) Then
	Begin
		Hex := SafeVal ( '$' + TEdit(Sender).Text );
		If ( Hex >= 0 ) And ( Hex <= $FFFFFF ) Then
		Begin
			tbEndR.Position := Hex Shr 16 And 255;
			tbEndG.Position := Hex Shr 8 And 255;
			tbEndB.Position := Hex And 255;
		End;
	End;
end;

procedure TFormRGBValue.EditStartHexKeyPress(Sender: TObject; var Key: Char);
begin
	If ( Key >= 'a' ) And ( Key <= 'f' ) Then
	Begin
		Key := Chr ( Ord ( Key ) - 32 );
	End;
end;

procedure TFormRGBValue.cmdOKClick(Sender: TObject);
begin
	ModalResult := mrOk;
end;

procedure TFormRGBValue.cmdCancelClick(Sender: TObject);
begin
	ModalResult := mrCancel;
end;

procedure TFormRGBValue.EditKeyUp(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	If ( SafeVal ( TEdit(Sender).Text ) >= 0 )
	And ( SafeVal ( TEdit(Sender).Text ) <= 255 ) Then
	Begin
		bDontUpdateText := True;
		GetTrackBar(TEdit(Sender)).Position := SafeVal ( TEdit(Sender).Text );
	End;
end;

procedure TFormRGBValue.FormCreate(Sender: TObject);
begin
	FormMode := RGBValueGradient;
	GradientSize := 32;
end;

Procedure TFormRGBValue.SetFormMode ( NewFormMode : TFormMode; NewGradientSize : Integer );
begin
	FormMode := NewFormMode;
	GradientSize := NewGradientSize;
	//
	Case FormMode Of

		RGBValueSingle, RGBValueMix :
			PanelEndColor.Visible := False;

		RGBValueGradient :
			PanelEndColor.Visible := True;

	End;
	//
	UpdatePreview;
end;

procedure TFormRGBValue.SetStartRGB ( r, g, b : Integer );
Begin
	EditStartR.Text := IntToStr ( r );
	EditStartG.Text := IntToStr ( g );
	EditStartB.Text := IntToStr ( b );
	//
	tbStartR.Position := r;
	tbStartG.Position := g;
	tbStartB.Position := b;
	//
	UpdateStartHex;
End;

procedure TFormRGBValue.SetEndRGB ( r, g, b : Integer );
Begin
	EditEndR.Text := IntToStr ( r );
	EditEndG.Text := IntToStr ( g );
	EditEndB.Text := IntToStr ( b );
	//
	tbEndR.Position := r;
	tbEndG.Position := g;
	tbEndB.Position := b;
	//
	UpdateEndHex;
End;

end.
