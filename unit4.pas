unit Unit4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls, core;

type

  { TForm4 }

  TForm4 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  StringGrid1.Cells[5,0] := 'СКО'; //среднее квадратичное отклонение с платы

  Label3.Caption := 'Set Voltage when init';
  Label4.Caption := IntToStr(Modbus.selectedUnits); //число выбранных модулей
end;

procedure TForm4.Button1Click(Sender: TObject);
var i, min, max: integer;
    cmd, stringToSend, response :string; //общение с modbus;
    index: integer; //число строк таблицы
    AgilDV : double;
    res : string;
begin
  //снять показания приборов
  if (Modbus.units > 0) then
 // index := 0;
  For i := 0 to (Modbus.units - 1)  do
      begin
      //цикл по активированным платам
      if (not ADC[i].selected) then continue; //если плата не выбрана в главной части - не трогаем
      cmd := Modbus.cmd(IntToHEX(ADC[i].Address, 2), 'getADSFilters', '');
      stringToSend := Modbus.StrToHexStr(cmd);
      response := Modbus.send(stringToSend);
      Verification.currentIndex += 1;
      index := Verification.currentIndex;
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

end.

