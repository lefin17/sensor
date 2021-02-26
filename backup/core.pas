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
    function cmd(addr, mode, command, param: string):string;
    function Send(data: string): string;
  end;

type TVerification = Object
     N: integer; //число точек поверки на все модули
     end;

var
   Modbus: TModbus;    //работа с Com и шиной Modbus
   Verification: TVerification;  //объект по работе с поверкой модулей

implementation


function TModbus.cmd(addr, mode, command, param: string):string;
var
   res : string;
begin
 //библиотека комманд к контроллеру по заданному адресу - без выполнения и HEX подготовки
 res := addr + ' ' + mode;
     case command of
     'temp': res := 'AA BB';
     end;
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
  PortStatus := 'OK';
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

