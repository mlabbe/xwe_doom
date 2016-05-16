unit WadFile;

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

interface

Uses
	SysUtils, ZipMstr, Globals, Dialogs;

Type
	TFileType = ( ftWadFile, Wad2File, Wad3File, DukeFile, Duke2File, QuakeFile, UnrealFile,
		SingleFile, SingleLumpFile,
		PKFile, RFFFile, WolfFile, WolfAudioFile,
		AdrenixFile, DarkForcesFile, DarkForcesLFDFile, LGRESFile,
		PIGFile, PIG2File, HOGFile, PODFile, TLKFile, FORMFile, REZFile,
		RIDFile, MTIFile, DTIFile, SNIFile, GLBFile, RBXFile, XPRFile,
		EOB1File, EOB3File,
		ROTH2File, ROTH5File, DASFile, LABFile, CSFile, BLOFile, WRSFile,
		KTREZFile, PoziFile, AARESFile, FShockFile,
		TRFile, GRFile, QNFile,
		JFKWadFile,
		ftAll );

Type
	TWadEntry = Record
		Name : String;
		Position, Size : Integer;
		//
		EntryType : Integer;
	End;

Const
	MaxWadEntries = 50000;

Type
	TWadEntryType = Record
		Description : String;
		//
		FileType : TFileType; // File type
		Entry : String; // name match
		Size : Integer; // size match
		Signature : String; // data header match
		SectionStart : String; // section match
		SectionEnd : String;
		//
		Editor : String;
		EditorSubCat : String; // subcategory - for ScriptEditor
		ExportMethod : String;
		Icon : String;
		Header : Integer;
		//
		ColStart : Integer;
		Cols : Integer;
	End;

Var
	//
	iWadDirPos : Integer; // file position of wad entry directory
	sFileName : String; // name of open file
	sEditFile : String; // | file to edit: only PK files have
											// | different name than sFileName
	sMainWAD : String; // path + filename of 'main' wad file
	sLastModifiedDate : String;
	iSel, cPos, cLen : Longint;
	FileType : TFileType;

	//
	nWadEntries, nMainWadEntries : Longint;
	WadEntries, MainWadEntries : Array [ 1 .. MaxWadEntries ] Of TWadEntry;

	//
	nWadEntryTypes : Integer;
	WadEntryTypes : Array [ 1 .. 1024 ] Of TWadEntryType;

	//
	local_zipM : TZipMaster;

	// ##########################################################################

	Function MatchName ( s1, s2 : String ) : Boolean;

	Function FindEntryType ( s : String ) : Integer;
	Function FindEntryByType ( iEntryType : Integer ) : Integer;
	Function FindEntry ( s : String ) : Integer;
	Function FindEntryInMain ( s : String ) : Integer;
	Function FindEntryInMainFrom ( s : String; iStart : Integer ) : Integer;

	Procedure OpenEntry ( iEntry : Integer );

	Function IsFileEditable : Boolean;

implementation

Function MatchName ( s1, s2 : String ) : Boolean;
Var
	b, bAll : Boolean;
	p1, p2 : Integer;
	//
	i : Integer;
	sc, sl : String;
Begin
	If s2 = '' Then
		MatchName := False
	Else
	Begin
		//
		sl := s2;
		bAll := False;
		//
		While sl <> '' Do
		Begin
			//
			i := Pos ( ';', sl ); // check for mupltiple choices
			//
			If i = 0 Then	i := Length ( sl ) + 1; // none found, use whole string
			//
			sc := Copy ( sl, 1, i - 1 );
			sl := Copy ( sl, i + 1, Length ( sl ) - ( i - 1 ) );
			//
			b := True;
			p1 := 1;
			p2 := 1;
			//
			If Pos ( '*', sc ) = 0 Then
			Begin
				// longer?
				If Length ( s1 ) > Length ( sc ) Then
					b := False; // yes, no match
			End;
			//
			While b And ( p2 <= Length ( sc ) ) Do
			Begin
				If ( p1 > Length ( s1 ) ) Then
					b := False
				Else
				Begin
					If sc [ p2 ] <> '?' Then // don't check if it's "?"
					Begin
						If sc [ p2 ] = '*' Then // if it's a "*"...
						Begin
							p1 := Length ( s1 ) - ( Length ( sc ) - p2 ); // check end of string
							If p1 < 1 Then
                b := False;
						End
						Else
						Begin
							If sc [ p2 ] = '#' Then // numbers only
							Begin
								If ( s1 [ p1 ] < '0' ) Or ( s1 [ p1 ] > '9' ) Then
								Begin
									b := False; // not a number
								End;
							End
							Else
							Begin
								If s1 [ p1 ] <> sc [ p2 ] Then // check one character
									b := False;
							End;
						End;
					End;
					Inc ( p1 );
					Inc ( p2 );
				End;
			End;
			//
			bAll := bAll Or b;
		End;
		//
		MatchName := bAll;
	End;
End;

Function FindEntryType ( s : String ) : Integer;
Var
	i : Integer;
	b : Boolean;
Begin
	s := UpperCase ( Trim ( s ) );
	//
	i := 1;
	b := False;
	While Not b And ( i < nWadEntryTypes ) Do
	Begin
		If WadEntryTypes [ i ].Description = s Then
			b := True
		Else
			Inc ( i );
	End;
	//
	If Not b Then i := 0;
	FindEntryType := i;
End;

Function FindEntryByType ( iEntryType : Integer ) : Integer;
Var
	i : Integer;
	b : Boolean;
Begin
	i := 1;
	b := False;
	While Not b And ( i <= nWadEntries ) Do
	Begin
		If WadEntries [ i ].EntryType = iEntryType Then
			b := True
		Else
			Inc ( i );
	End;
	//
	If Not b Then i := 0;
	FindEntryByType := i;
End;

Function FindEntry ( s : String ) : Integer;
Var
	i : Integer;
	b : Boolean;
Begin
	s := UpperCase ( Trim ( s ) );
	//
	i := 1;
	b := False;
	While Not b And ( i <= nWadEntries ) Do
	Begin
		If MatchName ( Trim ( WadEntries [ i ].Name ), s ) Then
			b := True
		Else
			Inc ( i );
	End;
	//
	If Not b Then i := 0;
	FindEntry := i;
End;

Function FindEntryInMainFrom ( s : String; iStart : Integer ) : Integer;
Var
	i : Integer;
	b : Boolean;
Begin
	s := UpperCase ( Trim ( s ) );
	//
	i := iStart;
	b := False;
	While Not b And ( i <= nMainWadEntries ) Do
	Begin
		If MatchName ( MainWadEntries [ i ].Name, s ) Then
			b := True
		Else
			Inc ( i );
	End;
	//
	If Not b Then i := 0;
	FindEntryInMainFrom := i;
End;

Function FindEntryInMain ( s : String ) : Integer;
Begin
	FindEntryInMain := FindEntryInMainFrom ( s, 1 );
End;

Procedure OpenEntry ( iEntry : Integer );
{$IFDEF FULLVERSION}
Var
	s : String;
	sNew : String;
	Dummy : File;
	{$ENDIF}
Begin
	{$IFDEF FULLVERSION}
	//
	// *** PACK FILE SUPPORT ***
	//
	If FileType = PKFile Then
	Begin
		//
		// Extract it from the ZIPped file
		//
		s := WadEntries [ iEntry ].Name;
		//
		local_zipM.FSpecArgs.Add ( s );
		local_zipM.ExtrBaseDir := sTempFolder;
		local_zipM.Extract;
		//
		// rename it to (xwe) in front
		// so it gets deleted at the end
		//
		s := RemoveFolder ( s );
		sNew := '(xwe)' + s;
		//
		If FileExists ( sTempFolder + sNew ) Then
		Begin
			AssignFile ( Dummy, sTempFolder + sNew );
			Erase ( Dummy );
		End;
		//
		If Not FileExists ( sTempFolder + s ) Then
		Begin
			ShowMessage ( 'File does not exist: ' + sTempFolder + s );
		End
		Else
		Begin
			AssignFile ( Dummy, sTempFolder + s );
			Rename ( Dummy, sNew );
		End;
		//
		sEditFile := sTempFolder + sNew;
	End
	Else
	Begin
		sEditFile := sFileName;
	End;

	{$ELSE}

	sEditFile := sFileName; // Always the same WAD file

	{$ENDIF}
End;

Function IsFileEditable : Boolean;
Begin
	IsFileEditable := ( FileType = ftWadFile ) Or ( FileType = SingleLumpFile ); 
End;

end.
