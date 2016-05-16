program WCFConv;

uses
  Forms,
  Main in 'Main.pas' {FormMain},
  Stringz in '..\..\Stringz.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
