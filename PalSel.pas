unit PalSel;

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
	StdCtrls, Globals;

type
	TFormPal = class(TForm)
		lstPalette: TListBox;
		cmdOK: TButton;
		cmdCancel: TButton;
		procedure FormCreate(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	FormPal: TFormPal;

implementation

{$R *.DFM}

procedure TFormPal.FormCreate(Sender: TObject);
var
	i : Integer;
begin
	lstPalette.Items.Clear;
	lstPalette.Items.Add ( '(auto)' );
	For i := 0 To nPals - 1 Do
	Begin
		lstPalette.Items.Add ( Pals [ i ].Name );
	End;
	lstPalette.ItemIndex := iPreferredPal + 1;
end;

procedure TFormPal.cmdCancelClick(Sender: TObject);
begin
	Close;
end;

procedure TFormPal.cmdOKClick(Sender: TObject);
begin
	iPreferredPal := lstPalette.ItemIndex - 1;
	Close;
end;

end.
