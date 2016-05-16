unit Options;

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
	StdCtrls, Globals, ComCtrls;

type
	TFormOptions = class(TForm)
		PageControl1: TPageControl;
		TabSheet1: TTabSheet;
		TabSheet2: TTabSheet;
		TabSheet3: TTabSheet;
		cmdOK: TButton;
		cmdCancel: TButton;
		Label1: TLabel;
		chkOpenLast: TCheckBox;
		chkOnlyOneBackup: TCheckBox;
		chkShowFullPath: TCheckBox;
		chkShowSize: TCheckBox;
		chkShowPosition: TCheckBox;
		EditTempFolder: TEdit;
		chkAutoCleanUp: TCheckBox;
		chkAutoPlaySounds: TCheckBox;
		chkCutCopy: TCheckBox;
    chkDisableUndo: TCheckBox;
    chkDontAutoCapitalize: TCheckBox;
    TabSheet4: TTabSheet;
    radFileTypes0: TRadioButton;
    radFileTypes1: TRadioButton;
    radFileTypes2: TRadioButton;
    Label2: TLabel;
    radFileTypes3: TRadioButton;
    chkRawPNG: TCheckBox;
    chkPreviewMaps: TCheckBox;
    chkAutoApplyOffset: TCheckBox;
    chkAutoBackup: TCheckBox;

		procedure FormCreate(Sender: TObject);
		procedure cmdOKClick(Sender: TObject);
		procedure cmdCancelClick(Sender: TObject);
		procedure chkShowSizeClick(Sender: TObject);
	private
		{ Private declarations }
		procedure RefreshScreen;
		procedure SaveOptions;
	public
		{ Public declarations }
		ColumnsChanged : Boolean;
		AssociationsChanged : Boolean;
	end;

var
	FormOptions: TFormOptions;

implementation

{$R *.DFM}

procedure TFormOptions.FormCreate(Sender: TObject);
begin
	RefreshScreen;
end;

procedure TFormOptions.RefreshScreen;
begin
	chkOpenLast.Checked := gOpenLast;
	chkCutCopy.Checked := gCutCopyEmpty;
	chkOnlyOneBackup.Checked := gOnlyOneBack;
	chkAutoCleanUp.Checked := gAutoCleanUp;
	chkAutoBackup.Checked := gAutoBackup;
	chkPreviewMaps.Checked := gPreviewMaps;
	chkAutoPlaySounds.Checked := gAutoPlaySounds;
	chkDisableUndo.Checked := gDisableUndo;
	chkRawPNG.Checked := gRawPNG;
	chkAutoApplyOffset.Checked := gAutoApplyOffsets;
	EditTempFolder.Text := sTempFolder;
	//
	chkShowFullPath.Checked := gShowFullPath;
	chkShowSize.Checked := gShowSize;
	chkShowSizeClick ( Self );
	chkShowPosition.Checked := gShowPosition;
	chkDontAutoCapitalize.Checked := gDontAutoCapitalize;
	//
	If gAssociations = assoc_None Then
		radFileTypes0.Checked := True
	Else If gAssociations = assoc_WAD Then
		radFileTypes1.Checked := True
	Else If gAssociations = assoc_Common Then
		radFileTypes2.Checked := True
	Else
		radFileTypes3.Checked := True;
end;

procedure TFormOptions.SaveOptions;
Var
	NewAssociations : TAssociations;
begin
	gOpenLast := chkOpenLast.Checked;
	gCutCopyEmpty := chkCutCopy.Checked;
	gOnlyOneBack := chkOnlyOneBackup.Checked;
	gAutoCleanUp := chkAutoCleanUp.Checked;
	gAutoBackup := chkAutoBackup.Checked;
	gPreviewMaps := chkPreviewMaps.Checked;
	gAutoPlaySounds := chkAutoPlaySounds.Checked;
	gDisableUndo := chkDisableUndo.Checked;
	gRawPNG := chkRawPNG.Checked;
	gAutoApplyOffsets := chkAutoApplyOffset.Checked;
	sTempFolder := EditTempFolder.Text;
	//
	ColumnsChanged := ( gShowSize <> chkShowSize.Checked )
		Or ( gShowPosition <> ( chkShowPosition.Checked And chkShowPosition.Enabled ) );
	//
	gShowFullPath := chkShowFullPath.Checked;
	gShowSize := chkShowSize.Checked;
	gShowPosition := ( chkShowPosition.Checked And chkShowPosition.Enabled );
	gDontAutoCapitalize := chkDontAutoCapitalize.Checked;
	//
	If radFileTypes0.Checked Then
		NewAssociations := assoc_None
	Else If radFileTypes1.Checked Then
		NewAssociations := assoc_WAD
	Else If radFileTypes2.Checked Then
		NewAssociations := assoc_Common
	Else
		NewAssociations := assoc_All;
	//
	AssociationsChanged := NewAssociations <> gAssociations;
	gAssociations := NewAssociations;
end;

procedure TFormOptions.cmdOKClick(Sender: TObject);
begin
	SaveOptions;
	Close;
end;

procedure TFormOptions.cmdCancelClick(Sender: TObject);
begin
	Close;
end;

procedure TFormOptions.chkShowSizeClick(Sender: TObject);
begin
	chkShowPosition.Enabled := chkShowSize.Checked;
end;

end.
