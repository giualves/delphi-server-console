object Conexao: TConexao
  OldCreateOrder = False
  Height = 150
  Width = 215
  object fdConexao: TFDConnection
    Params.Strings = (
      'Database=D:\ControlGasDados\gas-giu.fdb'
      'User_Name=GAS'
      'Password=g@s'
      'DriverID=FB')
    Left = 40
    Top = 40
  end
end
