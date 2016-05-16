program XWE;

{%File 'We.txt'}
{%File 'xwe.ini'}

uses
  Forms,
  Main in 'Main.pas' {FormMain},
  Options in 'Options.pas' {FormOptions},
  ExportDlg in 'ExportDlg.pas' {FormExport},
  About in 'About.pas' {FormAbout},
  Globals in 'Globals.pas',
  MRUSupport in '..\MRUSupport.pas',
  Stringz in '..\Stringz.pas',
  Evaluate in '..\Evaluate.pas',
  GIFImage in '..\GIFImage.pas',
  PalSel in 'PalSel.pas' {FormPal},
  FndFile in 'FndFile.pas' {FormFndFile},
  TBrowse in 'TBrowse.pas' {FormTBrowse},
  Texture in 'Texture.pas',
  WadFile in 'WadFile.pas',
  FileIO in 'FileIO.pas',
  CRC in 'CRC.pas',
  RGBValue in 'RGBValue.pas' {FormRGBValue};

{$R *.RES}

begin
	Application.Initialize;
	Application.Title := 'eXtendable Wad Editor';
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormPal, FormPal);
  Application.CreateForm(TFormFndFile, FormFndFile);
  Application.CreateForm(TFormRGBValue, FormRGBValue);
  Application.Run;
end.
