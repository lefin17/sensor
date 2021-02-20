unit adc_class;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  ADC = Object
    livetime: integer; { Время жизни платы в секундах }
    SPS: integer; //есть и коды для задачи
    address: integer;//адрес устройства на шине
    selected: boolean; //выбрано ли устройство для работы с ним
    PGA: integer; //значение усилителя
    virt: boolean; //режим виртуализации - если виртуальное - не посылать на объект и дать эхо ответ как будто живое устройство

  end;

implementation

end.

