Import-Module -Name 'C:\Program Files (x86)\PowerShell Community Extensions\Pscx3\Pscx'
  
function downloadFile([string]$url, [string]$targetFile) {  
    "`nDownloading $url"  
    
    $uri = New-Object "System.Uri" "$url"  
    $request = [System.Net.HttpWebRequest]::Create($uri)  
    $request.set_Timeout(15000) #15 second timeout  
    $response = $request.GetResponse()  
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)  
    $responseStream = $response.GetResponseStream()  
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create  
    $buffer = new-object byte[] 10KB  
    $count = $responseStream.Read($buffer,0,$buffer.length)  
    $downloadedBytes = $count  
    while ($count -gt 0) { 
        [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop); 
        [System.Console]::Write("Downloaded {0}K of {1}K", [System.Math]::Floor($downloadedBytes/1024), $totalLength)  
        $targetStream.Write($buffer, 0, $count)  
        $count = $responseStream.Read($buffer,0,$buffer.length)  
        $downloadedBytes = $downloadedBytes + $count  
    }  
      
    "Finished Download"  
    $targetStream.Flush() 
    $targetStream.Close()  
    $targetStream.Dispose()  
    $responseStream.Dispose()  
}

"Description: Update Dart Editor to the latest nightly build."
"Author: Blake Niemyjski"
"Blogs: http://blakeniemyjski.com, http://windowscoding.com/blogs"
"Version: 1.0"

$basepath = "C:\Dart" 
$url = "http://gsdview.appspot.com/dart-editor-archive-continuous/latest/darteditor-win32-64.zip"

# Create the basepath if it doesn't exist.
if (!(Test-Path $basepath)) {
    New-Item -Path $basepath -ItemType directory
}

$zip = "$basepath\dart-editor.zip"
# Remove any previously downloaded zip if it exists.
if (Test-Path $zip) {
    Remove-Item $zip  
}  

try {
    downloadFile $url $zip  
} catch {
    "An error occurred while downloading the file: $url"
    Break
}

# Remove old backups.
if (Test-Path $basepath\Editor.old\) {  
    rd -r $basepath\Editor.old\  
}  

# Backup the current editor application if it exists.
if (Test-Path $basepath\Editor\) {  
    mv $basepath\Editor\ $basepath\Editor.old\  
}  

# Remove any previously extracted files.
if (Test-Path $basepath\Dart\) {  
    rd -r $basepath\Dart\
}

try {
    "`nExtracting $zip"
    Expand-Archive -Path $zip -OutputPath $basepath\  
} catch {
    "An error occurred while extracting the downloaded file. Please try again."
    Break
}

# Move the extracted Dart application to the Editor folder.
if (Test-Path $basepath\Dart\) {
    Rename-Item -Path $basepath\Dart\ -NewName "Editor"
}