unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, Grids,
  CheckLst, ExtCtrls, PairSplitter, ComCtrls, LazSerial, Unit2, inifiles,
  lazsynaser, core,
  //DataPortSerial,
  // DataPort,
  strutils, dateutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    ComboBox1: TComboBox;
 //   DataPortSerial1: TDataPortSerial;
// Serial: TBlockSerial;
    EditDevice: TEdit;
    MenuItem10: TMenuItem;
    MenuItem9: TMenuItem;
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
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure DataPortSerial1Close(Sender: TObject);
    procedure DataPortSerial1DataAppear(Sender: TObject);
    procedure DataPortSerial1Error(Sender: TObject; const AMsg: string);
    procedure DataPortSerial1Open(Sender: TObject);
    procedure DrawGrid1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);

    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
(*    procedure SerialRxData(Sender: TObject); *)
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
(*    procedure SerialStatus(Sender: TObject; Reason: THookSerialReason;
      const Value: string);                                              *)
    procedure Timer1StopTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    function hex_to_asci(hex:string):string;
  private

  public

  end;

var
  Form1: TForm1;
  IniFile: TiniFile;

implementation

{$R *.lfm}

{ TForm1 }


function TForm1.hex_to_asci(hex:string):string;
var i,j:integer;
    conc:string;
    a:byte;
begin
for i:= 1 to (length(hex) div (2) ) do
begin
j:=(i*2)-1;
a:=byte( strutils.Hex2Dec(copy(hex, j ,2) ) );
conc := conc+ char(a);
end;
result:= conc;
end;


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

  A := '$16$03$a7$80$00$05$de$ad';
  A := '16 03 a7 80 00 05 de ad';
  Memo1.Append(A);
  Memo1.Append(Modbus.StrToHexStr(A));
  Setlength(D, 8);
  D[0] := $16;
  D[1] := $03;
  D[2] := $A7;
  D[3] := $80;
  D[4] := $00;
  D[5] := $05;
  D[6] := $DE;
  D[7] := $AD;


  Timer1.Enabled := True;
//  Serial.Close;

end;

procedure TForm1.Button4Click(Sender: TObject);
var
  stringToSend: string;
  response: string;
  D: array of byte;


(* function send(port: string; data: string): string;
//function send(port: string; data: pointer; len: integer): string;
const
  recvTimeout = 2000; // время ожидания ответа от устройства
var
  ComPort: TBlockSerial;
  resp: Array of byte;
  i: byte;
  waiting: integer;
  dtStart: TDateTime;
  has_timed_out: boolean;
  output: string;

begin
  ComPort := TBlockSerial.Create;
  try
    ComPort.Connect(port);
    if ComPort.LastError > 0 then
    begin
      StatusBar1.SimpleText := 'Couldn''t connect to port';
      Exit;
    end;
    ComPort.Config(115200, 8, 'N', SB1, false, false);
    if ComPort.LastError > 0 then
    begin
      StatusBar1.SimpleText := 'Couldn''t connect to port';
      Exit;
    end;
   ComPort.SendString(data);
 //     ComPort.SendBuffer(data, len);
    if ComPort.LastError > 0 then
    begin
      StatusBar1.SimpleText := 'No data to send';
      Exit;
    end;

    output := '';
    while 1 = 1 do
    begin
      // начинаем ждать ответа
      dtStart := Now;
      has_timed_out := false;
      while ComPort.WaitingData = 0 do
      begin
        if MilliSecondsBetween(dtStart, Now) > recvTimeout then
        begin
          has_timed_out := true;
          break;
        end;
        sleep(200);
      end;

      if has_timed_out then
      begin
        StatusBar1.SimpleText := 'No responce';
        break; // выход - в буфере ничего нет
      end;

      waiting := ComPort.WaitingData;
     Memo1.Append('waiting: ' + IntToStr(waiting));
    SetLength(resp, waiting);

    for i := 0 to Length(resp) - 1 do
    begin
      resp[i] := ComPort.RecvByte(2000);
    end;

    if ComPort.LastError > 0 then
    begin
      StatusBar1.SimpleText := 'Ошибка приёма данных';
      Exit;
    end;
    end;

  finally
    ComPort.free;
  end;
  Memo1.Append('Length of resp - ' + IntToStr(Length(resp)));
 output := '';
 for i := 0 to Length (resp) - 1 do
  begin
    output += IntToHex(resp[i], 2) + ' ';  // Строка hex значений, разделённая пробелами
   // break;
  end; (* *)

 (* Delete(output, Length(output), 1);  // Удаление последнего пробела в строке *)

  Result := output;
end;         *)

begin
Setlength(D, 8);

//A := '$16$03$a7$80$00$05$de$ad';
// -> good
// stringToSend := Chr($16) + Chr($03) + Chr($a7) + Chr($80) + Chr($00) + Chr($05) + Chr($de) + Chr($ad);  // Modbus-запрос
// ID номер модуля
// stringToSend := Chr($16) + Chr($03) + Chr($01) + Chr($d0) + Chr($00) + Chr($06) + Chr($de) + Chr($ad);  // Modbus-запрос
// stringToSend := $16 + $03 + $a7 + $80 + $00 + $05 + $de + $ad;
stringToSend := Modbus.StrToHexStr('16 03 a7 80 00 05 de ad');
Modbus.port := 'COM2'; //удалить на настройки

response := Modbus.send(stringToSend);
if (Modbus.portStatus <> 'OK') then Memo1.Append(Modbus.portStatus);
// response := send('COM2', stringToSend);
// response := send('COM2', D, 8);
   Memo1.Append(response);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
//  StringGrid1.RowCount := 2;
 //поиск на шине modbus плат отвечающих на запрос
end;


procedure TForm1.DataPortSerial1Close(Sender: TObject);
begin
 //  DataPort.Active := True;
 //  DataPortSerial1.Active:=False;
   StatusBar1.SimpleText := 'Serial Port disconnected';
end;

procedure TForm1.DataPortSerial1DataAppear(Sender: TObject);
var str: string;
begin
  // str := DataPortSerial1.Pull(64);
  // Memo1.Append(str);
end;

procedure TForm1.DataPortSerial1Error(Sender: TObject; const AMsg: string);
begin
  Memo1.Append('Error on port: ' + AMsg)
end;

procedure TForm1.DataPortSerial1Open(Sender: TObject);
begin
  StatusBar1.SimpleText := 'Port connected';
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
   (* if Serial.Active then
    Serial.Active := false ;
    IniFile.Free;
     Application.Terminate; *)
   //if DataPortSerial1.Active then
   //   begin
   //     DataPortSerial1.Close();
   //     DataPortSerial1.Active := False;
   //   end;
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
 // EditDevice.Text := DataPortSerial1.Port;
 StringGrid1.Cells[0,0] := 'Index';
 StringGrid1.Cells[1,0] := 'Affect';
 StringGrid1.Cells[2,0] := 'Address';
 StringGrid1.Cells[3,0] := 'Serial Number';
 StringGrid1.ColWidths[3] := 100;
 StringGrid1.Cells[4,0] := 'Type';
 StringGrid1.Cells[5,0] := 'PGA';
 StringGrid1.Cells[6,0] := 'SPS';
 StringGrid1.Cells[7,0] := 'FIR';
 StringGrid1.Cells[8,0] := 'RunTime';
 StringGrid1.Cells[9,0] := 'Error Counter';
 StringGrid1.ColWidths[9] := 100;
 StringGrid1.Cells[10,0] := 'Version';

end;



procedure TForm1.MenuItem10Click(Sender: TObject);
begin
 Form2.Show;
end;

procedure TForm1.MenuItem9Click(Sender: TObject);
begin
  //
     (*   Serial.ShowSetupDialog; *)
end;



(* procedure TForm1.SerialRxData(Sender: TObject);
var Str: String;
begin
  Str := Serial.ReadData;
//  Memo1.Append(Str);
end; *)

procedure TForm1.MenuItem4Click(Sender: TObject);
begin

end;

(* procedure TForm1.SerialStatus(Sender: TObject; Reason: THookSerialReason;
  const Value: string);
begin
   case Reason of
    HR_SerialClose : StatusBar1.SimpleText := 'Port ' + Value + ' closed';
    HR_Connect :   StatusBar1.SimpleText := 'Port ' + Value + ' connected';
    HR_Wait :  StatusBar1.SimpleText := 'Wait : ' + Value ;
    end;
end; *)

procedure TForm1.Timer1StopTimer(Sender: TObject);
begin
// Serial.Close;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
       Timer1.Enabled := False;
 Memo1.Append('stop the timer');
 // DataPortSerial1.Close()
end;


end.

