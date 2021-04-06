unit MathCore;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

//source http://forum.pascal.net.ru/index.php?showtopic=27123
type matrix=array of array of real;
     vector=array of real; {Нумеруем точки с нуля + добавляем динамичности в размерности точек}

type TMNK = class       //метод наименьших квадратов как класс для внешнего использования
  n,m,k,i:integer;
  x,f,c:vector;
  a:matrix;
  x0,x9,h,x1:real;
  function ex (a:real; n:integer):real;
  procedure Gram (n,m:integer; var x,f:vector; var a:matrix);
  procedure Gauss(n:integer; var a:matrix; var x:vector);
  function fi (m:integer; var c:vector; x1:real):real;
  procedure setNM(n:integer, m:integer); //число экспериментальных точек, m - значение степени полинома, c - коэффициенты полинома.
  procedure test; //определение тестовых данных и степени полинома
  end;

implementation

function TMNK.ex (a:real; n:integer):real;
 {Показательная функция для формирования матрицы Грама}
var i:integer;
    e:real;
begin
 e:=1;
 for i:=1 to n do e:=e*a;
 ex:=e;
end;

procedure TMNK.Gram (n,m:integer; var x,f:vector; var a:matrix);
{Формирование матрицы Грама A по векторам данных X,F}
var i,j:integer;
    p,q,r,s:real;
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

procedure TMNK.Gauss(n:integer; var a:matrix; var x:vector);
{Решение СЛАУ методом Гаусса}
{a - расширенная матрица системы, x - вектор результата}
var i,j,k,l,k1,n1:integer;
    r,s:real;
begin
 {Прямой ход:}
 n1:=n+1;
 for k:=0 to n do begin
  k1:=k+1;
  s:=a[k,k];
  for j:=k1 to n1 do a[k,j]:=a[k,j]/s;
  for i:=k1 to n do begin
   r:=a[i,k];
   for j:=k1 to n1 do a[i,j]:=a[i,j]-a[k,j]*r;
  end;
 end;
 {Обратный ход:}
 for i:=n downto 0 do begin
  s:=a[i,n1];
  for j:=i+1 to n do s:=s-a[i,j]*x[j];
  x[i]:=s;
 end;
end;


procedure TMNK.test;
begin
 //загоняем значения сюда и вычисляем полином. определяем значение в промежуточной точке

end;

procedure TMNK.setNM(n:integer, m:integer);
//выставление степени полинома и числа экспериментальных точек\
var i: integer;
begin
 SetLength(a, n + 1);
 for i := 0 to n do
      SetLength(a[i], n+1);
 SetLength(x, n + 1);
 SetLength(f, n + 1);
 SetLength(c, n + 1);

end;

function TMNK.fi (m:integer; var c:vector; x1:real):real;
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

