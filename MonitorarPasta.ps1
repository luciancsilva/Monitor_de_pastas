$folderPath = "C:\\Users\\lucia\\Downloads"
$logFile = "C:\\Users\\lucia\\Desktop\\log.txt"

function Get-FolderTree {
   param (
       [string]$path,
       [string]$indent = ""
   )
   
   Get-ChildItem -Path $path | ForEach-Object {
       if ($_.PSIsContainer) {
           "$indent+-- [$($_.Name)]" | Add-Content -Path $logFile
           Get-FolderTree -path $_.FullName -indent "$indent    "
       } else {
           "$indent+-- $($_.Name)" | Add-Content -Path $logFile
       }
   }
}

$initialState = Get-ChildItem -Recurse -Path $folderPath | Select-Object Name, FullName, PSIsContainer

while ($true) {
   Start-Sleep -Seconds 10
   $currentState = Get-ChildItem -Recurse -Path $folderPath | Select-Object Name, FullName, PSIsContainer
   
   $differences = Compare-Object -ReferenceObject $initialState -DifferenceObject $currentState -Property Name, FullName, PSIsContainer
   
   if ($differences) {
       $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
       "Alteracoes detectadas em $timestamp" | Add-Content -Path $logFile
       
       foreach ($diff in $differences) {
           $status = if ($diff.SideIndicator -eq "=>") {"Adicionado"} else {"Removido"}
           $name = if ($diff.PSIsContainer) {"[$($diff.Name)]"} else {$diff.Name}
           "$status - $name" | Add-Content -Path $logFile
       }
       
       "Estrutura Atual da Pasta" | Add-Content -Path $logFile
       Get-FolderTree -path $folderPath
       $initialState = $currentState
   }
}