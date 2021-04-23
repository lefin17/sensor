unit writeSettingsADC;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  ExtCtrls, TAGraph, TASeries, TAMultiSeries,
  core, //класс объявляющий степень полинома
  MathCore; //класс с методами Гаусса-Грамма

type

  { TForm5 }

  TForm5 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Chart1: TChart;
    Chart1BubbleSeries1: TBubbleSeries;
    Chart1LineSeries1: TLineSeries;
    Label1: TLabel;
    Memo1: TMemo;
    RadioGroup1: TRadioGroup;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
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

