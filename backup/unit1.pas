unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, Grids,
  CheckLst, ExtCtrls, PairSplitter, ComCtrls, LazSerial, Unit2, unit3, unit4, inifiles,
  simpleipc, lazsynaser,
  // DataPortIP,
  core,
  //DataPortSerial,
  // DataPort,
  strutils, dateutils,
  blcksock;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    ComboBox1: TComboBox;
 //   DataPortSerial1: TDataPortSerial;
// Serial: TBlockSerial;
    EditDevice: TEdit;
    Label1: TLabel;
    MenuItem10: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem9: TMenuItem;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    ProgressBar1: TProgressBar;
    SaveDialog1: TSaveDialog;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    Timer1: TTimer;

  //  procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure DataPortSerial1Close(Sender: TObject);
    procedure DataPortSerial1DataAppear(Sender: TObject);
    procedure DataPortSerial1Error(Sender: TObject; const AMsg: string);
    procedure DataPortSerial1Open(Sender: TObject);
    procedure DataPortTCP1Close(Sender: TObject);
    procedure DrawGrid1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);

    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
(*    procedure SerialRxData(Sender: TObject); *)
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
(*    procedure SerialStatus(Sender: TObject; Reason: THookSerialReason;
      const Value: string);                                              *)
    procedure Timer1StopTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    function hex_to_asci(hex:string):string;
  private

  public

  end;

const
  _PGA_ = 5;  //столбец усилителя в таблице
  _SPS_ = 6;  //столбец частоты чтения в таблице

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





procedure TForm1.Button4Click(Sender: TObject);
var
  stringToSend: string;
  response: string;
  D: array of byte;




begin
Setlength(D, 8);

//A := '$16$03$a7$80$00$05$de$ad';
// -> good
// stringToSend := Chr($16) + Chr($03) + Chr($a7) + Chr($80) + Chr($00) + Chr($05) + Chr($de) + Chr($ad);  // Modbus-запрос
// ID номер модуля
// str ingToSend := Chr($16) + Chr($03) + Chr($01) + Chr($d0) + Chr($00) + Chr($06) + Chr($de) + Chr($ad);  // Modbus-запрос
// stringToSend := $16 + $03 + $a7 + $80 + $00 + $05 + $de + $ad;
stringToSend := Modbus.StrToHexStr('16 03 a7 80 00 05 de ad');
Modbus.port := 'COM2'; //удалить на настройки

response := Modbus.send(stringToSend);
if (Modbus.portStatus <> 'OK')
   then
   Memo1.Append(Modbus.portStatus)
   else
   Memo1.Append(response);
end;

procedure TForm1.Button5Click(Sender: TObject);
//прием данных с Agilent
var ip: string;
    Agilent: TTCPBlockSocket;
    ms: TMemoryStream;
    value, cmd: string;
    var clientBuffer: array of byte;
    I: integer;
    output : string;
    b: Byte;
//    Buffer: TMemory;
begin

(*
 https://bravikov.wordpress.com/2015/05/18/%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0-%D1%81-%D0%BC%D1%83%D0%BB%D1%8C%D1%82%D0%B8%D0%BC%D0%B5%D1%82%D1%80%D0%BE%D0%BC-agilent-34410a-%D0%BD%D0%B0-%D0%BF%D0%B8%D1%82%D0%BE%D0%BD%D0%B5/
#python
 # Установить режим измерения: переменное напряжение
 s.send(b'CONFigure:VOLTage:AC\n')


 # Запустить измерение
 s.send(b'*TRG\n')

 # Включить ожидание запуска
 s.send(b'INITiate\n')
 # Передать измерение
 s.send(b'FETCh?\n')

 # Получить и отобразить измерение
 value = s.recv(100).decode('utf-8')
 print(value) *)
Agilent := TTCPBlockSocket.Create;
//ms:=TMemoryStream.Create;
Agilent.Connect(Agil.ip, '5025');  //подключение к Agilent
Memo1.Append(IntToStr(Agilent.LastError));

Agilent.ConnectionTimeout:=1000; //TimeOut 1s (1000 ms)
//cmd :=  'DISP: TEXT "WAITING"' + #10;
//output := Agil.getCommand(cmd);
//clientBuffer := TEncoding.UTF8.GetBytes(cmd);
//Memo1.Append(IntToStr(Length(clientBuffer)));

//I := 0;
//output := '';
//  while (I <= High(clientBuffer)) do
//  begin
//    output := output + chr(clientBuffer[I]);
//    Inc(I)
//  end;
//Agilent.SendString(output);
//Agilent.Free;
//Exit;
Agilent.SendString(Agil.getCommand('CONFigure:VOLTage:DC' + #10));
Memo1.Append(IntToStr(Agilent.LastError));

//# Настроить запуска измерения по команде '*TRG'
Agilent.SendString(Agil.getCommand('TRIGger:SOURce BUS' + #10));
Memo1.Append(IntToStr(Agilent.LastError));

Agilent.SendString(Agil.getCommand('INITiate' + #10));  //Включить ожидание запуска
Memo1.Append(IntToStr(Agilent.LastError));

Agilent.SendString(Agil.getCommand('*TRG'  + #10));
Memo1.Append(IntToStr(Agilent.LastError));
 sleep(500);
 Agilent.SendString(Agil.getCommand('R?' + #10));
Memo1.Append('Error after R command: ' + IntToStr(Agilent.LastError));

value := Agilent.RecvPacket(1000);
//#
//Agilent.SendString(Agil.getCommand('FETCh?'  + #10)) ; //Передать измерение

// b := Agilent.RecvByte(1000);
// value := chr(b);
Memo1.Append('Error after byte recive: ' + IntToStr(Agilent.LastError));
// value := Agilent.RecvBufferStr(1000, 1000);

Memo1.Append(IntToStr(Length(value)) + ' value:' +  value + ': v');
Agilent.Free;
end;

procedure TForm1.Button6Click(Sender: TObject);
    var ip: string;
        Agilent: TTCPBlockSocket;
        ms: TMemoryStream;
        value, cmd: string;
        var clientBuffer: array of byte;
        I: integer;
        output : string;
        b: byte;
 begin

Agilent := TTCPBlockSocket.Create;
// ms := TMemoryStream.Create;
Agilent.Connect(Agil.ip, '5025');  //подключение к Agilent
Memo1.Append(IntToStr(Agilent.LastError));
Agilent.SendString(Agil.getCommand('R?' + #10));
value := Agilent.RecvPacket(1000);
output := UTF8decode(value);
//value := Agilent.RecvBufferStr(1000, 1000);
Memo1.Append('value: ' + IntToStr(Length(value)) + value + ' : ' + output);
Agilent.Free;
end;

procedure TForm1.Button7Click(Sender: TObject);
var a: integer;
    res: longint;

begin
    a := 24;
    res := Modbus.dec_to_bin(StrToInt('$' + IntToStr(a)));
    Memo1.Append(IntToStr(res));
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

procedure TForm1.DataPortTCP1Close(Sender: TObject);
begin

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
 StringGrid1.Cells[_PGA_,0] := 'PGA';
 StringGrid1.Cells[_SPS_,0] := 'SPS';
 StringGrid1.Cells[7,0] := 'FIR';
 StringGrid1.Cells[8,0] := 'RunTime';
 StringGrid1.Cells[9,0] := 'Error Counter';
 StringGrid1.ColWidths[9] := 100;
 StringGrid1.Cells[10,0] := 'Temp';
 StringGrid1.Cells[11,0] := 'Version';
 StringGrid1.ColWidths[11] := 200;

end;



procedure TForm1.MenuItem10Click(Sender: TObject);
begin
 Form2.Show;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  Form4.Show;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
var
f: text;
s, tmp: string;
i, j : integer;
begin
  //Сохранение поверочной таблицы поиска ПЛАТ
   SaveDialog1.Filter:='*.txt|*.txt';
   tmp := Modbus.replace(DateTimeToStr(NOW), ' ', '_');
   tmp := Modbus.replace(DateTimeToStr(NOW), ':', '');
   SaveDialog1.FileName:='TAB1_' + tmp;
   if SaveDialog1.Execute then
   begin
    s:=SaveDialog1.FileName;//берем имя файла
    assignfile(f,s);//связываем имя переменной с файлом
    rewrite(f);//открываем фвйл для записи//записываем массив в файл
    for i:=0 to StringGrid1.RowCount - 1 do
        begin
        for j:=0 to StringGrid1.ColCount - 1 do
           write(f, StringGrid1.Cells[j, i] + #9); // #9 - символ табуляции
        writeln(f, '');
        end;
    closefile(f);
   end;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
var i, min, max, index: integer;
  addr, cmd, stringToSend, response : string; //адрес платы HEX
begin
  //поиск Модулей
  Modbus.port := 'COM2'; //увести в настройки при инициализации
  min:= Modbus.minAddr;
  max:= Modbus.maxAddr;
  Label1.Caption:=IntToStr(min);

  ProgressBar1.Min := min;
  ProgressBar1.Max := max;
  index:=0;
  for i:= min to max do

      begin
          addr := IntToHex(i, 2);
          ProgressBar1.Position := i;
          Label1.Caption := IntToStr(i); //выводит поиск платы
          Form1.Refresh;

          cmd := addr + ' 03 a7 80 00 05 de ad';   //что это за команда на плату? - чтение -
          stringToSend := Modbus.StrToHexStr(cmd);
          response := Modbus.send(stringToSend);
          if (Modbus.portStatus <> 'OK')
             then
                 begin
              //   Memo1.Append(Modbus.portStatus);
                 end
             else
                 begin
                     Memo1.Append(response);
                     index += 1;
                     Modbus.units := index; //количество объектов равно
                     //работа по созданию объектов ADC
                     SetLength(ADC, index);
                     ADC[index - 1] := TADC.Create;
                     ADC[index - 1].Address:=i; //десятичный адрес (для использования требуется преобразование в HEX)
                     ADC[index - 1].selected := True;
                     StringGrid1.RowCount := index + 1;
                     StringGrid1.Cells[0, index] := IntToStr(index);
                     StringGrid1.Cells[2, index] := IntToStr(i); //Addr;
                     StringGrid1.Objects[1, index]:=TCheckBox.Create(StringGrid1);
                     TCheckBox(StringGrid1.Objects[1, index]).Parent:=StringGrid1;
                     TCheckBox(StringGrid1.Objects[1, index]).Left := StringGrid1.CellRect(1, index).Left + 15;
                     TCheckBox(StringGrid1.Objects[1, index]).Top := StringGrid1.CellRect(1, index).Top;
                     TCheckBox(StringGrid1.Objects[1, index]).Checked:= True;

                     //чтение времени наработки платы
                     cmd := Modbus.cmd(addr, 'getRunningTime', '');
                     Memo1.Append(cmd);
                     stringToSend := Modbus.StrToHexStr(cmd);
                     response := Modbus.send(stringToSend);
                     Memo1.Append(response);
                     ADC[index - 1].Runtime := Modbus.RRRuningTime(response);
                     StringGrid1.Cells[8, index] := IntToStr(Modbus.RRRuningTime(response));

                     //версия платы
                     cmd := Modbus.cmd(addr, 'getVersion', '');
                     Memo1.Append(cmd);
                     stringToSend := Modbus.StrToHexStr(cmd);
                     response := Modbus.send(stringToSend);
                     Memo1.Append(response);
                     StringGrid1.Cells[11, index] := Modbus.RRVersion(response);

                     //тип кабеля
                     cmd := Modbus.cmd(addr, 'getConnectionType', '');
                     Memo1.Append(cmd);
                     stringToSend := Modbus.StrToHexStr(cmd);
                     response := Modbus.send(stringToSend);
                     Memo1.Append(response);
                     StringGrid1.Cells[4, index] := Modbus.RRConnectionType(response);
                      //Температура
                     cmd := Modbus.cmd(addr, 'getTemperature', '');
                     Memo1.Append(cmd);
                     stringToSend := Modbus.StrToHexStr(cmd);
                     response := Modbus.send(stringToSend);
                     Memo1.Append(response);
                     StringGrid1.Cells[10, index] := Modbus.RRTemperature(response);

                     //запрос по ошибке
                     cmd :=  Modbus.cmd(IntToHex(cardAddr, 2), 'getErrors', '');
                     Memo1.Append(cmd);
                     stringToSend := Modbus.StrToHexStr(cmd);
                     response := Modbus.send(stringToSend);
                     Memo1.Append(response);
                     StringGrid1.Cells[9, index] := '$' + Modbus.RRErrors(response);

                     //Запрос по ADS
                     cmd := Modbus.cmd(addr, 'getADS', '');
                     Memo1.Append(cmd);
                     stringToSend := Modbus.StrToHexStr(cmd);
                     response := Modbus.send(stringToSend);
                     Memo1.Append(response);
                     //печать ответов
                     Modbus.RRAds(response);
                     //PGA
                     Memo1.Append(Modbus.tempWord);
                     Memo1.Append('ans PGA: ' + Modbus.tempWordPGA);

                     StringGrid1.Cells[_PGA_, index] := IntToStr(Modbus.trPGA(Modbus.PGA));
                     StringGrid1.Cells[_SPS_, index] := FloatToStr(Modbus.trSPS(Modbus.SPS));

                 end


      end;
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

procedure TForm1.StringGrid1Click(Sender: TObject);
var row, col: integer;
  res: string;
begin
  res := '';
  row := StringGrid1.Row;
  col := StringGrid1.Col;
  if ((row > 0) and (col = 1)) then
          if TCheckBox(StringGrid1.Objects[col, row]).Checked
          then res := 'checked'
          else res := 'non';
  if ((row > 0) and (col = 9)) then
     begin
       //read errors and reset error function
       Form3.getAddr(StrToInt(StringGrid1.cells[2, row]));

       Form3.show;
     end;
  Memo1.Append(res);
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

