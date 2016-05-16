unit Globals;

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

Const
	VersionMajor = '1';
	VersionMinor = '16.beta';

Type
	TAssociations = ( assoc_None, assoc_WAD, assoc_Common, assoc_All );

var
	gOpenLast : Boolean;
	gCutCopyEmpty : Boolean;
	sTempFolder : String;
	gOnlyOneBack : Boolean;
	gAutoCleanUp : Boolean;
	gAutoBackup : Boolean;
	gPreviewMaps : Boolean;
	gAutoPlaySounds : Boolean;
	gDisableUndo : Boolean;
	gRawPNG : Boolean;
	gAutoApplyOffsets : Boolean;
	//
	gCacheTextures : Boolean;
	//
	gShowFullPath : Boolean;
	gShowSize : Boolean;
	gShowPosition : Boolean;
	gDontAutoCapitalize : Boolean;
	//
	gAssociations : TAssociations;
	//
	sCredits : String;
	sExePath : String;
	//
	gFileReadOnly : Boolean; // if true, file is read-only

Type
	// ---

	TPal = Record
		Name : String;
		Pal : Array [ 0 .. 255, 0 .. 2 ] Of Byte;
	End;

Type
	TPicData = Array [ 0 .. 1000000 ] Of Byte;

Var
	PicData : ^TPicData;

Var
	//
	// ---
	//
	nPals : Integer;
	iPreferredPal : Integer;
	Pals : Array [ 0 .. 99 ] Of TPal;

	procedure UpdateIniFile ( sSection, sMatch, sTool : String );
	Function RemoveFolder ( s : String ) : String;
	function GetEnvVarValue(const VarName: string): string;

implementation

Uses
	Windows, SysUtils, Stringz;

Function RemoveFolder ( s : String ) : String;
Var
	s0 : String;
Begin
	s0 := Copy ( s, Length ( s ), 1 );
	If ( s0 <> '/' ) And ( s0 <> '\' ) Then
	Begin
		s0 := '';
	End
	Else
	Begin
		s := Copy ( s, 1, Length ( s ) - 1 );
	End;
	//
	If PosR ( '/', s ) > 0 Then
	Begin
		s := RemoveFromLeft ( s, PosR ( '/', s ) );
	End;
	If PosR ( '\', s ) > 0 Then
	Begin
		s := RemoveFromLeft ( s, PosR ( '\', s ) );
	End;
	//
	s := s + s0;
	//
	RemoveFolder := s;
End;

procedure UpdateIniFile ( sSection, sMatch, sTool : String );
Var
	tf, tn : TextFile;
	s, sOrig : String;
	bSection, bDone : Boolean;
Begin
	AssignFile ( tf, sExePath + 'xwe.ini' );
	Reset ( tf );
	//
	AssignFile ( tn, sExePath + 'xwe.~ini' );
	Rewrite ( tn );
	//
	bSection := False;
	bDone := False;
	//
	While Not Eof ( tf ) Do
	Begin
		ReadLn ( tf, sOrig );
		s := Trim ( sOrig );
		//
		if Not bDone Then
		Begin
			if Length ( s ) > 0 Then
			begin
				If ( s [ 1 ] <> ';' ) Then
				Begin
					If ( s [ 1 ] = '<' )
					Or ( s [ 1 ] = '(' )
					Or ( s [ 1 ] = '[' ) Then
					Begin
						//
						// --- Section start.
						//
						If bSection Then
						Begin
							// our section is just now over, but line was not found
							// add it 'manually'
							WriteLn ( tn, sTool );
							bDone := True;
						End
						Else
						Begin
							If UpperCase ( s ) = UpperCase ( sSection ) Then
							Begin
								// this is our section.
								bSection := True;
							End;
						End;
					End
					Else
					Begin
						If bSection Then
						Begin
							If UpperCase ( Copy ( s, 1, Length ( sMatch ) ) ) = UpperCase ( sMatch ) Then
							Begin
								sOrig := ';' + sOrig;
								WriteLn ( tn, sTool );
								bDone := True;
							End;
						End;
					End;
				End;
			End;
		end;
		//
		WriteLn ( tn, sOrig );
	End;
	//
	If Not bDone Then
	Begin
		If Not bSection Then
		Begin
			WriteLn ( tn, sSection );
		End;
		WriteLn ( tn, sTool );
	End;
	//
	CloseFile ( tf );
	CloseFile ( tn );
	//
	AssignFile ( tf, sExePath + 'xwe.ini' );
	Erase ( tf );
	AssignFile ( tf, sExePath + 'xwe.~ini' );
	Rename ( tf, sExePath + 'xwe.ini' );
End;

function GetEnvVarValue(const VarName: string): string;
var
	BufSize: Integer;  // buffer size required for value
begin
	// Get required buffer size (inc. terminal #0)
	BufSize := GetEnvironmentVariable ( PChar ( VarName ), nil, 0 );
	if BufSize > 0 then
	begin
		// Read env var value into result string
		SetLength ( Result, BufSize - 1 );
		GetEnvironmentVariable ( PChar ( VarName ), PChar ( Result ), BufSize );
	end
	else
		// No such environment variable
		Result := '';
end;

end.
