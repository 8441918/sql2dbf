{*************************************************************}
{                                                             }
{       Экспортирование данных из SQL сервера в DBase файл    }
{                                                             }
{        Параметры командной строки                           }
{          -srv=str      Параметры соединения с sql-сервером  }
{          -sql=file     Имя файла, содержащего SQL запрос    }
{          -dbfstr=file  Файл со структурой создаваемого dbf  }
{          -dbf=file     Получаемый dbf-файл                  }
{       Copyright (c) Куколь Евгений                          }
{                                                             }
{*************************************************************}
program sql2dbf;

{$APPTYPE CONSOLE}

uses
  classes,
  SysUtils,
  ActiveX,
  db,
  adodb,
  halcn6db,

  uCommandLine in 'uCommandLine.pas';

var
  fParams: TCommandLine;

function ConnectToServer: TAdoConnection;
var s: String;
begin
  result := nil;
  s := fParams.GetParam('srv');
  if s = '' then exit;
  result:= TAdoConnection.Create(nil);
  try
    result.ConnectionString := s;
    result.Connected := true;
  except
    on e: Exception do
      begin
        result.Free;
        result := nil;
      end;
  end;
end;

function CreateEmptyDbf: THalcyonDataset;
var
  s: String;
  crt : TCreateHalcyondataSet;
begin
  result := nil;
  s := fParams.GetParam('dbfstr');
  if (not FileExists(s) or (fParams.GetParam('dbf')='')) then exit;
  try
    result := THalcyonDataSet.Create(nil);
    result.TableName := fParams.GetParam('dbf');
    crt := TCreateHalcyonDataSet.Create(nil);
    try
      crt.DBFType := Clipper;
      crt.DBFTable := result;
      crt.AutoOverwrite := true;
      crt.CreateFields.LoadFromFile(s);
      crt.Execute;
    finally
      crt.Free;
    end;
  except
    if assigned(result) then
      begin
        result.Free;
        result := nil;
      end;
  end;


end;

function ExecuteQuery: TAdoQuery;
var sql: TStringList;
    s: String;
    cnct: TAdoConnection;
begin
  result := nil;
  s := fParams.GetParam('sql');
  if not fileexists(s) then exit;
  cnct := ConnectToServer;
  if not assigned(cnct) then exit;

  result := TAdoQuery.Create(nil);
  try

    result.Connection := cnct;
    sql := TStringList.Create;
    try
      sql.LoadFromFile(s);
      result.SQL.Text := sql.Text;
      result.Open;
    finally
      sql.Free;
    end;
  except
    on e: Exception do
      begin
        result.Free;
        result := nil;
      end;
  end;
end;

function CopyFields (const src: TFields; dst: TFields): Boolean;
var i: Integer;
    s: String;
begin
  result := false;
  for I := 0 to src.Count - 1 do
    begin
      s := src[i].FieldName;
      if (dst.FindField(s)<> nil) then
        dst.FieldByName(s).AsString := src.FieldByName(s).AsString;
    end;
end;

function CopyToDBF: Boolean;
var qry: TAdoQuery;
    dbf: THalcyonDataSet;
begin
  result := false;
  qry := nil;
  dbf := CreateEmptyDbf;
  if not assigned(dbf) then Exit;
  try
    qry := ExecuteQuery;
    if qry.Active then
      begin
        while not qry.Eof do
          begin
            dbf.Append;
              CopyFields(qry.Fields, dbf.Fields);
            dbf.Post;
            qry.Next;
          end;
      end;
  finally
    if assigned(dbf) then
      dbf.Free;
    if assigned(qry) then
      begin
        qry.Connection.Free;
        qry.Free;
      end;
  end;
  
  
end;

begin
  if (CoInitialize(nil)=S_FALSE) then
    begin
      exit;
    end;
  fParams := TCommandLine.Create;
  try
    CopyToDbf;
  finally
    fParams.Free;
    CoUninitialize;
  end;
end.
