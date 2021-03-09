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

                 end;
end;

end.

