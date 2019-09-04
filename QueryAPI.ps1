Param(
    [Parameter(Mandatory=$false)]
    [string]$apiKey = "**********",
    [Parameter(Mandatory=$false)]
    [string]$apiSecret = "**********"
)
 
Add-Type –assemblyName PresentationFramework;
Add-Type –assemblyName PresentationCore;
Add-Type –assemblyName WindowsBase;
Add-Type -AssemblyName System.Windows.Forms;
 
[xml]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MainWindow" WindowStyle="None" SizeToContent="WidthAndHeight" WindowStartupLocation="CenterScreen">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto" />
            <ColumnDefinition Width="Auto" />
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <Label Grid.Column="0" Grid.Row="0" Grid.ColumnSpan="3" Content="Type or paste list of HP computer serial numbers below, each on a new line:"/>
        <TextBox Grid.Column="0" Grid.Row="1" Grid.ColumnSpan="3" Name="txtBoxSerials" TextWrapping="Wrap" HorizontalScrollBarVisibility="Disabled" VerticalScrollBarVisibility="Auto" Width="500" Height="500" AcceptsReturn="True" Margin="5,5,5,5"/>
        <Button Grid.Column="1" Grid.Row="2" Content="OK" Name="btnOK" VerticalAlignment="Center" Width="100" Margin="0,0,5,5" />
        <Button Grid.Column="2" Grid.Row="2" Content="Cancel" Name="btnCancel" VerticalAlignment="Center" Width="100" Margin="0,0,5,5" />
    </Grid>
</Window>
"@
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml);
$Window=[Windows.Markup.XamlReader]::Load($reader);
 
$txtBoxSerials = $Window.FindName('txtBoxSerials');
$btnOK = $Window.FindName('btnOK');
$btnCancel = $Window.FindName('btnCancel');
 
$btnOK.add_click({
    $script:items = @(($txtBoxSerials.Text.Trim()).Split("`n").Trim());
    $Window.Close();
});
 
$btnCancel.add_click({
    $Window.Close();
    exit;
});
 
$Window.ShowDialog() | Out-Null;
 
$hasInvalid = $false;
$items | % {
    if($_ -notmatch "^\w+$") {$hasInvalid = $true}
}
 
if($hasInvalid) {
    Write-Host "No serial numbers or invalid serial numbers have been provided, process will terminate" -ForegroundColor Red;
}
else {
    # Get access token
    Write-Host "Retrieving HP API access token" -ForegroundColor Green;
    $body = @{
        apiKey = $apiKey;
        apiSecret = $apiSecret;
        grantType = "client_credentials";
        scope = "warranty";
    }
    try {
        $result = Invoke-RestMethod -Method Post -Uri "https://css.api.hp.com/oauth/v1/token" -ContentType "application/x-www-form-urlencoded" -Body $body;
        $script:accessToken = $result.Root.access_token;
        Write-Host "Successfully retrieved HP API access token: $($accessToken)" -ForegroundColor Green;
    } catch {
        Write-Host "Error encountered getting access token, description: $($_.Exception.Response.StatusDescription), status code: $($_.Exception.Response.StatusCode.value__), process will terminate" -ForegroundColor Red;
        exit;
    }
 
    #  Create bulk job
    Write-Host "Submitting bulk warranty request to API" -ForegroundColor Green;
    $headers = @{
        Authorization = "basic $($accessToken)";
    }
    $arr = @();
    $items | % {
        $arr += "{`"sn`": `"$($_)`"}";
    }
    $json = "[ $($arr -join ",") ]";
 
    try {
        $result = Invoke-RestMethod -Method Post -Uri "https://css.api.hp.com/productWarranty/v1/jobs" -ContentType "application/json" -Body $json -Headers $headers;
    }
    catch {
        Write-Host "Error encountered submitting bulk warranty request, description: $($_.Exception.Response.StatusDescription), status code: $($_.Exception.Response.StatusCode.value__), process will terminate" -ForegroundColor Red;
        exit;
    }
 
    # Wait for job completion
    if($result.jobId) {
        $jobId = $result.jobId;
        Write-Host "Job successfully submitted, job id: $($jobId), estimated time: $($result.estimatedTime) seconds, retrieving job status every 5 minutes until complete, please wait" -ForegroundColor Green;
        do {
            Start-Sleep -Seconds (60*5);
            try {
                $result = Invoke-RestMethod -Method Get -Uri "https://css.api.hp.com/productWarranty/v1/jobs/$($jobId)" -ContentType "application/json" -Headers $headers;
                if($result.status) {
                    if($result.status -eq "not found") {
                        Write-Host "Error encountered, job status for job id: $($jobId) has not been found, process will terminate" -ForegroundColor Red;
                        exit;
                    }
                    else {
                        Write-Host "Job status for job id: $($jobId) is $($result.status)" -ForegroundColor Green;
                    }
                }
                else {
                    if($result.estimatedTime) {
                        Write-Host "Job id: $($jobId) has not yet started, estimated time: $($result.estimatedTime) seconds" -ForegroundColor Green;
                    }
                    else {
                        Write-Host "Error encountered retrieving job status for job id: $($jobId), description: $($result.message), process will terminate" -ForegroundColor Red;
                        exit;
                    }
                }
            }
            catch {
                Write-Host "Error encountered retrieving job status for job id: $($jobId), description: $($_.Exception.Response.StatusDescription), status code: $($_.Exception.Response.StatusCode.value__), process will terminate" -ForegroundColor Red;
                exit;
            }
        } until ($result.status -and $result.status -notlike "*progress*")
 
        if($result.status -like "complete*") {
            Write-Host "Job status for job id: $($jobId) is complete, retrieving results" -ForegroundColor Green;
            try {
                $result = Invoke-RestMethod -Method Get -Uri "https://css.api.hp.com/productWarranty/v1/jobs/$($jobId)/results" -ContentType "application/json" -Headers $headers;
                $tempFileName = ([System.IO.Path]::GetTempFileName());
                Remove-Item $tempFileName -Recurse -Force -ErrorAction SilentlyContinue;
                Write-Host "Saving results to CSV file: $($tempFileName).csv" -ForegroundColor Green;
                $result | Export-Csv -Path "$($tempFileName).csv" -NoTypeInformation;
                Write-Host "Opening CSV file in Excel: $($tempFileName).csv" -ForegroundColor Green;
                Start-Process -FilePath Excel -ArgumentList "`"$($tempFileName).csv`"" -ErrorAction SilentlyContinue;
            }
            catch {
                Write-Host "Error encountered retrieving results for job id: $($jobId), description: $($_.Exception.Response.StatusDescription), status code: $($_.Exception.Response.StatusCode.value__), process will terminate" -ForegroundColor Red;
            }
        }
    }
    else {
        Write-Host "Error encountered submitting bulk warranty request, description: $($result.Root.message), process will terminate" -ForegroundColor Red;
    }
}