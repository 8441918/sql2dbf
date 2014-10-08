unit uEvgLog;

interface
uses
  syncobjs,
  classes, sysutils;

type IEvgLog = interface
  //имя файла лога - текущая дата. LogName - игнорируется
  procedure SetDayLog(isDay: Boolean);
  //если "" - каталог с программой
  procedure SetDirectory (dir: String);
  //если "" - имя программы + .log (игнорируется, если DayLog)
  procedure SetLogName (fn: String);
  //Файл открывается перед каждой записью и закрывается после нее
  procedure SetReopen(reopen: Boolean);
  //При записи в файл - также выводится в консоль
  procedure SetToConsole(cons: Boolean);
  procedure WriteString (const msg: String; wrDate: Boolean = false; wrTime: Boolean = false);
end;

function GetLog: IEvgLog;
procedure WriteString (const msg: String; wrDate: Boolean = false; wrTime: Boolean = false);

implementation


type TEvgLog = class (TInterfacedObject, IEvgLog)
  private
    fDayLog: Boolean;
    fLogDirectory: string;
    fLogName: String;
    fReopen: Boolean;
    fStream: TFileStream;
    fToConsole: Boolean;
    procedure CloseStream;
    function GetDateLogName: String;
    function OpenStream: Boolean;
    procedure SetDayLog(b: Boolean);
    procedure SetDirectory (s: String);
    procedure SetLogName (s: String);
    procedure SetReopen(b: Boolean);
    procedure SetToConsole(b: Boolean);
    procedure WriteMsg(const msg: String);
  public
    constructor Create();
    destructor Destroy; override;
    //Имя файл
    property FileName: String Read fLogName Write SetLogName;
    property DayLog: Boolean Read fDayLog Write SetDayLog;
    property Directory: String Read fLogDirectory Write SetDirectory;
    property Reopen: Boolean Read fReopen Write SetReopen;
    //выводить в консоль
    property ToConsole: Boolean Read fToConsole Write SetToConsole;
    procedure WriteString (const msg: String; wrDate: Boolean = false; wrTime: Boolean = false);
end;


constructor TEvgLog.Create;
begin
  inherited Create;
  FileName := '';
  Directory := '';
  fReopen := false;
  fDayLog := true;
  fToConsole := false;
end;

destructor TEvgLog.Destroy;
begin
  CloseStream;
  inherited Destroy;
end;

procedure TEvgLog.CloseStream;
begin
  if assigned (fStream) then FreeAndNil(fStream);
end;

function TEvgLog.GetDateLogName: String;
begin
  result := FormatDateTime('yyyymmdd',now) + '.log';  
end;

function TEvgLog.OpenStream: Boolean;
var fn : String;
  mode: Word;
begin
  result := true;
  if assigned(fStream) then exit;
  if fDayLog then fn := GetDateLogName else fn := FileName;
  fn := Directory + fn;
  if FileExists(fn) then
    mode := (fmOpenWrite or fmShareDenyWrite)
  else
    mode := (fmCreate or fmShareDenyWrite);
  fStream := TFileStream.Create(fn, mode);
  fStream.Seek(0,soFromEnd);
end;

procedure TEvgLog.SetDayLog(b: Boolean);
begin
  fDayLog := b;
end;

procedure TEvgLog.SetDirectory(s: string);
begin
  if (trim(s) = '') then
      s := ExtractFileDir(paramstr(0));
  fLogDirectory := IncludeTrailingPathDelimiter(s);
  ForceDirectories(fLogDirectory);
end;

procedure TEvgLog.SetLogName(s: string);
begin
  if trim(s) = '' then
      s := extractfilename(paramstr(0)) + '.log';
  fLogName := s;
end;

procedure TEvgLog.SetReopen(b: Boolean);
begin
  fReopen := b;
end;

procedure TEvgLog.SetToConsole(b: Boolean);
begin
  fToConsole := b;
end;

procedure TEvgLog.WriteMsg(const msg: string);
begin
  if not OpenStream then exit;
  fStream.Write(msg[1], length(msg));
  if fReopen then CloseStream;
end;

procedure TEvgLog.WriteString(const msg: string; wrDate, wrTime: Boolean);
var prfx, txtOut: String;
begin
  prfx := ' ';
  if wrDate then prfx := 'yyyymmdd ';
  if wrTime then prfx := prfx + 'hh:nn:ss ';
  txtOut := FormatDateTime(prfx, now) + msg;
  if fToConsole then WriteLn(txtOut);
  WriteMsg(txtOut + #13 + #10);
end;

///////////////////////////////////////////////////////////////////////////////
var
  Lock: TCriticalSection;
  _log: IEvgLog;

function GetLog: IEvgLog;
begin
  result := nil;
  Lock.Acquire;
  Try
    if not Assigned(_log) then
      _log := TEvgLog.Create;
    Result := _log;
  Finally
    Lock.Release;
  End;
end;

procedure WriteString(const msg: string; wrDate, wrTime: Boolean);
begin
  Lock.Acquire;
  try
    if not Assigned(_log) then
      _log := TEvgLog.Create;
    _log.WriteString(msg, wrDate, wrTime);
  finally
    Lock.Release;
  end;
end;

initialization
  Lock := TCriticalSection.Create;
finalization
  Lock.Free;


end.
