unit UserVarsLoad;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls,
  ComCtrls, core; //ядро программы - modbus, ads, verification (калибровка)

type

  { TForm6 }

  TForm6 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    ProgressBar1: TProgressBar;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ShowCoefs(index: integer); //отображает коэффициенты полинома выбранного по таблице
    procedure Button1Click(Sender: TObject); //кнопка прочитать пользовательские настройки
    procedure ReadUserVars; //читать пользовательские настройки с плат (выбранных на UNIT 1)
    procedure ShowUserVars; //показать в текущей форме пользовательские настройки
    procedure StringGrid1Click(Sender: TObject);
  private
    tmpSPSstring: array of string; //то что нужно будет занести в текстовое значение по SPS + FILTER для каждой платы
    tmpSPS: array of integer; //то что нужно занести в ADC при применении настроек  (byte - int)
    tmpFIR: array of string; //то что нужно вывести в таблицу
    tmpFilter: array of integer;//настройки фильтра в побитной сетке
    tmpFirLen: array of integer; //длина фильтра
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
  SetLength(tmpSPS, modules); //задачем числом модулей, а загружать или нет - решает настройка..
  SetLength(tmpFilter, modules);
  SetLength(tmpFirLen, modules);
  ProgressBar1.Min:=0;
  ProgressBar1.Max:=(modules)*10;
  for i := 0 to modules - 1 do
      begin
         SetLength(tmpCoef[i], 8); //восемь коэффициентов полинома..
        //чтение пользовательских настроек и коэффициентов
         //     if (not ADC[i].selected) then continue; //если плата не выбрана в главной части - не трогаем - проверка перед запуском формы
         //заполняем данныеми по всем, а вот применять да или нет решим отдельно
         cmd := Modbus.cmd(IntToHEX(ADC[i].Address, 2), 'getUserADS', '');
         Memo1.Append('gU-ADS C*:' + cmd);
         stringToSend := Modbus.StrToHexStr(cmd);
         response := Modbus.send(stringToSend);
         Modbus.USER_RRAds(response);
         //отладка
         Memo1.Append('gU-ADS R*:' + response);
         Memo1.Append('A*U_SPS:' + IntToStr(Modbus.USER_SPS));
         Memo1.Append('A* U_Filter:' + IntToStr(Modbus.USER_Filter));
         ProgressBar1.Position:=(i*10 + 1); Form6.Refresh;
         //тут нужно загнать во временные переменные
         tmpSPS[i] := Modbus.USER_SPS;
         tmpSPSstring[i] := FloatToStr(Modbus.trSPS(Modbus.USER_SPS));
         tmpFilter[i] := Modbus.USER_Filter;
        //чтение длины фильтра
         cmd := Modbus.cmd(IntToHEX(ADC[i].Address, 2), 'getUSER_FIRLEN', '');
         Memo1.Append('gU-FL C*:' + cmd);
         stringToSend := Modbus.StrToHexStr(cmd);
         response := Modbus.send(stringToSend);
         ProgressBar1.Position:=(i*10 + 2); Form6.Refresh;
         MEMO1.Append('gU-FL R*:' + response);
         tmpFirLen[i] := Modbus.USER_RRFirLen(response);
         //чтение коэффициентов полинома
         for j:= 0 to 7 do
              begin  //чтение коэффициентов полинома из пользовательской памяти
              cmd := Modbus.cmd(IntToHEX(ADC[i].Address, 2), 'getUserCoefs', 'F7 ' + IntToStr(j) + '0 00 04'); //четыре слова по два байта на чтение коэффициента
              Memo1.Append('gU-Cf C*:' + cmd);
              stringToSend := Modbus.StrToHexStr(cmd);
              response := Modbus.send(stringToSend);
              MEMO1.Append('gU-FL R*:' + response);
              Memo1.Append('gU-cf A*[' + IntToStr(i) + ']:' + FloatToStr(Modbus.USER_RRCoef(response)));
//              tmpFirLen[i] := Modbus.USER_RRFirLen(response);
              tmpCoef[i][j] := Modbus.USER_RRCoef(response);
              ProgressBar1.Position:=(i*10 + 3 + j); Form6.Refresh;
              end;

      end;
end;

procedure TForm6.ShowCoefs(index: integer);
var i : integer;
begin
  if (Length(ADC) < index) then exit;
  StringGrid2.Cells[0, 0] := 'Degree';
  StringGrid2.ColWidths[0] := 40;
  StringGrid2.Cells[1, 0] := 'Value';
  StringGrid2.ColWidths[1] := 200;

  StringGrid2.RowCount := 9;
  for i:= 0 to 7 do
       begin
       StringGrid2.Cells[0, i + 1] := IntToStr(i);
       StringGrid2.Cells[1, i + 1] := FloatToStr(tmpCoef[index][i]);
       end;

end;

procedure TForm6.Button2Click(Sender: TObject);
begin

end;

procedure TForm6.Button3Click(Sender: TObject);
begin

end;

procedure TForm6.ShowUserVars;
var i, j: integer;
    maxCoef: integer;
    modules: integer;
   begin
     //показать в текущей таблице полученные значения
     modules := Length(ADC);
     StringGrid1.RowCount := modules + 1;
     StringGrid1.Cells[0, 0] := 'index';
     StringGrid1.ColWidths[0] := 30;
     StringGrid1.Cells[1, 0] := 'Addr';
     StringGrid1.ColWidths[1] := 50;
     StringGrid1.Cells[2, 0] := 'HEX';
     StringGrid1.ColWidths[2] := 50;
     StringGrid1.Cells[3,0] := 'SPS';
     StringGrid1.ColWidths[3] := 70;
     StringGrid1.Cells[4,0] := 'Filter';
     StringGrid1.ColWidths[4] := 70;
     StringGrid1.Cells[5,0] := 'FirLen';
     StringGrid1.ColWidths[5] := 70;
     StringGrid1.Cells[6,0] := 'Coef';
     StringGrid1.ColWidths[6] := 70;
     for i := 0 to modules - 1 do
         begin
            StringGrid1.Cells[0, i + 1] := IntToStr(i);
            StringGrid1.Cells[1, i + 1] := IntToStr(ADC[i].address);
            StringGrid1.Cells[2, i + 1] := IntToHEX(ADC[i].address, 2);
            StringGrid1.Cells[3, i + 1] := FloatToStr(Modbus.trSPS(tmpSPS[i]));
            StringGrid1.Cells[4, i + 1] := Modbus.trFilter(tmpFilter[i]);
            StringGrid1.Cells[5, i + 1] := IntToStr(tmpFirLen[i]);
            //найти максимальный действующий коэффициент и отобразить его здесь
            maxCoef:=0
            for j := 0 to 7 do
                if (tmpCoef[i][j]<>0) then maxCoef := j;
            StringGrid1.Cells[6, i + 1] := 'COEFS (' + IntToStr(maxCoef) + ')'; //при нажатии - коэффициенты полинома
         end;
   end;

procedure TForm6.StringGrid1Click(Sender: TObject);
begin
  if (StringGrid1.Col = 6) then
          ShowCoefs(StringGrid1.Row - 1);
end;

procedure TForm6.Button1Click(Sender: TObject);
begin
  ReadUserVars;
  //отображение
  ShowUserVars;
end;

end.

