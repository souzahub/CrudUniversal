{* By Luan Souza de Siqueira
 * Data Criação - 29/08/2024
 * Release - 29/08/2024
}
unit uCrudUniversal;

interface

uses
  Data.DB, FireDAC.Comp.Client, System.Variants, System.SysUtils;

type
  TCrudUniversal = class
  private
    FQuery: TFDQuery;
  public
    constructor Create(AQuery: TFDQuery);
    procedure Insert(const Tabela: string; const Campos: array of string; const Valor: array of Variant);
    procedure Update(const Tabela: string; const Campos: array of string; const Valor: array of Variant; const Condition: string);
    procedure Delete(const Tabela: string; const Condicao: string);
//    procedure Select(const Tabela: string; const Campos: array of string; const Condition: string);
  end;

implementation

constructor TCrudUniversal.Create(AQuery: TFDQuery);
begin
  FQuery := AQuery;
end;

procedure TCrudUniversal.Insert(const Tabela: string; const Campos: array of string; const Valor: array of Variant);
var
  SQL, FieldList, ValueList: string;
  i: Integer;
begin
  FieldList := '';
  ValueList := '';

  // Construir a lista de campos e os placeholders de parâmetros
  for i := Low(Campos) to High(Campos) do
  begin
    FieldList := FieldList + Campos[i];
    ValueList := ValueList + ':' + Campos[i];
    if i < High(Campos) then
    begin
      FieldList := FieldList + ', ';
      ValueList := ValueList + ', ';
    end;
  end;

  SQL := 'INSERT INTO ' + Tabela + ' (' + FieldList + ') VALUES (' + ValueList + ')';

  // Preparar e executar a consulta
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add(SQL);

  for i := Low(Valor) to High(Valor) do
  begin
    // Detectar o tipo de dado e definir o tipo do parâmetro
    case VarType(Valor[i]) of
      varUString, varOleStr, varString:
        FQuery.Params[i].DataType := ftString;
      varDouble, varCurrency:
        FQuery.Params[i].DataType := ftFloat;
      varInteger, varSmallint:
        FQuery.Params[i].DataType := ftInteger;
      // Adicione mais tipos de dados conforme necessário
    else
      raise Exception.Create('Tipo de dado não suportado.');
    end;

    FQuery.Params[i].Value := Valor[i];

  end;

  FQuery.ExecSQL;

end;

procedure TCrudUniversal.Update(const Tabela: string; const Campos: array of string; const Valor: array of Variant; const Condition: string);
var
  SQL, UpdateList: string;
  i: Integer;
begin
  UpdateList := '';

  // Construir a lista de campos e os placeholders de parâmetros para o UPDATE
  for i := Low(Campos) to High(Campos) do
  begin
    UpdateList := UpdateList + Campos[i] + ' = :' + Campos[i];
    if i < High(Campos) then
      UpdateList := UpdateList + ', ';
  end;

  SQL := 'UPDATE ' + Tabela + ' SET ' + UpdateList + ' WHERE ' + Condition;

  // Preparar e executar a consulta
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add(SQL);

  for i := Low(Valor) to High(Valor) do
  begin

    // Detectar o tipo de dado e definir o tipo do parâmetro
    if VarType(Valor[i]) = varString then
      FQuery.Params[i].DataType := ftString
    else if VarType(Valor[i]) in [varDouble, varCurrency] then
      FQuery.Params[i].DataType := ftFloat
    else if VarType(Valor[i]) = varInteger then
      FQuery.Params[i].DataType := ftInteger;

    // Adicione mais verificações de tipo aqui conforme necessário
    FQuery.Params[i].Value := Valor[i];

  end;

  FQuery.ExecSQL;

end;

procedure TCrudUniversal.Delete(const Tabela: string; const Condicao: string);
begin

  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('DELETE FROM ' + Tabela + ' WHERE ' + Condicao);
  FQuery.ExecSQL;

end;

//procedure TCrudUniversal.Select(const Tabela: string; const Campos: array of string; const Condition: string);
//begin
//  FQuery.Close;
//  FQuery.SQL.Clear;
//  FQuery.SQL.Add('SELECT ' + (Campos) + ' FROM ' + Tabela + ' WHERE ' + Condition);
//  FQuery.Open;
//end;

end.

//para utilixar
{

var
  CrudUniversal: TCrudUniversal;
begin
  CrudUniversal := TCrudUniversal.Create(dmDados.FDAuxiliar); // Chamada da classe CrudUniversal

  // Inserir um novo registro com diferentes tipos de dados
  CrudUniversal.Insert('GRUPOS',
    ['NOME', 'DESCRICAO', 'FOTO', 'VALOR'],
    [edNome.Text, edDescricao.Text, edFoto.Text, 123.45]);
  CrudUniversal.Free;

  // Update
    // Atualizar um registro com diferentes tipos de dados
    CrudUniversal.Update('GRUPOS',
      ['NOME', 'DESCRICAO', 'VALOR'],
      [edNome.Text, edDescricao.Text, 123.45],
      'ID = 1');
    CrudUniversal.Free;



  // Deletar um registro
  CRUDHelper.Delete('GRUPOS', 'ID = 1');
  CrudUniversal.Free;

  // Selecionar registros
  CRUDHelper.Select('GRUPOS', ['NOME', 'DESCRICAO', 'FOTO'], 'ID > 0');
  CrudUniversal.Free;

end;



}
