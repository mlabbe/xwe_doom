unit FileIO;

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
	Dialogs, SysUtils, Stringz, Globals;

Const
	DataMax = $C000;

Type
	TData = Array [ 0 .. DataMax - 1 ] Of Byte;
	PData = ^TData;

Var
	fOpenCount : Integer;
	//
	sTempFile : String;
	//
	f : File;
	fo : File;
	//
	LastFileReadOnly : Boolean;

	// Common file operations
	Function fOpen ( sFN : String ) : Boolean;
	Function fOpen_ ( sFN : String; bQuiet : Boolean ) : Boolean;
	procedure fClose;
	Function fSeek ( Var f : File; iPos : Integer ) : Boolean;
	Function GetString ( Var f : File; iLength : Integer ) : String;
	Function GetString8 ( Var f : File ) : String;
	Function GetZString ( Var f : File ) : String;
	Function GetLongUnreal ( Var f : File ) : Integer;
	Function GetLong2 ( Var f : File ) : Integer;
	Function GetLong ( Var f : File ) : Integer;
	Function GetWord2 ( Var f : File ) : SmallInt;
	Function GetWord ( Var f : File ) : SmallInt;
	Function GetByte ( Var f : File ) : ShortInt;

	// Export Procedures
	Function fOpenTemp : Boolean; // for exporting
	procedure SendByte ( Var f : File; b : Byte );
	Procedure SendWord ( Var f : File; w : SmallInt );
	Procedure SendLong ( Var f : File; i : Integer );
	Procedure SendLong2 ( Var f : File; i : Integer );
	Procedure SendString8 ( Var f : File; s : String );

	// CopyData
	procedure CopyData ( Var FromFile, ToFile : File; DataLength : Integer );

implementation

// ********************************************************************
//
// Common file operations
//
// ********************************************************************

Function fOpen ( sFN : String ) : Boolean;
Begin
	fOpen := fOpen_ ( sFN, False );
End;

Function fOpen_ ( sFN : String; bQuiet : Boolean ) : Boolean;
Var
	i : Integer;
Begin
	Inc ( fOpenCount );
	//
	If fOpenCount > 1 Then
	Begin
		fOpen_ := True; // already open
	End
	Else
	Begin
		LastFileReadOnly := False;
		{$I-}
		AssignFile ( f, sFN );
		FileMode := fmOpenReadWrite;
		Reset ( f, 1 );
		{$I+}
		i := IOResult;
		If i = 5 Then
		Begin
			//
			// - retry as read-only
			//
			{$I-}
			AssignFile ( f, sFN );
			FileMode := fmOpenRead;
			Reset ( f, 1 );
			{$I+}
			i := IOResult;
			LastFileReadOnly := True;
		End;
		//
		If i <> 0 Then
		Begin
			If Not bQuiet Then
			Begin
				If i = 2 Then
				Begin
					MessageDlg ( 'File not found: ' + sFN, mtWarning, [mbOK], 0 );
				End
				Else
				Begin
					MessageDlg ( 'File could not be opened. (Error ' + IntToStr ( i ) + ')' + #13 + sFN, mtWarning, [mbOK], 0 );
				End;
			End;
			//
			fOpen_ := False;
			LastFileReadOnly := False;
			Dec ( fOpenCount );
		End
		Else
		Begin
			fOpen_ := True;
		End;
	End;
end;

procedure fClose;
Begin
	If fOpenCount > 0 Then
	Begin
		Dec ( fOpenCount );
		If ( fOpenCount = 0 ) Then
		Begin
			CloseFile ( f );
		End;
	End;
end;

function fSeek ( Var f : File; iPos : Integer ) : Boolean;
Var
	iFS : Integer;
Begin
	iFS := FileSize ( f );
	If ( iFS >= iPos ) And ( iPos >= 0 ) Then
	Begin
		Seek ( f, iPos );
		fSeek := True;
	End
	Else
	Begin
		MessageDlg ( 'Invalid seek.' + #13 +
			'(' + Comma ( iPos ) + ' - file size ' + Comma ( iFS ) + ')',
			mtError, [mbOK], 0 );
		fSeek := False;
	End;
End;

function fOpenTemp : Boolean;
Begin
	sTempFile := sTempFolder + '(xwe)' +
		IntToHex ( Random ( $FF ), 2 ) +
		IntToHex ( Random ( $FF ), 2 ) +
		IntToHex ( Random ( $FF ), 2 ) +
		IntToHex ( Random ( $FF ), 2 ) + '.TMP';
	//
	AssignFile ( fo, sTempFile );
	FileMode := fmOpenReadWrite;
	ReWrite ( fo, 1 );
	//
	fOpenTemp := True;
End;

Function GetString ( Var f : File; iLength : Integer ) : String;
Var
	s : String;
	i : Integer;
Begin
	s := '';
	//
	If iLength > 0 Then
	Begin
		For i := 1 To iLength Do
			s := s + '_';
		//
		BlockRead ( F, s [ 1 ], iLength, i );
		//
		While i < iLength Do
		Begin
			Inc ( i );
			s [ i ] := #32;
		End;
		//
		For i := 1 To iLength Do
		Begin
			If s [ i ] = #0 Then
				s [ i ] := #32;
		End;
	End;
	//
	GetString := s;
end;

Function GetString8 ( Var f : File ) : String;
Var
	s : String;
	i : Integer;
Begin
	s := '________';
	//
	BlockRead ( F, s [ 1 ], 8 );
	//
	i := 1;
	While i <= 8 Do
	Begin
		If s [ i ] = #0 Then
		Begin
			s := Copy ( Copy ( s, 1, i - 1 ) + '        ', 1, 8 );
			i := 8;
		End;
		Inc ( i );
	End;
	//
	GetString8 := s;
end;

Function GetZString ( Var f : File ) : String;
Var
	s : String;
	b : Byte;
Begin
	s := '';
	b := GetByte ( f );
	While b <> 0 Do
	Begin
		s := s + Chr ( b );
		b := GetByte ( f );
	End;
	//
	GetZString := s;
end;

Function GetLong2 ( Var f : File ) : Integer;
Var
	b1, b2, b3, b4 : Byte;
Begin
	BlockRead ( f, b1, 1 );
	BlockRead ( f, b2, 1 );
	BlockRead ( f, b3, 1 );
	BlockRead ( f, b4, 1 );
	//
	GetLong2 := ( b1 Shl 24 ) Or ( b2 Shl 16 ) Or ( b3 Shl 8 ) Or b4;
end;

Function GetLong ( Var f : File ) : Integer;
Var
	i : Integer;
Begin
	BlockRead ( f, i, 4 );
	GetLong := i;
end;

Function GetLongUnreal ( Var f : File ) : Integer;
Var
	b : Byte;
	bCont : Boolean;
	bNeg : Boolean;
	v, Bits : Integer;
Begin
	// get first byte
	b := GetByte ( f );
	//
	bNeg := ( b And $80 ) = $80; // keep negative bit
	bCont := ( b And $40 ) = $40; // get "continue" bit
	//
	v := b And $3F;
	Bits := 6;
	//
	While bCont Do
	Begin
		//
		b := GetByte ( f );
		bCont := ( b And $80 ) = $80; // get "continue" bit
		v := v Or Integer ( ( ( b And $7F ) Shl Bits ) );
		Inc ( Bits, 7 );
		//
	End;
	//
	If bNeg Then v := -v;
	GetLongUnreal := v;
End;

Function GetWord2 ( Var f : File ) : SmallInt;
Var
	b1, b2 : Byte;
Begin
	BlockRead ( f, b1, 1 );
	BlockRead ( f, b2, 1 );
	//
	GetWord2 := ( b1 Shl 8 ) Or b2;
End;

Function GetWord ( Var f : File ) : SmallInt;
Var
	i : SmallInt;
Begin
	BlockRead ( F, i, 2 );
	GetWord := i;
end;

Function GetByte ( Var f : File ) : ShortInt;
Var
	i : ShortInt;
Begin
	BlockRead ( F, i, 1 );
	GetByte := i;
end;

// ****************************
// *** File output functions
// ****************************

Procedure SendByte ( Var f : File; b : Byte );
Begin
	BlockWrite ( f, b, 1 );
End;

Procedure SendWord ( Var f : File; w : SmallInt );
Begin
	BlockWrite ( f, w, 2 );
End;

Procedure SendLong ( Var f : File; i : Integer );
Begin
	BlockWrite ( f, i, 4 );
End;

Procedure SendLong2 ( Var f : File; i : Integer );
Begin
	SendByte ( f, i Shr 24 And 255 );
	SendByte ( f, i Shr 16 And 255 );
	SendByte ( f, i Shr 8 And 255 );
	SendByte ( f, i And 255 );
End;

Procedure SendString8 ( Var f : File; s : String );
Begin
	s := Trim ( s );
	If Not gDontAutoCapitalize Then
	Begin
		s := UpperCase ( s );
	End;
	While Length ( s ) < 8 Do
	Begin
		s := s + #0;
	End;
	BlockWrite ( f, s [ 1 ], 8 );
End;

//********************************************
// Copies some bytes from one file to another
//
procedure CopyData ( Var FromFile, ToFile : File; DataLength : Integer );
Var
	c : Integer;
	d : PData;
Begin
	GetMem ( d, DataMax );
	//
	While DataLength > 0 Do
	Begin
		c := DataLength;
		If c > DataMax Then
			c := DataMax;
		BlockRead ( FromFile, d^, c );
		BlockWrite ( ToFile, d^, c );
		Dec ( DataLength, c );
	End;
	//
	FreeMem ( d, DataMax );
end;

end.
