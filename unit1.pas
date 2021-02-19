unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, Grids,
  CheckLst, ExtCtrls, PairSplitter, LazSerial, Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    LazSerial1: TLazSerial;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    StringGrid1: TStringGrid;
    procedure DrawGrid1Click(Sender: TObject);
    procedure LazSerial1RxData(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  Form2.show;

end;

procedure TForm1.DrawGrid1Click(Sender: TObject);
begin

end;

procedure TForm1.LazSerial1RxData(Sender: TObject);
begin

end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin

end;

end.

