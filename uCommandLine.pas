unit uCommandLine;

interface
uses
  classes, sysutils, iniFiles;
type TCommandLine = class
  private
    fParams : THashedStringList;
    function ParseCmdLine: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function GetParam (const name: String): String;
end;

implementation

constructor TCommandLine.Create;
begin
  inherited Create;
  fParams := THashedStringList.Create;
  ParseCmdLine;
end;

destructor TCommandLine.Destroy;
begin
  fParams.Free;
  inherited Destroy;
end;

function TCommandLine.GetParam(const name: string): String;
var k: Integer;
begin
  result := '';
  k := fParams.IndexOfName(name);
  if k = -1 then exit;
  result := fParams.ValueFromIndex[k];
end;

function TCommandLine.ParseCmdLine: Boolean;
var cnt: Integer;
  s: string;
begin
  result := false;
  if (not assigned(fParams) or (paramcount = 0)) then exit;
  cnt := 1;
  while cnt <= paramcount  do
    begin
      s := paramstr(cnt);
      if ((length(trim(s)) > 1) and (copy(s,1,1)='-')) then
        begin
          s := copy(s,2, length(s)-1);
          fParams.Add(s);
        end;
      inc(cnt);
    end;
    result := true;
end;



end.
