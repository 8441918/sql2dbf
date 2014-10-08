unit uDbfTools;

interface
uses
  classes, sysutils,
  uEvgLog,
  db,halcn6db;
type TDBFExport = class
  private
    fTable: THalcyonDataSet;
    procedure CopyFields(const fld: TFields);
    function CreateEmpty(const structFile: String): Boolean;
    procedure FreeTable;
  public
    constructor Create (const structFile, outFile: String);
    destructor Destroy; override;
    function ExportFromDataSet(ds: TDataSet): Boolean;
    function IsOk: Boolean;
end;
implementation

constructor TDBFExport.Create(const structFile: string; const outFile: string);
begin
  inherited Create;
  if not FileExists(structFile) then
    begin
      WriteString('DBF: structure not found', false, true);
      exit;
    end;
  try
    fTable := THalcyonDataSet.Create(nil);
    fTable.TableName := outFile;
    if not CreateEmpty(structFile) then FreeTable;
  except
    on e: Exception do
      WriteString('DBF: ' + e.Message, false, true);
  end;
end;

destructor TDBFExport.Destroy;
begin
  FreeTable;
  inherited Destroy;
end;

procedure TDBFExport.CopyFields(const fld: TFields);
var i: Integer;
    s: String;
begin
  for I := 0 to fld.Count - 1 do
    begin
      s := fld[i].FieldName;
      if (fTable.Fields.FindField(s)<> nil) then
        fTable.Fields.FieldByName(s).AsString := fld[i].AsString;
    end;
end;

function TDBFExport.CreateEmpty(const structFile: string): Boolean;
var
  crt : TCreateHalcyondataSet;
begin
  result := false;
  try
    crt := TCreateHalcyonDataSet.Create(nil);
    try
      crt.DBFType := Clipper;
      crt.DBFTable := fTable;
      crt.AutoOverwrite := true;
      crt.CreateFields.LoadFromFile(structFile);
      crt.Execute;
      result := true;
    finally
      crt.Free;
    end;
  except
    on e: Exception do
      begin
        WriteString('DBF.CreateEmpty: ' + e.Message, false, true);
      end;
  end;
end;

function TDBFExport.ExportFromDataSet(ds: TDataSet): Boolean;
begin
  result := false;
  if not assigned(ds) or not ds.Active then exit;
  while not ds.Eof do
    begin
      fTable.Append;
      CopyFields(ds.Fields);
      fTable.Post;
      ds.Next;
    end;
  result := true;
end;

procedure TDBFExport.FreeTable;
begin
  if assigned(fTable) then
    FreeAndNil(fTable);
end;

function TDBFExport.IsOk: Boolean;
begin
  result := assigned(fTable);
end;
end.
