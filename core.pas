unit core;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dateutils, strutils, LazSynaSer;

type
  TModbus = class
    fromAddress: integer; //адрес с которого проходит поиск по шине
    units: integer;  //число найденых объектов
    items: array[0..256] of byte; //массив объектов найденых на шине
    port: string; //номер порта
    speed: integer;
    minAddr: integer; //минимальный адрес для начала поиска на плате
    portStatus: string; //статус порта если не удалось подключиться для отображения
    function replace(text, s_old, s_new: string):string; //подготовка строки к преобразованию
    function StrToHexStr(SHex: string):string;
    function cmd(addr, command, param: string):string;
    function Send(data: string): string;
    function RRRuningTime(answer: string):integer; //определение времени наработки на отказ (RR -  Read Result)
    function RRVersion(answer: string):string; //определение версии программы
    function RRConnectionType(answer: string):string;
    function RRTemperature(answer: string):string; //чтение температуры
  end;

type TAgilent = class
     ip: string;
     function getCommand(cmd: string):string;
     end;

type TVerification = Object
     N: integer; //число точек поверки на все модули
     end;

var
   Modbus: TModbus;    //работа с Com и шиной Modbus
   Verification: TVerification;  //объект по работе с поверкой модулей
   Agil: TAgilent;

implementation

function TAgilent.getCommand(cmd: string):string;
var
clientBuffer: array of Byte;
I: integer;
output: string;
begin
  clientBuffer := TEncoding.UTF8.GetBytes(cmd);
I := 0;
output := '';
  while (I <= High(clientBuffer)) do
  begin
    output := output + chr(clientBuffer[I]);
    Inc(I);
  end;
  Result := output;
end;

function TModbus.RRVersion(answer: string):string;
var res: string;
   str, version : string;
   H, Y, m, d, i, s: string;
begin
   str:=replace(answer, ' ', '');
   if (Length(str)<14) then
      begin
           res := '0';
           Exit; //ошибка чтения ответа
      end;
   version := 'Ver: ' + Copy(str, 21, 2);

   Y := copy(str, 3 * 2 + 1, 4); //год выпуска платы
   m := copy(str, 5 * 2 + 1, 2); //месяц выпуска
   d := copy(str, 6 * 2 + 1, 2); //день выпуска платы
   s := copy(str, 9 * 2 + 1, 2); //время в секундах сборки платы
   i := copy(str, 8 * 2 + 1, 2); //время в минутах
   H := copy(str, 7 * 2 + 1, 2); //время в часах
   res := version + ' inst: ' + Y + '-' + m + '-' + d + ' ' + H + ':' + i + ':' + s;
     Result := res;
end;

function TModbus.RRRuningTime(answer: string):integer;
var i, res: integer;
   str, s : string;

begin
   str:=replace(answer, ' ', '');
   if (Length(str)<14) then
      begin
           res := 0;
           Exit; //ошибка чтения ответа
      end;
   s := '';
   for i:= 6 downto 3 do
     s += Copy(str, i * 2 + 1, 2);
     val('$' + s, res, i);
        if (i <> 0) then res := 0;
     Result := res;
end;

function TModbus.RRConnectionType(answer: string):string;
//определение типа кабеля подключения
var i: integer;
   res, str, s : string;

begin
   str:=replace(answer, ' ', '');
   if (Length(str)<8) then
      begin
           res := '0';
           Exit; //ошибка чтения ответа
      end;
   s := Copy(str, 3 * 2 + 1, 4);
   res := 'UNDEF';
   case s of
     '5001' : res := 'IDT1';
     '5002' : res := 'IDT2';
     '5003' : res := 'IDT3';
     '5004' : res := 'IDT4';
     'FFFF' : res := 'UNKNOWN';
     end;
     Result := res;
end;

function TModbus.RRTemperature(answer: string):string;
//определение температуры АЦП
var i: integer;
    d: Extended;
   res, str, s, s1 : string;

begin
   str:=replace(answer, ' ', '');
   if (Length(str)<8) then
      begin
           res := '0';
           Exit; //ошибка чтения ответа
      end;
   s := Copy(str, 7 * 2 + 1, 8);
   s1 := Copy(str, 11 * 2 + 1, 4);
   d := StrToFloat(s + ',' + s1);
   res := FloatToStr((d - 122400) / 420 + 25);
   res := Copy(res, 0, 5);
   Result := res;
end;


function TModbus.cmd(addr, command, param: string):string;
var
   res : string;
begin
 //библиотека комманд к контроллеру по заданному адресу - без выполнения и HEX подготовки
 res := addr;
     case command of
     'temp': res := 'AA BB';
     'getRunningTime': res += ' 03 01 C0 00 02';   //время наработки на отказ
     'getVersion': res += ' 03 02 00 00 04'; //запрос на чтение версии ПО и времени сборки
     'getConnectionType': res += ' 03 11 00 00 01';
     'getTemperature': res += ' 03 AB B0 00 05'; //температура АЦП
     end;
     res += ' DE AD'; //конец слова команды
     Result := res;
end;

function TModbus.replace(text, s_old, s_new: string):string;
var
    s: string;
    i, l_old: byte;
begin
    s := text;
    l_old := length(s_old);
    i := 1;
    while i <> 0 do begin
        i := pos(s_old, s);
        if i <> 0 then begin
            delete(s, i, l_old);
            insert(s_new, s, i);
        end;
    end;
    Result := s;
end;

function TModbus.StrToHexStr(SHex: string):string;
var
 Buf: array of Byte;
// SHex: String;
 I, Len: Integer;
 output: string;
begin
 output := '';
 SHex := replace(SHex, ' ', '');
 // SHex := "6D 6F 75 73 65";
 Len := Length(SHex);
 if (Len > 0) and (Len mod 2 = 0) then
 begin
   SetLength(Buf, Len div 2);
   I := 0;
   while (I <= High(Buf)) do
   begin
     Buf[I] := StrToInt('$' + Copy(SHex, I * 2 + 1, 2));
     output := output + chr(Buf[I]);
     Inc(I)
   end;
 end;
 Result := output;
end;

function TModbus.send(data: string): string;
//function send(port: string; data: pointer; len: integer): string;
const
  recvTimeout = 200; // время ожидания ответа от устройства
var
  ComPort: TBlockSerial;
  resp: Array of byte;
  i: byte;
  waiting: integer;
  dtStart: TDateTime;
  has_timed_out: boolean;
  output: string;

begin
  PortStatus := 'Empty';
  ComPort := TBlockSerial.Create;
  try
    ComPort.Connect(port);
    if ComPort.LastError > 0 then
    begin
      PortStatus := 'Couldn''t connect to port';
      Exit;
    end;
    ComPort.Config(115200, 8, 'N', SB1, false, false);
    if ComPort.LastError > 0 then
    begin
      PortStatus := 'Couldn''t connect to port';
      Exit;
    end;
   ComPort.SendString(data);
 //     ComPort.SendBuffer(data, len);
    if ComPort.LastError > 0 then
    begin
      PortStatus := 'No data to send';
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
        PortStatus := 'NO RESPONCE';
        break; // выход - в буфере ничего нет
      end;

      waiting := ComPort.WaitingData;
     // Memo1.Append('waiting: ' + IntToStr(waiting));
      SetLength(resp, waiting);

    for i := 0 to Length(resp) - 1 do
    begin
      resp[i] := ComPort.RecvByte(2000);
    end;

    if ComPort.LastError > 0 then
    begin
      PortStatus := 'ERROR Recieve data';
      Exit;
    end;
    end;

  finally
    ComPort.free;
  end;
//    Memo1.Append('Length of resp - ' + IntToStr(Length(resp)));
 output := '';
 if Length(resp)>0 then
 begin
  PortStatus:='OK';
 for i := 0 to Length (resp) - 1 do
  begin
    output += IntToHex(resp[i], 2) + ' ';  // Строка hex значений, разделённая пробелами
   // break;
  end; (* *)
 end;
 (* Delete(output, Length(output), 1);  // Удаление последнего пробела в строке *)

  Result := output;
end;

//end;



end.

