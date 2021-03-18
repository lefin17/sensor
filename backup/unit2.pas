unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, inifiles, core;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

procedure TForm2.Label4Click(Sender: TObject);
begin

end;

procedure TForm2.FormCreate(Sender: TObject);

begin

Modbus := TModbus.Create;   //создание объекта класса modbus...
Agil := TAgilent.Create;
IniFile := TIniFile.Create('settings.ini');

Modbus.speed := StrToInt(IniFile.ReadString('Modbus', 'Speed', '115200'));
Modbus.port := IniFile.ReadString('Modbus', 'Port', 'COM2');
Modbus.minAddr := IniFile.ReadInteger('Modbus', 'minAddr', 10);

Verification.N := IniFile.ReadInteger('Verification', 'Attemts', 5);
Agil.ip := IniFile.ReadString('Agilent', 'IP', '192.168.103.103');
Edit1.Text := Agil.ip;


IniFile.Free;
end;

procedure TForm2.ComboBox4Change(Sender: TObject);
begin
  Modbus.minAddr := StrToInt(ComboBox4.Caption);
end;

procedure TForm2.Edit2Change(Sender: TObject);
var ctrlDots: integer;
begin
IniFile := TIniFile.Create('settings.ini');
ctrlDots := StrToInt(Edit2.Text);
Verification.N := ctrlDots;
IniFile.WriteInteger('Verification', 'Attemts', ctrlDots);
IniFile.free;
end;

procedure TForm2.Button3Click(Sender: TObject);
var IP: string;
begin
IniFile := TIniFile.Create('settings.ini');
IP := Edit1.Text;
IniFile.WriteString('Agilent', 'IP', IP);
IniFile.free;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin

end;

end.

