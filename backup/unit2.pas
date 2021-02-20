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
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Label4Click(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;
  IniFile: TINIFile; //file of settings
  Modbus: TModbus; //Настройки шины с модулями АЦП
implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.Label4Click(Sender: TObject);
begin

end;

procedure TForm2.FormCreate(Sender: TObject);

begin

IniFile := TIniFile.Create('settings.ini');
Modbus.speed := StrToInt(IniFile.ReadString('Modbus', 'Speed', '115200'));
Modbus.port := IniFile.ReadString('Modbus', 'Port', 'COM2');
Modbus.minAddr := StrToInt(IniFile.ReadSection('Modbus', 'minAddr', '10'));
IniFile.Free;
end;

end.

