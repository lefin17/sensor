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
  strutils, dateutils, mathcore,
  uservarsload,
  blcksock;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
 //   DataPortSerial1: TDataPortSerial;
// Serial: TBlockSerial;
    EditDevice: TEdit;
    Label1: TLabel;
    MenuItem11: TMenuItem;
    MenuItem2: TMenuItem;
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
    Checkbox1 : TCheckbox;
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure getSelectedADC(); //берем какие нажатые галочки на плате и присваиваем объекту если всё в порядке...
    //нажатие на checkbox
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure CheckBox1OnChange(Sender: TObject);
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
    procedure MenuItem11Click(Sender: TObject);
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
  _FILTER_ = 7; //столбец в таблице с применяемым фильтром
  _FIRLEN_ = 8; //длина фильтра
  _TEMP_ = 11;   //температура
  _VERSION_ = 12; //версия
  _RUNTIME_ = 9; //время наработки платы
  _ERR_ = 10; // ошибки с платы
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
  Form2.Show;

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
// Modbus.port := 'COM2'; //удалить на настройки

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

// Agilent.SendString(Agil.getCommand('CURR:DC:NPLC 10' + #10));  //NPLC
// Memo1.Append('NPLC: ' + IntToStr(Agilent.LastError));

Agilent.SendString(Agil.getCommand('INITiate' + #10));  //Включить ожидание запуска
Memo1.Append(IntToStr(Agilent.LastError));



//'CURR:DC:NPLC 100 ' + #10)

Agilent.SendString(Agil.getCommand('*TRG'  + #10));
Memo1.Append(IntToStr(Agilent.LastError));
 sleep(1000);
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
 StringGrid1.Cells[_FILTER_,0] := 'FILTER';
 StringGrid1.Cells[_FIRLEN_, 0] := 'FIRLEN';
 StringGrid1.Cells[_RUNTIME_,0] := 'RunTime';
 StringGrid1.Cells[10,0] := 'Error Counter';
 StringGrid1.ColWidths[10] := 100;
 StringGrid1.Cells[_TEMP_,0] := 'Temp'; //11
 StringGrid1.Cells[_VERSION_,0] := 'Version'; //12
 StringGrid1.ColWidths[_VERSION_] := 200;

end;



procedure TForm1.MenuItem10Click(Sender: TObject);
begin
 Form2.Show;
end;

procedure TForm1.MenuItem11Click(Sender: TObject);
begin
  getSelectedADC(); //записать на ADC - кто из них будет в работе
  Form6.Show;
  //как-то по завершению применения пользовательских настроек - обновить данные в таблице
  //возможно вызовом функции применить из первого окна второй кнопкой (первая посмотреть) вторая - применить.. .
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  getSelectedADC(); //записать на ADC - кто из них будет в работе
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
   tmp := Modbus.replace(tmp, ':', '');
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

procedure TForm1.CheckBox1OnChange(Sender: TObject);
begin
  Memo1.Append('check box clicked');
end;

procedure TForm1.Button8Click(Sender: TObject);
var mnk: TMNK;
power: integer; //степень полинома
i : integer;
begin
  power := 2;
  mnk := TMNK.Create;
  mnk.test(power); //выделяем память под вектора
  mnk.Gram;  // (n,m,x,f,a); {считаем матрицу Грама}
  mnk.Gauss; // (m,a,c);;

  Memo1.Append('Коэффициенты полинома МНК ' +  IntToStr(power) + ' степени:');
 for i:=0 to power do Memo1.Append('c[' + IntToStr(i) + '] := ' + FloatToStr(mnk.c[i]));
  mnk.Free;
//  writeln;
end;

procedure TForm1.Button10Click(Sender: TObject);
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

Agilent := TTCPBlockSocket.Create;
//ms:=TMemoryStream.Create;
Agilent.Connect(Agil.ip, '5025');  //подключение к Agilent
Memo1.Append(IntToStr(Agilent.LastError));

Agilent.ConnectionTimeout:=1000; //TimeOut 1s (1000 ms)

//Agilent.SendString(Agil.getCommand('CURR:DC:NPLC 10' + #10));
//Memo1.Append(IntToStr(Agilent.LastError));


//# Настроить запуска измерения по команде '*TRG'
Agilent.SendString(Agil.getCommand('CURR:DC:NPLC?' + #10));
Memo1.Append('GET NPLC: ' + IntToStr(Agilent.LastError));


 sleep(2000);
// Agilent.SendString(Agil.getCommand('R?' + #10));
//Memo1.Append('Error after R command: ' + IntToStr(Agilent.LastError));

value := Agilent.RecvPacket(500);
//#
//Agilent.SendString(Agil.getCommand('FETCh?'  + #10)) ; //Передать измерение

// b := Agilent.RecvByte(1000);
// value := chr(b);
Memo1.Append('Error after byte recive: ' + IntToStr(Agilent.LastError));
// value := Agilent.RecvBufferStr(1000, 1000);

Memo1.Append(IntToStr(Length(value)) + ' value:' +  value + ': v');
  sleep(1000);

  Agilent.SendString(Agil.getCommand('TRIGger:SOURce BUS' + #10));
  Memo1.Append(IntToStr(Agilent.LastError));

Agilent.SendString(Agil.getCommand('*TRG'  + #10));
Memo1.Append(IntToStr(Agilent.LastError));
 sleep(1000);
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

procedure TForm1.Button11Click(Sender: TObject);

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
 Agilent := TTCPBlockSocket.Create;
 //ms:=TMemoryStream.Create;
 Agilent.Connect(Agil.ip, '5025');  //подключение к Agilent
 Memo1.Append(IntToStr(Agilent.LastError));

 Agilent.ConnectionTimeout:=1000; //TimeOut 1s (1000 ms)

Agilent.SendString(Agil.getCommand('CONFigure:VOLTage:DC AUTO' + #10));
Memo1.Append(IntToStr(Agilent.LastError));
Agilent.SendString(Agil.getCommand('VOLT:DC:NPLC 100' + #10));
Memo1.Append(IntToStr(Agilent.LastError));

//# Настроить запуска измерения по команде '*TRG'
Agilent.SendString(Agil.getCommand('TRIGger:SOURce BUS' + #10));
Memo1.Append(IntToStr(Agilent.LastError));

// Agilent.SendString(Agil.getCommand('CURR:DC:NPLC 10' + #10));  //NPLC
// Memo1.Append('NPLC: ' + IntToStr(Agilent.LastError));

Agilent.SendString(Agil.getCommand('INITiate' + #10));  //Включить ожидание запуска
Memo1.Append(IntToStr(Agilent.LastError));



//'CURR:DC:NPLC 100 ' + #10)

Agilent.SendString(Agil.getCommand('*TRG'  + #10));
Memo1.Append(IntToStr(Agilent.LastError));
 sleep(6000);
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

procedure TForm1.Button12Click(Sender: TObject);
var Len : integer;
    i: integer;
    addr: string;
    cmd: string;
    stringToSend: string;
    response: string;
begin
// записать текущие настройки плат в пользовательскую историю
//  Modbus.port := 'COM2'; //увести в настройки при инициализации
  Len := LEngth(ADC);
  getSelectedADC();
  ProgressBar1.Min := 0;
  ProgressBar1.Max := Len - 1;
  if (Len = 0) then exit; //ничего не делаем
  for i:= 0 to Len - 1 do
      begin
          addr := IntToHex(ADC[i].Address, 2);
          ProgressBar1.Position := i;
          Label1.Caption := IntToStr(ADC[i].Address); //выводит поиск платы
          Form1.Refresh;
          //команда на запись в пользовательскую память
          if (not ADC[i].selected) then continue;

          cmd := Modbus.cmd(addr, 'setUSER_FIR_LENGTH', ADC[i].HEXFIRLen01); //для фильтра 01
          Memo1.Append('CMD SET USER LENGTH: ' + cmd);
          stringToSend := Modbus.StrToHexStr(cmd);
          response := Modbus.send(stringToSend);
          Memo1.Append('SET USER LEN F01 R*: ' + response);

          cmd := Modbus.cmd(addr, 'setUSER_FIR_LENGTH', ADC[i].HEXFIRLen00); //для фильтра 01
          Memo1.Append('CMD SET USER LENGTH: ' + cmd);
          stringToSend := Modbus.StrToHexStr(cmd);
          response := Modbus.send(stringToSend);
          Memo1.Append('SET USER LEN F00 R*: ' + response);

          cmd := Modbus.cmd(addr, 'setUSER_SPS_FILTER', ADC[i].HEXSPS);
          Memo1.Append('S*:' + cmd);
          stringToSend := Modbus.StrToHexStr(cmd);
          response := Modbus.send(stringToSend);
          Memo1.Append('A*: ' + IntToStr(ADC[i].Address) + ' SET USER FILTER + SPS R*: ' +  response);
      end;



end;

procedure TForm1.getSelectedADC();
var i:integer;
    len: integer;
begin

     len := Length(ADC);
     if (len = 0) then exit;

     for i:=0 to len - 1 do
          if (StringGrid1.RowCount > i) then
                 ADC[i].selected := TCheckBox(StringGrid1.Objects[1, i+1]).Checked;

//проверка галочек в таблице

end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin

end;

procedure TForm1.Button15Click(Sender: TObject);
var setLength: integer;
    qint, cmd: string; //ключ длины и команда
    stringToSend: string; //комманда которая будет послана на плату
    response: string; //ответ от платы
    len: integer;
    i: integer;
    addr: string; //адрес платы HEX
begin
   //запись длины филтра
   //Modbus.port := 'COM2'; //заменить на настройки
   len := Length(ADC);
   setLength := StrToInt(ComboBox3.Items[ComboBox3.ItemIndex]) - 1; //текущая длина
   getSelectedADC();
   if (len = 0) then exit;
   for i:= 0 to len - 1 do
       begin
          if (not ADC[i].selected) then continue;
          addr := IntToHex(ADC[i].Address, 2);

          cmd := Modbus.cmd(addr, 'setNORM', ''); //режим норм
          Memo1.Append(cmd);
          stringToSend := Modbus.StrToHexStr(cmd);
          response := Modbus.send(stringToSend);
          Memo1.Append(response);

          Modbus.DecToQ(16, setLength, qint);
          while (Length(qint) < 4) do qint := '0' + qint;
          StringGrid1.Cells[_FIRLEN_, i + 1]:= IntToStr(setLength + 1);
          cmd := Modbus.cmd(addr, 'setFIR_LENGTH', '01 ' + qint); //для фильтра 01
          ADC[i].HEXFIRLen01:='01 00 01 02 ' + qint; // ## номер фильтра, число регистров, число байт, значение
          ADC[i].HEXFIRLen00:='00 00 01 02 ' + qint; // ## номер фильтра, число регистров, число байт, значение
          Memo1.Append('CMD SET LENGTH: ' + cmd);
          stringToSend := Modbus.StrToHexStr(cmd);
          response := Modbus.send(stringToSend);
          Memo1.Append('SET LEN R*: ' + response);
       end;
end;

procedure TForm1.Button16Click(Sender: TObject);
var len, i: integer;
    cmd, response, stringToSend, settings: string;
    addr: string;
    a, b, qint : string;
    ulen: integer;
begin
   len := length(ADC);
   //инициализируем работу с отмеченными платами
   getSelectedADC();
   progressBar1.Min := 0;
   progressBar1.Max := len * 5;

   for i:= 0 to len - 1 do
       begin
       //если не выбрана плата пропускаем

       if (not ADC[i].selected) then continue;
       //переводим в режим NORM
       Label1.Caption := IntToStr(ADC[i].Address);
       addr := IntToHEX(ADC[i].Address, 2);
          cmd := Modbus.cmd(addr, 'setNORM', '');
          Memo1.Append(cmd);
          stringToSend := Modbus.StrToHexStr(cmd);
          response := Modbus.send(stringToSend);
          Memo1.Append(response);
          ProgressBar1.Position:=i*5 + 1; Form1.Refresh;
       //читаем пользовательскую память по SPS
         cmd := Modbus.cmd(addr, 'getUserADS', '');
         Memo1.Append('gU-ADS C*:' + cmd);
         stringToSend := Modbus.StrToHexStr(cmd);
         response := Modbus.send(stringToSend);
         Modbus.USER_RRAds(response);
         //отладка
         Memo1.Append('gU-ADS R*:' + response);
         Memo1.Append('A*U_SPS:' + IntToStr(Modbus.USER_SPS));
         Memo1.Append('A* U_Filter:' + IntToStr(Modbus.USER_Filter));
         ProgressBar1.Position:=i*5 + 2; Form1.Refresh;
       //записываем в рабочую область
         a:= FloatToStr(modbus.trSPS(Modbus.USER_SPS));
         b:= modbus.trFilter(Modbus.User_Filter);
         settings := Modbus.trSPS_FILTER(a, b);
         Memo1.Append(settings);

         cmd := Modbus.cmd(addr, 'setSPS_FILTER', settings);
         Memo1.Append(cmd);
         stringToSend := Modbus.StrToHexStr(cmd);
         response := Modbus.send(stringToSend);
         Memo1.Append('SET FILTER + SPS R*: ' +  response);
         //записываем в таблицу результатов
         StringGrid1.Cells[_SPS_, i + 1] := a;
         StringGrid1.Cells[_Filter_, i + 1] := b;
         //записываем в таблицу результатов
         ProgressBar1.Position:=i*5 + 3; Form1.Refresh;

         //по длине фильтра
         cmd := Modbus.cmd(IntToHEX(ADC[i].Address, 2), 'getUSER_FIRLEN', '');
         Memo1.Append('gU-FL C*:' + cmd);
         stringToSend := Modbus.StrToHexStr(cmd);
         response := Modbus.send(stringToSend);
         MEMO1.Append('gU-FL R*:' + response);
         ulen := Modbus.USER_RRFirLen(response) - 1;
         Memo1.Append(IntToStr(ulen));
         ProgressBar1.Position:=(i*5 + 4); Form1.Refresh;

         Modbus.DecToQ(16, ulen, qint);
          while (Length(qint) < 4) do qint := '0' + qint;
          StringGrid1.Cells[_FIRLEN_, i + 1]:= IntToStr(ulen + 1);
          cmd := Modbus.cmd(addr, 'setFIR_LENGTH', '01 ' + qint); //для фильтра 01
          ADC[i].HEXFIRLen01:='01 00 01 02 ' + qint; // ## номер фильтра, число регистров, число байт, значение
          ADC[i].HEXFIRLen00:='00 00 01 02 ' + qint; // ## номер фильтра, число регистров, число байт, значение
          Memo1.Append('CMD SET LENGTH: ' + cmd);
          stringToSend := Modbus.StrToHexStr(cmd);
          response := Modbus.send(stringToSend);
          Memo1.Append('SET LEN R*: ' + response);

       end;
     progressBar1.Position := ProgressBar1.Max;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
var len, i: integer;
begin
len:= Length(ADC);
for i:= 0 to len - 1 do
    TCheckBox(StringGrid1.Objects[1, i + 1]).Checked:= CheckBox1.Checked;
end;

procedure TForm1.ComboBox2Change(Sender: TObject);
begin
    //запись в рабочие настройки значений FIR + SPS

end;

procedure TForm1.ComboBox3Change(Sender: TObject);
begin

end;

procedure TForm1.Button13Click(Sender: TObject);
var filter: string;
    sps: string;
    cmd: string;  //команда на запись в устройство
    response: string; //ответ от платы
    len: integer;  //количество плат
    addr: string; //адрес устройства
    settings : string;
    i: integer;
    stringToSend: string;
begin
  //запись в рабочие настройки значений FIR + SPS
  // Modbus.port := 'COM2'; //заменить на настройки
   len := Length(ADC);

   getSelectedADC();
   if (len = 0) then exit;
   for i:= 0 to len - 1 do
       begin
          if (not ADC[i].selected) then continue;
          addr := IntToHex(ADC[i].Address, 2);

          sps := ComboBox1.Items[ComboBox1.ItemIndex];
          filter := ComboBox2.Items[ComboBox2.ItemIndex];

          StringGrid1.Cells[_SPS_, i + 1] := sps;
          StringGrid1.Cells[_FILTER_, i + 1] := filter;

          Memo1.Append('Addr' + IntToStr(ADC[i].Address) + ' SPS: ' + sps + ' FILTER: ' + filter);
          settings := Modbus.trSPS_FILTER(sps, filter);
          Memo1.Append(settings);
          //собираем байт
          if (Length(settings) = 1) then settings := '0' + settings; //добавление до полного слова

          ADC[i].HEXSPS := settings; //то что нужно написать
          cmd := Modbus.cmd(addr, 'setNORM', '');
          Memo1.Append(cmd);
          stringToSend := Modbus.StrToHexStr(cmd);
          response := Modbus.send(stringToSend);
          Memo1.Append(response);

          cmd := Modbus.cmd(addr, 'setSPS_FILTER', settings);
          Memo1.Append(cmd);
          stringToSend := Modbus.StrToHexStr(cmd);
          response := Modbus.send(stringToSend);
          Memo1.Append('SET FILTER + SPS R*: ' +  response);
       end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var len: integer;
i: integer;
begin
  //тест
   len := Length(ADC);
   for i:= 0 to len - 1 do
      MEMO1.Append('i: ' + IntToStr(ADC[i].Address));
end;

procedure TForm1.Button9Click(Sender: TObject);
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

Agilent := TTCPBlockSocket.Create;
//ms:=TMemoryStream.Create;
Agilent.Connect(Agil.ip, '5025');  //подключение к Agilent
Memo1.Append(IntToStr(Agilent.LastError));

Agilent.ConnectionTimeout:=10000; //TimeOut 1s (1000 ms)

Agilent.SendString(Agil.getCommand('VOLT:DC:NPLC 0.2' + #10));
Memo1.Append(IntToStr(Agilent.LastError));


//# Настроить запуска измерения по команде '*TRG'
Agilent.SendString(Agil.getCommand('VOLT:DC:NPLC?' + #10));
Memo1.Append(IntToStr(Agilent.LastError));


 sleep(2000);
// Agilent.SendString(Agil.getCommand('R?' + #10));
//Memo1.Append('Error after R command: ' + IntToStr(Agilent.LastError));

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

procedure TForm1.MenuItem6Click(Sender: TObject);
var i, min, max, index: integer;
  addr, cmd, stringToSend, response : string; //адрес платы HEX
begin
  //поиск Модулей
//  Modbus.port := 'COM2'; //увести в настройки при инициализации
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
                     StringGrid1.Objects[1, index]:= TCheckBox.Create(StringGrid1);
                     TCheckBox(StringGrid1.Objects[1, index]).Parent:=StringGrid1;
                     TCheckBox(StringGrid1.Objects[1, index]).Left := StringGrid1.CellRect(1, index).Left + 15;
                     TCheckBox(StringGrid1.Objects[1, index]).Top := StringGrid1.CellRect(1, index).Top;
                     TCheckBox(StringGrid1.Objects[1, index]).Checked:= True;

                   //  TCheckBox(StringGrid1.Objects[1, index]).onChange := TForm1.CheckBox1onChange(StringGrid1);
                   //перевод в режим norm
                   cmd := Modbus.cmd(addr, 'setNORM', '');
                   Memo1.Append(cmd);
                   stringToSend := Modbus.StrToHexStr(cmd);
                   response := Modbus.send(stringToSend);
                   Memo1.Append(response);
                     //чтение времени наработки платы
                     cmd := Modbus.cmd(addr, 'getRunningTime', '');
                     Memo1.Append(cmd);
                     stringToSend := Modbus.StrToHexStr(cmd);
                     response := Modbus.send(stringToSend);
                     Memo1.Append(response);
                     ADC[index - 1].Runtime := Modbus.RRRuningTime(response);
                     StringGrid1.Cells[_RUNTIME_, index] := IntToStr(Modbus.RRRuningTime(response));

                     //версия платы
                     cmd := Modbus.cmd(addr, 'getVersion', '');
                     Memo1.Append(cmd);
                     stringToSend := Modbus.StrToHexStr(cmd);
                     response := Modbus.send(stringToSend);
                     Memo1.Append(response);
                     StringGrid1.Cells[_VERSION_, index] := Modbus.RRVersion(response);

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
                     StringGrid1.Cells[_TEMP_, index] := Modbus.RRTemperature(response);

                     //запрос по ошибке
                     cmd :=  Modbus.cmd(addr, 'getErrors', '');
                     Memo1.Append('getErrors command: ' + cmd);
                     stringToSend := Modbus.StrToHexStr(cmd);
                     response := Modbus.send(stringToSend);
                     Memo1.Append('getErrors response:' + response);
                     StringGrid1.Cells[_ERR_, index] := '$' + Modbus.RRErrors(response);

                     //запрос по Серийному номеру
                     cmd :=  Modbus.cmd(addr, 'getSerial', '');
                     Memo1.Append('getSerial command: ' + cmd);
                     stringToSend := Modbus.StrToHexStr(cmd);
                     response := Modbus.send(stringToSend);
                     Memo1.Append('getSerial response: ' + response);
                     StringGrid1.Cells[3, index] := Modbus.RRSerial(response);

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
                     ADC[index - 1].HEXSPS := Modbus.HEXSPS; //то что получаем с SPS
                     StringGrid1.Cells[_PGA_, index] := IntToStr(Modbus.trPGA(Modbus.PGA));
                     StringGrid1.Cells[_SPS_, index] := FloatToStr(Modbus.trSPS(Modbus.SPS));
                     StringGrid1.Cells[_FILTER_, index] := Modbus.trFilter(Modbus.Filter);
              //текущая длина фильтра
                     cmd := Modbus.cmd(addr, 'getFIRLEN', '');
                     Memo1.Append(cmd);
                     stringToSend := Modbus.StrToHexStr(cmd);
                     response := Modbus.send(stringToSend);
                     Memo1.Append('FIRLEN R*:' + response);
                     ADC[index - 1].FIRLength := StrToInt(Modbus.RRFirLen(response));
                     ADC[index - 1].HEXFIRLen01 := Modbus.HEXFIRLen01; //записываем для пользовательской записи
                     ADC[index - 1].HEXFIRLen00 := Modbus.HEXFIRLen00;
                     StringGrid1.Cells[_FIRLEN_, index] := Modbus.FirLenText;
                 end;

    //    if (length(ADC) > 0) then break;
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
  Application.terminate;
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
  if ((row > 0) and (col = _ERR_)) then
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

