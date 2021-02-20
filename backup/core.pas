unit core;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TModbus = class
    fromAddress: integer; //адрес с которого проходит поиск по шине
    units: integer;  //число найденых объектов
    items: array[0..256] of byte; //массив объектов найденых на шине
    port: string; //номер порта
    speed: integer;
    minAddr: integer; //минимальный адрес для начала поиска на плате
    function replace(text, s_old, s_new: string):string; //подготовка строки к преобразованию
    function StrToHexStr(SHex: string):string;
    function cmd(addr, mode, command, param: string):string;
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
     'temp': res:="AA BB";
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

end.

