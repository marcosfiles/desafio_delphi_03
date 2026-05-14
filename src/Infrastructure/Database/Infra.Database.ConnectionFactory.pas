unit Infra.Database.ConnectionFactory;

interface

uses
  FireDAC.Comp.Client;

type
  TConnectionFactory = class
  public
    class function CriarConexao: TFDConnection; static;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  App.Config,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.DApt;

{ TConnectionFactory }

class function TConnectionFactory.CriarConexao: TFDConnection;
var
  LConfig: TDatabaseConfig;
  LDatabase: string;
begin
  LConfig := TAppConfig.LerDatabaseConfig;
  LDatabase := LConfig.Database;

  if ExtractFileDrive(LDatabase) = '' then
    LDatabase := TPath.Combine(ExtractFilePath(ParamStr(0)), LDatabase);

  Result := TFDConnection.Create(nil);
  try
    Result.LoginPrompt := False;

    Result.Params.Clear;
    Result.Params.DriverID := LConfig.DriverID;
    Result.Params.Database := LDatabase;
    Result.Params.UserName := LConfig.UserName;
    Result.Params.Password := LConfig.Password;

    if LConfig.Server <> '' then
      Result.Params.Values['Server'] := LConfig.Server;

    Result.Params.Values['CharacterSet'] := LConfig.CharacterSet;
    Result.Params.Values['Protocol'] := LConfig.Protocol;

    Result.Connected := True;
  except
    Result.Free;
    raise;
  end;
end;

end.

