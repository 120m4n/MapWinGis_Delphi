unit uCore.Types;

interface

type
  TAppCommand = (
    acNone,
    acOpen,
    acLoadProject,
    acSaveProject,
    acSaveProjectAs,
    acCloseProject,
    acZoomIn,
    acZoomOut,
    acPan,
    acZoomMax,
    acZoomToLayer,
    acZoomToSelected,
    acSelect,
    acSelectByPolygon,
    acIdentify,
    acSetProjection,
    acAddVector,
    acAddRaster,
    acAddDatabase,
    acEditLayer,
    acSaveLayerEdits,
    acUndoEdits,
    acEditFields,
    acSnapshot,
    acMeasure,
    acMeasureArea,
    acClearSelection,
    acRemoveLayer,
    acSearch,
    acCloseApp
  );

  TProjectState = (
    psEmpty,
    psNoChanges,
    psHasChanges
  );

  TLayerType = (
    ltAll,
    ltVector,
    ltRaster,
    ltDatabase
  );

  TFileType = (
    ftProject,
    ftLayer,
    ftImage
  );

implementation

end.