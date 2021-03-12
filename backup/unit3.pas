unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, core;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure getAddr(addr: integer);
  private

  public
    cardAddr: integer; //адрес модуля для которого в данный момент работает форма
  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.getAddr(addr: integer);
begin
           cardAddr:= addr;
           Label2.Caption:=IntToStr(cardAddr);
end;

procedure TForm3.Button1Click(Sender: TObject);
var cmd, stringToSend, response: string;

begin
  //reset button
   cmd := Modbus.cmd(IntToHex(cardAddr, 2), 'resetErrors', '');
  stringToSend := Modbus.StrToHexStr(cmd);
  response := Modbus.send(stringToSend);
           if (Modbus.portStatus <> 'OK')
             then
                 begin
                    Memo1.Append(Modbus.portStatus);
                 end
             else
                 begin
                     Memo1.Append(response);


                 end;
end;

procedure TForm3.Button2Click(Sender: TObject);
var cmd, stringToSend, response: string;
   tmp: string;
   tmp0:Longint;
   i: integer;
   flag : boolean;
   msg: string;
function getIndex(t: Longint; index: integer):boolean;
           var res: integer;
            begin
               res:= round(t/EXP(index*LN(10))) - round(t/EXP((index+1)*LN(10)))*10;
               if (res = 1) then Result:=True else Result:=False;

            end;
begin

  cmd := Modbus.cmd(IntToHex(cardAddr, 2), 'getErrors', '');
  stringToSend := Modbus.StrToHexStr(cmd);
  response := Modbus.send(stringToSend);
  if (Modbus.portStatus <> 'OK')
    then
    begin
        Memo1.Append(Modbus.portStatus);
    end
    else
    begin
     Memo1.Append(response);
     tmp:=Copy(Modbus.replace(response, ' ', ''), 3*2 + 1, 2);
     tmp0:=Modbus.dec_to_bin(StrToInt('$' + tmp));
     for i:=0 to 7 do
     begin
     flag:= getIndex(tmp0, i);
     tmp:=IntToStr(tmp0);
     if (flag) then
     begin
     case i + 8 of
          8: msg := 'Бит 8 - зафиксирована перезагрузка АЦП';
          9: msg := 'Бит 9 - зафиксировано отклонение питающего напряжения датчика от номинала';
          10: msg := 'Бит 10';
          11: msg := 'Бит 11';
          12: msg := 'Бит 12';
          13: msg := 'Бит 13';
          14: msg := 'Бит 14';
          15: msg := 'Бит 15';


     end;
     Memo1.Append(msg);
     end;

      //является ли нужный байт взведенным
     Memo1.Append(tmp);
     tmp:=Copy(Modbus.replace(response, ' ', ''), 4*2 + 1, 2);
     tmp0 := Modbus.dec_to_bin(StrToInt('$' + tmp));
     for i:=0 to 7 do
     begin
     flag:= getIndex(tmp0, i);
     tmp:=IntToStr(tmp0);
     if (flag) then
     begin
     case i of
          0: msg := 'Бит 0 - сброс по внутренней защите памяти';
          1: msg := 'Бит 1 - сброс по байту конфигурации контроллера';
          2: msg := 'Бит 2 - сброс по аппаратному ресету (на ноге микроконтроллера)';
          3: msg := 'Бит 3 – низкое напряжение питания при работе в обычном режиме.';
          4: msg := 'Бит 4 – произошел программный сброс.';
          5: msg := 'Бит 5 - произошел сброс по независимому (другому) вачдог-таймеру';
          6: msg := 'Бит 6 – произошел сброс по вачдог-таймеру ';
          7: msg := 'Бит 7 – низкое напряжения питания при работе в спецрежимах.';


     end;
     Memo1.Append(msg);
     end;

     end;
     Memo1.Append(tmp);
     end;
end;

end.

