unit adc_class;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  ADC = Object
    Runtime: integer; { Время жизни платы в секундах }
    SPS: integer; //есть и коды для задачи
    Address: integer;//адрес устройства на шине
    selected: boolean; //выбрано ли устройство для работы с ним
    PGA: integer; //значение усилителя
    SerialNumber: string; //серийный номер объекта
    ErrorCounter: integer; //счетчик ошибок
    Errors: string; // ошибки нужно будет вывести таблицей в порядке возникновения
    virt: boolean; //режим виртуализации - если виртуальное - не посылать на объект и дать эхо ответ как будто живое устройство

  end;

implementation

end.

