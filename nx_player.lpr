program nx_player;

{$mode objfpc}{$H+}
{$DEFINE UseCThreads}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads, cmem,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, umain, uos_flat
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(Tfmain, fmain);
  Application.Run;
end.

