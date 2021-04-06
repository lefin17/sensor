unit MathCore;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

//source http://forum.pascal.net.ru/index.php?showtopic=27123
type matrix = array of array of Double;
     vector = array of Double; {Нумеруем точки с нуля + добавляем динамичности в размерности точек}

type TMNK = class       //метод наименьших квадратов как класс для внешнего использования
  n,m:integer;
  x,f,c:vector;
  a:matrix;
  x0,x9,h:Double;
  function ex (b:Double; power:integer):Double;
  procedure Gram;
  procedure Gauss;
  function fi (x1:Double):Double;
  procedure setNM(Dots:integer; power:integer); //число экспериментальных точек, m - значение степени полинома, c - коэффициенты полинома.
  procedure test(power: integer); //определение тестовых данных и степени полинома
  end;

implementation

function TMNK.ex (b:Double; power:integer):Double;
 {Показательная функция для формирования матрицы Грама}
var i:integer;
    e:Double;
begin
 e:=1;
 for i:=1 to power do e:=e*b;
 ex:=e;
end;

procedure TMNK.Gram ();
// procedure TMNK.Gram (n,m:integer; var x,f:vector; var a:matrix);
{Формирование матрицы Грама A по векторам данных X,F}
var i,j:integer;
    p,q,r,s:Double;
begin
 for j:=0 to m do begin
  s:=0; r:=0; q:=0;
  for i:=0 to n do begin
   p:=ex(x[i],j);
   s:=s+p;
   r:=r+p*f[i];
   q:=q+p*ex(x[i],m);
  end;
  a[0,j]:=s;
  a[j,m]:=q;
  a[j,m+1]:=r;
 end;
 {Надо формировать только 1-ю строку и 2 последних столбца матрицы Грама,
  остальные элементы легко получить циклическим копированием:
  + нужно динамически выделять память под массив данных}
 for i:=1 to m do
 for j:=0 to m-1 do a[i,j]:=a[i-1,j+1];
end;

procedure TMNK.Gauss();
//procedure TMNK.Gauss(n:integer; var a:matrix; var x:vector);
{Решение СЛАУ методом Гаусса}
{a - расширенная матрица системы, x - вектор результата (здесь должно быть c)}
var i,j,k,l,k1,n1:integer;
    r,s:Double;
begin
 {Прямой ход:}
 n1:=m+1;
 for k:=0 to m do begin
  k1:=k+1;
  s:=a[k,k];
  for j:=k1 to n1 do if (s <> 0) then a[k,j]:=a[k,j]/s;
  for i:=k1 to m do begin
   r:=a[i,k];
   for j:=k1 to n1 do a[i,j]:=a[i,j]-a[k,j]*r;
  end;
 end;
 {Обратный ход:}
 for i:=m downto 0 do begin
  s:=a[i,n1];
  for j:=i+1 to m do s:=s-a[i,j]*c[j];
  c[i]:=s;
 end;
end;


procedure TMNK.test(power: integer);
begin
 //загоняем значения сюда и вычисляем полином. определяем значение в промежуточной точке
//  procedure InputData (n:integer; var x,f:vector); {Ввод исходных данных}
//begin
//for i:=0 to n do begin
//  write ('Введите пару значений X(',i,'),F(',i,'):');
//  readln (x[i],f[i]);
// end;
// end; }
setNM(11, power);

x[0] := 0.000423789024353;
x[1] := 0.500779151916504;
x[2] := 1.00206851959229 ;
x[3] := 1.50345921516418 ;
x[4] := 2.00470924377441 ;
x[5] := 2.50648856163025 ;
x[6] := 3.00470530986786 ;
x[7] := 3.49787652492523 ;
x[8] := 3.99551510810852 ;
x[9] := 4.49537575244904 ;
x[10] := 4.99807238578796;

f[0] := 0.00043228028;
f[1] := 0.499946803  ;
f[2] := 1.00014863   ;
f[3] := 1.5005835    ;
f[4] := 2.0007813    ;
f[5] := 2.49974587   ;
f[6] := 3.00084234   ;
f[7] := 3.50008043   ;
f[8] := 4.00023171   ;
f[9] := 4.5014619    ;
f[10] := 5.00085153  ;

end;

procedure TMNK.setNM(Dots:integer; Power:integer);
//выставление степени полинома и числа экспериментальных точек\
var i: integer;
begin
 n := Dots + 1;
 m := Power;
 SetLength(a, n + 2);
 for i := 0 to (n + 2) do
      SetLength(a[i], n + 2);
 SetLength(x, n + 2);
 SetLength(f, n + 2);
 SetLength(c, n + 2);

end;

function TMNK.fi (x1:Double):Double;
{Аппроксимирующая функция по найденным коэффициентам МНК}
{m - степень полинома, c - вектор коэффициентов,
 x1 - точка, в которой ищем значение}
var i:integer; p:real;
begin
 p:=c[m];
 for i:=m-1 downto 0 do p:=c[i]+x1*p;
 fi:=p;
end;

end.

