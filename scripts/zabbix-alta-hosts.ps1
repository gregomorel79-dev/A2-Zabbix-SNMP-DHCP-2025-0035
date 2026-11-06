# Alta de R1, SW1 y SW2 en Zabbix 7.0 por API (ejecutar en PowerShell; cambiar ESA_IP por la IP de la web de Zabbix)
$zip = "ESA_IP"
$url = "http://$zip/api_jsonrpc.php"
function Z($m,$p,$tok){
  $h=@{"Content-Type"="application/json-rpc"}
  if($tok){$h["Authorization"]="Bearer $tok"}
  $b=@{jsonrpc="2.0";method=$m;params=$p;id=1} | ConvertTo-Json -Depth 10
  $r=Invoke-RestMethod -Uri $url -Method Post -Headers $h -Body $b
  if($r.error){throw ($r.error | ConvertTo-Json)}
  $r.result
}
$tok = Z "user.login" @{username="Admin";password="zabbix"} $null
$gid = (Z "hostgroup.create" @{name="LAB-A2-2025-0035"} $tok).groupids[0]
$t = Z "template.get" @{filter=@{host=@("Cisco IOS by SNMP")}} $tok
if(-not $t){ $t = Z "template.get" @{filter=@{host=@("Network Generic Device by SNMP")}} $tok }
$tid = $t[0].templateid
foreach($d in @(@("R1","10.20.35.1"),@("SW1","10.20.35.2"),@("SW2","10.20.35.3"))){
  Z "host.create" @{host=$d[0]; interfaces=@(@{type=2;main=1;useip=1;ip=$d[1];dns="";port="161";details=@{version=2;bulk=1;community="Zabbix2025"}}); groups=@(@{groupid=$gid}); templates=@(@{templateid=$tid})} $tok
}
