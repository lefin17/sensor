unit core;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dateutils, strutils, LazSynaSer,   blcksock;

type
  TBytes8 = array[0..7] of Byte; //для преобразования числел для платы

type
  TModbus = class
    fromAddress: integer; //адрес с которого проходит поиск по шине
    units: integer;  //число найденых объектов
    selectedUnits: integer; //число выбранных для поверки плат
    controlDots: integer; //число контрольных точек по напряжению
    controlDotsPerDot: integer; //число контрольных снятий каждой точки
    items: array[0..256] of byte; //массив объектов найденых на шине
    port: string; //номер порта
    speed: integer;
    tempWord: string; //пробная строка для отладки ответа
    tempWordPGA: string; //пробная строка для отладки ответа (PGA)

    SPS: integer; //частота чтения в битной сетке текущего адаптера, далее должно записываться в объект платы
    PGA: integer; //усилитель в битной сетке
    ByPass : integer; //включен ли обход усилителя на текущей плате (по которой идет опрос)
    Filter: integer; //фильтр в битной сетке
    ADSAnswer: string; //ответ по текущему ADS (системе АЦП на текущей плате)
    Voltage: double;  //напряжение (нужно учесть PGA)
    VoltageDeviation: double; //СКО среднеквадратичное отклонение //RRFir(0)
    minAddr: integer; //минимальный адрес для начала поиска на плате
    maxAddr: integer;
    portStatus: string; //статус порта если не удалось подключиться для отображения
    function replace(text, s_old, s_new: string):string; //подготовка строки к преобразованию
    function StrToHexStr(SHex: string):string;
    function Bytes2Double(a: TBytes8): Double; //преобразование байт в массив
    function Double2Bytes(d: Double): TBytes8;
    function cmd(addr, command, param: string):string;
    function Send(data: string): string;
    function RRRuningTime(answer: string):integer; //определение времени наработки на отказ (RR -  Read Result)
    function RRVersion(answer: string):string; //определение версии программы
    function RRConnectionType(answer: string):string;
    procedure RRAds(answer: string); //чтение ответа от ADS
    function RRFir(answer: string):string; //чтение данных на филтрах АЦП
    function RRTemperature(answer: string):string; //чтение температуры
    function RRErrors(answer: string):string; //чтение ошибок на плате
    function RRSerial(answer: string):string; //чтение серийного номера
    function dec_to_bin(dec: LongInt): LongInt; //перевод из DEC в BINARY(INT)
    function bin_to_dec(bin: LongInt): LongInt; //перевод из BINARY (INT) в DEC
    function trPGA(code: LongInt):integer;
    function trSPS(code: LongInt):Double;
  end;

type TAgilent = class
     ip: string;
     Voltage: double;
     LastResult : string;
     LastError: integer; //последняя ошибка - если была ошибка - не принимать
     function getCommand(cmd: string):string;
     procedure getVoltage();
     procedure getLastError(error: integer); //забираем последнюю ошибку с Agilent если пошло всё хорошо
     function replace(text, s_old, s_new: string):string; //подготовка строки к преобразованию
     end;

type TVerification = Object
     N: integer; //число точек поверки на все модули
     Power: integer; //степень полинома для функции восстановления
     CurrentV: Double; // текущее напряжение для задания на вольтметре
     currentIndex : integer; //текущий индекс чтения
     Vmin, Vmax: double; //от куда и до куда проводим эксперимент
     end;

type
  TADC = Class   //хранилище информации по платам
    Runtime: integer; { Время жизни платы в секундах }
    SPS: integer; //есть и коды для задачи
    Address: integer;//адрес устройства на шине
    selected: boolean; //выбрано ли устройство для работы с ним
    PGA: integer; //значение усилителя
    SerialNumber: string; //серийный номер объекта
    PolyPower: integer; //текущая степень полинома карты
    ErrorCounter: integer; //счетчик ошибок
    Errors: string; // ошибки нужно будет вывести таблицей в порядке возникновения
    virt: boolean; //режим виртуализации - если виртуальное - не посылать на объект и дать эхо ответ как будто живое устройство
    VerificationDots: array of double; //экспериментальные точки
    AgilDots: array of double; //точки по данному АЦП с Agilent'а
    VoltageDots: array of double; //точки по данному измерению с AЦП платы
    Coefs: array of double; //коэффициенты полинома функции восстановления
    function fi(power: integer; x1: Double):Double; //функция по восстановлению значения
  end;

var
   Modbus: TModbus;    //работа с Com и шиной Modbus
   Verification: TVerification;  //объект по работе с поверкой модулей
   Agil: TAgilent;
   ADC: array of TADC;

implementation

function TModbus.Double2Bytes(d: Double): TBytes8;
var
  r: TBytes8 absolute d;
begin
  Result := r;
end;

function TModbus.Bytes2Double(a: TBytes8): Double;
var
  r: Double absolute a;
begin
  Result := r;
end;

function TADC.fi(power: integer; x1: Double):Double;
{Аппроксимирующая функция по найденным коэффициентам МНК}
{power - степень полинома, Coefs - вектор коэффициентов,
 x1 - точка, в которой ищем значение}
var i:integer; p:Double;
begin
 fi:= 0;
 if (Length(Coefs) < power) then Exit; //не должно работать...  защита от переполнения
 p := Coefs[power];
 for i := power - 1 downto 0 do p := Coefs[i] + x1*p;
 fi:=p;
end;

procedure TAgilent.getLastError(error: integer);
begin
 if (error > LastError) then LastError := error; // не сбрасывается нулевой ошибкой
end;

function TAgilent.replace(text, s_old, s_new: string):string;
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

procedure TAgilent.getVoltage();
var Agilent: TTCPBlockSocket;
// ms: TMemoryStream;
value, cmd: string;
code: integer;
check : string;
var clientBuffer: array of byte;
I: integer;
output : string;
b: Byte;
begin
LastError := 0;
Agilent := TTCPBlockSocket.Create;
//что делать если нет на IP?
Agilent.Connect(ip, '5025');  //подключение к Agilent

getLastError(Agilent.LastError);

Agilent.ConnectionTimeout:=1000; //TimeOut 1s (1000 ms)
Agilent.SendString(Agil.getCommand('CONFigure:VOLTage:DC' + #10));
getLastError(Agilent.LastError);

Agilent.SendString(Agil.getCommand('VOLT:DC:NPLC 100' + #10));  //Включаем фильтр NPLC 100
getLastError(Agilent.LastError);

Agilent.SendString(Agil.getCommand('TRIGger:SOURce BUS' + #10));
getLastError(Agilent.LastError);

Agilent.SendString(Agil.getCommand('INITiate' + #10));  //Включить ожидание запуска
getLastError(Agilent.LastError);

(*
Syntax
[SENSe:]CURRent[:DC]:NPLC {<PLCs>|MIN|MAX|DEF}

[SENSe:]CURRent[:DC]:NPLC? [{MIN|MAX}]

Description
This command sets the integration time in number of power line cycles (PLCs) for dc current measurements. Integration time affects the measurement resolution (for better resolution, use a longer integration time) and measurement speed (for faster measurements, use a shorter integration time).
*)



Agilent.SendString(Agil.getCommand('*TRG'  + #10));
sleep(6000); //пауза нужна для попадания результата измерения в буфер обмена
Agilent.SendString(Agil.getCommand('R?' + #10));
getLastError(Agilent.LastError);

value := Agilent.RecvPacket(1000);
// LastResult := value;
check := Copy(value, 0, 4);
Voltage := -1;
value := replace(Copy(value, 5, 20), '.', ','); //функция зависит от региональных настроек
LastResult := value;


if (check = '#215') then
   begin
   Voltage := StrToFloat(value); //вырезаем кусок кода из ответа содержащего напряжение
   end;
Agilent.Free;
end;

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

function TModbus.trSPS(code: LongInt):Double;
var ans : Double;
begin
  case code of
       0: ans:=2.5;
       1: ans:= 5;
       10: ans:=10;
       11: ans:= 16.6;
       100: ans:=20;
       101: ans:= 50;
       110: ans:= 60;
       111: ans:=100;
       1000: ans:= 400;
       1001: ans:= 1200;
       1010: ans:= 2400;
       1011: ans:= 4800;
       1100: ans:= 7200;
       1101: ans:=14400;
       1110: ans:=19200;
       1111: ans:= 25600;
  end;
  if (code >= 10000) then ans := 40000;
  Result:=ans;
end;

function TModbus.trPGA(code: LongInt):integer;
//коэффициенты усиления PGA (Program Gain Amplifier)
var ans: integer;
begin
   case code of
      0: ans:= 1;
      1: ans:= 2;
      10: ans:= 4;
      11: ans:= 8;
      100: ans:= 16;
      101: ans:= 32;
      110: ans:= 64;
      111: ans:= 128;
   end;
 Result:= ans;
end;

procedure TModbus.RRAds(answer: string);
//чтение параметров системы АЦП на текущей плате
var res: string;
   i: integer;
   tmp : string;
   DR : LongInt; //DataRate
   FR : LongInt;
   str: string;
   word : string;
begin
   str:=replace(answer, ' ', '');
   if (Length(str)<14) then
      begin
           res := '0';
           Exit; //ошибка чтения ответа
      end;

   for i := 0 to 12 do
    begin
      word := copy(str, i * 4 + 9, 2);
 //     tempWord := answer + '-' + word;
    //  Exit;
      case i of
         2: begin
            DR:=round(dec_to_bin(StrToInt('$' + word))/EXP(3*LN(10)));
            FR:=round(dec_to_bin(StrToInt('$' + word))) - DR * 1000;
            SPS := DR;
            Filter := FR;
            tempWord := word;
         end;
         16: begin
           ByPass := round(dec_to_bin(StrToInt('$' + word))/EXP(7 * LN(10)));
           PGA:=round(dec_to_bin(StrToInt('$' + word))) - 1000000*ByPass;
           tempWordPGA := word;
         end;
      end;
    end;

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
//определение времени наработки в часах
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
     res := round(res / 60 /60); //время наработки платы в часах (целое число пока)
     Result := res;
end;

function TModbus.RRConnectionType(answer: string):string;
//определение типа кабеля подключения
var i: integer;
   res, str, s : string;

begin
   str:=replace(answer, ' ', '');
   if (Length(str)<8) then  //что-то типа защиты на не нулевой результат ответа от ПИ (Платы измерительной)
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

function TModbus.RRFir(answer: string):string;
//чтение ошибок на выбранной плате
var i: integer;
    d: Extended;
   res, str, s, s1 : string;
   b:LongInt;
   Vref : integer; //опорное напряжение
   Gain : integer;
begin
   Gain := 1;
   Vref := 5;
   str:=replace(answer, ' ', '');
   if (Length(str)<8) then
      begin
           res := '0';
           Exit; //ошибка чтения ответа
      end;
   //определение напряжение по ответу на FIR (IDT3 - 0 фильтр)
   s := Copy(str, 9, 6);
   b := StrToInt('$' + s);

   Voltage := Vref / (Gain * 8388608) * b;   // 2^23 = 8388608
   s1 := Copy(str, 15, 8);
   b := StrToInt('$' + s1);
   VoltageDeviation := Vref / (Gain * 8388608) * b;   //Отклонение которое выдаёт плата
   res := s;
   Result := res;
end;

function TModbus.RRErrors(answer: string):string;
//чтение ошибок на выбранной плате
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
   res := Copy(str, 3*2 + 1, 4);
   // res := 'чтение ошибок на плате';   //пока в модуле Unit3
   Result := res;
end;

function TModbus.RRSerial(answer: string):string;
//Чтение серийного номера - три блока с низким байом записи LSB
var i, j: integer;
    d: Extended;
   res, str, s, s1 : string;

begin
   str:=replace(answer, ' ', '');
   if (Length(str)<8) then
      begin
           res := '0';
           Exit; //ошибка чтения ответа
      end;
   res := '';
   for j := 0 to 2 do
       begin
       for i:= 3 downto 0 do
           res += Copy(str, 3*2 + (j * 4) + i*2 + 1, 2);
       res += ' ';
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
     'getSerial': res += '03 01 D0 00 06'; //серийный номер платы
     'getTemperature': res += ' 03 AB B0 00 05'; //температура АЦП
     'getErrors': res += ' 03 01 00 00 01'; //чтение ошибок
     'resetErrors': res += ' 06 01 00 00 00'; // сброс ошибок
     'setNORM': res += ' 06 10 00 00 00'; //перевод в режим NORM
     'setEXEC': res += ' 06 10 00 00 01'; //перевод в режим EXEC
     'getADS' : res += ' 03 0A 00 00 13'; //чтение всех настроек ADS
     'getADSFilters': res += ' 03 1D 00 00 20'; //Регистры данных КИХ Фильтров
     'putCoefs': res += '10' + param;
     'readCoefs': res += '03' + param; //сюда адрес + число регистов
     end;
     res += ' DE AD'; //конец слова команды
     Result := res;
end;


function TModbus.dec_to_bin(dec: longInt): longInt;
var
  bin, rank, modulo: longInt;
begin
  bin := 0;
  rank := 1;
  while dec > 0 do
  begin
    modulo := dec mod 2;
    dec := dec div 2;
    bin := bin + modulo * rank;
    rank := rank * 10;
  end;
  result := bin;
end;

function TModbus.bin_to_dec(bin: LongInt): LongInt;
var dec, two, rank: LongInt;
begin
  two := 1;
  dec := 0;
  while bin > 0 do
  begin
    rank := bin mod 10;
    bin := bin div 10;
    dec := dec + rank * two;
    two := two * 2;
  end;
  result := dec;
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

