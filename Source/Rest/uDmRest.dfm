object DmRest: TDmRest
  OldCreateOrder = False
  Height = 344
  Width = 411
  object rstClient: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'https://itunes.apple.com/search?media=music&term=jackjohnson'
    Params = <>
    RaiseExceptionOn500 = False
    Left = 80
    Top = 104
  end
  object rstRequest: TRESTRequest
    Client = rstClient
    Params = <>
    Response = rstResponse
    SynchronizedEvents = False
    Left = 120
    Top = 48
  end
  object rstResponse: TRESTResponse
    ContentType = 'text/javascript'
    Left = 168
    Top = 96
  end
  object rstAdapter: TRESTResponseDataSetAdapter
    Dataset = MemRest
    FieldDefs = <>
    Response = rstResponse
    Left = 120
    Top = 152
  end
  object MemRest: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired]
    UpdateOptions.CheckRequired = False
    Left = 120
    Top = 216
  end
  object Qry: TFDQuery
    Left = 304
    Top = 208
    object QryID: TIntegerField
      FieldName = 'ID'
    end
    object QryNome: TStringField
      FieldName = 'Nome'
      Size = 50
    end
    object QryCPF: TStringField
      FieldName = 'CPF'
    end
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 304
    Top = 160
  end
end
