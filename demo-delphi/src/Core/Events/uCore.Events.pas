unit uCore.Events;

interface

type
  TNewExtentEventArgs = record
    XMin: Double;
    YMin: Double;
    XMax: Double;
    YMax: Double;
  end;

  TOgrLayerEventArgs = record
    LayerHandle: Integer;
    LayerName: string;
  end;

  TSelectionChangedEventArgs = record
    LayerHandle: Integer;
    SelectionCount: Integer;
  end;

implementation

end.