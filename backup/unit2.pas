unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  inifiles, core, strutils;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    StringGrid1: TStringGrid;
    procedure Button4Click(Sender: TObject);
    procedure Edit4Change(Sender: TObject);
    procedure Edit5Change(Sender: TObject);
    procedure Edit6Change(Sender: TObject);
    procedure Edit7Change(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure readIni;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label4Click(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;
  IniFile: TINIFile; //file of settings

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.readIni;
begin
Modbus := TModbus.Create;   //создание объекта класса modbus...
Agil := TAgilent.Create;
IniFile := TIniFile.Create('settings.ini');

Modbus.speed := IniFile.ReadInteger('Modbus', 'Speed', 115200);
Modbus.port := IniFile.ReadString('Modbus', 'Port', 'COM2');

Modbus.minAddr := IniFile.ReadInteger('Modbus', 'minAddr', 10);
Modbus.maxAddr := IniFile.ReadInteger('Modbus', 'maxAddr', 64);

Verification.N := IniFile.ReadInteger('Verification', 'Attemts', 5);
Verification.Power := IniFile.ReadInteger('Verification', 'Power', 2);
Verification.Vmin := IniFile.ReadFloat('Verification', 'Vmin', 0);
Verification.Vmax := IniFile.ReadFloat('Verification', 'Vmax', 5);

Agil.ip := IniFile.ReadString('Agilent', 'IP', '192.168.103.103');
   IniFile.Free;
end;

procedure TForm2.Edit4Change(Sender: TObject);
var polyPower : integer;
begin
IniFile := TIniFile.Create('settings.ini');
polyPower := StrToInt(Edit4.Text);
Verification.Power := polyPower;
IniFile.WriteInteger('Verification', 'Power', polyPower);
IniFile.free;
end;

procedure TForm2.Button4Click(Sender: TObject);
var i: integer;
  delta, ui: double;
  Vmin: double;
  Vmax: double;
  ctrlDots : integer;
begin
  try
    IniFile := TIniFile.Create('settings.ini');
    Vmin := StrToFloat(Edit5.Text);
    Verification.Vmin := Vmin;
    IniFile.WriteFloat('Verification', 'Vmin', Vmin);
    IniFile.free;

  finally
  end;

  IniFile := TIniFile.Create('settings.ini');
ctrlDots := StrToInt(Edit2.Text);
Verification.N := ctrlDots;
IniFile.WriteInteger('Verification', 'Attemts', ctrlDots);
IniFile.free;

//показать точки эксперимента
  StringGrid1.RowCount := 1;
  StringGrid1.Cells[0, 0] := '#N';
  StringGrid1.Cells[1, 0] := 'V(def)';

  delta := (Verification.Vmax - Verification.Vmin)/(Verification.N-1);
  ui := Verification.Vmin;
  for i:= 0 to Verification.N - 1  do
      begin
        StringGrid1.RowCount := StringGrid1.RowCount + 1;
        StringGrid1.Cells[0, i + 1] := IntToStr(i);
        StringGrid1.Cells[1, i + 1] := FloatToStr(ui);
        ui += delta;
      end;
end;

procedure TForm2.Edit5Change(Sender: TObject);
var Vmin: double;
begin
   //Vmin change
(* try
  IniFile := TIniFile.Create('settings.ini');
  Vmin := StrToFloat(Edit5.Text);
  Verification.Vmin := Vmin;
  IniFile.WriteFloat('Verification', 'Vmin', Vmin);
  IniFile.free;

finally
end;
    *)
end;

procedure TForm2.Edit6Change(Sender: TObject);
var Vmax: double;
begin
  (*
  IniFile := TIniFile.Create('settings.ini');
  try
  Vmax := StrToFloat(Edit6.Text);
  Verification.Vmax := Vmax;
  IniFile.WriteFloat('Verification', 'Vmax', Vmax);
  finally
  end;
  IniFile.free;    *)
end;

procedure TForm2.Edit7Change(Sender: TObject);
begin

end;

procedure TForm2.Label12Click(Sender: TObject);
begin

end;

procedure TForm2.Label4Click(Sender: TObject);
begin

end;

procedure TForm2.FormCreate(Sender: TObject);

begin

     readIni;


//Edit2.Text := IntToStr(Verification.N);



end;

procedure TForm2.FormShow(Sender: TObject);
begin
   readIni; //чтение настроек каждый раз (для того чтоб настройка работала
   Edit2.Text := IntToStr(Verification.N);
   Edit1.Text := Agil.ip;
   Edit3.Text := IntToStr(Modbus.maxAddr);
   Edit4.Text := IntToStr(Verification.Power); //степень полинома
   Edit5.Text := FloatToStr(Verification.Vmin); //от какого напряжения снимаем показания
   Edit6.Text := FloatToStr(Verification.Vmax);
   Edit7.Text := Modbus.port;

end;

procedure TForm2.ComboBox4Change(Sender: TObject);
begin
  Modbus.minAddr := StrToInt(ComboBox4.Caption);
end;

procedure TForm2.Edit2Change(Sender: TObject);
var ctrlDots: integer;
begin
(* IniFile := TIniFile.Create('settings.ini');
ctrlDots := StrToInt(Edit2.Text);
Verification.N := ctrlDots;
IniFile.WriteInteger('Verification', 'Attemts', ctrlDots);
IniFile.free; *)
end;

procedure TForm2.Button3Click(Sender: TObject);
var IP: string;
begin
IniFile := TIniFile.Create('settings.ini');
IP := Edit1.Text;
Agil.ip := IP;
IniFile.WriteString('Agilent', 'IP', IP);
IniFile.free;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
 IniFile := TIniFile.Create('settings.ini');

IniFile.WriteInteger('Verification', 'Atemt', StrToInt(Edit2.Text));  //применение попыток
Modbus.Port := Edit7.Text;
IniFile.WriteString('Modbus', 'port', Modbus.port);

IniFile.WriteInteger('Modbus', 'minAddr', Modbus.minAddr);
Modbus.maxAddr:=StrToInt(Edit3.Text);
IniFile.WriteInteger('Modbus', 'maxAddr', Modbus.maxAddr);
IniFile.free;
Close;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  Close;
end;

end.

