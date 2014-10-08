{*************************************************************}
{                                                             }
{       ��������������� ������ �� SQL ������� � DBase ����    }
{                                                             }
{        ��������� ��������� ������                           }
{          -srv=str      ��������� ���������� � sql-��������  }
{          -sql=file     ��� �����, ����������� SQL ������    }
{          -dbfstr=file  ���� �� ���������� ������������ dbf  }
{          -dbf=file     ���������� dbf-����                  }
{       Copyright (c) ������ �������                          }
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
  uCommandLine in 'uCommandLine.pas',
  uDbfTools in 'uDbfTools.pas',
  uQuery in 'uQuery.pas',
  uEvgLog in 'uEvgLog.pas';

var
  fParams: TCommandLine;
  fLog: IEvgLog;

function CopyToDBF: Boolean;
var
  fQry: TQuery;
  fDbf: TDBFExport;
begin
  result := false;
  fQry := TQuery.Create(fParams.GetParam('srv'));
  try
    fQry.Connect;
    fDbf := TDBFExport.Create(fParams.GetParam('dbfstr'), fParams.GetParam('dbf'));
    try
      if not fDbf.IsOk then Exit;
      result := fDbf.ExportFromDataSet(fQry.QueryFromFile(fParams.GetParam('sql')));
    finally
      fDbf.free;
    end;
  finally
    fQry.Free;
  end;
end;

begin
  if (CoInitialize(nil)=S_FALSE) then
      exit;
  fLog := GetLog;
  if assigned(fLog) then
    begin
      fLog.SetReopen(true);
      fLog.SetToConsole(true);
    end;
  fParams := TCommandLine.Create;
  try
    CopyToDbf;
  finally
    fParams.Free;
    fLog := nil;
    CoUninitialize;
  end;
end.
