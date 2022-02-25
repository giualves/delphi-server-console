inherited TituloService: TTituloService
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  Height = 204
  inherited fdConexao: TFDConnection
    Connected = True
  end
  object qryCobConf: TFDQuery
    Connection = fdConexao
    SQL.Strings = (
      
        '/*7340 - sel_cobconf_cedente - selecionar as informacoes do cede' +
        'nte do boleto*/'
      
        'select estab.*, cidade.nome CIDADENOME, uf.sigla, PORTADOR.AGENC' +
        'IA, PORTADOR.CONTA, '
      'cobconf.*'
      ' from cobconf'
      
        'inner join estab on (estab.id = coalesce(cobconf.estab_id, coale' +
        'sce(cobconf.infoestab_id, :ESTAB_ID)))'
      'left join cidade on cidade.id = estab.cidade_id'
      'left join uf on uf.id = cidade.uf_id'
      'left join PORTADOR on PORTADOR.ID = COBCONF.PORTADOR_ID'
      ''
      'where cobconf.id = :COBCONF_ID')
    Left = 104
    Top = 96
    ParamData = <
      item
        Name = 'ESTAB_ID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 3
      end
      item
        Name = 'COBCONF_ID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 3
      end>
  end
  object qryTitulo: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 32
    Top = 104
  end
end
