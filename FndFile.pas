unit FndFile;

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
	StdCtrls, Globals, Stringz;

type
	TFormFndFile = class(TForm)
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
    lblMessage: TLabel;
		EditDescription: TEdit;
		EditPath: TEdit;
		EditFileName: TEdit;
		cmdOK: TButton;
		cmdCancel: TButton;
    cmdBrowse: TButton;
		OpenDialog1: TOpenDialog;
		cmdFindIt: TButton;
		procedure cmdCancelClick(Sender: TObject);
		procedure cmdOKClick(Sender: TObject);
		procedure cmdBrowseClick(Sender: TObject);
		procedure cmdFindItClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
	private
		{ Private declarations }
		bFound : Boolean;
		sFound : String;
		gCount : Integer;
	public
		{ Public declarations }
		Desc, Path, Exec : String;
		Procedure FindOneFile ( sPath, sFile : String );
	end;

var
	FormFndFile: TFormFndFile;

implementation

{$R *.DFM}

Const
	MaxCheck = 6;
	Check : Array [ 1 .. MaxCheck ] Of String =
	( 'DOOM', 'NODE', 'GAME', 'TOOL', 'UTIL', 'PROG' );

Procedure TFormFndFile.FindOneFile ( sPath, sFile : String );
Var
	i : Integer;
	bDup : Boolean;
	iResult : Integer;
	sr : TSearchRec;
Begin
	//
	Inc ( gCount );
	//
	If FileExists ( sPath + sFile ) Then
	Begin
		bFound := True;
		sFound := sPath + sFile;
	End
	Else
	Begin
		//
		If ( gCount And 15 ) = 0 Then
		Begin
			Caption := '(' + Comma ( gCount ) + ')';
		End;
		//
		i := 1;
		While Not bFound And ( i <= MaxCheck ) Do
		Begin
			iResult := FindFirst ( sPath + '*' + Check [ i ] + '*.*', faDirectory, sr );
			While Not bFound And ( iResult = 0 ) Do
			Begin
				If ( Copy ( sr.Name, 1, 1 ) <> '.' ) And ( ( sr.Attr And faDirectory ) <> 0 ) Then
					FindOneFile ( sPath + sr.Name + '\', sFile );
				//
				iResult := FindNext ( sr );
			End;
			Inc ( i );
		End;
		If Not bFound Then
		Begin
			//
			iResult := FindFirst ( sPath + '*.*', faDirectory, sr );
			While Not bFound And ( iResult = 0 ) Do
			Begin
				If ( Copy ( sr.Name, 1, 1 ) <> '.' ) And ( ( sr.Attr And faDirectory ) <> 0 ) Then
				Begin
					bDup := False;
					i := 1;
					While Not bDup And ( i <= MaxCheck ) Do
					Begin
						If Pos ( Check [ i ], UpperCase ( sr.Name ) ) > 0 Then
							bDup := True
						Else
							Inc ( i );
					End;
					//
					If Not bDup Then
						FindOneFile ( sPath + sr.Name + '\', sFile );
				End;
				//
				iResult := FindNext ( sr );
			End;
			//
		End;
	End;
End;

procedure TFormFndFile.cmdCancelClick(Sender: TObject);
begin
	Close;
end;

procedure TFormFndFile.cmdOKClick(Sender: TObject);
Var
	s : String;
begin
	s := EditPath.Text + EditFileName.Text;
	//
	If Not FileExists ( s ) Then
	Begin
		s := EditPath.Text + '\' + EditFileName.Text;
		If FileExists ( s ) Then
		Begin
			EditPath.Text := EditPath.Text + '\';
		End;
	End;
	//
	If FileExists ( s ) Then
	Begin
		//
		Desc := EditDescription.Text;
		Path := EditPath.Text;
		Exec := EditFileName.Text;
		//
		UpdateIniFile ( '(TOOLS)', Desc + ',', Desc + ',' + Path + ',' + Exec );
		//
		Close;
	End
	Else
	Begin
		MessageDlg ( 'File not found.' + #13 + s, mtError, [mbOK], 0 );
	End;
end;

procedure TFormFndFile.cmdBrowseClick(Sender: TObject);
begin
	With OpenDialog1 Do
	Begin
  	InitialDir := EditPath.Text;
		Filter := EditFileName.Text + ' File|' + EditFileName.Text + '|All Files|*.*';
		If Execute Then
		Begin
			EditPath.Text := Copy ( FileName, 1, PosR ( '\', FileName ) );
			EditFileName.Text := RemoveFromLeft ( FileName, PosR ( '\', FileName ) );
		End;
	End;
end;

procedure TFormFndFile.cmdFindItClick(Sender: TObject);
Var
	sPath : String;
begin
	bFound := False;
	gCount := 0;
	Cursor := crHourGlass;
	//
	lblMessage.Caption := 'Searching...';
	//
  sPath := Copy ( EditPath.Text, 1, 2 );
  If Copy ( sPath, 2, 1 ) <> ':' Then
  	sPath := 'C:';
	FindOneFile ( sPath + '\', EditFileName.Text );
	//
	If bFound Then
	Begin
		EditPath.Text := Copy ( sFound, 1, PosR ( '\', sFound ) );
		EditFileName.Text := RemoveFromLeft ( sFound, PosR ( '\', sFound ) );
		//
		lblMessage.Caption := 'The "Find It!" function located this file. Please verify that it is the correct one and click OK.';
		//
		cmdOK.SetFocus;
	End
	Else
	Begin
		lblMessage.Caption := 'The "Find It!" function could not locate this file. Please make sure the file name is correct.';
		//
		ShowMessage ( 'Sorry, the file was not found.' );
		//
		cmdBrowse.SetFocus;
	End;
	//
	Cursor := crDefault;
end;

procedure TFormFndFile.FormCreate(Sender: TObject);
begin
	lblMessage.Caption := 'This file was not found. Please specify the correct path, or click "Find It!" to search for the file automatically.';
end;

end.
