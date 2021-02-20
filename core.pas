unit core;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TModbus = Object
    fromAddress: integer; //адрес с которого проходит поиск по шине
    units: integer;  //число найденых объектов
    items: array[0..256] of byte; //массив объектов найденых на шине
    port: string;
    speed: integer;
    minAddr: integer; //минимальный адрес для начала поиска на плате
  end;

implementation

end.

