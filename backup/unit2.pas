unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, inifiles;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
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
var speed: integer;
begin

IniFile := TIniFile.Create('settings.ini');
speed := StrToInt(IniFile.ReadString('Modbus', 'Speed', '115200'));

end;

end.

