#spécifier le chemin de destinatation pour l'exportcsv
$ExportPath = $null

#prompt
$UOcible = Read-Host -Prompt ' Quelle est UO cible pour les utilisateurs à exporter ? (ex : OU=Standards,OU=Utilisateurs,DC=[CLIENT],DC=com) '
$UOgroup = Read-Host -Prompt " Quelle est UO contenant les groupes de l'utilisateur qui doit s'afficher ? (ex : OU=SHARE,OU=Globaux,OU=Groupes,DC=[CLIENT],DC=com) "

#var
$users = Get-ADUser -Filter * -Properties * | where { ($_.DistinguishedName -match $UOcible) } | Sort-Object -Property name
$group = Get-AdGroup -Filter * | where { ($_.DistinguishedName -match $UOgroup ) }

$dict = [ordered]@{ }
$tab = @()

foreach ( $objuser in $users )
{
    foreach ( $grup in $group.Name)
    {
        #liste de tous les groupes de l'user
        $line = Get-ADPrincipalGroupMembership -Identity $objuser.SamAccountName | where { ($_.name -match $grup ) }
        foreach($data in $line.name)
        {    
            if ($data -eq $grup){
                $tab += $data + ","
            }
        }
    }
    #ajoute une ligne contenant l'user + les groupes où il est membre de
    $dict.Add($objuser.DisplayName, $tab)

    #vider le tableau contenant les groupes de l'user
    $tab = $null
}
#export
$dict.GetEnumerator() | select Name, Value | export-csv -NoTypeInformation -Path $ExportPath = $null
