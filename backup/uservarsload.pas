unit UserVarsLoad;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls,
  core; //ядро программы - modbus, ads, verification (калибровка)

type

  { TForm6 }

  TForm6 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    procedure Button1Click(Sender: TObject); //кнопка прочитать пользовательские настройки
    procedure ReadUserVars; //читать пользовательские настройки с плат (выбранных на UNIT 1)
    procedure ShowUserVars; //показать в текущей форме пользовательские настройки
  private
    tmpSPSstring: array of string; //то что нужно будет занести в текстовое значение по SPS + FILTER для каждой платы
    tmpSPS: array of double; //то что нужно занести в ADC при применении настроек
    tmpFIR: array of string; //то что нужно вывести в таблицу
    tmpCoef: array of array of double; //то что выводить по коэффициентам полинома
  public

  end;

var
  Form6: TForm6;

implementation

{$R *.lfm}

{ TForm6 }


procedure TForm6.ReadUserVars;
var i, j: integer;
    modules: integer;
    cmd, stringToSend, response, res: string;
begin
  //цикл по активным платам
  modules := Length(ADC);
  if (modules = 0) then exit;

  SetLength(tmpSPSstring, modules); //ставим значение SPS равным количеству модулей
  SetLength(tmpCoef, modules); //инициализация временных коэффициентов прочтенных с платы

  for i := 0 to modules - 1 do
      begin
         SetLength(tmpCoef[i], 8); //восемь коэффициентов полинома..
        //чтение пользовательских настроек и коэффициентов
              if (not ADC[i].selected) then continue; //если плата не выбрана в главной части - не трогаем - проверка перед запуском формы
         cmd := Modbus.cmd(IntToHEX(ADC[i].Address, 2), 'getUserADS', '');
         Memo1.Append('gU-ADS C*:' + cmd);
         stringToSend := Modbus.StrToHexStr(cmd);
         response := Modbus.send(stringToSend);
         Modbus.USER_RRAds(response);
         Memo1.Append('gU-ADS R*:' + response);
         Memo1.Append('A*U_SPS:' + IntToStr(Modbus.USER_SPS));
         Memo1.Append('A* U_Filter:' + IntToStr(Modbus.USER_Filter));
        //
      end;
end;

procedure ShowUserVars;
   begin
     //показать в текущей таблице полученные значения
   end;

procedure TForm6.Button1Click(Sender: TObject);
begin
  ReadUserVars;
  //отображение
  ShowUserVars;
end;

end.

