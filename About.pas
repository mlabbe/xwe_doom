unit About;

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
	ExtCtrls, StdCtrls, Globals;

type
	TFormAbout = class(TForm)
		l1: TLabel;
		l2: TLabel;
		l3: TLabel;
		lv: TLabel;
		le: TLabel;
		lw: TLabel;
		editEmail: TEdit;
    editWebsite: TEdit;
		cmdOK: TButton;
		procedure FormCreate(Sender: TObject);
		procedure cmdOKClick(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	FormAbout: TFormAbout;

implementation

{$R *.DFM}

procedure TFormAbout.FormCreate(Sender: TObject);
begin
	lv.Caption := 'Version ' + VersionMajor + '.' + VersionMinor;
	l3.Caption := sCredits;
end;

procedure TFormAbout.cmdOKClick(Sender: TObject);
begin
	Close;
end;

end.

