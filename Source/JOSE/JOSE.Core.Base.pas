{******************************************************************************}
{                                                                              }
{  Delphi JOSE Library                                                         }
{  Copyright (c) 2015 Paolo Rossi                                              }
{  https://github.com/paolo-rossi/delphi-jose-jwt                              }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}

/// <summary>
///   Base class for the JOSE entities
/// </summary>
unit JOSE.Core.Base;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  JOSE.Types.Bytes,
  JOSE.Types.JSON;

const
  PART_SEPARATOR: Char = '.';

type
  EJOSEException = class(Exception);

  TJOSEBase = class
  private
    function GetEncoded: TJOSEBytes;
    function GetURLEncoded: TJOSEBytes;
    procedure SetEncoded(const Value: TJOSEBytes);
    procedure SetURLEncoded(const Value: TJOSEBytes);
  protected
    FJSON: TJSONObject;

    procedure AddPairOfType<T>(const AName: string; const AValue: T);
  public
    constructor Create;
    destructor Destroy; override;

    function Clone: TJSONObject;

    property JSON: TJSONObject read FJSON write FJSON;
    property Encoded: TJOSEBytes read GetEncoded write SetEncoded;
    property URLEncoded: TJOSEBytes read GetURLEncoded write SetURLEncoded;
  end;

function ToJSON(Value: TJSONAncestor): string;

implementation

uses
  System.JSON,
  JOSE.Encoding.Base64;

{$IF CompilerVersion >= 28}
function ToJSON(Value: TJSONAncestor): string;
begin
  Result := Value.ToJson;
end;
{$ELSE}
function ToJSON(Value: TJSONAncestor): string;
var
  LBytes: TBytes;
  LLen: Integer;
begin
  SetLength(LBytes, Value.EstimatedByteSize);
  LLen := Value.ToBytes(LBytes, 0);
  Result := TEncoding.UTF8.GetString(LBytes, 0, LLen);
end;
{$ENDIF}

{ TJOSEBase }

function TJOSEBase.Clone: TJSONObject;
begin
  Result := FJSON.Clone as TJSONObject;
end;

constructor TJOSEBase.Create;
begin
  FJSON := TJSONObject.Create;
end;

destructor TJOSEBase.Destroy;
begin
  FJSON.Free;
  inherited;
end;

function TJOSEBase.GetEncoded: TJOSEBytes;
begin
  Result := TBase64.Encode(ToJSON(FJSON));
end;

function TJOSEBase.GetURLEncoded: TJOSEBytes;
begin
  Result := TBase64.URLEncode(ToJSON(FJSON));
end;

procedure TJOSEBase.SetEncoded(const Value: TJOSEBytes);
var
  LJSONStr: TJOSEBytes;
begin
  LJSONStr := TBase64.Decode(Value);
  FJSON.Parse(LJSONStr, 0)
end;

procedure TJOSEBase.SetURLEncoded(const Value: TJOSEBytes);
var
  LJSONStr: TJOSEBytes;
  LValue: TJSONValue;
begin
  LJSONStr := TBase64.URLDecode(Value);
  LValue := TJSONObject.ParseJSONValue(LJSONStr.AsBytes, 0, True);

  if Assigned(LValue) then
  begin
    FJSON.Free;
    FJSON := LValue as TJSONObject;
  end;

end;

procedure TJOSEBase.AddPairOfType<T>(const AName: string; const AValue: T);
begin
  TJSONUtils.SetJSONValueFrom<T>(AName, AValue, FJSON);
end;

end.
