 # ご利用の環境にあわせて設定
$rg = 'YourResourceGroup'
$lbname = 'YourLoadBalancerName'
$subnet ='YourSubnetName'
$subscription = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

# 接続
$Conn = Get-AutomationConnection -Name 'AzureRunAsConnection' 
Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID `
-ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

Select-AzureRmSubscription -SubscriptionId $subscription -TenantId $Conn.tenantid 

# LB と BackendPool を取得、LB に空の BackendPool を事前作成しておく
$lb = Get-AzureRmLoadBalancer -ResourceGroupName $rg -Name $lbname
$beaddresspool = Get-AzureRmLoadBalancerBackendAddressPoolConfig -LoadBalancer $lb

# VM の NIC を取得
$nics =Get-AzureRmNetworkInterface -ResourceGroupName $rg | `
Where-Object {$_.IpConfigurations[0].Subnet.Id -match '.*/' + $subnet}

foreach($nic in $nics)
{
    # 各 NIC を LB のバックエンドプールへ追加
    $nic.IpConfigurations[0].LoadBalancerBackendAddressPools=$beaddresspool
    Set-AzureRmNetworkInterface -NetworkInterface $nic
} 
