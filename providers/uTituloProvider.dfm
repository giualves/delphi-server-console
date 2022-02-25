object TituloProvider: TTituloProvider
  OldCreateOrder = False
  Height = 150
  Width = 215
  object fdTitulo: TFDQuery
    SQL.Strings = (
      'select * from titulo t where t.id = :ID')
    Left = 136
    Top = 32
    ParamData = <
      item
        Name = 'ID'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
  end
end
