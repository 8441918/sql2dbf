unit uQuery;

interface
uses
  sysutils, classes,
  uEvgLog,
  db, adodb;
type TQuery = class
  private
    fConnect: TAdoConnection;
    fQry: TAdoQuery;
  public
    constructor Create (const connectStr: String);
    destructor Destroy; override;
    procedure Connect;
    function IsConnected: Boolean;
    function Query(const sql: string): TDataSet;
    function QueryFromFile (const fn: string): TDataSet;
    procedure ReleaseQuery;
end;
implementation

constructor TQuery.Create (const connectStr: String);
begin
  inherited Create;
  fConnect := TAdoConnection.Create(nil);
  fConnect.ConnectionString := connectStr;
end;

destructor TQuery.Destroy;
begin
  ReleaseQuery;
  fConnect.Free;
  inherited Destroy;
end;

procedure TQuery.Connect;
begin
  try
    if not assigned(fConnect) then
      begin
       WriteString('Connect: fConnect not assigned', false, true);
       Exit;
      end;
    fConnect.Connected := true;
    WriteString('Connected.', false, true);
  except
    on e: Exception do
      begin
        WriteString('Connect: ' + e.Message, false, true);
      end;
  end;
end;

function TQuery.IsConnected: Boolean;
begin
  if not assigned(fConnect) then
     result := false
  else
     result := fConnect.Connected;
end;

function TQuery.Query(const sql: string): TDataSet;
begin
  result := nil;
  try
    ReleaseQuery;
    if ((trim(sql) = '') or (not IsConnected)) then
      begin
       WriteString('Query: SQL empty or not connected', false, true);
       exit;
      end;
    try
      fQry:= TAdoQuery.Create(nil);
      fQry.Connection := fConnect;
      fQry.SQL.Text := sql;
      fQry.Open;
      WriteString('Query executed. ' + IntToStr(fQry.RecordCount)+ ' records', false, true);
    except
       on e: Exception do
        begin
          WriteString('Query: ' + e.Message, false, true);
          ReleaseQuery;
        end;
    end;
  finally
    result := fQry;
  end;
end;

function TQuery.QueryFromFile(const fn: string): TDataSet;
var ts: TStringList;
begin
  result := nil;
  if not fileexists(fn) then exit;
  ts:= TStringList.Create;
  try
    ts.LoadFromFile(fn);
    result := Query(ts.Text);
  finally
    ts.Free;
  end;
end;

procedure TQuery.ReleaseQuery;
begin
  if assigned(fQry) then FreeAndNil(fQry);
end;


end.
