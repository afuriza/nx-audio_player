unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls,
  Graphics, Dialogs, ComCtrls, uos_flat,
  StdCtrls, ExtCtrls;

type

  { Tfmain }

  Tfmain = class(TForm)
    btnPlay: TButton;
    btnStop: TButton;
    btnAddAudF: TButton;
    llength: TLabel;
    lposition: TLabel;
    ltname: TLabel;
    Label3: TLabel;
    lvTrack: TListView;
    OpenDialog1: TOpenDialog;
    tbTrack: TTrackBar;
    tbVol: TTrackBar;
    procedure btnAddAudFClick(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure ClosePlayer1;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure tbTrackChange(Sender: TObject);
    procedure tbTrackMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure tbTrackMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure tbVolChange(Sender: TObject);
    procedure ShowPosition;
  private
    { private declarations }
  public
    lib1, lib2, lib3: string;
    currtrack: integer;
    stopit: boolean;
    audioplay: cardinal;
    outd, ind: integer;
    procedure nextplay(itrack: integer);
    { public declarations }
  end;

var
  fmain: Tfmain;


implementation

{$R *.lfm}

{ Tfmain }

procedure Tfmain.nextplay(itrack: integer);
var
  vol: double;
  temptime: ttime;
  ho, mi, se, ms: word;
begin
  uos_stop(audioplay);
  stopit := False;
  if btnPlay.Caption = 'Play' then
  begin
    if BtnStop.Enabled = False then
    begin
      if not (lvTrack.SelCount = 0) then
      begin
        audioplay := 0;
        uos_CreatePlayer(audioplay);

        ind := uos_AddFromFile(audioplay, PChar(lvTrack.Items[itrack].Caption),
          -1, 0, -1);
        ltname.Caption := SysUtils.ExtractFileName(lvTrack.Items[itrack].Caption);
        outd := uos_AddIntoDevOut(audioplay, -1, -1,
          uos_InputGetSampleRate(audioplay, ind), -1, 0, -1);
        uos_InputSetPositionEnable(audioplay, ind, 1);
        temptime := uos_InputLengthTime(audioplay, ind);
        uos_LoopProcIn(audioplay, ind, @ShowPosition);
        DecodeTime(temptime, ho, mi, se, ms);

        llength.Caption := format('%.2d:%.2d', [mi, se]);
        uos_EndProc(audioplay, @ClosePlayer1);
        uos_AddDSPVolumeIn(audioplay, ind, 1, 1);
        if tbVol.Position = 10 then
          vol := 1
        else
        if tbVol.Position > 10 then
          vol := 1 + ((10 - tbVol.Position) / 2.5)
        else
          vol := tbVol.Position / 10;
        uos_SetDSPVolumeIn(audioplay, ind, vol, vol, True);
        tbTrack.Max := uos_InputLength(audioplay, ind);
        uos_Play(audioplay);
        btnPlay.Caption := 'Pause';
        btnStop.Enabled := True;
      end;
    end
    else
    begin
      uos_RePlay(audioplay);
      btnPlay.Caption := 'Pause';
    end;
  end
  else
  begin
    uos_Pause(audioplay);
    btnPlay.Caption := 'Play';
  end;

end;

procedure Tfmain.ClosePlayer1;
begin
  ltname.Caption := '';
  tbTrack.Position := 0;
  lposition.Caption := '00:00';
  llength.Caption := '00:00';
  btnStop.Enabled := False;
  btnPlay.Caption := 'Play';
  if (not stopit) and (currtrack < lvTrack.Items.Count - 1) then
  begin
    currtrack := currtrack + 1;
    nextplay(currtrack);
  end;
end;

procedure Tfmain.FormActivate(Sender: TObject);
var
  ordir: string;
{$IFDEF Darwin}
  opath: string;
{$ENDIF}
begin
  ordir := application.Location;
  {$IFDEF Windows}
  {$if defined(cpu64)}
  lib1 := ordir + 'audlib\Windows\64bit\LibPortaudio-64.dll';
  lib2 := ordir + 'audlib\Windows\64bit\LibSndFile-64.dll';
  lib3 := ordir + 'audlib\Windows\64bit\LibMpg123-64.dll';
  {$else}
  lib1 := ordir + 'audlib\Windows\32bit\LibPortaudio-32.dll';
  lib2 := ordir + 'audlib\Windows\32bit\LibSndFile-32.dll';
  lib3 := ordir + 'audlib\Windows\32bit\LibMpg123-32.dll';
  {$endif}
  {$ENDIF}

  {$IFDEF Darwin}
  opath := ordir;
  opath := copy(opath, 1, Pos('/uos', opath) - 1);
  lib1 := opath + '/audlib/Mac/32bit/LibPortaudio-32.dylib';
  lib2 := opath + '/audlib/Mac/32bit/LibSndFile-32.dylib';
  lib3 := opath + '/audlib/Mac/32bit/LibMpg123-32.dylib';
  {$ENDIF}

  {$IFDEF linux}
  {$if defined(cpu64)}
  lib1 := ordir + 'audlib/Linux/64bit/LibPortaudio-64.so';
  lib2 := ordir + 'audlib/Linux/64bit/LibSndFile-64.so';
  lib3 := ordir + 'audlib/Linux/64bit/LibMpg123-64.so';
  {$else}
  lib1 := ordir + 'audlib/Linux/32bit/LibPortaudio-32.so';
  lib2 := ordir + 'audlib/Linux/32bit/LibSndFile-32.so';
  lib3 := ordir + 'audlib/Linux/32bit/LibMpg123-32.so';
  {$endif}
  {$ENDIF}

  {$IFDEF freebsd}
  {$if defined(cpu64)}
  lib1 := ordir + 'audlib/FreeBSD/64bit/libportaudio-64.so';
  lib2 := ordir + 'audlib/FreeBSD/64bit/libmpg123-64.so';
  lib3 := ordir + 'audlib/FreeBSD/64bit/libsndfile-64.so';
  {$else}
  lib1 := ordir + 'audlib/FreeBSD/32bit/libportaudio-32.so';
  lib2 := ordir + 'audlib/FreeBSD/32bit/libsndfile-32.so';
  lib3 := ordir + 'audlib/FreeBSD/32bit/libmpg123-32.so';
  {$endif}
  {$ENDIF}
  if uos_LoadLib(PChar(lib1), PChar(lib2), PChar(lib3)) = 0 then
  begin

  end
  else
  begin
    if uosLoadResult.PAloaderror = 1 then
      MessageDlg(lib1 + ' do not exist...', mtWarning, [mbYes], 0);
    if uosLoadResult.PAloaderror = 2 then
      MessageDlg(lib1 + ' do not load...', mtWarning, [mbYes], 0);
    if uosLoadResult.SFloaderror = 1 then
      MessageDlg(lib2 + ' do not exist...', mtWarning, [mbYes], 0);
    if uosLoadResult.SFloaderror = 2 then
      MessageDlg(lib2 + ' do not load...', mtWarning, [mbYes], 0);
    if uosLoadResult.MPloaderror = 1 then
      MessageDlg(lib3 + ' do not exist...', mtWarning, [mbYes], 0);
    if uosLoadResult.MPloaderror = 2 then
      MessageDlg(lib3 + ' do not load...', mtWarning, [mbYes], 0);
  end;
end;

procedure Tfmain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if btnStop.Enabled then
  begin
    btnStop.Click;
  end;
end;

procedure Tfmain.tbTrackChange(Sender: TObject);
begin

end;

procedure Tfmain.tbTrackMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  uos_Pause(audioplay);
end;

procedure Tfmain.tbTrackMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  uos_seek(audioplay, ind, tbTrack.Position);
  uos_RePlay(audioplay);
end;

procedure Tfmain.tbVolChange(Sender: TObject);
var
  vol: double;
begin
  if tbVol.Position = 10 then
    vol := 1
  else
  if tbVol.Position > 10 then
    vol := 1 + ((10 - tbVol.Position) / 2.5)
  else
    vol := tbVol.Position / 10;

  if (btnStop.Enabled = True) then
    uos_SetDSPVolumeIn(audioplay, ind, vol, vol, True);
end;

procedure Tfmain.btnAddAudFClick(Sender: TObject);
var
  item: TListItem;
begin
  if opendialog1.Execute then
  begin
    Item := LvTrack.Items.Add;
    Item.Caption := OpenDialog1.FileName;
    Item.SubItems.Add('Unknown');
  end;
end;

procedure Tfmain.btnPlayClick(Sender: TObject);
var
  vol: double;
  temptime: ttime;
  ho, mi, se, ms: word;
begin
  stopit := False;
  if btnPlay.Caption = 'Play' then
  begin
    if BtnStop.Enabled = False then
    begin
      if not (lvTrack.SelCount = 0) then
      begin
        currtrack := lvTrack.Selected.Index;
        audioplay := 0;

        uos_CreatePlayer(audioplay);

        ind := uos_AddFromFile(audioplay, PChar(lvTrack.Selected.Caption),
          -1, 0, -1);
        ltname.Caption := SysUtils.ExtractFileName(lvTrack.Selected.Caption);

        outd := uos_AddIntoDevOut(audioplay, -1, -1,
          uos_InputGetSampleRate(audioplay, ind), -1, 0, -1);
        uos_InputSetPositionEnable(audioplay, ind, 1);
        temptime := uos_InputLengthTime(audioplay, ind);
        uos_LoopProcIn(audioplay, ind, @ShowPosition);
        DecodeTime(temptime, ho, mi, se, ms);

        llength.Caption := format('%.2d:%.2d', [mi, se]);
        uos_EndProc(audioplay, @ClosePlayer1);
        uos_AddDSPVolumeIn(audioplay, ind, 1, 1);
        if tbVol.Position = 10 then
          vol := 1
        else
        if tbVol.Position > 10 then
          vol := 1 + ((10 - tbVol.Position) / 2.5)
        else
          vol := tbVol.Position / 10;
        uos_SetDSPVolumeIn(audioplay, ind, vol, vol, True);
        tbTrack.Max := uos_InputLength(audioplay, ind);
        uos_Play(audioplay);
        btnPlay.Caption := 'Pause';
        btnStop.Enabled := True;
      end;
    end
    else
    begin
      uos_RePlay(audioplay);
      btnPlay.Caption := 'Pause';
    end;
  end
  else
  begin
    uos_Pause(audioplay);
    btnPlay.Caption := 'Play';
  end;

end;


procedure Tfmain.btnStopClick(Sender: TObject);
begin
  stopit := True;
  uos_Stop(audioplay);
end;

procedure Tfmain.ShowPosition;
var
  temptime: ttime;
  ho, mi, se, ms: word;
begin
  if TbTrack.Tag = 0 then
  begin
    tbTrack.Position := uos_InputPosition(audioplay, ind);
    temptime := uos_InputPositionTime(audioplay, ind);
    // Length of input in time
    DecodeTime(temptime, ho, mi, se, ms);
    lposition.Caption := format('%.2d:%.2d', [mi, se]);
  end;
end;

end.
