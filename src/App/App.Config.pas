unit App.Config;

interface

type
  TDatabaseConfig = record
    DriverID: string;
    Server: string;
    Database: string;
    UserName: string;
    Password: string;
    CharacterSet: string;
    Protocol: string;
  end;

  TAppConfig = class
  private
    class function ArquivoConfig: string; static;
    class procedure CriarArquivoPadrao(const AArquivo: string); static;
  public
    class function LerDatabaseConfig: TDatabaseConfig; static;
  end;

implementation

uses
  System.SysUtils,
  System.IniFiles,
  System.IOUtils;

{ TAppConfig }

class function TAppConfig.ArquivoConfig: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'config.ini');
end;

class procedure TAppConfig.CriarArquivoPadrao(const AArquivo: string);
var
  LIni: TIniFile;
begin
  LIni := TIniFile.Create(AArquivo);
  try
    LIni.WriteString('Database', 'DriverID', 'FB');
    LIni.WriteString('Database', 'Server', '');
    LIni.WriteString('Database', 'Database', 'C:\Delphi\projeto\data\TESTE_CRIACAO.FDB');
    LIni.WriteString('Database', 'UserName', 'SYSDBA');
    LIni.WriteString('Database', 'Password', 'masterkey');
    LIni.WriteString('Database', 'CharacterSet', 'ISO8859_1');
    LIni.WriteString('Database', 'Protocol', 'Local');
  finally
    LIni.Free;
  end;
end;

class function TAppConfig.LerDatabaseConfig: TDatabaseConfig;
var
  LIni: TIniFile;
  LArquivo: string;
begin
  LArquivo := ArquivoConfig;

  if not TFile.Exists(LArquivo) then
    CriarArquivoPadrao(LArquivo);

  LIni := TIniFile.Create(LArquivo);
  try
    Result.DriverID := LIni.ReadString('Database', 'DriverID', 'FB');
    Result.Server := LIni.ReadString('Database', 'Server', '');
    Result.Database := LIni.ReadString('Database', 'Database', 'C:\Delphi\projeto\data\TESTE_CRIACAO.FDB');
    Result.UserName := LIni.ReadString('Database', 'UserName', 'SYSDBA');
    Result.Password := LIni.ReadString('Database', 'Password', 'masterkey');
    Result.CharacterSet := LIni.ReadString('Database', 'CharacterSet', 'ISO8859_1');
    Result.Protocol := LIni.ReadString('Database', 'Protocol', 'Local');
  finally
    LIni.Free;
  end;
end;

end.

