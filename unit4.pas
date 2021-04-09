unit Unit4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls, core, MathCore;

type

  { TForm4 }

  TForm4 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WriteCells3(Addr, power: integer; key: string; value: string);
  private

  public

  end;

const
  __ADDR__ = 3;
var
  Form4: TForm4;

implementation

{$R *.lfm}

{ TForm4 }

procedure TForm4.FormCreate(Sender: TObject);
begin
  StringGrid1.Cells[0,0] := '#N'; //номер по порядку напряжения
  StringGrid1.Cells[1,0] := 'DEF(V)'; //запрашиваемое напряжение
  StringGrid1.Cells[2,0] := 'Agilent'; //Напряжение на Agilente
  StringGrid1.Cells[__ADDR__,0] := 'Addr'; //Адрес устройства платы с которой брать напряжение
  StringGrid1.Cells[4,0] := 'AVG'; //Среднее напряжение на фильтре без усилителя и опорного напряжения
  StringGrid1.Cells[5,0] := 'Deviation'; //среднее квадратичное отклонение с платы

  Label3.Caption := 'Set Voltage when init';
  Label4.Caption := IntToStr(Modbus.selectedUnits); //число выбранных модулей

  //таблица значений коэффициентов полиномов для определения мин/макс
  StringGrid3.Cells[0,0] := 'Addr';  //Адрес устройства
  StringGrid3.Cells[1,0] := 'Power'; //степень полинома
  StringGrid3.Cells[2,0] := 'key'; //что отображаем
  StringGrid3.Cells[3,0] := 'value'; //значение того что отображаем
end;

procedure TForm4.Button1Click(Sender: TObject);
var i, j, min, max: integer;
    cmd, stringToSend, response :string; //общение с modbus;
    index: integer; //число строк таблицы
    AgilDV : double;
    res : string;
    maxD : double;
begin
  //снять показания приборов
  if (Modbus.units > 0) then
 // index := 0;
  StringGrid2.RowCount:=Modbus.units + 1;

  For i := 0 to (Modbus.units - 1)  do
      begin
      //цикл по активированным платам
      StringGrid2.Cells[0, i + 1]:=IntToStr(i);

      if (not ADC[i].selected) then continue; //если плата не выбрана в главной части - не трогаем
      StringGrid2.Cells[1, i + 1] := IntToStr(ADC[i].Address); //адрес измерительной платы (вторая таблица)

      cmd := Modbus.cmd(IntToHEX(ADC[i].Address, 2), 'getADSFilters', '');
      stringToSend := Modbus.StrToHexStr(cmd);
      response := Modbus.send(stringToSend);
      Verification.currentIndex += 1;
      index := Verification.currentIndex;
      SetLength(ADC[i].VerificationDots, index);
      SetLength(ADC[i].AgilDots, index);
      SetLength(ADC[i].VoltageDots, index);
      StringGrid1.RowCount := index + 1; //увеличение строк таблицы результатов

      StringGrid1.Cells[0, index] := IntToStr(index); // порядковый номер
      StringGrid1.Cells[1, index] := FloatToStr(Verification.CurrentV); //  текущее напряжение
      StringGrid1.Cells[__ADDR__, index] := IntToStr(ADC[i].Address);
      //Agilent Read DV (постоянное напряжение на Agilent'е
      Agil.getVoltage(); //взять напряжение с вольтметра
      Memo1.Append(Agil.LastResult);
      if (Agil.LastError = 0) then
         StringGrid1.Cells[2, index] := FloatToStr(Agil.Voltage)
         else
         StringGrid1.Cells[2, index] := 'Error on Agilent:' + IntToStr(Agil.LastError);

      Memo1.Append(response);
      res := Modbus.RRFir(response);
      Memo1.Append(res);
      StringGrid1.Cells[4, index] := FloatToStr(Modbus.Voltage);

      ADC[i].VerificationDots[index - 1] :=  abs(Modbus.Voltage - Agil.Voltage); // текущее отклонение без процентов
      ADC[i].AgilDots[index - 1] := Agil.Voltage;
      ADC[i].VoltageDots[index - 1] := Modbus.Voltage;
      maxD := 0;
      for j := 0 to index - 1 do
          if (maxD < ADC[i].VerificationDots[j]) then maxD := ADC[i].VerificationDots[j];
      StringGrid2.Cells[2, i + 1] := FloatToStr(maxD); //максимальное отклонение по плате
      StringGrid1.Cells[5, index] := FloatToStr(Modbus.VoltageDeviation);
      end;

   if (Verification.CurrentV < 5) then
    begin
    Verification.CurrentV += 5/(Verification.N-1);
    Label3.Caption := FloatToStr(Verification.CurrentV)
    end
    else
    Button1.Enabled := False;  // блокировка кнопки проведения эксперимента
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
  //инициализация
  Label3.Caption := '0 [V]';
  Verification.CurrentV := 0.0;
  Verification.currentIndex := 0;
  Label4.Caption:= IntToStr(Modbus.selectedUnits);
  Button1.Enabled := True;
end;

procedure TForm4.Button3Click(Sender: TObject);
var
f: text;
s, tmp: string;
i, j : integer;
begin
  //Сохранение поверочной таблицы
   SaveDialog1.Filter:='*.txt |*.txt';
   tmp := Modbus.replace(DateTimeToStr(NOW), ' ', '_');
   tmp := Modbus.replace(tmp, ':', '');
   SaveDialog1.FileName:='TAB2_' + tmp;
   if SaveDialog1.Execute then
   begin

    s:=SaveDialog1.FileName;//берем имя файла
    assignfile(f,s);//связываем имя переменной с файлом
    rewrite(f);//открываем фвйл для записи//записываем массив в файл
    for i:=0 to StringGrid1.RowCount - 1 do
        begin
        for j:=0 to StringGrid1.ColCount - 1 do
           write(f, StringGrid1.Cells[j, i] + #9); // #9 - символ табуляции
        writeln(f, '');
        end;
    closefile(f);
 //   f.free;
   end;
end;

procedure TForm4.Button4Click(Sender: TObject);
var
f: text;
s, tmp: string;
i, j : integer;
begin
  //Сохранение второй таблицы
   SaveDialog1.Filter:='*.txt|*.txt';
   tmp := Modbus.replace(DateTimeToStr(NOW), ' ', '_');
   tmp := Modbus.replace(tmp, ':', '');
   SaveDialog1.FileName:='TAB3_' + tmp;
   if SaveDialog1.Execute then
   begin
    s:=SaveDialog1.FileName;//берем имя файла
    assignfile(f,s);//связываем имя переменной с файлом
    rewrite(f);//открываем фвйл для записи//записываем массив в файл
    for i:=0 to StringGrid2.RowCount - 1 do
        begin
        for j:=0 to StringGrid2.ColCount - 1 do
           write(f, StringGrid2.Cells[j, i] + #9); // #9 - символ табуляции
        writeln(f, '');
        end;
    closefile(f);
   end;
end;

procedure TForm4.WriteCells3(Addr, power: integer; key: string; value: string);
begin
   StringGrid3.RowCount := StringGrid3.RowCount + 1;
   StringGrid3.Cells[0, StringGrid3.RowCount - 1] := IntToStr(Addr);
   StringGrid3.Cells[1, StringGrid3.RowCount - 1] := IntToStr(power);
   StringGrid3.Cells[2, StringGrid3.RowCount - 1] := key;
   StringGrid3.Cells[3, StringGrid3.RowCount - 1] := value;
end;

procedure TForm4.Button5Click(Sender: TObject);
var mnk : TMNK;  //объект работы с методом наименьших квадратов
power : integer; //степень полинома
i, j, k, m: integer; // i - объект (плата измерительная), j - точка измерения, k - номер коэффициента полинома, m - степень полинома
Dots: integer; //число точек измерения
maxD, errI: double;
begin
  StringGrid3.RowCount:=1;
  for m := 2 to 7 do
     begin
     power := m;

     for i := 0 to (Modbus.units - 1) do //цикл по платам
         begin
         maxD := 0; //максимальная ошибка
         errI := 0; //интегральная ошибка

         Dots := Length(ADC[i].VerificationDots); //длина массива точек измерения
         if (Dots < power + 1) then
            begin
            Memo1.Append('Не достаточно точек измерения');
            continue;
            end;

            mnk := TMNK.Create;
            mnk.setNM(Dots, power); //устанавливаем размерность массива
            for j := 0 to Dots - 1 do
                begin
                mnk.x[j] := ADC[i].VoltageDots[j]; //показания с АЦП
                mnk.f[j] := ADC[i].AgilDots[j]; //показания с agilentа;
                end;
            mnk.Gram;  // (n,m,x,f,a); {считаем матрицу Грама}
            mnk.Gauss; // (m,a,c);;

            Memo1.Append('Коэффициенты полинома МНК ' +  IntToStr(power) + ' степени для ИП(' + IntToStr(ADC[i].Address) + ')');
            // SetLength(ADC[i].Coefs, power + 1);
            for k:=0 to power do
                begin
                 WriteCells3(ADC[i].Address, power, 'c' + intToStr(k), FloatToStr(mnk.c[k]))
               // Memo1.Append('c[' + IntToStr(k) + '] := ' + FloatToStr(mnk.c[k]));
               // ADC[i].Coefs[k] := mnk.c[k]; //присвоение найденного полинома нужному значению.
                end;
            //максимальная ошибка по точкам от agilent'а
            for j := 0 to Dots - 1 do
               if maxD < abs(ADC[i].AgilDots[j] - mnk.fi(ADC[i].VoltageDots[j])) then
                  maxD := abs(ADC[i].AgilDots[j] - mnk.fi(ADC[i].VoltageDots[j]));
                  WriteCells3(ADC[i].Address, power, 'errMax', FloatToStr(maxD));  //пишем в таблицу максимальную ошибку для заданной степени полинома
           mnk.Free;


            end;
         end;

end;

procedure TForm4.Button6Click(Sender: TObject);
var
f: text;
s, tmp: string;
i, j : integer;
begin
  //Сохранение второй таблицы
   SaveDialog1.Filter:='*.txt|*.txt';
   tmp := Modbus.replace(DateTimeToStr(NOW), ' ', '_');
   tmp := Modbus.replace(tmp, ':', '');
   SaveDialog1.FileName:='Poly_' + tmp;
   if SaveDialog1.Execute then
   begin
    s:=SaveDialog1.FileName;//берем имя файла
    assignfile(f,s);//связываем имя переменной с файлом
    rewrite(f);//открываем фвйл для записи//записываем массив в файл
    for i:=0 to StringGrid3.RowCount - 1 do
        begin
        for j:=0 to StringGrid3.ColCount - 1 do
           write(f, StringGrid3.Cells[j, i] + #9); // #9 - символ табуляции
        writeln(f, '');
        end;
    closefile(f);
   end;
end;




end.

