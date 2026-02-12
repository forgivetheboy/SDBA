#glenn berry diag

Invoke-DbaDiagnosticQuery -SqlInstance chicco-pc -UseSelectionHelper -ExcludeDatabase Random500MB,DWQueue | Export-DbaDiagnosticQuery -Path X:\y
    