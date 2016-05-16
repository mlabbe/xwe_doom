unit Main;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, Stringz, ShellAPI, ExtCtrls;

type
  TFormMain = class(TForm)
    OpenDialog1: TOpenDialog;
    PanelMain: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    txtIn: TEdit;
    txtOut: TEdit;
    cmdStart: TButton;
    cmdBrowse1: TButton;
    cmdBrowse2: TButton;
		procedure cmdStartClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
    procedure cmdBrowse1Click(Sender: TObject);
	private
		{ Private declarations }
		Function th ( s : String ) : String;
		function ExecuteFile(const FileName, Params, DefaultDir: string;
			ShowCmd: Integer): THandle;
		Procedure ConvertFile ( sFileName : String );
	public
		{ Public declarations }
	end;

var
	FormMain: TFormMain;

implementation

{$R *.DFM}

function TFormMain.ExecuteFile(const FileName, Params, DefaultDir: string;
	ShowCmd: Integer): THandle;
Var
	zFileName, zParams, zDir: array[0..79] of Char;
Begin
	Result := ShellExecute(Application.MainForm.Handle, nil,
		StrPCopy(zFileName, FileName), StrPCopy(zParams, Params),
		StrPCopy(zDir, DefaultDir), ShowCmd);
end;

Function TFormMain.th ( s : String ) : String;
Begin
	If Copy ( s, 1, 2 ) = '0x' Then
		th := '$' + RemoveFromLeft ( s, 2 )
	Else
		th := s;
End;

procedure TFormMain.cmdStartClick(Sender: TObject);
Var
	s, sPath : String;
	sr : TSearchRec;
	iError : Integer;
Begin
	//
	s := txtIn.Text;
	sPath := Copy ( s, 1, PosR ( '\', s ) );
	//
	iError := FindFirst ( s, faAnyFile, sr );
	While iError = 0 Do
	Begin
		ConvertFile ( sPath + sr.Name );
		//
		iError := FindNext ( sr );
	End;
	//
End;

procedure TFormMain.ConvertFile ( sFileName : String );
var
	tf, tn : TextFile;
	s : String;
	i : Integer;
	//
	s1, s2, s3, s4, s5 : String;
begin
	If Not FileExists ( sFileName ) Then
	Begin
		ShowMessage ( 'Source file does not exist.' );
		Exit;
	End;
	//
	AssignFile ( tf, sFileName );
	Reset ( tf );
	//
	s := RemoveFromLeft ( sFileName, PosR ( '\', sFileName ) );
	s := Copy ( s, 1, Pos ( '.', s ) ) + 'ini';
	s := txtOut.Text + 'xwe-config-' + s;
	AssignFile ( tn, s );
	ReWrite ( tn );
	//
	i := 0;
	While Not EOF ( tf ) Do
	Begin
		ReadLn ( tf, s );
		//
		If Copy ( s, 1, 1 ) = '[' Then
		Begin
			i := 0;
		End;
		//
		If i <> 0 Then
		Begin
			//
			If ( s = '' ) Or ( Copy ( s, 1, 1 ) = ';' ) Then
			Begin
				WriteLn ( tn, s );
			End
			Else
			Begin
				//
				If i > 0 Then
				Begin
					s := Replace ( s, #9, ' ' );
					s := Replace ( s, '  ', ' ' );
				End;
				//
				Case i Of

					1 :
					Begin
						//
						SplitAtMark ( s, s1, ' ' );
						SplitAtMark ( s1, s2, ' ' );
						SplitAtMark ( s2, s3, ' ' );
						SplitAtMark ( s3, s4, ' ' );
						//
						s1 := Zero ( SafeVal ( s1 ), 3 );
						s2 := Zero ( SafeVal ( s2 ), 3 );
						s3 := UpperCase ( s3 );
						//
						s4 := '"' + s4 + '"';
						//
						WriteLn ( tn, s1 + ',' + s2 + ',' + s3 + ',' + s4 + '=' + th ( s ) );
						//
					End;

					2 :
					Begin
						//
						SplitAtMark ( s, s1, ' ' );
						SplitAtMark ( s1, s2, ' ' );
						SplitAtMark ( s2, s3, ' ' );
						SplitAtMark ( s3, s4, ' ' );
						SplitAtMark ( s4, s5, ' ' );
						//
						s := Zero ( SafeVal ( th ( s ) ), 3 );
						s1 := Zero ( SafeVal ( th ( s1 ) ), 3 );
						//
						s5 := '"' + s5 + '"';
						//
						WriteLn ( tn, s1 + ',$' +
							IntToHex ( SafeVal ( s4 ), 2 ) +
							IntToHex ( SafeVal ( s3 ), 2 ) +
							IntToHex ( SafeVal ( s2 ), 2 ) + ',' + s5 + '=' + s );
						//
					End;

					3 :
					Begin
						SplitAtMark ( s, s1, ' ' );
						SplitAtMark ( s1, s2, ' ' );
						//
						WriteLn ( tn, s1 + ',"' + s2 + '"=' + th ( s ) );
					End;

					4 :
					Begin
						SplitAtMark ( s, s1, ' ' );
						//
						s1 := '"' + s1 + '"';
						WriteLn ( tn, s1 + '=' + th ( s ) );
					End;

					5 :
					Begin
						SplitAtMark ( s, s1, ' ' );
						//
						s1 := '"' + s1 + '"';
						WriteLn ( tn, '1,' + s1 + '=' + th ( s ) );
					End;

				End;
			End;
		End;
		//
		If s = '[Things.Types]' Then
		Begin
			WriteLn ( tn, '(THINGTYPES:ClassID,Size,Sprite,Name)' );
			i := 1;
		End
		Else
		Begin
			If s = '[Things.Classes]' Then
			Begin
				WriteLn ( tn, '(THINGCLASSES:Flag,Color,Name)' );
				i := 2;
			End
			Else
			Begin
				//
				If ( s = '[Specials.Types]' )
				Or ( s = '[LineDefs.Types]' ) Then
				Begin
					WriteLn ( tn, '(LINEDEFTYPES:)' );
					i := 3;
				End
				Else
				Begin
					If ( s = '[Specials.Classes]' )
					Or ( s = '[LineDefs.Classes]' ) Then
					Begin
						WriteLn ( tn, '(LINEDEFCLASSES:)' );
						i := 4;
					End
					Else
					Begin
						//
						If s = '[Sectors.Types]' Then
						Begin
							WriteLn ( tn, '(SECTORCLASSES:)' );
							WriteLn ( tn, '"Default"=1' );
							//
							WriteLn ( tn, '(SECTORTYPES:)' );
							i := 5;
						End
						Else
						Begin
						End;
						//
					End;
				End;
			End;
		End;
	End;
	//
	CloseFile ( tf );
	CloseFile ( tn );
	//
	Caption := 'Done!';
	ExecuteFile ( 'EXPLORER.EXE', txtOut.Text, '', SW_SHOWMAXIMIZED );
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
	txtIn.Text := 'c:\Doom\wauthor\*.wcf';
	txtOut.Text := 'C:\';
end;

procedure TFormMain.cmdBrowse1Click(Sender: TObject);
begin
	OpenDialog1.Filter := 'WCF Files|*.wcf';
	OpenDialog1.InitialDir := Copy ( txtIn.Text, 1, PosR ( '\', txtIn.Text ) );
	If OpenDialog1.Execute Then
	Begin
		txtIn.Text := OpenDialog1.FileName;
	End;
end;

end.
