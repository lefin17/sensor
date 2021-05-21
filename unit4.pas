unit Unit4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls, core, MathCore,
  writeSettingsADC; //запись данных на плату

type

  { TForm4 }

  TForm4 = class(TForm)
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
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    procedure Button10Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure StringGrid3DblClick(Sender: TObject);
    procedure WriteCells3(Addr, power: integer; key: string; value: string);
  private
    indexADC: integer;
    rescanVoltage: double;
    rescanRow: integer;
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

procedure TForm4.FormShow(Sender: TObject);
begin
      StringGrid2.Cells[0, 0] := 'index'; //максимальное отклонение по плате
      StringGrid2.Cells[1, 0] := 'Address';
      StringGrid2.Cells[2, 0] := 'MaxE';

end;

procedure TForm4.Label3Click(Sender: TObject);
begin

end;

procedure TForm4.StringGrid1DblClick(Sender: TObject);
var address: string;
  i: integer;
begin
  //отправка информации по какой плате и по какому напряжению нужно снять данные
  if (Button1.Enabled = false) then
  begin
  address := StringGrid1.Cells[__ADDR__, StringGrid1.Row];
  if (length(address) = 0) then exit;

  for i:=0 to length(ADC) - 1 do
      if ADC[i].Address = StrToInt(address) then
         begin
         indexADC := i;
         break;
         end;
  rescanRow := StringGrid1.Row;
  ReScanVoltage := StrToFloat(StringGrid1.Cells[1, StringGrid1.Row]);
  Label3.Caption := FloatToStr(ReScanVoltage) + ' V (' + address + ')';
  end
end;

procedure TForm4.StringGrid3DblClick(Sender: TObject);
var addr, polyPower, col, row, i : integer;

begin
  //запись платы
  // Row

  row := StringGrid3.Row;

  if (row = 0) then exit;
  col := StringGrid3.Col;
  addr := StrToInt(StringGrid3.Cells[0, row]);
  polyPower := StrToInt(StringGrid3.Cells[1, row]);
  for i := 0 to Length(ADC) - 1 do
      if (ADC[i].Address = addr) then
         begin
         Form5.indexAdc := i;
         ADC[i].PolyPower  := polyPower;
         break;
         end;

//  Form5.indexAdc:=addr;
  Form5.show();
end;

procedure TForm4.Button1Click(Sender: TObject);
var i, j, min, max: integer;
    cmd, stringToSend, response :string; //общение с modbus;
    index: integer; //число строк таблицы
    AgilDV : double;
    res : string;
    maxD : double;
    len: integer; //текущая длина
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
      len := Length(ADC[i].VerificationDots); //текущая точка для выбранной платы
      SetLength(ADC[i].VerificationDots, len + 1);
      SetLength(ADC[i].AgilDots, len + 1);
      SetLength(ADC[i].VoltageDots, len + 1);
      SetLength(ADC[i].CurrentV, len + 1);

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

      ADC[i].VerificationDots[len] :=  abs(Modbus.Voltage - Agil.Voltage); // текущее отклонение без процентов
      ADC[i].AgilDots[len] := Agil.Voltage;
      ADC[i].VoltageDots[len] := Modbus.Voltage;
      ADC[i].CurrentV[len] := Verification.CurrentV;
      maxD := 0;
      for j := 0 to index - 1 do
          if (maxD < ADC[i].VerificationDots[j]) then maxD := ADC[i].VerificationDots[j];
      StringGrid2.Cells[2, i + 1] := FloatToStr(maxD); //максимальное отклонение по плате
      StringGrid1.Cells[5, index] := FloatToStr(Modbus.VoltageDeviation);
      end;

   if (Verification.CurrentV < Verification.Vmax - 0.01) then //здесь дельта погрешность из-за задаваемого значения максимального и минимального напряжений
    begin
//    Verification.CurrentV += 5/(Verification.N-1);
         Verification.CurrentV += (Verification.Vmax - Verification.Vmin)/(Verification.N-1);
    Label3.Caption := FloatToStr(Verification.CurrentV)
    end
    else
    Button1.Enabled := False;  // блокировка кнопки проведения эксперимента
end;

procedure TForm4.Button10Click(Sender: TObject);
var cmd: string;
    response, res, stringToSend: string;
    i: integer;
    j: integer;
    modules: integer;
    maxD : double; // ошибка по плате
begin
  if (rescanrow = 0) then exit; //не работаем если не было двойного щелчка на таблицу
  //чтение одного изделия заного - нужное напряжение, нужно найти точку...
  Agil.getVoltage2(); //взять напряжение с вольтметра //без чтения и паузы
  //запуск чтения по плате
      cmd := Modbus.cmd(IntToHEX(ADC[indexADC].Address, 2), 'getADSFilters', '');
      stringToSend := Modbus.StrToHexStr(cmd);
      response := Modbus.send(stringToSend);
      res := Modbus.RRFir(response);

//      Modbus.Voltage;  // текущая ситуация
//      Modbus.VoltageDeviation;

       Memo1.Append('unit ' + IntToStr(indexADC) + ' R*:' + response + ' V*:' +  FloatToStr(Modbus.Voltage));
       Agil.getVoltage2Read(); //финализировали чтение Agilent'а

       StringGrid1.Cells[2, rescanRow] := FloatToStr(Agil.Voltage);


       StringGrid1.Cells[4, rescanRow] := FloatToStr(Modbus.Voltage);
       StringGrid1.Cells[5, rescanRow] := FloatToStr(Modbus.VoltageDeviation);

       //нахождение индекса экспериментальной точки
       for i:=0 to LENGTH(ADC[indexADC].CurrentV) - 1 do
           begin
              if (rescanVoltage = ADC[indexADC].CurrentV[i])
                 then
                  begin
                      ADC[indexADC].VerificationDots[i] :=  abs(Modbus.Voltage - Agil.Voltage); // текущее отклонение без процентов
                      ADC[indexADC].AgilDots[i] := Agil.Voltage;
                      ADC[indexADC].VoltageDots[i] := Modbus.Voltage; //должны существовать
                  end;
           end;
//определение максимальной ошибки по текущей плате
      maxD := 0;

      for j := 0 to LENGTH(ADC[indexADC].VerificationDots) - 1 do
          if (maxD < ADC[indexADC].VerificationDots[j]) then maxD := ADC[indexADC].VerificationDots[j];
           StringGrid2.Cells[2, indexADC + 1] := FloatToStr(maxD); //максимальное отклонение по плате
end;

procedure TForm4.Button2Click(Sender: TObject);
// *********** Процедура инициализации плат Москва перед считыванием значений
var i: integer;
    addr: string;
    cmd: string;
    stringToSend:string;
    response:string;
    len: integer;
begin
  //инициализация
//  Label3.Caption := '0 [V]';
//  Verification.CurrentV := 0.0;
  Verification.CurrentV := Verification.Vmin;
  Label3.Caption := FloatToStr(Verification.Vmin) + ' [V]';
  Verification.currentIndex := 0;
  Label4.Caption:= IntToStr(Modbus.selectedUnits);
  Button1.Enabled := True;

  //Перевод в режим EXEC всех плат
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
  //обнуление таблиц при инициализации
  StringGrid1.RowCount:=1; //убиваем наполненные таблицы
  StringGrid2.RowCount:=1;
  StringGrid3.RowCount:=1;
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
  Memo1.Append('Modbus.units: ' + intTostr(Modbus.units));
  for m := 2 to 7 do
     begin
     power := m;
     Memo1.Append('power: ' + intToStr(m));

     for i := 0 to (Modbus.units - 1) do //цикл по платам
         begin
         maxD := 0; //максимальная ошибка
         errI := 0; //интегральная ошибка
         memo1.Append('ADC ' + IntToStr(i) + ' ADC[i].Ver.length: '+ IntToStr(Length(ADC[i].VerificationDots)));

         Dots := Length(ADC[i].VerificationDots); //длина массива точек измерения
         if (Dots < power + 1) then
            begin
            Memo1.Append('Не достаточно точек измерения');
            continue;
            end;
           // mnk := NILL;
            mnk := TMNK.Create;
          //  Memo1.Append('mnk created');
           // sleep(100);
           // Memo1.Append('sleep complite');
            mnk.setNM(Dots, power); //устанавливаем размерность массива
           // Memo1.Append('set n, m');
            for j := 0 to Dots - 1 do
                begin
                mnk.x[j] := ADC[i].VoltageDots[j]; //показания с АЦП
                mnk.f[j] := ADC[i].AgilDots[j]; //показания с agilentа;
                end;
         //   Memo1.Append('dots set complite');
            mnk.Gram;  // (n,m,x,f,a); {считаем матрицу Грама}
         //   Memo1.Append('Gram done');
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

procedure TForm4.Button7Click(Sender: TObject);
//open results for quick load experiment
var
f: text;
s, tmp: string;
i, j, k, m : integer;
line:string;
dots: array of string;
addr, index: integer;
def, agl, avg, dev: double;
act: boolean;
oldDef : double;
begin
  //Сохранение второй таблицы
   OpenDialog1.Filter:='*.txt|*.txt';
   if OpenDialog1.Execute then
   begin
    k := 0;
    s:=OpenDialog1.FileName;//берем имя файла
    assignfile(f,s);//связываем имя переменной с файлом
    reset(f);//открываем фвйл для записи//записываем массив в файл
    Verification.currentIndex := 0;
    oldDef := -1;
    while not eof(f) do // находим минимум среди положительных и запоминаем его и его позицию
    begin
         k += 1;
         readln(f, line);
         dots := line.Split(#9);
         if (Length(dots)<5) then continue;

       //if (k = 1) then
       //   begin
             //заполнение заголовков таблицы
             StringGrid1.RowCount := k;

             for j := 0 to Length(dots) - 2 do
             StringGrid1.Cells[j, k - 1] := dots[j];
      //    end;

         if (k = 1) then continue;  //строка заголовков

         m := StrToInt(dots[0]);  //индекс измерения

         def := StrToFloat(dots[1]); //не используется при расчетах
         addr := StrToInt(dots[3]);   //адрес платы (если сейчас не инициализирована - пропускаем вообще)
         act := false;
         if (Length(ADC) > 0) then    //проверяем ПИ (плату) на инициализацию.
         for j := 0 to Length(ADC) - 1  do
             if (ADC[j].Address = addr) then
             begin
             act := true;
             i := j; //нахождение индекса объекта с которым работаем
             end;

         if (not act) then
         begin
          memo1.Append('Device with address ' + IntToStr(addr) + ' not activated by search');
          continue;
         end;
         agl := StrToFloat(dots[2]); //показания agilent
         avg := StrToFloat(dots[4]);
         dev := StrToFloat(dots[5]); //СКО (средне квадратичное - не используется при расчетах)

         if (def <> oldDef) then
         begin
          Verification.currentIndex += 1;
          oldDef := def;
         end;
         index := Verification.currentIndex;
         SetLength(ADC[i].VerificationDots, index);
         SetLength(ADC[i].AgilDots, index);
         SetLength(ADC[i].VoltageDots, index);
         SetLength(ADC[i].CurrentV, index);
         //присваивание исходных точек нужным объектам
         ADC[i].VerificationDots[index - 1] :=  abs(avg - agl); // текущее отклонение без процентов
         ADC[i].AgilDots[index - 1] := Agl;
         ADC[i].VoltageDots[index - 1] := avg;
         ADC[i].CurrentV[index - 1] := def;
    end;
    closefile(f);
   end;
end;

procedure TForm4.Button8Click(Sender: TObject);
var i : integer;
begin
  StringGrid3.RowCount := 1;
  for i:= 0 to 10 do
   begin
   StringGrid3.RowCount := StringGrid3.RowCount + 1;
   StringGrid3.Cells[0, StringGrid3.RowCount - 1] := 'A';;
   StringGrid3.Cells[1, StringGrid3.RowCount - 1] := 'B';
   StringGrid3.Cells[2, StringGrid3.RowCount - 1] := 'C';
   StringGrid3.Cells[3, StringGrid3.RowCount - 1] := 'D';
   end;

end;

procedure TForm4.Button9Click(Sender: TObject);
var i, j, min, max: integer;
    cmd, stringToSend, response :string; //общение с modbus;
    index: integer; //число строк таблицы
    AgilDV : double;
    res : string;
    maxD : double;
    tmp: array of double; //пробные экспериментальные точки полученные по платам Москва
    tmp_dev: array of double; //разброс
    dotStart : integer;
    len : integer; //длина эксперимента на точках
begin
  //снять показания приборов за один прогон...
  if (Modbus.units > 0) then
 // index := 0;

  //тут инициализация команды на agilent..
  Agil.getVoltage2(); //взять напряжение с вольтметра //без чтения и паузы
  dotStart := Verification.currentIndex; //точка старта для заполнения после снятия Agilent'а
  index := Verification.currentIndex;
  For i := 0 to (Modbus.units - 1)  do
      begin
      //цикл по активированным платам

      if (not ADC[i].selected) then continue; //если плата не выбрана в главной части - не трогаем
      cmd := Modbus.cmd(IntToHEX(ADC[i].Address, 2), 'getADSFilters', '');
      stringToSend := Modbus.StrToHexStr(cmd);
      response := Modbus.send(stringToSend);
      index := index + 1;
      SetLength(tmp, index);
      SetLength(tmp_dev, index);
      res := Modbus.RRFir(response);
      tmp[index - 1] := Modbus.Voltage;  // текущая ситуация
      tmp_dev[index - 1] := Modbus.VoltageDeviation;
      Memo1.Append('unit ' + IntToStr(i) + ' R*:' + response + ' V*:' +  FloatToStr(tmp[index - 1]));

    end;

  StringGrid2.RowCount:=Modbus.units + 1;
  Verification.currentIndex := index; //текущий индекс для следующих скачиваний
  Agil.getVoltage2Read(); //финализировали чтение Agilent'а
  StringGrid1.RowCount := index + 1; //увеличение строк таблицы результатов
  Memo1.Append(Agil.LastResult);
      if (Agil.LastError = 0) then
         StringGrid1.Cells[2, index] := FloatToStr(Agil.Voltage)
         else
         StringGrid1.Cells[2, index] := 'Error on Agilent:' + IntToStr(Agil.LastError);

  index := dotStart;
  For i := 0 to (Modbus.units - 1)  do
      begin
      //цикл по активированным платам
      StringGrid2.Cells[0, i + 1] := IntToStr(i + 1);
      StringGrid2.Cells[1, i + 1] := IntToStr(ADC[i].Address);

      if (not ADC[i].selected) then continue; //если плата не выбрана в главной части - не трогаем

      index := index + 1;

      if (Agil.LastError = 0) then
         StringGrid1.Cells[2, index] := FloatToStr(Agil.Voltage); //заполняем все значения...

      len := length(ADC[i].VerificationDots);
      SetLength(ADC[i].VerificationDots, len + 1);
      SetLength(ADC[i].AgilDots, len + 1);
      SetLength(ADC[i].VoltageDots, len + 1);
      SetLength(ADC[i].CurrentV, len + 1);


      StringGrid1.Cells[0, index] := IntToStr(index); // порядковый номер
      StringGrid1.Cells[1, index] := FloatToStr(Verification.CurrentV); //  текущее напряжение
      StringGrid1.Cells[__ADDR__, index] := IntToStr(ADC[i].Address);
      //Agilent Read DV (постоянное напряжение на Agilent'е

      ADC[i].VerificationDots[len] :=  abs(tmp[index - 1] - Agil.Voltage); // текущее отклонение без процентов
      ADC[i].AgilDots[len] := Agil.Voltage;
      ADC[i].VoltageDots[len] := tmp[index - 1];
      ADC[i].CurrentV[len] := Verification.CurrentV;
      maxD := 0;
      for j := 0 to len do
          if (maxD < ADC[i].VerificationDots[j]) then maxD := ADC[i].VerificationDots[j];

      StringGrid2.Cells[2, i + 1] := FloatToStr(maxD); //максимальное отклонение по плате
      StringGrid1.Cells[4, index] := FloatToStr(tmp[index - 1]); //временное значение напряжения
      StringGrid1.Cells[5, index] := FloatToStr(tmp_dev[index - 1]);
      end;

   if (Verification.CurrentV < Verification.Vmax - 0.01) then //здесь дельта погрешность из-за задаваемого значения максимального и минимального напряжений
    begin
//    Verification.CurrentV += 5/(Verification.N-1);
         Verification.CurrentV += (Verification.Vmax - Verification.Vmin)/(Verification.N-1);
    Label3.Caption := FloatToStr(Verification.CurrentV)
    end
    else
    Button1.Enabled := False;  // блокировка кнопки проведения эксперимента
end;




end.

