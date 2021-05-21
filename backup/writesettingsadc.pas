unit writeSettingsADC;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  ExtCtrls, TAGraph, TASeries, TAMultiSeries,
  core, //класс объявляющий степень полинома
  MathCore, TADrawUtils, TACustomSeries; //класс с методами Гаусса-Грамма

type

  { TForm5 }

  TForm5 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    Chart1LineSeries2: TLineSeries;
    Chart1LineSeries3: TLineSeries;
    Chart1LineSeries4: TLineSeries;
    Label1: TLabel;
    Memo1: TMemo;
    RadioGroup1: TRadioGroup;
    StringGrid1: TStringGrid;
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Chart1LineSeries2CustomDrawPointer(ASender: TChartSeries;
      ADrawer: IChartDrawer; AIndex: Integer; ACenter: TPoint);
    procedure Label1Click(Sender: TObject);
    procedure WriteCells1(key: string; value: string);    //вывод коэффициентов на экран
    procedure WritePoly(power: integer); //вывод степени полинома и его расчет к плате
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private

  public
       indexAdc: integer;  //это индекс массива, не адрес
  end;

var
  Form5: TForm5;

implementation

{$R *.lfm}

{ TForm5 }

procedure TForm5.WriteCells1(key: string; value: string);
var b : array of byte;
    c : byte;
    s : string;
begin
   StringGrid1.RowCount := StringGrid1.RowCount + 1;
   StringGrid1.Cells[0, StringGrid1.RowCount - 1] := key;
   StringGrid1.Cells[1, StringGrid1.RowCount - 1] := value;
     SetLength(b, 8);
        b := Modbus.Double2Bytes(StrToFloat(value));
        s := '';
        for c in b do s := s + ' ' + IntToHex(c,2);

   StringGrid1.Cells[2, StringGrid1.RowCount - 1] := s; // (HEX)
end;

procedure TForm5.Button2Click(Sender: TObject);
var j:  integer;
    x, f: double;
    Dots : integer;
begin
  //печать графика для
    Chart1LineSeries1.Clear;
    Dots := Length(ADC[indexADC].VerificationDots);
    for j := 0 to Dots - 1 do
                begin
                x := ADC[indexAdc].VoltageDots[j]; //показания с АЦП
                f := ADC[indexAdc].AgilDots[j]; //показания с agilentа;
                   Chart1LineSeries1.AddXY(x, f);
                end;

end;

procedure TForm5.Button3Click(Sender: TObject);
var i: integer;
    s: string;
    d: double;
    b: array of byte;
    c: byte;
    cmd : string;
    addr, param, stringToSend, response : string; //адрес устройства в hex
begin
   addr := IntToHex(ADC[indexADC].Address, 2);
   for i := 0 to 7 do
      begin
         (* Команда чтения данных:
          $1d$03$f0$00$00$03$de$ad
          Ответ: 1D 03 06 12 34 56 78 9A BC F1 83 *)


         param := 'F7 ' + IntToStr(i) + '0 00 04';
         cmd := Modbus.cmd(addr, 'readCoefs', param);
         Memo1.Append(cmd);
         stringToSend := Modbus.StrToHexStr(cmd);
         response := Modbus.send(stringToSend);
         Memo1.Append(response);
      end;

end;

procedure TForm5.Button1Click(Sender: TObject);
var i: integer;
    s: string;
    d: double;
    b: array of byte;
    c: byte;
    cmd : string;
    addr, param, stringToSend, response : string; //адрес устройства в hex
begin
  //шаг 1. -> в цикле преобразовать Double в HEX
  addr := IntToHex(ADC[indexADC].Address, 2);
           //перевод платы в режим Norm
           cmd := Modbus.cmd(addr, 'setNorm', '');
           stringToSend := Modbus.StrToHexStr(cmd);
           response := Modbus.send(stringToSend);
           Memo1.Append(response);

  for i := 0 to 7 do
      begin
        if (i <= ADC[indexAdc].PolyPower) then
              d := ADC[indexAdc].Coefs[i]
              else
              d := 0.0;
        SetLength(b, 8);
        b := Modbus.Double2Bytes(d);
        s := '';
        for c in b do s := s + ' ' + IntToHex(c,2);
        Memo1.Append('i: ' + IntToStr(i) + ' V: ' + FloatToStr(d) + ' HEX: ' +  s);

        //отправка данных на плату в пользовательскую область

        (*  Команда записи данных:
         $1d$10$f0$00$00$03$06$12$34$56$78$9a$bc$de$ad
         Ответ: 1D 10 F0 00 00 03 B1 54
         Команда чтения данных:
          $1d$03$f0$00$00$03$de$ad
          Ответ: 1D 03 06 12 34 56 78 9A BC F1 83 *)
         param := 'F7 ' + IntToStr(i) + '0 00 04 08' + s;
         // param := 'f0 00 00 03 06 12 34 56 78 9A BC' ; //тестовая запись
         cmd := Modbus.cmd(addr, 'putCoefs', param);
         Memo1.Append(cmd);
         stringToSend := Modbus.StrToHexStr(cmd);
         response := Modbus.send(stringToSend);
         Memo1.Append(response);
      end;


  //послать команду на запись
  //вывести результат команды
end;

procedure TForm5.Button10Click(Sender: TObject);
var cmd, stringToSend, response: string;
    res : string;
begin
  //добавить тестовую точку на график абсолютной ошибки
  //читаем agilent на полном фильтре, читаем с конкретной платы
  Agil.getVoltage(); //взять напряжение с вольтметра
  Chart1LineSeries3.ShowPoints:=True;
  Chart1LineSeries3.LineType:=ltNone;
  Chart1LineSeries3.Pointer.Brush.Color:=clRed;
  Chart1LineSeries4.ShowPoints:=True;
  Chart1LineSeries4.LineType:=ltNone;
  Chart1LineSeries4.Pointer.Brush.Color:=clGreen;
    //перевести в режим EXEC... до начала работы
    cmd := Modbus.cmd(IntToHEX(ADC[indexADC].Address, 2), 'getADSFilters', '');
      stringToSend := Modbus.StrToHexStr(cmd);
      response := Modbus.send(stringToSend);
      res := Modbus.RRFir(response);
//      Chart1BubbleSeries1.OverrideColor := bocPen;
      Chart1LineSeries3.AddXY(Agil.Voltage, 25*(Agil.Voltage - Modbus.Voltage));
      Chart1LineSeries4.AddXY(Agil.Voltage, 25*(Agil.Voltage - ADC[indexADC].fi(ADC[indexADC].PolyPower, Modbus.Voltage)));
      Memo1.Append('modbus voltage' + FloatToStr(Modbus.Voltage));
      Memo1.Append('Agil.Voltage' + FloatToStr(Agil.Voltage));
      Memo1.Append('ADC.Fi*:' + FloatToStr(ADC[indexADC].fi(ADC[indexADC].PolyPower, Modbus.Voltage)));
//      Modbus.Voltage;  // текущая ситуация
//      Modbus.VoltageDeviation;

       // Memo1.Append('unit ' + IntToStr(indexADC) + ' R*:' + response + ' V*:' +  FloatToStr(Modbus.Voltage));
end;

procedure TForm5.Button11Click(Sender: TObject);
var len: integer; //число модулей для инициализации
    addr, cmd, stringToSend, response: string; //команда на модуль
begin
   len := Length(ADC);
  for i:= 0 to len - 1 do
          begin
          addr := IntToHex(ADC[i].Address, 2);
          cmd := Modbus.cmd(addr, 'setEXEC', '');
          Memo1.Append('SET EXEC: ' + IntToStr(i) + ' C*:'+ cmd);
          stringToSend := Modbus.StrToHexStr(cmd);
          response := Modbus.send(stringToSend);
          Memo1.Append('R*: ' + response);

          end;
end;

procedure TForm5.Button4Click(Sender: TObject);
var j:  integer;
    x, f: double;
    Dots : integer;
    power : integer;
begin
  //печать графика для
    Chart1LineSeries1.Clear;
    Dots := Length(ADC[indexADC].VerificationDots);
    for j := 0 to Dots - 1 do
                begin
                x := ADC[indexAdc].VoltageDots[j]; //показания с АЦП
                power := ADC[indexADC].PolyPower; //степень полинома
                //VoltageDots - приведенное показание AЦП
                //25  - это про приведение к 4 вольтам и 100%
                f := 25*(ADC[indexAdc].AgilDots[j] - ADC[indexADC].fi(power, ADC[indexAdc].VoltageDots[j])); //показания с agilentа;
                   Chart1LineSeries1.AddXY(x, f);
                end;
end;

procedure TForm5.Button5Click(Sender: TObject);
var j:  integer;
    x, f: double;
    Dots : integer;
    power : integer;
begin
  //печать графика для
    Chart1LineSeries1.Clear;
    Dots := Length(ADC[indexADC].VerificationDots);
    for j := 0 to Dots - 1 do
                begin
                x := ADC[indexAdc].VoltageDots[j]; //показания с АЦП
                power := ADC[indexADC].PolyPower; //степень полинома
                //VoltageDots - приведенное показание AЦП
                //25  - это про приведение к 4 вольтам и 100%
                f := 25*(ADC[indexAdc].AgilDots[j] -  ADC[indexAdc].VoltageDots[j]); //показания с agilentа;
                   Chart1LineSeries1.AddXY(x, f);

                end;
end;

procedure TForm5.Button6Click(Sender: TObject);
begin
  //поиск предыдущей платы
  indexADC := indexADC - 1;
  if (indexADC < 0) then indexADC := LENGTH(ADC) - 1;
  while(not ADC[indexADC].selected) do
         begin
            indexADC := indexADC - 1;
            if (indexADC < 0) then indexADC := LENGTH(ADC) - 1;
         end;
         Label1.Caption:=IntToStr(ADC[indexADC].Address);
         ADC[indexAdc].PolyPower := RadioGroup1.ItemIndex + 2;
         writePoly(ADC[indexADC].polyPower);
end;

procedure TForm5.Button7Click(Sender: TObject);
begin
    //поиск следующей платы
    indexADC := indexADC + 1;
  if (indexADC > Length(ADC) - 1) then indexADC := 0;
  while(not ADC[indexADC].selected) do
         begin
            indexADC := indexADC - 1;
            if (indexADC < 0) then indexADC := LENGTH(ADC) - 1;
         end;
         Label1.Caption:=IntToStr(ADC[indexADC].Address);
         ADC[indexAdc].PolyPower := RadioGroup1.ItemIndex + 2;
         writePoly(ADC[indexADC].polyPower);
end;

procedure TForm5.Button8Click(Sender: TObject);
//выводим ошибку по текущей степени полинома
var j:  integer;
    x, f: double;
    Dots : integer;
    power : integer;
    min, max: double;
    N: integer; //число точек для вывода графика по полиному
begin
  //печать графика для
    Chart1LineSeries2.Clear;
    Chart1LineSeries2.SeriesColor:=clLime;
    Dots := Length(ADC[indexADC].VerificationDots);
    min := ADC[indexADC].AgilDots[0];
    max := ADC[indexADC].AgilDots[Dots - 1];
    N := 1000;
    for j := 0 to N do
                begin
                x:= min + (max - min) / N * j;
                power := ADC[indexADC].PolyPower; //степень полинома
                f := 25 * (ADC[indexADC].fi(power, x) - x);
                Chart1LineSeries2.AddXY(x, f);
                end;
end;

procedure TForm5.Button9Click(Sender: TObject);
begin
  Chart1LineSeries2.Clear;
  Chart1LineSeries3.Clear;
    Chart1LineSeries4.Clear;
end;

procedure TForm5.Chart1LineSeries2CustomDrawPointer(ASender: TChartSeries;
  ADrawer: IChartDrawer; AIndex: Integer; ACenter: TPoint);
begin

end;

procedure TForm5.Label1Click(Sender: TObject);
begin

end;

procedure TForm5.writePoly(power: integer);
var maxD, errI : double;
  Dots : integer;
  mnk : TMNK; //методы математики
  i, j, k: integer;
begin
   StringGrid1.RowCount := 1;
   StringGrid1.cells[0,0] := 'key';
   StringGrid1.cells[1,0] := 'value'; //заголовок таблицы со степенями
    StringGrid1.ColWidths[0] := 50;
    StringGrid1.ColWidths[1] := 100;
    StringGrid1.ColWidths[2] := 100;

   SetLength(ADC[indexADC].Coefs, power + 1);

         maxD := 0; //максимальная ошибка
         errI := 0; //интегральная ошибка
         Dots := Length(ADC[indexADC].VerificationDots); //длина массива точек измерения
         if (Dots < power + 1) then
            begin
            Memo1.Append('Не достаточно точек измерения');
            exit();
            end;

            mnk := TMNK.Create;
            mnk.setNM(Dots, power); //устанавливаем размерность массива
            for j := 0 to Dots - 1 do
                begin
                mnk.x[j] := ADC[indexAdc].VoltageDots[j]; //показания с АЦП
                mnk.f[j] := ADC[indexAdc].AgilDots[j]; //показания с agilentа;
                end;
            mnk.Gram;  // (n,m,x,f,a); {считаем матрицу Грама}
            mnk.Gauss; // (m,a,c);;
            for k:=0 to power do
                begin
                 WriteCells1('c' + intToStr(k), FloatToStr(mnk.c[k]));
                 ADC[indexADC].Coefs[k] := mnk.c[k]; //применение полинома к плате
                end;
            //максимальная ошибка по точкам от agilent'а
           mnk.Free;
     if (power < 7) then
        for i:= power + 1 to 7 do
           WriteCells1('c' + intToStr(i), '0,0');
end;

procedure TForm5.RadioGroup1Click(Sender: TObject);
begin
  //изменение степени полинома текущей платы
  ADC[indexAdc].PolyPower := RadioGroup1.ItemIndex + 2;
  writePoly(ADC[indexADC].polyPower);
  //заполнение таблицы нужной степенью полинома
end;

procedure TForm5.FormShow(Sender: TObject);
begin
  Label1.Caption:= 'Плата ' + IntToStr(ADC[indexAdc].address);
  RadioGroup1.ItemIndex := ADC[indexAdc].polyPower - 2; //степень полинома и индекс на радио группе
  writePoly(ADC[indexADC].polyPower);
end;

procedure TForm5.FormCreate(Sender: TObject);
begin
  indexAdc := 0;
end;

end.

