unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, Grids,
  CheckLst, ExtCtrls, PairSplitter, ComCtrls, LazSerial, Unit2, inifiles,
  lazsynaser;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ComboBox1: TComboBox;
    EditDevice: TEdit;
    MenuItem10: TMenuItem;
    MenuItem9: TMenuItem;
    Serial: TLazSerial;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    Timer1: TTimer;

    procedure Button3Click(Sender: TObject);
    procedure DrawGrid1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);

    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure SerialRxData(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure SerialStatus(Sender: TObject; Reason: THookSerialReason;
      const Value: string);
    procedure Timer1StopTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  IniFile: TiniFile;

implementation

{$R *.lfm}

{ TForm1 }


 (* {$IFDEF LINUX}
 IniFile := TIniFile.Create(
 GetAppConfigFile(False) + '.conf');

{$ELSE}
 IniFile := TIniFile.Create(
 ExtractFilePath(Application.EXEName) + 'SerTest.ini');
{$ENDIF}    *)

procedure TForm1.MenuItem3Click(Sender: TObject);
begin


end;

procedure TForm1.DrawGrid1Click(Sender: TObject);
begin

end;

procedure TForm1.Button3Click(Sender: TObject);
var A: string;
    D: array of byte;
begin
  A := '$16$03$a7$80$00$05$de$ad';
  Setlength(D, 8);
  D[0] := $16;
  D[1] := $03;
  D[2] := $A7;
  D[3] := $80;
  D[4] := $00;
  D[5] := $05;
  D[6] := $DE;
  D[7] := $AD;

  Serial.Open;

  Timer1.Enabled := True;
//  Serial.Close;

end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    if Serial.Active then
    Serial.Active := false ;
    IniFile.Free;
     Application.Terminate;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
{$IFDEF LINUX}
 IniFile := TIniFile.Create(
 GetAppConfigFile(False) + '.conf');

{$ELSE}
 IniFile := TIniFile.Create(
 ExtractFilePath(Application.EXEName) + 'SerTest.ini');
{$ENDIF}
 EditDevice.Text := Serial.Device;
end;



procedure TForm1.MenuItem10Click(Sender: TObject);
begin
 Form2.Show;
end;

procedure TForm1.MenuItem9Click(Sender: TObject);
begin
        Serial.ShowSetupDialog;
end;



procedure TForm1.SerialRxData(Sender: TObject);
var Str: String;
begin
  Str := Serial.ReadData;
//  Memo1.Append(Str);
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin

end;

procedure TForm1.SerialStatus(Sender: TObject; Reason: THookSerialReason;
  const Value: string);
begin
   case Reason of
    HR_SerialClose : StatusBar1.SimpleText := 'Port ' + Value + ' closed';
    HR_Connect :   StatusBar1.SimpleText := 'Port ' + Value + ' connected';
    HR_Wait :  StatusBar1.SimpleText := 'Wait : ' + Value ;
    end;
end;

procedure TForm1.Timer1StopTimer(Sender: TObject);
begin
 Serial.Close;
 Timer1.Enabled := False;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin

end;


end.

